#!/bin/bash -e
# https://github.com/tradichel/SecurityMetricsAutomation
# Network/stacks/deploy_sandbox.sh
# author: @teriradichel @2ndsightlab
# description: deploy network resources in sanbox account
# Note: If resources get stuck in a bad state:
# https://aws.amazon.com/premiumsupport/knowledge-center/cloudformation-update-rollback-failed/
##############################################################

source network_functions.sh
source ../../Functions/shared_functions.sh

#######
# VPC with Public Route Table
######
vpcprefix="NAT"
vpc=$vpcprefix'VPC'
cidr="10.20.0.0/24"
rttype="Public"

deploy_vpc $vpcprefix $cidr $rttype

#######
# NACL - HTTPS (443) Outbound and ephemeral return
######
naclrulestemplate="cfn/NACLRules/HTTPSOnlyOutbound.yaml"
naclname="HTTPSOutboundNACL"
deploy_nacl $naclname $vpc $naclrulestemplate

#######
# Public Subnet
######
cidrbits=5
rttype="Public"
cidrindex=0
zoneindex=2
subnetcount=2
routetablename=$vpc$rttype'RouteTable'
publicsubnetname=$vpc$rttype'RouteSubnet'
deploy_subnet $publicsubnetname $vpcprefix $rttype $cidrindex $zoneindex $cidrbits $subnetcount $naclname $routetablename

#######
# EIP for NAT
######
eipname="NATEIP"
deploy_eip $eipname

#######
# NAT
######
eipexport=$eipname
natname="SandboxNAT"
deploy_nat $natname $eipexport $publicsubnetname

#######
# NAT Route Table
######
deploy_route_table $vpc "NAT" "$natname"

#######
# Private Subnet
######
cidrbits=5
rttype="NAT"
cidrindex=1
zoneindex=2
subnetcount=2
routetablename=$vpc$rttype'RouteTable'
privatesubnetname=$vpc$rttype'RouteSubnet'
deploy_subnet $privatesubnetname $vpcprefix $rttype $cidrindex $zoneindex $cidrbits $subnetcount $naclname $routetablename

#######
# CodeCommit VPC Endpoint and SGs
######
service="CodeCommit"

#code commit actions:
#https://docs.aws.amazon.com/service-authorization/latest/reference/list_awscodecommit.html
acct=$(aws sts get-caller-identity --profile SandboxAdmin --output text --profile $profile | cut -f1)
readprincipals="arn:aws:iam::$acct:user/WebAdmin"
readactions="codecommit.listrepositories"
readresources="*"
readallowdeny="Allow"
writeprincipals=$readprincipals
writeactions="codecommit.GitPull,codecommit.GitPush,codecommit.UpdateComment,codecommit.CreateCommit,codecommit.DeleteFile"
writeresources="*"
writeallowdeny="Allow"
#sgname='NATVPC'$service'VPCEndpointInterface'

deploy_vpce_generic "CodeCommitGit" "git-codecommit-fips" "$vpc" "$privatesubnetname" "$readprincipals" "$readactions" "$readresources" "$readallowdeny" "$writeprincipals" "$writeactions" "$writeresources" "$writeallowdeny" 
 
#######
# Lambda VPC Endpoint and SGs
#######

service="Lambda"

#Lambda actions:
#https://docs.aws.amazon.com/service-authorization/latest/reference/list_awslambda.html
acct=$(aws sts get-caller-identity --profile SandboxAdmin --output text --profile $profile | cut -f1)
readprincipals="arn:aws:iam::$acct:user/WebAdmin"
readactions="lambda.listfunctions"
readresources="*"
readallowdeny="Allow"
writeprincipals=$readprincipals
writeactions="lambda.Invoke*"
writeresources="*"
writeallowdeny="Allow"

deploy_vpce_generic "$service" "lambda" "$vpc" "$privatesubnetname" "$readprincipals" "$readactions" "$readresources" "$readallowdeny" "$writeprincipals" "$writeactions" "$writeresources" "$writeallowdeny"

#######
# SecretsManager VPC Endpoint and SGs
#######

service="SecretsManager"

#SecretsManager actions:
#https://docs.aws.amazon.com/service-authorization/latest/reference/list_awssecretsmanager.html
acct=$(aws sts get-caller-identity --profile SandboxAdmin --output text --profile $profile | cut -f1)
readprincipals="arn:aws:iam::$acct:role/*LambdaRole"
readactions="secretsmanager.ListSecrets"
readresources="*"
readallowdeny="Allow"
writeprincipals=""
writeactions="*"
writeresources="*"
writeallowdeny="Deny"

deploy_vpce_generic "$service" "secretsmanager" "$vpc" "$privatesubnetname" "$readprincipals" "$readactions" "$readresources" "$readallowdeny" "$writeprincipals" "$writeactions" "$writeresources" "$writeallowdeny"

#######
# GitHub Prefix List and SG
# NOTE: IF YOU GET AN ERROR HERE, RUN THE SCRIPT AGAIN.
# THE GITHUB SERVICE SEEMS TO HAVE RANDOM ISSUES.
# Also be aware rate limiting by the service, but that
# is not always the problem.
######
deploy_github_prefix_list

prefix="Github"
desc="Github-SG-Uses-Customer-Prefix-list"
template="cfn/SGRules/Github.yaml"
deploy_security_group $vpc $prefix $desc $template

echo "Deployed GitHub Security Group"

#######
# S3 SG with AWS Prefix List
######
#prefix="S3"
#desc="S3PrefixListSG"
#deploy_s3_security_group $vpc $prefix $desc

#################################################################################
# Copyright Notice
# All Rights Reserved.
# All materials (the “Materials”) in this repository are protected by copyright 
# under U.S. Copyright laws and are the property of 2nd Sight Lab. They are provided 
# pursuant to a royalty free, perpetual license the person to whom they were presented 
# by 2nd Sight Lab and are solely for the training and education by 2nd Sight Lab.
#
# The Materials may not be copied, reproduced, distributed, offered for sale, published, 
# DISPLAYed, performed, modified, used to create derivative works, transmitted to 
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
                                                                                  
