#!/bin/bash
# /Apps/StaticWebsite/init_vars.sh
#set variables so names are consistent in scripts

source ../../../Functions/shared_functions.sh
source ../../../Functions/assume_role.sh

#get the root directory for this code base
cd ../../../
base_path=$(pwd)

#aws cli profile with permissions to do the following:
#query the OrgPrefix SSM parameter in the root account
#query CloudFormation stacks in the root account
#assume the default AWS Organizations role...
#(which will go away later but using for initial testing)
#execute other funtions in the Organizations folder
orgprofile='OrgRoot'

#get the root directory for this code base
change_dir "Organization" $base_path $orgprofile
orgprefix=$(get_organization_prefix)

#set the variables involved in cross account role usage
user='WebAdmin'
console_access='true'
groupname='XacctWebAdmin'
useraccountname='Sandbox'
webaccountname='Sandbox-Web'


