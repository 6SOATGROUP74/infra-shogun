import json
import boto3
import os

def lambda_handler(event, context):
    print(event)
    body = json.loads(event['body'])
    username = body['cpf']
    email = body['email']
    
    client = boto3.client('cognito-idp')
    user_pool_id = os.environ['cognito_id']
    
    try:
        
        response = client.admin_create_user(
            UserPoolId=user_pool_id,
            Username=username,
            UserAttributes=[
                {
                    'Name': 'email',
                    'Value': email
                },
            ],
            MessageAction='SUPPRESS',
            TemporaryPassword='Temp@1234'  
        )
        
        return {
            'statusCode': 200,
            'body': json.dumps({'message': 'User registered successfully'})
        }
    except Exception as e:
        return {
            'statusCode': 400,
            'body': json.dumps({'error': str(e)})
        }