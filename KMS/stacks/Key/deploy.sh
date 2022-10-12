#!/bin/bash -e
# https://github.com/tradichel/SecurityMetricsAutomation
# KMS/stacks/Key/deploy.sh
# description: deploy KMS keys
##############################################################
source ../../../Functions/shared_functions.sh
source key_functions.sh

echo "------Create a CLI profile named 'KMS' before running these scripts ---"

echo "------Key for batch job credentials -----"

desc="KMS Key for Batch Job Credentials"
keyalias="BatchJobCredentials"
conditionservice="secretsmanager"

#get the encryption ARN for our key policy 
stack='IAM-Role-DeployBatchJobCredentialsIAMBatchRole'
exportname='DeployBatchJobCredentialsIAMBatchJobRoleArn'
encryptarn=$(get_stack_export $stack $exportname)
  
#get the decryption ARN for our key policy 
stack='IAM-Role-TriggerBatchJobLambdaRole'
exportname='TriggerBatchJobLambdaRoleRoleArn'
decryptarn=$(get_stack_export $stack $exportname)

deploy_key $encryptarn $decryptarn $keyalias $conditionservice $desc

echo "------Key for batch job trigger -----"

desc="KMS Key for Batch Job Trigger"
keyalias="TriggerBatchJob"
conditionservice="parameterstore"

#get the encryption ARN for our key policy 
stack='IAM-Role-GenerateBatchJobIdLambdaRole'
exportname='GenerateBatchJobIdLambdaRoleRoleArn'
encryptarn=$(get_stack_export $stack $exportname)
  
#get the decryption ARN for our key policy 
stack='IAM-Role-TriggerBatchJobLambdaRole'
exportname='TriggerBatchJobLambdaRoleRoleArn'
decryptarn=$(get_stack_export $stack $exportname)

deploy_key $encryptarn $decryptarn $keyalias $conditionservice $desc

echo "------Key for Developer Secrets -----"

group="Developers"
users=$(get_users_in_group $group $profile)
decryptarns=$users

desc="KMS Key to encrypt developer resources in secrets manager"
keyalias="DeveloperSecrets"
conditionservice="secretsmanager"

#get the encryption ARNs for our key policy 
stack='IAM-Role-IAMAdminsRole'
exportname='IAMAdminsRoleArnExport'
encryptarn1=$(get_stack_export $stack $exportname)

stack='IAM-Role-AppSecRole'
exportname='AppSecRoleArnExport'
encryptarn2=$(get_stack_export $stack $exportname)

encryptarns=$encryptarn1','$encryptarn2

#get the developer group role to decrypt arn
deploy_key $encryptarns $decryptarns $keyalias $conditionservice $desc

echo "------Key for Developer Non-Secrets Resources -----"

desc="KMS Key to encrypt developer resources that are not in Secrets Manager"
keyalias="DeveloperComputeResources"
conditionservice="kms"

#get the encryption ARN for our key policy 
stack='IAM-Role-AppDeploymentRole'
exportname='AppDeploymentRoleArnExport'
encryptarns=$(get_stack_export $stack $exportname)

#get the developer group role to decrypt arn
group="Developers"
users=$(get_users_in_group $group $profile)
decryptarns=$users
deploy_key $encryptarns $decryptarns $keyalias $conditionservice $desc

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
