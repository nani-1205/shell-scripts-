#!/bin/bash

# Script to install MySQL on RHEL 9 or CentOS 9

# Check if the script is run with root privileges
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root."
  exit 1
fi

# --- Step 1: Update the system ---
echo "Updating the system..."
dnf update -y

if [ $? -ne 0 ]; then
  echo "Error updating the system. Please check your internet connection and try again."
  exit 1
fi

# --- Step 2: Install MySQL Server ---
echo "Installing MySQL Server..."
dnf install mysql-server -y

if [ $? -ne 0 ]; then
  echo "Error installing MySQL Server.  Check the output above for details."
  exit 1
fi

# --- Step 3: Start and Enable MySQL Service ---
echo "Starting and enabling MySQL service..."
systemctl enable --now mysqld

if [ $? -ne 0 ]; then
  echo "Error starting and enabling MySQL service.  Check the output above for details."
  exit 1
fi

# --- Step 4: Secure MySQL Installation ---
echo "Securing MySQL installation..."
mysql_secure_installation

# The mysql_secure_installation script is interactive, so the script can't 
# automatically answer the questions.  The user will need to provide input.
# It's better to leave this as an interactive step for security reasons.

# --- Step 5: Access MySQL (Informational Only - Cannot be automated) ---
echo "MySQL installation complete!"
echo " "
echo "To access the MySQL shell, run: sudo mysql"
echo " "
echo "You can also access using user and password. Find root password using following command"
echo "sudo grep 'temporary password' /var/log/mysqld.log"

exit 0