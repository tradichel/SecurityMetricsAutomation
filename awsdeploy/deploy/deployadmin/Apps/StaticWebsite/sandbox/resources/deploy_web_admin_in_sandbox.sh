#!/bin/bash -e
# https://github.com/tradichel/SecurityMetricsAutomation
# Org/stacks/Apps/StaticWebsite/deploy_web_admin_in_sandbox.sh
# author: @teriradichel @2ndsightlab
# Description: Deploy a WebAdmin in the sandbox account
##############################################################
#variables used below are assigned in ../init_vars.sh

change_dir "Organization" $base_path $profile

#create an aws cli profile for the Sandbox account
remoteprofile=$(create_org_admin_role_profile $useraccountname)

#get the sandbox web account number
sbwebacctnum=$(get_account_number $webaccountname)
echo "Cross account role in account: $sbwebacctnum"

change_dir "IAMUser" $base_path $remoteprofile
deploy_user $user $console_access

change_dir "IAMGroup" $base_path $remoteprofile
deploy_group "$groupname" "$sbwebacctnum"
add_users_to_group $user $groupname




