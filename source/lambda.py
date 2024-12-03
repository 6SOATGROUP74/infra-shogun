import logging

import boto3
from botocore.exceptions import ClientError
import json
from datetime import datetime
import os

client = boto3.client('cognito-idp')


def lambda_handler(event, context):

    username = event['headers'].get('documento')
    print(username)
    try:

        response = client.admin_get_user(
            UserPoolId=os.environ['cognito_id'],
            Username=username
        )
        
        
        response = generate_policy('user', 'Allow', event['methodArn'])
        
        print(response)
        
        return response

    except ClientError as e:
        return generate_policy('user', 'Deny', event['methodArn'])

def generate_policy(principal_id, effect, resource):

    arn_pattern = "/".join(resource.split("/")[:2]) + "/*/*"

    auth_response = {
        "principalId": principal_id
    }
    
    if effect and resource:
        auth_response["policyDocument"] = {
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Action": "execute-api:Invoke",
                    "Effect": effect,
                    "Resource": arn_pattern
                }
            ]
        }
    
    print(auth_response)
    return auth_response
