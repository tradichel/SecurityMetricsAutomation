#!/bin/bash -e
jobname='CloneGitHubtoCodeCommit'
rolename=$jobname'Role'
region=$(aws configure list | grep region | awk '{print $2}')
account=$(aws sts get-caller-identity --query Account --output text)
secretid='SandboxDevAutomationSecret-qxDynd'

secret=$(aws secretsmanager get-secret-value --secret-id 'arn:aws:secretsmanager:'$region':'$account':secret:'$secretid --query SecretString --output text)

access_key_id=$(echo $secret | jq -r ".aws_access_key_id")
secret_key=$(echo $secret | jq -r ".aws_secret_key")

aws configure set aws_access_key_id $access_key_id --profile $rolename
aws configure set aws_secret_access_key $secret_key --profile $rolename
aws configure set region $region --profile $rolename
aws configure set output "json" --profile $rolename

code=074194
mfadevicename="SandboxDevAutomationMFA"

creds=$(aws sts assume-role --token-code $code --serial-number 'arn:aws:iam::'$account':mfa/'$mfadevicename --role-session-name $jobname --role-arn 'arn:aws:iam::'$account':role/'$jobname'Role' --profile $rolename)

accesskeyid="$(echo $creds | jq -r ".Credentials.AccessKeyId")"
secretaccesskey="$(echo $creds | jq -r ".Credentials.SecretAccessKey")"
sessiontoken="$(echo $creds | jq -r ".Credentials.SessionToken")"

sudo yum update -y
sudo yum -y install docker
sudo service docker start
sudo usermod -a -G docker ec2-user
sudo systemctl enable docker
docker version

image="assumerole"
repo="sandbox"
pass=$account'.dkr.ecr.'$region'.amazonaws.com'
tag="$pass/$repo:$image"

aws ecr get-login-password --region $region | docker login --username AWS --password-stdin $pass
docker pull $tag

docker run $tag "CloneGitHubtoCodeCommitRole" "$accesskeyid" "$secretaccesskey" "$sessiontoken" "$region"
