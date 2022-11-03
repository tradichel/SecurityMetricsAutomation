#!/bin/bash -e
# https://github.com/tradichel/SecurityMetricsAutomation
# Delete/delete_functions.sh
# author: @teriradichel @2ndsightlab
####################################################################
get_stack_export(){

  stackname=$1
  exportname=$2

  value=""
  qry="Stacks[0].Outputs[?ExportName=='$exportname'].OutputValue"
  value=$(aws cloudformation describe-stacks --stack-name $stackname --query $qry --output text 2>/dev/null || true)

  echo $value

}

get_stack_status(){

  stack="$1"

  s=$(aws cloudformation describe-stacks --stack-name "$stack" --query Stacks[0].StackStatus --output text 2>&1 || true)	
	if [[ "$s" == *"does not exist"* ]]; then s="NOEXIST"; fi

	echo "$s"

}

stack_exists(){

  stack="$1"

	s=$(get_stack_status $stack)
	
	if [ "$s" == "NOEXIST" ]; then echo "false"; return; fi

  if [ "$s" == "DELETE_IN_PROGRESS" ]; then
			sleep 10
			echo $(stack_exists $stack)
 	else
		echo "true"
	fi

}

delete_stack() {

  stack="$1"
	confirm="$2"
	profile="$3"

	if [ "$profile" == "" ]; then profile="delete"; fi

  stack_exists=$(stack_exists $stack)
	if [ "$stack_exists" == "false" ]; then
		 echo "$stack does not exist"
		 return 0
	fi 

  if [ "$confirm" == "y" ]; then
    echo "Delete stack: $stack? (y to delete, any other key to skip)"; read ok
	else
		ok="y"
  fi
	
	if [ "$ok" == "y" ]; then
		echo "aws cloudformation delete-stack --stack-name $stack --profile $profile"
  	aws cloudformation delete-stack --stack-name $stack --profile $profile
	fi

	stack_exists=$(stack_exists $stack)
  if [ $stack_exists == "true" ]; then
		echo "Stack $stack was not deleted."
		exit
	else
		echo "Stack $stack was deleted." 
	fi 

}

delete_stacks(){

	stacks=("${!1}")
	resource="$2"
  confirm="$3"
	profile="$4"

  echo "Delete $resource resources? (y to delete, CTRL-C to exit, any key to continue)"; read ok
  if [ "$ok" != "y" ]; then return; fi 
  if [ "$profile" == "" ]; then profile="delete"; fi

	for stack in ${stacks[@]}; do
		delete_stack $stack $confirm $profile
 		echo "~~~~~~~~~~~~~~~~~~~~~~~~~~"
	done

}

delete_kms_keys(){

  aliases=("${!1}")
  confirm="$2"

  echo "Delete KMS key resources? (y to delete, CTRL-C to exit, any key to continue)"; read ok
  if [ "$ok" != "y" ]; then return; fi

  for alias in ${aliases[@]}; do
    delete_kms_key $alias $confirm
  done

}

key_exists() {

	keyid="$1"

	for key in $(aws kms describe-key --key-id $keyid --output text --profile $profile); do
		status=$(aws kms describe-key --query 'KeyMetadata.KeyState' --key-id $keyid --output text)
		if [ "$status" == "Enabled" ]; then echo "true"; return; fi
	done

	echo "false"

}

get_key_id() {

	alias="$1"

  aliasstack='KMS-Key-'$alias
  output=$alias'KeyIDExport'
  keyid=$(get_stack_export $aliasstack $output)
	
	echo $keyid

}

delete_aliases() {

	keyid="$1"

	profile="delete"

	echo "Delete alias for keyid: $keyid"

	for alias in $(aws kms list-aliases --key-id $keyid --output text --profile $profile); do
		profile="KMS"
		echo "Delete key alias: $alias for keyid $keyid"
		echo "aws kms delete-alias --alias-name alias/$alias --profile $profile || true"
		aws kms delete-alias --alias-name alias/$alias --profile $profile || true
		profile="delete"
	done

}

delete_kms_key() {

  alias="$1"
	confirm="$2"

	profile="delete"

	keyid=$(get_key_id $alias)
	if [ "$keyid" == "" ]; then 
		echo "Key stack does not exist for key alias: $alias"
	else
		exists=$(key_exists $keyid)
		if [ "$exists" == "false" ]; then 
			echo "KMS key $keyid does not exist or is pending deletion"
 		else 
			echo "Key exists: $keyid"; 
 			delete_aliases $keyid
  		profile="KMS"
			echo "aws kms schedule-key-deletion --key-id $keyid --pending-window-in-days 7 --profile $profile || true"
  		aws kms schedule-key-deletion --key-id $keyid --pending-window-in-days 7 --profile $profile || true
		fi
 
 		keystack="KMS-Key-$alias"
 		delete_stack $keystack $confirm "KMS"
	fi

	keystack="KMS-KeyAlias-$alias"
	delete_stack $keystack $confirm "KMS"

}

delete_kms_admins(){

  echo "Delete KMS admins? (y to delete, CTRL-C to exit, any key to continue)"; read ok
  if [ "$ok" != "y" ]; then return; fi

 	countkeys=0
	profile="delete"

  echo ""; echo "Keys in this AWS Account: "
	for key in $(aws kms list-keys --query 'Keys[*].KeyId' --output text --profile $profile); do

    status=$(aws kms describe-key --query 'KeyMetadata.KeyState' --key-id $key --output text)
    manager=$(aws kms describe-key --query 'KeyMetadata.KeyManager' --key-id $key --output text)

    if [ "$status" == "Enabled" ]; then
      if [ "$manager" == "CUSTOMER" ]; then
        countkeys=countkeys+1
        alias=$(aws kms list-aliases --key-id $key --query 'Aliases[*].AliasName' \
          --query 'Aliases[*].AliasName' --output text)
        echo $key' '$alias' '$status'  '$manager
      fi
    fi

  done

  if [ $countkeys > 0 ]; then
      echo "If delete KMS Admins any keys that only they can administer cannot be deleted or edited. Continue?"
      read continue; if [ "$continue" != "y" ]; then exit; fi
  else
      echo "All KMS key stacks deleted"
  fi

  delete_iam_profile "KMSAdmins" "y"

}

delete_iam_profiles(){

  profiles=("${!1}")
  confirm="$2"

  profile="delete"

	echo "Delete IAM Profiles? (y to delete, CTRL-C to exit, any key to continue)"; read ok
  if [ "$ok" != "y" ]; then exit; fi

  for iamprofile in ${profiles[@]}; do
		echo "Delete IAM Profile: $iamprofile"
    delete_iam_profile $iamprofile $confirm
  done

}

delete_iam_profile() {

  iamprofile="$1"
  confirm="$2"

  stacks=('IAM-UserToGroupAddition-AddUsersTo'$iamprofile 
    				'IAM-Policy-'$iamprofile'GroupPolicy' 
    				'IAM-Policy-'$iamprofile'GroupRolePolicy'
    				'IAM-Policy-'$iamprofile'GroupRoleKMSPolicy'
						'IAM-Policy-'$iamprofile
    				'IAM-Role-'$iamprofile'Role'
            'IAM-Role-'$iamprofile'Group'
     				'IAM-Group-'$iamprofile)
    
  delete_stacks stacks[@] "IAM Profile: $iamprofile" $confirm 

}
