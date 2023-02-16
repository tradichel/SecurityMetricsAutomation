#!/bin/bash -e
# https://github.com/tradichel/SecurityMetricsAutomation
# KMS/stacks/Key/deploy.sh
# description: deploy initial KMS key in the mangaement account
# Executed in the organization's management account
###############################################################
source ../../../Functions/shared_functions.sh
source ../../../KMS/stacks/key_functions.sh

echo "------Create a CLI profile named 'OrgRoot' before running this script ---"

echo "------Key for Organization Root Secrets -----"

desc="OrgRootSecrets"
keyalias="OrgRootSecrets"
conditionservice="secretsmanager"

#get the encryption ARN for our key policy 
stack='ROOT-USER-OrgRoot'
exportname='OrgRootUserArnExport'
encryptarn=$(get_stack_export $stack $exportname)

#get the decryption ARN for our key policy 
stack='ROOT-USER-OrgRoot'
exportname='OrgRootUserArnExport'
decryptarn=$(get_stack_export $stack $exportname)

deploy_key $encryptarn $decryptarn $keyalias $conditionservice $desc
