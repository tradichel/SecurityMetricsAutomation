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
  validate_param "orgid" $orgid $function

  parameters=$(add_parameter "OrganizationIdParam" "$orgid")
  if [ "$trail" != "" ]; then
     parameters=$(add_parameter "" "$trail" $parameters)
  fi

  bucketpolicyname="CloudTrailBucketPolicy"
  resourcetype="S3BucketPolicy"
  template='cfn/Policy/CloudTrailBucketPolicy.yaml'

  deploy_stack $profile $bucketpolicyname $resourcetype $template "$parameters"

}


