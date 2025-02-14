#!/bin/bash

# Script to display load average

echo "--- Load Average (1, 5, 15 minutes) ---"
load_average=$(uptime | tr ',' ' ' | awk '{
  for (i=1; i<=NF; i++) {
    if ($i == "load" && $(i+1) == "average:") {
      printf "%s, %s, %s\n", $(i+2), $(i+3), $(i+4)
      exit
    }
  }
}')
echo "$load_average"

exit 0