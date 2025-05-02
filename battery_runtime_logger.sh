#!/bin/bash

counter=0
logfile=/home/trinity/battery.log
counterfile=/home/trinity/counter
charge_percentage=0
old_charge_percentage=0
result=0

if test -f $counterfile
then
counter=$(cat $counterfile)
fi

while [ "$?" -eq "0" ]
do

# This code works if there isn't a capacity reported via a file.
#charge_now=$(cat /sys/class/power_supply/BAT0/charge_now)
#charge_full=$(cat /sys/class/power_supply/BAT0/charge_full)
#charge_percentage=$(echo "scale=2; $charge_now / $charge_full" | bc)

# This is for when there is a capacity file available.
charge_percentage=$(cat /sys/class/power_supply/BAT0/capacity)

# Checking to see if the battery charge is significantly different than the previous value. If so, throw a notification and exit with an error code.
result=$(($old_charge_percentage - $charge_percentage))
if [[ $result -gt "5" ]]
then
notify-send "Battery charge has dropped significantly!"
exit 88
fi

# Handle various tasks based on current battery percentage.
# Write the date and percentage to a logfile.
date | tee -a $logfile
echo "$charge_percentage%" | tee -a /home/trinity/battery.log

# If at a percentage divisible by 5, send a notification to the user and note how much approximate screen on time has occurred.
if [[ "$charge_percentage" == "80" ]] || [[ "$charge_percentage" == "60" ]] || [[ "$charge_percentage" == "40" ]] || [[ "$charge_percentage" == "20" ]]
then
notify-send "Battery is at $charge_percentage."
echo "Running on battery for $counter minutes with the screen on." | tee -a $logfile
fi

# Take care of variables and sleep for 1 minute.
counter=$(($counter + 1))
echo $counter > $counterfile
old_charge_percentage=$charge_percentage          # This is so I can add comparison to catch if the battery drops more than 5% across a minute of checking.
sleep 60
done
