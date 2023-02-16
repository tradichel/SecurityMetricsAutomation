#!/bin/bash -e
# VMs/stacks/vm_functions.sh 
# author: @tradichel @2ndsightlab
##############################################################

source ../../Functions/shared_functions.sh

profile="AppDeploy"

get_latest_ami(){

	arch="$1"

	if [ "$arch" == "" ]; then arch="arm64"; fi
	
	if [ "$arch" == "arm64" ]; then
		#get latest linux arm ami
		param='ami.linux.arm.base.baseami.arm64'
		ami=$(aws ec2 describe-images \
    	--owners amazon \
    	--filters "Name=name,Values=amzn2-ami-hvm*" \
      	 "Name=root-device-type,Values=ebs" \
       		"Name=architecture,Values=$arch" \
    	--query 'Images[*].[ImageId,CreationDate,Name]' \
    	--output text \
    	| sort -r -k2 | head -1 | cut -f1)
		ami=$(echo $ami | sed 's/ //g')
		echo $ami
		exit
	fi
	
	echo 'Architection '$arch' is not handled by this function' 1>&2
  exit 1

}

deploy_developer_vm(){
  user="$1"
  ec2type="$2"
	ami=$3

	#get the security group ids for our developer VM

	stack='Network-SecurityGroup-RemoteAccessPublicVPC-SSH'-$user
	exportname='RemoteAccessPublicVPC-SSH-'$user
	remote_access_sg=$(get_stack_export $stack $exportname)

  stack='Network-SecurityGroup-RemoteAccessPublicVPC-Github'
  exportname='RemoteAccessPublicVPC-Github'
  github_sg=$(get_stack_export $stack $exportname)

  stack='Network-SecurityGroup-RemoteAccessPublicVPC-S3'
  exportname='RemoteAccessPublicVPC-S3'
  s3_sg=$(get_stack_export $stack $exportname)

  stack='Network-SecurityGroup-RemoteAccessPublicVPC-VPCEndpointAccess'
  exportname='RemoteAccessPublicVPC-VPCEndpointAccess'
  vpce_sg=$(get_stack_export $stack $exportname)

	sgids=$remote_access_sg','$s3_sg','$github_sg','$vpce_sg

	echo 'Developer security groups: '$sgids
	
	deploy_vm $user $ec2type $ami $sgids

}

deploy_vm(){

	user="$1"
	ec2type="$2"
	ami="$3"
	sgids="$4"

  function=${FUNCNAME[0]}
  validate_param "user" $user $function
  validate_param "ec2type" $ec2type $function
  validate_param "ami" $ami $function
	validate_param "sgids" $sgids $function

	template='cfn/UserVM.yaml'
  resourcetype='EC2'

  parameters=$(add_parameter "NameParam" $user)
  parameters=$(add_parameter "AMIParam" $ami "$parameters")
  parameters=$(add_parameter "InstanceTypeParam" $ec2type "$parameters")
  parameters=$(add_parameter "SecurityGroupIdsParam" "$sgids" "$parameters")

	deploy_stack $profile $user $resourcetype $template "$parameters"

	stack="AppDeploy-EC2-$user"
	exportname="$user-$ami"
	id=$(get_stack_export $stack $exportname)
	stop_vm $id
}

stop_vm () {

	id="$1"

	echo "Stop instance ID: $id (y to stop)"?
	read ok

	if [ "$ok" == "y" ]; then
		aws ec2 stop-instances --instance-ids $id
	fi
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
                                                                                     
