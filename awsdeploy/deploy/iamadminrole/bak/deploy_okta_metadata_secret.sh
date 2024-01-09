#!/bin/bash -e
# https://github.com/tradichel/SecurityMetricsAutomation/
# Org/stacks/Secrets/deploy.sh
# author: @teriradichel @2ndsightlab
# description: Deploy OrgRoot secrets
##############################################################
source secret_functions.sh

echo "An CLI Profile named OrgRoot is required to run this code."
echo "This script should only be run one time to deploy the Okta Metadata in the root account."
echo "Be careful with permissions that allow someone to alter the Okta Metadata."

#create user specific secrets for developers
keyalias="OrgRootSecrets"

#using shared function that looks up key export
kmskeyid=$(get_kms_key_id $keyalias "OrgRoot")
if [ "$kmskeyid" == "" ]; then
  echo "KMS key id is not set." 1>&2
  exit 1
fi

create_secret OktaMetadata $kmskeyid "set_okta_metadata_in_aws_secret_named_OktaMetadata"

