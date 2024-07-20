# Oracle Database Setup with ORDS and APEX

This guide will help you build and run an Oracle Database Docker container, configure Oracle REST Data Services (ORDS) with Oracle Application Express (APEX), and set up the necessary scripts for automation.

## Prerequisites

- Docker installed on your system
- Sufficient system resources to run an Oracle Database container

## Steps

### 1. Build the Docker Image

Clone the Oracle Docker images repository and build the Oracle Database Docker image:

```sh
git clone https://github.com/oracle/docker-images.git
cd docker-images/OracleDatabase/SingleInstance/dockerfiles
./buildContainerImage.sh -v 23.4.0 -p

docker run -d --name 23cfree \
  -p 8521:1521 -p 8500:5500 -p 8023:8080 -p 9043:8443 \
  -e ORACLE_PWD=qwer1234 -e ORACLE_SID=FREE \
  container-registry.oracle.com/database/free:latest

docker exec 23cfree /bin/bash -c '
  curl -o apex-latest.zip https://download.oracle.com/otn_software/apex/apex-latest.zip
  unzip apex-latest.zip
  cd apex
  dnf update -y
  dnf install sudo nano expect -y
  sqlplus / as sysdba <<SQL
  ALTER SESSION SET CONTAINER = FREEPDB1;
  @apexins.sql SYSAUX SYSAUX TEMP /i/
  ALTER USER APEX_PUBLIC_USER ACCOUNT UNLOCK;
  ALTER USER APEX_PUBLIC_USER IDENTIFIED BY qwer1234;
  SQL
'
docker exec 23cfree /bin/bash -c '
cd apex
sqlplus / as sysdba <<SQL
ALTER SESSION SET CONTAINER = FREEPDB1;
@apxchpwd.sql
ADMIN
k@mail@ru
SQL
'

docker exec -u root 23cfree /bin/bash -c '
mkdir -p /home/oracle/software/{apex,ords} /home/oracle/scripts /etc/ords/config /home/oracle/logs
cp -r /home/oracle/apex/images /home/oracle/software/apex
echo "oracle ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
dnf install java-17-openjdk -y
dnf install ords expect -y
java -version
expect <<EOF
spawn ords --config /etc/ords/config install
expect "Enter a number to select the TNS net service name to use or specify the database"
send "2\r"
expect "Provide database user name with administrator privileges.Enter the administrator username:"
send "SYS\r"
expect "Enter the database password for SYS AS SYSDBA:"
send "qwer1234\r"
expect "Enter a number to update the value or select option A to Accept and Continue"
send "8\r"
expect "Enter the APEX static resources location:"
send "/home/oracle/software/apex/images\r"
expect "Enter a number to update the value or select option A to Accept and Continue"
send "A\r"
expect eof
EOF
'

docker cp start_ords.sh 23cfree:/home/oracle/scripts/
docker cp stop_ords.sh 23cfree:/home/oracle/scripts/
docker cp 01_auto_ords.sh 23cfree:/opt/oracle/scripts/startup/
sleep 60
docker restart 23cfree

sudo sh /home/oracle/scripts/start_ords.sh

orapki wallet export -wallet /opt/oracle/product/23ai/dbhomeFree/data/wallet -dn 'CN=server_dn,C=US' -request /opt/oracle/product/23ai/dbhomeFree/data/wallet/creq.txt -pwd qwer1234

orapki wallet add -wallet /opt/oracle/product/23ai/dbhomeFree/data/wallet -trusted_cert -cert /opt/oracle/product/23ai/dbhomeFree/data/wallet/trusted_cert.txt -pwd qwer1234

orapki wallet add -wallet /opt/oracle/product/23ai/dbhomeFree/data/wallet/ewallet.p12 -user_cert -cert /opt/oracle/product/23ai/dbhomeFree/data/wallet/cert.txt

http://localhost:8023/ords

Default Credentials:

INTERNAL
ADMIN
APEX[123]
