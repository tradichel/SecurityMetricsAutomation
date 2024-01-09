# SecurityMetricsAutomation

This code is associated with a series of blog posts. Please refer to these posts for more information:

[Automating Security Metrics](
https://medium.com/cloud-security/automating-cybersecurity-metrics-890dfabb6198).

# How I earn a living:

Hire me for a penetration test by contacting me on LinkedIn: [Penetration Testing](https://2ndsightlab.com/cloud-penetration-testing.html)

Have a question? 
Schedule a call with me through [ians research](https://www.iansresearch.com/)

The code is not for sale of for commercial use. If you'd like to license
the proprietary inventions contact me for more information on LinkedIn: [Teri Radichel]:(https://linkedin.com/in/teriradichel)

# About this code:

This code has evolved over the series of blog posts I've written to explore
topics in secure deployments in cloud environments, and most specifically
on AWS. BTW, I'm an AWS Security Hero, if you know what that is. :)

* /POC - code from initial posts testing initial concepts

* /awsdeploy - much better, revamped version where I'm migrating over the code

Note: None of this is complete or production ready. I'm still testing
various ideas. 

I've introduced the concept of Micro-temlpates throughout the series:
[Microtemplates](https://medium.com/cloud-security/cloudformation-micro-templates-ae70236ae2d1)

You can find the templates in the /awsdeploy/resources folder if you're looking
for a CloudFormation template that meets your needs or ideas for writing
your own templates for your own individual, non-commericial use.

This post gives a good overview of current iteration of the deployment process
which involves a container that requires MFA for AWS deployments:

[Deploying a Project Account on AWS](https://medium.com/cloud-security/configuring-a-new-project-account-one-job-many-templates-ba467bf19928)

Note that I tried to use a container on Lambda but I couldn't get
the MFA functionality working in a stricly private network where
all services are accessed via VPC Endpoints. Perhaps that will be
fixed and I will revisit later, but it seems that the container
appoach provides a bit better privacy at this point.

Note that the configuration is not completely secure. More work
needs to be done to secure all the components such as the 
container running this job and long term I will likely not 
use bash.

The code in the /awsdeploy directory consists of the following:

* /container - some scripts to handle various container tasks
* Dockerfile - used to deploy a container image that runs scripts and requires MFA.
* /deploy - containers scripts each role can run to deploy resources.
* /resources - CloudFormation temlpates organized in alignment with AWS documentation.
* /job - contains the run.sh script that runs when the container starts
* /job/run.sh - requires MFA code and executes specified script
* localtest.sh - script for local testing which asks for which script to run and code
* /userjobs - scripts included by localtest.sh to list jobs a role can execute.
* /gen_code - scripts to generate a new CloudFormation resource template and deploy scripts
* /ec2 - some proof of concept code to run the container on an EC2 instance

#################################################################################

Copyright Notice
All Rights Reserved.
All materials (the “Materials”) in this repository are protected by copyright 
under U.S. Copyright laws and are the property of 2nd Sight Lab, LLC. They are provided 
pursuant to a royalty free, perpetual license the person to whom they were presented 
by 2nd Sight Lab, LLC and are solely for the training and education by 2nd Sight Lab, LLC.

The Materials may not be copied, reproduced, distributed, offered for sale, published, 
displayed, performed, modified, used to create derivative works, transmitted to 
others, or used or exploited in any way, including, in whole or in part, as training 
materials by or for any third party.

The above copyright notice and this permission notice shall be included in all 
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A 
PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT 
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION 
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

################################################################################
