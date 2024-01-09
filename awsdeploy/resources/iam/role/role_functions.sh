#!/bin/bash -e
# https://github.com/tradichel/SecurityMetricsAutomation
# awsdeploy/resource/iam/role/role_functions.sh
# author: @teriradichel @2ndsightlab
# Description: Role to manage the organization for the root-orgadmin user in the root-org account
##############################################################

source deploy/shared/functions.sh

deploy_role() {

  rolename="$1"
  users="$2"
  env="$3"

  function=${FUNCNAME[0]}
  validate_var "$function" "rolename" "$rolename"
  validate_var "$function" "env" "$users"
  validate_var "$function" "env" "$env"
  
	validate_environment $env

  rolename="$env-$rolename"

  parameters=$(add_parameter "NameParam" $rolename)
  parameters=$(add_parameter "UsersParam" $users $parameters) 

  deploy_stack $rolename "iam" "role" $parameters

}

deploy_group_role(){

  groupname="$1"
  
  function=${FUNCNAME[0]}
  validate_var $function "groupname" $groupname

  #retrieve a list of user ARNs in the group
  users=$(aws iam get-group --group-name $groupname --profile $profile \
      --query Users[*].Arn --output text | sed 's/\t/,/g')

  if [ "$users" == "" ]; then
    echo 'No users in group '$groupname' so the group role will not be created.'
    exit
  fi

  timestamp=$(get_timestamp)

  resourcetype='role'
  template='grouprole.yaml'
  p=$(add_parameter "GroupNameParam" $groupname)
  p=$(add_parameter "GroupUsers" $users "$p")
  p=$(add_parameter "TimestampParam" $timestamp "$p")
  rolename=$groupname'role'

	deploy_stack $rolename "iam" "role" $p $template

  policyname=$groupname'GroupRolePolicy'
  deploy_role_policy $policyname $profile

}

#the groupname is the group of users who are allowed to assume the role.
#The remote account AWS CLI profile can make changes in the user account.
#the target profile can deploy the cross-account role in the remote account.
deploy_crossaccount_group_role(){

  groupname="$1"
  remoteacctprofile="$2"
  targetacctprofile="$3"

  function=${FUNCNAME[0]}
  validate_var $function "groupname" "$groupname"
  validate_var $function "remoteacctprofile" "$remoteacctprofile"
  validate_var $function "targetacctprofile" "$targetacctprofile"

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
  resourcetype='role'
  template='grouprole.yaml'
  p=$(add_parameter "GroupNameParam" $groupname)
  p=$(add_parameter "GroupUsers" $users "$p")
  p=$(add_parameter "TimestampParam" $timestamp "$p")
 
	echo need to set rolename; exit

	deploy_stack $rolename "iam" "role" $p $template

  policyname=$groupname'grouprolepolicy'
  deploy_role_policy $policyname $profile

}

deploy_role_policy(){

  policyname=$1

  function=${FUNCNAME[0]}
  validate_var $function "policyname" "$policyname"

  p=$(add_parameter "NameParam" $policyname)
  template=$policyname'.yaml'
  
  deploy_stack $policyname "iam" "policy" $p $template

}

deploy_app_policy(){

  service="$1"
  appname="$2"
  env="$3"
  secret="$4"
  readbucket="$5"
  writebucket="$6"
  actions="$7"
  resources="$8"

  if [ "$secret" == "" ]; then
    secret="false"
  fi

  function=${FUNCNAME[0]}
  validate_var $function "functionname" "$appname"
  validate_var $function "env" "$env"
  validate_var $function "secret" "$secret"
  validate_var $function "service" "$service"

  p=$(add_parameter "NameParam" $appname)
  p=$(add_parameter "EnvParam" $env $p)
  p=$(add_parameter "HasSecretParam" $secret $p)
  p=$(add_parameter "ServiceParam" $service $p)
  if [ "$readbucket" != "" ]; then
    p=$(add_parameter "S3ReadBucketArnParam" $readbucket $p)
  fi
  if [ "$writebucket" != "" ]; then
    p=$(add_parameter "S3riteBucketArnParam" $writebucket $p)
  fi
  if [ "$actions" != "" ]; then
    p=$(add_parameter "ActionsParam" $actions $p)
  fi
  if [ "$resources" !="" ]; then
    p=$(add_parameter "ResourcesParam" $resources $p)
  fi

  policyname=$appname$service'rolepolicy'
  template='apppolicy.yaml'
  
  deploy_stack $policyname "iam" "policy" $p $template

}

deploy_ec2_instance_profile(){

  profilename=$1
  rolename=$2

  function=${FUNCNAME[0]}
  validate_var $function "profilename" "$profilename" 
  validate_var $function "rolename" "$rolename"

  p=$(add_parameter "NameParam" "$profilename")
  p=$(add_parameter "RoleNamesParam" "$rolename" "$p")
  template='cfn/EC2InstanceProfile.yaml'
  
  deploy_stack $profilename "iam" "ec2instanceprofile" $p $template

}

deploy_aws_service_role(){

  awsservice=$1

	#aws service is name of service only not full domain
	rolename=$awsservice'role'
	rolename=$(echo $rolename | sed 's/-//g')
	rolename='org-'$rolename
	
  function=${FUNCNAME[0]}
  validate_var $function "awsservice" "$awsservice"

  template='awsservicerole.yaml'
  p=$(add_parameter "NameParam" $rolename)
  p=$(add_parameter "AWSServiceParam" $awsservice $p)

  deploy_stack $rolename "iam" "role" $p $template 
 
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
