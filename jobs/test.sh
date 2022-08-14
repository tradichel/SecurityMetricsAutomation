#!/bin/bash -e

#note: 
#the deploy script deploys the job including the role and IAM Policy.
#the test sript tests the job, to a certain extent
#IAM deployments are eventually consistent so you may want to test the job separately after a period of time.
cd iam/DeployBatchJobCredentials
./deploy.sh
./test.sh job_batchcred
cd ../..


