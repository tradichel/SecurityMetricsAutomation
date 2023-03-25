#!/bin/bash -e
# https://github.com/tradichel/SecurityMetricsAutomation/
# Org/stacks/SCP/deploy_root_scps.sh
# author: @teriradichel @2ndsightlab
# description: SCPs deployed by root user of an AWS Organization
# The corresponding user is OrgRoot in this repository.
##############################################################
source scp_functions.sh
source ../Organization/org_functions.sh

echo "An CLI Profile named OrgRoot is required to run this code."

###
#root OU SCPS
### 
deploy_allowedregions
deploy_denyaddaccounttoroot

#later
#scpname="DenyRoute53Domains"
#deploy_root_scp $scpname

###
#DenyAll OU SCPs
###
ouname="DenyAll"
targets=$(get_ou_id $ouname)
scpname="DenyAll"
deploy_scp $scpname $targets

###
# Governance OU SCPs
###
ouname="Governance"
targets=$(get_ou_id $ouname)

scpname="DenyLeaveOrganization"
deploy_scp $scpname $targets

scpname="DenyRootActions"
deploy_scp $scpname $targets

###
# Suspended OU SCPS (Close Account)
###

ouname="Suspended"
targets=$(get_ou_id $ouname)

scpname="DenyAllButCloseAccount"
deploy_scp $scpname $targets

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
