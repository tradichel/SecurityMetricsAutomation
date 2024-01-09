#!/bin/bash -e
# https://github.com/tradichel/SecurityMetricsAutomation
# awsdeploy/deploy/root-orgadminrole/organizations_account.sh
# author: @teriradichel @2ndsightlab
# Description: Deploy root-orgadmin account subject to 
# service control policies, unlike the root account
##############################################################

source deploy/shared/validate.sh
source resources/organizations/account/account_functions.sh
source resources/ssm/parameter/parameter_functions.sh

caller="deploy/root-orgadminrole/organizations_account.sh"

profile="$1"
region="$2"
accountname="$3"
ouname="$4"

if [ "$ouname" == "" ] || [ "$ouname" == "root" ]; then
	echo "Deploying accounts in the root OU is not allowed."
fi
 
validate_set $caller "profile" $profile
validate_set $caller "region" $region
validate_set $caller "accountname" $accountname
validate_set $caller "ouname" $ouname

#deploy the account
deploy_account "$accountname" "$ouname"

#get the org parameter value
org=$(get_ssm_parameter_value "org")
validate_set $caller "org" $org

#create the aws cli profile matching account name
assume_organizations_role $accountname

#create the alias
alias=$org'-'$accountname

#set the alias - the account name is the AWS CLI profile 
#after calling assume_organizations_role $accountname
create_account_alias $alias $accountname

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

