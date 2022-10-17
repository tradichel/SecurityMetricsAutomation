#!/bin/bash -e
# https://github.com/tradichel/SecurityMetricsAutomation
# IAM/test.sh
# author: @tradichel @2ndsightlab
#############################################################

echo "Have you already created the IAM Admin user, group and role? (y for yes, anything else to exit.)"
read ok
if [ "$ok" != "y" ]; then
	echo "Run the test.sh script in the root directory and enter Y when asked if you want to create the IAM Admin."
	exit
fi

cd ..
cd stacks/User
./deploy.sh
cd ../../test

cd ..
cd  stacks/Group
./deploy.sh
cd ../../test

cd ..
cd stacks/Role
./deploy.sh
cd ../../test

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
                                                                                    
