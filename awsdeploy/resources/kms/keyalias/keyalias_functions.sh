#!/bin/bash -e
# https://github.com/tradichel/SecurityMetricsAutomation
# KMS/stacks/KeyAlias/keyalias_functions.sh
# author: @teriradichel @2ndsightlab
##############################################################
source deploy/shared/functions.sh

deploy_keyalias(){

  keyid="$1"
  alias="$2"

  f=${FUNCNAME[0]}
  validate_var $f "keyid" $keyid
  validate_var $f "alias" $alias

	#if the key alias does not start with alias/ then add it
	prefix=$(echo $alias | cut -d '/' -f1)
	if [ "$prefix" != "alias/" ]; then alias='alias/'$alias; fi
	parameters=$(add_parameter "KeyIdParam" "$keyid")
  parameters=$(add_parameter "KeyAliasParam" $alias $parameters)
  category="kms"
  resourcetype='keyalias'
  	
	deploy_stack $alias $category $resourcetype $parameters

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
                                                                                     
