#!/bin/bash

# --- Configuration ---
USER_E02="ec2-user"
HOST_E02="18.60.184.24"
PASSWORD_E02="Saijagan@12"  # SSH Keys!
SOURCE_E02="/opt/Jagan*"
DESTINATION_E01="/opt/back-up"
NUM_BACKUPS_TO_KEEP=3  # Number of backups to keep

# --- Script Logic ---

if [ ! -d "$DESTINATION_E01" ]; then
  mkdir -p "$DESTINATION_E01"
  echo "Created destination directory: $DESTINATION_E01"
fi

# Check for and install sshpass
install_sshpass() {
  if ! command -v sshpass &> /dev/null; then
    echo "sshpass is not installed. Attempting to install..."
    if command -v apt-get &> /dev/null; then
      sudo apt-get update
      sudo apt-get install -y sshpass
    elif command -v yum &> /dev/null; then
      sudo yum install -y sshpass
    elif command -v dnf &> /dev/null; then
      sudo dnf install -y sshpass
    else
      echo "Error: Could not determine package manager. Please install 'sshpass' manually."
      exit 1
    fi
  fi
}
install_sshpass

# Use sshpass with scp
sshpass -p "$PASSWORD_E02" scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -r "$USER_E02@$HOST_E02:$SOURCE_E02" "$DESTINATION_E01"

if [ $? -eq 0 ]; then
  echo "File transfer complete."
else
  echo "ERROR: File transfer failed."
  exit 1
fi

# --- Create Tar Archive with Timestamp ---
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
TAR_FILE="$DESTINATION_E01/backup_$TIMESTAMP.tar.gz"

# Create the tar.gz archive
TEMP_DIR="$DESTINATION_E01/temp_archive"
mkdir -p "$TEMP_DIR"
cp -r "$DESTINATION_E01"/* "$TEMP_DIR"
tar -czvf "$TAR_FILE" -C "$TEMP_DIR" .

# Check tar exit status
tar_exit_code=$?
if [ "$tar_exit_code" -eq 0 ] || [ "$tar_exit_code" -eq 1 ]; then
  echo "Tar archive created: $TAR_FILE"

  rm -rf "$TEMP_DIR"

    # --- Rotate Backups ---
    # 1. Get a sorted list of existing backup files (oldest first).
    #    - The `sort` command sorts the filenames. The timestamp format makes this work correctly.
    #    - `head -n -N` removes the last N lines (the newest backups).
    BACKUPS_TO_DELETE=$(ls -tr "$DESTINATION_E01/backup_"*.tar.gz | head -n -"$NUM_BACKUPS_TO_KEEP")

    # 2. Delete the oldest backups (if any).
    if [ -n "$BACKUPS_TO_DELETE" ]; then  # Check if the string is NOT empty
        echo "Deleting old backups:"
        echo "$BACKUPS_TO_DELETE" # List files for safety
        rm -f $BACKUPS_TO_DELETE  # Delete
    else
        echo "No old backups to delete."
    fi


  # --- Delete original files on E01
    rm -rf "$DESTINATION_E01/Jagan"
    if [ $? -eq 0 ]; then
        echo "Original files deleted from $DESTINATION_E01"
    else
        echo "ERROR: Failed to delete original files from $DESTINATION_E01."
        exit 1
    fi


else
  echo "ERROR: Failed to create tar archive (tar exit code: $tar_exit_code)."
  rm -rf "$TEMP_DIR"
  exit 1
fi

exit 0



# [root@ip-10-0-1-161 ~]# crontab -e
# crontab: installing new crontab
# [root@ip-10-0-1-161 ~]# crontab -l
# */5 * * * * /root/backup.sh