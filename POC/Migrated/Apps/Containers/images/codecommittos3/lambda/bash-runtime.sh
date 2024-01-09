#!/bin/sh -e

source /lambda/credentials.sh
source /lambda/function_name.sh

DEBUG="true"
REQUESTID=""
SCHEME=""
REQUESTID_TMP="$(mktemp)"

#local scheme http otherwise https
if [ "$AWS_LAMBDA_RUNTIME_API" == "127.0.0.1:9001" ]; then
	SCHEME="http"
else
	SCHEME="https"
fi

set -euo pipefail
source /lambda/errors.sh && set_trap

process_request(){
	while :
	do

		HEADERS="$(mktemp)"

  	# Get an event. The HTTP request will block until one is received
  	EVENT_DATA=$(curl -sS -LD "$HEADERS" "$SCHEME://${AWS_LAMBDA_RUNTIME_API}/2018-06-01/runtime/invocation/next")
    
  	# Extract request ID by scraping response headers received above
  	REQUESTID=$(grep -Fi Lambda-Runtime-Aws-Request-Id "$HEADERS" | tr -d '[:space:]' | cut -d: -f2)
	 	echo "$REQUESTID" > $REQUESTID_TMP
		echo "$(cat $REQUESTID_TMP | sed 's/\"//g')"

		#initialize neccessary values
	  get_function_name $HEADERS
	
		echo $FUNCTION_NAME

  	# Run the handler function from the script
  	RESPONSE=$($(echo "$_HANDLER" | cut -d. -f2) "$EVENT_DATA" "$HEADERS")
	
  	# Send the response
		curl "$SCHEME://${AWS_LAMBDA_RUNTIME_API}/2018-06-01/runtime/invocation/$REQUESTID/response"  -d "$RESPONSE"
		
    rm $HEADERS

	done

}

#Initialization - load function handler
#**** SECURITY NOTE *****
# Unlike the example in the AWS Documentation
# I am not going to allow a user to override 
# the working directory and function to 
# whatever they want inside the container.
# For now, the handler will always be in in 
# the following location
# ***********************
source /job/run.sh

process_request 2>&1 | tee $TMP

