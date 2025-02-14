#!/bin/bash

# Script to display load average

echo "--- Load Average (1, 5, 15 minutes) ---"
load_average=$(uptime | awk -F '[:,]' '{print $4 ", " $5 ", " $6}')
echo "$load_average"

exit 0