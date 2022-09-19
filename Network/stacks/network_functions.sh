#!/bin/bash -e
# https://github.com/tradichel/SecurityMetricsAutomation
# Network/stacks/network_functions.sh
# author: @teriradichel @2ndsightlab
# description: shared network functions
##############################################################


source "../../Functions/shared_functions.sh"
servicename="Network"

deploy_vpc (){

  prefix="$1"
	cidr="$2"
	vpctype="$3"
  profile="$4"

  function=${FUNCNAME[0]}
  validate_param "prefix" $prefix $function
  validate_param "cidr" $cidr $function
  validate_param "vpctype" $vpctype $function
  validate_param "profile" $profile $function

  vpcname=$prefix$vpctype'VPC'

	resourcetype='VPC'
  template='cfn/VPC.yaml'
  p=$(add_parameter "NameParam" $vpcname)
 	p=$(add_parameter "CIDRParam" $cidr $p)
  p=$(add_parameter "VPCTypeParam" $vpctype $p)
	
  deploy_stack $profile $servicename $vpcname $resourcetype $template "$p"

	fix_vpc_route_table $vpcname

}

fix_vpc_route_table(){

	vpcname="$1"

	newrtname=$vpcname'RouteTable'

  function=${FUNCNAME[0]}
  validate_param "vpcname" $vpcname $function

	vpcid=$(aws ec2 describe-vpcs \
					--filter Name=tag:Name,Values=$vpcname \
					--query Vpcs[*].VpcId --output text)

	mainrtid=$(aws ec2 describe-route-tables \
						--filters Name=vpc-id,Values=$vpcid Name=association.main,Values=true \
						--query RouteTables[].RouteTableId --output text)

  newrtid=$(aws ec2 describe-route-tables \
					--filters Name=vpc-id,Values=$vpcid Name=tag:Name,Values=$newrtname \
					--query RouteTables[].RouteTableId --output text) 

  if [ "$mainrtid" != "$newrtid" ]; then		
		associd=$(aws ec2 describe-route-tables \
					--filters Name=vpc-id,Values=$vpcid Name=association.main,Values=true \
					--query RouteTables[0].Associations[0].RouteTableAssociationId --output text)
		aws ec2 replace-route-table-association --association-id $associd --route-table-id $newrtid
		aws ec2 delete-route-table --route-table-id $mainrtid
	fi

}


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




