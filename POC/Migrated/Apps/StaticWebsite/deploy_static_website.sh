#!/bin/bash -e

#ugly script for testing
owner="2ndSightLab"
domain="dev.rainierrhododendrons.com"
nsdomain="rainierrhododendrons.com"
appname=$(echo $domain | sed 's/\./-/g')
deployacctname='2sldev-Sandbox-Web'
rolename="XacctWebAdminGroup" #roleprofile=rolename
mfa="true"
#should get dynamically
region="xx-xxxx-x"
env="sandbox"
#need this for keys and buckets
kmskeyalias="$env-Apps"

#make sure resources are deployed first
#./Sandbox/deploy.sh

#current directory
startdir=$(pwd)

#root directory for this code
cd ../../
basepath=$(pwd)

source $basepath/Functions/shared_functions.sh
source $basepath/Functions/assume_role.sh

#we don't need an AWS profile to run this code.
profile="none"
echo "------------GITHUB REPO ---------------"
echo "Create Github Repositry $owner/$domain? (y)"; read y
if [ "$y" == "y" ]; then
  change_dir "GitHub" $basepath "NA"
  create_repository $owner $domain
  cd $startdir
fi 

echo "------------CodeCommit REPO ---------------"
echo "Create CodeCommit Repositry $env$appname? (y)"; read y
if [ "$y" == "y" ]; then
	profile="SandboxAdmin"
  change_dir "CodeCommit" $profile
  create_repository $env $appname
fi


echo "----------------GET ACCOUNT NUMBER FOR DEPLOYMENT ACCOUNT--------------"
change_dir "Account" "OrgRoot"
acctnum=$(get_account_number_by_account_name $deployacctname)
if [ "$acctnum" == "" ]; then echo "Account number not found for $deployacctname"; exit; fi
echo "Deployment account number: $acctnum"

echo "-------------------CLI PROFILE FOR DEPOYMENT ACCOUNT --------------------"
echo "If you get an error regarding MFA devices make sure your webadmin profile credentials are correct."
echo "The credentials should be associated with the WebAdmin *user* not a role."
echo "Make sure there are no session tokens in the credentials file for this profile."
profile="WebAdmin"
cd $base_path
create_cross_account_role_profile $acctnum $rolename $mfa $region
echo "Created role profile $rolename"
profile="XacctWebAdminGroup"

echo "Deploy hosted zone for $domain using profile $rolename? (y)"; read y
if [ "$y" == "y" ]; then
	change_dir "DNS" $rolename
	deploy_hosted_zone $appname $domain

	#query the new hosted zone	
  aws route53 list-hosted-zones-by-name --dns-name $domain --profile $rolename

	echo "---------GET HOSTED ZONE NS -------------" 
	hostedzoneid=$(aws route53 list-hosted-zones-by-name --dns-name $domain --output text --profile $rolename --query 'HostedZones[0].Id' | cut -d "/" -f3)
	ns=$(aws route53  list-resource-record-sets --hosted-zone-id $hostedzoneid --profile $rolename | grep "ns-" | grep -v "hostmaster" | cut -d ":" -f2 | sed 's/ //g' | sed 's/"//g' | sed 's/^/Name=/g' | paste -d " "  -s)
	
	echo $ns

fi

echo "---------DEPLOY NS RECORDS ON PRIMARY DOMAIN------------"
echo "Deploy NS changes on primary domain (not a subdomain)? (y)"; read y
if [ "$y" == "y" ]; then

	profile="OrgRoot"
	denyall_ou="DenyAll"
	domains_ou="Domains"
	domainsacctname="Domains"

  change_dir "OU" $basepath "OrgRoot"
  domains_ouid=$(get_ou_id_from_name $domains_ou)
	denyall_ouid=$(get_ou_id_from_name $denyall_ou)

	change_dir "Account" $basepath "OrgRoot"
	domainsacctnum=$(get_account_number_by_account_name $domainsacctname)

	ouid=$(get_account_ou $domainsacctnum)
	if [ "$ouid" != "$domains_ouid" ]; then	
		move_account $domainsacctnum $denyall_ouid $domains_ouid
	fi

  #change_dir "DNS" $basepath "DomainsNS"
  aws route53domains update-domain-nameservers --domain-name $domain --nameservers $ns --profile ns_domains

	ouid=$(get_account_ou $domainsacctnum)
	if [ "$ouid" != "$denyall_ouid" ]; then 
  	move_account $domainsacctnum $domains_ouid $denyall_ouid
	fi

else

	echo "Update the primary domain hosted zone with NS records for a subdomain? (y)"; read y
	if [ "$y" == "y" ]; then

		profile="XacctWebAdminGroup"
		domain="rainierrhododendrons.com"
		subdomain="dev.rainierrhododendrons.com"
		change_dir "DNS" $rolename
		ns=$(get_name_servers_for_cli_command $subdomain)
		echo $ns
		profile="zone_admin"
		#todo - update or create as appropriate
		action="UPSERT"
		add_ns_record_for_subdomain_via_cli $domain $subdomain $ns $action
		domain=$subdomain

	fi

fi

echo "Deploy TLS certificate using AWS Certificate Manager? (y)"; read y
if [ "$y" == "y" ]; then  
	change_dir "AppSec" $rolename
  deploy_certificate $domain $appname $hostedzoneid
fi

#only need to deploy this once per env
echo "Deploy KMS key for $kmskeyalias? (y)"; read y
if [ "$y" == "y" ]; then

  echo "------------ Deploy KMS Key ------------"
	change_dir "Key" $rolename
	encryptarn=$(aws iam get-role --role-name XacctWebAdminGroup --profile XacctWebAdminGroup | grep Arn | cut -d ":" -f2- | sed 's/ //g' | sed 's/"//g' | sed 's/,//g')
	decryptarn=$encryptarn
	profile="XacctWebAdminGroup"

	#I want to change this to all be managed by the KMS acct later
 	envacct="SandboxWebAccount"
	deploy_key $envacct $encryptarn $decryptarn $kmskeyalias

	echo "------------ Deploy KMS Key Alias ------------"
	change_dir "KeyAlias" $rolename
	keyid=$(get_key_id $kmskeyalias)
  deploy_key_alias $keyid $kmskeyalias

fi

echo "Deploy S3 bucket? (y)"; read y
if [ "$y" == "y" ]; then
  echo "------------ Create S3 bucket ------------"
	env="sandbox"
 	change_dir "S3" $rolename
	echo deploy_s3_bucket_for_public_static_site $domain $env $kmskeyalias
	deploy_s3_bucket_for_public_static_site $domain $env $kmskeyalias
fi

echo "Deploy S3 bucket policy? (y)"; read y
if [ "$y" == "y" ]; then
  echo "------------ Create S3 bucket ------------"
  change_dir "S3" "$rolename"
  bucketname="sandbox-2sldev-devrainierrhododendronscom"
	appname="codecommittos3"
	service="Lambda"
	readorwrite="Write"
	awsacctnum="xxxxxxxxxxxx"
  deploy_app_s3_bucket_policy $awsacctnum $appname $service $readorwrite
fi

echo "Deploy x? (y)"; read y
if [ "$y" == "y" ]; then
  echo "------------ Create x ------------"

fi
