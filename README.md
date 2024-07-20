Oracle Database Setup with ORDS and APEX
This guide will help you build and run an Oracle Database Docker container, configure Oracle REST Data Services (ORDS) with Oracle Application Express (APEX), and set up the necessary scripts for automation.

Prerequisites
Docker installed on your system
Sufficient system resources to run an Oracle Database container
Steps
1. Build the Docker Image
Clone the Oracle Docker images repository and build the Oracle Database Docker image:

sh
Copy code
git clone https://github.com/oracle/docker-images.git
cd docker-images/OracleDatabase/SingleInstance/dockerfiles
./buildContainerImage.sh -v 23.4.0 -p
2. Run the Docker Container
Start the Oracle Database container with the necessary ports and environment variables:

sh
Copy code
docker run -d --name 23cfree \
  -p 8521:1521 -p 8500:5500 -p 8023:8080 -p 9043:8443 \
  -e ORACLE_PWD=qwer1234 -e ORACLE_SID=FREE \
  container-registry.oracle.com/database/free:latest
3. Install and Configure APEX
Execute the following commands inside the running container to install APEX:

sh
Copy code
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
Set up the APEX administration password:

sh
Copy code
docker exec 23cfree /

in ReadMe.md format pls
ChatGPT
Here's the script reformatted as a ReadMe.md file for your Oracle Database configuration:

markdown
Copy code
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
2. Run the Docker Container
Start the Oracle Database container with the necessary ports and environment variables:

sh
Copy code
docker run -d --name 23cfree \
  -p 8521:1521 -p 8500:5500 -p 8023:8080 -p 9043:8443 \
  -e ORACLE_PWD=qwer1234 -e ORACLE_SID=FREE \
  container-registry.oracle.com/database/free:latest
3. Install and Configure APEX
Execute the following commands inside the running container to install APEX:

sh
Copy code
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
Set up the APEX administration password:

sh
Copy code
docker exec 23cfree /bin/bash -c '
cd apex
sqlplus / as sysdba <<SQL
ALTER SESSION SET CONTAINER = FREEPDB1;
@apxchpwd.sql
ADMIN
k@mail@ru
SQL
'
4. Configure ORDS
Execute the following commands inside the running container to install and configure ORDS:

sh
Copy code
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
5. Copy and Execute Startup Scripts
Copy the startup scripts to the container and execute them:

sh
Copy code
docker cp start_ords.sh 23cfree:/home/oracle/scripts/
docker cp stop_ords.sh 23cfree:/home/oracle/scripts/
docker cp 01_auto_ords.sh 23cfree:/opt/oracle/scripts/startup/
sleep 60
docker restart 23cfree

sudo sh /home/oracle/scripts/start_ords.sh
6. Configure Oracle Wallet (Optional)
sh
Copy code
orapki wallet export -wallet /opt/oracle/product/23ai/dbhomeFree/data/wallet -dn 'CN=server_dn,C=US' -request /opt/oracle/product/23ai/dbhomeFree/data/wallet/creq.txt -pwd qwer1234

orapki wallet add -wallet /opt/oracle/product/23ai/dbhomeFree/data/wallet -trusted_cert -cert /opt/oracle/product/23ai/dbhomeFree/data/wallet/trusted_cert.txt -pwd qwer1234

orapki wallet add -wallet /opt/oracle/product/23ai/dbhomeFree/data/wallet/ewallet.p12 -user_cert -cert /opt/oracle/product/23ai/dbhomeFree/data/wallet/cert.txt
7. Access ORDS
You can access ORDS at the following URL:

bash
Copy code
http://localhost:8023/ords
Default Credentials:

INTERNAL
ADMIN
APEX[123]
Notes
Ensure the jdbc.MaxLimit and jdbc.InitialLimit settings in the ORDS configuration are appropriately sized for a production environment.
Update any placeholder values such as passwords and email addresses as needed.
vbnet
Copy code

This ReadMe provides a clear, step-by-step guide for setting up Oracle DB with ORDS and APEX using Docker, ensuring easy configuration and automation.





