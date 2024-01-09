# IAM Roles and Policies

Note that the policies for Lambda functions and Batch Jobs are stored with the code for those resources. That's because the permisions are closely related to the functionality of those resources and an organization might have developers writing and changin those policies. They could also be stored here if an organization decides that developers should not be allowed to write policies for applications. It is also possible to limit the policies developers can write. For more infomration read and follow this blog series:

https://medium.com/cloud-security/automating-cybersecurity-metrics-890dfabb6198

The policies for user roles are in the cfn/Policy directory.
