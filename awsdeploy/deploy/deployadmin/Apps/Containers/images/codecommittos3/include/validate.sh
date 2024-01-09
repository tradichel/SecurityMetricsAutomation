#!/bin/bash

#validate that the value only has alphanumeric characters,
#dashes (-) or underscores (_).
validate_alphanumeric_underscore_dash_period(){
	v=$(echo "$1" | sed 's/[^[:alnum:]_-.]//g')

	if [ "$1" != "$v" ]; then

		>&2 echo "Invalid value. Must contain only alphanumeric characters, strings, dashes or periods."
		exit 1
	fi
}

#validate the value is set (not null, not empty string)
#first parameter is the value, 2nd parameter is the name
validate_set(){
	if [ "$1" == "" ] || [ "$1" == "null" ]; then
	    >&2 echo "Error: $2 value not set."
    	exit 1
	fi	
}

#validate that the string does not contain quotes
#note that this does not check for encoded characters
validate_no_quotes(){
  v=$(echo "$1" | sed "s/'//g" | sed 's/"//g' )

  if [ "$1" != "$v" ]; then
    >&2 echo "Invalid value. No quotes allowed."
    exit 1
  fi
}

#remove unsafe characters and return the result
safe_string_alphanumeric_underscore_dash(){
	ss=$(echo "$1" | sed "s/[^[:alnum:]_-]//g")
	echo $ss
}

safe_numeric(){
	n=$(echo "$1" | sed "s/[^[:digit:]]//g")
	echo $n
}

valdiate_length(){
	value="$1"
	length="$2"

	n=${#value}
	if [ "$n" !=  "$length" ]; then
     >&2 echo "Invalid length: $n. Should be $length"
    exit 1
	fi
}

