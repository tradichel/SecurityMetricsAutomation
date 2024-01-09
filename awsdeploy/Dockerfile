# https://github.com/tradichel/SecurityMetricsAutomation
# awsdepoy/Dockerfile
# author: @tradichel @2ndsightlab
# description: Builds the image with all the code to deploy
# AWS resources in a consistent manner with a container
# that requires MFA to execute if you require MFA for role
# assumption - which the admin templates in this codebase do
##############################################################

FROM public.ecr.aws/amazonlinux/amazonlinux:2023

#update the container and install packages
RUN yum update -y
RUN yum install git -y
RUN yum install unzip -y
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o "awscliv2.zip"
RUN unzip awscliv2.zip
RUN ./aws/install
RUN aws --version
RUN yum remove unzip -y
RUN yum install python3-pip -y
RUN pip3 --version
RUN pip3 install --user setuptools
RUN pip3 install --user git-remote-codecommit
RUN yum remove python3-pip -y
RUN yum install jq -y

WORKDIR /job
Copy job/ /job/
COPY resources/ /job/resources/
COPY deploy /job/deploy/
COPY userjobs /job/userjobs/
RUN chmod -R 755 /job

ENTRYPOINT ["/job/run.sh"]
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

