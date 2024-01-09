#!/bin/bash
# https://github.com/tradichel/SecurityMetricsAutomation
# Apps/Containers/dockertest/push.sh
# author: @teriradichel @2ndsightlab
##############################################################

profile="SandboxAdmin"
repo="sandbox"
image=$(basename "$PWD")
echo "Pushing docker image: $image"

region=$(aws configure list --profile $profile | grep region | awk '{print $2}')
aws_account_id=$(aws sts get-caller-identity --query Account --output text --profile $profile)

imageid=$(docker images | grep $image | grep 'latest' | awk '{print$3}')

pass=$aws_account_id'.dkr.ecr.'$region'.amazonaws.com'
tag="$pass/$repo:$image"

echo "Pushing image id $imageid to $tag"

aws ecr get-login-password --region $region --profile $profile | docker login --username AWS --password-stdin $pass

docker tag $imageid $tag

docker push $tag







