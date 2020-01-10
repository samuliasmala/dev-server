#!/bin/bash
# Script to create development environment in Ubuntu under Vagrant/Virtualbox

bash bootstrap-common.sh

# GUI
# Install required packages for GUI,
# instructions from https://stackoverflow.com/questions/18878117/using-vagrant-to-run-virtual-machines-with-desktop-environment
sudo apt-get install -y xfce4 virtualbox-guest-dkms virtualbox-guest-utils virtualbox-guest-x11
# Permit anyone to start the GUI
sudo sed -i 's/allowed_users=.*$/allowed_users=anybody/' /etc/X11/Xwrapper.config
# Enable guest tools, not sure if needed
sudo VBoxClient --clipboard
sudo VBoxClient --draganddrop
sudo VBoxClient --display
sudo VBoxClient --checkhostversion
sudo VBoxClient --seamless

# Print instructions
echo "To access GUI:
Login with username: vagrant, password: vagrant via the login prompt on the virtualbox GUI. Then start xfce by running
'startx'"
