#!/bin/bash -e

source ../../../../Functions/shared_functions.sh

profile="AppSec"

deploy_batch_job_policy() {
	jobname="$1"
	
	#deploy the policy
	resourcetype="Policy"
	policyname='Batch'$jobname'Policy'
	template='cfn/'$policyname'.yaml'
	deploy_stack $profile $policyname $resourcetype $template
}

deploy_batch_job_secret() {
	secretname="$1"
	batchjobadmin="$2"
	
	template='cfn/'$secretname'Secret.yaml'
	resourcetype="Secret"
	parameters=$(add_parameter "UserNameParam" $batchjobadmin)
	deploy_stack $profile $secretname $resourcetype $template $parameters
}
