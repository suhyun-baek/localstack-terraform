## localstack-terraform 
### 환경
 - OS : ubuntu18.04
 - Terraform : Terraform v0.12.20
 - Docker : Docker version 19.03.8
 - Docker-compose : docker-compose version 1.21.2
 - local
### 환경 구성
#### common
 - 공통 작업
    sudo apt-get update
    
#### Terraform
 - 필요 패키지 설치
    sudo apt-get install unzip
 - 다운로드
    wget https://releases.hashicorp.com/terraform/0.12.20/terraform_0.12.20_linux_amd64.zip
 - 압축 풀기
    unzip terraform_0.12.20_linux_amd64.zip
 - 파일 이동
    sudo cp terraform /usr/local/bin/
 - 버전 확인
    terraform -v

#### Docker
 - Docker 패키지 설치
    sudo apt-get -y install docker-ce docker-ce-cli containerd.io
 - Test
    sudo docker run hello-world
 - ubuntu 계정에 Docker 실행 권한을 주기위해 그룹 추가
    sudo usermod -aG docker ubuntu
 - Docker 서비스 재시작
    sudo service docker restart
  
#### Docker-compose
 - Docker-compose 다운로드
    sudo curl -L https://github.com/docker/compose/releases/download/1.21.2/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
 - 실행 권한 추가
    sudo chmod +x /usr/local/bin/docker-compose
