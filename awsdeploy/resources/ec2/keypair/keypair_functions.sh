#!/bin/bash -e
# https://github.com/tradichel/SecurityMetricsAutomation
# awsdeploy/resources/ec2/sshkey/sshkey_functions.sh
# author: @teriradichel @2ndsightlab
# Description: project user ssh key for ec2 instance in project account
##############################################################

source deploy/shared/functions.sh
source deploy/shared/validate.sh
source resources/secretsmanager/secret/secret_functions.sh

#####################
#This function presumes you have an existing secret named
#[env]-[username]-keypair-binary and 
#[env]-[username]-keypair-string
#that the principal calling the 
#function can access to store the keypair
#in the secret, including permission to use a 
#customer-managed key and the user that
#owns the key can access to retrieve the key
##################
deploy_keypair(){
	env="$1"
	username="$2"
	deleteexisting="$3" #optional - will not delete unless 'y'

	keyname=$env'-'$username'-keypair'
	secretnamebinary=$keyname'-binary'
	secretnametext=$keyname'-string'

  echo "--------------CREATE SSH KEY PAIR: $key-------------------"
  keys=$(aws ec2 describe-key-pairs --profile $profile)

	echo "Checking for existing keypair"
  if [[ "$keys" == *"$keyname"* ]]; then
    echo "Key pair found: $keyname"
    if [ $deleteexisting ]; then
			echo "Deleting and recreating key"
      aws ec2 delete-key-pair --key-name $keyname --profile $profile
    else
      return 0
    fi
  fi

  echo "Create new keypair"
  key=$(aws ec2 create-key-pair --key-name $keyname --profile $profile)
	filepath='/tmp/keypair.txt'
  echo $key | jq -r ".KeyMaterial" > $filepath
	
  set_secret_binary_value $secretnamebinary $filepath
  set_secret_textfile_value $secretnametext $filepath
}

deploy_keypair_with_cloudformation_if_you_must(){
	keypairname="$1"

	function=${FUNCNAME[0]}
  validate_var "$function" "keypairname" $keypairname

	cat="ec2"
  resourcetype="keypair"
 	
	p=$(add_parameter "NameParam" $keypairname)

  deploy_stack $name $cat $resourcetype $p
}

#################################################################################
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
