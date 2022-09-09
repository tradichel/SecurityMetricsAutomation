# SecurityMetricsAutomation

This code is associated with a series of blog posts. Please refer to these posts for more information:

[Automating Security Metrics](
https://medium.com/cloud-security/automating-cybersecurity-metrics-890dfabb6198).

If you found this code and/or the associated blog posts helpful, please consider buying my first cybersecurity book where I introduce security metrics you may want to track and the concept of automated cybersecurity metric reporting to assess cybersecurity risk.

[Cybersecurity for Executives in the Age of Cloud](https://amzn.to/3viUgXC)

If you would like to use the material or software in this repository for training, presentations, publishing, or any other commercial use, please contact Teri Radichel, CEO of 2nd Sight Lab, LLC for a license agreement.

Got a question? Schedule a call with me through [IANS Research](https://www.iansresearch.com/).

Thank you!

About this code:

This code creates a framework for running AWS Batch Jobs (a working progress) that will hopefully require MFA to executewhen we are done. Not only does this code execute batch jobs the blog series walks through the architectural decisions to set up a security cloud environment with segregation of duties, zero trust networking, encryption, and eventually proper networking and organizational policies.

Note that this framework does not use SSO due to limitations explained in the blog series, nor does it use a Yubikey for MFA due to the increase attack vectors also explained in the blog series.

Testing the code:

1. Create an AWS CLI profile named "iam" that has permission to use CoudForamtion and create IAM resources.

[Using an AWS CLI Profile with MFA](
https://medium.com/cloud-security/using-an-aws-cli-profile-with-mfa-a1ca79289031
)

2. Run the test.sh scirpt in the root directory. When it asks you if you have set up a kms profile, hit Ctrl-C to exit.

3. Add a virtual MFA device to the users created by the test script. At the time of this writing IAMAdmin and KMSAdmin are in use but in the future all users created by the test script will need MFA.

4. Modify your iam AWS CLI profile to use credentials and MFA from the IAMAdmin user created by the test script.

5. Set up an AWS CLI profile name "kms" using the MFA and credentials from the KMSAdmin user created by the script.

6. Execute the test.sh script again and continue through all the tests.

 
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
