#!/bin/bash

# Script to install Node.js, PM2, Angular CLI, MongoDB, MySQL, Redis, and Kafka on CentOS 9

# --- WARNING: INCLUDING THE PASSWORD IN THE SCRIPT IS A SECURITY RISK ---
# It's better to set the MYSQL_ROOT_PASSWORD environment variable BEFORE running the script.
# This script will still set it for convenience, but BE AWARE OF THE SECURITY IMPLICATIONS.

# If you get Kafka sevice "Failed". Follow the steps:
# 1. Edit the /etc/systemd/system/kafka.service file:
#sudo nano /etc/systemd/system/kafka.service
            #&
# Comment out the User and Group lines:
#  [Service]
#  Type=simple
#  #User=root  # Comment this out
#  #Group=root # Comment this out
#  ExecStart=/opt/kafka/kafka/bin/kafka-server-start.sh /opt/kafka/kafka/config/server.properties
#  ExecStop=/opt/kafka/kafka/bin/kafka-server-stop.sh

# --- Set the MySQL root password ---
export MYSQL_ROOT_PASSWORD="Jagan@1204"

# --- Check for root privileges ---
if [[ $EUID -ne 0 ]]; then
  echo "This script requires root privileges. Please run with sudo."
  exit 1
fi

# --- Update package lists ---
echo "Updating package lists..."
dnf update -y

# --- Function to handle installation with error checking ---
install_package() {
  local package_name="$1"
  local command="$2"
  echo "Installing $package_name..."
  $command
  if [ $? -eq 0 ]; then
    echo "$package_name installed successfully."
  else
    echo "Error: Failed to install $package_name."
    exit 1
  fi
}

# --- Install Node.js and npm ---
echo "Installing Node.js and npm..."
# Enable the Node.js module
dnf module enable nodejs:18 -y  # Or the desired Node.js version
install_package "Node.js" "dnf install -y nodejs"

# --- Install PM2 ---
install_package "PM2" "npm install -g pm2"

# --- Install Angular CLI ---
install_package "Angular CLI" "npm install -g @angular/cli"

# --- Install MongoDB ---
echo "Installing MongoDB..."
# Create a MongoDB repository file
cat <<EOF | sudo tee /etc/yum.repos.d/mongodb-org.repo
[mongodb-org-7.0]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/\$releasever/mongodb-org/7.0/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-7.0.asc
EOF
install_package "MongoDB" "dnf install -y mongodb-org"

# --- Install MySQL ---
echo "Installing MySQL..."

# Install MySQL Server
install_package "MySQL" "dnf install mysql-server -y"

# Start and Enable MySQL Service
echo "Starting and enabling MySQL service..."
systemctl enable --now mysqld

# Get the MySQL password from an environment variable
# Check if it is empty or not
if [ -z "$MYSQL_ROOT_PASSWORD" ]; then
  echo "Error: Please set the environment variable MYSQL_ROOT_PASSWORD before running this script."
  exit 1
fi

# Secure MySQL Installation
echo "Securing MySQL installation..."

# Get temporary password from log file
TEMPORARY_PASSWORD=$(sudo grep 'temporary password' /var/log/mysqld.log | awk '{print $NF}')

# Set Root Password
echo "Setting MySQL Root Password"
mysql -u root --password="$TEMPORARY_PASSWORD" -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';"

# Removing anonymous user
echo "Removing anonymous users..."
mysql -u root --password="$TEMPORARY_PASSWORD" -e "DELETE FROM mysql.user WHERE User='';"

# Disallow remote root login
echo "Disallowing remote root login..."
mysql -u root --password="$TEMPORARY_PASSWORD" -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"

# Remove test databases and access to them
echo "Removing test databases and access to them..."
mysql -u root --password="$TEMPORARY_PASSWORD" -e "DROP DATABASE IF EXISTS test; DELETE FROM mysql.db WHERE Db='test\\_%';"

# Reload privilege tables
echo "Reloading privilege tables..."
mysql -u root --password="$TEMPORARY_PASSWORD" -e "FLUSH PRIVILEGES;"

# Print root user password instructions
echo "MySQL installation complete!"
echo " "
echo "To access the MySQL shell, run: sudo mysql -u root -p"
echo " "
echo "You can access using user and password. Find root password using following command"
echo "sudo grep 'temporary password' /var/log/mysqld.log"

# --- Install Redis ---
install_package "Redis" "dnf install -y redis"

# --- Install Kafka ---

# First, install Java Development Kit (JDK)
echo "Installing Java Development Kit (JDK) for Kafka..."
install_package "Java Development Kit (JDK)" "dnf install -y java-11-openjdk-devel"

# Set the download directory
KAFKA_DOWNLOAD_DIR=/tmp

# Set the desired Kafka version
KAFKA_VERSION=3.6.1
SCALA_VERSION=2.13
KAFKA="kafka_${SCALA_VERSION}-${KAFKA_VERSION}"
KAFKA_TGZ="${KAFKA}.tgz"

# Construct the Kafka download URL
KAFKA_DOWNLOAD_URL="https://archive.apache.org/dist/kafka/${KAFKA_VERSION}/${KAFKA_TGZ}"

# Set the installation directory
KAFKA_INSTALL_DIR=/opt/kafka

# Create the download directory
mkdir -p ${KAFKA_DOWNLOAD_DIR}

# Create the install directory
mkdir -p ${KAFKA_INSTALL_DIR}

# Download Kafka
echo "Downloading Kafka from ${KAFKA_DOWNLOAD_URL}..."
wget "${KAFKA_DOWNLOAD_URL}" -P ${KAFKA_DOWNLOAD_DIR}

# Check if the Kafka download was successful
if [ -f "${KAFKA_DOWNLOAD_DIR}/${KAFKA_TGZ}" ]; then
    echo "Kafka download successful."
else
    echo "Error: Kafka download failed."
    exit 1
fi

# Extract Kafka
echo "Extracting Kafka..."
tar -xzf ${KAFKA_DOWNLOAD_DIR}/${KAFKA_TGZ} -C ${KAFKA_INSTALL_DIR}

# Rename the Kafka directory to kafka
mv ${KAFKA_INSTALL_DIR}/${KAFKA} ${KAFKA_INSTALL_DIR}/kafka

# Remove the Kafka installation file from the /tmp directory
rm ${KAFKA_DOWNLOAD_DIR}/${KAFKA_TGZ}

# Create Kafka systemd unit file
cat <<EOF | sudo tee /etc/systemd/system/kafka.service
[Unit]
Description=Apache Kafka server
Requires=network.target remote-fs.target
After=network.target remote-fs.target

[Service]
Type=simple
User=root  # Change this to a dedicated kafka user in production
Group=root # Change this to a dedicated kafka group in production
ExecStart=${KAFKA_INSTALL_DIR}/kafka/bin/kafka-server-start.sh ${KAFKA_INSTALL_DIR}/kafka/config/server.properties
ExecStop=${KAFKA_INSTALL_DIR}/kafka/bin/kafka-server-stop.sh

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd daemon
systemctl daemon-reload

# Enable Kafka service to start on boot
systemctl enable kafka

# Start Kafka service
systemctl start kafka

# Check Kafka service status
systemctl status kafka

echo "Installation complete.  Remember to configure databases and set up users/passwords!"
exit 0