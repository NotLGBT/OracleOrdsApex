export ORDS_HOME=/usr/local/bin/ords
export _JAVA_OPTIONS="-Xms512M -Xmx512M"
LOGFILE=/home/oracle/logs/ords-`date +"%Y""%m""%d"`.log
nohup ${ORDS_HOME} --config /etc/ords/config serve >> $LOGFILE 2>&1 & echo "View log file with : tail -f $LOGFILE"