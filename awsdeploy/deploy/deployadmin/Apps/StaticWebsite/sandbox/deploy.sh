#!/bin/bash -e

#This is an ugly POC script.
#I will likely replace this with Okta roles later, depending on the outcome of my Okta assessment.

#deploy the resources to test static websites in sandbox environment
# - Sandbox account
# - SandboxWeb account
# - User in the sandbox account allowed to assume a role in SandboxWeb
# - Cross account role in SandboxWeb

source ../../../Functions/shared_functions.sh
source ../../../Functions/assume_role.sh

#get the root directory for this code base
cd ../../../
base_path=$(pwd)

#This code presumes an account named $orgprefix-sandbox already exists. 
#It was created with the Org governance accounts
orgprofile='OrgRoot'
user='WebAdmin'
console_access='true'
groupname='XacctWebAdmin'

change_dir "Organization" $base_path $orgprofile
orgprefix=$(get_organization_prefix)
sandboxwebacctname=$orgprefix'-Sandbox-Web'
sandboxacctname=$orgprefix'-Sandbox'

echo "-----CHECK VARS------"
echo "orgprefix: $orgprefix"
echo "web account name: $sandboxwebacctname"
echo "User account name: $sandboxacctname"

echo "-----DEPLOY [ORGPREFIX]-SANBOX-WEB WITH PROFILE----"
change_dir "Account" $base_path $orgprofile
deploy_account_w_ou_name 'Sandbox-Web' 'sandbox'

echo "-------CREATE CLI PROFILE FOR SANDBOX--------"
change_dir "Organization" $base_path $orgprofile
create_org_admin_role_profile $sandboxacctname
aws configure list --profile $sandboxacctname

echo "-------GET ACCOUNT NUMBER FOR SANDBOX WEB----"
change_dir "Account" $base_path $orgprofile
sbwebacctnum=$(get_account_number_by_account_name $sandboxwebacctname)
if [ "$sbwebacctnum" == "" ]; then echo "Error: account number not found for $sandboxwebacctname"; exit; fi

echo "-------DEPLOY WEBADMIN IN SANBOX----"
change_dir "IAMUser" $base_path $sandboxacctname
deploy_user $user $console_access

echo "------DEPLOY WEBADMIN GROUP IN SANDBOX----"
change_dir "IAMGroup" $base_path $sandboxacctname
deploy_group "$groupname" "$sbwebacctnum"

echo "----ADD WEB ADMIN TO WEBADMIN GROUP----"
add_users_to_group $user $groupname

echo "---CREATE CLI PROFILE FOR [ORGPREFI]-SANDBOX-WEB-----"
change_dir "Organization" $base_path $orgprofile
create_org_admin_role_profile $sandboxwebacctname
aws configure list --profile $sandboxacctname

echo "----DEPLOY CROSS ACCOUNT ROLE IN SANDBOX-WEB------"
change_dir "IAMRole" $base_path $orgprofile
deploy_crossaccount_group_role $groupname $sandboxacctname $sandboxwebacctname

echo "done"
