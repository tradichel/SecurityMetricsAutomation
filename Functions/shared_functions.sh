# https://github.com/tradichel/SecurityMetricsAutomation
# Functions/share_functions.sh
# author: @teriradichel @2ndsightlab
##############################################################
validate_param(){

  name=$1
  value=$2
  func=$3

  if [ "$value" == "" ]; then
    echo 'Parameter '$name' must be provided to function '$func 1>&2
		exit 1
  fi

}

get_stack_export(){

  stackname=$1
  exportname=$2

	func=${FUNCNAME[0]}
	validate_param 'stackname' $stackname $func
  validate_param 'exportname' $exportname $func

  qry="Stacks[0].Outputs[?ExportName=='$exportname'].OutputValue"
  value=$(aws cloudformation describe-stacks --stack-name $stackname --query $qry --output text)

  echo $value

}

deploy_stack () {

  profile="$1"
	servicename="$2"
  resourcename="$3"
  resourcetype="$4"
  template="$5"
  parameters="$6"

  func=${FUNCNAME[0]}
  validate_param 'profile' $profile $func
  validate_param 'resourcename' $resourcename $func
  validate_param 'resourcetype' $resourcetype $func
  validate_param 'template' $template $func

	#not all stacks have parameters
  #validate_param 'parameters' $parameters $func
 
  stackname=$servicename'-'$resourcetype'-'$resourcename

  echo "-------------- $stackname -------------------"

	c="aws cloudformation deploy --profile $profile 
			--stack-name $stackname 
      --template-file $template "

  if [ "$servicename" == "IAM" ]; then
		 c=$c' --capabilities CAPABILITY_NAMED_IAM '
	fi

	if [ "$parameters" != "" ]; then 
  	echo "Parameters: $parameters"
  	c=$c' --parameter-overrides '$parameters
	fi

	echo $c

	($c)

}

deploy_iam_stack () {

  servicename="IAM"
	
  profile="$1"
  resourcename="$2"
  resourcetype="$3"
  template="$4"
  parameters="$5"

  deploy_stack $1 $servicename $2 $3 $4 $5

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
                                                                                     
