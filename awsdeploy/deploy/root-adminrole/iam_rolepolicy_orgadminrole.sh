#!/bin/bash -e
# https://github.com/tradichel/SecurityMetricsAutomation
# awsdeploy/deploy/rootadminrole/iam_rolepolicy_orgadminrolepolicy.sh
# author: @teriradichel @2ndsightlab
# Description: Policy for root-orgadminrole in management account
##############################################################
profile="$1"
region="$2"

source resources/organizations/organization/organization_functions.sh
source resources/iam/rolepolicy/rolepolicy_functions.sh
source deploy/shared/functions.sh
source deploy/shared/validate.sh

s="deploy/rootadminrole/iam_rolepolicy_orgadminrolepolicy.sh"
validate_set $s "profile" $profile
validate_set $s "region" $region

rolename="orgadminrole"
policyname=$rolename'policy'
account=$(get_management_account_number)
validate_set $s "account" $account
rolearn="arn:aws:iam::$account:role/$rolename"
env="root"

deploy_rolepolicy $policyname $rolearn $env

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
