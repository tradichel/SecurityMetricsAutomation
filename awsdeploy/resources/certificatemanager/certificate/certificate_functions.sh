#!/bin/bash -e
# https://github.com/tradichel/SecurityMetricsAutomation/
# awsdeploy/resources/certificatemanager/certificatemanager_functions.sh
# author: @teriradichel @2ndsightlab
# description: Functions to deploy tls certificates
##############################################################
source deploy/shared/functions.sh
source deploy/shared/validate.sh
source resources/route53/hostedzone/hostedzone_functions.sh
source resources/route53/cname/cname_functions.sh

#certificates must be deployed in xx-xxxx-x to work with CloudFront
#Otherwise, certificates must be deployed in the same region where
#the resources exist that they will e used with.
#For less headaches, deploy the certs and hosted zones that support
#them in the same region.
deploy_certificate(){
  domain="$1"
	env="$2"

  func=${FUNCNAME[0]}
  validate_set $func "domain" $domain
  validate_set $func "env" $env
  validate_set $func "region" $region
  validate_set $func "profile" $profile

  dotstodashes=$(dots_to_dashes $domain)
  hostedzoneid=$(get_hostedzone_id $domain)
  validate_set $func "hostedzoneid" $hostedzoneid

  #certificate statcks hang in a CREATE_IN_PROGRESS state until
  #validation is complete or drop off after 72 hours 
  stack="$profile-certificatemanager-certificate-$env-$dotstodashes"
  status=$(get_stack_status $stack)
  if [ "$status" != "CREATE_IN_PROGRESS" ]; then

		#certificate has not yet been deployed so deploy it
  	parameters=$(add_parameter "DomainNameParam" "$domain")
		parameters=$(add_parameter "DotsToDashesParam" "$dotstodashes" $parameters)
  	parameters=$(add_parameter "HostedZoneIdParam" "$hostedzoneid" $parameters)
	
		category="certificatemanager"
		resourcetype="certificate"
  	stackname=$env'-'$dotstodashes

		#this stack will hang waiting until the required CNAME
		#gets deployed so run it in the background
		deploy_stack $stackname $category $resourcetype $parameters &

	fi

	#validation needs to wait until the required information
	#is available from the certificate stack. It then pulls out 
	#the cname information from the certificate stack and
	#deploys a cname so the certificate validation and stack
	#can complete and get out of Pending validation status. 

	stackname="$profile-certificatemanager-certificate-$env-$dotstodashes"
  echo "Certificate stackname: $stackname"
  
	name=""
	value=""
	status=""

	#wait until stack exists to proceed
	while [ "$(get_stack_status $stackname)" == "" ]; do
		sleep 5
	done

	#try 10 times to get the cname name and value
	i=0
	while [[ $i -lt 11 ]] 
	do

		sleep 5

		grepvalue="value"
  	s=$(aws cloudformation describe-stack-events --stack-name $stackname --region $region \
			--profile $profile | grep -i $grepvalue | sed 's/^.*{//g' | sed 's/}.*$//g')
    
		if [ "$s" == "" ]; then echo "Waiting for stack to deploy..."; continue; fi
	
  	echo "Get CNAME name and value from: $s"
  	stack_cname_name=$(echo $s | cut -d ':' -f2 | cut -d ',' -f1)
  	stack_cname_value=$(echo $s | cut -d ':' -f4)
		if [ "$stack_cname_name" != "" ]; then break; fi #we got the values we need
	
	done

	echo "CNAME name: $stack_cname_name"  
	echo "CNAME value: $stack_cname_value"
  if [ "$stack_cname_name" == "" ]; then echo "cname name not found in $s in stack: $stackname"; exit; fi
  if [ "$stack_cname_value" == "" ]; then echo "cname value not found in $s in stack: $stackname"; exit; fi

  #Deploy the validation record on the domain
  #If it is a subdomain this record goes on the subdomain
  #NOTE: This won't work correctly if the NS records on the 
  #Subdomain haven't been added as a NS record on the parent
  #domain for that subdomain
  deploy_cname $env $domain $stack_cname_name $stack_cname_value

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




