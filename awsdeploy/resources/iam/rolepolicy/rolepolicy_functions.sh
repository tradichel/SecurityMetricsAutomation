#!/bin/bash -e
# https://github.com/tradichel/SecurityMetricsAutomation
# awsdeploy/resources/iam/rolepolicy/rolepolicy_functions.sh
# author: @teriradichel @2ndsightlab
# Description: Policy that allows deployment of organization resources
##############################################################
source deploy/shared/functions.sh
source deploy/shared/validate.sh

deploy_rolepolicy() {

  rolepolicyname="$1"
  rolearn="2"
  env="$3"

  function=${FUNCNAME[0]}
  validate_var "$function" "rolepolicyname" "$rolepolicyname"
  validate_var "$function" "rolearn" "$rolearn"
  validate_var "$function" "env" "$env"
  
	validate_environment $env

  rolepolicyname="$env-$rolepolicyname"

  parameters=$(add_parameter "NameParam" $rolepolicyname)
  parameters=$(add_parameter "RoleArnParam" $rolepolicyarn $parameters)

	template=$rolepolicyname'.yaml'

  deploy_stack $rolepolicyname "iam" "rolepolicy" $parameters $template

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
