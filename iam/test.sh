#!/bin/sh -e

#deploy batch job admins
cd batch_job_admins
./deploy.sh
cd ..

#get arn for batch job admin user
adminarn=$(aws cloudformation describe-stacks --stack-name BatchJobAdmin \
	--query "Stacks[0].Outputs[?ExportName=='batchjobuserarn'].OutputValue" --output text)

#deploy batch job role
job="POC" 
cd batch_job_role
./deploy.sh $job $adminarn
cd ..

cd iam_admins
./deploy.sh
cd ..

cd kms_admins
./deploy.sh
cd ..

cd kms_admin_role
./deploy.sh
cd ..

cd trigger_job_role
./deploy.sh
cd ..



