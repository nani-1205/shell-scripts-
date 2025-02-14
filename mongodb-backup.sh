#!/bin/bash

# Variables (modify these!)
HOST="18.61.75.247:27017"
USERNAME="ADMIN"
PASSWORD="ADMIN@1234"
AUTHENTICATION_DATABASE="admin"

# Attempt to connect using the mongo shell
mongo --host "$HOST" -u "$USERNAME" -p "$PASSWORD" --authenticationDatabase "$AUTHENTICATION_DATABASE" <<EOF
  print("Successfully connected to MongoDB!");
  db.version(); // Get the MongoDB server version
  quit();
EOF

# Check the exit code
if [ $? -eq 0 ]; then
  echo "Connection test successful."
else
  echo "Connection test failed. Check credentials and host."
  exit 1 # Exit with an error if the connection fails
fi

exit 0