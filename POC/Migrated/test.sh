#!/bin/bash
echo "Enter code:"
read -s code

creds=$(aws sts assume-role --token-code $code --serial-number arn:aws:iam::xxxxxxxxxxxx:mfa/CloneGitJob --role-session-name job --role-arn arn:aws:iam::xxxxxxxxxxxx:role/CloneGitHubtoCodeCommitRole --profile job)

echo $creds

accesskeyid="$(echo $creds | jq -r ".Credentials.AccessKeyId")"
secretaccesskey="$(echo $creds | jq -r ".Credentials.SecretAccessKey")"
sessiontoken="$(echo $creds | jq -r ".Credentials.SessionToken")"

echo $accesskeyid
echo $secretaccesskey
echo $sessiontoken




