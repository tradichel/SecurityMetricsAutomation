#!/bin/bash -e
# https://github.com/tradichel/SecurityMetricsAutomation
# Org/stacks/S3/deploy.sh
# description: deploy buckets owned by OrgRoot
# Executed in the organization's management account
###############################################################
source ../../../S3/stacks/s3_functions.sh
source org_s3_functions.sh

echo "------Create a CLI profile for the OrgRoot user before running this script ---"
echo "----- see blog post about the org root user in the blog series"

##deploy buckets
cd ../../../S3/stacks/

profile="OrgRoot"
suffix="s3accesslogs"
keyalias="OrgRootCloudTrail"

deploy_s3_bucket $profile $suffix $keyalias

suffix=cloudtrail

deploy_s3_bucket $profile $suffix $keyalias

cd ../../Org/stacks/S3

deploy_cloudtrail_bucket_policy

deploy_s3accesslog_bucket_policy

################################################################################
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
