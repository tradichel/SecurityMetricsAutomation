#!/bin/sh

client_state="INIT"

send_error(){
  exit_code="$?"
  if [ "$exit_code" != "0" ]; then

    error_message="An error $1 has occurred on line $2. Exit code $exit_code"
		error_type="$client_state Error"
 		ERROR="{\"errorMessage\" : \"$error_message\", \"errorType\" : \"$error_type\"}"

    if [ "$client_state" == "INIT" ]; then
        echo "Call AWS Lambda Initialization Error API"
				curl "http://${AWS_LAMBDA_RUNTIME_API}/2018-06-01/runtime/init/error" -d "$ERROR" --header "Lambda-Runtime-Function-Error-Type: Unhandled"
        exit
    fi
    
		#if we haven't exited yet we have a process error
		curl "http://${AWS_LAMBDA_RUNTIME_API}/2018-06-01/runtime/invocation/$REQUEST_ID/error" -d "$ERROR" --header "Lambda-Runtime-Function-Error-Type: Unhandled"
    exit

  fi
}

trap 'send_error $? $LINENO' ERR SIGTERM SIGKILL SIGINT SIGHUP SIGQUIT SIGILL SIGABRT SIGSYS SIGFPE SIGPIPE SIGSEGV EXIT

set -euo pipefail

#Initialization - load function handler
#**** SECURITY NOTE *****
# Unlike the exmaple in the AWS Documentation
# I am not going to allow a user to override 
# the working directory and function to 
# whatever they want inside the container.
# For now, the hanler will always be in in 
# the following location
# ***********************
source /home/functions/handler.sh

while :
do

  HEADERS="$(mktemp)"
  
  # Get an event. The HTTP request will block until one is received
  EVENT_DATA=$(curl -sS -LD "$HEADERS" "http://${AWS_LAMBDA_RUNTIME_API}/2018-06-01/runtime/invocation/next")
		
  # Extract request ID by scraping response headers received above
  REQUEST_ID=$(grep -Fi Lambda-Runtime-Aws-Request-Id "$HEADERS" | tr -d '[:space:]' | cut -d: -f2)

	# Processing error once we have a Request ID
	client_state="PROCESS"

  # Run the handler function from the script
  RESPONSE=$($(echo "$_HANDLER" | cut -d. -f2) "$EVENT_DATA" "$HEADERS")
  
	# Send the response
  curl "http://${AWS_LAMBDA_RUNTIME_API}/2018-06-01/runtime/invocation/$REQUEST_ID/response"  -d "$RESPONSE"

done





