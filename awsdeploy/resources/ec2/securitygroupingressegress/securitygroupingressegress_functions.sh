#!/bin/bash -e
# https://github.com/tradichel/SecurityMetricsAutomation
# awsdeploy/resources/ec2/securitygroupingressegress/securitygroupingressegress_functions.sh
# author: @teriradichel @2ndsightlab
# description: deploy security group rules
##############################################################

source deploy/shared/functions.sh
source deploy/shared/validate.sh
source resources/ec2/prefixlist/prefixlist_functions.sh
source resources/ec2/securitygroup/securitygroup_functions.sh

#this function assumes you need
#to allow one cidr for SSH access
deploy_rules_with_cidr() {
	sgname="$1"
	rulesname="$2"
	cidr="$3"
	
  f=${FUNCNAME[0]}
  validate_var $f "sgname" "$sgname"
  validate_var $f "rulesname" "$rulesname"	
	validate_var $f "cidr" "$cidr"
  
	sgid=$(get_securitygroup_id $sgname)

  p=$(add_parameter "SecurityGroupIdParam" $sgid)
  p=$(add_parameter "AllowCidrParam" $cidr $p)

  deploy_securitygroupingressegress $rulesname $p
}

deploy_rules_with_destinationprefixlist() {
  sgname="$1"
  rulesname="$2"
  prefixlistid="$3"
  
  f=${FUNCNAME[0]}
  validate_var $f "sgname" "$sgname"
  validate_var $f "rulesname" "$rulesname"
  validate_var $f "prefixlistid" "$prefixlistid"
  
  sgid=$(get_securitygroup_id $sgname)

  p=$(add_parameter "SecurityGroupIdParam" $sgid)
  p=$(add_parameter "DestinationPrefixListIdParam" $prefixlistid $p)

  deploy_securitygroupingressegress $rulesname $template $p
}


deploy_rules_with_sourceprefixlist() {
  sgname="$1"
  rulesname="$2"
  prefixlistid="$3"
  
  f=${FUNCNAME[0]}
  validate_var $f "sgname" "$sgname"
  validate_var $f "rulesname" "$rulesname"
  validate_var $f "prefixlistid" "$prefixlistid"

  sgid=$(get_securitygroup_id $sgname)

  p=$(add_parameter "SecurityGroupIdParam" $sgid)
  p=$(add_parameter "SourcePrefixListIdParam" $prefixlistid $p)
 
  deploy_securitygroupingressegress $rulesname $template $p
}

deploy_rules_with_destinationsecuritygroup() {
  sgname="$1"
  rulesname="$2"
  destinationsgname="$3"
  
  f=${FUNCNAME[0]}
  validate_var $f "sgname" "$sgname"
  validate_var $f "rulesname" "$rulesname"
  validate_var $f "destinationsgname" "$destinationsgname"

  sgid=$(get_securitygroup_id $sgname)
	destsgid=$(get_securitygroup_id $destinationsgname)

  p=$(add_parameter "SecurityGroupIdParam" $sgid)
  p=$(add_parameter "DestinationSecurityGroupIdParam" $destinationsecuritygroupid $p)

  deploy_securitygroupingressegress $rulesname $template $p
}

deploy_rules_with_sourcesecuritygroup() {
  sgname="$1"
  rulesname="$2"
  sourcesgname="$3"
  
  f=${FUNCNAME[0]}
  validate_var $f "sgname" "$sgname"
  validate_var $f "rulesname" "$rulesname"
  validate_var $f "sourcesgname" "$sourcesgname"

  sgid=$(get_securitygroup_id $sgname)
	sourcesgid=$(get_securitygroup_id $sourcesgname)

  p=$(add_parameter "SecurityGroupIdParam" $sgid)
  p=$(add_parameter "SourceSecurityGroupIdParam" $sourcesgid $p)

  deploy_securitygroupingressegress $rulesname $template $p
}

#set the parameters in the calling function
#and pass them in
deploy_securitygroupingressegress(){
	rulesname="$1"
	parameters="$2"
  
  f=${FUNCNAME[0]}
  validate_var $f "rulesname" "$rulesname"
  validate_var $f "parameters" "$parameters"

	echo "PRARAMETERS: $parameters"

	template=$(echo $rulesname | cut -d '-' -f2)
	template=$template'.yaml'

	category="ec2"
  resourcetype="securitygroupingressegress"
  deploy_stack $rulesname $category $resourcetype $parameters $template
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
