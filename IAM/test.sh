#!/bin/bash -e
# https://github.com/tradichel/SecurityMetricsAutomation
# test.sh
# author: @tradichel @2ndsightlab
##############################################################
#!/bin/bash -e

echo "Running stacks with the AWS CLI Profile default"

profile="default"

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
echo " Have you set up an AWS CLI Profile named iam?"
echo " Exit and See README.md if you haven't."
echo " Ctrl-C to exit. Enter to proceed."
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
read ok

echo "Running the remaining stacks with the AWS CLI Profile iam"
profile="iam"

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
echo " Set up MFA for these users before proceeding:"
echo " KMSAdmin, NetworkAdmin, Developer, SecurityMetricsOperator"
echo ""
echo " Create these AWS CLI proiles beore proceeding:"
echo " kms, network, dev, securitymetrics"
echo ""
echo " Ctrl-C to exit. Enter to proceed."
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
read ok


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
~                                                                                     
