#!/bin/bash
# https://github.com/tradichel/SecurityMetricsAutomation
# Org/stacks/S3/org_s3_functions.sh
# author: @teriradichel @2ndsightlab
###############################################################
source ../../../Functions/shared_functions.sh

profile="OrgRoot"

deploy_s3accesslog_bucket_policy(){

   bucketpolicyname="S3AccessLogBucketPolicy"
   template='cfn/Policy/S3AccessLogBucketPolicy.yaml'
   resourcetype="S3BucketPolicy"

   deploy_stack $profile $bucketpolicyname $resourcetype $template	

}

deploy_cloudtrail_bucket_policy() {
  trail="$1"

  orgid=$(get_organization_id)

  function=${FUNCNAME[0]}
  validate_param "orgid" "$orgid" "$function"

  parameters=$(add_parameter "OrganizationIdParam" "$orgid")
  if [ "$trail" != "" ]; then
     parameters=$(add_parameter "" "$trail" $parameters)
  fi

  bucketpolicyname="CloudTrailBucketPolicy"
  resourcetype="S3BucketPolicy"
  template='cfn/Policy/CloudTrailBucketPolicy.yaml'

  deploy_stack $profile $bucketpolicyname $resourcetype $template "$parameters"

}

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
