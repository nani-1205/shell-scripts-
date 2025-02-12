#!/bin/bash

# Script to display load average

echo "--- Load Average (1, 5, 15 minutes) ---"
load_average=$(uptime | awk '{print $10 $11 $12}') #Correctly captures all three load averages
echo "$load_average"

exit 0