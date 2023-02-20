#!/bin/bash -e
# https://github.com/tradichel/SecurityMetricsAutomation/
# Org/stacks/Organization/deploy.sh
# author: @teriradichel @2ndsightlab
# description: Deploy AWS Organization and settings
##############################################################

deploy_organization(){

	id=$(get_organization_id)
	if [ "$id" == "" ]; then
		aws organizations create-organization
	else
		echo "Organization already exists: $id"
	fi
}

get_root_id(){
	rootouid=$(aws organizations list-roots --query Roots[0].Id --output text)
	echo $rootouid
}

get_ou_id(){
	 ouname=$1

   rootouid=$(get_root_id)

   ouid=$(aws organizations list-organizational-units-for-parent --parent-id $rootouid \
     --query 'OrganizationalUnits[?Name==`'$ouname'`].Id' --output text)

	 echo $ouid

}

enable_scps(){
	
	enabled=$(aws organizations describe-organization --query \
		 'Organization.AvailablePolicyTypes[?Type==`SERVICE_CONTROL_POLICY`].Status' --output text)
	
	if [ "$enabled" == "ENABLED" ]; then
		echo "SCPs are already enabled."
  else
		rootouid=$(get_root_id)
 	 	aws organizations enable-policy-type --root-id $rootouid --policy-type SERVICE_CONTROL_POLICY
	fi

}

get_organization_id(){
	orgid=$(aws organizations describe-organization --query 'Organization.Id' --output text)
	echo $orgid
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
