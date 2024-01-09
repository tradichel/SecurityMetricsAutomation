#!/bin/bash
if [ -z "${AWS_LAMBDA_RUNTIME_API}" ]; then
	echo "Executing Lambda Runtime Interface Emulator with parameter: $@"
	exec /usr/local/bin/aws-lambda-rie /rie-bash.sh $@
else
  exec /rie-bash.sh $@
fi






