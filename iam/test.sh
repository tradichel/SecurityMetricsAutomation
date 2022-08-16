#!/bin/sh -e

#deploy batch job admins
cd batch_job_admins
./deploy.sh
cd ..

#deploy batch job role
job="POC" 
batchjobtype="batch"
cd batch_job_role
./deploy.sh $job $batchjobtype
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



