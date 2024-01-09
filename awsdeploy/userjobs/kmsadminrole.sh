#!/bin/bash

#account where user credentials exist
mfaaccount="root-org"
username="root-orgadmin"
deployrolename="root-orgadminrole"

echo "Enter number for script to deploy with $deploynamerole:"

echo "1 Nonprod App Key: Key for encrypting AMIs, repositories, app testing"
echo "2 Nonprod Logs Key: Key for all nonprod logs"
echo "3 Nonprod Project Key: Key for a project account and the data stored in it"
echo "4 Nonprod Web S3 Key: lower cost, less stringent security for a website"

if [ "$scriptno" == "1" ]; then job="organizations_all"; env="root";
else
  echo "Choice does not exist or is not implemented yet."
  exit
fi
