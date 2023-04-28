#!/bin/bash -e
# https://github.com/tradichel/SecurityMetricsAutomation
# IAM/stacks/OktaRole/role_functions.sh
# author: @teriradichel @2ndsightlab
# Description: Functions to deploy okta SAML federation 
# roles and policies
##############################################################

source "../../../Functions/shared_functions.sh"
profile='IAM'

deploy_root_okta_role(){
	profile='OrgRoot'
  deploy_okta_role $1
}

deploy_okta_role(){

	rolename="$1"
		
	function=${FUNCNAME[0]}
	validate_param "rolename" "$rolename" $function

	timestamp=$(get_timestamp)

	resourcetype='Role'
	template='cfn/OktaRole.yaml'
	p=$(add_parameter "RoleNameParam" $rolename)
	p=$(add_parameter "TimestampParam" $timestamp "$p")
	stackname=$rolename'Role'

	deploy_stack $profile $stackname $resourcetype $template "$p"

	policyname='Okta'$rolename'RolePolicy'
	deploy_role_policy $policyname $profile

}

deploy_role_policy(){

	policyname="$1"

  function=${FUNCNAME[0]}
 	validate_param "policyname" "$policyname" $function

  p=$(add_parameter "NameParam" $policyname)
	template='cfn/Policy/'$policyname'.yaml'
	resourcetype='Policy'

	deploy_stack $profile $policyname $resourcetype $template "$p"

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

