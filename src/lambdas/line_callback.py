import boto3
import json
import re

from boto3.dynamodb.conditions import Key, Attr
from botocore.exceptions import ClientError

from linebot import LineBotApi,WebhookHandler
from linebot.models import TextSendMessage
from linebot.exceptions import LineBotApiError

from misc import build_item_dict

UNORGANIZED_NAME = "_UNORGANIZED"

dynamodb = boto3.resource('dynamodb')

db_table = dynamodb.Table('ginnan-icho-Item')
line_user_table = dynamodb.Table('ginnan-icho-LineUser')

line_bot_api = LineBotApi('pWgzEoWm3PKS/azWeLsuCaC4F/52GVHzuSAGZGU1QRZ+VJOXtzwOiwSX3+D4I7L7I9liEgQrzFbzu3rPS6BREqvmCMNLXA0QNGmkJ5dxS409/+53+bG9863tSirnkUtkM8p/+CgTeMHGig+fe5gxdwdB04t89/1O/w1cDnyilFU=')





def register(e):
    username = re.match(r"registerme (?P<username>\w+)",e['message']['text']).group('username')
    user = line_user_table.put_item(
            Item = {
                'line_user_id':e['source']['userId'],
                'username':username,
                }
            )
    line_bot_api.reply_message(
        e['replyToken'],
        TextSendMessage(text='registered you as ' + username))



def send_list(e,user):
    items = db_table.query(KeyConditionExpression=Key('owner').eq(user['username'])
            )['Items']
    res = build_item_dict(items)
    text = ""
    for group_name,description_list in res.items():
        if group_name == UNORGANIZED_NAME:
            text += "未整理" + "\n"
        else:
            text += group_name + "\n"
        for description in description_list:
            text += ("  " + description + "\n")
    line_bot_api.reply_message(
        e['replyToken'],
        TextSendMessage(text=text))

def add_item(e,user):
    db_table.put_item(
            Item = {
                'owner':user['username'],
                'group__description':UNORGANIZED_NAME + "__" + e['message']['text'],
                'group_name':UNORGANIZED_NAME,
                'description':e['message']['text'],
                }
            )
    line_bot_api.reply_message(
        e['replyToken'],
        TextSendMessage(text='add item'))

def send_register_message(e):
    line_bot_api.reply_message(
        e['replyToken'],
        TextSendMessage(text='you must register to this system.Please send username as "registerme {username}"'))




def handler(event,context):
    for e in event['body-json']['events']:
        # e['message']['text'] が送られてきた本文
        if e['message']['text'].startswith('registerme '):
            register(e)
        else:
            try:
                response = line_user_table.get_item(
                        Key = {
                            'line_user_id':e['source']['userId'],
                            }
                        )
                user = response['Item']

                if e['message']['text'] == "list":
                    # 一覧取得
                    send_list(e,user)
                else:
                    add_item(e,user)
            except (ClientError,KeyError):
                # this is not registered user
                send_register_message(e)


