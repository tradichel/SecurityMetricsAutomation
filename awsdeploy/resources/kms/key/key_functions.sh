#/bin/bash -e
# KMS/stacks/Key/key_functions.sh 
# author: @tradichel @2ndsightlab
##############################################################

source deploy/shared/functions.sh
source deploy/shared/validate.sh

get_key_id(){
  alias="$1"
  
	#for some unknown reason you have to put alias/ in front of KMS aliases
	#almost everywhere you use them. Why, AWS, WHY???
  query='Aliases[?AliasName==`alias/'$alias'`].TargetKeyId'
  keyid=$(aws kms list-aliases --query $query --output text --profile $profile)

  echo $keyid
}

#note: must deploy with the key admin role assigned in the 
#template because that's what CloudFormation or KMS
#requires. There is some logic that 
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
				
				#the role calling the script in the admin
				adminarn=$(get_role_arn)

				function=${FUNCNAME[0]}
				validate_var $function "encryptarn" $encryptarn 
        validate_var $function "decryptarn" $decryptarn
	      validate_var $function "keyalias" $keyalias
				validate_var $function "adminarn" $adminarn

				cat='kms'
        resourcetype='key'
	      timestamp="$(date)"
        timestamp=$(echo $timestamp | sed 's/ //g')

        parameters=$(add_parameter "EncryptArnParam" "$encryptarn,$adminarn")
        parameters=$(add_parameter "DecryptArnParam" "$decryptarn,$adminarn" "$parameters")
        parameters=$(add_parameter "AdminArnParam" $adminarn "$parameters")
        parameters=$(add_parameter "KeyAliasParam" $keyalias "$parameters")
        parameters=$(add_parameter "TimestampParam" $timestamp "$parameters")

				if [ "$serviceusedwith" != "" ]; then 
          parameters=$(add_parameter "ServiceParam" $serviceusedwith $parameters)
				fi

        if [ "$creategrant" == "true" ]; then
          parameters=$(add_parameter "CreateGrantAllowedParam" "true" $parameters)
        fi

				if [ "$servicescanencrypt" != "" ]; then
        	parameters=$(add_parameter "EncryptServicesParam" $servicescanencrypt $parameters)
				fi

        if [ "$servicescandecrypt" != "" ]; then
          parameters=$(add_parameter "DecryptServicesParam" $servicescandecrypt $parameters)
        fi

        if [ "$desc" != "" ]; then
        	parameters=$(add_parameter "DescParam" "$desc" $parameters)
				fi

	      echo "deploy_stack $keyalias $cat $resourcetype $parameters"
	      deploy_stack $keyalias $cat $resourcetype $parameters

}

deploy_env_amikey(){
	orgid="$1"
	encryptou="$2"
	decryptou="$3"
	keyalias="$4"

  #the role calling the script in the admin
  adminarn=$(get_role_arn)

  function=${FUNCNAME[0]}
  validate_var $function "encryptou" $encryptou
  validate_var $function "decryptou" $decryptou
  validate_var $function "keyalias" $keyalias
  validate_var $function "adminarn" $adminarn

  cat='kms'
  resourcetype='key'
  timestamp="$(date)"
  timestamp=$(echo $timestamp | sed 's/ //g')

	parameters=$(add_parameter "OrganizationIdParam" "$orgid")
  parameters=$(add_parameter "EncryptArnParam" "$adminarn" $parameters)
  parameters=$(add_parameter "DecryptArnParam" "$adminarn" "$parameters")
  parameters=$(add_parameter "EncryptOuParam" "$encryptou" $parameters)
  parameters=$(add_parameter "DecryptOuParam" "$decryptou" "$parameters")
  parameters=$(add_parameter "AdminArnParam" $adminarn "$parameters")
  parameters=$(add_parameter "KeyAliasParam" $keyalias "$parameters")
  parameters=$(add_parameter "TimestampParam" $timestamp "$parameters")
	parameters=$(add_parameter "CreateGrantAllowedParam" "true" $parameters)

	echo "deploy_stack $keyalias $cat $resourcetype $parameters"
  deploy_stack $keyalias $cat $resourcetype $parameters
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
                                                                                     
