#!/bin/bash

# Description: Pulls datasets based on a grep filter and lists just the dataset path.

# Script notes:
# If you are needing to filter out specific datasets, set counter to 0.
# Otherwise you will need to set counter to 2 to skip the first two lines of the output.
# The recommendation is to filter down what you need and call the function multiple times if necessary.



# Global Vars go here


list_datasets(){
# Function specific vars go here
counter=0
while [ $counter -le $(("${#datasets[@]}-1")) ]
do dataset=$(echo ${datasets[$counter]} | cut -d ' ' -f 1)
echo $dataset
let counter=counter+1
done
datasets=$null
}


clear

# This maps out all pools on the system.
mapfile -t datasets < <(zfs list | grep DS)
list_datasets

sleep 2

mapfile -t datasets < <(zfs list | grep Not)
list_datasets
