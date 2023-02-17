#!/bin/bash -e
# https://github.com/tradichel/SecurityMetricsAutomation/
# Org/stacks/Secrets/secret_functions.sh
# author: @teriradichel @2ndsightlab
# description: Functions for user creation
##############################################################
source ../../../Functions/shared_functions.sh

profile="OrgRoot"

create_secret(){

	secretname="$1"
	kmskeyid="$2"
	value="$3"

	if [ "$value" == "" ]; then value="temp-value-for-secret-creation"; fi

  func=${FUNCNAME[0]}
  validate_param 'secretname' $secretname $func
  validate_param 'kmskeyid' $kmskeyid $func

  #create secret
  resourcetype='Secret'
  template='cfn/Secret.yaml'
  parameters=$(add_parameter "NameParam" $secretname)
  parameters=$(add_parameter "KMSKeyID" $kmskeyid $parameters)
  deploy_stack $profile $secretname $resourcetype $template $parameters

}

################################################################################
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
