#!/bin/bash -e
# https://github.com/tradichel/SecurityMetricsAutomation
# resources/iam/group/group_functions.sh
# author: @teriradichel @2ndsightlab
# Description: Functions to deploy a group and add users to groups
##############################################################
source "deploy/shared/functions.sh"
source "deploy/shared/validate.sh"

add_users_to_group() {

  usernames="$1"
	groupname="$2"
  
  function=${FUNCNAME[0]}
  validate_var $function "usernames" "$usernames"
	validate_var $function "groupname" "$groupname"
	
	timestamp=$(get_timestamp)

	name='nonprod-usertogroupaddition'$groupname
	category='iam'
	resourcetype='usertogroupaddition'

	parameters=$(add_parameter "UserNamesParam" $usernames)
	parameters=$(add_parameter "GroupNameParam" $groupname $parameters)
  parameters=$(add_parameter "TimestampParam" $timestamp $parameters)
	deploy_stack $name $category $resourcetype $parameters

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

