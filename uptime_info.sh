#!/bin/bash

# Script to display system uptime

echo "--- System Uptime ---"
uptime=$(uptime -p)
echo "$uptime"

exit 0