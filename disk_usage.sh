#!/bin/bash

# Script to display disk usage (root partition)

echo "--- Disk Usage (Root Partition) ---"
disk_total=$(df -h / | awk 'NR==2{print $2}')
disk_used=$(df -h / | awk 'NR==2{print $3}')
disk_avail=$(df -h / | awk 'NR==2{print $4}')
disk_percent=$(df -h / | awk 'NR==2{print $5}')

echo "Total Disk Space: ${disk_total}"
echo "Used Disk Space: ${disk_used}"
echo "Available Disk Space: ${disk_avail}"
echo "Disk Usage: ${disk_percent}"

exit 0