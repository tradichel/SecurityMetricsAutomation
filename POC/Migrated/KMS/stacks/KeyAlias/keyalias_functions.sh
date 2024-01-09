#!/bin/bash -e
# https://github.com/tradichel/SecurityMetricsAutomation
# KMS/stacks/KeyAlias/keyalias_functions.sh
# author: @teriradichel @2ndsightlab
##############################################################
source ../../../Functions/shared_functions.sh

profile="KMS"

deploy_orgroot_key_alias(){
	profile="OrgRoot"
	deploy_key_alias $1 $2
}

deploy_key_alias(){

  keyid="$1"
  alias="$2"

  function=${FUNCNAME[0]}
  validate_param "keyid" "$keyid" "$function"
  validate_param "alias" "$alias" "$function"

	parameters=$(add_parameter "KeyIdParam" "$keyid")
  parameters=$(add_parameter "KeyAliasParam" $alias $parameters)
  template='cfn/KeyAlias.yaml'
  resourcetype='KeyAlias'
  	
	deploy_stack $profile $alias $resourcetype $template "$parameters"

}


get_orgroot_key_id () {
   profile="OrgRoot"
   get_key_id $1
}

get_key_id_by_alias() {
	alias="$1"
	get_key_id $1
}

get_key_id () {

	alias="$1"

  function=${FUNCNAME[0]}
  validate_param "alias" "$alias" "$function"

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
                                                                                     
