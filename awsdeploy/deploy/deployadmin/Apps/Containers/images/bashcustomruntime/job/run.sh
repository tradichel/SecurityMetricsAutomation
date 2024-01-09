#!/bin/bash -e

DEBUG="true"
source /include/secrets.sh
source /include/validate.sh

function run () {
  event="$1"
  headers="$2"

	env
	
	echo "success"

}


