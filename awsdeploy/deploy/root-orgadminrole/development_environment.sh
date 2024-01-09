#!/bin/bash -e
# https://github.com/tradichel/SecurityMetricsAutomation
# Org/stacks/Account/deploy.sh
# author: @teriradichel @2ndsightlab
# Description: Deploy Sandbox account and admin
##############################################################

#I'm totally messing around with this script to set up 
#an account. It's got things commented out that no longer work but
#I wrote about in past posts as this evolves into something useful to set up
#new environments (accounts)

#include the common functions
source ../../../../Functions/shared_functions.sh 
source ../../../../Functions/assume_role.sh
#source ../../../IAM/stacks/User/user_functions.sh
#source ../../../IAM/stacks/Group/group_functions.sh
#source ../../../IAM/stacks/Role/role_functions.sh

#all the following needs revision to to work with new change_dir
#functions and profiles, not to mention switching to OKTA

#profile used to create the cross-account role
profile="OrgRoot"
accountname="Sandbox"
user="SandBoxAdmin"
kmsadmins="sandbox-2sldev-admin" #role name for administration of Sandbox env including KMS keys

acctnum=$(get_account_number $accountname)
rolename=$(get_account_org_role $accountname)

#echo "- CREATE CROSS ACCOUNT ROLE PROFILE account name: $acctnum rolename: $rolename account name: $accountname --"
#profile=$(create_cross_account_role_profile $acctnum $rolename $accountname)

#echo "New profile: $profile"

#echo "Deploy IAM User: Sandbox Admin"
#cd ../../../IAM/stacks/User
#deploy_sandbox_admin 'SandboxAdmin'
#cd ../../../Org/stacks/Sandbox

#echo "Deploy KMS Admins Group and add Sandbox Admin"
#cd ../../../IAM/stacks/Group
#deploy_group $kmsadmins
#add_users_to_group $user $kmsadmins
#cd ../../../Org/stacks/Sandbox

#echo "Deploy KMSAdmins Group Role"
#cd ../../../IAM/stacks/Role
#deploy_group_role $kmsadmins
#cd ../../../Org/stacks/Sandbox

#Deploy Batch ServiceLinked role

#deploy a KMS key for the Sandbox environment

#get Sandbox account number
profile="OrgRoot"
sandboxacct=$(get_account_number_by_name "Sandbox")

#change to KMS directory
dir="Key"
profile="SandboxAdminRole"
change_dir "$dir"

#encryptarns
sandboxadmin="arn:aws:iam::$sandboxacct:user/SandboxAdmin"
webadmin="arn:aws:iam::$sandboxacct:user/WebAdmin"
sandboxdev="arn:aws:iam::$sandboxacct:user/SandboxDev"
encryptarns="$sandboxadmin,$webadmin,$sandboxdev"

#decryptarns
sandboxdevec2role="arn:aws:iam::$sandboxacct:role/SandboxDevEC2Role"
codecommit="arn:aws:iam::$sandboxacct:role/codecommittos3LambdaRole"
decryptarns="$encryptarns,$sandboxdevec2role,$codecommit"

#services
#usedwithservice="secretsmanager"
usedwithservice="none"
servicescanencrypt="ecr.amazonaws.com"
servicescandecrypt="ecr.amazonaws.com,secretsmanager.amazonaws.com"
creategrant="true"

keyalias="deploy"
desc=""

echo "Deploy KMS Deploy Key $keyalias"
deploy_key $encryptarns $decryptarns $keyalias $usedwithservice $creategrant $servicescanencrypt $servicescandecrypt $desc

change_dir "KeyAlias" $profile
kmskeyid=$(get_key_id_by_alias $keyalias)
deploy_key_alias $kmskeyid $keyalias

#######DEPLOY APP KEY#################

change_dir "Key" $profile

#encryptarns
sandboxadmin="arn:aws:iam::$sandboxacct:user/SandboxAdmin"
webadmin="arn:aws:iam::$sandboxacct:user/WebAdmin"
sandboxdev="arn:aws:iam::$sandboxacct:user/SandboxDev"
encryptarns="$sandboxadmin,$webadmin,$sandboxdev"

#decryptarns
decryptarns="$encryptarns"

#services
#usedwithservice="secretsmanager"
usedwithservice="none"
servicescanencrypt="s3.amazonaws.com"
servicescandecrypt="secretsmanager.amazonaws.com"
creategrant="false"

keyalias="appdata"
desc=$keyalias

echo "Deploy KMS appdata Key $keyalias"
deploy_key $encryptarns $decryptarns $keyalias $usedwithservice $creategrant $servicescanencrypt $servicescandecrypt $desc

change_dir "KeyAlias" $profile
kmskeyid=$(get_key_id_by_alias $keyalias)
deploy_key_alias $kmskeyid $keyalias

#######DEPLOY LOGS KEY#################

change_dir "Key" $profile

#encryptarns
#this should be none? Only the services that write logs
#sandboxadmin=""
#encryptarns=""

#decryptarns
sandboxadmin="arn:aws:iam::$sandboxacct:role/SandboxAdmin"
sandboxwebadmin="arn:aws:iam::$sandboxacct:role/SandboxWebAdmin"
decryptarns="$sandboxadmin,$sandboxwebadmin"
enryptarns=$decryptarns

#services
#usedwithservice="secretsmanager"
usedwithservice="none"
servicescanencrypt="s3.amazonaws.com"
servicescandecrypt=""
creategrant="false"

keyalias="logs"
desc=$keyalias

echo "Deploy KMS Deploy Key"
deploy_key $encryptarns $decryptarns $keyalias $usedwithservice $creategrant $servicescanencrypt $servicescandecrypt $desc
exit

change_dir "KeyAlias" $profile
kmskeyid=$(get_key_id_by_alias $keyalias)
echo "KMS Key ID: $kmskeyid"
deploy_key_alias $kmskeyid $keyalias


#deploy ECR repository
dir="ECR"
profile="SandboxAdmin"
change_dir $dir $profile

#has to be lowercase for ecr and S3 buckets, uppercase everywhere else
#could change the ECR template to take actual env name with a map later
env="sandbox"
principals="$encryptarns"
scanonpush="false"
immutability="MUTABLE"

create_ecr_repository $env $kmskeyid $principals $scanonpush $immutability

stack="Sandbox-User-SandboxAdmin"
exportname="SandboxAdminUserArnExport"
sbadminarn=$(get_stack_export $stack $exportname)

#echo "Create cross account role for Sandbox KMS admins"
rolename="KMSAdminsGroup"
#profile=$(create_cross_account_role_profile $acctnum $rolename)

#echo "Deploy key in Sandbox for EC2"
#cd ../../../KMS/stacks/Key
#keyalias="SandboxEC2"
#service="ec2"
#desc="SandboxEC2"
#deploy_key $sbadminarn $sbadminarn $keyalias $service "$desc"
#
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
