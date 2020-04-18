## localstack-terraform 
### 환경
 - OS : ubuntu18.04
 - Terraform : Terraform v0.12.20
 - Docker : Docker version 19.03.8
 - Docker-compose : docker-compose version 1.21.2
 
### 디렉토리 구성 
	 /localstack  = localstack를 실행하기 위한 docker-compose.yml 파일이 담겨있다.
	 /terraform   = terraform 파일이 모두 담겨있다.
		/terraform/module = module 파일이 담겨있다.
		/terraform/local = localstack 구성을 위한 파일이 담겨있다.
		/terraform/aws-test = aws에서 실제로 테스트 진행한 파일이 담겨있다.
	 /test        = 검증을 위한 파일이 담겨있다.
### 환경 구성
#### common
 - 공통 작업
	- sudo apt-get update

#### Terraform
 - 필요 패키지 설치
	- sudo apt-get install unzip
 - 다운로드
	- wget https://releases.hashicorp.com/terraform/0.12.20/terraform_0.12.20_linux_amd64.zip
 - 압축 풀기
 	- unzip terraform_0.12.20_linux_amd64.zip
 - 파일 이동
 	- sudo cp terraform /usr/local/bin/
 - 버전 확인
 	- terraform -v

#### Docker
 - Docker 패키지 설치
 	- sudo apt-get -y install docker-ce docker-ce-cli containerd.io
 - Test
 	- sudo docker run hello-world
 - ubuntu 계정에 Docker 실행 권한을 주기위해 그룹 추가
 	- sudo usermod -aG docker ubuntu
 - Docker 서비스 재시작
 	- sudo service docker restart
  
#### Docker-compose
 - Docker-compose 다운로드
 	- sudo curl -L https://github.com/docker/compose/releases/download/1.21.2/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
 - 실행 권한 추가
 	- sudo chmod +x /usr/local/bin/docker-compose

 
 
### 서비스 실행 방법
 - localstack 실행
 - terraform init/ apply

#### localstack
 - localstack/docker-compose.yml 디렉토리에서 docker-compose를 이용한 실행
 	- docker-compose up
 - http://localhost:8080 접속해서 정상적으로 실행중인지 확인

#### terraform 
 - (localstack) terraform/local/ 디렉토리에서 아래 두 명령어 실행
  	- terraform init
 	- terraform apply
 - (aws) terraform/local/ 디렉토리에서 아래 두 명령어 실행
  	- terraform init
 	- terraform apply

### AWS 리소스 구성
#### S3
 - 버킷 명 : nginx-log-bsh0817
 - path 구조
 	- 시간 단위로 json 형태로 변환된 nginx 로그</br>
		- nginx-log-bsh0817/kinesis/firehose/migration/year=YYYY/month=MM/day=DD/hour=HH</br>
	- 정상적으로 처리된 nginx 로그</br>
		- nginx-log-bsh0817/kinesis/firehose/origin/success/YYYY/MM/DD/HH</br>
	- error nginx 로그</br>
		- nginx-log-bsh0817/kinesis/firehose/origin/error/processing-failed/YYYY/MM/DD/HH
 
#### Kinesis Data Stream
 - Kinesis Data Stream 명 : nginx-log-bsh0817-stream</br>
 
#### Kinesis Firehose
 - Kinesis Firehose 명 : nginx-log-bsh0817-firehose</br>
 - source : nginx-log-bsh0817-stream</br>
 - Transform source records with AWS Lambda : nginx-log-bsh0817_firehose_lambda</br>
 - Amazon S3 destination : nginx-log-bsh0817</br>
     
#### Lambda
 - Lambda 명 : firehose_lambda</br>
 - runtime : python3.7</br>


### 검증 시나리오

### 검증 환경
 - OS : ubuntu18.04
 - nginx : nginx version: nginx/1.14.0 (Ubuntu)
 - Python : Python 3.6.9
### 검증 환경 구성
 - nginx, git 패키지 설치
 	- sudo apt-get install -y nginx git
 - nginx 실행
 	- sudo service nginx start</br>
    	(정지 : sudo service nginx stop)</br>
    	(재시작 : sudo service nginx restart)</br>
    	(상태 확인 : sudo service nginx status)
 
### Kinesis agent 사용해 프로세스 검증
#### 방법: nginx에 실제 access log가 쌓이게 한 후에 Kinesis agent를 활용해 kinesis data stream으로 데이터 전송하는 방식
#### 구성 이유 : 전체 프로세스를 검증
#### 검증 절차
 - agent 소스 내려받기
 	- git clone https://github.com/awslabs/amazon-kinesis-agent.git
 - 설치 실행
 	- sudo ./setup --install
 - config 파일 수정
 	- sudo vi /etc/aws-kinesis/agent.json
	```json
	(localstack)
	{
	  "cloudwatch.emitMetrics": false,
	  "kinesis.endpoint": "http://localhost:4573",
	  "cloudwatch.endpoint": "http://localhost:4582",
	  "awsAccessKeyId": "foo",
	  "awsSecretAccessKey": "val",
	  "flows": [
	    {
	      "filePattern": "/var/log/nginx/access.log",
	      "kinesisStream": "nginx-log-bsh0817-stream"
	    }
	  ]
	}
	```
	```json
	(aws)
	{
	  "cloudwatch.emitMetrics": false,
	  "kinesis.endpoint": "https://kinesis.ap-northeast-2.amazonaws.com",
	  "awsAccessKeyId": "foo",
	  "awsSecretAccessKey": "val",
	  "flows": [
	    {
	      "filePattern": "/var/log/nginx/access.log",
	      "kinesisStream": "nginx-log-bsh0817-stream"
	    }
	  ]
	}
	```
 - kinesis agent user nginx 로그 그룹에 권한 추가
 	- sudo gpasswd -a aws-kinesis-agent-user adm

 - kinesis agent 재시작
 	- sudo service aws-kinesis-agent restart

 - kinesis agent 로그파일 보기
 	- tail -f /var/log/aws-kinesis-agent/aws-kinesis-agent.log
    
 - nginx-log-bsh0817 버킷에 데이터 확인 및 Cloud Watch log 확인

### 실제 데이터 검증
#### 방법: 실제 로그를 Python을 이용해 대량으로 전송시켜 성능 검증
#### 구성 이유 : 다양한 로그 패턴의 오류 발생률 등을 확인하기위한 검증
 - test/send-log-to-kinesis.py 파일 실행
 
</br></br></br></br>
### trouble shooting
- Terraform을 이용해 localstack에서 firehose를 생성 할 경우 extended_s3_configuration 영역이 추가가 안되 firehose와 Lambda 연결이 어려웠다. 이로 인해 AWS 실제 계정으로 전체 테스트를 진행하고 localstack에서는 진행하지 못했다.
- Kinesis agent를 이용해 localstack의 data stream에 데이터를 전송하려 할 때 많은 이슈 발생
	- 4/15일 localstack 설치 후 kinesis agent 테스트시 </br>
		error: UnicodeDecodeError: 'utf-8' codec can't decode byte 0xbf in position 0: invalid start byte</br>
	- 4/17일 15일 이슈에 대해 localstack 에 pom.xml에 jackson-dataformat-cbor을 추가 하려했으나 4/16일 업데이트이 이미 추가 되어 있어 신규로 업데이트 진행. 신규 이슈 발생</br>
		localstack error: localstack.services.generic_proxy: Error forwarding request: 'utf-8' codec can't decode byte 0xbf in position 0</br>
		kinesis agent error : unicodedecodeerror 'utf-8' codec can't decode byte 0xbf in position 0</br>
