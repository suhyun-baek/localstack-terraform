## localstack-terraform 
### 환경
 - OS : ubuntu18.04
 - Terraform : Terraform v0.12.20
 - Docker : Docker version 19.03.8
 - Docker-compose : docker-compose version 1.21.2
 
### 환경 구성
#### common
 - 공통 작업</br>
    sudo apt-get update
    
#### Terraform
 - 필요 패키지 설치</br>
   sudo apt-get install unzip
 - 다운로드</br>
    wget https://releases.hashicorp.com/terraform/0.12.20/terraform_0.12.20_linux_amd64.zip
 - 압축 풀기</br>
    unzip terraform_0.12.20_linux_amd64.zip
 - 파일 이동</br>
    sudo cp terraform /usr/local/bin/
 - 버전 확인</br>
    terraform -v

#### Docker
 - Docker 패키지 설치</br>
    sudo apt-get -y install docker-ce docker-ce-cli containerd.io
 - Test</br>
    sudo docker run hello-world
 - ubuntu 계정에 Docker 실행 권한을 주기위해 그룹 추가</br>
    sudo usermod -aG docker ubuntu
 - Docker 서비스 재시작</br>
    sudo service docker restart
  
#### Docker-compose
 - Docker-compose 다운로드</br>
    sudo curl -L https://github.com/docker/compose/releases/download/1.21.2/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
 - 실행 권한 추가</br>
    sudo chmod +x /usr/local/bin/docker-compose

 
 
### 서비스 실행 방법
 - localstack 실행
 - terraform init/ apply

#### localstack
 - localstack/docker-compose.yml 디렉토리에서 docker-compose를 이용한 실행</br>
    docker-compose up
 - http://localhost:8080 접속해서 정상적으로 실행중인지 확인

#### terraform 
 - terraform/local/ 디렉토리에서 아래 두 명령어 실행</br>
    terraform init</br>
    terraform apply</br>


### AWS 리소스 구성
#### S3
 - 버킷 명 : nginx-log.bsh0817
 - path 구조
  - 시간 단위로 json 형태로 변환된 로그</br>
      nginx/kinesis/firehose/migration/day=YYYYDDMMHH/</br>
  - 원본 로그</br>
      nginx/kinesis/firehose/origin/success/YYYY/DD/MM/HH</br>
  - error 로그</br>
      nginx/kinesis/firehose/origin/error/YYYY/DD/MM/HH</br>
      
#### Kinesis Data Stream
 - Kinesis Data Stream 명 : nginx-log.bsh0817-stream</br>
 
#### Kinesis Firehose
 - Kinesis Firehose 명 : nginx-log.bsh0817-firehose</br>
     source : nginx-log.bsh0817-stream</br>
     Transform source records with AWS Lambda : firehose_lambda</br>
     Amazon S3 destination : nginx-log.bsh0817</br>
     
#### Lambda
 - Lambda 명 : firehose_lambda</br>
 - runtime : python3.7</br>


