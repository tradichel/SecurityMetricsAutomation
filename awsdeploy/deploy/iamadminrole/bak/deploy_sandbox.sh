#!/bin/bash -e
#

source role_functions.sh

policyname="ECSCloudWatchPolicy"
deploy_role_policy $policyname

awsservice='Batch'
rolename='BatchComputeEnvironmentRole'
deploy_aws_service_role $rolename $awsservice

awsservice='Batch'
rolename='BatchComputeEnvironmentRole2'
deploy_aws_service_role $rolename $awsservice

policyname=$rolename'Policy'
deploy_role_policy $policyname
  
exit

awsservice='VPCFlowLogs'
rolename=$awsservice'Role'
deploy_aws_service_role $rolename $awsservice

policyname='VPCFlowLogsPolicy'
deploy_role_policy $policyname


