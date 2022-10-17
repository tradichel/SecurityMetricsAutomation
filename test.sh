#!/bin/sh -e
# https://github.com/tradichel/SecurityMetricsAutomation
# test.sh
# author: @teriradichel @2ndsightlab
##############################################################
#Before you run this code you need to set up AWS CLI profiles for the following:

#test all the things

echo "Create IAM Admins? (Enter y to test, anything else to continue, CTRL-C to exit)"
read ok
if [ "$ok" == "y" ]; then
  cd IAM/test
  ./test_iam_admin.sh
  cd ../..
	exit
fi

echo "Test IAM? (Enter y to test, anything else to continue, CTRL-C to exit)"
read ok
if [ "$ok" == "y" ]; then
	cd IAM/test
	./test.sh
	cd ../..
fi


echo "Test Network?  (Enter y to test, anything else to continue, CTRL-C to exit)"
read ok
if [ "$ok" == "y" ]; then
	cd Network
	./test.sh
	cd ..
fi

echo "Test KMS?  (Enter y to test, anything else to continue, CTRL-C to exit)"
read ok
if [ "$ok" == "y" ]; then
	cd KMS
	./test.sh
	cd ..
fi

echo "Test AppSec?  (Enter y to test, anything else to continue, CTRL-C to exit)"
read ok
if [ "$ok" == "y" ]; then
	cd AppSec
	./test.sh
	cd ..
fi

echo "Test KMS IAM Role Policies?  (Enter y to test, anything else to continue, CTRL-C to exit)"
read ok
if [ "$ok" == "y" ]; then

  cd IAM/test
  ./test_kms_policies.sh
  cd ../..
fi

echo "Test Jobs?  (Enter y to test, anything else to continue, CTRL-C to exit)"
read ok
if [ "$ok" == "y" ]; then
	cd Jobs
	./test.sh
	cd ..
fi

echo "Test Lambda?  (Enter y to test, anything else to continue, CTRL-C to exit)"
read ok
if [ "$ok" == "y" ]; then
	cd Lambda
	./test.sh
	cd ..
fi

echo "Test SSH key deployment?  (Enter y to test, anything else to continue, CTRL-C to exit)"
read ok
if [ "$ok" == "y" ]; then
	cd IAM/test
	./test_ssh.sh
	cd ../..
fi

echo "Test VMs?  (Enter y to test, anything else to continue, CTRL-C to exit)"
read ok
if [ "$ok" == "y" ]; then
	cd VMs
	./test.sh
	cd ..
fi

echo "Test Complete"


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
