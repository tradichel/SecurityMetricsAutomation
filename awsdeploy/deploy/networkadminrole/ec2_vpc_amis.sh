#!/bin/bash -e
# https://github.com/tradichel/SecurityMetricsAutomation
# awsdeploy/deploy/networkadminrole/ec2_vpc_amis.sh
# author: @teriradichel @2ndsightlab
# Description: vpc in a project account
##############################################################

source resources/ec2/vpc/vpc_functions.sh
source deploy/shared/functions.sh
source deploy/shared/validate.sh

profile="$1"
region="$2"
env="$3"
#parameters="$4"

echo "*****************************"
echo "Deploy ec2 projectvpc"
echo "profile: $profile"
echo "region: $region"
echo "env: $env"
#echo "parameters: $parameters"
echo "*****************************"

d=$(basename "$PWD")
s=$(basename "$0")
s="$d/$s"
validate_set $s "profile" $profile
validate_set $s "region" $region
validate_environment $s $env
#validate_set $s "parameters" $parameters

vpcname="$env-private-amivpc"
cidr="10.10.10.0/24"
vpctype="private"

deploy_vpc $vpcname $cidr $vpctype $env

vpcname="$env-public-amivpc"
cidr="10.10.20.0/24"
vpctype="public"

deploy_vpc $vpcname $cidr $vpctype $env

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
