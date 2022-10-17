#!/bin/bash -e
# https://github.com/tradichel/SecurityMetricsAutomation
# Network/stacks/network_functions.sh
# author: @teriradichel @2ndsightlab
# description: shared network functions
##############################################################

source "../../Functions/shared_functions.sh"
profile="Network"

deploy_vpc (){

  prefix="$1"
	cidr="$2"
	vpctype="$3"

  function=${FUNCNAME[0]}
  validate_param "prefix" $prefix $function
  validate_param "cidr" $cidr $function
  validate_param "vpctype" $vpctype $function

  vpcname=$prefix$vpctype'VPC'

	resourcetype='VPC'
  template='cfn/VPC.yaml'
  p=$(add_parameter "NameParam" $vpcname)
 	p=$(add_parameter "CIDRParam" $cidr $p)
	
  deploy_stack $profile $vpcname $resourcetype $template "$p"

	#deploy route table
  resourcetype='RouteTable'
  template='cfn/RouteTable.yaml'
	rtname=$vpcname'RouteTable'
  p=$(add_parameter "NameParam" $rtname)
  p=$(add_parameter "VPCExportParam" $vpcname $p)
  p=$(add_parameter "RouteTypeParam" $vpctype $p)

  deploy_stack $profile $rtname $resourcetype $template "$p"

	fix_vpc_route_table $vpcname

	clean_up_default_sg $vpcname

}

fix_vpc_route_table(){

	vpcname="$1"

  function=${FUNCNAME[0]}
  validate_param "vpcname" $vpcname $function

	newrtname=$vpcname'RouteTable'

	# get the vpc output id from this stack:
  # Network-VPC-$vpcname

	stack='Network-VPC-'$vpcname
	exportname=$vpcname
	vpcid=$(get_stack_export $stack $exportname)

  stack='Network-RouteTable-'$vpcname'RouteTable'
  exportname=$vpcname'RouteTable'
  newrtid=$(get_stack_export $stack $exportname)

	mainrtid=$(aws ec2 describe-route-tables \
						--filters Name=vpc-id,Values=$vpcid Name=association.main,Values=true \
						--query RouteTables[0].RouteTableId --output text)

  if [ "$mainrtid" != "$newrtid" ]; then		
  	echo "Updating VPC: $vpcid main route table $mainrtid to new route table: $newrtid"
		associd=$(aws ec2 describe-route-tables \
					--filters Name=vpc-id,Values=$vpcid Name=association.main,Values=true \
					--query RouteTables[0].Associations[0].RouteTableAssociationId --output text)
		aws ec2 replace-route-table-association --association-id $associd --route-table-id $newrtid
		aws ec2 delete-route-table --route-table-id $mainrtid
	fi

}

get_vpc_id_by_name() {

  vpcname="$1"

 	vpcid=$(aws ec2 describe-vpcs \
          --filter Name=tag:Name,Values=$vpcname \
          --query Vpcs[*].VpcId --output text)
	echo $vpcid

}

clean_up_default_sg(){

  vpcname="$1"

  vpcid=$(get_vpc_id_by_name $vpcname)

  sgid=$(aws ec2 describe-security-groups \
        --filter Name=group-name,Values=default Name=vpc-id,Values=$vpcid \
        --query SecurityGroups[*].GroupId --output text)

  sgname=$vpcname'-Default'

  aws ec2 create-tags \
    --resources $sgid \
    --tags 'Key="Name",Value="'$sgname'"'

  name=$sgname'-Rules'
  template='cfn/SGRules/NoAccess.yaml'
	exportparam=$vpcname'DefaultSecurityGroup'
  p=$(add_parameter "SGExportParam" $exportparam)
  resourcetype='SGRules'
  deploy_stack $profile $name $resourcetype $template "$p"

}

deploy_security_group() {

	vpc="$1"
	prefix="$2"
	desc="$3"
	rulestemplate="$4"
	cidr="$5"
	
	template="cfn/SecurityGroup.yaml"
	resourcetype="SecurityGroup"	
	sgname=$vpc'-'$prefix
	p=$(add_parameter "NameParam" $sgname)
	p=$(add_parameter "VPCExportParam" $vpc $p)
	p=$(add_parameter "GroupDescriptionParam" "$desc" $p)
	
	deploy_stack $profile $sgname $resourcetype $template "$p"

	name=$sgname'-Rules'
	template=$rulestemplate
  p=$(add_parameter "NameParam" $name)
  p=$(add_parameter "SGExportParam" $sgname $p)
	#cidr for remote access to AWS only at this time
  if [ "$cidr" != "" ]; then p=$(add_parameter "AllowCidrParam" "$cidr" $p); fi
	resourcetype='SGRules'
	deploy_stack $profile $name $resourcetype $template "$p"
	
}

deploy_subnets(){

  vpc="$1"
	vpccidr="$2"
	subnetcount=$3
	firstzoneindex=$4
	cidrbits=$5
	naclrulestemplate=$6

  function=${FUNCNAME[0]}
  validate_param "vpc" $vpc $function
	validate_param "vpccidr" $vpccidr $function
  validate_param "subnetcount" $subnetcount $function
  validate_param "firstzoneindex" $firstzoneindex $function
  validate_param "cidrbits" $cidrbits $function
  validate_param "naclrulestemplate" $naclrulestemplate $function

  #assuming all the subnets use the same NACL here
	template="cfn/NACL.yaml"
	naclname=$vpc'-NACL'
	resourcetype='NACL'
	p=$(add_parameter "NameParam" $naclname)
	p=$(add_parameter "VPCExportParam" $vpc $p)
	deploy_stack $profile $naclname $resourcetype "$template" "$p"
  
	#add nacl rules
	resourcetype="NetworkACLEntry"
	name=$naclname'Entries'
 	p=$(add_parameter "NACLExportParam" $naclname)
  deploy_stack $profile $name $resourcetype $naclrulestemplate "$p"

	i=0
 
  while (( $i < $subnetcount ));
  do
	
	 index=$i	
	 #why not to use bash on the next line
   i=$((($i+1)))
   subnetname=$vpc'-Subnet'$i
	
   resourcetype='Subnet'
   template='cfn/Subnet.yaml'  
	 p=$(add_parameter "NameParam" $subnetname)
   p=$(add_parameter "VPCExportParam" $vpc $p)
   p=$(add_parameter "ZoneIndexParam" $index $p)
   p=$(add_parameter "VPCCidrExportParam" $vpccidr $p)
   p=$(add_parameter "SubnetCountParam" $i $p)
   p=$(add_parameter "CidrBitsParam" $cidrbits $p)
   p=$(add_parameter "SubnetIndexParam" $index $p)   
 
	 deploy_stack $profile $subnetname $resourcetype $template "$p"

	template=cfn/SubnetAssociation.yaml
	resourcetype='SubnetAssociation'

  timestamp="$(date)"
  t=$(echo $timestamp | sed 's/ //g')
  p=$(add_parameter "SubnetIdExportParam" $subnetname)
  p=$(add_parameter "NACLIdExportParam" $naclname $p) 
	p=$(add_parameter "TimestampParam" $t $p)
	deploy_stack $profile $subnetname$naclname $resourcetype $template "$p"

	done

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
