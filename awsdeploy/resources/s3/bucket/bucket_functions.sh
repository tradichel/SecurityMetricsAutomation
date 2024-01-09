#!/bin/bash -e
# https://github.com/tradichel/SecurityMetricsAutomation
# resources/s3/bucket/bucket_functions.sh
# author: @teriradichel @2ndsightlab
##############################################################
source deploy/shared/functions.sh

deploy_bucket() {
 
  bucketname="$1"
  kmskeyid="$2"
	deploylogbucket="$3"
	kmskeyidlogs="$4"

  f=${FUNCNAME[0]}
  validate_var $f "bucketname" "$bucketname"
  validate_var $f "kmskeyid" "$kmskeyid"

	#bucket names are lowercase
  bucketnamesuffix=$(echo $bucketname | tr '[:upper:]' '[:lower:]')

  category='s3'
  resourcetype='bucket'

	#if log bucket specified, deploy it
	if [ "$deploylogbucket" == "true" ]; then
		
	 	validate_var $f "kmskeyidlogs" "$kmskeyidlogs"
    parameters=$(add_parameter "NameParam" "$bucketname-logs")
    parameters=$(add_parameter "KMSKeyIdParam" $kmskeyidlogs $parameters)
		parameters=$(add_parameter "DeployLogBucketParam" "false" $parameters)
    deploy_stack $bucketname $category $resourcetype "$parameters"

	else
		#in case not set at all
		deploylogbucket="false"
  fi
	
	#deploy the s3 bucket
  parameters=$(add_parameter "NameParam" "$bucketname")
  parameters=$(add_parameter "KMSKeyIdParam" $kmskeyid $parameters)
	parameters=$(add_parameter "DeployLogBucketParam" "$deploylogbucket" $parameters)
	deploy_stack $bucketname $category $resourcetype $parameters

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

  f=${FUNCNAME[0]}
	validate_var $f "bucketnamesuffix" "$bucketnamesuffix"
  validate_var $f "appname" "$appname"
	validate_var $f "service" "$service"
	validate_var $f "readorwrite" "$readorwrite"

	parameters=$(add_parameter "BucketNameSuffixParam" "$bucketnamesuffix")  
	parameters=$(add_parameter "AppNameParam" "$appname" "$parameters")
	parameters=$(add_parameter "ServiceParam" "$service" "$parameters")
	parameters=$(add_parameter "ReadOrWriteParam" "$readorwrite" "$parameters")

  category="s3"
	resourcetype='bucket'
	policyname=$env'-'$bucketname'appbucketpolicy'

  deploy_stack $policyname $category $resourcetype $parameters $policyname
	
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
                                                                                     
