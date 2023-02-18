

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
