#!/bin/bash -e
# https://github.com/tradichel/SecurityMetricsAutomation/
# awsdeploy/organizations/policy/policy_functions.sh
# author: @teriradichel @2ndsightlab
# description: Functions for organizations policy deployment
# including service control policies
##############################################################
source deploy/shared/functions.sh
source resources/organizations/organization/organization_functions.sh
source deploy/shared/validate.sh

deploy_administrator_scps(){

	#vars
	deploy_role="root-adminrole"
	resource_cat="organizations"
	resource_type="policy"
	admin_policy_resource_name="administratorpolicy"
  lockdown_policy_resource_name="administratorlockdownpolicy"
	env="root"

	#define paths
	template_path="resources/organizations/policy"
	tmp_path='/tmp'/$template_path
	
	#make path in tmp file
	mkdir -p $tmp_path

	#file names
	admin_template=$admin_policy_resource_name'.yaml'
	lockdown_template=$lockdown_policy_resource_name'.yaml'

	#fullpaths
	admin_templatefullpath=$template_path'/'$admin_template
	admin_tmpfullpath=$tmp_path'/'$admin_template
	lockdown_templatefullpath=$template_path'/'$lockdown_template
	lockdown_tmpfullpath=$tmp_path'/'$lockdown_template

	echo "Deploy initial admin template"
  cp -r $admin_templatefullpath $admin_tmpfullpath
	value="\"*\""
	placeholder1=$lockdown_policy_resource_name'arn'
	replace_template_var $admin_tmpfullpath $placeholder1 $value
  deploy_root_scp 'root-'$admin_policy_resource_name $admin_tmpfullpath

	echo "Deploy lockdown policy."
	cp -r $lockdown_templatefullpath $lockdown_tmpfullpath
	adminarn=$(get_arn_from_stack $deploy_role $resource_cat $resource_type $admin_policy_resource_name $env)
	echo "Admin Policy ARN: $adminarn"

	placeholder2=$admin_policy_resource_name'arn'
	replace_template_var $lockdown_tmpfullpath $placeholder2 $adminarn
	deploy_root_scp 'root-'$lockdown_policy_resource_name $lockdown_tmpfullpath

  echo "Get the admin policy arn, replace in file, deploy lockdown policy."  
	cp $admin_templatefullpath $admin_tmpfullpath
  lockdownarn=$(get_arn_from_stack $deploy_role $resource_cat $resource_type $lockdown_policy_resource_name $env)
  echo "Lockdown Policy ARN: $lockdownarn"
	replace_template_var $admin_tmpfullpath $placeholder1 $lockdownarn
  deploy_root_scp 'root-'$admin_policy_resource_name $admin_tmpfullpath

}

sdeploy_root_policy(){
	deploy_root_scp $1
}

deploy_root_scp(){
  scpname="$1"
	template="$2"
	
	env=$(echo $scpname | cut -d "-" -f1)
	
	if [ "$env" != "root" ]; then	
	 	scpname="root-$scpname"
	fi
 
	root_ou_id=$(get_root_id)
  deploy_scp $scpname $root_ou_id $template
}

deploy_policy(){
	deploy_scp $1 $2
}

deploy_scp(){
  scpname="$1"
  targetids="$2"
	template="$3"

	echo "Deploy SCP: $scpname targets: $targetids template $template"

  func=${FUNCNAME[0]}
  validate_var $func 'scpname' $scpname
  validate_var $func 'targetids' $targetids

  parameters=$(add_parameter "NameParam" $scpname)
  parameters=$(add_parameter "TargetIdsParam" $targetids $parameters)

  deploy_scp_with_parameters $scpname $parameters $template
}

#should probably be a list of regions in 
#parameter store
deploy_allowedregions(){
  region1="$1"
	region2="$2"

  scpname="AllowedRegions"
  targetids=$(get_root_id)

	echo "Deploy allowed regions to root id: $targetids"

  func=${FUNCNAME[0]}
  validate_var $func 'scpname' $scpname
  validate_var $func 'targetids' $targetids
  validate_var $func 'region1' $region1
	validate_var $func 'region2' $region2

  parameters=$(add_parameter "NameParam" $scpname)
  parameters=$(add_parameter "TargetIdsParam" $targetids $parameters)
  parameters=$(add_parameter "Region1Param" $region1 $parameters)
  parameters=$(add_parameter "Region2Param" $region2 $parameters)

  deploy_scp_with_parameters $scpname $parameters

}

deploy_scp_with_parameters(){
  scpname="$1"
  parameters="$2"
	template="$3"

  func=${FUNCNAME[0]}
  validate_var $func "scpname" $scpname
  validate_var $func "parameters" $parameters 

	category="organizations"
  resourcetype="policy"
	if [ "$template" == "" ]; then
		template=$(echo $scpname | cut -d "-" -f2)
		template=$template'.yaml'
  fi
	deploy_stack $scpname $category $resourcetype $parameters $template

}



################################################################################
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
