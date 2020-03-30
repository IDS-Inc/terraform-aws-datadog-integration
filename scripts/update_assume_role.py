import argparse
import boto3
import json

def assume_role(aws_account_number):

    # Beginning the assume role process for account
    sts_client = boto3.client('sts')

    # Get the current partition
    partition = sts_client.get_caller_identity()['Arn'].split(":")[1]

    response = sts_client.assume_role(
        RoleArn='arn:{}:iam::{}:role/{}'.format(
            partition,
            aws_account_number,
            'terraform_master'
        ),
        RoleSessionName='IAMTrustRelationship'
    )

    # Storing STS credentials
    session = boto3.Session(
        aws_access_key_id=response['Credentials']['AccessKeyId'],
        aws_secret_access_key=response['Credentials']['SecretAccessKey'],
        aws_session_token=response['Credentials']['SessionToken']
    )

    print("Assumed session for {}.".format(aws_account_number))

    return session

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Remove default networking')
    parser.add_argument('--account_id', type=str, required=True, help="AWS Account ID")
    parser.add_argument('--role_name', type=str, required=True, help="DataDog IAM Role name")
    parser.add_argument('--datadog_external_id', type=str, required=True, help="External ID for DataDog")
    args = parser.parse_args()

    role_name = args.role_name
    external_id = args.datadog_external_id

    session = assume_role(args.account_id)
    iam = session.client('iam')

    datadog_role = iam.get_role(RoleName=role_name)['Role']

    policy = datadog_role['AssumeRolePolicyDocument']
    policy['Statement'][0]['Condition'] = {'StringEquals': {'sts:ExternalId': external_id}}

    response = iam.update_assume_role_policy(
            RoleName=role_name,
            PolicyDocument=json.dumps(policy)
        )

    if response['ResponseMetadata']['HTTPStatusCode'] != 200:
        print(f"Couldn't add ExternalId to in policy\n{response}")
        exit(1)
    else:
        print(f"ExternalId updated for {role_name}")

