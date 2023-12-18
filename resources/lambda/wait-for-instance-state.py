import os
import time
import boto3

EC2_CLIENT = boto3.client('ec2')
SSM_CLIENT = boto3.client('ssm')

def main(event, context):
    desired_state = event['state']
    instance_id = event['instance_id']

    while True:
        ec2_response = EC2_CLIENT.describe_instances(InstanceIds=[instance_id])
        state = ec2_response['Reservations'][0]['Instances'][0]['State']['Name']

        ssm_response = SSM_CLIENT.describe_instance_information(Filters=[{'Key': 'InstanceIds', 'Values': [instance_id]}])
        reachable = True if ssm_response['InstanceInformationList'] else False

        if (desired_state == 'stopped' and state == 'stopped') \
        or (desired_state == 'running' and state == 'running' and reachable):
            break

        time.sleep(5)

    return state
