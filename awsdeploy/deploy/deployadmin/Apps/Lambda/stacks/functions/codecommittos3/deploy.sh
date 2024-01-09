#!/bin/bash -e
#https://github.com/tradichel/SecurityMetricsAutomation
#Apps/Lambda/stacks/functions/dockertest/deploy
#author @teriradichel @2ndsightlab
#deploy lambda with container
####################################
source ../../../../../Functions/assume_role.sh
source ../../../../../Functions/shared_functions.sh

#function name
fname="codecommittos3"
env="Sandbox"

secret="true"

#deploy lambda IAM role
change_dir "IAMRole" "IAM"
awsservice='Lambda'
rolename=$fname$awsservice'Role'
deploy_aws_service_role $rolename $awsservice

actions="codecommit:GitPull"
resources="arn:aws:codecommit:xx-xxxx-x:464339214996:dev.*"
readbucket="arn:aws:s3:::sandboxwebaccount-xxxxxxxxxxxx-devrainierrhododendronscom"
writebucket=""
deploy_app_policy "$awsservice" "$fname" "$env" "$secret" "$readbucket" "$writebucket" "$actions" "$resources"

#deploy lambda
change_dir "Lambda" "SandboxAdmin"
deploy_lambda $fname $env $secret





