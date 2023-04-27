#!/bin/bash -e
# https://github.com/tradichel/SecurityMetricsAutomation
# S3/stacks/S3_functions.sh
# author: @teriradichel @2ndsightlab
##############################################################
source ../../../Functions/shared_functions.sh

deploy_s3_bucket() {
 
  profile="$1"
  bucketnamesuffix="$2"
  kmskeyalias="$3"

  function=${FUNCNAME[0]}
  validate_param "bucketnamesuffix" $bucketnamesuffix $function
  validate_param "kmskeyalias" $kmskeyalias $function
  validate_param "profile" $profile $function

  kmskeyid=$(get_key_id $kmskeyalias $profile)
  echo "Key: $kmskeyid"

  if [ "$kmskeyid" == "" ]; then
    echo "key not found for alias: $kmskeyalias"
    exit
  fi

  bucketnamesuffix=$(echo $bucketnamesuffix | tr '[:upper:]' '[:lower:]')
  profileparam=$(echo $profile | tr '[:upper:]' '[:lower:]')

  parameters=$(add_parameter "BucketNameSuffixParam" "$bucketnamesuffix")
  parameters=$(add_parameter "KMSKeyIdParam" $kmskeyid $parameters)
  parameters=$(add_parameter "ProfileParam" $profileparam $parameters)

  template='cfn/Bucket.yaml'
  resourcetype='S3Bucket'
  	
  deploy_stack $profile $bucketnamesuffix $resourcetype $template "$parameters"

}

get_key_id () {
	
  alias="$1"
  profile="$2"

  function=${FUNCNAME[0]}
  validate_param "alias" $alias $function
  validate_param "profile" $alias $function

  stack=$profile'-Key-'$alias
  exportname=$alias'KeyIDExport'
  keyid=$(get_stack_export $stack $exportname)

  echo $keyid

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
                                                                                     
