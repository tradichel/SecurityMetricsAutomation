#!/bin/sh
# https://github.com/tradichel/SecurityMetricsAutomation
# Delete/delete.sh
# author: @teriradichel @2ndsightlab
####################################################################

source ./delete_functions.sh

echo "For each question answer: y to confirm, any key for skip or no, Ctrl-C to exit."; read ok
echo "Do you have a profile named 'delete' with permission to delete everything except KMS keys?"; read ok
echo "Do you have a profile named 'KMS' that is allowed to schedule deletion of your KMS keys?"; read ok
echo "Confirm every individual stack prior to deletion?"; read confirm
if [ "$confirm" != "y" ]; then confirm="n"; fi


#TODO:
#Not deleting EIP yet so I don't have to change my local firewall rules
#Have not added deletion of all the network stacks yet

eipassocstacks=('Network-EIPAssociation-RemoteAccessEIPId')
delete_stacks eipassocstacks[@] "EIP Association" $confirm

ec2stacks=('AppDeploy-EC2-Developer')
delete_stacks ec2stacks[@] "ec2" $confirm

batchstacks=('AppSec-Policy-BatchDeployJobCredentialsPolicy'
             'IAM-Role-DeployJobCredentialsIAMBatchRole')
delete_stacks batchstacks[@] "batch" $confirm

lambdastacks=('AppDeploy-Lambda-GenerateBatchJobId'
							'IAM-Role-GenerateBatchJobIdLambdaRole'
							'IAM-Role-TriggerBatchJobLambdaRole')
delete_stacks lambdastacks[@] "lambda" $confirm

iamsecretstacks=('IAM-Policy-DeveloperUserSecretPolicy'
          'IAM-Policy-TriggerBatchJobLambdaPolicy'
          'IAM-Policy-GenerateBatchJobIdPolicy'
          'IAM-Policy-DeployBatchJobCredentialsIAMJobPolicy')
delete_stacks iamsecretstacks[@] "Secret IAM policy" $confirm

secretstacks=('AppSec-SecretResourcePolicy-SecretResourcePolicy' 
						  'deploycreds-Secret-IAMBatchJobCredentials' 
							'deploycreds-Secret-BatchJobCredentials'
							'AppSec-Policy-BatchDeployJobCredentialsPolicy'
							'AppSec-Secret-Developer')
delete_stacks secretstacks[@] "secrets" $confirm

kmspolicystacks=('IAM-Policy-IAMAdminsGroupRoleKMSPolicy'
								 'IAM-Policy-AppSecGroupRoleKMSPolicy'
								 'IAM-Policy-GroupRunEC2FromConsolePolicy'
								 'IAM-Policy-AppDeploymentGroupRoleKMSPolicy')
delete_stacks kmspolicystacks[@] "KMS IAM policy" $confirm

keys=('DeveloperEC2'
			'DeveloperSecrets' 
			'TriggerBatchJob' 
			'BatchJobCredentials' 
			'DeveloperComputeResources')
delete_kms_keys keys[@] $confirm

delete_kms_admins

echo "TODO: Networking deletion not implemented"
#networkstacks=('IAM-Policy-VPCFlowLogsPolicy')
#delete_stacks $networkstacks "network" $profile

profiles=('IAMAdmins' 
          'NetworkAdmins' 
          'Developers' 
          'BatchAdmins' 
          'AppDeployment' 
          'AppSec' 
          'SecurityMetricsOperators')

delete_iam_profiles profiles[@] $confirm

echo "TODO: User deletion not implemented"

echo "Process Complete"

