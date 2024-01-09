#!/bin/bash
# https://github.com/tradichel/SecurityMetricsAutomation
# awsdepoy/job/run.sh
# author: @tradichel @2ndsightlab
# description: Script that runs when container executes
##############################################################
 
#include files
source /job/deploy/shared/validate.sh
source /job/deploy/shared/functions.sh

#main
	parameters="$1"
	rolename=$(get_container_parameter_value $parameters "rolename")
	access_key=$(get_container_parameter_value $parameters "accesskey")
	secret_key=$(get_container_parameter_value $parameters "secretaccesskey")
	session_token=$(get_container_parameter_value $parameters "sessiontoken")
	region=$(get_container_parameter_value $parameters "region")
	env=$(get_container_parameter_value $parameters "env")
	script=$(get_container_parameter_value $parameters "script")
	parameters=$(get_container_parameter_value $parameters "parameters")

	s="job/run.sh"
	validate_set $s $rolename "rolename"
	validate_set $s $access_key "access_key"
	validate_set $s $secret_key "secret_key"
	validate_set $s $session_token "session_token"
	validate_set $s $region "region"
	validate_environment $s $env
	validate_set $s $script "script"

  echo "### Creating profile for $rolename ###"
  aws configure set aws_access_key_id $access_key --profile $rolename
  aws configure set aws_secret_access_key $secret_key --profile $rolename
  aws configure set aws_session_token $session_token --profile $rolename
  aws configure set region $region --profile $rolename
  aws configure set output "json" --profile $rolename

  #clear variables
  access_key=""
  secret_key=""
  session_token=""

  echo "### Created AWS CLI profile: $rolename ###"
	aws sts get-caller-identity --profile $rolename
	
	cd /job/
	cmd=(./deploy/$rolename/$script $rolename $region $env $parameters)
	"${cmd[@]}"



