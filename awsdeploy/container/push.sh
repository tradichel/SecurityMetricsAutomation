#!/bin/bash
# https://github.com/tradichel/SecurityMetricsAutomation
# awsdeploy/push.sh
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






