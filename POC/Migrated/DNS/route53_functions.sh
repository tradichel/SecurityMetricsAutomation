#!/bin/bash -e
# https://github.com/tradichel/SecurityMetricsAutomation
# awsdeploy/resources/route53/route53_functions.sh
# author: @teriradichel @2ndsightlab
##############################################################
source deploy/shared/functions.sh
source deploy/shared/validate.sh

deploy_hosted_zone() {
  appname="$1"
  domain="$2"

  function=${FUNCNAME[0]}
  validate_set $function "appname" "$appname" 
  validate_set $function "domain" "$domain"
 
  parameters=$(add_parameter "AppNameParam" $appname)
  parameters=$(add_parameter "DomainNameParam" $domain $parameters)
  
 	category="route53"
  resourcetype='hostedzone'

  deploy_stack $appname $category $resourcetype $parameters
}

get_hostedzone(){
	domain="$1"

  function=${FUNCNAME[0]}
  validate_set $function "domain" $domain

	hostedzoneid=$(aws route53 list-hosted-zones-by-name --dns-name $domain --output text --profile $profile --query 'HostedZones[0].Id' | cut -d "/" -f3)
	
	echo "$hostedzoneid"

}

#in the format expected by AWS CLI to update primary domain
get_ns_records_for_domain_update(){
	domain="$1"
	
	hostedzoneid=$(get_hosted_zone $domain)

	ns=$(aws route53  list-resource-record-sets --hosted-zone-id $hostedzoneid --profile $profile | grep "ns-" | grep -v "hostmaster" | cut -d ":" -f2 | sed 's/ //g' | sed 's/"//g' | sed 's/^/Name=/g' | paste -d " "  -s)

	echo $ns

}

#comma separated list
get_list_of_name_servers(){

	domain="$1"

  hostedzoneid=$(get_hosted_zone_id $domain)

  ns=$(aws route53  list-resource-record-sets --hosted-zone-id $hostedzoneid --profile $profile | grep "ns-" | grep -v "hostmaster" | cut -d ":" -f2 | sed 's/ //g' | sed 's/"//g' | paste -d " "  -s | sed 's/ /,/g')

	echo $ns
}


#formatted as AWS CLI expects
get_name_servers_for_cli_command(){
  domain="$1"

  hostedzoneid=$(get_hosted_zone_id $domain)

  ns=$(aws route53  list-resource-record-sets --hosted-zone-id $hostedzoneid --profile $profile | grep "ns-" | grep -v "hostmaster" | cut -d ":" -f2 | sed 's/ //g' | sed 's/"//g' | sed 's/^/{\"Value\":\"/g' | paste -d " "  -s | sed 's/ /\"},/g' | sed 's/$/\"}/g')
	
  echo $ns
}

export_zone(){

	domain="$1"
  hostedzoneid=$(get_hosted_zone_id $domain)

	aws route53 list-resource-record-sets --hosted-zone-id $hostedzoneid --profile $profile --output json | jq -jr '.ResourceRecordSets[] | "\(.Name) \t\(.TTL) \t\(.Type) \t\(.ResourceRecords[]?.Value)\n"'

}

get_app_name_from_domain(){
	domain="$1"
	appname=$(echo $domain | sed 's/\./-/g')
	echo $appname
}

delete_dns_record(){
	domain="$1"
	dnstype="$2"
	name="$3"
	value="$4"
	ttl="3600"

	#ttl="$5"

	#try to delete AWS CloudFormation stack if it exists
	appname=$(get_app_name_from_domain $domain)
	stackname="$profile-$type-$appname"

	echo "Deleting stack: $stackname"
	aws cloudformation delete-stack --stack-name $stackname --profile $profile

	action="DELETE"

  cd ~
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

  hostedzoneid=$(get_hosted_zone_id $domain)

	#dangerously ignoring error - should instead check if exists, then delete, but this is too painful
  aws route53 change-resource-record-sets --hosted-zone-id $hostedzoneid --change-batch "file://$f" --profile $profile

}

#get the ns records for subdomain first - may require a separate profile
add_ns_record_for_subdomain_via_cli(){
	domain="$1"
	subdomain="$2"
	ns="$3"
	action="$4"
	
  function=${FUNCNAME[0]}
  validate_set $function "domain" "$domain"
  validate_set $function "subdomain" "$subdomain"
  validate_set $function "ns" "$ns"
  validate_set $function "action" "$action"

	if [ '$action' != 'CREATE' ]; then
		if [ '$action' != 'UPDATE' ]; then
			echo "Action should be CREATE,  or UPSERT"
			exit
		fi
 fi
	
	cd ~
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

	hostedzoneid=$(get_hosted_zone_id $domain)
	
	aws route53 change-resource-record-sets --hosted-zone-id $hostedzoneid --change-batch "file://$f" --profile $profile

}

deploy_cname() {
  appname="$1"
  domain="$2"
	cname="$3"
	cnamevalue="$4"

  function=${FUNCNAME[0]}
  validate_param $function "appname" "$appname"
  validate_param $fucntion "domain" "$domain
  validate_param $function "cname" "$cname"
  validate_param $function "cnamevalue" "$cnamevalue" 

  hostedzoneid=$(get_hosted_zone_id $domain)

	#because CloudFormation does not delete CNAMES when deleting stacks,
	#if the stack does not exist and the cname does, I need to delete it.
	ttl=300
	#TODO: Only run this command if CNAME does not exists
	#Also, look up CNAME TTL
	#delete_dns_record $domain 'CNAME' $cname $cnamevalue $ttl

	#for some reasons the above is changing the path
	set_context

  parameters=$(add_parameter "CNameParam" $cname $parameters)
  parameters=$(add_parameter "CNameValueParam" $cnamevalue $parameters)
  parameters=$(add_parameter "HostedZoneIdParam" $hostedzoneid $parameters)

  category="route53"
  resourcetype="cname"

  deploy_stack $appname $category $resourcetype $parameters

	echo $hostedzoneid

} 

deploy_tls_validation_record() {
  domain="$1"

  svc="cloudformation"

  appname=$(echo $domain | sed 's/\./-/g')
  suffix="TLSCertificate-$appname"
  stackname=$(aws $svc list-stacks --profile $profile | grep -i Name | grep "$suffix" |  head -n 1 | cut -d ':' -f2 | sed 's/"//g' | sed 's/,//g' | sed 's/ //g')
  if [ "$stackname" == "" ]; then
    echo "stackname not found for domain $domain and appname $appname ending with $suffix";  exit
  fi
  echo "Stackname: $stackname"
	grepvalue="value"
  s=$(aws $svc describe-stack-events --stack-name $stackname --profile $profile | grep -i $grepvalue | sed 's/^.*{//g' | sed 's/}.*$//g')
  echo "String with $grepvalue: $s"
  name=$(echo $s | cut -d ':' -f2 | cut -d ',' -f1)
  echo "CNAME name: $name"
  value=$(echo $s | cut -d ':' -f4)
  echo "CNAME value: $value"

  if [ "$name" == "" ]; then
    aws cloudformation describe-stack-events --stack-name $stackname --profile $profile
    echo "CNAME name not found"; exit
  fi

  if [ "$value" == "" ]; then
    aws cloudformation describe-stack-events --stack-name $stackname --profile $profile
    echo "CNAME value not found"; exit
  fi
	
  deploy_cname $appname $domain $name $value

}
