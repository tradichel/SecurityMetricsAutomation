#!/bin/bash -e
# https://github.com/tradichel/SecurityMetricsAutomation
# Org/stacks/Account/deploy.sh
# author: @teriradichel @2ndsightlab
# Description: Deploy Sandbox account and admin
##############################################################

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
##################################################################################
# Copyright Notice
# All Rights Reserved.
# All materials (the “Materials”) in this repository are protected by copyright
# under U.S. Copyright laws and are the property of 2nd Sight Lab. They are provided
# pursuant to a royalty free, perpetual license the person to whom they were presented
# by 2nd Sight Lab and are solely for the training and education by 2nd Sight Lab.
#
# The Materials may not be copied, reproduced, distributed, offered for sale, published,
# displayed, performed, modified, used to create derivative works, transmitted to
# others, or used or exploited in any way, including, in whole or in part, as training
# materials by or for any third party.
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
# INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
# PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
################################################################################
