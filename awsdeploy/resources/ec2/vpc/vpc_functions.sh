#!/bin/bash -e
# https://github.com/tradichel/SecurityMetricsAutomation
# resources/ec2/vpc/vpc_functions.sh
# author: @teriradichel @2ndsightlab
# description: deploy a VPC
##############################################################
source deploy/shared/functions.sh
source deploy/shared/validate.sh
source resources/ec2/routetable/routetable_functions.sh
source resources/ec2/securitygroup/securitygroup_functions.sh

thisscript=$(echo $(basename "$PWD")/$(basename "$0"))
 
#run the script in the deploy/iamadmin folder
#to deploy the vpc-flow-logs role before
#calling this function.
#The script to create the role only needs
#to be called once for multiple vpcs,
#unless you want different roles for each
#VPC to distinguish those actions in the logs.
deploy_vpc(){
  vpcname="$1"
  cidr="$2"
  rttype="$3"

  f=$thisscript-${FUNCNAME[0]}
  validate_var $f "prefix" $vpcname
  validate_var $f "cidr" $cidr
  validate_var $f "rttype" $rttype
  
  category="ec2"
  resourcetype="vpc"

  p=$(add_parameter "NameParam" $vpcname)
  p=$(add_parameter "CIDRParam" $cidr $p)
  
  deploy_stack $vpcname $category $resourcetype $p
  
	import_vpc_default_routetable $vpcname $rttype

	import_vpc_default_securitygroup $vpcname "default"

}

get_default_security_group_id(){
 vpcid="$1"

 query='SecurityGroups[?GroupName==`default`].GroupId'
 defaultsg=$(aws ec2 describe-security-groups \
  --query $query \
	--filters "Name=vpc-id,Values=$vpcid" \
  --profile $profile \
  --output text)
 echo $defaultsg

}

get_main_route_table_id(){
 vpcid="$1"

 query='RouteTables[?Associations[].Main].RouteTableId'
 mainrt=$(aws ec2 describe-route-tables \
  --query $query \
  --filters "Name=vpc-id,Values=$vpcid" \
  --profile $profile \
  --output text)
 echo $mainrt

}

import_vpc_default_routetable(){
  vpcname="$1"
	env="$2"
	rttype="$3"
	
	category="EC2"
	resourcetype="RouteTable"
	routetablename=$vpcname'routetable'
	vpcid=$(get_vpc_id $vpcname)
	routetableid=$(get_main_route_table_id $vpcid)
 	resourceidname="RouteTableId"
	importtemplate="resources/ec2/routetable/routetableimport.yaml"
  finaltemplate="resources/ec2/routetable/routetable.yaml"

  f=$thisscript-${FUNCNAME[0]}
  validate_set $f "vpcid" $vpcid
  validate_var $f "routetableid" $routetableid
	
	#create the template file in tmp dir
	#and override vpicd placeholder
	tmp="/tmp/routetableimport.yaml"
	cp $importtemplate $tmp
	replace_placeholder "{{vpcid}}" $vpcid $tmp
  importtemplate=$tmp
	cat $importtemplate

  p=$(add_parameter "NameParam" $routetablename)
  p=$(add_parameter "VpcIdParam" $vpcid $p)
  p=$(add_parameter "RouteTypeParam" $rttype $p)

  import_resource_to_stack \
    $routetablename \
    $category \
   	$resourcetype \
		$routetableid \
		$resourceidname \
    $importtemplate \
    $finaltemplate \
		$p
}

import_vpc_default_securitygroup(){
  vpcname="$1"
	name="$2"

  securitygroupname=$vpcname'securitygroup'
  category="EC2"
  resourcetype="SecurityGroup"
  vpcid=$(get_vpc_id $vpcname)
  sgid=$(get_default_security_group_id $vpcid)
  importtemplate="resources/ec2/securitygroup/securitygroupimport.yaml"
	
  f=$thisscript-${FUNCNAME[0]}
  validate_set $f "vpcid" $vpcid
  validate_var $f "routetableid" $routetableid

  tmp="/tmp/securitygroupimport.yaml"
  cp $importtemplate $tmp
  replace_placeholder "{{vpcid}}" $vpcid $tmp
	replace_placeholder "{{name}}" $name $tmp
  importtemplate=$tmp
  cat $importtemplate

  import_resource_to_stack \
    $routetablename \
    $category \
    $resourcetype \
    $routetableid \
    $resourceidname \
    $importtemplate 
}

#import a resource into a stack
import_resource_to_stack(){
	resourcename="$1"
  category="$2"
	resourcetype="$3"
	resourceid="$4"
	resourceidname="$5"
	importtemplate="$6"
 	finaltemplate="$7"
	parameters="$8"

  stackname="$profile-$category-$resourcetype-$resourcename"
	stackname=$(truncate $stackname 128)
	stackname=$(tolower $stackname)
	changesetname="import-$stackname"
	changesetname=$(truncate $stackname 128)

  f=$thisscript-${FUNCNAME[0]}
  validate_var $f "resourcename" $resourcename
  validate_var $f "category" $category
  validate_var $f "resourcetype" $resourcetype
  validate_var $f "resourceid" $resourceid
  validate_var $f "importtemplate" $importtemplate

  import="[{\"ResourceType\":\"AWS::$category::$resourcetype\",\"LogicalResourceId\":\"$resourcetype\",\"ResourceIdentifier\":{\"$resourceidname\":\"$resourceid\"}}]"

  echo "Importing:"
  echo "Name: $resourcename"
	echo "Category: $categoryname"
	echo "Resource Type: $resourcetype"
  echo "Stackname: $stackname"
	echo "Changeset name: $changesetname"
  echo "Resource Id: $resourceid"
  echo "Import template: $importtemplate"
  echo "Final temlpate: $finaltemplate"
	echo "Import: $import"

 	#deploy empty stack so we can import the reosurces into it
 	aws cloudformation deploy \
		--template-file "resources/emptystack/emptystack.yaml" \
		--stack-name $stackname \
		--profile $profile

 	#create a change set
 	aws cloudformation create-change-set \
			--stack-name $stackname \
			--change-set-name $changesetname \
			--change-set-type IMPORT \
  		--resources-to-import $import \
      --profile $profile \
			--template-body "file://$importtemplate"
	
	#wait for the changeset creation to complete
	aws cloudformation wait change-set-create-complete \
  	--stack-name $stackname \
  	--change-set-name $changesetname \
		--profile $profile

	#execute change set
	aws cloudformation execute-change-set \
		--change-set-name $changesetname \
		--stack-name $stackname \
 		--profile $profile

 	#wait until import is complete
 	aws cloudformation wait stack-import-complete \
     --stack-name $stackname \
  	 --profile $profile

	if [ "$finaltemplate" != "" ]; then
		category=$(tolower $cat)
		resourcetype=$(tolower $resourcetype)
 		deploy_stack $resourcename $category $resourcetype $parameters $finaltemplate
	fi

}

get_vpc_id() {
  vpcname="$1"

 	vpcid=$(aws ec2 describe-vpcs \
          --filter Name=tag:Name,Values=$vpcname \
          --query Vpcs[*].VpcId --output text --profile $profile)
	echo $vpcid
}

#note: gets the first CIDR for a VPC
get_vpc_cidr(){
	vpcname="$1"

	vpccidr=$(aws ec2 --output text \
	--query 'Vpcs[*].{CidrBlock:CidrBlock}' \
	describe-vpcs \
	--filter Name=tag:Name,Values=$vpcname \
	--profile $profile)

	echo $vpccidr
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
