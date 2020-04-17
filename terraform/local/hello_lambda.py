'''
@ Author : bsh0817
@ Created : 2020. 04. 15
@ Update : 2020. 04. 16
'''
import os
import json
import traceback
import base64
import re
from datetime import datetime, timedelta, timezone
import boto3


# time zone
KST = timezone(timedelta(hours=9))
# s3
s3 = boto3.resource('s3')
# bucket name
bucket_name = os.environ['log_bucket_name']
# log base path
bucket_base_path = os.environ['log_bucket_base_path']
# log time format
log_time_format = '%d/%b/%Y:%H:%M:%S %z'


def lambda_handler(event, context):
    '''
        @ main function

        @Arguments Example
            event ={
                "records": [
                    {
                    "recordId": "49606071918085754084961748518444464546381847279259615234000000",
                    "approximateArrivalTimestamp": 1586939722216,
                    "data": "MTI1LjE3OS4xNC43MSAtIC0gWzE1L0Fwci8yMDIwOjA4OjM0OjIyICswMDAwXSAiR0VUIC9yZXJlcmxkamhramhqayBIVFRQLzEuMSIgNDA0IDIwOSAiLSIgIk1vemlsbGEvNS4wIChXaW5kb3dzIE5UIDEwLjA7IFdpbjY0OyB4NjQpIEFwcGxlV2ViS2l0LzUzNy4zNiAoS0hUTUwsIGxpa2UgR2Vja28pIENocm9tZS84MC4wLjM5ODcuMTYzIFNhZmFyaS81MzcuMzYiCg==",
                    "kinesisRecordMetadata": {
                        "sequenceNumber": "49606071918085754084961748518444464546381847279259615234",
                        "subsequenceNumber": 0,
                        "partitionKey": "846407.7730515298",
                        "shardId": "shardId-000000000000",
                        "approximateArrivalTimestamp": 1586939722216
                        }
                    }
                ]
            }
            context = ""
    '''

    try:
        if "records" in event and len(event["records"]) > 0:
            # json으로 로그 형식 변경
            json_log = fn_convert_log_to_json(event)
            # 시간 단위로 로그를 분리해 s3에 업로드
            for odjectKey in json_log:
                # odjectKey 값은 시간 정보와 첫번째 recordId 값으로 지정해 파일명의 중복을 피하고, 
                # 로그 파싱 이슈발생으로 재작업시 중복된 데이터를 피하기 위함
                param = {
                    'odjectKey': "{}{}/{}".format(bucket_base_path, odjectKey, event["records"][0]["recordId"]),
                    'data': json_log[odjectKey]
                }
                # print(param)
                fn_s3_put(param)
    except : 
        print ("err : " + str(traceback.format_exc()))

    return {'records': event['records']}

def fn_convert_log_to_json(param):
    '''
        @ convert log to json

        @Arguments Example
            param ={
                "records": [
                    {
                    "recordId": "49606071918085754084961748518444464546381847279259615234000000",
                    "approximateArrivalTimestamp": 1586939722216,
                    "data": "MTI1LjE3OS4xNC43MSAtIC0gWzE1L0Fwci8yMDIwOjA4OjM0OjIyICswMDAwXSAiR0VUIC9yZXJlcmxkamhramhqayBIVFRQLzEuMSIgNDA0IDIwOSAiLSIgIk1vemlsbGEvNS4wIChXaW5kb3dzIE5UIDEwLjA7IFdpbjY0OyB4NjQpIEFwcGxlV2ViS2l0LzUzNy4zNiAoS0hUTUwsIGxpa2UgR2Vja28pIENocm9tZS84MC4wLjM5ODcuMTYzIFNhZmFyaS81MzcuMzYiCg==",
                    "kinesisRecordMetadata": {
                        "sequenceNumber": "49606071918085754084961748518444464546381847279259615234",
                        "subsequenceNumber": 0,
                        "partitionKey": "846407.7730515298",
                        "shardId": "shardId-000000000000",
                        "approximateArrivalTimestamp": 1586939722216
                        }
                    }
                ]
            }
        @Responce Example
            responce = {
                "2020041517" : "{"host": "125.179.14.71", "user": "-", "time": "15/Apr/2020:08:34:22 +0000", "method": "GET", "path": "/rererldjhkjhjk", "protocol": "HTTP/1.1", "status": "404", "size": "209", "referer": "-", "userAgent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.163 Safari/537.36"}\n"
                "2020041518" : "{"host": "125.179.14.71", "user": "-", "time": "15/Apr/2020:09:34:22 +0000", "method": "GET", "path": "/rererldjhkjhjk", "protocol": "HTTP/1.1", "status": "404", "size": "209", "referer": "-", "userAgent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.163 Safari/537.36"}\n"
            }
    '''

    responce = {}
    for record in param['records']:
        # 디코딩
        payload = base64.b64decode(record['data']).decode("utf-8")

        # pattern에 따라 파싱
        payload_pattern_match_result = fn_data_pattern().match(payload)
        # dict 형식으로 저장
        payload_pattern_match_result = payload_pattern_match_result.groupdict()
        # 로그의 time을 15/Apr/2020:08:34:22 +0000 형태를 한국 시로 변경
        log_time = datetime.fromtimestamp(datetime.strptime(payload_pattern_match_result["time"], log_time_format).timestamp(), tz=KST)
        # 시간 단위로 로그 정리
        payload_time = log_time.strftime('%Y%m%d%H')
        if payload_time in responce:
            responce[payload_time] += str(json.dumps(payload_pattern_match_result, ensure_ascii=False)) + "\n"
        else:
            responce[payload_time] = str(json.dumps(payload_pattern_match_result, ensure_ascii=False)) + "\n"
        
    return responce

def fn_data_pattern():
    '''
        @ make pattern
    '''
    ## data pattern
    parts = [
        r'(?P<host>\S+)',                   # host
        r'\S+',                             # indent (unused)
        r'(?P<user>\S+)',                   # user
        r'\[(?P<time>.+)\]',                # time
        r'"(?P<method>\S+)',                # method
        r'(?P<path>\S+)',                   # path
        r'(?P<protocol>.+)"',               # protocol
        r'(?P<status>[0-9]+)',              # status
        r'(?P<size>\S+)',                   # size
        r'"(?P<referer>.*)"',               # referer
        r'"(?P<userAgent>.*)"',                 # user agent
    ]
    
    return re.compile(r'\s+'.join(parts)+r'\s*\Z')

def fn_s3_put(param):
    '''
        @ s3 file upload

        @Arguments Example
            param = {
                    'odjectKey': '2020041501/49606071918085754084961748518444464546381847279259615234000000',
                    'data': '{"test":"test"}'
                }
    '''
    s3.Object(bucket_name, param["odjectKey"]).put(Body=param["data"])
