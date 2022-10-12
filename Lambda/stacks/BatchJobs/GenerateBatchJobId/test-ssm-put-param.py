#!/bin/python3
import boto3
ssm = boto3.client('ssm')

param_name="TestParameter"
param_value="TestValue"
param_type="SecureString"

#using AWS default encrypt (type=SecureString)
ssm.put_parameter(Name=param_name,Value=param_value,Type=param_type) 
val = ssm.get_parameter(Name=param_name, WithDecryption=True)

print(val)
