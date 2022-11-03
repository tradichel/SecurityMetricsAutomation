#!/bin/bash -e
# https://github.com/tradichel/SecurityMetricsAutomation
# IAM/stacks/Role/deploy.sh
# author: @teriradichel @2ndsightlab
# Description: Depiloy all roles
##############################################################

#run the script to deploy the first IAM user in this same directory before running this script.
echo "-------------- Deploy Roles -------------------"
echo "You must have a CLI profile named "IAM" configured to run this script"

source role_functions.sh

deploy_group_role 'AppDeployment'
deploy_group_role 'KMSAdmins'
deploy_group_role 'NetworkAdmins'
deploy_group_role 'SecurityMetricsOperators'
deploy_group_role 'AppDeployment'
deploy_group_role 'Developers'
deploy_group_role 'AppSec'

awsservice='EC2'
rolename=$awsservice'AppDeployRole'
deploy_aws_service_role $rolename $awsservice

deploy_ec2_instance_profile "EC2AppDeployInstanceProfile" $rolename

jobname="DeployJobCredentials"
jobtype="IAM"
deploy_batch_role $jobname $jobtype

lambdaname='TriggerBatchJob'
deploy_lambda_role $lambdaname

lambdaname='GenerateBatchJobId'
deploy_lambda_role $lambdaname

awsservice='VPCFlowLogs'
rolename=$awsservice'Role'
deploy_aws_service_role $rolename $awsservice

policyname='VPCFlowLogsPolicy'
deploy_role_policy $policyname

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

