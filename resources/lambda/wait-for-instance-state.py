import time
import boto3

EC2_CLIENT = boto3.client('ec2')
SSM_CLIENT = boto3.client('ssm')

def main(event, context):
    desired_state = event['state']
    instance_ids = event['instance_ids']

    while True:
        ec2_response = EC2_CLIENT.describe_instances(InstanceIds=instance_ids)
        states = [ x['State']['Name'] for x in ec2_response['Reservations'][0]['Instances'] ]

        ssm_response = SSM_CLIENT.describe_instance_information(Filters=[{'Key': 'InstanceIds', 'Values': instance_ids}])
        reachable_instances = len(ssm_response['InstanceInformationList'])

        if (
            desired_state == 'stopped' and
            all(x == 'stopped' for x in states) and
            reachable_instances == 0
        ) or (
            desired_state == 'running' and
            all(x == 'running' for x in states) and
            reachable_instances == len(instance_ids)
        ):
            break

        time.sleep(5)
