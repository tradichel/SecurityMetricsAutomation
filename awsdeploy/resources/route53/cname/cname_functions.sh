#!/bin/bash -e
# https://github.com/tradichel/SecurityMetricsAutomation
# awsdeploy/resources/route53/cname/cname_functions.sh
# author: @teriradichel @2ndsightlab
##############################################################
source deploy/shared/functions.sh
source deploy/shared/validate.sh
source resources/route53/hostedzone/hostedzone_functions.sh

deploy_cname() {
  env="$1"
	domain="$2"
  cname="$3"
  cnamevalue="$4"
	ttl="$5"

	if [ "$ttl" == "" ]; then ttl="300"; fi

  function=${FUNCNAME[0]}
  validate_set $function "domain" $domain
  validate_set $function "cname" $cname 
  validate_set $function "cnamevalue" $cnamevalue 
  validate_set $function "env" $env 

	delete_cname_if_exists $domain

  hostedzoneid=$(get_hostedzone_id $domain)

  parameters=$(add_parameter "CNameParam" $cname)
  parameters=$(add_parameter "CNameValueParam" $cnamevalue $parameters)
  parameters=$(add_parameter "HostedZoneIdParam" $hostedzoneid $parameters)
  parameters=$(add_parameter "TtlParam" $ttl $parameters)

  category="route53"
  resourcetype="cname"
	dotstodashes=$(dots_to_dashes $domain)

  deploy_stack $env'-'$dotstodashes $category $resourcetype $parameters

}

get_cname_value(){
  domain="$1"
  name="$2"
	
	hostedzoneid=$(get_hostedzone_id $domain)
	f=${FUNCNAME[0]}
	validate_set $f "hostedzoneid" $hostedzoneid

 	query='ResourceRecordSets[?Type==`CNAME`].ResourceRecords[].Value'
  value=$(aws route53 list-resource-record-sets --hosted-zone-id $hostedzoneid \
    --query $query --profile $profile --region $region --output text)

	echo $value

}

get_cname_name(){
  domain="$1"
 
  hostedzoneid=$(get_hostedzone_id $domain)
  f=${FUNCNAME[0]}
  validate_set $f "hostedzoneid" $hostedzoneid

  query='ResourceRecordSets[?Type==`CNAME`].Name'
  name=$(aws route53 list-resource-record-sets --hosted-zone-id $hostedzoneid \
    --query $query --profile $profile --region $region --output text)

  echo $name

}

get_cname_ttl(){
  domain="$1"

  hostedzoneid=$(get_hostedzone_id $domain)
  f=${FUNCNAME[0]}
  validate_set $f "hostedzoneid" $hostedzoneid

  query='ResourceRecordSets[?Type==`CNAME`].TTL'
  ttl=$(aws route53 list-resource-record-sets --hosted-zone-id $hostedzoneid \
    --query $query --profile $profile --region $region --output text)

  echo $ttl

}

#because CloudFormation does not delete cnames
#when it deletes a CloudFormation stack
#and seems to be adding the cname before my stack
#can insert it...
delete_cname_if_exists(){
	domain="$1"

	dnstype="CNAME"
	name=$(get_cname_name $domain)
	if [ "$name" != "" ]; then 
  	value=$(get_cname_value $domain $name)
		ttl=$(get_cname_ttl $domain)
		delete_dns_record $domain $dnstype $name $value $ttl
	fi
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
