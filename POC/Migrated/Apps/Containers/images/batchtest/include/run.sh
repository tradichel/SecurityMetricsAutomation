#!/bin/bash
#

#include files
source validate.sh
source parameters.sh

#functions
get_repo_name() {
  event="$1"

  repo=$(echo $token | jq -r .github_repo)
  validate_set $repo "repo"
  validate_alphanumeric_underscore_dash_period $repo
  echo $repo

}

get_token() {
  event="$1"

  token=$(echo $event | jq -r .token)
  validate_set $token "token"
  valdiate_length $token 6
  token=$(safe_numeric $token)
  echo $token

}


#main

  repo=$(get_repo_name "repo")
  token=$(get_token "token")

  echo "### Get the credentials for the automation user ###"
  access_key=$(get_secret_value "secret_key_id")
  secret_key=$(get_secret_value "secret_access_key")
  mfa_serial=$(get_secret_value "mfa_serial")
  lambda_assume_role=$(get_secret_value "assume_role")

  user="automation"

  echo "### Create a profile for the automation user ####"
  aws configure set aws_access_key_id $access_key --profile $user
  aws configure set aws_secret_access_key $secret_key --profile $user
  aws configure set region $AWS_DEFAULT_REGION --profile $user
  aws configure set output "json" --profile $user

  echo "### Assume the Lambda role ####"

  creds=$(aws sts assume-role --role-arn "$lambda_assume_role" \
        --role-session $FUNCTION_NAME \
        --profile $FUNCTION_NAME \
        --serial-number $mfa_serial \
        --token-code $token \
        --profile $user \
        --debug )

  echo "### Role assumed. Retrieving temporary credentials. ###"
  access_key=$(echo $creds | jq -r '.Credentials''.AccessKeyId');
  secret_key=$(echo $creds | jq -r '.Credentials''.SecretAccessKey');
  session_token=$(echo $creds | jq -r '.Credentials''.SessionToken');

  echo "### Creating profile for $rolename ###"

  aws configure set aws_access_key_id $access_key --profile $rolename
  aws configure set aws_secret_access_key $secret_key --profile $rolename
  aws configure set aws_session_token $session_token --profile $rolename
  aws configure set region $AWS_DEFAULT_REGION --profile $rolename
  aws configure set mfa_serial $mfa_serial --profile $rolename
  aws configure set output "json" --profile $rolename

  #clear variables
  access_key=""
  secret_key=""
  session_token=""

  echo "### Created AWS CLI profile: $rolename ###"

  echo "### Get Git Secrets ###"
  secret="GitSecrets"

  pat=$(get_secret_value_for_profile "github_pat" $rolename $secret)
  owner=$(get_secret_value_for_profile "github_owner" $rolename $secret)
  auth=$(echo -n "x-access-token:$pat" | base64 | tr -d '\n')

  echo "### Clone github repo bare ###"
  github_repo='https://github.com/'$owner'/'$repo'.git'
  git --bare -c http.$github_repo.extraheader="Authorization: Basic $auth" clone $github_repo

  #clear variables
  auth=""
  owner=""
  pat=""

  ls -al

  cd $repo
  ls
  echo "### Push to AWS CodeCommit ###"
  aws_repo='https://git-codecommit.'$AWS_DEFAULT_REGION'.amazonaws.com/v1/repos/'$repo'.git'
  #git push --mirror $aws_repo
  cd ..
  rm -rf $repo

  rm $AWS_CONFIG_FILE
  rm $AWS_SHARED_CREDENTIALS_FILE
