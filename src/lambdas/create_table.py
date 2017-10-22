import boto3

dynamodb = boto3.resource('dynamodb')

dynamodb.create_table(
        TableName = 'Item',
        KeySchema = [
            {
                'AttributeName' : 'owner',
                'KeyType' : 'HASH',
                },
            {
                'AttributeName' : 'group__description',
                'KeyType' : 'RANGE'
            },
        ],
        AttributeDefinitions = [
            {
                'AttributeName' : 'owner',
                'AttributeName' : 'S',
            },
            {
                'AttributeName' : 'group__description',
                'AttributeName' : 'S',
            }
        ],
        ProvisionedThroughput={
            'ReadCapacityUnits': 10,
            'WriteCapacityUnits': 10
        }
        )


