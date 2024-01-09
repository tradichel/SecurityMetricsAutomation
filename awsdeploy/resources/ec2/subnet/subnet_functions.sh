#!/bin/bash -e
# https://github.com/tradichel/SecurityMetricsAutomation
# resources/ec2/subnet/subnet_functions.sh
# author: @teriradichel @2ndsightlab
# description: deploy a VPC
##############################################################

source deploy/shared/functions.sh
source deploy/shared/validate.sh
source resources/ec2/vpc/vpc_functions.sh

#The index is the value at the end of the zone id, 
#not the index of an array of zones as would be
#used in a select in CloudFormazion which would
#start at 0; CloudFormation 
get_availability_zone_name () {
	index="$1"

	query='AvailabilityZones[?ends_with(ZoneId,`az'$index'`)].ZoneName'
	azname=$(aws ec2 describe-availability-zones \
	--query $query \
	--profile $profile \
	--output text)
	echo $azname
}

get_next_available_az_index () {
  index="$1" #if this index is available it will be returned
	
	state="unavailable"

	while [ "$state" != "" ]; do

		query='AvailabilityZones[?ends_with(ZoneId,`az'$index'`)].State'
		state=$(aws ec2 describe-availability-zones \
 	 	--query $query \
		--profile $profile \
 	 	--output text)
		if [ "$state" == "available" ]; then echo $index; break; fi
		index=$((index+1))

	done
}

#Call deploy_subnets to deploy
#multiple subnets which then calls 
#this function
deploy_subnet(){
	subnetname="$1"
  vpcid="$2"
	vpccidr="$3"
  zoneindex="$4"   #AZ index - number at the end of the AZ ID
	cidrindex="$5" 	 #used with !Cidr in subnet.yaml to calculate subnet cidrs
	cidrbits="$6" 	 #/24 /16 etc. - used with !Cidr in subnet.yaml
	subnetcount="$7" #used with !Cidr in subnet.yaml
 
  f=${FUNCNAME[0]}
  validate_var $f "subnetname" $subnetname
  validate_var $f "vpcid" "$vpcid"
	validate_var $f "vpccidr" "$vpccidr"
  validate_var $f "zoneindex" "$zoneindex"
  validate_var $f "cidrindex" "$cidrindex"
  validate_var $f "cidrbits" "$cidrbits"
  validate_var $f "subnetcount" "$subnetcount"
  
	#The number at the end of the AZ ID you want to use
  az=$(get_availability_zone_name $zoneindex)
	validate_var $f "get az from $zoneindex" $az

	category='ec2'
  resourcetype='subnet'
	p=$(add_parameter "NameParam" $subnetname)
  p=$(add_parameter "VPCIdParam" $vpcid $p)
  p=$(add_parameter "AZParam" $az $p)
  p=$(add_parameter "VPCCidrParam" $vpccidr $p)
  p=$(add_parameter "CidrIndexParam" $cidrindex $p)
  p=$(add_parameter "CidrBitsParam" $cidrbits $p)  
  p=$(add_parameter "SubnetCountParam" $subnetcount $p)

	deploy_stack $subnetname $category $resourcetype $p

}

#Cidr bits from aws documentation:
#Subnet bits is the inverse of subnet mask. 
#To calculate the required host bits for a given subnet bits, 
#subtract the subnet bits from 32 for IPv4 or 128 for IPv6.
deploy_subnets(){
  vpcname="$1"
  subnetcount="$2" #how many subnets
  cidrbits="$3" #optional: defaults to /27 or 32-27=5 bits
 
	if [ "$cidrbits" == "" ]; then cidrbits=5; fi
	
	#variables are validated in deploy_subnet
		
	vpcid=$(get_vpc_id $vpcname)
  f=${FUNCNAME[0]}
  validate_var $f "vpcid" $vpcid
	echo "VPCID: $vpcid"

  vpccidr=$(get_vpc_cidr $vpcname)
  validate_var $f "get vpccidr from vpcid $vpcid" $vpccidr
	echo "VPC Cidr: $vpccidr"

	sname="subnet"
  
	#- availability zone indexes start at 1 because it is the 
	#- number at the end of the Zone ID when you list out the 
	#- azs in a region. The function below looks for the next
	#- *avaiable* index and uses that on each iteration
	#- of the loop
	#
	#- subnet index appended to subnet name starts with 1
	#
	#- the cidr index calucated by !CIDR in the template starts with 0
	#- because the select is referencing the index in the array of CIDRs it
	#- generated based on the parameters you pass to it
	
	azindex=1

	for (( i=1; i<=$subnetcount; ++i )); do  
  
   subnetname=$vpcname$sname$i
	 cidrindex=$(($i - 1))
	 
	 #there is a chance that the zone becomes unavailable by the time the next
	 #function uses the index, but that is a bit out of our control.
	 #I could write some complicated logic to try another zone but not right now.
	 azindex=$(get_next_available_az_index $azindex)
	 echo "Next available subnet: $azindex"
	 if [ "$azindex" != "" ]; then 
	 	 deploy_subnet $subnetname $vpcid $vpccidr $azindex $cidrindex $cidrbits $subnetcount 
	 fi
	done

}

get_subnet_id(){
	subnetname="$1"
	query='Subnets[].SubnetId'
	subnetid=$(aws ec2 describe-subnets \
	 --query $query \
	 --filter Name=tag:Name,Values=$subnetname \
	 --profile $profile \
	 --output text)
	echo $subnetid
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
