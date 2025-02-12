
# How to Use:

# Save: Save the script to a file (e.g., clear_cache.sh).

# Make Executable: chmod +x clear_cache.sh

# Run: sudo ./clear_cache.sh
#---------------------------------------------------------------------------------------------------------------------------

#!/bin/bash

# Script to clear system caches
# This script requires root privileges

# Check if the script is run with sudo
if [[ $EUID -ne 0 ]]; then
  echo "This script requires root privileges. Please run with sudo."
  exit 1
fi

# --- Clear PageCache, dentries and inodes ---
echo "Clearing PageCache, dentries and inodes..."
sync
echo 3 > /proc/sys/vm/drop_caches
if [ $? -eq 0 ]; then
  echo "Successfully cleared PageCache, dentries and inodes."
else
  echo "Error: Failed to clear PageCache, dentries and inodes."
  exit 1
fi

# --- Clear dentries and inodes ---
echo "Clearing dentries and inodes..."
sync
echo 2 > /proc/sys/vm/drop_caches
if [ $? -eq 0 ]; then
    echo "Successfully cleared dentries and inodes."
else
  echo "Error: Failed to clear dentries and inodes."
    exit 1
fi

# --- Clear PageCache only ---
echo "Clearing PageCache only..."
sync
echo 1 > /proc/sys/vm/drop_caches
if [ $? -eq 0 ]; then
  echo "Successfully cleared PageCache only."
else
  echo "Error: Failed to clear PageCache only."
    exit 1
fi

echo "Cache clearing complete."

exit 0



