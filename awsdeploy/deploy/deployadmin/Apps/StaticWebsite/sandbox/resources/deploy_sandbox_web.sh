#!/bin/bash -e
# https://github.com/tradichel/SecurityMetricsAutomation
# Org/stacks/Apps/StaticWebsite/deploy_sandbox_web_account.sh
# author: @teriradichel @2ndsightlab
# Description: Deploy a Sandbox-Web account for testing
# static website deployments
##############################################################
cd ../../../../Org/stacks/Account
source account_functions.sh

deploy_account_w_ou_name 'Sandbox-Web' 'Sandbox'


