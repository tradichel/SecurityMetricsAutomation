#!/bin/bash
# https://github.com/tradichel/SecurityMetricsAutomation
# Apps/Containers/dockertest/push.sh
# author: @teriradichel @2ndsightlab
##############################################################
echo "Enter AWS CLI profile:"
read profile

aws sts get-caller-identity --profile $profile

echo "Enter the values for the ECR registry where you want to push the container."

echo "Enter region:"
read region

echo "Enter account id:"
read aws_account_id

echo "Enter repository name:"
read repo

echo "Docker images (this push file is for testing dockertest container in Lambda)"
docker images | grep dockertest

echo "Enter image id:"
read image

pass=$aws_account_id'.dkr.ecr.'$region'.amazonaws.com'
tag="$pass/$repo:dockertest"

aws ecr get-login-password --region $region --profile $profile | docker login --username AWS --password-stdin $pass

docker tag $image $tag

docker push $tag







