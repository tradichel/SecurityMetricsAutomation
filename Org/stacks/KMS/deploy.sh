#!/bin/bash -e
# https://github.com/tradichel/SecurityMetricsAutomation
# KMS/stacks/Key/deploy.sh
# description: deploy initial KMS key in the mangaement account
# Executed in the organization's management account
###############################################################
source ../../../Functions/shared_functions.sh

echo "------Create a CLI profile named 'KMS' before running this script ---"
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

cd ../../../KMS/stacks/Key/
source key_functions.sh
deploy_orgroot_key $encryptarn $decryptarn $keyalias $conditionservice $desc
cd ../../../Org/stacks/KMS

echo "-----------  OrgRoot Key Alias -----------"
cd ../../../KMS/stacks/KeyAlias/
source keyalias_functions.sh
keyid=$(get_key_id $keyalias)
deploy_orgroot_key_alias $keyid $keyalias
cd ../../../Org/stacks/KMS



