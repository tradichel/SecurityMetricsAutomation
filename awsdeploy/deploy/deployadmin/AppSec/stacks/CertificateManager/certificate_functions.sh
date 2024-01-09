#!/bin/bash -e
# https://github.com/tradichel/SecurityMetricsAutomation/
# AppSec/stacks/Certificates/certificate_functions.sh
# author: @teriradichel @2ndsightlab
# description: Functions to deploy tls certificates
##############################################################
source ../../../Functions/shared_functions.sh

deploy_certificate(){
  domain="$1"
	appname="$2"
	hostedzoneid="$3"

  func=${FUNCNAME[0]}
  validate_param "domainname" "$domain" "$func"
  validate_param "appname" "$appname" "$func"
	validate_param "hostedzoneid" "hostedzoneid" "$func"

  template='cfn/Certificate.yaml'
  parameters=$(add_parameter "DomainNameParam" "$domain")
	parameters=$(add_parameter "AppNameParam" "$appname" $parameters)
  parameters=$(add_parameter "HostedZoneIdParam" "$hostedzoneid" $parameters)
	
	resourcetype="TLSCertificate"
  deploy_stack $profile $appname $resourcetype $template $parameters

}




