#!/bin/bash

env='root'
mfaaccount=$env
username=$env'-admin'
deployrolename=$username'role'

#things the rootadminrole can deploy
echo "Enter number for script to deploy with the rootadminrole:"
echo "1 organization prefix (org) parameter (root)"
echo "2 organization domain parameter (root)"
echo "3 organization (root)"
echo "4 org account (root)"
echo "5 root-orgadminrole (root)"
echo "6 root-orgadminrolepolicy (root)"
echo "7 administrator service control policies (root)"
echo "8 root-orgadminuser (root-org)"
echo "9 root-orgadminuserpolicy (root-org)"
echo "10 all"

read scriptno

if [ "$scriptno" == "1" ]; then
  job="ssm_parameter_org"
  echo "Enter org prefix (appended to some resource names):"; read org
  validate_alphanumeric $org
  validate_no_quotes $org
  parameters="[org=$org]"
  deploytoaccount="root"

elif [ "$scriptno" == "2" ]; then
  job="ssm_parameter_domain"
  echo "Enter domain for account emails:"; read domain
  validate_alphanumeric_underscore_dash_period $domain
  validate_no_quotes $domain
  parameters="[domain=$domain]"
  deploytoaccount="root"

elif [ "$scriptno" == "3" ]; then job="organizations_organization"; deploytoaccount="root"
elif [ "$scriptno" == "4" ]; then job="organizations_account_org"; deploytoaccount="root"
elif [ "$scriptno" == "5" ]; then job="iam_role_orgadminrole"; deploytoaccount="root"
elif [ "$scriptno" == "6" ]; then job="iam_rolepolicy_orgadminrole"; deploytoaccount="root"
elif [ "$scriptno" == "7" ]; then job="organizations_policy_administratorscps" deploytoaccount="root"
elif [ "$scriptno" == "8" ]; then job="iam_user_orgadmin"; deploytoaccount="root-org"
elif [ "$scriptno" == "9" ]; then job="iam_userpolicy_orgadmin"; deploytoaccount="root-org"
elif [ "$scriptno" == "10" ]; then
  job="all_root"

  echo "Enter org prefix (appended to some resource names):"; read org
  validate_alphanumeric $org
  validate_no_quotes $org

  echo "Enter domain for account emails:"; read domain
  validate_alphanumeric_underscore_dash_period $domain
  validate_no_quotes $domain

  parameters="[org=$org,domain=$domain]"
  deploytoaccount="root"
elif [ "$scriptno" == "11" ]; then job="all_root_org"; deploytoaccount="root-org"
else echo "Invalid selection $scriptno"; exit
fi



