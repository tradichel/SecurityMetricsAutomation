#!bin/bash

#global functions used by all Lambda functions
source /credentials.sh
source /function_name.sh

init(){
	headers="$1"

	#must get creds before function name in test environment
	get_creds
	get_function_name $headers

}



