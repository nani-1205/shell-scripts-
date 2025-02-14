#!/bin/bash

# Script to restore a MongoDB database using mongorestore

# Define variables
HOST="18.61.75.247:27017"
DATABASE="Jagan"
USERNAME="ADMIN"
PASSWORD="ADMIN@1234"
AUTHENTICATION_DATABASE="admin"
BACKUP_DIR="/root/backup/Jagan"  # The directory containing the backup data

# Construct the mongorestore command
# Note: If the backup directory contains subdirectories for each collection
# (as it does with the default mongodump output), mongorestore will
# automatically restore the collections to the database.

MONGORESTORE_COMMAND="mongorestore --host=$HOST --gzip --db $DATABASE --username $USERNAME --password '$PASSWORD' --authenticationDatabase $AUTHENTICATION_DATABASE $BACKUP_DIR"

# Alternatively, if your backup is a single compressed file, use:
# MONGORESTORE_COMMAND="mongorestore --host=$HOST --gzip --db $DATABASE --username $USERNAME --password '$PASSWORD' --authenticationDatabase $AUTHENTICATION_DATABASE --archive=$BACKUP_DIR.gz" # Assuming the backup file is named 'Jagan.gz'

# Echo the command for debugging (optional)
echo "Running command: $MONGORESTORE_COMMAND"

# Execute the mongorestore command
$MONGORESTORE_COMMAND

# Check the exit code
if [ $? -eq 0 ]; then
  echo "MongoDB restore successful!"
else
  echo "MongoDB restore failed."
  exit 1  # Exit with an error code
fi

exit 0
