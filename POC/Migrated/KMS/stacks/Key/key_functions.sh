#!/bin/bash -e
# KMS/stacks/Key/key_functions.sh 
# author: @tradichel @2ndsightlab
##############################################################

source ../../../Functions/shared_functions.sh

profile="KMS"

deploy_orgroot_key(){

	profile="OrgRoot"
	deploy_key $1 $2 $3 $4 $5

}

#note: must deploy with the key admin role assigned in the 
#template because that's what CloudFormation or KMS
#requires. There is some potentially faulty logic that 
#presumes the role deploying the key is also the
#adminsitrator of the key.
deploy_key(){
	      encryptarn="$1"
	      decryptarn="$2"
 	      keyalias="$3"
	      serviceusedwith="$4"
				creategrant="$5"
				servicescanencrypt="$6"
				servicescandecrypt="$7"
	      desc="$8"
				
        function=${FUNCNAME[0]}
				validate_param "encryptarn" "$encryptarn" "$function"
        validate_param "decryptarn" "$decryptarn" "$function"
	      validate_param "keyalias" "$keyalias" "$function"

	      template='cfn/Key.yaml'
        resourcetype='Key'
	      timestamp="$(date)"
        timestamp=$(echo $timestamp | sed 's/ //g')

        parameters=$(add_parameter "EncryptArnParam" $encryptarn)
        parameters=$(add_parameter "DecryptArnParam" $decryptarn "$parameters")
        parameters=$(add_parameter "KeyAliasParam" $keyalias "$parameters")
        parameters=$(add_parameter "TimestampParam" $timestamp "$parameters")

				if [ "$serviceusedwith" != "" ]; then 
          parameters=$(add_parameter "ServiceParam" $serviceusedwith "$parameters")
				fi

        if [ "$creategrant" == "true" ]; then
          parameters=$(add_parameter "CreateGrantAllowedParam" "true" "$parameters")
        fi

				if [ "$servicescanencrypt" != "" ]; then
        	parameters=$(add_parameter "EncryptServicesParam" $servicescanencrypt "$parameters")
				fi

        if [ "$servicescandecrypt" != "" ]; then
          parameters=$(add_parameter "DecryptServicesParam" $servicescandecrypt "$parameters")
        fi

        if [ "$desc" != "" ]; then
        	parameters=$(add_parameter "DescParam" "$desc" "$parameters")
				fi

	      echo "deploy_stack $profile $keyalias $resourcetype $template \"$parameters\""
	      deploy_stack $profile $keyalias $resourcetype $template "$parameters"

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
                                                                                     
