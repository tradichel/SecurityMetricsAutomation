#!/bin/bash -e

source network_functions.sh

vpcprefix="NAT"
vpc=$vpcprefix'VPC'

privatesubnetname='NATVPCNATRouteSubnet'

service="SecretsManager"

#SecretsManager actions:
#https://docs.aws.amazon.com/service-authorization/latest/reference/list_awssecretsmanager.html
acct=$(aws sts get-caller-identity --profile SandboxAdmin --output text --profile $profile | cut -f1)
readprincipals="arn:aws:iam::$acct:role/dockertestLambdaRole"
readactions="secretsmanager:ListSecrets,secretsmanager:GetSecretValue"
readresources="*"
readallowdeny="Allow"
writeprincipals=""
writeactions="*"
writeresources="*"
writeallowdeny="Deny"

deploy_vpce_generic "$service" "secretsmanager" "$vpc" "$privatesubnetname" "$readprincipals" "$readactions" "$readresources" "$readallowdeny" "$writeprincipals" "$writeactions" "$writeresources" "$writeallowdeny"

service="STS"

#STS actions:
#https://docs.aws.amazon.com/service-authorization/latest/reference/list_awssts.html
acct=$(aws sts get-caller-identity --profile SandboxAdmin --output text --profile $profile | cut -f1)
readprincipals="arn:aws:iam::$acct:role/dockertestLambdaRole"
readactions="sts:get-caller-identity"
readresources="*"
readallowdeny="Allow"
writeprincipals=""
writeactions="*"
writeresources="*"
writeallowdeny="Deny"

deploy_vpce_generic "$service" "sts" "$vpc" "$privatesubnetname" "$readprincipals" "$readactions" "$readresources" "$readallowdeny" "$writeprincipals" "$writeactions" "$writeresources" "$writeallowdeny"


service="KMS"

#KMS actions:
#https://docs.aws.amazon.com/service-authorization/latest/reference/list_awskms.html
acct=$(aws sts get-caller-identity --profile SandboxAdmin --output text --profile $profile | cut -f1)
readprincipals="arn:aws:iam::$acct:role/dockertestLambdaRole"
readactions="kms:Decrypt"
readresources="*"
readallowdeny="Allow"
writeprincipals=""
writeactions="*"
writeresources="*"
writeallowdeny="Deny"

deploy_vpce_generic "$service" "kms-fips" "$vpc" "$privatesubnetname" "$readprincipals" "$readactions" "$readresources" "$readallowdeny" "$writeprincipals" "$writeactions" "$writeresources" "$writeallowdeny"

