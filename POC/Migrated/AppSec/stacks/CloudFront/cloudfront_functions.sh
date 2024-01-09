#!/bin/bash -e
# https://github.com/tradichel/SecurityMetricsAutomation/
# AppSec/stacks/Certificates/certificate_functions.sh
# author: @teriradichel @2ndsightlab
# description: Functions to deploy tls certificates
##############################################################
source ../../Functions/shared_functions.sh

validate_certificate(){
  hostedzoneid="$1"
	domainname="$2"

  func=${FUNCNAME[0]}
  validate_param "hostedzoneid" "$hostedzoneid" "$func"
  validate_param "domainname" "$domainname" "$func"

  template='cfn/Certificate.yaml'
  parameters=$(add_parameter "hostedzoneid" $hostedzoneid)
  parameters=$(add_parameter "domainname" $domainname $parameters)
  deploy_stack $profile $secretname $resourcetype $template $parameters

}


deploy_certificate(){
  domainame="$1"

  func=${FUNCNAME[0]}
  validate_param "domainname" "$domainname" "$func"

  template='cfn/Certificate.yaml'
  parameters=$(add_parameter "domainname" $domainname $parameters)
  deploy_stack $profile $secretname $resourcetype $template $parameters
}
