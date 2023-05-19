#!/bin/bash -e
# https://github.com/tradichel/SecurityMetricsAutomation
# IAM/stacks/Group/group_functions.sh
# author: @teriradichel @2ndsightlab
# Description: Functions to deploy a group and add users to groups
##############################################################
source "../../../Functions/shared_functions.sh"
profile='IAM'

deploy_group(){

	groupname=$1
	profile_override="$2"

	function=${FUNCNAME[0]}
	validate_param "groupname" "$groupname" "$function"

	if [ "$profile_override" != "" ]; then
		profile=$profile_override
	fi

	resourcetype='Group'
	template='cfn/Group.yaml'
	parameters=$(add_parameter "NameParam" $groupname)
  
	deploy_stack $profile $groupname $resourcetype $template "$parameters"

	policyname=$groupname'GroupPolicy'	
  template='cfn/GroupPolicy.yaml'
	deploy_group_policy $groupname $template $policyname

}

deploy_group_policy(){

	groupname=$1
  template="$2"
 	policyname="$3"

  function=${FUNCNAME[0]}
 	validate_param "groupname" "$groupname" "$function"
  validate_param "template" "$template" "$function"
	validate_param "policyname" "$policyname" "$function"

	parameters=$(add_parameter "NameParam" $groupname)
	resourcetype='Policy'
	deploy_stack $profile $policyname $resourcetype $template "$parameters"

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

