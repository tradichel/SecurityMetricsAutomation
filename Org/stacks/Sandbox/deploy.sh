#!/bin/bash -e

#include the common functions
source ../../../Functions/shared_functions.sh 
source ../../../IAM/stacks/User/user_functions.sh
source ../../../IAM/stacks/Group/group_functions.sh
source ../../../IAM/stacks/Role/role_functions.sh

#profile used to create the cross-account role
profile="OrgRoot"
accountname="Sandbox"
acctnum=$(get_account_number $accountname)
rolename=$(get_account_org_role $accountname)
user="SandBoxAdmin"
kmsadmins="KMSAdmins" #group adn role name

profile=$(create_cross_account_role_profile $acctnum $rolename $accountname)

echo "New profile: $profile"

echo "Deploy IAM User: Sandbox Admin"
cd ../../../IAM/stacks/User
deploy_sandbox_admin 'SandboxAdmin'
cd ../../../Org/stacks/Sandbox

echo "Deploy KMS Admins Group and add Sandbox Admin"
cd ../../../IAM/stacks/Group
deploy_group $kmsadmins
add_users_to_group $user $kmsadmins
cd ../../../Org/stacks/Sandbox

echo "Deploy KMSAdmins Group Role"
cd ../../../IAM/stacks/Role
deploy_group_role $kmsadmins
cd ../../../Org/stacks/Sandbox
 
#stack="Sandbox-User-SandboxAdmin"
#exportname="SandboxAdminUserArnExport"
#sbadminarn=$(get_stack_export $stack $exportname)

#echo "Create cross account role for Sandbox KMS admins"
#rolename="KMSAdminsGroup"
#profile=$(create_cross_account_role_profile $acctnum $rolename)

#echo "Deploy key in Sandbox for EC2"
#cd ../../../KMS/stacks/Key
#keyalias="SandboxEC2"
#service="ec2"
#desc="SandboxEC2"
#deploy_key $sbadminarn $sbadminarn $keyalias $service "$desc"
