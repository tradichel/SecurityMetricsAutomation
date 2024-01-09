#!/bin/bash -e
# https://github.com/tradichel/SecurityMetricsAutomation/
# awsdeploy/resources/organizations/organization/organization_functions.sh
# author: @teriradichel @2ndsightlab
# description: Functions used to deploy an organization
##############################################################

source deploy/shared/functions.sh
source resources/ssm/parameter/parameter_functions.sh

deploy_organization(){

	#get organization name parameter from parameter store
	org=$(get_ssm_parameter_value "org")

	func=${FUNCNAME[0]}	
	validate_var $func "org" $org
  validate_var $func "profile" $profile
  validate_var $func "region" $region

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

		#creates an empty stack so we can import resources we want in it
  	aws cloudformation deploy --template-file resources/emptystack/emptystack.yaml \
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
	#not using common deploy function here as the naming is a bit different
	aws cloudformation deploy --template-file resources/organizations/organization/organization.yaml \
				--stack-name root-organizations-organization-$org \
				--parameter-overrides NameParam="$org"  \
				--profile $profile --region $region
}

get_root_id(){
	rootouid=$(aws organizations list-roots --query Roots[0].Id --output text --profile $profile)
	echo $rootouid
}

enable_all_features(){

	  enabled=$(aws organizations describe-organization --query \
		       'Organization.FeatureSet' --output text --profile $profile)

	    if [ "$enabled" == "ALL" ]; then
				echo "ALL features are already enabled"
  	  else
	      aws organizations enable-all-features --profile $profile
       fi
    }


enable_scps(){
	
	enabled=$(aws organizations describe-organization --query \
		 'Organization.AvailablePolicyTypes[?Type==`SERVICE_CONTROL_POLICY`].Status' --output text --profile $profile)
	
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
  	orgprefix=$(get_ssm_parameter_value "org") 
	fi
  if [ "$orgprefix" == "" ]; then
    echo "Error retrieving prefix for organization. You may be in the wrong account or do not have permissions or the parameter does not exist."
		exit
	fi
	echo $orgprefix
}

get_organization_domain(){
  if [ "$domain" == "" ]; then
    domain=$(get_ssm_parameter_value "domain")
  fi
  if [ "$domain" == "" ]; then
    echo "Error retrieving domain for organization. You may be in the wrong account or do not have permissions or the parameter does not exist."
		exit
  fi
  echo $domain
}

enable_service(){

	servicename="$1.amazonaws.com"

  echo "Enable trusted access for $servicename"
  aws organizations enable-aws-service-access \
      --service-principal $servicename \
      --profile $profile
}

disable_service(){

  servicename="$1.amazonaws.com"

  echo "Disable trusted access for $servicename"
  aws organizations disable-aws-service-access \
      --service-principal $servicename \
      --profile $profile
}

register_delegated_administrator(){

  servicename="$1.amazonaws.com"
	account="$2"

  echo "Register delegated administrator $account for $servicename"
  aws organizations register-delegated-administrator \
			--account-id $account \
      --service-principal $servicename \
      --profile $profile

}

deregister_delegated_administrator(){

  servicename="$1.amazonaws.com"
  account="$2"

  echo "Deregister delegated administrator $account for  $servicename"
  aws organizations deregister-delegated-administrator \
      --account-id $account \
      --service-principal $servicename \
      --profile $profile

}

get_management_account_number(){
 aws organizations describe-organization \
	 --profile $profile \
	 --query 'Organization.MasterAccountId' \
	 --output text
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
