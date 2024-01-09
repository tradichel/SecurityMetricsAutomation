#!/bin/bash

#account where user credentials exist
mfaaccount="root-org"
username="root-orgadmin"
deployrolename="root-orgadminrole"

echo "Enter number for script to deploy with $deploynamerole:"

#all these jobs use the nonprod app KMS key so that has to be
#created first
echo "1 AMI Builder Parameters"
echo "2 AMI Builder S3 bucket"
echo "3 AMI Builder Populate S3 Bucket"
echo "3 AMI - Linux Base Arm"
echo "4 AMI - Linux Tools arm (S3 repo, base tools and libraries)"
echo "5 AMI - Linux Pentest arm (Install and configure pentest tools)"
echo "6 AMI - Linux Builder arm (Everything + github sync script)"
echo "7 AMI - Windows Base (Base Windows AMI)"
echo "8 AMI - Windows Pentest (2SL Pentest Configuration)"
echo "9 AMI - Ubuntu Base arm"

if [ "$scriptno" == "1" ]; then job="organizations_all"; env="root";
else
  echo "Choice does not exist or is not implemented yet."
  exit
fi
