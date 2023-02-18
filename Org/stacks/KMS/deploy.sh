#!/bin/bash -e
# https://github.com/tradichel/SecurityMetricsAutomation
# KMS/stacks/Key/deploy.sh
# description: deploy initial KMS key in the mangaement account
# Executed in the organization's management account
###############################################################
source ../../../Functions/shared_functions.sh

echo "------Create a CLI profile named 'KMS' before running this script ---"
echo "------Key for Organization Root Secrets -----"

desc="OrgRootSecrets"
keyalias="OrgRootSecrets"
conditionservice="secretsmanager"

#get the encryption ARN for our key policy 
stack='ROOT-USER-OrgRoot'
exportname='OrgRootUserArnExport'
encryptarn=$(get_stack_export $stack $exportname)

#get the decryption ARN for our key policy 
stack='ROOT-USER-OrgRoot'
exportname='OrgRootUserArnExport'
decryptarn=$(get_stack_export $stack $exportname)

cd ../../../KMS/stacks/Key/
source key_functions.sh
deploy_orgroot_key $encryptarn $decryptarn $keyalias $conditionservice $desc
cd ../../../Org/stacks/KMS

echo "-----------  OrgRoot Key Alias -----------"
cd ../../../KMS/stacks/KeyAlias/
source keyalias_functions.sh
keyid=$(get_orgroot_key_id $keyalias)
deploy_orgroot_key_alias $keyid $keyalias
cd ../../../Org/stacks/KMS

################################################################################
# Copyright Notice
# All Rights Reserved.
# All materials (the “Materials”) in this repository are protected by copyright 
# under U.S. Copyright laws and are the property of 2nd Sight Lab. They are provided 
# pursuant to a royalty free, perpetual license the person to whom they were presented 
# by 2nd Sight Lab and are solely for the training and education by 2nd Sight Lab.
#
# The Materials may not be copied, reproduced, distributed, offered for sale, published, 
# displayed, performed, modified, used to create derivative works, transmitted to 
# others, or used or exploited in any way, including, in whole or in part, as training 
# materials by or for any third party.
#
# The above copyright notice and this permission notice shall be included in all 
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
# INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A 
# PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT 
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION 
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
################################################################################  
