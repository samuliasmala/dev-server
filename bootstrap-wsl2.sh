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

# The X Server
# Instructions from https://www.gregbrisebois.com/posts/chromedriver-in-wsl2/
cat >> ~/.bashrc_local <<"EOF"
# Add DISPLAY environment variable to tell GUI applications at which IP
# address the X Server is that we want to use
export DISPLAY=$(cat /etc/resolv.conf | grep nameserver | awk '{print $2; exit;}'):0.0

EOF

echo "The X Server:"
echo "Download and install VcXsrv in Windows. Once installed, run xlaunch.exe
(from the VcXsrv folder in Program Files). You can leave most of the settings as
default, but make sure to check “Disable access control”.
"

# Install Chrome
echo "Installing Chrome"
sudo apt-get install -y curl unzip xvfb libxi6 libgconf-2-4
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt install -y ./google-chrome-stable_current_amd64.deb
google-chrome --version

echo "Start new shell session to apply umask correctly "
