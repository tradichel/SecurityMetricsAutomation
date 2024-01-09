#!/bin/bash -e
# https://github.com/tradichel/SecurityMetricsAutomation
# Network/stacks/deploy.sh
# author: @teriradichel @2ndsightlab
# description: deploy network resources
# Note: If resources get stuck in a bad state:
# https://aws.amazon.com/premiumsupport/knowledge-center/cloudformation-update-rollback-failed/
##############################################################

source network_functions.sh

#######
# Remote Access VPC (Public)
######
vpcprefix="RemoteAccess"
cidr="10.10.0.0/24"
vpctype="Public"

deploy_vpc $vpcprefix $cidr $vpctype

#######
# Remote Access Subnets
######
cidrbits=5
vpc=$vpcprefix$vpctype'VPC'
cidr=$vpcprefix$vpctype'VPCCIDR'
count=1
firstzone=0
nacltemplate='cfn/NACLRules/Developer.yaml'

deploy_subnets $vpc $cidr $count $firstzone $cidrbits $nacltemplate

#######
# GitHub Prefix List and SG
# NOTE: IF YOU GET AN ERROR HERE, RUN THE SCRIPT AGAIN.
# THE GITHUB SERVICE SEEMS TO HAVE RANDOM ISSUES.
#	Also be aware rate limiting by the service, but that
#	is not always the problem.
######
deploy_github_prefix_list

prefix="Github"
desc="Github-SG-Uses-Customer-Prefix-list"
template="cfn/SGRules/Github.yaml"
deploy_security_group $vpc $prefix $desc $template

echo "Deployed GitHub Security Group"

#######
# CloudFormation VPC Endpoint and SGs
######
prefix="VPCEndpointInterface"
desc="SG-for-VPC-Endpoint"
template="none"
deploy_security_group $vpc $prefix $desc $template
vpce_sgname=$vpc'-'$prefix

prefix="VPCEndpointAccess"
desc="SG-to-access-VPC-Endpoint"
template="none"
deploy_security_group $vpc $prefix $desc $template
vpceaccess_sgname=$vpc'-'$prefix

template='cfn/SGRules/VPCEndpointInterface.yaml'
deploy_sg_rules $vpce_sgname $template

template='cfn/SGRules/VPCEndpointAccess.yaml'
deploy_sg_rules $vpceaccess_sgname $template

deploy_vpce "cloudformation"

#######
# S3 SG with AWS Prefix List
######
prefix="S3"
desc="S3PrefixListSG"
deploy_s3_security_group $vpc $prefix $desc

#######
# Remote Access SGs
######
deploy_remote_access_sgs_for_group "Developers" "RemoteAccessPublicVPC"

#######
# Application VPC and SGs (Privte)
######
cidrbits=5
vpc=$vpcprefix$vpctype'VPC'
cidr=$vpcprefix$vpctype'VPCCIDR'
count=2
firstzone=0
nacltemplate='cfn/NACLRules/HTTPOutbound.yaml'
deploy_subnets $vpc $cidr $count $firstzone $cidrbits $nacltemplate

vpcprefix="BatchJobs"
cidr="10.20.0.0/24"
vpctype="Private"
deploy_vpc $vpcprefix $cidr $vpctype

prefix="TriggerBatchJobLambda"
desc=$prefix
template="cfn/SGRules/NoAccess.yaml"
deploy_security_group $vpc $prefix $desc $template

prefix="GenBatchJobIdLambda"
desc=$prefix
template="cfn/SGRules/NoAccess.yaml"
deploy_security_group $vpc $prefix $desc $template


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
                                                                                  
