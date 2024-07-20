# OracleOrdsApex
OracleOrdsApex setup 

Go to https://github.com/oracle/docker-images/tree/main/OracleDatabase/SingleInstance/dockerfiles/23.4.0
Build your own image ./buildContainerImage.sh -f -v 23.4.0 -p
After creation, run the Dockerfile and execute scripts like described below (update this soon LOL): 


#!/bin/bash

# Run Docker container
docker run -d --name 23cfree -p 8521:1521 -p 8500:5500 -p 8023:8080 -p 9043:8443 -e ORACLE_PWD=qwer1234 ORACLE_SID=FREE container-registry.oracle.com/database/free:latest


docker exec 23cfree /bin/bash -c '
  # Execute scripts
  curl -o apex-latest.zip https://download.oracle.com/otn_software/apex/apex-latest.zip
  unzip apex-latest.zip
  cd apex
  su -c "dnf update -y"
  su -c "dnf install sudo -y"
  su -c "dnf install nano -y"
  su -c "dnf install expect -y"
  sed -i "s|HIDE|default \"Apex[123]\" HIDE|g" /home/oracle/apex/apxchpwd.sql
  sqlplus / as sysdba << SQL
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
'

docker exec -u root 23cfree /bin/bash -c '
mkdir /home/oracle/software
mkdir /home/oracle/software/apex
mkdir /home/oracle/software/ords
mkdir /home/oracle/scripts
cp -r /home/oracle/apex/images /home/oracle/software/apex
cd /home/oracle/
su -c "sed -i \"74s/.*/Defaults !lecture/\" /etc/sudoers"
echo "oracle ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
su -c "dnf install java-17-openjdk -y"
su -c "mkdir /etc/ords"
su -c "mkdir /etc/ords/config"
su -c "mkdir /home/oracle/logs"
su -c "chmod -R 777 /etc/ords"
su -c "java -version"
su -c "yum-config-manager --add-repo=http://yum.oracle.com/repo/OracleLinux/OL8/oracle/software/x86_64"
su -c "dnf install ords -y"
su -c "export _JAVA_OPTIONS=\"-Xms512M -Xmx512M\""
su -c"dnf install expect"
expect << EOF
spawn su -c "ords --config /etc/ords/config install
expect "Enter a number to select the TNS net service name to use or specify the database"
send "2\r"
expect "Provide database user name with administrator privileges.Enter the administrator username:"
send "SYS\r"
expect "Enter the database password for SYS AS SYSDBA:"
send "qwer1234\r"
expect " Enter a number to update the value or select option A to Accept and Continue"
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



2024-07-17T11:54:10.867Z WARNING     *** jdbc.MaxLimit in configuration |default|lo| is using a value of 10, this setting may not be sized adequately for a production environment ***
2024-07-17T11:54:10.867Z WARNING     *** jdbc.InitialLimit in configuration |default|lo| is using a value of 10, this setting may not be sized adequately for a production environment ***


INTERNAL
ADMIN 
APEX[123]

http://localhost:8023/ords
