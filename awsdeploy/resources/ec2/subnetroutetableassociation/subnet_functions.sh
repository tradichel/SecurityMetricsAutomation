#!/bin/bash -e
# https://github.com/tradichel/SecurityMetricsAutomation
# resources/ec2/subnet/subnet_functions.sh
# author: @teriradichel @2ndsightlab
# description: deploy a VPC
##############################################################

source deploy/shared/functions.sh
source deploy/shared/validate.sh
source resources/ec2/vpc/vpc_functions.sh

get_availability_zone () {
	index="$1"

	azid=$(aws ec2 describe-availability-zones --profile $profile \
			| grep "az$index" -B1 | grep -v "az$index" \
			| cut -d ":" -f2 | sed 's/ //g' | sed 's/"//g' | sed 's/,//g')

	echo $azid

}

deploy_subnet(){

	subnetname="$1"
  vpcname="$2"
	rttype="$3"
	cidrindex=$4 #one less than subnet index
	zoneindex=$5
	cidrbits=$6
	subnetcount=$7
  naclname="$8"
  routetablename="$9"
	
	vpccidr=$vpcprefix'vpccidr'

  f=${FUNCNAME[0]}
  validate_var $f "subnetname" $subnetname
  validate_var $f "vpc" "$vpc"
	validate_var $f "rttype" "$rttype"
  validate_var $f "cidrindex" "$cidrindex"
  validate_var $f "zoneindex" "$zoneindex"
  validate_var $f "cidrbits" "$cidrbits"
  validate_var $f "subnetcount" "$subnetcount"
	validate_var $f "naclname" "$naclname"
 	validate_var $f "routetablename" "$routetablename"

  az=$(get_availability_zone $zoneindex)

	category='ec2'
  resourcetype='subnet'
	p=$(add_parameter "NameParam" $subnetname)
  p=$(add_parameter "VPCExportParam" $vpc $p)
  p=$(add_parameter "AZParam" $az $p)
  p=$(add_parameter "VPCCidrExportParam" $vpccidr $p)
  p=$(add_parameter "CidrIndexParam" $cidrindex $p)
  p=$(add_parameter "CidrBitsParam" $cidrbits $p)  
  p=$(add_parameter "SubnetCountParam" $subnetcount $p)
	deploy_stack $subnetname $category $resourcetype $p

}

#move the associations to the other folders
	resourcetype='subnetnaclassociation'
  timestamp="$(date)"
  t=$(echo $timestamp | sed 's/ //g')
  p=$(add_parameter "SubnetIdExportParam" $subnetname)
  p=$(add_parameter "NACLIdExportParam" $naclname $p) 
	p=$(add_parameter "TimestampParam" $t $p)
	deploy_stack $subnetname'nacl' $category $resourcetype $p

  resourcetype='subnetroutetableassociation'
  timestamp="$(date)"
  t=$(echo $timestamp | sed 's/ //g')
  p=$(add_parameter "SubnetIdExportParam" $subnetname)
  p=$(add_parameter "RouteTableIdExportParam" $routetablename $p)
  p=$(add_parameter "TimestampParam" $t $p)
  deploy_stack $subnetname'routetableassociation' $category $resourcetype $p

deploy_subnets(){
  vpc="$1"
  vpccidr="$2" #use same cidr as VPC - could look this up ...
  subnetcount=$3 #how many subnets
  firstzoneindex=$4 #if zone a is failing can start at 2 for zone b, e.g.
  cidrbits=$5 #bits like /24 or /16 etc.
  naclrulestemplate=$6 #naclid - deploy nacl separately
	routetablename=$7

	sname="Subnet"

  i=0

  while (( $i < $subnetcount ));
  do

   #why not to use bash on the next line
   i=$((($i+1)))
   subnetname=$vpc$sname$i

	 deploy_subnet $vpc $subnetname $vpccidr $i $fistzoneindex $cidrbits $naclid $routetablename

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
