#!/bin/bash -e
# https://github.com/tradichel/SecurityMetricsAutomation
# awsdeploy/resources/route53/hostedzone/hostedzone_functions.sh
# author: @teriradichel @2ndsightlab
##############################################################
source deploy/shared/functions.sh
source deploy/shared/validate.sh

#formatted to update primary domain
get_ns_records(){
	domain="$1"

  hostedzoneid=$(get_hostedzone $domain)

	ns=$(aws route53  list-resource-record-sets --hosted-zone-id $hostedzoneid \
  --profile $profile --region $region \
   | grep "ns-" | grep -v "hostmaster" | cut -d ":" -f2 | \
   sed 's/ //g' | sed 's/"//g' | sed 's/^/Name=/g' | paste -d " "  -s)

  echo $ns
}

deploy_hostedzone() {
  domain="$1"
  env="$2"

  function=${FUNCNAME[0]}
  validate_set $function "env" "$env" 
  validate_set $function "domain" "$domain"
 
	#because aws naming conventions :^|
	dotstodashes=$(dots_to_dashes $domain)
  parameters=$(add_parameter "DomainDotsToDashesParam" $dotstodashes)
  parameters=$(add_parameter "DomainNameParam" $domain $parameters)
  
 	category="route53"
  resourcetype="hostedzone"
	resourcename=$env'-'$dotstodashes
		
  deploy_stack $resourcename $category $resourcetype $parameters
	
	echo "Make sure you update the NS records for this hosted zone"
	echo "on the apex (primary) domain for a subdomain or on the"
	echo "domain registration NS server records for the apex domain"

	#TODO: Create an automated test for this:
	#https://repost.aws/questions/QU3blJ2vdMSdO-T7KcRc5xuQ/pointing-ec2-public-ip-address-to-my-domain-using-a-record
	
}

get_hostedzone_id(){
	domain="$1"

  function=${FUNCNAME[0]}
  validate_set $function "domain" $domain

	hostedzoneid=$(aws route53 list-hosted-zones-by-name --dns-name $domain --region $region --output text --profile $profile --query 'HostedZones[0].Id' | cut -d "/" -f3)
	
	echo "$hostedzoneid"
}

#comma separated list
get_name_servers(){

	domain="$1"

  function=${FUNCNAME[0]}
  validate_set $function "domain" $domain

  hostedzoneid=$(get_hosted_zone_id $domain)
  validate_set $function "hostedzoneid" "$hostedzoneid"
 
	ns=$(aws route53  list-resource-record-sets --hosted-zone-id $hostedzoneid \
   --profile $profile --region $region | grep "ns-" | grep -v "hostmaster" | \
		cut -d ":" -f2 | sed 's/ //g' | sed 's/"//g' | paste -d " "  -s | sed 's/ /,/g')

	echo $ns
}


#formatted as AWS CLI expects
get_name_servers_for_cli_command(){
  domain="$1"

  function=${FUNCNAME[0]}
  validate_set $function "domain" $domain

  hostedzoneid=$(get_hostedzone_id $domain)
  validate_set $function "hostedzoneid" $hostedzoneid

  ns=$(aws route53  list-resource-record-sets --hosted-zone-id $hostedzoneid \
	--profile $profile --region $region | grep "ns-" | grep -v "hostmaster" | cut -d ":" -f2 | sed 's/ //g' \
	 | sed 's/"//g' | sed 's/^/{\"Value\":\"/g' | paste -d " "  -s | sed 's/ /\"},/g' | sed 's/$/\"}/g')
	
  echo $ns
}

get_domain_from_subdomain(){
	subdomain="$1" 	
  while [ $(echo "$subdomain" | sed 's/\.//g') != "$subdomain" ]; do
    parentdomain=$subdomain
    subdomain=$(echo "$subdomain" | cut -d "." -f2-)
  done
	echo $parentdomain
}

#update the NS records on a primary domain (not a subdomain)
update_name_servers(){
 	primarydomain="$1"
	nameservers="$2"

  function=${FUNCNAME[0]}
  validate_set $function "primarydomain" $primarydomain
  validate_set $function "nameservers" $nameservers
	
	aws route53domains update-domain-nameservers --domain-name $primaydomain \
		 --nameservers $nameservers --profile $profile --region $region
}

