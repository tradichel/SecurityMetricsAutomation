#!/bin/bash -e


#description: Fix organanization roles in existing accounts
#using OrgRoot for now. Eventually want to switch to governance account
#Only works for accounts with a role matching the expecetd name
########

base_dir="../../.."
source "$base_dir/Functions/shared_functions.sh"
source "$base_dir/Functions/assume_role.sh"
source "$base_dir/IAM/stacks/Group/group_functions.sh"
source "$base_dir/IAM/stacks/Role/role_functions.sh"

profile="OrgRoot"

#loop through accounts
accounts=$(aws organizations list-accounts --query 'Accounts[].[Id]' --output text --profile $profile)

#for this function, we are not goign to use account names
#existing names may have spaces and breks things
#also, we don't need to look up the account id - we arlready have it.
for acctid in $accounts; do
	
	#have a problem when account name has spaces
	#doing the following to keep it simple
	acctname=$(aws organizations describe-account --account-id $acctid --query 'Account.Name' --output text  --profile $profile)
	echo "account name for account id $acctid is $acctname"

  rolename="$acctname"
  roleprofile=$(echo $acctname | sed 's/ //g')
	
	echo "create_cross_account_role_profile \"$acctid\" \"$rolename\" \"$roleprofile\""
  orgprofile=$(create_cross_account_role_profile "$acctid" "$rolename" "$roleprofile")
  echo "AWS CLI roleprofile created: $orgprofile"

	#TOOD: NOT DONE
done
