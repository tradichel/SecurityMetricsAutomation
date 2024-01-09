#!/bin/bash -e
# https://github.com/tradichel/SecurityMetricsAutomation/
# awsdeploy/resources/ssm/parameter/parameter_functions.sh
# author: @teriradichel @2ndsightlab
# description: Functions for AWS::SSM::Parameter
# and CLI scripts to deploy secure string parameters
##############################################################
source deploy/shared/functions.sh

#depoy with cloudformation
deploy_ssm_parameter(){

  name="$1"
  value="$2"

	echo "Parameters deployed via CloudFormation will be unencrypted"

  func=${FUNCNAME[0]}
  validate_var $func 'name' "$name"
 
 	cat="ssm"
	resourcetype='parameter'
  parameters=$(add_parameter "NameParam" $name)
  parameters=$(add_parameter "ValueParam" $value $parameters)

  deploy_stack $name $cat $resourcetype $parameters

}

ssm_parameter_exists(){
	ssm_name="$1"
  
  func=${FUNCNAME[0]}
  validate_var $func "name" "$ssm_name"

	v=$(aws ssm describe-parameters --filters "Key=Name,Values=$ssm_name" --profile $profile)	
	t=$(echo $v | jq '.Parameters | length')
	if [[ $t == 0 ]]; then
		echo "false"
	else
		echo "true"
	fi

}

get_ssm_parameter_value(){
  ssm_name="$1"

  func=${FUNCNAME[0]}
  validate_var $func "name" "$ssm_name"

	v=""
	exists=$(ssm_parameter_exists $ssm_name)
	if [ "$exists" == "true" ]; then
  	v=$(aws ssm get-parameter --name $ssm_name --with-decryption --query "Parameter.Value" --output text --profile $profile)
  fi
	echo $v
}

set_ssm_parameter_value(){
  ssm_name="$1"
  ssm_value="$2"
  parmtype="$3"
  tier="$4"
	kmskeyid="$5"

	#secure string doesn't work with 
	#cloudformation at the time I wrote
	#these scripts - default to standard,
	#secure string which is encrypted with 
	#the AWS managed KMS key
	
  if [ "$tier" == "" ]; then
    tier="Standard"
  fi

  if [ "$parmtype" == "" ]; then
    parmtype="SecureString"
  fi

  func=${FUNCNAME[0]}
  validate_var $func "name" "$ssm_name"
  validate_var $func "value" "$ssm_value"

	ssm_name=$ssm_name

	if [ "$kmskeyid" != "" ]; then
		echo "aws ssm put-parameter --name $ssm_name --key-id $kmskeyid \
    	--value $ssm_value --tier $tier --type 'SecureString' --profile $profile"
  	aws ssm put-parameter --name $ssm_name --overwrite --key-id $kmskeyid --value $ssm_value \
			 --tier $tier --type $parmtype --profile $profile
	else
    echo "aws ssm put-parameter --name $ssm_name \
      --value $ssm_value --tier $tier --type 'SecureString' --profile $profile"
    aws ssm put-parameter --name $ssm_name --overwrite --value $ssm_value \
       --tier $tier --type $parmtype --profile $profile
	fi
}

#deploy with scirpt
validate_ssm_parameter_value(){
	ssm_name="$1"
	kmskeyid="$2"
  ssm_value="$3"
	tier="$4"
	change="$5"

  if [ "$chnage" == "" ]; then change="y"; fi

  if [ "$tier" == "" ]; then tier="Standard"; fi

  if [ "$ssm_value" == "" ]; then ssm_value="[Not Set]"; fi

  func=${FUNCNAME[0]}
  validate_var $func "name" "$ssm_name"
  validate_var $func "kmskeyid" "$kmskeyid"

  if [ "$change" == "y" ]; then
    echo "Enter the new value for $ssm_name:"
    read ssm_value

    set_ssm_parameter_value "$ssm_name" "$keyid" "$ssm_value"
  fi
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
