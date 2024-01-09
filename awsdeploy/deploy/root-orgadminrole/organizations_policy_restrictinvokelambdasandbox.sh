#!/bin/bash
echo "source"

source scp_functions.sh

echo "source"

source ../Organization/organization_functions.sh

###
# Restrict Lambda invokation in Sandbox
###


ouname="Sandbox"
echo "get ou id"
dig organizations.xx-xxxx-x.amazonaws.com
targets=$(get_ou_id $ouname)
echo "$targets"

scpname="RestrictInvokeLambdaSandbox"
echo "Deploy SCP"
deploy_scp $scpname $targets
