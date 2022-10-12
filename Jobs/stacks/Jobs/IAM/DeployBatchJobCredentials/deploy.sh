#!/bin/bash -e
# https://github.com/tradichel/SecurityMetricsAutomation
# Jobs/stacks/IAMJobs/DeployBatchJobCredentials/deploy.sh
# author: @teriradichel @2ndsightlab
# description: test script for DeployBatchJobCreds functionality
##############################################################

#this will change later when this code becomes and actual batch job
#for now just testing the fucntionality of the CF templates
#the IAM admins will be allowed to run this job
#the IAM admins will also be allowed to provide the MFA to exec jobs

echo "-------------- Deploy Job: DeployBatchJobCredentials -------------------"
echo ""
echo "In order to run this template you will need to set up an AWS CLI profile"
echo "named deploycreds and allow the IAMAdmin to assume the role."
echo "OK? CTRL-C to Exit. Enter to continue."
echo ""
echo "------------------------------------------------------------------------"

source ../../../../../Functions/shared_functions.sh

profile="IAM"
resource="DeployBatchJobCredentialsIAMJobPolicy"
resourcetype="Policy"
template='cfn/'$resource'.yaml'
	
deploy_stack $profile $resource $resourcetype $template

profile="deploycreds"
resource="BatchJobCredentials"
template='cfn/BatchJobCredentials.yaml' 
resourcetype=Secret
parameters=$(add_parameter "UserNameParam" 'SecurityMetricsOperator')
deploy_stack $profile $resource $resourcetype $template $parameters

# 9/19/22 - For some reason CloudForamtion starated forcing me to add Delete permisisons
# to the above policy for this stack to properly update. I do NOT want this user to 
# have delete permissions but to get this to deploy for now I added it to the above
# policy. Will address this later and only run this stack if it does not already
# exist.
resource="IAMBatchJobCredentials"
template='cfn/BatchJobCredentials.yaml'
resourcetype=Secret
parameters=$(add_parameter "UserNameParam" 'IAMAdmin')
deploy_stack $profile $resource $resourcetype $template $parameters

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
