#!/bin/bash -e
# https://github.com/tradichel/SecurityMetricsAutomation
# Network/stacks/deploy.sh
# author: @teriradichel @2ndsightlab
# description: deploy network resources
# Note: If resources get stuck in a bad state:
# https://aws.amazon.com/premiumsupport/knowledge-center/cloudformation-update-rollback-failed/
##############################################################

source network_functions.sh

vpcprefix="RemoteAccess"
cidr="10.10.0.0/24"
vpctype="Public"

deploy_vpc $vpcprefix $cidr $vpctype

cidrbits=5
vpc=$vpcprefix$vpctype'VPC'
cidr=$vpcprefix$vpctype'VPCCIDR'
count=1
firstzone=0
nacltemplate='cfn/NACLRules/RemoteAccessInbound.yaml'

deploy_subnets $vpc $cidr $count $firstzone $cidrbits $nacltemplate

vpcprefix="BatchJobs"
cidr="10.20.0.0/24"
vpctype="Private"

deploy_vpc $vpcprefix $cidr $vpctype

cidrbits=5
vpc=$vpcprefix$vpctype'VPC'
cidr=$vpcprefix$vpctype'VPCCIDR'
count=2
firstzone=0
nacltemplate='cfn/NACLRules/HTTPOutbound.yaml'
deploy_subnets $vpc $cidr $count $firstzone $cidrbits $nacltemplate

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
                                                                                  
