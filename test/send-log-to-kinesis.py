import traceback
import boto3


kinesis_client = boto3.client('kinesis', region_name="ap-northeast-2")
stream_name = "nginx-log-bsh0817-stream"
local_file_path = "test-log.log"


def main():
    '''
        @ main
    '''
    with open(local_file_path,'r', encoding='UTF8', errors='ignore') as f:
        logs = f.readlines()
        for record in logs :
            try:
                fn_put_record(record)
            except:
                print(record)
                print ("err : " + str(traceback.format_exc()))
            

def fn_put_record(param):
    '''
        @ put_record

        @Arguments Example
            param ={
                "records": [
                    '139.162.106.181 - - [17/Apr/2020:06:46:27 +0900] "GET / HTTP/1.1" 404 74 "-" "HTTP Banner Detection (https://security.ipip.net)"',
                    '139.162.106.181 - - [17/Apr/2020:06:46:27 +0900] "GET / HTTP/1.1" 404 74 "-" "HTTP Banner Detection (https://security.ipip.net)"'
                ]
            }
    '''      
    kinesis_client.put_record(
        StreamName=stream_name,
        Data=param.encode(),
        PartitionKey='0'
    )

if __name__ == "__main__":
    main()