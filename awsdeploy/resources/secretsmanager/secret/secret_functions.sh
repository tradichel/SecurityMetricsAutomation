#!/bin/bash -e
# https://github.com/tradichel/SecurityMetricsAutomation
# awsdeploy/resources/secretsmanager/secret/secret_functions.sh
# author: @teriradichel @2ndsightlab
# Description: deploy a secret
##############################################################
source deploy/shared/functions.sh

deploy_secret() {
  secretname="$1"
	kmskeyid="$2"
	secretvalue="$3"

  function=${FUNCNAME[0]}
  validate_var "$function" "secretname" "$secretname" 
  validate_var "$function" "kmskeyid" "$kmskeyid" 
  validate_var "$function" "secretvalue" "$secretvalue"
 
  parameters=$(add_parameter "NameParam" $secretname)
  parameters=$(add_parameter "KMSKeyID" $kmskeyid $parameters)
  parameters=$(add_parameter "SecretValue" $secretvalue $parameters)

  deploy_stack $secretname "secretsmanager" "secret" $parameters
}

#secret must exist
#secret id is:
#The ARN or name of the secret to add a new version to.
set_secret_string_value(){
	secretname="$1"
  key="$2"
	value="$3"

	#need to add logic to handle updates to existing json strings
	#insert: ,\"password\":\"EXAMPLE-PASSWORD\" before the last curly brace
	secretstring='{"'$key'":"'$value'"}'
	aws secretsmanager put-secret-value --secret-id $secretname \
		--secret-string $secretstring --profile $profile 
}

set_secret_textfile_value(){
  secretname="$1"
  file="$2"

  echo "Updating secret textfile value: $secretname" 
  aws secretsmanager put-secret-value --secret-id $secretname \
    --secret-string file://$file \
    --profile $profile
}

#pass in a binary file for file
set_secret_binary_value(){
  secretname="$1"
  file="$2"

	echo "Updating secret binary value: $secretname" 
  aws secretsmanager put-secret-value --secret-id $secretname \
		 --secret-binary fileb://$file \
  	 --profile $profile 
}

get_secret_value(){
  key="$1"
  secretname="$3"

  secret="$(aws secretsmanager get-secret-value --secret-id $secretname --query SecretString --output text --profile $profile)"
	value="$(echo $secret | jq -r ."$key")"
  validate_set $value "$key"
  validate_no_quotes $value
  echo $value

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
