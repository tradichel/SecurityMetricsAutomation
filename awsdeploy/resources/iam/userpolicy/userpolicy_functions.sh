#!/bin/bash -e
# https://github.com/tradichel/SecurityMetricsAutomation
# awsdeploy/deploy/rootadminrole/iam_userpolicy_orgadminuserpolicy.sh
# author: @teriradichel @2ndsightlab
# Description: functions for user policies
##############################################################


source deploy/shared/functions.sh
source deploy/shared/validate.sh
source resources/organizations/organization/organization_functions.sh

deploy_userpolicy() {

  userpolicyname="$1"

  function=${FUNCNAME[0]}
  validate_var $function "userpolicyname" $userpolicyname
  
	env=$(echo $userpolicyname | cut -d "-" -f1)
	validate_environment $env

	managementaccountid=$(get_management_account_number)

  parameters=$(add_parameter "NameParam" $userpolicyname)
  parameters=$(add_parameter "ManagementAccountIdParam" $managementaccountid)

  template=$userpolicyname'.yaml'

  deploy_stack $userpolicyname "iam" "userpolicy" $parameters $template

}

#deploy a user policy to allow a user to access their
#own secret named [env]-[username]
#
deploy_secret_userpolicy(){

  #not done#
  category='IAM'
  resourcetype='userpolicy'
  template='usersecretpolicy.yaml'
  parameters=$(add_parameter "NameParam" $keyname)
  resource=$keyname'UserSecretPolicy'
  deploy_stack $resource $category $resourcetype $parameters

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
