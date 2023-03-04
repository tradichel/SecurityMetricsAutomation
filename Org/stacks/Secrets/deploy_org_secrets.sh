#/bin/bash -e
# https://github.com/tradichel/SecurityMetricsAutomation/
# Org/stacks/Secrets/deploy_org_secrets.sh
# author: @teriradichel @2ndsightlab
# description: Deploy OrgRoot organizational secrets
##############################################################
source secret_functions.sh

echo "An CLI Profile named OrgRoot is required to run this code."

#create user specific secrets for developers
keyalias="OrgRootSecrets"

#using shared function that looks up key export
kmskeyid=$(get_kms_key_id $keyalias "OrgRoot")
if [ "$kmskeyid" == "" ]; then
  echo "KMS key id is not set." 1>&2
  exit 1
fi

create_secret OrgPrefix $kmskeyid "set_orgprefix_value_in_secrets_manager"
create_secret OrgDomain $kmskeyid "set_orgdomain_value_in_secrets_manager"

