#!/bin/bash

# --- Configuration ---
USER_E02="ec2-user"
HOST_E02="18.60.184.24"
PASSWORD_E02="Saijagan@12"  # SSH Keys!
SOURCE_E02="/opt/Jagan*"
DESTINATION_E01="/opt/back-up"
NUM_BACKUPS_TO_KEEP=3
LOG_FILE="/opt/back-up/backup.log"
LOCK_FILE="/tmp/backup.lock"

# Redirect stdout and stderr
exec > >(tee -a "$LOG_FILE") 2>&1

# --- Locking ---
if [ -f "$LOCK_FILE" ]; then
    echo "Backup already running. Exiting."
    exit 0
fi
touch "$LOCK_FILE"

cleanup() {
    rm -f "$LOCK_FILE"
}
trap cleanup EXIT

# --- Script Logic ---

if [ ! -d "$DESTINATION_E01" ]; then
  /bin/mkdir -p "$DESTINATION_E01"
  echo "Created destination directory: $DESTINATION_E01"
fi

# Check for and install sshpass (Full paths for safety)
install_sshpass() {
  if ! /usr/bin/command -v sshpass &> /dev/null; then
    echo "sshpass is not installed. Attempting to install..."
    if /usr/bin/command -v apt-get &> /dev/null; then
      sudo /usr/bin/apt-get update
      sudo /usr/bin/apt-get install -y sshpass
    elif /usr/bin/command -v yum &> /dev/null; then
      sudo /usr/bin/yum install -y sshpass
    elif /usr/bin/command -v dnf &> /dev/null; then
      sudo /usr/bin/dnf install -y sshpass
    else
      echo "Error: Could not determine package manager.  Please install 'sshpass' manually."
       rm -f "$LOCK_FILE" #Clean up lock file
      exit 1
    fi
  fi
}
install_sshpass

# Use sshpass with scp
/usr/bin/sshpass -p "$PASSWORD_E02" /usr/bin/scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -r "$USER_E02@$HOST_E02:$SOURCE_E02" "$DESTINATION_E01"

if [ $? -eq 0 ]; then
  echo "File transfer complete."
else
  echo "ERROR: File transfer failed."
  rm -f "$LOCK_FILE" #Clean up lock file
  exit 1
fi

# --- Create Tar Archive with Timestamp ---
TIMESTAMP=$(/bin/date +%Y%m%d_%H%M%S)
TAR_FILE="$DESTINATION_E01/backup_$TIMESTAMP.tar.gz"
TEMP_DIR="$DESTINATION_E01/temp_archive"

# 1. Create the temporary directory.
/bin/mkdir -p "$TEMP_DIR"

# 2. Copy *only* the contents of Jagan/ into the temporary directory.
/bin/cp -r "$DESTINATION_E01/Jagan/"* "$TEMP_DIR"

# 3. Create the tar archive from the temporary directory.
/bin/tar -czvf "$TAR_FILE" -C "$TEMP_DIR" .

tar_exit_code=$?
if [ "$tar_exit_code" -eq 0 ] || [ "$tar_exit_code" -eq 1 ]; then
  echo "Tar archive created: $TAR_FILE"

  # 4. Delete the temporary directory.
  /bin/rm -rf "$TEMP_DIR"

  # --- Rotate Backups ---
  BACKUPS_TO_DELETE=$(/bin/ls -tr "$DESTINATION_E01/backup_"*.tar.gz | /bin/head -n -"$NUM_BACKUPS_TO_KEEP")
  if [ -n "$BACKUPS_TO_DELETE" ]; then
      echo "Deleting old backups:"
      echo "$BACKUPS_TO_DELETE"
      /bin/rm -f $BACKUPS_TO_DELETE
  else
      echo "No old backups to delete."
  fi

    # 5. Delete original copied directory
    /bin/rm -rf "$DESTINATION_E01/Jagan"
    if [ $? -eq 0 ]; then
        echo "Original files deleted from $DESTINATION_E01"
    else
        echo "ERROR: Failed to delete original files from $DESTINATION_E01."
         rm -f "$LOCK_FILE" #Clean up lock file
        exit 1
    fi

else
  echo "ERROR: Failed to create tar archive (tar exit code: $tar_exit_code)."
  /bin/rm -rf "$TEMP_DIR" # Clean up on failure
   rm -f "$LOCK_FILE" #Clean up lock file
  exit 1
fi
#Clean up lock file on normal exit
exit 0