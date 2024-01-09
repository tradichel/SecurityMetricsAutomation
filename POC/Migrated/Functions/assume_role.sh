#!/bin/bash 
# https://gitub.com/tradichel/SecurityMetricsAutomation
# Functions/assume_role.sh
# author: @terradichel @2ndsightlab
##############################################################


#this function is very hokey and it presumes:
#1. You have performed a git clone
#2. You did not change the name of the SecurityMetricsAutomation directory 
get_base_path(){

  #me=$(basename "$0")
  #p=$(locate $me)
  p=$(pwd)
  p=$(echo $p | sed 's/SecurityMetricsAutomation.*$//g')
  p=$p'SecurityMetricsAutomation'
  echo $p

}

if [ "$SOURCE" != "true" ]; then
	 sma_path=$(get_base_path)
   source $sma_path'/Functions/shared_functions.sh'
   SOURCE="true"
fi

get_account_org_role(){
  acctname="$1"

  orgprefix=$(aws secretsmanager get-secret-value --secret-id OrgPrefix --query SecretString --output text --profile $profile)
  rolename="$orgprefix-$acctname"

  echo $rolename
}

check_profile(){
  profile="$1"
  aws configure --profile $profile list
}

check_profiles(){
	#check values for testing only
	#will mess up any code counting on te rolename returin
	echo "~/.aws/config"
	cat ~/.aws/config
	echo "~/.aws/credentials"
	cat ~/.aws/credentials
}

set_profile(){
  p=$1
  if [ "$profile" != "$p" ]; then
      echo "Set profile: $p"
      profile="$p"
      check_profile $profile
  fi
}

get_source(){
	
	dir=""
	source_file=""
	prof=""

	dir="$1"
	source_file="$2"
	prof="$3"

	echo "Get Source: directory: $dir file $source_file Profile: $prof"

  function=${FUNCNAME[0]}
  validate_param "dir" "$dir" "$function"
  validate_param "dir" "$source_file" "$function"
  validate_param "prof" "$prof" "$function"

	echo "Change to directory $dir and profile $prof source $source_file"
	cd "$dir"
	source "$source_file"
	profile=$prof

}

change_dir(){
  dir="$1" #dir to change to (KMS, IAM, etc.)
  two="$2" #profile if 3 does not exist
	three="$3" #profile if exists

	#the reason for this hokey code is because I modified the code to be more simple
	#the second parameter is no longer needed, but some old code still passes it in
	#once all code revised to match no longer need the last parameter and
	#the second parameter is always the profile
	#if three params, profile is the last, otherwise the 2nd param is the profile
	if [ "$three" != "" ]; then
		prof=$three
	else
		prof=$two
	fi

	#get the base path
	if [ $SOURCE != 'true' ]; then
		sma_path=$(get_base_path)
	fi
	
	echo "Base Path: $sma_path"

	#if profile is not passed in, use existing profile
	if [ "$prof" == "" ]; then prof=$profile; fi

  echo "Change to directory $dir and profile $profile source $source_file"
  function=${FUNCNAME[0]}
  validate_param "dir" "$dir" "$function"
 
  if [ "$dir" == "Lambda" ]; then
    get_source $sma_path/Apps/$dir/stacks/ "lambda_functions.sh" $prof; return
  fi

  if [ "$dir" == "ECR" ]; then
    get_source $sma_path/AppSec/stacks/$dir "ecr_functions.sh" $prof; return
  fi

  if [ "$dir" == "GitHub" ]; then
    get_source $sma_path/SourceControl/$dir "git_functions.sh" $prof; return
  fi

  if [ "$dir" == "CodeCommit" ]; then
    get_source $sma_path/SourceControl/$dir/stacks "codecommit_functions.sh" $prof; return
  fi

  if [ "$dir" == "Organization" ]; then
		get_source "$sma_path/Org/stacks/$dir" "organization_functions.sh" $prof; return
  fi

  if [ "$dir" == "OU" ]; then
    get_source "$sma_path/Org/stacks/$dir/" "ou_functions.sh" $prof; return
  fi

  if [ "$dir" == "Account" ]; then
    get_source "$sma_path/Org/stacks/$dir/" "account_functions.sh" $prof; return
  fi

  if [ "$dir" == "Key" ]; then
    get_source "$sma_path/KMS/stacks/$dir" "key_functions.sh" $prof; return
  fi

  if [ "$dir" == "KeyAlias" ]; then
    get_source "$sma_path/KMS/stacks/$dir" "keyalias_functions.sh" $prof; return
  fi

  if [ "$dir" == "SSM" ]; then
    get_source $sma_path/AppSec/stacks/SSMParameters "parameter_fuctions.sh" $prof; return
  fi

  if [ "$dir" == "IAMGroup" ]; then
    get_source $sma_path/IAM/stacks/Group "group_functions.sh" $prof; return
  fi

  if [ "$dir" == "IAMRole" ]; then
    get_source $sma_path/IAM/stacks/Role "role_functions.sh" $prof; return
  fi

  if [ "$dir" == "IAMUser" ]; then
   	get_source $sma_path/IAM/stacks/User "user_functions.sh" $prof; return
  fi

  if [ "$dir" == "DNS" ]; then
    get_source $sma_path/DNS/stacks/ "dns_functions.sh" $prof; return
  fi

	#should change this to certificate
	if [ "$dir" == "AppSec" ]; then
		get_source $sma_path/AppSec/stacks/CertificateManager/ "certificate_functions.sh" $prof; return
	fi

  if [ "$dir" == "Secret" ]; then
    get_source $sma_path/AppSec/stacks/Secrets/ "secrets_functions.sh" $prof; return
  fi

  if [ "$dir" == "S3" ]; then
		get_source $sma_path/S3/stacks/ "s3_functions.sh" $prof; return
  fi
}

