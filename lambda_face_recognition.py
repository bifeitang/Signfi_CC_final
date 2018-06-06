
# coding: utf-8

# In[ ]:


from __future__ import print_function

import boto3
from decimal import Decimal
import json
import urllib
import re
import time

print('Loading function!!!')

dynamodb = boto3.client('dynamodb')
dynamodb2 = boto3.resource('dynamodb')
s3 = boto3.client('s3')
s4 = boto3.resource('s3')
rekognition = boto3.client('rekognition')


# --------------- Helper Functions ------------------

def index_faces(bucket, key):

    response = rekognition.index_faces(
        Image={"S3Object":
            {"Bucket": bucket,
            "Name": key}},
            CollectionId="family_collection")
    return response
    
def update_index(ppName,cc,tablename):
    res = dynamodb.update_item(
        TableName = tablename,
        Key={
            'Name': {'S': ppName}
            },
        ExpressionAttributeValues={
            ":my_value":{"L": [{"N":cc}]}, ':r': {'L':[]}
        },
        UpdateExpression="SET Records = list_append(if_not_exists(Records, :r), :my_value)",
        ReturnValues="UPDATED_NEW"
        )
        
def new_table(tablename):
    table = dynamodb.create_table(
    TableName=tablename,
    KeySchema=[
        {
            'AttributeName': 'Name',
            'KeyType': 'HASH'
        },
    ],
    AttributeDefinitions=[
        {
            'AttributeName': 'Name',
            'AttributeType': 'S'
        },

    ],
    ProvisionedThroughput={
        'ReadCapacityUnits': 5,
        'WriteCapacityUnits': 5
    }
)


def createCsv(tableName, bucket, key1):
    try:
        t = time.strftime("%Y-%m-%d_%H-%M-%S",time.gmtime())
        table = dynamodb2.Table(tableName)
        response = table.scan()
        print ("List in table ", response['Items'])
        temp = key1.split('/')[:-2]
        key = '/'.join(temp)
        object = s4.Object(bucket, key + '/statistic/%s.csv'%t)
        object2 = s4.Object(bucket, key + '/statistic/history.csv')
        summary = "Name, Presence\r\n"
        file = "Name, Presence\r\n"
        # object.put(Body = header)
        for item in response['Items']:
            try:
                file = file + (item['Name'] + ',' + str(item['Records'][-1]) + '\r\n')
                summary = summary + item['Name'] + ',' + str(sum(item['Records'])) + '\r\n'
            except Exception as e:
                print("No records:" + e)
                continue
        print("Content in time.csv is ", file)
        print("Content in history.csv is ", summary)
        object.put(Body=file.encode('ascii'))
        object2.put(Body=summary.encode('ascii'))
    except Exception as e:
        print(e)
        
def compare_faces(key1, key2, bT, bS):
    # retrieve and resize images for display
    bucketTarget = bT
    bucketSource = bS
    

    # Compare faces using Rekognition

    ret = rekognition.compare_faces(
        SourceImage={
            "S3Object": {
                "Bucket": bucketSource,
                "Name" : key2,
            }
    
        },
        TargetImage={
            "S3Object": {
                "Bucket": bucketTarget,
                "Name" : key1,
            }    
        }
        # SimilarityThreshold=    the default is 80%, you can change it here.
    )
    return(ret)
    
# --------------- Main handler ------------------

def prepare(event, context):
    print(event)
    # Get the object from the event
    bucket = event['Records'][0]['s3']['bucket']['name']
    print("bucket here:"+ bucket)
    key1 = urllib.unquote_plus(event['Records'][0]['s3']['object']['key'].encode('utf8'))
    print("key1 here:"+ key1)
    if "target" in key1:
        lambda_handler(event, bucket, key1)
    elif "source" in key1:
        tablename = key1.split('/')[-3]
        try:
            new_table(tablename)
        except Exception as e:
            print("Table already existed, skip the create table request")
    
    # Calls Amazon Rekognition IndexFaces API to detect faces in S3 object 
    # to index faces into specified collection

def lambda_handler(event, bucket, key1):
    respS3 = s3.list_objects_v2(Bucket=bucket)
    bT = bS = bucket
    for i in range(1, len(respS3['Contents'])):
        if "source" in respS3['Contents'][i]['Key'] and respS3['Contents'][i]['Key'][-1] != "/":
            key2 = respS3['Contents'][i]['Key']
            pattern = re.compile('source/(.+).png')
            ppName = pattern.findall(key2)[0]
            try:
                response = compare_faces(key1, key2, bT, bS)
                similarity = str(response['FaceMatches'][0]['Similarity'])
        
                # Commit faceId and full name object metadata to DynamoDB
                if response['ResponseMetadata']['HTTPStatusCode'] == 200:   #200 represents success
                    print(similarity)
                    if similarity > 80:
                        cc = '1'
                        update_index(ppName, cc, key1.split('/')[-3])
    
                        print(ppName+": This guy attended the class.")
                # faceId = response['FaceRecords'][0]['Face']['FaceId']

                # ret = s3.head_object(Bucket=bucket,Key=key1)
                # personFullName = ret['Metadata']['fullname']

                # update_index('family_collection',faceId,personFullName)

            # Print response to console
        
            except Exception as e:
                print(e)
                cc = '0'
                update_index(ppName, cc, key1.split('/')[-3])
                print("The guy in {} didn't attend class. ".format(key2))
                #print("Error processing object {} from bucket {}. ".format(key2, bucket))
                #raise e  #if raise error, the lambda will automatically run 2 more times.
    createCsv(key1.split('/')[-3], bucket, key1)

