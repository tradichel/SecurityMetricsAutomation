#!/bin/bash -e
 
#this deploy script presumes you have set up a cli profile with ksm with appopriate permissions

#get arn for batch job admin user
encryptarn=$(aws cloudformation describe-stacks --stack-name IamJobRoleDeployBatchJobCredentials \
  --query "Stacks[0].Outputs[?ExportName=='batchjobrolearnDeployBatchJobCredentials'].OutputValue" --output text)

#get arn for batch job admin user
decryptarn=$(aws cloudformation describe-stacks --stack-name RoleTriggerBatchJob \
  --query "Stacks[0].Outputs[?ExportName=='triggerjobtriggerrolearn'].OutputValue" --output text)


./deploy_key_trigger.sh $encryptarn $decryptarn "kms" 

./deploy_key_alias_trigger.sh "kms"



