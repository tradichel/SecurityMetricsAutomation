#!/bin/bash -e
# https://github.com/tradichel/SecurityMetricsAutomation
# awsdeploy/localtest.sh
# author: @tradichel @2ndsightlab
# description: Test code in container outside an EC2 instance
##############################################################
source deploy/shared/validate.sh
source deploy/shared/functions.sh
source resources/organizations/organization/organization_functions.sh 
source resources/organizations/account/account_functions.sh 

echo "********************************************"
echo "Set session length for temporary credentials"
echo "********************************************"
#minimum 900 secods or 15 minutes
max_session_duration_seconds=900
echo "Session length is $max_session_duration_seconds. Override? (y)"
read override
if [ "$override" == "y" ]; then
 	echo "Enter seconds"; read seconds
	validate_numeric $seconds
	max_session_duration_seconds=$seconds
fi

echo "********************************************"
echo "Build image if files changed"
echo "********************************************"
echo "Build? (y)"; read build
if [ "$build" == "y" ]; then ./container/build.sh;fi
echo "********************************************"
echo "Build complete"
echo "********************************************"
echo "********************************************"
echo "Optionally Push and Pull container to ECR"
echo "********************************************"

echo "Push to and pull to validate correct image is in ECR? (y)"; read push
if [ "$push" == "y" ]; then 
	echo "********************************************"
	echo "********** Push container to ECR ***********"
	echo "********************************************"
	./container/push.sh; 
	
	image="awsdeploy"
	echo "********************************************"
	echo " Pull image back down (testing push worked correctly)"
	echo "********************************************"
	source container/pull.sh
fi

echo "********************************************"
echo "***** Get User Credentials to Run Job ******"
echo "********************************************"
echo "Which user's credentials (stored in Secrets Manager) will be used for this deployment? (Enter number)"
echo "1 - root-admin"
echo "2 - root-orgadmin"
read userno
echo "********************************************"
echo "Select a Job $username is Allowed to Run"
echo "********************************************"
if [ "$userno" == "1" ]; then  source userjobs/root-adminrole.sh; 
elif [ "$userno" == "2" ]; then source userjobs/root-orgadminrole.sh; 
else echo "Invalid selection $userno"; exit
fi

s="localtest.sh"
validate_set $s "username" $username
validate_environment $s $env

#job is set in the sourced file in the last stop
script="$job.sh"

echo "********************************************"
echo "Role to simulate EC2 instance role"
echo "********************************************"
echo "Enter rolename to simulate EC2 instance role. Enter for SandboxAdminRole. L to list all profiles:"
read ec2rolename
if [ "$ec2rolename" == "L" ]; then aws configure list-profiles | sort; "Enter profile:"; fi
if [ "$ec2rolename" == "" ]; then ec2rolename="SandboxAdminRole"; fi
validate_set $s "ec2rolename" $ec2rolename

echo "********************************************"
echo "Get Deploy To Account Id "
echo "********************************************"
echo "*****TODO: Fix this because unless you create a cross account role, ec2 instance cannot do this.*****"
profile=OrgRoot

echo "Get Deploy To account number for account name: $deploytoaccount"
deploytoaccount=$(get_account_number_by_account_name $deploytoaccount)
echo "Deploy to account: $deploytoaccount"

echo "********************************************"
echo "Get The Account Number where the MFA Exists for the User"
echo "********************************************"
echo "Get MFA account number for account name: $mfaaccount"
mfaaccount=$(get_account_number_by_account_name $mfaaccount)
echo "MFA account: $mfaaccount"
echo "********************************************"
echo "Deploy to the same region as EC2 Rolename to prevent excessive cost and pain"
echo "********************************************"
#region is altered for a few jobs but heed the warning
region=$(get_region_for_profile $ec2rolename)
echo "Deploy TO and FROM Region: $region"
echo "********************************************"
echo "Get The Account Id That is Executing the Job and secret with credentials exists"
echo "********************************************"
ec2account=$(get_account_for_profile $ec2rolename)
echo "********************************************"
echo "Get Credentials from secrets manager in account $ec2account for $username"
echo "********************************************"
secret=$(aws secretsmanager get-secret-value \
  --secret-id 'arn:aws:secretsmanager:'$region':'$ec2account':secret:'$username \
  --query SecretString --output text --profile $ec2rolename)
validate_set $s "Access key and secret key in secret $username" $secret
access_key_id=$(echo $secret | jq -r ".aws_access_key_id")
secret_key=$(echo $secret | jq -r ".aws_secret_key")
validate_set $s "access_key_id in secret $username." $access_key_id
validate_set $s "secret_key in secret $username." $secret_key
echo "********************************************"
echo " Configure CLI Profile $deployrolename"
echo "********************************************"
#due to policies MFA will only work if MFA device name matches username
mfa_serial="arn:aws:iam::$mfaaccount:mfa/$username"
echo "********************************************"
echo "Configure CLI profile $deployrolename with temporary credentials and mfa: $mfa_serial"
echo "********************************************"
configure_cli_profile \
	$deployrolename \
  $access_key_id \
  $secret_key \
  $region \
  $mfa_serial

code=""
while [ "$code" == "" ]; do
	echo "Enter MFA code for $mfa_serial (crtl-C to exit):"; read -s code
done

sessionname="$username-$deployrolename-$job"
sessionname=$(echo "${sessionname:0:64}")
echo "********************************************"
echo "Use profile to get short term credentials for session: $sessionname"
echo "********************************************"
creds=$(aws sts assume-role --token-code $code \
  --serial-number $mfa_serial \
  --role-session-name $sessionname \
  --role-arn 'arn:aws:iam::'$deploytoaccount':role/'$deployrolename \
  --profile $deployrolename  \
  --region $region \
	--duration-seconds $max_session_duration_seconds)

accesskeyid="$(echo $creds | jq -r ".Credentials.AccessKeyId")"
secretaccesskey="$(echo $creds | jq -r ".Credentials.SecretAccessKey")"
sessiontoken="$(echo $creds | jq -r ".Credentials.SessionToken")"
echo "********************************************"
echo "Create parameter list to pass to container, including credentials"
echo "********************************************"
parameters="\
	rolename=$deployrolename,\
	accesskey=$accesskeyid,\
	secretaccesskey=$secretaccesskey,\
	sessiontoken=$sessiontoken,\
	region=$region,\
	env=$env,\
	script=$script,\
	parameters=$parameters"

#remove any spaces so the parameter list is treated as a single argument passed to the container
parameters=$(echo $parameters | sed 's/ //g')

image=$(basename "$PWD")
echo "********************************************"
echo "Run the contain $image and execute the job $job in account $deploytoaccount"
echo "********************************************"
docker run $image $parameters

