#!/bin/bash -e
# https://github.com/tradichel/SecurityMetricsAutomation
# awsdeploy/userdata.sh
# author: @tradichel @2ndsightlab
# description: Test userdata inside a container
# note: works, but not done - need to manually update values
##############################################################
adminname="rootadmin"
rolename="rootadminrole"
script="listroles"
jobname=$rolename$job
script="$script.sh"

#for secret
region=$(aws configure list | grep region | awk '{print $2}')
account=$(aws sts get-caller-identity --query Account --output text)
secretid='rootadminsecret-6036CU'
secret=$(aws secretsmanager get-secret-value --secret-id 'arn:aws:secretsmanager:'$region':'$account':secret:'$secretid --query SecretString --output text)
access_key_id=$(echo $secret | jq -r ".aws_access_key_id")
secret_key=$(echo $secret | jq -r ".aws_secret_key")

#configure cli profile
remoteregion="xx-xxxx-x"
aws configure set aws_access_key_id $access_key_id --profile $rolename
aws configure set aws_secret_access_key $secret_key --profile $rolename
aws configure set region $remoteregion --profile $rolename
aws configure set output "json" --profile $rolename

code=168230
mfadevicename="$adminname"
account=$(aws sts get-caller-identity --query Account --output text --profile $rolename)
creds=$(aws sts assume-role --token-code $code --serial-number 'arn:aws:iam::'$account':mfa/'$mfadevicename --role-session-name $jobname --role-arn 'arn:aws:iam::'$account':role/'$rolename --profile $rolename)

accesskeyid="$(echo $creds | jq -r ".Credentials.AccessKeyId")"
secretaccesskey="$(echo $creds | jq -r ".Credentials.SecretAccessKey")"
sessiontoken="$(echo $creds | jq -r ".Credentials.SessionToken")"

sudo yum update -y
sudo yum -y install docker
sudo service docker start
sudo usermod -a -G docker ec2-user
sudo systemctl enable docker
docker version

image="awsdeploy"
repo="sandbox"
pass=$account'.dkr.ecr.'$region'.amazonaws.com'
tag="$pass/$repo:$image"

aws ecr get-login-password --region $region | docker login --username AWS --password-stdin $pass
docker pull $tag

docker run $tag "$jobname" "$accesskeyid" "$secretaccesskey" "$sessiontoken" "$region" "$script"

#################################################################################
# Copyright Notice
# All Rights Reserved.
# All materials (the “Materials”) in this repository are protected by copyright 
# under U.S. Copyright laws and are the property of 2nd Sight Lab. They are provided 
# pursuant to a royalty free, perpetual license the person to whom they were presented 
# by 2nd Sight Lab and are solely for the training and education by 2nd Sight Lab.
#
# The Materials may not be copied, reproduced, distributed, offered for sale, published, 
# displayed, performed, modified, used to create derivative works, transmitted to 
# others, or used or exploited in any way, including, in whole or in part, as training 
# materials by or for any third party.
#
# The above copyright notice and this permission notice shall be included in all 
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
# INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A 
# PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT 
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION 
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
################################################################################
