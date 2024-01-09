#!/bin/bash -e
# https://github.com/tradichel/SecurityMetricsAutomation
# awsdeploy/deploy/networkadminrole/ec2_subnetnaclassociation_projectsubnetnaclassociation.sh
# author: @teriradichel @2ndsightlab
# Description: subnet nacl association for a project account
##############################################################
source resources/ec2/subnetnetworkaclassociation/subnetnetworkaclassociation_functions.sh
source resources/ec2/subnet/subnet_functions.sh
source resources/ec2/networkacl/networkacl_functions.sh
source deploy/shared/functions.sh
source deploy/shared/validate.sh

profile="$1"
region="$2"
env="$3"
parameters="$4"

echo "*****************************"
echo "Deploy ec2 projectsubnetnaclassociation"
echo "profile: $profile"
echo "region: $region"
echo "env: $env"
echo "parameters: $parameters"
echo "*****************************"

s="deploy/networkadminrole/ec2_subnetnaclassociation_projectsubnetnaclassociation.sh"
validate_set $s "profile" $profile
validate_set $s "region" $region
validate_environment $s $env
validate_set $s "parameters" $parameters

projectid=$(get_container_parameter_value $parameters "projectid")
validate_set $s "projectid" $projectid

naclname=$env'-'$projectid'vpcnacl'
naclid=$(get_networkacl_id $naclname)
validate_set $s "naclid from $naclname" $naclid

for (( i=1; i<=3; ++i )); do
	subnetname=$env'-'$projectid'vpcsubnet'$i
	subnetid=$(get_subnet_id $subnetname)
	validate_set $s "$subnetid from $subnetname" $subnetname
	assocname=$subnetname'naclassociation'
	deploy_subnetnetworkaclassociation $assocname $subnetid $naclid
done

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
