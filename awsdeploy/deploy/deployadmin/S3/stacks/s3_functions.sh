#!/bin/bash -e
# https://github.com/tradichel/SecurityMetricsAutomation
# S3/stacks/S3_functions.sh
# author: @teriradichel @2ndsightlab
##############################################################
source ../../Functions/shared_functions.sh

deploy_s3_bucket() {
 
  bucketnamesuffix="$1"
  kmskeyalias="$2"
	deploylogbucket="$3"
	kmskeyaliaslogs="$4"

  function=${FUNCNAME[0]}
  validate_param "bucketnamesuffix" "$bucketnamesuffix" $function
  validate_param "kmskeyalias" "$kmskeyalias" $function

  kmskeyid=$(get_key_id $kmskeyalias $profile)
  if [ "$kmskeyid" == "" ]; then
    echo "key not found for alias: $kmskeyalias"
    exit
  fi
	echo "Conents Key: $kmskeyid"

  bucketnamesuffix=$(echo $bucketnamesuffix | tr '[:upper:]' '[:lower:]')
  env=$(echo $env | tr '[:upper:]' '[:lower:]')

  template='cfn/Bucket.yaml'
  resourcetype='S3Bucket'

	#if log bucket specified, deploy it
	if [ "$deploylogbucket" == "true" ]; then

		if [ "$kmskeyaliaslogs" == "" ]; then 
			kmskeyidlogs = $kmskeyid
		else
  		kmskeyidlogs=$(get_key_id $kmskeyaliaslogs $profile)
  		if [ "$kmskeyidlogs" == "" ]; then
    		echo "key not found for alias: $kmskeyaliaslogs"
    		exit
 	 		fi
  	fi
		echo "Logs Key: $kmskeyidlogs"
	
    parameters=$(add_parameter "BucketNameSuffixParam" "$bucketnamesuffix-logs")
    parameters=$(add_parameter "KMSKeyIdParam" $kmskeyidlogs $parameters)
		parameters=$(add_parameter "DeployLogBucketParam" "false" $parameters)
    deploy_stack $profile $bucketnamesuffix $resourcetype $template "$parameters"

	else
		#in case not set at all
		deploylogbucket="false"
  fi
	
	#deploy the s3 bucket
  parameters=$(add_parameter "BucketNameSuffixParam" "$bucketnamesuffix")
  parameters=$(add_parameter "KMSKeyIdParam" $kmskeyid $parameters)
	parameters=$(add_parameter "DeployLogBucketParam" "$deploylogbucket" $parameters)
	deploy_stack $profile $bucketnamesuffix $resourcetype $template "$parameters"

}

deploy_s3_bucket_for_public_static_site(){
  domainname="$1"
	envparam="$2"

	kmskeyalias="$envparam-Apps"
	appname=$(echo $domainname | sed 's/\.//g')
	deploylogbucket="true"
	kmskeyaliaslogs=$kmskeyalias

	deploy_s3_bucket $appname $kmskeyalias $deploylogbucket $kmskeyaliaslogs

}

deploy_app_s3_bucket_policy(){
	bucketnamesuffix="$1"
	appname="$2"
  service="$3"
	readorwrite="$4"

  function=${FUNCNAME[0]}
	validate_param "bucketnamesuffix" "$bucketnamesuffix" $function
  validate_param "appname" "$appname" $function
	validate_param "service" "$service" $function
	validate_param "readorwrite" "$readorwrite" $function

	parameters=$(add_parameter "BucketNameSuffixParam" "$bucketnamesuffix")  
	parameters=$(add_parameter "AppNameParam" "$appname" "$parameters")
	parameters=$(add_parameter "ServiceParam" "$service" "$parameters")
	parameters=$(add_parameter "ReadOrWriteParam" "$readorwrite" "$parameters")

  template='cfn/Policy/AppBucketPolicy.yaml'
  resourcetype='S3BucketPolicy'
	policyname=$bucketname'AppBucketPolicy'

  deploy_stack $profile $policyname $resourcetype $template "$parameters"
	
}

get_key_id () {
	
  alias="$1"
  profile="$2"

  function=${FUNCNAME[0]}
  validate_param "alias" $alias $function
  validate_param "profile" $alias $function

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
                                                                                     
