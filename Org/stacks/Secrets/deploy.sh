#!/bin/bash -e
# https://github.com/tradichel/SecurityMetricsAutomation/
# Org/stacks/Secrets/deploy.sh
# author: @teriradichel @2ndsightlab
# description: Deploy OrgRoot secrets
##############################################################
source appsec_functions.sh

echo "An CLI Profile named AppSec is required to run this code."
profile="AppSec"

#create user specific secrets for developers
keyalias="OrgRootSecrets"

#using shared function that looks up key export
kmskeyid=$(get_kms_key_id $keyalias)

if [ "$kmskeyid" == "" ]; then
  echo "KMS key id is not set." 1>&2
  exit 1
fi

cd ../../../AppSec/stacks
create_secret OktaMetadata $kmskeyid
cd ../../Org/stacks/Secrets

