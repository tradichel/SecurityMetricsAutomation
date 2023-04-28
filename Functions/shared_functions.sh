#!/bin/bash
# https://github.com/tradichel/SecurityMetricsAutomation
# Functions/shared_functions.sh
# author: @teriradichel @2ndsightlab
##############################################################
validate_param(){
  name="$1"
  value="$2"
  func="$3"

  if [ "$func" == "" ]; then
    echo 'Parameter '$name' and function name must be provided to validate_param' 1>&2
    exit 1
	fi

  if [ "$value" == "" ]; then
    echo 'Parameter '$name' must be provided to function '$func 1>&2
		exit 1
  fi

}

get_stack_export(){

  stackname=$1
  exportname=$2

  func=${FUNCNAME[0]}
  validate_param 'stackname' $stackname $func
  validate_param 'exportname' $exportname $func

  qry="Stacks[0].Outputs[?ExportName=='$exportname'].OutputValue"
  value=$(aws cloudformation describe-stacks --stack-name $stackname --query $qry --output text --profile $profile)

  if [ "$value" == "" ]; then
    echo 'Export '$exportname' for stack '$stackname' did not return a value' 1>&2
    exit 1
  fi

	echo $value
}

get_kms_key_id(){
	alias="$1"
	stackprofile="$2"

	if [ "$profile" == "" ]; then
		stackprofile="KMS"
	fi

  func=${FUNCNAME[0]}
  validate_param 'alias' $alias $func

	keystack=$stackprofile'-Key-'$alias
	keyexport=$alias'KeyIDExport'

	kmskeyid=$(get_stack_export $keystack $keyexport)
	echo $kmskeyid

}

get_stack_status() {

	stackname="$1"
        
  echo $(aws cloudformation describe-stacks --stack-name $stackname \
     --query Stacks[0].StackStatus --output text 2>/dev/null || true) 

}

iam_allowed_profile(){
  profile="$1"
  if [ "$profile" == "IAM" ]; then echo true; exit; fi
  if [ "$profile" == "OrgRoot" ]; then echo true; exit; fi 
  if [ "$profile" == "ROOT" ]; then echo true; exit; fi
  if [ "$profile" == "AppSec" ]; then echo true; exit; fi
  if [ "$profile" == "Sandbox" ]; then echo true; exit; fi
  echo false;
}

#pass in parameters in this format, with quotes:
#"key=value","key=value","key="value"
deploy_stack () {

  profile="$1"
  resourcename="$2"
  resourcetype="$3"
  template="$4"

 	#adding brackets here to avoid repetitive code elsewhere
  parameters="[$5]"

  func=${FUNCNAME[0]}
  validate_param 'profile' $profile $func
  validate_param 'resourcename' $resourcename $func
  validate_param 'resourcetype' $resourcetype $func
  validate_param 'template' $template $func
	#not all stacks have parameters

  stackname=$profile'-'$resourcetype'-'$resourcename
	status=$(get_stack_status $stackname)
	
	if [ "$status" == "ROLLBACK_COMPLETE" ]; then
		aws cloudformation delete-stack --stack-name $stackname  
        while [ "$(get_stack_status $stackname)" == "DELETE_IN_PROGRESS" ]
        do
		sleep 5
		done
	fi

  echo "-------------- $stackname -------------------"

	c="aws cloudformation deploy --profile $profile 
			--stack-name $stackname 
      --template-file $template "
  
  iam_allowed=$(iam_allowed_profile $profile)
 
	echo "IAM ALLOWED: $iam_allowed"
 
 	if [ "$iam_allowed" = true ]; then
          c=$c' --capabilities CAPABILITY_NAMED_IAM '
	fi

	if [ "$parameters" != "" ]; then 
  	  c=$c' --parameter-overrides '$parameters
	fi

	echo $c

  ($c)

}

get_timestamp() {

  timestamp="$(date)"
  timestamp=$(echo $timestamp | sed 's/ //g')
	echo $timestamp

}

add_parameter () {

  key="$1"
  value="$2"
  params="$3"

  p="\"$key=$value\""
  if [ "$params" == "" ]; then echo $p; exit; fi
	echo $params,$p

}

get_users_in_group() {
	groupname="$1"
	profile="$2"

 	func=${FUNCNAME[0]}
  validate_param 'groupname' $groupname $func
  validate_param 'profile' $profile $func

	#retrieve a list of user ARNs in the group
  users=$(aws iam get-group --group-name $groupname --profile $profile \
      --query Users[*].Arn --output text | sed 's/\t/,/g')

	echo $users

}

