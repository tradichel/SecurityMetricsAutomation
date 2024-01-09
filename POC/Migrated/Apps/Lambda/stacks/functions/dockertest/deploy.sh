#!/bin/bash -e
#https://github.com/tradichel/SecurityMetricsAutomation
#Apps/Lambda/stacks/functions/dockertest/deploy
#author @teriradichel @2ndsightlab
#deploy lambda with container
####################################
source ../../../../../Functions/assume_role.sh
source ../../../../../Functions/shared_functions.sh

#function name
fname="dockertest"
env="Sandbox"

secret="true"

#deploy lambda IAM role
change_dir "IAMRole" "IAM"
awsservice='Lambda'
deploy_aws_service_role $fname $awsservice
deploy_app_policy $fname $env $secret

#deploy lambda
change_dir "Lambda" "SandboxAdmin"
deploy_lambda $fname $env $secret




