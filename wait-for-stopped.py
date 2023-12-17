import os
import time
import boto3

INSTANCE_ID = os.environ['INSTANCE_ID']
EC2_CLIENT = boto3.client('ec2')

def main(event, context):
    while True:
        response = EC2_CLIENT.describe_instances(InstanceIds=[INSTANCE_ID])
        state = response['Reservations'][0]['Instances'][0]['State']['Name']
        if state == 'stopped':
            break
        time.sleep(5)
    return state
