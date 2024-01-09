#!/bin/bash -e
# https://github.com/tradichel/SecurityMetricsAutomation
# resources/ec2/subnet/subnet_functions.sh
# author: @teriradichel @2ndsightlab
# description: deploy a VPC
##############################################################

source deploy/shared/functions.sh
source deploy/shared/validate.sh

deploy_subnetnetworkaclassociation(){
	assocname="$1"
	subnetid="$2"
	naclid="$3"

  f=${FUNCNAME[0]}
  validate_var $f "assocname" $assocname
  validate_var $f "subnetid" $subnetid
  validate_var $f "naclid" "$naclid"

	category="ec2"
	resourcetype='subnetnetworkaclassociation'
  timestamp="$(date)"
  t=$(echo $timestamp | sed 's/ //g')
  p=$(add_parameter "SubnetIdParam" $subnetid)
  p=$(add_parameter "NACLIdParam" $naclid $p) 
	p=$(add_parameter "TimestampParam" $t $p)

	deploy_stack $assocname $category $resourcetype $p
}

#  resourcetype='subnetroutetableassociation'
#  timestamp="$(date)"
#  t=$(echo $timestamp | sed 's/ //g')
#  p=$(add_parameter "SubnetIdExportParam" $subnetname)
#  p=$(add_parameter "RouteTableIdExportParam" $routetablename $p)
#  p=$(add_parameter "TimestampParam" $t $p)
#  deploy_stack $subnetname'routetableassociation' $category $resourcetype $p

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
