#!/bin/bash -e

# If the AWS_ACCESS_KEY_ID is not set the function is not running in Lambda.
# It is running locally. We can pass in credential here to test
# Testing with the same role the Lambda uses ensures we are testing with the 
# same permissions exactly that the Lambda function has.
# The credentials, though hard coded, will expire after a certain amount
# of time. Also, the way I plan to design the Lamba functions, they will 
# have limited access.

get_creds(){

	echo "Running get_creds in credentials.sh"

	if [ "$(echo $AWS_ACCESS_KEY_ID)" == "" ]; then
		source /job/creds.sh	
	else

	#If we are in DEBUG mode only, we can generate the following output, which
	#makes it easy to copy and past over the above credentials with the Lambda output.
	#This should be turned off in production environments or any enironment where the 
	#logs are not secure, because this output will end up in the logs as well.
	#If you are working in an unsecured environment with too much access, do not
	#use this approach. Create a separate method for obtaining the credentials
	#when the function runs instead of grabbing them from Lambda.
	#That means you aren't using 1-to-1 testing because your test role
	#needs to grant a developer access to assume the role in the trust policy
	#- something you do not want in a production environment.
		if [ "$DEBUG" == "true" ]; then 

			echo "export AWS_SESSION_TOKEN=$AWS_SESSION_TOKEN"
			echo "export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID"
			echo "export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY"
			echo "export AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION"

		fi

  fi

}

get_creds


