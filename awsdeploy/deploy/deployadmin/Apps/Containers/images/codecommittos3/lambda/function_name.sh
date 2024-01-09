#!/bin/bash -e

get_function_name(){
	headers="$1"
	
	if [[ -v FUNCTION_NAME ]]; then
		echo "Function name exists: $FUNCTION_NAME"; return
	fi
	
	#the documentation says this should exist but it does not inside a container function
	if [[ -v $AWS_LAMBDA_FUNCTION_NAME ]]; then
		echo "Get functiton name from environment variable"
		function_name=$(safe_string_alphanumeric_underscore_dash $AWS_LAMBDA_FUNCTION_NAME)
		FUNCION_NAME=$function_name; return
	fi

	echo "Getting function name from headers: $(cat $headers)"

	#get the function name from the ARN in the headers
	function_name=$(cat $headers | grep Lambda-Runtime-Invoked-Function-Arn | cut -d ':' -f8)

	#something odd goign on with the name here. Make sure we are only getting back expected characters
	#should validate all values anyway so maybe I'll make this a common function later
	function_name=$(safe_string_alphanumeric_underscore_dash $function_name)

	if [ "$function_name" == "test_function" ]; then
    function_name=$(aws sts get-caller-identity | grep UserId | cut -d ":" -f3 | sed 's/"//g' | sed 's/,//g')
		function_name=$(safe_string_alphanumeric_underscore_dash $function_name)
	fi

  export FUNCTION_NAME=$function_name

	echo "Got function name from headers: $FUNCTION_NAME"
	
}



