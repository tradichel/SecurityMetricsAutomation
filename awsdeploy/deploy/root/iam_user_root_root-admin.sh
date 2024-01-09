#!/bin/bash -e
# https://github.com/tradichel/SecurityMetricsAutomation
# awsdeploy/deploy/root/iam_user_root-admin.sh
# author: @teriradichel @2ndsightlab
# Description: Copy files used below to AWS CloudShell
# in a new account and execute each script. 
# Then deploy the resourcs in the /deploy/root-adminrole folder
# using the new root-adminrole
##############################################################
#resources/iam/user/user.yaml
aws cloudformation deploy --template-file user.yaml --stack-name root-root-iam-user-root-admin --capabilities CAPABILITY_NAMED_IAM --parameter-overrides NameParam=root-admin ConsoleAccessParam=true

#resources/iam/managedpolicy/root-accountrolepermissionsboundary.yaml
aws cloudformation deploy --template-file root-permissionsboundary.yaml  --stack-name root-root-iam-managedpolicy-root-permissionboundary --capabilities CAPABILITY_NAMED_IAM

#resources/iam/userpolicy/root-adminuserpolicy.yaml
aws cloudformation deploy --template-file root-adminuserpolicy.yaml --stack-name root-root-iam-userpolicy-root-adminuserpolicy --capabilities CAPABILITY_NAMED_IAM

#resources/iam/role/role.yaml
aws cloudformation deploy --template-file root-adminrole.yaml --stack-name root-root-role-iam-root-adminrole --capabilities CAPABILITY_NAMED_IAM

#resources/iam/rolepolicy/root-adminrolepolicy.yaml
aws cloudformation deploy --template-file root-adminrolepolicy.yaml --stack-name root-root-iam-rolepolicy-root-adminrolepolicy --capabilities CAPABILITY_NAMED_IAM

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

