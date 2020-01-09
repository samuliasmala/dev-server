#!/bin/bash

# Upgrade system
sudo apt update
sudo apt upgrade -y

# Install dotfiles to customize shell
git clone git@github.com:samuliasmala/dotfiles.git .dotfiles
echo 'nnyyyyyyy' | .dotfiles/bootstrap.sh

# Add misc packages
sudo apt install -y tldr zip unzip

# Set timezone to Helsinki
echo "Europe/Helsinki" | sudo tee /etc/timezone
sudo unlink /etc/localtime
sudo ln -s /usr/share/zoneinfo/Europe/Helsinki /etc/localtime

# Locale generation has to be done before postgresql installation, or it should be restarted:
# service postgresql restart
sudo locale-gen fi_FI.UTF-8 en_US.UTF-8

# Set max_user_watches higher to avoid "Error: ENOSPC: System limit for number of file watchers reached" when using Gulp
echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf && sudo sysctl -p

# Install nvm
wget -qO- https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" # This loads nvm

# Set Node default global packages which are installed with nvm install
echo "pm2
sequelize-cli
nodemon" > $NVM_DIR/default-packages

# Install Node 12 and default packages
nvm install --no-progress 12

# Install Yarn
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt update && sudo apt install --no-install-recommends yarn

# Install Docker
curl https://get.docker.com | bash
sudo usermod -aG docker $USER

# Install Docker-compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.25.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

#Install Google Cloud SDK
# Add the Cloud SDK distribution URI as a package source:
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
# Make sure you have apt-transport-https installed:
sudo apt install -y apt-transport-https ca-certificates
# Import the Google Cloud public key:
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
# Update and install the Cloud SDK:
sudo apt update && sudo apt install -y google-cloud-sdk
# Login to Google account
gcloud auth login
# List projects and select one of them
gcloud projects list
echo "To select project run
gcloud config set project PROJECT-ID

To deploy project run
gcloud app deploy"

# Install Heroku cli
curl https://cli-assets.heroku.com/install-ubuntu.sh | sh
heroku --version
heroku login

# DATABASES
# Install and configure database
sudo apt install -y postgresql postgresql-contrib redis
# Create Postgres database and user
sudo -u postgres createuser -s vagrant
sudo -u postgres psql -c "CREATE DATABASE testdb WITH ENCODING 'UTF8';"
sudo -u postgres psql -c "ALTER USER vagrant WITH ENCRYPTED PASSWORD 'pass';"
# Enable passwordless access
echo 'localhost:5432:*:vagrant:pass' > ~/.pgpass && chmod 0600 ~/.pgpass
# Configure postgres to allow connections from Vagrant host
sudo sed -i "s/#listen_address.*/listen_addresses = '*'/" $(find /etc/postgresql -name postgresql.conf)
sudo tee -a  $(find /etc/postgresql -name pg_hba.conf) <<EOF
# Accept all IPv4 connections from Vagrant host (10.0.2.2)
host    all             all             10.0.2.2/32             md5
EOF
sudo systemctl restart postgresql

# Print instructions
echo "Run '. .bashrc' to source .bashrc and enable nvm, node and npm. Alternatively start new shell session

To access GUI:
Login with username: vagrant, password: vagrant via the login prompt on the virtualbox GUI. Then start xfce by running
'startx'"
