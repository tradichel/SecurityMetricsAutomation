# !/bin/bash -e
# https://github.com/tradichel/SecurityMetricsAutomation
# IAM/stacks/Role/role_functions.sh
# author: @teriradichel @2ndsightlab
# Description: Functions to deploy a group and add users to groups
##############################################################

source "../../../Functions/shared_functions.sh"

deploy_group_role(){

	groupname=$1
	profile=$2
	
	function=${FUNCNAME[0]}
	validate_param "groupname" $groupname $function
	validate_param "profile" $profile $function

	#retrieve a list of user ARNs in the group
  users=$(aws iam get-group --group-name $groupname \
			--query Users[*].Arn --output text | sed 's/\t/,/g')

	if [ "$users" == "" ]; then
		echo 'No users in group '$groupname' so the group role will not be created.'
		exit
	fi

	resourcetype='Role'
	template='cfn/GroupRole.yaml'
	parameters='GroupNameParam='$groupname' GroupUsers='$users	
	stackname=$groupname'Role'
	deploy_iam_stack $profile $stackname $resourcetype $template "$parameters"
	
	policyname=$groupname'GroupRolePolicy'
	deploy_role_policy $policyname $profile

}

deploy_role_policy(){

	policyname=$1
	profile=$2

  function=${FUNCNAME[0]}
 	validate_param "policyname" $policyname $function
	validate_param "profile" $profile $function

	parameters='NameParam='$policyname
	template='cfn/Policy/'$policyname'.yaml'
	resourcetype='Policy'
	deploy_iam_stack $profile $policyname $resourcetype $template "$parameters"

}


deploy_batch_role(){

	jobname=$1
  jobtype=$2
  profile=$3

  function=${FUNCNAME[0]}
  validate_param "jobname" $rolepname $function
  validate_param "jobtype" $jobtype $function
  validate_param "profile" $profile $function

  resourcetype='Role'
  template='cfn/BatchJobRole.yaml'
  parameters='["JobNameParam='$jobname'","BatchJobTypeParam='$jobtype'"]'  
	rolename=$jobname$jobtype'BatchRole'
  deploy_iam_stack $profile $rolename $resourcetype $template "$parameters"

}

deploy_lambda_role(){

  lambdaname=$1
  profile=$2

  function=${FUNCNAME[0]}
  validate_param "lambdaname" $lambdaname $function
  validate_param "profile" $profile $function

  resourcetype='Role'
  template='cfn/LambdaRole.yaml'
  parameters='LambdaNameParam='$lambdaname
  rolename=$lambdaname'LambdaRole'
  deploy_iam_stack $profile $rolename $resourcetype $template "$parameters"

}

get_role_arn_export (){

	#need to move some code for export retrieval to stack functions
  rolepname=$1

	function=${FUNCNAME[0]}
	validate_param $rolename $function

  roleexport=$rolename'ArnExport'
  stack='IAM-Role-'$groupname
  qry="Stacks[0].Outputs[?ExportName=='$roleexport'].OutputValue"
  rolearn=$(aws cloudformation describe-stacks --stack-name $stack --query $qry --output text)
  echo $grouparn

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

