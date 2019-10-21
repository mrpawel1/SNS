import boto3
import os
from botocore.exceptions import ClientError

# Replace sender@example.com with your "From" address.
# This address must be verified with Amazon SES.
SENDER = os.environ.get("SENDER")

# Replace recipient@example.com with a "To" address. If your account
# is still in the sandbox, this address must be verified.
RECIPIENT = os.environ.get("RECIPIENT")

# Specify a configuration set. If you do not want to use a configuration
# set, comment the following variable, and the
# ConfigurationSetName=CONFIGURATION_SET argument below.
CONFIGURATION_SET = "ConfigSet"

# If necessary, replace us-west-2 with the AWS Region you're using for Amazon SES.
AWS_REGION = os.environ.get("REGION")

# The subject line for the email.
SUBJECT = os.environ.get("SUBJECT")

# The character encoding for the email.
CHARSET = "UTF-8"

# Create a new SES resource and specify a region.
client = boto3.client('ses', region_name=AWS_REGION)


# Try to send the email.
def handler(event, context):
    try:
        # Provide the contents of the email.
        print("event: ".format(event))
        response = client.send_email(
            Destination={
                'ToAddresses': [
                    RECIPIENT,
                ],
            },
            Message={
                'Body': {
                    'Html': {
                        'Charset': CHARSET,
                        'Data': """<html>
<head></head>
<body>
  <h1>File on S3 created</h1>
  <p>Bucket name: <b>{bucket}</b><br>
  File name: <b>{file}</b><br>
  File size: <b>{size}</b></p>
</body>
</html>
                        """.format(
                            bucket=event['Records'][0]['s3']['bucket']['name'],
                            file=event['Records'][0]['s3']['object']['key'],
                            size=event['Records'][0]['s3']['object']['size']
                        )
                    },
                    'Text': {
                        'Charset': CHARSET,
                        'Data': "File on S3 created\r\n"
                                "Bucket name: {bucket}"
                                "File name: {file}"
                                "File size: {size}".format(
                                                            bucket=event['Records'][0]['s3']['bucket']['name'],
                                                            file=event['Records'][0]['s3']['object']['key'],
                                                            size=event['Records'][0]['s3']['object']['size']
                                                            ),
                    },
                },
                'Subject': {
                    'Charset': CHARSET,
                    'Data': SUBJECT,
                },
            },
            Source=SENDER,
            # If you are not using a configuration set, comment or delete the
            # following line
            # ConfigurationSetName=CONFIGURATION_SET,
        )
    # Display an error if something goes wrong.
    except ClientError as e:
        print(e.response['Error']['Message'])
    else:
        print("Email sent! Message ID:"),
        print(response['MessageId'])
