# Snowflake to kafka

Sent snowflake table deltas to kafka topic. 

Read full article at
https://maxcotec.com/learning/snowflake-streams-to-kafka-topic

Watch YouTube tutorial at
https://youtu.be/nTq64FYCOU0

## S3 source kafka connector

Configuration:
```yaml
name=S3SourceKafkaConnector # this can be anything 
connector.class=io.lenses.streamreactor.connect.aws.s3.source.S3SourceConnector
value.converter=org.apache.kafka.connect.storage.StringConverter 
topics=$TOPIC
tasks.max=1 
connect.s3.kcql=insert into $TOPIC select * from $BUCKET_NAME:users STOREAS `json` 
connect.s3.aws.auth.mode=Credentials 
connect.s3.aws.access.key=$AWS_IAM_USER_ACCESS_KEY 
connect.s3.aws.secret.key=$AWS_IAM_USER_SECRET_KEY 
connect.s3.aws.region=$AWS_REGION
```

* Replace `$TOPIC` with the name of kafka topic
* Replace `$BUCKET_NAME` with your own bucket name.
* Replace `$AWS_REGION` to the region where you s3 bucket is located
* Replace `$AWS_IAM_USER_ACCESS_KEY` and `$AWS_IAM_USER_SECRET_KEY` with your actual AWS IAM user secret credentials. 
Make sure this user has the following IAM policy;

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "ListObjectsInBucket",
            "Effect": "Allow",
            "Action": ["s3:ListBucket"],
            "Resource": ["arn:aws:s3:::$BUCKET_NAME"]
        },
        {
            "Sid": "AllObjectActions",
            "Effect": "Allow",
            "Action": "s3:*Object",
            "Resource": ["arn:aws:s3:::$BUCKET_NAME/*"]
        }
    ]
}
```

