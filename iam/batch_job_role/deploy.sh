# batch_job_role/deploy.sh
# author: @teriradichel @2ndsightlab
# deploy an IAM role used by a batch job
job="$1"
batchjobtype="$2"
profile="$3"

if [ "$job" == "" ]; then
  echo "You must pass in the job name with matches a directory."
  echo "The job name should not contain special characters or start with a number."
  exit
fi

if [ "$batchjobtype" == "" ]; then
  echo "You must pass in a batch job type of "iam" or "batch" for batch job: $job"
	echo "Only the Batch Administrator can assume a role of type batch."
	echo "Only the IAM Administrator can assume a role of time iam."
  exit
fi

if [ "$profile" == "" ]; then
  profile="default";
fi

stackname="BatchJobRole"$job

echo "Stackname: "$stackname
echo "Job: "$job
echo "Batch Job Type: "$batchjobtype

echo "-------------- JOB ROLE:$job -------------------"
aws cloudformation deploy \
    --profile $profile \
    --capabilities CAPABILITY_NAMED_IAM \
    --stack-name $stackname \
    --template-file cfn/role_batch_job.yaml \
    --parameter-overrides \
      jobnameparam=$job \
      batchjobtypeparam=$batchjobtype

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
