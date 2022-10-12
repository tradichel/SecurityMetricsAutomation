#!/bin/bash -e
# https://github.com/tradichel/SecurityMetricsAutomation
# IAM/test.sh
# author: @tradichel @2ndsightlab
#############################################################

echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo " Have you set up a role profile named IAM? "
echo " Create an AWS IAM Profile named IAM as explained "
echo " in the blog series. You can use any user in "
echo " a new AWS account to run this initial set up to "
echo " execute this initial portion of the script to "
echo " create the IAM admin user, group, and role. "
echo " Then the script will pause so you can change "
echo " your AWS CLI configuration to use the new IAM "
echo " Admin role created by this script. "
echo " Ctrl-C to exit. Enter to proceed."
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
read ok

cd stacks/User
./deploy_first_iam_admin.sh
cd ../..

cd stacks/Group
./deploy_iam_group.sh
cd ../..

cd stacks/Role
./deploy_iam_role.sh
cd ../..

echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo " IAM User is deployed."
echo " Have you added a virtual MFA device to this user?"
echo " Have you set up an AWS CLI Profile named IAM?"
echo " Exit and See README.md if you haven't."
echo " Once you are sure your new IAM admin user and "
echo " role are working properly, delete any temporary "
echo " manually created users. Add two MFA keys to your " 
echo " root account and store them away in a safe place. "
echo " NOTE: you can now add two Yubikeys to an AWS SSO "
echo " User but I haven't checked if you can do that for "
echo " a root account. Also read the blog post on why "
echo " I use virtual MFA for AWS CLI profiles."
echo " Ctrl-C to exit. Enter to proceed."
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
read ok

cd stacks/User
./deploy.sh
cd ../..

cd stacks/Group
./deploy.sh
cd ../..

cd stacks/Role
./deploy.sh
cd ../..

echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo " Set up MFA for al users before proceeding:"
echo " "
echo " Create these AWS CLI proiles beore proceeding:"
echo " IAM, KMS, AppDeploy, AppSec, Network, deploycreds"
echo ""
echo " Ctrl-C to exit. Enter to proceed."
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
read ok


#################################################################################
# Copyright Notice
# All Rights Reserved.
# All materials (the “Materials”) in this repository are protected by copyright 
# undeir U.S. Copyright laws and are the property of 2nd Sight Lab. They are provided 
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
                                                                                    
