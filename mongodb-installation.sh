#!/bin/bash

# Script to install MongoDB 8.0 on a Red Hat based system

# Check if the script is run with root privileges
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root."
  exit 1
fi

# --- Step 1: Configure the repository ---

REPO_FILE="/etc/yum.repos.d/mongodb-org-8.0.repo"

cat > "$REPO_FILE" <<EOL
[mongodb-org-8.0]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/9/mongodb-org/8.0/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://pgp.mongodb.com/server-8.0.asc
EOL

echo "MongoDB 8.0 repository configured at $REPO_FILE"

# --- Step 2: Install MongoDB Community Server (Latest Release) ---

echo "Installing the latest stable version of MongoDB..."

yum install -y mongodb-org

if [ $? -eq 0 ]; then
  echo "MongoDB installed successfully."

  # Optional: Start and enable MongoDB service
  systemctl start mongod
  systemctl enable mongod
  echo "MongoDB service started and enabled on boot."

else
  echo "Error installing MongoDB.  Check the output above for details."
  exit 1
fi

# ---  Optional: Check MongoDB version  ---

echo "Checking MongoDB version..."
mongod --version

echo "Installation complete."
exit 0