#call the following using the appropriate profile with 
#access to the correct account where the subdomain exists
#ns=$(get_name_servers_for_cli_command $subdomain)
update_subdomain_name_servers(){
	env="$1"
	parentdomain="$2"
	subdomain="$3"
	nameservers="$4"

  function=${FUNCNAME[0]}
  validate_set $function "parentdomain" $parentdomain
  validate_set $function "subdomain" $subdomain
  validate_set $function "nameservers" $nameservers
	validate_set $function "env" $env
	
  #UPSERT: If a resource set doesn't exist, Route 53 creates it. 
  #If a resource set exists Route 53 updates it with the values in the request.
  action="UPSERT"
  add_ns_record_for_subdomain_via_cli "$env" "$parentdomain" "$subdomain" "$nameservers" "$action"

}

export_zone(){

	domain="$1"
  hostedzoneid=$(get_hostedzone_id $domain)

	aws route53 list-resource-record-sets --hosted-zone-id $hostedzoneid \
	--profile $profile --output json --region $region | jq -jr '.ResourceRecordSets[] \
	| "\(.Name) \t\(.TTL) \t\(.Type) \t\(.ResourceRecords[]?.Value)\n"'

}

#This code is digusting.
#Will change it later if I can now that I've discoverd 
#CloudFormation imports
delete_dns_record(){
	domain="$1"
	dnstype="$2"
	name="$3"
	value="$4"
	ttl="$5"

	#try to delete AWS CloudFormation stack if it exists
	appname=$(dots_to_dashes $domain)
	stackname="$profile-$type-$appname"

	echo "Deleting stack: $stackname"
	aws cloudformation delete-stack --stack-name $stackname --profile $profile --region $region

	action="DELETE"

  f=$(pwd)
  f="$f/ns.temp"
  echo -e "{" > $f
  echo -e "\t\"Changes\": [" >> $f
  echo -e "\t{" >> $f
  echo -e "\t\t\"Action\": \"$action\"," >> $f
  echo -e "\t\t\"ResourceRecordSet\": {" >> $f
  echo -e "\t\t\t\"Name\": \"$name\"," >> $f
  echo -e "\t\t\t\"Type\": \"$dnstype\"," >> $f
  echo -e "\t\t\t\"TTL\": $ttl," >> $f
 	echo -e "\t\t\t\"ResourceRecords\": [ " >> $f
 	echo -e "\t\t\t\t{\"Value\": \"$value\"}" >> $f
 	echo -e "\t\t\t ]" >> $f
  echo -e "\t\t}" >> $f
  echo -e "\t}" >> $f
  echo -e "]" >> $f
  echo -e "}" >> $f

  cat $f

  hostedzoneid=$(get_hostedzone_id $domain)

	#dangerously ignoring error - should instead check if exists, then delete, but this is too painful
  aws route53 change-resource-record-sets --hosted-zone-id $hostedzoneid \
		--change-batch "file://$f" --profile $profile --region $region

}

#get the ns records for subdomain first - may require a separate profile
add_ns_record_for_subdomain_via_cli(){
	env="$1"
	parentdomain="$2"
	subdomain="$3"
	ns="$4"
	action="$5"
	
  function=${FUNCNAME[0]}
  validate_set $function "parentdomain" $parentdomain
  validate_set $function "subdomain" $subdomain
  validate_set $function "ns" $ns
  validate_set $function "action" $action
	validate_set $function "env" $env

  echo "Get hosted zone for $parentdomain"
  hostedzoneid=$(get_hostedzone_id $parentdomain)
	if [ "$hostedzoneid" == "None" ]; then 
		deploy_hostedzone $parentdomain $env
		hostedzoneid=$(get_hostedzone_id $parentdomain)
	fi
  validate_set $function "hostedzoneid" $hostedzoneid

	if [ "$action" != "CREATE" ]; then
		if [ "$action" != "UPSERT" ]; then
			echo "Action should be CREATE or UPSERT not $action"
			exit
		fi
 fi
	
	f=$(pwd)
	f="$f/ns.temp"
	echo -e "{" > $f
	echo -e "\t\"Changes\": [" >> $f
	echo -e "\t{" >> $f
	echo -e "\t\t\"Action\": \"$action\"," >> $f
	echo -e "\t\t\"ResourceRecordSet\": {" >> $f
	echo -e "\t\t\t\"Name\": \"$subdomain\"," >> $f
	echo -e "\t\t\t\"Type\": \"NS\"," >> $f
	echo -e "\t\t\t\"TTL\": 3600," >> $f
	echo -e "\t\t\t\"ResourceRecords\": [ " >> $f
	echo -e "\t\t\t"$ns >> $f
	echo -e "\t\t\t ]" >> $f
	echo -e "\t\t}" >> $f
  echo -e "\t}" >> $f
	echo -e "]" >> $f
	echo -e "}" >> $f

	cat $f

	aws route53 change-resource-record-sets --hosted-zone-id $hostedzoneid \
		--change-batch "file://$f" --profile $profile --region $region

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
                                                                                   
