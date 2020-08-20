#!/bin/bash
# Script to create development environment in WSL2 Ubuntu

# Create wsl.conf file
sudo tee /etc/wsl.conf <<EOF
[automount]
# https://github.com/microsoft/WSL/issues/4778
# fmask cannot be 111 because then code and explorer.exe wouldn't work from WSL
options = "metadata,umask=002,fmask=011"
EOF

bash bootstrap-common.sh

# Restart Postgres to apply config changes
sudo service postgresql restart

# Start services when logging in if not started already
echo "
# Start services on login without requiring a password
$USER ALL=(ALL:ALL) NOPASSWD: /usr/sbin/service
" | sudo EDITOR='tee -a' visudo

echo "
# Start services if not already started
sudo service postgresql status > /dev/null || sudo service postgresql start
sudo service mysql status > /dev/null || sudo service mysql start
sudo service redis-server status > /dev/null || sudo service redis-server start
" >> ~/.bashrc_local

# Disable 'Utmp slot not found' message when closing screen window
echo "
# Disable 'Utmp slot not found' message
deflogin off" >> ~/.screenrc

echo "Start new shell session to apply umask correctly "
