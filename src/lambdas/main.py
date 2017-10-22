import boto3
import json

from boto3.dynamodb.conditions import Key, Attr
from urllib import parse

dynamodb = boto3.resource('dynamodb')
db_table = dynamodb.Table('facard-db')

def get_user(event,context):
    """
    primary keyが face idであるItemを全て取得してjsonでかえす
    """
    items = db_table.query(KeyConditionExpression=Key('faceid').eq(event['faceid']))['Items']
    return json.dumps(items)


def add_user(event,context):
    """
    未整理のメモを追加
    """
    item = {
        "faceid": event['context']['username'],
        "comapany" : event['body-json']['company'],
        "name": event['body-json']['name'],
        "department": event['body-json']['department'],
        "position": event['body-json']['position'],
        "TEL": event['body-json']['TEL'],
        "Mail": event['body-json']['mail'],
        "HP": event['body-json']['HP'],
    }
    
    db_table.put_item(
        Item = item
    )
    return json.dumps({})
