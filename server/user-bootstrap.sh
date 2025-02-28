#!/bin/bash

cd ~

ssh-keygen -t rsa -b 4096

cat ~/.ssh/id_rsa.pub
read -n 1 -s -r -p "Press any key to continue when you have added id_rsa.pub to Github (not mandatory)"

# Create authorized_keys file so root can add public key to it
touch ~/.ssh/authorized_keys

# Install dotfiles to customize shell
git clone git@github.com:samuliasmala/dotfiles.git .dotfiles
echo 'nyyyyyyyyy' | .dotfiles/bootstrap.sh

# Install nvm
wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" # This loads nvm

# Set Node default global packages which are installed with nvm install
[ "$(whoami)" = "pm" ] && echo "pm2" > $NVM_DIR/default-packages

# Install Node 20 and default packages
nvm install --no-progress 20

ln -s /opt/www

# Display command to execute to start pm on reboot
[ "$(whoami)" = "pm" ] && pm2 startup
