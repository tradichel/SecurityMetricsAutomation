#!/bin/bash -e
# https://github.com/tradichel/SecurityMetricsAutomation
# awsdeploy/resources/ec2/securitygroup/securitygroup_functions.sh
# author: @teriradichel @2ndsightlab
# description: deploy a security group
##############################################################

source deploy/shared/functions.sh
source deploy/shared/validate.sh
#circular dependency
#source resources/ec2/vpc/vpc_functions.sh
source resources/ec2/prefixlist/prefixlist_functions.sh

category="ec2"

clean_up_default_sg(){

  vpcname="$1"

	echo "Clean up default security group"

  vpcid=$(get_vpc_id_by_name $vpcname)

  sgid=$(aws ec2 describe-security-groups \
        --filter Name=group-name,Values=default Name=vpc-id,Values=$vpcid \
        --query SecurityGroups[*].GroupId --output text --profile $profile)

  sgname=$vpcname'defaultsecuritygroup'

  aws ec2 create-tags \
    --resources $sgid \
    --tags 'Key="Name",Value="'$sgname'"' \
		--profile $profile

  name=$sgname'securitygrouprules'
  template='resources/ec2/securitygroup/rules/noaccess.yaml'
	
  p=$(add_parameter "SecurityGroupIdParam" $sgid)
  resourcetype='securitygrouprules'
  deploy_stack $name $category $resourcetype $p $template

}

#this needs to pull from parameter store
#or something - don't use this until revisit
deploy_remote_access_sgs_for_group() {

	group="$1"
	vpc="$2"
	#need to get allowcidr and pass in as parameter to job
  allowcidr="$3"

	echo " --------------Deploy remote access security groups for $group --------------"
  f=${FUNCNAME[0]}
  validate_var $f "group" "$group"
  validate_var $f "vpc" "$vpc" 

	members=$(get_users_in_group $group $profile)

	echo 'Members: '$members
	for user in ${members//,/ }
	do
		echo 'user: '$user
	
		#extract the username from the ARN
		user=$(echo $user | sed 's:.*/::')

    echo 'user: '$user

		prefix="ssh$user"
		desc="SSHRemoteAccess-CantPassSpacesToCLIFixLater"
		template="cfn/sgrules/ssh.yaml"
		deploy_security_group $vpc $prefix $desc $template $allowcidr

		prefix="rdp$user"
		desc="RDPRemoteAccess-CantPassSpacesToCLIFixLater"
		template="cfn/sgrules/rdp.yaml"
		deploy_security_group $vpc $prefix $desc $template $allowcidr

  done

}

deploy_securitygroup() {

	vpcid="$1"
	sgname="$2"
	desc="$3"
	
  f=${FUNCNAME[0]}
  validate_var $f "vpcid" "$vpcid" 
  validate_var $f "sgname" "$sgname" 
  validate_var $f "desc" "$desc"
  
	category="ec2"
	resourcetype="securitygroup"
	p=$(add_parameter "NameParam" $sgname)
	p=$(add_parameter "VPCIdParam" $vpcid $p)
	p=$(add_parameter "GroupDescriptionParam" "$desc" $p)
	
	deploy_stack $sgname $category $resourcetype $p

}

get_securitygroup_id(){
	groupname="$1"

	query='SecurityGroups[?GroupName==`'$groupname'`].[GroupId]'
	sgid=$(aws ec2 describe-security-groups \
 		--query $query \
		--output text \
		--profile $profile)

	echo $sgid 

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
