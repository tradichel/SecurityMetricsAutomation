#!/bin/bash -e
# https://github.com/tradichel/SecurityMetricsAutomation/
# AppSec/stacks/Certificate/deploy.sh
# author: @teriradichel @2ndsightlab
# description Deploy certificates
##############################################################
source cloudfront_functions.sh

echo "An CLI Profile named AppSec is required to run this code."
profile="AppSec"

depoy_cloudfront "domain" etc.
