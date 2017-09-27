#!/bin/bash
#
# Init script
#
###########################################################

. init.sh

# Initialize the cronjob
cronFile=/tmp/buildcron
printf "SHELL=/bin/bash\n" > $cronFile
printenv -0 | sed -e 's/=\x0/=""\n/g'  | sed -e 's/\x0/\n/g' | sed -e "s/_=/PRINTENV=/g" >> $cronFile
printf "\n$CRONTAB_TIME /usr/bin/flock -n /tmp/lock.build /root/build.sh >> $DOCKER_LOG 2>&1\n" >> $cronFile
crontab $cronFile
rm $cronFile

# Run crond in foreground
crond -n -m off 2>&1
