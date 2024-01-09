#!/bin/bash -e
# https://github.com/tradichel/SecurityMetricsAutomation
# awsdepoy/deploy/rootadminrole/organization_service_trusted_access.sh
# author: @teriradichel @2ndsightlab
# Description: Enable or disable trusted access for an organization
##############################################################
profile="$1"
region="$2"

source resources/organizations/organization/organization_functions.sh
source deploy/shared/functions.sh
source deploy/shared/validate.sh

validate_set "profile" $profile
validate_set "region" $region

enable_service "cloudtrail"
#migration service
disable_service "mgn"
enable_service "account"
#bug?
#disable_service "artifact"
disable_service "auditmanager"
disable_service "backup"
#bug?
#disable_service "stacksets.cloudformation"
disable_service "compute-optimizer"
disable_service "config"
disable_service "controltower"
disable_service "detective"
disable_service "devops-guru"
#firewall manager
disable_service "fms"
enable_service "guardduty"
disable_service "health"
disable_service "inspector2"
disable_service "license-manager"
disable_service "macie"
disable_service "license-management.marketplace"
#Resource Access Manager
disable_service "ram"
disable_service "resource-explorer-2"
disable_service "storage-lens.s3"
disable_service "securitylake"
disable_service "servicecatalog"
disable_service "sso"
disable_service "ssm"
disable_service "tagpolicies.tag"
enable_service "reporting.trustedadvisor"
disable_service "wellarchitected"
#ip management
disable_service "ipam"
disable_service "reachabilityanalyzer.networkinsights"

echo "~~~"
echo "Manually enable AWS IAM Access Analyzer"
echo "https://docs.aws.amazon.com/IAM/latest/UserGuide/access-analyzer-getting-started.html"
echo "~~~"
echo "Manually enable cost and usage reports for the organization."
echo "https://medium.com/cloud-security/enabling-cost-and-usage-5a7e4ba99791"
echo "~~~"
echo "Network manager can be enabled via the console for CloudWan and Transit Gateway"
echo "https://docs.aws.amazon.com/organizations/latest/userguide/services-that-can-integrate-network-manager.html"
echo  "~~~"
echo "When you create a delegated adminstrator for Security Hub, the service is automatically enabled"
echo "https://docs.aws.amazon.com/organizations/latest/userguide/services-that-can-integrate-securityhub.html"
echo "~~~"
echo "Enable AWS Directory service manually if you need it."
echo "https://docs.aws.amazon.com/organizations/latest/userguide/services-that-can-integrate-directory-service.html"
echo "Done."
echo "~~~"
echo "IAM Service last access works across organizations and does not need to be enabled."
echo "https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_access-advisor.html"
echo "~~~"
echo "You can automate requests to change service quotas in new accounts using a service quota template"
echo "https://docs.aws.amazon.com/cli/latest/reference/service-quotas/"
echo "~~~"

echo "Done."
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
