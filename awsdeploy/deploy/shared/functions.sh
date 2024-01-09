#!/bin/bash
# https://github.com/tradichel/SecurityMetricsAutomation
# Functions/shared_functions.sh
# author: @teriradichel @2ndsightlab
# WARNING: Bash is not a very safe language
# There is no scoping so if you use the same varname
# in multiple functions and you call both you can end up
# with overwritten values. Be careful.
##############################################################

replace_template_var(){
  tmpfile="$1"
  placeholder="$2"
  value="$3"

  func=${FUNCNAME[0]}
  validate_set $func 'tmpfile' $tmpfile
  validate_set $func 'placeholder' $placeholder
  validate_set $func 'value' $value

  #remove quotes from value
  value=$(echo $value | sed "s/'//g" | sed 's/"//g')
  echo sed -i "s|{{$placeholder}}|$value|g" $tmpfile
  sed -i "s|{{$placeholder}}|$value|g" $tmpfile
  cat $tmpfile

}

get_container_parameter_value(){
	params="$1"
  pname="$2"
	
	func=${FUNCNAME[0]}
	validate_set $func 'params' $params
	validate_set $func 'pname' $pname

	for p in ${params//,/ }
	do
  	n=$(echo $p | cut -d "=" -f1)
  	if [ "$n" == "$pname" ]; then
			value=$(echo $p | sed 's/,//g' | cut -d "=" -f2)
			#if value starts with [ get everyting to end because it's the parameter list to forward; remove the ]
			if [[ $value == [* ]]; then
				value=$(echo $params | cut -d '[' -f2 | sed 's/]//g')
			fi
			echo $value
			exit
  	fi
	done

	#may have optional parameter
	#need to check if value is set outside of this function because bash
	
}

configure_cli_profile(){
	role="$1"
	access_key_id="$2"
	aws_secret_access_key="$3"
	region="$4"
	mfa_serial="$5"

	output="json"

	aws configure set aws_access_key_id $access_key_id --profile $role
	aws configure set aws_secret_access_key $secret_key --profile $role
	aws configure set region $region --profile $role
	aws configure set output "json" --profile $role
	aws configure set mfa_serial $mfa_serial --profile $role

	aws sts get-caller-identity --profile $role
}

get_region_for_profile(){
	profile="$1"

  func=${FUNCNAME[0]}
  validate_set $func 'profile' $profile

	region=$(aws configure list --profile $profile | grep region | awk '{print $2}')
	echo $region
}

get_account_for_profile(){
	profile="$1"

  func=${FUNCNAME[0]}
  validate_set $func 'profile' $profile

	account=$(aws sts get-caller-identity --query Account --output text --profile $profile)
	echo $account
}

get_stack_export(){

  stackname=$1
  exportname=$2

  func=${FUNCNAME[0]}
  validate_set "$func" 'stackname' "$stackname"
  validate_set "$func" 'exportname' "$exportname"

  qry="Stacks[0].Outputs[?ExportName=='$exportname'].OutputValue"
  value=$(aws cloudformation describe-stacks --stack-name $stackname --query $qry --output text \
		--profile $profile --region $region)

  if [ "$value" == "" ]; then
    echo 'Export '$exportname' for stack '$stackname' did not return a value' 1>&2
    exit 1
  fi

  if [ "$value" == "None" ]; then
    echo 'Export '$exportname' for stack '$stackname' did not return a value' 1>&2
    exit 1
  fi

	echo $value

}


#get id from cloudforamtion stack
get_id_from_stack(){
	role="$1"
	resource_cat="$2"
	resource_type="$3"
	resource_name="$4"
	env="$5"

  resource="$resource_cat-$resource_type-$env-$resource_name"
  stack="$role-$resource"
  output="arn-$resource"

	id=$(get_stack_export $stack $output)	
	echo $id

}

#get arn from cloudformation stack
get_arn_from_stack(){
  role="$1"
  resource_cat="$2"
  resource_type="$3"
  resource_name="$4"
  env="$5"

	resource="$resource_cat-$resource_type-$env-$resource_name"
	stack="$role-$resource"
	output="arn-$resource"

  arn=$(get_stack_export $stack $output)        
  echo $arn
}

get_stack_status() {

	stackname="$1"

  echo $(aws cloudformation describe-stacks --stack-name $stackname --region $region \
     --query Stacks[0].StackStatus --output text --profile $profile 2>/dev/null || true) 

}

display_stack_errors(){
	stackname="$1"
	profile="$2"

	aws cloudformation describe-stack-events --stack-name $stackname --max-items 5 \
		--region $region --profile $profile | grep -i "status"
}

#get the role that is making the call to deploy something
get_role_name(){
	#rolenames cannot start with a letter or the stack name will fail.
  role=$(aws sts get-caller-identity --region $region --profile $profile --output text --query Arn | cut -d '/' -f2)
	echo $role
}

get_role_arn(){
  #rolenames cannot start with a letter or the stack name will fail.
  role=$(aws sts get-caller-identity --profile $profile --region $region --output text --query Arn)
  echo $role
}

#REQUIREMENTS:
#must execute scripts from the directory containing the /resources and /deploy directories.
#must set the value of $profile before calling this function
#pass in parameters in this format, with quotes:
#"key=value","key=value","key=value"
deploy_stack () {
  resourcename="$1"
	category="$2"
  resourcetype="$3"
  parameters="$4"
	template="$5"

  func=${FUNCNAME[0]}
  validate_set $func 'resourcename' $resourcename
  validate_set $func 'resourcetype' $resourcetype
  validate_set $func 'category' $category
  validate_set $func 'region' $region
  validate_set $func 'profile' $profile

	#usernames do not need to be prefixed with environment
	if [ "$resourcetype" == "user" ]; then
		echo "Deploying user: $user"
	else

		#kms key aliases start with alias/ because why? IDK
		if [ "$resourcetype" == "keyalias" ]; then
			resourcename=$(echo $resourcename | cut -d "/" -f2)
		fi

		#the prefix before the dash should be the environment name
		env=$(echo $resourcename | cut -d "-" -f1)
	
		#if the name is missing after "env-" throw an error
		if [ "$(echo $resourcename | cut -d "-" -f2)" == "" ];	then
			echo "Invalid resource name $resourcename" 1>&2
			exit 1
		fi
		
		#validate the environment variable is a valid value
		validate_environment $func $env $resourcename
	
	fi
 
	#resource name is template name if not overridden
	if [ "$template" == "" ]; then template=$resourcetype'.yaml';fi
	
	if ! [[ "$template" =~ '/' ]]; then
		template='resources/'$category'/'$resourcetype'/'$template
	fi

	#add parameters if any were passed in
  if [ "$parameters" != "" ]; then parameters="[$parameters]"; fi
	
	#formulate the stack name
  stackname=$profile'-'$category'-'$resourcetype'-'$resourcename
	
	#get the status if the stack already exists
	status=$(get_stack_status $stackname)

	#delete the stack if it already exists
	if [ "$status" == "ROLLBACK_COMPLETE" ]; then
		aws cloudformation delete-stack --stack-name $stackname --region $region --profile $profile  
        while [ "$(get_stack_status $stackname)" == "DELETE_IN_PROGRESS" ]
        do
		sleep 5
		done
	fi

  echo "-------------- Deploying $stackname -------------------"

	c="aws cloudformation deploy --profile $profile 
			--stack-name $stackname --region $region
      --template-file $template"  
	
  #allowing IAM for all stacks; presume IAM Policies, SCPs, 
  #and Permission Boundaries will handle this, which is more appropriate
	c=$c' --capabilities CAPABILITY_NAMED_IAM '

	if [ "$parameters" != "" ]; then 
  	  c=$c' --parameter-overrides '$parameters
	fi

	echo "$c"
		
	e="display_stack_errors $stackname $profile"

	cd /job

  {	($c) } || { ($e) }	
}

get_timestamp() {

  timestamp="$(date)"
  timestamp=$(echo $timestamp | sed 's/ //g')
	echo $timestamp

}

add_parameter () {
  paramkey=$1
  paramvalue=$2
  addtoparams=$3

	func=${FUNCNAME[0]}
	validate_set $func "key" $paramkey
	validate_set $func "value" $paramvalue
 
	addp="\"$paramkey=$paramvalue\""	
  if [ "$addtoparams" == "" ]; then echo $addp; exit; fi
  echo $addtoparams,$addp
	
}

get_users_in_group() {
	groupname="$1"
	profile="$2"

 	func=${FUNCNAME[0]}
  validate_set "$func" 'groupname' "$groupname"
  validate_set "$func" 'profile' "$profile"

	#retrieve a list of user ARNs in the group
  users=$(aws iam get-group --group-name $groupname --profile $profile --region $region \
      --query Users[*].Arn --output text | sed 's/\t/,/g')

	echo $users

}

#replace a var in {{ }}
replace_placeholder() {
	name="$1"
	value="$2"
	file="$3"

  s=$(sed -i "s|$name|$value|g" $file)
}

#get the current account ID where resources will be deployed
get_account_id(){
  acctid=$(aws sts get-caller-identity --query Account --output text --profile $profile --region $region)
  echo $acctid
}

#get_account_number moved to account_functions.sh

get_current_region(){
	echo $(get_profile_region)
}

get_profile_region(){
   region=$AWS_DEFAULT_REGION
	 if [ "$region" == "" ]; then 
	 	 region=$(aws configure get region --profile $profile)	
	 fi
	 echo $region
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
                                                                                     
