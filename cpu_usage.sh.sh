#!/bin/bash

# Script to display CPU usage

echo "--- CPU Usage ---"
cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2+$4}')
echo "Total CPU Usage: ${cpu_usage}%"

exit 0