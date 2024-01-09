#!/bin/bash -e
# https://github.com/tradichel/SecurityMetricsAutomation/
# Org/stacks/Organization/deploy.sh
# author: @teriradichel @2ndsightlab
# description: Deploy AWS Organization and settings
##############################################################

orgprefix=""

deploy_organization(){
	profile="$1"
	region="$2"
	org="$3"
	env="$4"

	#todo: validate variables
	#use common deploy function
	#create a common import function

	stackname="root-organizations-organization-$org"
	orgid=$(aws organizations describe-organization --query Organization.Id --output text --profile $profile --region $region)

	exists=$(aws cloudformation describe-stacks \
			--stack-name $stackname \
			--query 'Stacks[0].Outputs[?ExportName==`'$org'`].OutputValue' \
			--output text --profile $profile --region $region || echo "")

	if [ "$exists" = "" ] || [ "$exists" == "None" ]; then

  	import="[{\"ResourceType\":\"AWS::Organizations::Organization\",\"LogicalResourceId\":\"Organization\",\"ResourceIdentifier\":{\"Id\":\"$orgid\"}}]"
  	changesetname="import-organization-changeset"

  	aws cloudformation deploy --template-file resources/emptystack.yaml \
		--stack-name $stackname --profile $profile --region $region

  	#import changeset
  	aws cloudformation create-change-set --stack-name $stackname --change-set-name $changesetname --change-set-type IMPORT \
    	--resources-to-import $import \
			--template-body file://resources/organizations/organization/organizationimport.yaml \
			--profile $profile --region $region

  	#wait for the changeset to complete
  	aws cloudformation wait change-set-create-complete \
    	--stack-name $stackname \
    	--change-set-name $changesetname \
    	--profile $profile --region $region

  	#execute change set
  	aws cloudformation execute-change-set --change-set-name $changesetname  --stack-name $stackname  --profile $profile --region $region

  	#wait until import is complete
  	aws cloudformation wait stack-import-complete \
      --stack-name $stackname --profile $profile --region $region
	fi

	#deploy the new organization or the updated template with outputs if the organization was imported
	aws cloudformation deploy --template-file resources/organizations/organization/organization.yaml \
				--stack-name root-organizations-organization-$org \
				--parameter-overrides NameParam="$org"  \
				--profile $profile --region $region
}

get_root_id(){
	rootouid=$(aws organizations list-roots --query Roots[0].Id --output text --profile $profile)
	echo $rootouid
}

get_ou_id(){
	 ouname="$1"

   rootouid=$(get_root_id)

   ouid=$(aws organizations list-organizational-units-for-parent --parent-id $rootouid \
     --query 'OrganizationalUnits[?Name==`'$ouname'`].Id' --output text --profile $profile)

	 echo $ouid

}

enable_all_features(){

	  enabled=$(aws organizations describe-organization --query \
		       'Organization.FeatureSet' --output text --profile Org)

	    if [ "$enabled" == "ALL" ]; then
				echo "ALL features are already enabled"
  	  else
	      aws organizations enable-all-features --profile $profile
       fi
    }


enable_scps(){
	
	enabled=$(aws organizations describe-organization --query \
		 'Organization.AvailablePolicyTypes[?Type==`SERVICE_CONTROL_POLICY`].Status' --output text --profile Org)
	
	if [ "$enabled" == "ENABLED" ]; then
		echo "SCPs are already enabled."
  else
		rootouid=$(get_root_id)
 	 	aws organizations enable-policy-type --root-id $rootouid --policy-type SERVICE_CONTROL_POLICY --profile $profile
	fi

}

get_organization_id(){
	orgid=$(aws organizations describe-organization --query 'Organization.Id' --output text --profile $profile)
	echo $orgid
}

get_organization_prefix(){
	if [ "$orgprefix" == "" ]; then 
  	orgprefix=$(aws secretsmanager get-secret-value --secret-id OrgPrefix --query SecretString --output text --profile $profile) 
	fi
	echo $orgprefix
}

enable_cloudtrail(){  
	 echo "Enable cloutrail"
   aws organizations enable-aws-service-access --service-principal cloudtrail.amazonaws.com --profile $profile
}

#the default aws organizations role does not require mfa
create_org_admin_role_profile(){
	acctname="$1"
	mfa="$2"

  acctnum=$(get_account_number_by_account_name $acctname)
	rolename=$(get_org_admin_role_name $acctname $mfa)  
	profie="OrgRoot"

	create_cross_account_role_profile "$acctnum" "$rolename" "$mfa"

	echo "Created AWS CLI Role Profile $roleprofile"

}

get_org_admin_role_name(){
	acctname="$1"
  mfa="$2"

	orgprefix=$(get_organization_prefix)	
  #if the account name does not start with org prefix then add it

	if [ "$mfa" == "true" ]; then mfa="-mfa"; else mfa=""; fi 
  if [[ "$acctname" =~ ^"$orgprefix" ]]; then
		echo $acctname$mfa
	else
		echo $orgprefix'-'$acctname$mfa
	fi
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
