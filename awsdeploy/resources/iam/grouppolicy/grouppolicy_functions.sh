#!/bin/bash -e
# https://github.com/tradichel/SecurityMetricsAutomation
# resources/iam/group/grouppolicy_functions.sh
# author: @teriradichel @2ndsightlab
# Description: Functions to deploy a group policy
##############################################################
source "deploy/shared/functions.sh"
source "deploy/shared/validate.sh"

deploy_project_group_policy(){
	groupname="$1"
	xacctnum="$2" #optional

	template="projectgrouppolicy.yaml"
	
	deploy_group_policy $groupname $template $xacctnum
}

deploy_group_policy(){

	groupname="$1"
	template="$2"
	xacctnum="$3" #optional

	policyname=$groupname'grouppolicy'

  f=${FUNCNAME[0]}
 	validate_var $f "groupname" "$groupname" 
 	validate_var $f "policyname" "$policyname"

	if [ "$template" == "" ]; then 
		template='$policyname'
	fi

	parameters=$(add_parameter "NameParam" $policyname)
  parameters=$(add_parameter "GroupNameParam" $groupname $parameters)
  if [ "$xacctnum" != "" ]; then
		echo $xacctnum
    parameters=$(add_parameter "XAcctNumParam" $xacctnum $parameters)
  fi

	category='iam'
	resourcetype='grouppolicy'

	echo "deploy_stack $category $category $resourcetype $parameters $template"
	deploy_stack $policyname $category $resourcetype $parameters $template

}

add_users_to_group() {

  usernames="$1"
	groupname="$2"
  
  function=${FUNCNAME[0]}
  validate_param "usernames" "$usernames" "$function"
	validate_param "groupname" "$groupname" "$function"
	
	timestamp=$(get_timestamp)

	template='cfn/UserToGroupAddition.yaml'
	name='AddUsersTo'$groupname
	resourcetype='UserToGroupAddition'
	parameters=$(add_parameter "UserNamesParam" $usernames)
	parameters=$(add_parameter "GroupNameParam" $groupname $parameters)
  parameters=$(add_parameter "TimestampParam" $timestamp $parameters)
	deploy_stack $profile $name $resourcetype $template "$parameters"

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

