#!/bin/bash
source /validate.sh

get_secret_value(){

	key="$1"

	secret="$(aws secretsmanager get-secret-value --secret-id ${FUNCTION_NAME}Secret --query SecretString --output text)"
	value="$(echo $secret | jq -r ."$key")"
	validate_set $value "$key"
	validate_no_quotes $value
	echo $value

}

get_secret_value_for_profile(){

  key="$1"
	profile_name="$2"
	secret_name="$3"

  secret="$(aws secretsmanager get-secret-value --secret-id $secret_name --query SecretString --output text --profile $profile_name)"
  value="$(echo $secret | jq -r ."$key")"
  validate_set $value "$key"
  validate_no_quotes $value
  echo $value

}




