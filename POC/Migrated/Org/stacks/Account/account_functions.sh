#!/bin/bash -e
# https://github.com/tradichel/SecurityMetricsAutomation/
# Org/stacks/Account/account_functions.sh
# author: @teriradichel @2ndsightlab
# description: Functions for account creation
##############################################################

source ../../../Functions/shared_functions.sh
source ../Organization/organization_functions.sh

profile="OrgRoot"

deploy_account_w_ou_name(){

	accountname="$1"
	ouname="$2"
	
	ouid=$(get_ou_id $ouname)
	
	deploy_account $accountname $ouid

}


#default OU is DenyAll so OU may not be passed in
deploy_account() {

	accountname="$1"
	ou_id="$2"

	function=${FUNCNAME[0]}
  validate_param "accountname" "$accountname" "$function"
	
  template="cfn/Account.yaml"
  resourcetype='Account'
  parameters=$(add_parameter "NameParam" $accountname)
	
	if [ "$ou_id" != "" ]; then
		parameters=$(add_parameter "ParentIdsParam" $ou_id $parameters)
	fi

	deploy_stack $profile $accountname $resourcetype $template $parameters
	
}

get_account_ou(){
	accountid="$1"

  function=${FUNCNAME[0]}
  validate_param "accountid" "$accountid" "$function"

	ouid=$(aws organizations list-parents --child-id $accountid --output text --query 'Parents[0].Id' --profile OrgRoot)
	echo $ouid
}

move_account(){
	accountid="$1"
	ou_from="$2"
	ou_to="$3"

  function=${FUNCNAME[0]}
  validate_param "accountid" "$accountid" "$function"
  validate_param "ou_from" "$ou_from" "$function"
  validate_param "ou_to" "$ou_to" "$function"

	echo "Move $accountid from $ou_from to $ou_to"
  aws organizations move-account --account-id $accountid --source-parent-id $ou_from --destination-parent-id $ou_to --profile $profile
}

get_account_number_by_account_name_and_cf_stack(){
  accountname=$1

  profile='OrgRoot'
  stack='OrgRoot-Account-'$accountname
  exportname=$accountname'Account'
  acctnum=$(get_stack_export $stack $exportname)

  echo $acctnum
}

get_account_number_by_account_name(){
	account_name=$1

  function=${FUNCNAME[0]}
  validate_param "account_name" "$account_name" "$function"

	accountid=$(aws organizations list-accounts --query 'Accounts[?Name == `'$account_name'`].Id' --output text --profile $profile)
  echo $accountid

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
