#!/bin/bash

ssh-keygen -t rsa -b 4096
cat ~/.ssh/id_rsa.pub
read -n 1 -s -r -p "Press any key to continue when you have added id_rsa.pub to Github"

# Install dotfiles to customize shell
git clone git@github.com:samuliasmala/dotfiles.git .dotfiles
echo 'nyyyyyyyy' | .dotfiles/bootstrap.sh

# Add login key to .shh/authorized_keys
cat server/id_rsa.pub >> ~/.ssh/authorized_keys
