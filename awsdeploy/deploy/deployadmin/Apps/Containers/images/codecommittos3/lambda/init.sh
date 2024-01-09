#!bin/bash -e

#global functions used by all Lambda functions
source /lambda/credentials.sh
source /lambda/function_name.sh

init_function(){
	headers="$1"

	#must get creds before function name in test environment
	get_creds
	get_function_name $headers

}