get_organization_id(){
   orgid=$(aws organizations describe-organization --query 'Organization.Id' --output text)
   echo $orgid
}

get_account_id(){
  acctid=$(aws sts get-caller-identity --query Account --output text)
  echo $acctid
}

get_account_org_role(){
  acctname="$1"

  orgprefix=$(aws secretsmanager get-secret-value --secret-id OrgPrefix --query SecretString --output text --profile $profile)
  rolename="$orgprefix-$acctname"

  echo $rolename
}

get_account_number(){
    accountname="$1"
  
    stack='OrgRoot-Account-'$accountname
    exportname=$accountname'Account'
    acctnum=$(get_stack_export $stack $exportname $profile)
    echo $acctnum
  }

create_cross_account_role_profile(){
  acctnum=$1
  rolename=$2
  roleprofile="$3"

  if [ "$roleprofile" == "" ]; then roleprofile=$rolename; fi

  arn="arn:aws:iam::$acctnum:role/$rolename"
  sessionName=$profile'Session'
  creds=$(aws sts assume-role --role-arn "$arn" --role-session-name $sessionName --profile $profile)

  AWS_ACCESS_KEY_ID=$(echo $creds | jq -r '.Credentials''.AccessKeyId');
  AWS_SECRET_ACCESS_KEY=$(echo $creds | jq -r '.Credentials''.SecretAccessKey');
  AWS_SESSION_TOKEN=$(echo $creds | jq -r '.Credentials''.SessionToken');

  aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID --profile $roleprofile
  aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY --profile $roleprofile
  aws configure set aws_session_token $AWS_SESSION_TOKEN --profile $roleprofile
  region=$(get_current_region)
  aws configure set region $region --profile $roleprofile

  #return new profile name
  echo "$roleprofile"

  #check values for testing only
  #will mess up any code counting on te rolename returin
  #echo "~/.aws/config"
  #cat ~/.aws/config
  #echo "~/.aws/credentials"
  #cat ~/.aws/credentials
 
}

assume_cross_account_role(){

  account=$1
  profile=$2

  #retrieve the sandbox account number
  stack='OrgRoot-Account-'$account
  exportname=$account'Account'
  sbacctnum=$(get_stack_export $stack $exportname)

  orgprefix=$(aws secretsmanager get-secret-value --secret-id OrgPrefix --query SecretString --output text)
  rolename="$orgprefix-$account"
  arn="arn:aws:iam::$sbacctnum:role/$rolename"

  echo $arn

  sessionName=$profile'Session'
  echo "aws sts assume-role --role-arn $arn --role-session-name $sessionName"
  creds=$(aws sts assume-role --role-arn $arn --role-session-name $sessionName)

  AWS_ACCESS_KEY_ID=$(echo $creds | jq -r '.Credentials''.AccessKeyId');
  AWS_SECRET_ACCESS_KEY=$(echo $creds | jq -r '.Credentials''.SecretAccessKey');
  AWS_SESSION_TOKEN=$(echo $creds | jq -r '.Credentials''.SessionToken');

  #for testing only - should not normally echo credentials to logs!
  #echo $AWS_ACCESS_KEY_ID
  #echo $AWS_SECRET_ACCESS_KEY
  #echo $AWS_SESSION_TOKEN

  export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
  export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
  export AWS_SESSION_TOKEN=$AWS_SESSION_TOKEN

  echo "Caller identity:"
  aws sts get-caller-identity

}

stop_assume_cross_account_role(){
 
  unset AWS_ACCESS_KEY_ID
  unset AWS_SECRET_ACCESS_KEY
  unset AWS_SESSION_TOKEN

  echo "Caller identity:"
  aws sts get-caller-identity

}

#may have to modify this if this var
#is not nost to also check
#aws configure get region
get_current_region(){
   echo $AWS_DEFAULT_REGION
}


#################################################################################
# Copyright Notice
# All Rights Reserved.
# All materials (the “Materials”) in this repository are protected by copyright 
# under U.S. Copyright laws and are the property of 2nd Sight Lab. They are provided 
# pursuant to a royalty free, perpetual license the person to whom they were presented 
# by 2nd Sight Lab and are solely for the training and education by 2nd Sight Lab.
#
# The Materials may not be copied, reproduced, distributed, offered for sale, published, 
# displayed, performed, modified, used to create derivative works, transmitted to 
# others, or used or exploited in any way, including, in whole or in part, as training 
# materials by or for any third party.
#
# The above copyright notice and this permission notice shall be included in all 
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
# INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A 
# PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT 
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION 
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
################################################################################ 
                                                                                     
