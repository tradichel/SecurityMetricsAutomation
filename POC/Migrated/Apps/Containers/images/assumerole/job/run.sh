#!/bin/bash
#

#include files
source /job/validate.sh
source /job/secrets.sh

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

	rolename="$1"
	access_key="$2"
	secret_key="$3"
	session_token="$4"
	region="$5"
	repo="$6"

  echo "### Creating profile for $rolename ###"
  aws configure set aws_access_key_id $access_key --profile $rolename
  aws configure set aws_secret_access_key $secret_key --profile $rolename
  aws configure set aws_session_token $session_token --profile $rolename
  aws configure set region $region --profile $rolename
  aws configure set output "json" --profile $rolename

  #clear variables
  access_key=""
  secret_key=""
  session_token=""

  echo "### Created AWS CLI profile: $rolename ###"

	aws sts get-caller-identity --profile $rolename

	exit

  echo "### Get Git Secrets ###"
  secret="CloneGitHubtoCodeCommitSecret"

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
