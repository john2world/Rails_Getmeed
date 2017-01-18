#!/bin/sh
# add a new line for each job to update the cron job file individually
# setting the job to kill unwanted process to 15 mins
# setting up the log file
mkdir -p /home/ubuntu/log
touch /home/ubuntu/log/killunwantedprocess.log
(crontab -l ; echo "*/15 * * * * /home/ubuntu/resume/current/OfflineScripts/OtherScripts/killUnwantedProcess.pl") | sort - | uniq - | crontab -

