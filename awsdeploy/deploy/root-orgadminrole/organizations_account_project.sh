#!/bin/bash -e
# https://github.com/tradichel/SecurityMetricsAutomation
# awsdeploy/deploy/root-orgadminrole/organizations_account_project.sh
# author: @teriradichel @2ndsightlab
# Description: Account for a segregated project account
##############################################################

source deploy/shared/functions.sh
source deploy/shared/validate.sh
source resources/organizations/account/account_functions.sh

profile="$1"
region="$2"
env="$3"
parameters="$4"

s="awsdeploy/deploy/root-orgadminrole/organizations_account_project.sh"
validate_set $s "profile" $profile
validate_set $s "region" $region
validate_environment $s $env
validate_set $s "parameters" $parameters

projectid=$(get_container_parameter_value "$parameters" "projectid")
validate_set $s "projectid" $projectid

accountname=$env'-'$projectid

echo "*******************************************************************"
echo "Deploy account: $accountname"
echo "*******************************************************************"

#either deploy account or assume role
./deploy/root-orgadminrole/organizations_account.sh $profile $region "$accountname" "$env-projects"

accountid=$(get_account_number_by_account_name $accountname)
#create the aws cli profile matching account name

parameters=$parameters',accountname='$accountname',accountid='$accountid

echo "*******************************************************************"
echo "Assume organizations role for $accountname"
echo "*******************************************************************"
assume_organizations_role $accountname
profile="$accountname"

echo "*******************************************************************"
echo "Deploying project resources in account: $accountname id: $accountid"
echo "profile: $profile"
echo "region: $region"
echo "env: $env"
echo "parameters: $parameters"
echo "projectid: $projectid"
echo "*******************************************************************"

scripts=(
  "iamadminrole/iam_group_project.sh"
	"iamadminrole/iam_grouppolicy_project.sh"
	"iamadminrole/iam_user_project.sh"
	"iamadminrole/iam_usertogroupaddition_project.sh"
	"kmsadminrole/kms_key_project.sh"
	"kmsadminrole/kms_keyalias_project.sh"
	"appadminrole/s3_bucket_project.sh"
	"networkadminrole/ec2_eip_project.sh"
	"iamadminrole/iam_role_flowlogsrole.sh"
	"networkadminrole/ec2_vpc_project.sh"
	"networkadminrole/ec2_networkacl_project.sh"
	"networkadminrole/ec2_networkaclentry_project_httpandhttpsoutbound.sh"
	"networkadminrole/ec2_networkaclentry_project_remoteaccessinbound.sh"
	"networkadminrole/ec2_networkaclentry_project_blockunwantedinbound.sh"
  "networkadminrole/ec2_networkaclentry_project_exceptionsinbound.sh" 
	"networkadminrole/ec2_subnet_project.sh"
	"networkadminrole/ec2_subnetnaclassociation_project.sh"
  "networkadminrole/ec2_securitygroup_project.sh"	
	"networkadminrole/ec2_securitygroupingressegress_project.sh"
  "secretsadminrole/secretsmanager_secret_projectusersecret.sh"
	"user/ec2_sshkey_projectuser.sh"
  "user/ec2_instance_projectec2linux.sh"
	"user/ec2_instance_projectec2ubuntu.sh"
	"user/ec2_instance_projectec2windows.sh"
)

#deploy all the scripts in the list
for s in ${scripts[*]}
do
   c="./deploy/$s $profile $region $env $parameters"
   echo $c
   bash $c
done

	echo "TODO: scripts in deploy/root-orgadminrole/organizations_account_project.sh"
	echo "~~~~" 
	echo "TODO: 9. build Linux AMI in AMIs account"
	echo "TODO: 8. share AMI to project account"
	echo "TODO: 7. amiadmin/ec2_instance_projectec2linux.sh"
	echo "TODO: 6. test role"
	echo "TODO: 5. build Ubuntu AMI in AMIs account"
	echo "TODO: 4. share amin to project account"
	echo "TODO: 3. amiadmin/ec2_instance_projectec2ubuntu.sh"
	echo "TODO: 2. Test web credentials"
	echo "TODO: 1. S3 bucket policy: appadminrole/s3_bucketpolicy_projectbucketpolicy.sh"
	
	echo "~~~ OTHER ~~~"
 	echo "TODO: Parameter list in SSM Parameter Store"
	echo "TODO: Check all headers, footers, and file names in every folder - fix"
	echo "TODO: Move existing code to POC repo"
	echo "TODO: Git Secrets on POC code"
	echo "TODO: Git Secrets on new code"
	echo "TODO: CodeCommit repo for new code"
	echo "TODO: Check in all code"
	
	echo "TODO: User secret policy so user can access their own secret"
	echo "TODO: Add KMS Admin to all keys from KMS accnt - need something other than org role"
	echo "TODO: Remove org role from key after deploy?"

#################################################################################
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
