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

s="awsdeploy/deploy/root-orgadminrole/environment.sh"
validate_set $s "profile" $profile
validate_set $s "region" $region
validate_environment $s $env
#validate_set $s "parameters" $parameters

#so we can switch back to the original profile
orgprofile=$profile

echo "*******************************************************************"
echo "Deploy $env kms ami key"
echo "*******************************************************************"
accountname=$env'-kms'
accountid=$(get_account_number_by_account_name $accountname)

validate_set $s "kmsaccountname" $accountname
validate_set $s "kmsaccountid" $accountid

echo "*******************************************************************"
echo "Assume KMS account organizations role for $accountname $accountid"
echo "*******************************************************************"
assume_organizations_role $accountname
profile="$accountname"

echo "*******************************************************************"
echo "Deploying project resources in account: $accountname id: $accountid"
echo "profile: $profile"
echo "region: $region"
echo "env: $env"
echo "parameters: $parameters"
echo "*******************************************************************"

scripts=(
	#"kmsadminrole/kms_key_env_amis.sh"
)

#deploy all the scripts in the list
for s in ${scripts[*]}
do
	c="./deploy/$s $profile $region $env $parameters"; bash $c; 
done

echo "*******************************************************************"
echo "Return to root-orgadmin role"
echo "*******************************************************************"

profile=$orgprofile

echo "*******************************************************************"
echo "Deploy AMI account resources"
echo "*******************************************************************"
accountname=$env'-ami'
accountid=$(get_account_number_by_account_name $accountname)

echo "*******************************************************************"
echo "Assume AMIS account organizations role for $accountname $accountid"
echo "*******************************************************************"
assume_organizations_role $accountname
profile="$accountname"

echo "*******************************************************************"
echo "Deploying project resources in account: $accountname id: $accountid"
echo "profile: $profile"
echo "region: $region"
echo "env: $env"
echo "parameters: $parameters"
echo "*******************************************************************"

scripts=(
	"iamadminrole/iam_role_flowlogsrole.sh"
  "networkadminrole/ec2_vpc_amis.sh"
)

#deploy all the scripts in the list
for s in ${scripts[*]}
do
  c="./deploy/$s $profile $region $env $parameters"; bash $c; 
done

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