#create an AWS cross account role profile
#all cross account roles in this code require MFA
create_cross_account_role_profile(){
  acctnum="$1"
  rolename="$2" #role to assume
  mfa="$3"
	region="$4"

  function=${FUNCNAME[0]}
  validate_param "acctnum" "$acctnum" "$function"
  validate_param "rolename" "$rolename" "$function"

  arn="arn:aws:iam::$acctnum:role/$rolename"
  sessionName=$rolename'Session'

	if [ "$mfa" == "true" ]; then

	  #this works for ubikeys and virtual - if you use something else you might need
	  #to modify this code as I don't know what the output looks like
	  #profile must have specific user credentials for this to work
	  mfaserial=$(aws iam list-mfa-devices --profile $profile --output text | grep -v utf | head -n 1 | cut -f3)
  
    if [ "$mfaserial" == "" ]; then
		  echo "You must add a virtual MFA device to your use account to assume roles that require mfa."
			return 1
		fi
     	
	  echo "Enter mfa token"
	  read token

	  creds=$(aws sts assume-role --role-arn "$arn" \
        --role-session-name $sessionName \
        --profile $profile \
        --serial-number $mfaserial \
        --token-code $token)
 
  else
    creds=$(aws sts assume-role --role-arn "$arn" \
        --role-session-name $sessionName \
        --profile $profile)
	fi

  AWS_ACCESS_KEY_ID=$(echo $creds | jq -r '.Credentials''.AccessKeyId');
  AWS_SECRET_ACCESS_KEY=$(echo $creds | jq -r '.Credentials''.SecretAccessKey');
  AWS_SESSION_TOKEN=$(echo $creds | jq -r '.Credentials''.SessionToken');

	if [ "$region" == "" ]; then

  	region=$(get_current_region)
		if [ "$region" == "" ]; then 
			echo "No region found for profile $profile"
	  	exit 1
		fi
	fi
  
	aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID --profile $rolename
  aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY --profile $rolename
  aws configure set aws_session_token $AWS_SESSION_TOKEN --profile $rolename
  aws configure set region $region --profile $rolename
	if [ "$mfaserial" != "" ]; then
		aws configure set mfa_serial $mfaserial --profile $rolename
  fi
  aws configure set output "json" --profile $rolename
	
  echo "Created AWS CLI profile: $rolename"
}

assume_cross_account_role(){

  accountnum="$1"
	orgprefix="$2"
	accountname="$3"
  profile="$4"
  mfa="$5"

  rolename="$orgprefix-$account"
  arn="arn:aws:iam::$sbacctnum:role/$rolename"

  echo $arn

  sessionName=$rolename'Session'

  if [ "$mfa" == "true" ]; then
    #this works for ubikeys and virtual - fi you use something else you might need
    #to modify this code as I don't know what the output looks like
    mfaserial=$(aws iam list-mfa-devices --profile $profile --output text | grep -v utf | head -n 1 | cut -f3)

    if [ "$mfaserial" == "" ]; then
      echo "You must add a virtual MFA device to your use account to assume roles that require mfa."
      return 1
    fi

    echo "Enter mfa token"
    read token

    creds=$(aws sts assume-role --role-arn "$arn" \
        --role-session-name $sessionName \
        --profile $profile \
        --serial-number $mfaserial \
        --token-code $token)

  else
    creds=$(aws sts assume-role --role-arn "$arn" \
        --role-session-name $sessionName \
        --profile $profile)
  fi

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
 
assume_role_w_mfa_externalid(){
	accountid="$1"
	rolename="$2"
	mfatoken="$3"
	mfaserial="$4"
	externalid="$5"
  profile="$6"

	#temp hack for testing
	if [ "$profile" == "" ]; then 
		profile="hacker"
  fi

	assumerole="arn:aws:iam::"$accountid":role/$rolename"
	assumerolejson=$(aws sts assume-role --role-arn $assumerole  --role-session-name $rolename --profile $profile --external-id $externalid --token-code $token --serial-number $mfaserial --output text)
	id=$(echo $assumerolejson | jq .Credentials.AccessKeyId)
	accesskey=$(echo $assumerolejson | jq .Credentials.SecretAccessKey)
	session=$(echo $assumerolejson | jq .Credentials.SessionToken)

	export AWS_ACCESS_KEY_ID=$id
	export AWS_SECRET_ACCESS_KEY=$accesskey
	export AWS_SESSION_TOKEN=$session
	
	aws sts get-caller-identity
}

stop_assume_cross_account_role(){
 
  unset AWS_ACCESS_KEY_ID
  unset AWS_SECRET_ACCESS_KEY
  unset AWS_SESSION_TOKEN

  echo "Caller identity:"
  aws sts get-caller-identity

}

get_current_region(){
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
                                                                                     
