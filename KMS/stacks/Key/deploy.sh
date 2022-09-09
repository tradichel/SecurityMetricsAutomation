#!/bin/bash -e
# https://github.com/tradichel/SecurityMetricsAutomation
# KMS/stacks/Key/deploy.sh
# description: deploy KMS keys
##############################################################
source ../../../Functions/shared_functions.sh
source key_functions.sh

#must run this as a kms admin user
profile="kms"

desc="KMS Key for Batch Job Credentials"
keyalias="BatchJobCredentials"

#get the encryption ARN for our key policy 
stack='IAM-Role-DeployBatchJobCredentialsIAMBatchRole'
exportname='DeployBatchJobCredentialsIAMBatchJobRoleArn'
encryptarn=$(get_stack_export $stack $exportname)
  
if [ "$encryptarn" == "" ]; then
  echo 'Export '$exportname ' for stack '$stack' did not return a value'
  exit
fi

#get the decryption ARN for our key policy 
stack='IAM-Role-TriggerBatchJobLambdaRole'
exportname='TriggerBatchJobLambdaRoleArn'
decryptarn=$(get_stack_export $stack $exportname)

if [ "$decryptarn" == "" ]; then
  echo 'Export '$exportname ' for stack '$stack' did not return a value'
  exit
fi

deploy_key $profile $encryptarn $decryptarn $keyalias "$desc"

