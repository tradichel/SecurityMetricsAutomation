#!/bin/bash -e
# https://github.com/tradichel/SecurityMetricsAutomation/
# Org/stacks/SCP/scp_functions.sh
# author: @teriradichel @2ndsightlab
# description: Functions for SCP deployment
##############################################################
source ../../../Functions/shared_functions.sh

profile="Governance"

deploy_orgroot_scp(){
   profile="OrgRoot"
   deploy_scp $1 $2
}

deploy_scp(){
   scpname=$1
   targetids=$2

  func=${FUNCNAME[0]}
  validate_param 'scpname' $name $func
  validate_param 'targetids' $targetids $func

  parameters=$(add_parameter "NameParam" $scpname)
  parameters=$(add_parameter "TargetIdsParam" $targetids $parameters)

  deploy_scp $scpname $parameters

}

deploy_allowregionsscp(){
   scpname=$1
   targetids=$2
	 regions=$3

  func=${FUNCNAME[0]}
  validate_param 'scpname' $name $func
  validate_param 'targetids' $targetids $func
  validate_param 'regions' $regions $func

  parameters=$(add_parameter "NameParam" $scpname)
  parameters=$(add_parameter "TargetIdsParam" $targetids $parameters)
  parameters=$(add_parameter "RegionsParam" $regions $parameters)

	deploy_scp $scpname $parameters

}

deploy_scp(){
	scpname=$1
	parameters=$2

  resourcetype='SCP'
  template='cfn/'$scpname'.yaml'
  deploy_stack $profile $scpname $resourcetype $template $parameters

}



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
