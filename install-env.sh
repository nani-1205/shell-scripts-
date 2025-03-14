#!/bin/bash

# Script to install Angular, Node, MySQL, Redis, and Nginx on Amazon Linux 2023
# **WARNING: This script uses yum/dnf and RPM instead of dnf modules for MySQL.  This is NOT the recommended approach for Amazon Linux 2023 and may cause conflicts, even with the EL9 RPM.**
# **SERIOUS WARNING: This script includes --nogpgcheck which DISABLES a critical security measure. ONLY use if you fully trust the RPM source and understand the risks!**

# Define default values for versions
ANGULAR_VERSION="17.3.0"
NODE_VERSION="18.13.0"
MYSQL_VERSION="8.0.36"  # Only used for informational purposes now.
REDIS_VERSION="7.0.12"
NGINX_VERSION="1.24.0"

# ---  Helper Functions ---

log_info() {
  echo -e "\e[34m[INFO] $(date '+%Y-%m-%d %H:%M:%S') - $1\e[0m"
}

log_success() {
  echo -e "\e[32m[SUCCESS] $(date '+%Y-%m-%d %H:%M:%S') - $1\e[0m"
}

log_error() {
  echo -e "\e[31m[ERROR] $(date '+%Y-%m-%d %H:%M:%S') - $1\e[0m"
}

# Check for root privileges
if [[ $EUID -ne 0 ]]; then
  log_error "This script requires root privileges. Please run with sudo."
  exit 1
fi

# --- Update System ---
log_info "Updating system packages..."
dnf update -y

dnf install -y epel-release

dnf install -y dnf-plugins-core

dnf config-manager --set-enabled crb

# --- Install Node.js and npm ---
log_info "Installing Node.js ${NODE_VERSION} and npm..."

# Install nvm (Node Version Manager) if not already present
if ! command -v nvm &> /dev/null
then
  log_info "Installing nvm..."
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
fi

# Reload shell to recognize nvm
export NVM_DIR="$HOME/.nvm"
source "$NVM_DIR/nvm.sh"
source "$NVM_DIR/bash_completion"

# Ensure nvm is working
if ! command -v nvm &> /dev/null; then
  log_error "NVM is not available. Please restart your shell and try again."
  exit 1
fi

# Install the specified Node.js version
nvm install "${NODE_VERSION}"
nvm use "${NODE_VERSION}"
nvm alias default "${NODE_VERSION}"

# Verify Node.js and npm
if ! command -v node &> /dev/null || ! command -v npm &> /dev/null; then
  log_error "Node.js and npm installation failed."
  exit 1
fi

log_success "Node.js $(node -v) and npm $(npm -v) installed successfully."

# --- Install Angular CLI ---
log_info "Installing Angular CLI ${ANGULAR_VERSION}..."
npm install -g @angular/cli@"${ANGULAR_VERSION}"

if [ $? -ne 0 ]; then
  log_error "Failed to install Angular CLI."
  exit 1
fi
log_success "Angular CLI $(ng version | grep 'Angular CLI:' | awk '{print $3}') installed successfully."

# --- Install MySQL ---
log_info "Installing MySQL ${MYSQL_VERSION} using dnf and EL9 RPM (NOT RECOMMENDED, --nogpgcheck USED)..."

# Download the MySQL 8.0 Community Release RPM
log_info "Downloading MySQL 8.0 Community Release RPM..."
wget https://dev.mysql.com/get/mysql80-community-release-el9-1.noarch.rpm
if [ $? -ne 0 ]; then
  log_error "Failed to download MySQL RPM. Check the URL."
  exit 1
fi

# Install the MySQL 8.0 Community Release RPM
log_info "Installing MySQL 8.0 Community Release RPM..."
dnf install mysql80-community-release-el9-1.noarch.rpm -y --nogpgcheck
if [ $? -ne 0 ]; then
  log_error "Failed to install MySQL RPM."
  exit 1
fi

# Install the MySQL server package
log_info "Installing mysql-community-server..."
dnf install mysql-community-server -y --nogpgcheck
if [ $? -ne 0 ]; then
  log_error "Failed to install mysql-community-server using dnf."
  exit 1
fi

# Start the MySQL service
log_info "Starting mysqld service..."
systemctl start mysqld
if [ $? -ne 0 ]; then
  log_error "Failed to start mysqld."
  exit 1
fi

# Enable the MySQL service to start on boot
log_info "Enabling mysqld service to start on boot..."
systemctl enable mysqld
if [ $? -ne 0 ]; then
  log_error "Failed to enable mysqld."
  exit 1
fi

log_success "MySQL $(mysql --version) installed successfully."

# --- Install Redis ---
log_info "Installing Redis ${REDIS_VERSION}..."

dnf install -y redis6

systemctl enable redis6
systemctl start redis6

if [ $? -ne 0 ]; then
  log_error "Failed to install Redis."
  exit 1
fi

log_success "Redis $(redis-server --version | awk '{print $3}') installed successfully."

# --- Install Nginx ---
log_info "Installing Nginx ${NGINX_VERSION}..."

dnf install -y nginx

systemctl enable nginx
systemctl start nginx

if [ $? -ne 0 ]; then
  log_error "Failed to install Nginx."
  exit 1
fi
log_success "Nginx $(nginx -v 2>&1 | awk -F/ '{print $2}') installed successfully."

# --- Verify Installed Versions ---
log_info "Verifying installed versions..."
echo "Node.js: $(node -v)"
echo "npm: $(npm -v)"
echo "Angular CLI: $(ng version | grep 'Angular CLI:' | awk '{print $3}')"
echo "MySQL: $(mysql --version)"
echo "Redis: $(redis-server --version | awk '{print $3}')"
echo "Nginx: $(nginx -v 2>&1 | awk -F/ '{print $2}')"

log_success "All components installed successfully (with dnf MySQL - NOT RECOMMENDED, --nogpgcheck USED)!"

exit 0