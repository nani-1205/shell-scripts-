#!/bin/bash

# Script to display memory usage

echo "--- Memory Usage ---"
total_mem=$(free -m | awk 'NR==2{print $2}')
used_mem=$(free -m | awk 'NR==2{print $3}')
free_mem=$(free -m | awk 'NR==2{print $4}')
percent_used=$(( (used_mem * 100) / total_mem ))

echo "Total Memory: ${total_mem} MB"
echo "Used Memory: ${used_mem} MB"
echo "Free Memory: ${free_mem} MB"
echo "Memory Usage: ${percent_used}%"

exit 0