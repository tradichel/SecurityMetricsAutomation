#!/bin/bash

echo "Running /lambda/entry.sh"
source /lambda/init.sh

if [ -z "${AWS_LAMBDA_RUNTIME_API}" ]; then
	aws --version
	echo "Executing Lambda Runtime Interface Emulator with parameter: $@"
	exec /usr/local/bin/aws-lambda-rie /lambda/bash-runtime.sh $@
else
  exec /lambda/bash-runtime.sh $@
fi







