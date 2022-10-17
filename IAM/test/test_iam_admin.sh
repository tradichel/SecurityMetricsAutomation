#!/bin/bash -e
# https://github.com/tradichel/SecurityMetricsAutomation
# IAM/test.sh
# author: @tradichel @2ndsightlab
#############################################################

echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo " Have you set up an AWS CLI role profile named ROOT? "
echo " Create an AWS CLI profile named ROOT as explained "
echo " in the blog series. You can use any user in "
echo " a new AWS account that has IAM permission "
echo " to create the IAMAdmin user, group, and role."
echo ""
echo "CTRL-C to exit. Any other key to continue."
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
read ok


cd ..
cd stacks/User
./deploy_iam_admins.sh
cd ../../test

cd ..
cd stacks/Group
./deploy_iam_group.sh
cd ../../test

cd ..
cd stacks/Role
./deploy_iam_role.sh
cd ../../test

echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo " IAM Users, Group and Role deployed."
echo " Next steps:"
echo " * Create an AWS CLI Profile named IAM "
echo " as explained the the blog series before proceeding."
echo " * Disable your ROOT CLI profile credentials "
echo " and enable them if you need to recreate or modify "
echo " the IAM Admin resources. "
echo " * Store your credentials away "
echo " for that all powerful account and don't use it "
echo " except in case of emergency."
echo " * Perhaps develop a process that requires two "
echo " people to access and use it."
echo ""
echo " The script will now exit so you can creat the "
echo " IAM profile. Skip this step on your next run."
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
