#!/bin/bash 
#description: Example of testing role assumption permissions

source shared_functions.sh
source assume_role.sh

#get the root directory for this code base
cd ../
base_path=$(pwd)
echo "Base Path: $base_path"

#role that has permission to assume cross account roles
#and query IAM
profile="OrgRoot"
targetaccountname='Sandbox-Web'
rolename="XacctWebAdminGroup"
userToAssumeRole="WebAdmin"
useraccountname='Sandbox'
groupname='XacctWebAdmin'
m="\nCtrl-C to exit. Enter to continue."

#name of the role profile you want to create in your AWS CLI configuration.
#I'm using the role name as the AWS CLI profile name here
#Once created run commands like this: aws s3 ls --profile $roleprofile
roleprofile=$rolename

echo "Change to Organization directory and use OrgRoot AWS CLI profile"
change_dir "Account" $base_path "OrgRoot"; echo ""

echo "Get the account number of the account where the role exists"
acctnum=$(get_account_number $targetaccountname)
echo -e "The target account number is $acctnum.$m"; read ok

echo "Create an AWS CLI Profile for the default Organization role in $targetaccountname"
echo "Please wait..."
remoteprofile=$(create_org_admin_role_profile $targetaccountname)
cliprofile=$(cat ~/.aws/config | grep -i $remoteprofile -A2)
echo -e $cliprofile
echo -e "CLI profile created.$m"; read ok

echo "List the roles in the target account using profile: $remoteprofile" 
role=$(aws iam list-roles --profile $remoteprofile --output text | grep $rolename | cut -f2)
if [ "$role" != "" ]; then
	echo -e "Role exists: $role.$m"
else
	echo -e "Role does not exist.$m"
fi
read ok

echo "Evalute the role trust policy"
aws iam get-role --role-name $rolename --profile $remoteprofile
echo -e "Does the assume role document (trust policy) contain the ARN for the user that is allowed to assume the role?$m"
read ok

change_dir "Accounts" $base_path "OrgRoot"; echo ""
echo "Get the account number of the account where the role exists"
useracctnum=$(get_account_number $useraccountname)
echo -e "The user account number is $useracctnum.$m"; read ok

echo "Create an AWS CLI Profile for the default Organization role in $useraccountname"
echo "Please wait..."
useracctprofile=$(create_org_admin_role_profile $useraccountname)
cliprofile=$(cat ~/.aws/config | grep -i $useracctprofile -A2)
echo -e $cliprofile
echo -e "CLI profile created.$m"; read ok

echo "Check that user exists in the user account."
testuser=$(aws iam list-users --profile $useracctprofile --output text | grep $userToAssumeRole | cut -f2)
if [ "$testuser" == "" ]; then
	echo -e "$userToAssumeRole does not exist.$m"
else
	echo -e "$testuser exists.$m"
fi
read ok

echo "Check that the group exits."
testgroup=$(aws iam list-groups --profile $useracctprofile --output text | grep $groupname | cut -f2)
if [ "$testgroup" == "" ]; then
	echo -e "Group: $groupname does not exist in $useraccountname.$m"
else
	echo -e "Group: $testgroup exists in $useraccountname.$m"
fi
read ok

echo "Check that the user is in the group"
group=$(aws iam list-groups-for-user --profile $useracctprofile --user-name $userToAssumeRole --output text | grep $groupname | cut -f2)
if [ "$group" == "" ]; then
	echo -e "Group not found for user.$m"
else
	echo -e "User is in group: $group.$m"
fi
read ok

policyname=$groupname'GroupPolicy'
echo "Check that the group policy $policyname exists."
echo "Group policies:"
aws iam list-group-policies --profile $useracctprofile --group-name $groupname --output text
#this code should really loop through all policies but I know I only add one policy to groups in this codebase
testpolicy=$(aws iam list-group-policies --profile $useracctprofile --group-name $groupname --output json --query 'PolicyNames[0]')
if [ "$testpolicy" == "null" ]; then 
	echo -e "Policy $policyname does not exist for group: $groupname.$m"; read ok
else
	echo -e "Policy $testpolicy exists for group $groupname.$m"; read ok
fi 

echo "Evaluate the policy"
aws iam get-group-policy --profile $useracctprofile --policy-name $policyname --group-name $groupname
t=$(aws iam get-group-policy --profile $useracctprofile --policy-name $policyname --group-name $groupname | grep $rolename)

if [ "$t" == "" ]; then
	echo -e "NOT OK: Role name $rolename not found in policy.$m"; read ok
else
	echo -e "OK: Role name $rolename found in policy.$m"; read ok

	echo "Check for acctnum in policy"
	t=$(aws iam get-group-policy --profile $useracctprofile --policy-name $policyname --group-name $groupname | grep $acctnum)
  if [ "$t" == "" ]; then
		echo -e "NOT OK: Account number not found in role ARN in policy.$m"; read ok
  else
    echo -e "OK: Correct account number found in policy.$m"; read ok

		echo "Check for ARN in policy."
		arn="arn:aws:iam::$acctnum:role/$rolename"
    t=$(aws iam get-group-policy --profile $useracctprofile --policy-name $policyname --group-name $groupname | grep $arn)
		if [ "$t" == "" ]; then
			echo -e "NOT OK: Arn not found in policy. Is it properly formatted as $arn?$m"; read ok
		else
			echo -e "OK: Policy contains correct ARN.$m"; read ok
		fi
	fi
fi
read ok

#set profile trying to assume the role
profile=$userToAssumeRole

echo "Create a cross account CLI Profile for $rolename"
mfa="true"
create_cross_account_role_profile $acctnum $rolename $roleprofile $mfa
cliprofile=$(cat ~/.aws/config | grep -i $roleprofile -A2)
echo -e $cliprofile
echo -e "CLI profile created.$m"; read ok

#TODO: need a mechanism to remove the role profile

echo "Assume cross account role and add credentials to environment vars"
assume_cross_account_role $accountnum $orgprefix $targetaccountname $roleprofile $mfa
echo "Assume role and add credentials to environent vars ok? Ctrl-C to exit."
read ok

echo "Remove credentials from environment vars"
stop_assume_cross_account_role
echo "Have the credentials been removed from environment variables?"
echo "Done."

