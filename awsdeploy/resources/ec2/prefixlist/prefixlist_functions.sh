#!/bin/bash -e
# https://github.com/tradichel/SecurityMetricsAutomation
# resources/ec2/vpc/prefixlist_functions.sh
# author: @teriradichel @2ndsightlab
# description: deploy a VPC
##############################################################

source deploy/shared/functions.sh
source deploy/shared/validate.sh
source resources/ec2/routetable/routetable_functions.sh

#for testing
get_github_ips(){

		api_line=$(curl -s https://api.github.com/meta --ipv4 | grep -n 'api' | cut -d ":" -f1 | head -1)
		pkg_line=$(curl -s https://api.github.com/meta --ipv4 | grep -n 'packages' | cut -d ":" -f1 | head -1)
		lines=$(( $pkg_line - $api_line ))

		echo $api_line
		echo $pkg_line
		echo $lines
		if [ "$lines" == "0" ]; then "echo invalid number of lines"; exit; fi

    ips=$(curl -s https://api.github.com/meta --ipv4 |
       grep 'api' -A $lines | sort | uniq |
       grep "/" | grep "\." | sed 's/"//g' | sed 's/ //g' | sed 's/,//g')

		c=0
		for ip in $ips
  	do
			c=$(($c + 1))
		done
		echo "$c ip addresses"
		echo $ips

}

deploy_github_prefix_list() {

  listname="GithubPrefixList"
	entries=""
	template="cfn/PrefixList-Github.yaml"
	
	if [ -f "$template" ]; then rm $template; fi

  api_line=$(curl -s https://api.github.com/meta --ipv4 | grep -n 'api' | cut -d ":" -f1 | head -1)
  pkg_line=$(curl -s https://api.github.com/meta --ipv4 | grep -n 'packages' | cut -d ":" -f1 | head -1)
  lines=$(( $pkg_line - $api_line ))
  if [ "$lines" == "0" ]; then "echo invalid number of lines. GitHub API Failed"; exit; fi

  ips=$(curl -s https://api.github.com/meta --ipv4 |
     grep 'api' -A $lines | sort | uniq |
     grep "/" | grep "\." | sed 's/"//g' | sed 's/ //g' | sed 's/,//g')

	for ip in $ips
	do
  	entries=$entries'        - Cidr: '$ip$'\\\n'
		entries=$entries$'          Description: github-git\\\n'
	done

	cat cfn/PrefixList.tmp | \
  sed 's*\[\[name\]\]*'$listname'*g'  | \
	sed 's*\[\[ips\]\]*'"$entries"'*' >> $template

	p=""
	resourcetype='PrefixList'
  deploy_stack $profile $listname $resourcetype $template "$p"

}

#get the s3 prefix list for the current region
get_s3_prefix_list(){
	echo $(aws ec2 describe-managed-prefix-lists --filters Name=owner-id,Values=AWS --output text --profile $profile | grep s3 | cut -f5)
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
