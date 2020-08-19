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

# Disable 'Utmp slot not found' message when closing screen window
echo "
# Disable 'Utmp slot not found' message
deflogin off" >> ~/.screenrc

echo "Start new shell session to apply umask correctly "
