#!/bin/bash -e
# https://github.com/tradichel/SecurityMetricsAutomation/
# Org/stacks/deploy.sh
# author: @teriradichel @2ndsightlab
# description: Deploy AWS IAM IdP
##############################################################

echo "Have you deployed the OrgRoot user in /Org/stacsk/OrgRoot/depoy.sh? Enter to continue. Ctrl-C to exit."
read ok
cd Organization
./deploy.sh
cd ../KMS
./deploy.sh
cd ../Secrets
./deploy.sh

echo "Add the metadata for Okta to the new secret: OrgRootSecrets. Enter to continue. Ctrl-C to exit"
read ok
cd ../IdP
./deploy.sh
cd ../OU
./deploy_root_ous.sh
cd ../SCP
./deploy_root_scps.sh
cd ..
~      
