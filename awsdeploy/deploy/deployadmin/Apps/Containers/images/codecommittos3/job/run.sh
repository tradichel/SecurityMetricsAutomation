#!/bin/bash -e

DEBUG="true"
source /include/secrets.sh
source /include/validate.sh

function run () {
  event="$1"
  headers="$2"

	#get repo name from event data passed into function
  repo="$(echo $event | jq -r '.aws_repo')"
  validate_set $repo "repo"
	validate_alphanumeric_underscore_dash_period $repo
	
	#get the region and bucket from secrets manager
	region=$(get_secret_value "region")
	bucket=$(get_secret_value "bucket")
	
	#calculate the bucket url and repo name
	bucket_url="s3://$bucket/"
	aws_repo="https://git-codecommit.$region.amazonaws.com/v1/repos/$repo"
	
	#change to the directory where we can write files in a Lambda function
	cd /tmp

	#delete the directory if it exists and clone the repo
	if [ -d "$repo" ]; then rm -rf $repo; fi 
	git clone --bare $aws_repo $repo 2>&1 | tee $TMP 
	ls $repo  2>&1 | tee $TMP

	#sync files to S3	
	aws s3 sync $repo $bucket_url 2>&1 | tee $TMP
	
	echo "success"

}


