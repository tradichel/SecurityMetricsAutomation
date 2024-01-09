#!/bin/bash -e
source ../../Functions/assume_role.sh
source ../../Functions/shared_functions.sh

domain="dev.rainierrhododendrons.com"
profile="XacctWebAdminGroup"
cd ../../
basepath=$(pwd)
change_dir "DNS" $basepath $profile
pwd

#!/bin/bash -e
echo "Current hosted zone:"
export_zone $domain
echo -e "\nDeploy CNAME:"

echo "deploy_tls_validation_record $domain"
deploy_tls_validation_record $domain

echo "TLS validation record deployment complete"
