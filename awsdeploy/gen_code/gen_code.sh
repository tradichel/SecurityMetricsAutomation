#!/bin/bash -e
# https://github.com/tradichel/SecurityMetricsAutomation
# awsdeploy/gen_code/gen_code.sh
# author: @teriradichel @2ndsightlab
# Description: Generate initial code for new resource types
##############################################################
source deploy/shared/validate.sh

rolename=""
resourcategory=""
resourcetype=""
resourcename=""
description=""

replace_vars(){
	f="$1"
	
  s=$(sed -i "s|{{filepath}}|$f|g" $f)
	s=$(sed -i "s|{{rolename}}|$rolename|g" $f)
  s=$(sed -i "s|{{resourcecategory}}|$resourcecategory|g" $f)
  s=$(sed -i "s|{{resourcetype}}|$resourcetype|g" $f)
  s=$(sed -i "s|{{resourcename}}|$resourcename|g" $f)
  s=$(sed -i "s|{{description}}|$description|g" $f)
	
}

echo "Process to add a new set of resource files for a resource type"
echo "Add the values that will be part of the file names:"
echo "deploy/[role]/[cat]_[type]_[name].sh:"
echo "resources/[cat]/[type]/[type]_functions.sh"
echo "resources/[cat]/[type]/[type.yaml"
echo ""
echo "Enter rolename that will deploy this resource:"
read rolename

echo "Enter resource category:"
read resourcecategory
	
echo "Enter resource type:"
read resourcetype

echo "Enter resource owner or container (app, account, resource name, etc.)"
read resourcename

echo "Enter description:"
read description

deployfile='deploy/'$rolename'/'$resourcecategory'_'$resourcetype'_'$resourcename'.sh'
echo "Do you want to add $deployfile?"
read a
if [ "$a" == "y" ]; then
	if [ -f "$deployfile" ]; then
		echo "The file $depoyfile already exists. Overwrite? (y)"
		read a
	fi
	if [ "$a" == "y" ]; then
		cat gen_code/header.txt gen_code/deploy.txt gen_code/footer.txt > $deployfile
		replace_vars $deployfile
		cat $deployfile
 	fi
fi

functionsfile='resources/'$resourcecategory'/'$resourcetype'/'$resourcetype'_functions.sh'
echo "Do you want to add a functions file: $functionsfile?"
read a
if [ "$a" == "y" ]; then
  if [ -f "$functionsfile" ]; then
    echo "The file $functionsfile already exists. Overwrite? (y)"
    read a
	 fi
   if [ "$a" == "y" ]; then
     cat gen_code/header.txt gen_code/functions.txt gen_code/footer.txt > $functionsfile
     replace_vars $functionsfile
     cat $functionsfile
	 fi
fi

echo "Do you want to add a CloudFormation template file? (y)"
read a
if [ "$a" == "y" ]; then
	echo "Use resource name as template name? (y)"
	read a

	if [ "$a" == "y" ]; then
		templatefile='resources/'$resourcecategory'/'$resourcetype'/'$resourcename'.yaml'
	else
		templatefile='resources/'$resourcecategory'/'$resourcetype'/'$resourcetype'.yaml'
	fi

	echo "Do you want to add the file: $templatefile?"
	read a
	if [ "$a" == "y" ]; then
  	if [ -f "$templatefile" ]; then
    	echo "The file $templatefile already exists. Overwrite? (y)"
    	read a
  	fi
  	if [ "$a" == "y" ]; then
     cat gen_code/header.txt gen_code/yaml.txt gen_code/footer.txt > $templatefile
     replace_vars $templatefile
     cat $templatefile
   fi
	fi
fi

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
