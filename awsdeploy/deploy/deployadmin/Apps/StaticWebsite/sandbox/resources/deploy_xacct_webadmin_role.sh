#!/bin/bash -e
# https://github.com/tradichel/SecurityMetricsAutomation
# Org/stacks/Apps/StaticWebsite/deploy_xcct_webadmin_role.sh
# author: @teriradichel @2ndsightlab
# Description: Deploy a WebAdmin xacct role in the
# sandbox-web account
##############################################################

#variables used below are assigne in ../init_vars.sh

remoteaccountprofile="$orgprefix-$useraccountname"
targetaccountprofile=$(create_org_admin_role_profile $webaccountname)

change_dir "IAMRole" $base_path $orgprofile
deploy_crossaccount_group_role $groupname $remoteaccountprofile $targetaccountprofile






