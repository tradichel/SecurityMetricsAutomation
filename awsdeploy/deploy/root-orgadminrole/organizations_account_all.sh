#!/bin/bash -e
# https://github.com/tradichel/SecurityMetricsAutomation
# awsdeploy/deploy/orgadminrole/organizations_account_all.sh
# author: @teriradichel @2ndsightlab
# Description: Deploy all accounts
##############################################################
source resources/organizations/account/account_functions.sh
source deploy/shared/functions.sh
source deploy/shared/validate.sh

profile="$1"
region="$2"

deploy_accounts(){
	accounts=("$@")

	for account in "${accounts[@]}";
		do
			./deploy/root-orgadminrole/organizations_account_$account.sh $profile $region &
		done
		wait #wait for batch to complete
}

#can only deloy 5 accounts at a time
accounts=("org_iam" "org_billing" "org_policies" "org_logmonitor" "nonprod_kms")
deploy_accounts "${accounts[@]}"

accounts=("nonprod_sandbox" "nonprod_repository" "nonprod_domain" "nonprod_ami")
deploy_accounts "${accounts[@]}"

accounts=("nonprod_web" "org_deploy" "org_backup" "nonprod_backup" )
deploy_accounts "${accounts[@]}"

#wait for stacks to complete
wait

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