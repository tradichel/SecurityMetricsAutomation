#!/bin/bash

#account where user credentials exist
mfaaccount="root-org"
username="root-orgadmin" 
deployrolename="root-orgadminrole"

echo "Enter number for script to deploy with $deploynamerole:"

#Scripts to create organizational units
echo "1 All organizations resources"
echo "2 All OUs"
echo "3 All Accounts"
echo "4 suspended ou"
echo "5 denyall ou"
echo "6 orgadmin ou" 
echo "7 governance ou"
echo "8 security ou"
echo "9 org backup ou"
echo "10 deploy ou"
echo "11 nonprod ou"
echo "12 nonprod resources ou"
echo "13 nonprod engineering ou"
echo "14 nonprod apps ou"
echo "15 nonprod projects ou"
echo "16 nonprod backup ou"
echo "17 IAM account"
echo "40 Environment - Nonprod"
echo "50 Project account in the nonprod OU"
echo "60 Test domain name and ssl cert"
echo "61 Test cloudfront domain and ssl cert (must be deployed in xx-xxxx-x)"
read scriptno

#scripts with parameters if neccessary

deploytoaccount="root"
if [ "$scriptno" == "1" ]; then job="organizations_all"; env="root";
elif [ "$scriptno" == "2" ]; then job="organizations_organizationalunit_all"; env="root";
elif [ "$scriptno" == "3" ]; then job="organizations_account_all"; env="root";

#root ous
elif [ "$scriptno" == "4" ]; then job="organizations_organizationalunit_suspended"; env="root"; 
elif [ "$scriptno" == "5" ]; then job="organizations_organizationalunit_denyall"; env="root";
elif [ "$scriptno" == "6" ]; then job="organizations_organizationalunit_org"; env="root";

#org ous
elif [ "$scriptno" == "7" ]; then job="organizations_organizationalunit_governance"; env="org";
elif [ "$scriptno" == "8" ]; then job="organizations_organizationalunit_security"; env="org";
elif [ "$scriptno" == "9" ]; then job="organizations_organizationalunit_backup"; env="org";
elif [ "$scriptno" == "10" ]; then job="organizations_organizationalunit_deploy"; env="org";
elif [ "$scriptno" == "11" ]; then job="organizations_organizationalunit_nonprod"; env="org"; 

#nonprod ous
elif [ "$scriptno" == "12" ]; then job="organizations_organizationalunit_resources"; env="nonprod"; 
elif [ "$scriptno" == "13" ]; then job="organizations_organizationalunit_engineering"; env="nonprod";
elif [ "$scriptno" == "14" ]; then job="organizations_organizationalunit_apps"; env="nonprod";
elif [ "$scriptno" == "15" ]; then job="organizations_organizationalunit_projects"; env="nonprod"; 
elif [ "$scriptno" == "16" ]; then job="organizations_organizationalunit_backup"; env="nonprod"; 

#org accounts
elif [ "$scriptno" == "17" ]; then job="organizations_account_org_iam"; env="org";
elif [ "$scriptno" == "18" ]; then job="organizations_account_org_billing"; env="org";
elif [ "$scriptno" == "19" ]; then job="organizations_account_org_policies"; env="org";#nonprod accounts

#org deploy account
elif [ "$scriptno" == "20" ]; then job="organizations_account_org_deploy"; env="org";

#security logmonitor account
elif [ "$scriptno" == "21" ]; then job="organizations_account_org_logmonitor"; env="org";

#org backup account
elif [ "$scriptno" == "22" ]; then job="organizations_account_org_backup"; env="org";

#nonprod accounts
elif [ "$scriptno" == "23" ]; then job="organizations_account_nonprod_kms"; env="nonprod";
elif [ "$scriptno" == "24" ]; then job="organizations_account_nonprod_amis"; env="nonprod";
elif [ "$scriptno" == "25" ]; then job="organizations_account_nonprod_domains"; env="nonprod";
elif [ "$scriptno" == "26" ]; then job="organizations_account_nonprod_sandbox"; env="nonprod";
elif [ "$scriptno" == "27" ]; then job="organizations_account_nonprod_web"; env="nonprod";
elif [ "$scriptno" == "28" ]; then job="organizations_account_nonprod_backup"; env="nonprod";

#environment
elif [ "$scriptno" == "40" ]; then job="environment"; env="nonprod";

#project account
elif [ "$scriptno" == "50" ]; then 
	
  echo "Enter Project ID:"
	read projectid
	#projectid="pv1w2dhadl"
	projectid="testproject"

  echo "Enter Username:"
  read projectusername
	#projectusername="pentester"
	projectusername="tester"

  echo "Enter Remote Access Cidr (for single IP include /32 at end):"
  read remoteaccesscidr
	remoteaccesscidr="73.108.70.205/32"

  echo "Enter HTTP/S Out Cidr (for single IP include /32 at end):"
  read httpsoutcidr
	httpsoutcidr="0.0.0.0/0"
	
  parameters="[projectid=$projectid,
			username=$projectusername,\
			remoteaccesscidr=$remoteaccesscidr,\
			httpsoutcidr=$httpsoutcidr]"

	job="organizations_account_project"
	env="nonprod" 

#project test domains
elif [ "$scriptno" == "60" ]; then
  
  echo "Enter Project ID:"
  read projectid

 	parameters='[projectid='$projectid']'
  job="test_domain"
  env="nonprod"

#project test cloudfront domain
elif [ "$scriptno" == "61" ]; then

  echo "Enter Project ID:"
  read projectid

	region="xx-xxxx-x"
  parameters='[projectid='$projectid']'
  job="test_cloudfront_domain"
  env="nonprod"


else

	echo "Choice does not exist or is not implemented yet."
	exit

fi 


