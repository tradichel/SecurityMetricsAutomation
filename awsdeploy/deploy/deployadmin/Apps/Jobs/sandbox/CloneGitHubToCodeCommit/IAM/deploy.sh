#!/bin/bash
#deploy the IAM roles and resources required by this batch job

source ../../../../../Functions/assume_role.sh
source ../../../../../Functions/shared_functions.sh

change_dir 'IAMRole' 'IAM'

env="Sandbox"
jobname='CloneGitHubToCodeCommit2'
secret='true'

#compute environment role and policy
awsservice='Batch'
rolename='BatchServiceComputeEnvironmentRole'
deploy_aws_service_role $rolename $awsservice

policyname=$rolename'Policy'
deploy_role_policy $policyname

#ec2 instance role
awsservice='EC2'
rolename='BatchECSInstanceRole'
deploy_aws_service_role $rolename $awsservice

policyname=$rolename'Policy'
deploy_role_policy $policyname

#ecs agent role
awsservice='ECSTasks'
rolename='BatchECSAgentRole'
deploy_aws_service_role $rolename $awsservice

policyname=$rolename'Policy'
deploy_role_policy $policyname

#job role - used in secret resource policy
awsservice='ECSTasks'
rolename=$jobname$awsservice'Role'
deploy_aws_service_role $rolename $awsservice

#batch job role secret
change_dir 'Secret' 'SandboxAdmin'

 if [ "$secret" == "true" ]; then
    #change_dir "Key"
    kmskeyid=$(get_kms_key_id $env'Key')

    if [ "$kmskeyid" == "" ]; then
      echo "KMS key id is not set." 1>&2
      exit 1
    fi

    echo "KMS Key ID: $kmskeyid"

    acctid=$(get_account_id)
    readonlyroles='arn:aws:iam::'$acctid:role/$jobname'BatchRole'
    secretname=$jobname'Secret'
    change_dir "Secret"
    create_secret $secretname $kmskeyid $readonlyroles

 fi

change_dir 'IAMRole' 'IAM'

#references secret, so deploy after secret
awsservice='ECSTasks'
policyname=$rolename'Policy'
deploy_app_policy "$jobname" "$env" "$secret" "$awsservice"







