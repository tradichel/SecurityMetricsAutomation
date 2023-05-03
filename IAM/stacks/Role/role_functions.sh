#!/bin/bash -e
# https://github.com/tradichel/SecurityMetricsAutomation
# IAM/stacks/Role/role_functions.sh
# author: @teriradichel @2ndsightlab
# Description: Functions to deploy a group and add users to groups
##############################################################

source "../../../Functions/shared_functions.sh"
profile='IAM'

deploy_group_role(){

	groupname="$1"
	profile_override="$2"
		
	function=${FUNCNAME[0]}
	validate_param "groupname" "$groupname" "$function"

	if [ "$profile_override" != "" ]; then profile=$profile_override; fi

	#retrieve a list of user ARNs in the group
  users=$(aws iam get-group --group-name $groupname --profile $profile \
			--query Users[*].Arn --output text | sed 's/\t/,/g')

	if [ "$users" == "" ]; then
		echo 'No users in group '$groupname' so the group role will not be created.'
		exit
	fi

	timestamp=$(get_timestamp)

	resourcetype='Role'
	template='cfn/GroupRole.yaml'
	p=$(add_parameter "GroupNameParam" $groupname)
	p=$(add_parameter "GroupUsers" $users "$p") 
  p=$(add_parameter "TimestampParam" $timestamp "$p")
	stackname=$groupname'Role'

	deploy_stack $profile $stackname $resourcetype $template "$p"

	policyname=$groupname'GroupRolePolicy'
	deploy_role_policy $policyname $profile

}

deploy_crossaccount_group_role(){

  groupname="$1"
  remoteacctprofile="$2"
	targetacctprofile="$3"

  function=${FUNCNAME[0]}
  validate_param "groupname" "$groupname" "$function"
  validate_param "remoteacctprofile" "$remoteacctprofile" "$function"
  validate_param "targetacctprofile" "$targetacctprofile" "$function"

  profile=$remoteacctprofile
  #retrieve a list of user ARNs in the group
  users=$(aws iam get-group --group-name $groupname --profile $profile \
      --query Users[*].Arn --output text | sed 's/\t/,/g')

  if [ "$users" == "" ]; then
    echo 'No users in group '$groupname' so the group role will not be created.'
    exit
  fi

  timestamp=$(get_timestamp)

	profile="$targetacctprofile"
  resourcetype='Role'
  template='cfn/GroupRole.yaml'
  p=$(add_parameter "GroupNameParam" $groupname)
  p=$(add_parameter "GroupUsers" $users "$p")
  p=$(add_parameter "TimestampParam" $timestamp "$p")
  stackname='XAcct'$groupname'Role'
	stackname=$(echo $stackname | sed 's/-//')
	echo "deploy_stack $profile $stackname $resourcetype $template \"$p\""
  deploy_stack $profile $stackname $resourcetype $template "$p"

  policyname=$groupname'GroupRolePolicy'
  deploy_role_policy $policyname $profile

}

deploy_role_policy(){

	policyname=$1

  function=${FUNCNAME[0]}
 	validate_param "policyname" "$policyname" "$function"

  p=$(add_parameter "NameParam" $policyname)
	template='cfn/Policy/'$policyname'.yaml'
	resourcetype='Policy'

	deploy_stack $profile $policyname $resourcetype $template "$p"

}

deploy_ec2_instance_profile(){

  profilename=$1
	rolename=$2

  function=${FUNCNAME[0]}
  validate_param "profilename" "$profilename" "$function"
  validate_param "rolename" "$rolename" "$function"

  p=$(add_parameter "NameParam" "$profilename")
  p=$(add_parameter "RoleNamesParam" "$rolename" "$p")
  template='cfn/EC2InstanceProfile.yaml'
  resourcetype='EC2InstanceProfile'

  deploy_stack $profile $profilename $resourcetype $template "$p"

}

deploy_batch_role(){

	jobname=$1
  jobtype=$2
  
  function=${FUNCNAME[0]}
  validate_param "jobname" "$rolepname" "$function"
  validate_param "jobtype" "$jobtype" "$function"

  resourcetype='Role'
  template='cfn/BatchJobRole.yaml'
	p=$(add_parameter "JobNameParam" $jobname)
  p=$(add_parameter "BatchJobTypeParam" $jobtype $p)  
	rolename=$jobname$jobtype'BatchRole'

  deploy_stack $profile $rolename $resourcetype $template "$p"

}

deploy_lambda_role(){

	lambda="$1"
  function=${FUNCNAME[0]}

  validate_param "lambda" "$lambda" "$function"
 
	rolename=$lambda'LambdaRole'	
	awsservice="Lambda"
	
	deploy_aws_service_role $rolename $awsservice

}

deploy_aws_service_role(){

  rolename=$1
	awsservice=$2
  
  function=${FUNCNAME[0]}
  validate_param "rolename" "$rolename" "$function"
  validate_param "awsservice" "$awsservice" "$function"
 
  resourcetype='Role'
  template='cfn/AWSServiceRole.yaml'
  p=$(add_parameter "NameParam" $rolename)
  p=$(add_parameter "AWSServiceParam" $awsservice $p)
  
	deploy_stack $profile $rolename $resourcetype $template "$p"

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

