#!/bin/bash -e
# https://github.com/tradichel/SecurityMetricsAutomation/
# IAM/stacks/Users/user_functions.sh
# author: @teriradichel @2ndsightlab
# description: Functions for user creation
##############################################################
source ../../../Functions/shared_functions.sh

profile="IAM"

deploy_user() {

	username="$1"
	console_access="$2"
	profile_override="$3"

  if [ "$profile_ovverride" != "" ]; then profile=$profile_override; fi
	
	function=${FUNCNAME[0]}
  validate_param "username" $username $function
	validate_param "console_access" $console_access $function

  template="cfn/User.yaml"
  resourcetype='User'
  parameters=$(add_parameter "NameParam" $username)
  
	if [ "$console_access" == "true" ]; then
  	parameters=$(add_parameter "ConsoleAccess" "true" $parameters)
	fi

	deploy_stack $profile $username $resourcetype $template $parameters
	
}

#using default profile to deploy first IAM user in an account
deploy_iam_admin() {

  username=$1

  function=${FUNCNAME[0]}
  validate_param "username" $username $function

	profile="ROOT"
	console_access="false"
	
  deploy_user $username $console_access $profile

}

create_ssh_key(){

	#name of ssh key, secret, and user
	keyname="$1"

	echo "--------------CREATE SSH KEY PAIR: $key-------------------"
	keys=$(aws ec2 describe-key-pairs)

	if [[ "$keys" == *"$keyname"* ]]; then
  	echo "Key pair found."
  	echo "Delete and re-create? (y)"
  	read createkey	
		if [ "$createkey" == "y" ]; then
			aws ec2 delete-key-pair --key-name $keyname --profile $profile
		else
			return 0
		fi
	fi
	
	#create keypair
  key=$(aws ec2 create-key-pair --key-name $keyname --profile $profile)
  keypem=$(echo $key | jq -r ".KeyMaterial")
	kmskeyid=$(get_stack_export "KMS-Key-DeveloperSecrets" "DeveloperSecretsKeyIDExport")
  
	#update the secret	
	cmd="aws secretsmanager update-secret --secret-id $keyname \
			--kms-key-id $kmskeyid --secret-string \"$keypem\" --profile $profile"

  secret=$(eval $cmd)
	
	#get secret id
	stackname='AppSec-Secret-'$keyname
	output=$keyname'SecretExport'
	secretid=$(get_stack_export $stackname $output)
	
	#update user iam policy to allow access to secret
  resourcetype='Policy'
  template='cfn/UserSecretPolicy.yaml'
  parameters=$(add_parameter "NameParam" $keyname)
	resource=$keyname'UserSecretPolicy'
  deploy_stack $profile $resource $resourcetype $template $parameters
	
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
