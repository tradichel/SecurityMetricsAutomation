#!/bin/bash -e
#/kms/deploy_key_trigger_batch_job_secrets.sh
#author: @teriradichel @2ndsightlab

#pass in the arn of the identities allowed to encrypt and decrypt using the KMS key
encryptarn="$1"
decryptarn="$2"
profile="$3"

if [ "$encryptarn" == "" ];then
  echo "An encrypt ARN is required. deploy_trigger_batch_key.sh encrytarn decryptarn [profile]"
  exit
fi

if [ "$decryptarn" == "" ];then
  echo "An decrypt ARN is required. deploy_trigger_batch_key.sh encrytarn decryptarn [profile]"
  exit
fi

if [ "$profile" == "" ]; then
  profile="default";
fi

desc="Key to encrypt secrets used to kick off batch jobs"
keyalias="batchcredkey"

#myarn=$(aws sts get-caller-identity --query Arn \
#        | cut -d "/" -f -2 \
#        | sed 's/assumed-role/role/' \
#        | sed 's/sts/iam/' \
#        | sed 's/"//')

echo "Encrypt Arn: " $encryptarn
echo "Decrypt Arn: " $decryptarn

echo "Arn for profile: $profile"
aws sts get-caller-identity --profile $profile

echo "-------------- KMS KEY -------------------"
aws cloudformation deploy \
    --profile $profile \
    --stack-name BatchKms$keyalias \
    --template-file cfn/kms_key.yaml \
    --parameter-overrides descparam="$desc" encryptarnparam="$encryptarn" decryptarnparam="$decryptarn"


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
