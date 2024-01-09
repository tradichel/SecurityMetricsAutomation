#!/bin/bash

name="assumerole"
echo "$name" | ../../build.sh

echo "Enter code:"
read -s code

creds=$(aws sts assume-role --token-code $code --serial-number arn:aws:iam::464339214996:mfa/CloneGitJob --role-session-name job --role-arn arn:aws:iam::464339214996:role/CloneGitHubtoCodeCommitRole --profile job)

accesskeyid="$(echo $creds | jq -r ".Credentials.AccessKeyId")"
secretaccesskey="$(echo $creds | jq -r ".Credentials.SecretAccessKey")"
sessiontoken="$(echo $creds | jq -r ".Credentials.SessionToken")"

echo "Run docker container"
docker run $name:latest "CloneGitHubtoCodeCommitRole" "$accesskeyid" "$secretaccesskey" "$sessiontoken" "xx-xxxx-x" 
