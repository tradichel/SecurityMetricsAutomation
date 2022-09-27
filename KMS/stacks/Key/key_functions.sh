#!/bin/bash -e
# KMS/stacks/Key/key_functions.sh 
# author: @tradichel @2ndsightlab
##############################################################

source ../../../Functions/shared_functions.sh

profile="KMS"

deploy_key(){

	encryptarn=$1
	decryptarn=$2
	keyalias=$3
	conditionservice=$4
	desc="$5"

  function=${FUNCNAME[0]}
  validate_param "desc" $desc $function
  validate_param "encryptarn" $encryptarn $function
  validate_param "decryptarn" $decryptarn $function
	validate_param "keyalias" $keyalias $function
  validate_param "conditionservice" $conditionservice $function
  
	template='cfn/Key.yaml'
  resourcetype='Key'
	timestamp="$(date)"
  timestamp=$(echo $timestamp | sed 's/ //g')

  parameters=$(add_parameter "EncryptArnParam" $encryptarn)
  parameters=$(add_parameter "DecryptArnParam" $decryptarn "$parameters")
  parameters=$(add_parameter "KeyAliasParam" $keyalias "$parameters")
  parameters=$(add_parameter "TimestampParam" $timestamp "$parameters")
  parameters=$(add_parameter "ServiceParam" $conditionservice "$parameters")
  parameters=$(add_parameter "DescParam" "$desc" "$parameters")

	deploy_stack $profile $profile $keyalias $resourcetype $template "$parameters"

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
                                                                                     
