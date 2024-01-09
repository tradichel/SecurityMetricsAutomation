#!/bin/bash -e
#
#
#desc: refresh temp credentials for a profile

source shared_functions.sh
source assume_role.sh

#the account that contains the cross-account role
accountname="Sandbox-Web"

#an AWS CLI profile that has permission to
#look up account numbers by account names in 
#AWS Organizations
profile=OrgRoot

#get the account number for the account name
acctnum=$(get_account_number $accountname)

#the role you want to assume
rolename="XacctWebAdminGroup"

#the AWS CLI profile with credentials
#that are allowed to assume the role
#with MFA
profile="WebAdmin"
mfa="true"
accountname="Sandbox-Web"

echo "Enter orgprefix:"
read orgprefix

echo "acctnum $acctnum"
echo "rolename $rolename"
echo "mfa $mfa"

#create the AWS CLI profile for the cross-account role with temp credentials
create_cross_account_role_profile $acctnum $rolename $mfa

echo "Created AWS CLI profile $roleprofile to assume cross-account role $rolename in the $accountname AWS account"

