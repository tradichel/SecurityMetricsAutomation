#!/bin/bash -e
# https://github.com/tradichel/SecurityMetricsAutomation
# awsdeploy/deploy/orgadminrole/organizations_organizationalunit_all.sh
# author: @teriradichel @2ndsightlab
# Description: Deploy all organizational units
##############################################################
source resources/organizations/organizationalunit/organizationalunit_functions.sh
source deploy/shared/functions.sh
source deploy/shared/validate.sh

profile="$1"
region="$2"
env="$3"

logs=""

deploy_ous(){
	ous=("$@")

	first="true"
	
	for ou in "${ous[@]}";
		do
			#the first OU in the array is the parent ou
			if [ "$first" == "true" ]; then env="$ou"; fi
			./deploy/root-orgadminrole/organizations_organizationalunit_$ou.sh $profile $region $env &
			#we have to wait for the parent OU to compete before we can deploy the child OUs in parallel
			if [ "$first" == "true" ]; then wait; first="false"; fi
		done
}

#have to deploy the orgamin ou before can deploy the child ous
#so for each branch in the tree we have a single array
#where the first element is the parent and the name of the environment

#orgadmin ou and children
ous=("org" "governance" "security" "deploy" "backup")
deploy_ous "${ous[@]}"

#nonrpod is under deploy so have to wait until deploy 
#is ready - could write some more complicated code here
#to check the status of the deploy OU but the time
#is not that excessive
wait

#nonprod ou and children under org-deploy
ous=("nonprod" "resources" "engineering" "projects" "apps" "backup")
deploy_ous "${ous[@]}"

#wait for stacks to complete
wait

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
