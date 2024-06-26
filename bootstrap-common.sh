#!/bin/bash

# Check that .ssh folder exists
if [ ! -e $HOME/.ssh/id_rsa ]; then
    echo "Restore .ssh folder (id_rsa, id_rsa.pub and config files)"
    echo "To continue, $HOME/.ssh/id_rsa must exist"
    exit 1
fi

# Move to home directory, required at least to install dotfiles
cd

# Upgrade system
sudo apt update
sudo apt upgrade -y

# Install dotfiles to customize shell
git clone git@github.com:samuliasmala/dotfiles.git .dotfiles
echo 'nyyyyyyyyy' | .dotfiles/bootstrap.sh

# Add misc packages
sudo apt install -y tldr zip unzip build-essential

# Set timezone to Helsinki
echo "Europe/Helsinki" | sudo tee /etc/timezone
sudo unlink /etc/localtime
sudo ln -s /usr/share/zoneinfo/Europe/Helsinki /etc/localtime

# Disable bash bell
sudo sed -i 's/# set bell-style none/set bell-style none/' /etc/inputrc

# Locale generation has to be done before postgresql installation, or it should be restarted:
# service postgresql restart
sudo locale-gen fi_FI.UTF-8 en_US.UTF-8

# Set max_user_watches higher to avoid "Error: ENOSPC: System limit for number of file watchers reached" when using Gulp
echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf && sudo sysctl -p

# Install nvm
wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" # This loads nvm

# Set Node default global packages which are installed with nvm install
echo "pm2" > $NVM_DIR/default-packages

# Install Node 20 and default packages
nvm install --no-progress 20

# Install Yarn
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt update && sudo apt install --no-install-recommends yarn

# Install Conda
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh
bash ~/miniconda.sh -b -p $HOME/.miniconda3
rm ~/miniconda.sh
# The installer will not prompt you for anything, including setup of your shell to activate conda. To add this activation in your current shell session:
eval "$($HOME/.miniconda3/bin/conda shell.bash hook)"
# With this activated shell, you can then install conda’s shell functions for easier access in the future:
conda init
# If you’d prefer that conda’s base environment not be activated on startup, set the auto_activate_base parameter to false:
conda config --set auto_activate_base false
# Add conda-forge - a community effort that provides conda packages for a wide range of software
conda config --add channels conda-forge
conda config --set channel_priority strict

# Use Python3 as default Python
sudo ln -s /usr/bin/python3 /usr/bin/python

# Install Pypy (faster Python interpreter)
sudo add-apt-repository -y ppa:pypy/ppa
sudo apt install -y pypy3


# Install Google Cloud SDK
# Add the Cloud SDK distribution URI as a package source:
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
# Make sure you have apt-transport-https installed:
sudo apt install -y apt-transport-https ca-certificates
# Import the Google Cloud public key:
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
# Update and install the Cloud SDK:
sudo apt update && sudo apt install -y google-cloud-sdk

# Install Heroku cli
curl https://cli-assets.heroku.com/install-ubuntu.sh | sh
heroku --version

# DATABASES
# Install databases
sudo apt install -y postgresql postgresql-contrib redis mysql-server
# Databases not started automatically after install in WSL
sudo service postgresql start
sudo service mysql start

# Cofigure Postgresql
# Create Postgres database and user
sudo -u postgres createuser -s $USER
sudo -u postgres psql -c "CREATE DATABASE $USER WITH ENCODING 'UTF8';"
sudo -u postgres psql -c "ALTER USER $USER WITH ENCRYPTED PASSWORD 'pswd';"
# Enable passwordless access
echo "localhost:5432:*:$USER:pswd" > ~/.pgpass && chmod 0600 ~/.pgpass
# Configure postgres to allow connections from Vagrant host
sudo sed -i "s/#listen_address.*/listen_addresses = '*'/" $(find /etc/postgresql -name postgresql.conf)
sudo tee -a  $(find /etc/postgresql -name pg_hba.conf) <<EOF
# Accept all IPv4 connections from Vagrant host (10.0.2.2)
host    all             all             10.0.2.2/32             md5
EOF

# Configure MySQL
sudo mysql -u root --execute="CREATE USER '$USER'@'localhost' IDENTIFIED BY 'pswd';"
sudo mysql -u root --execute="CREATE DATABASE $USER;"
sudo mysql -u root --execute="GRANT ALL PRIVILEGES ON * . * TO '$USER'@'localhost';"
sudo mysql -u root --execute="FLUSH PRIVILEGES;"
# Enable passwordless access
echo "[client]
user = $USER
password = pswd" > ~/.my.cnf && chmod 0600 ~/.my.cnf

# Print instructions
echo "Run '. .bashrc' to source .bashrc and enable nvm, node and npm. Alternatively start new shell session"

# APP SPECIFIC SETTINGS
# Kuura
sudo -u postgres createuser -s kuura
sudo -u postgres psql -c "ALTER USER kuura WITH ENCRYPTED PASSWORD 'kuurataan_kunnolla';"
echo "localhost:5432:*:kuura:kuurataan_kunnolla" >> ~/.pgpass
# VTI
sudo mysql -u root --execute="CREATE DATABASE vti_backend;"

# Print instructions how to login to cli accounts
echo "Login to Heroku account
$ heroku login

Login to Google account
$ gcloud auth login

List projects
$ gcloud projects list

Select project
$ gcloud config set project PROJECT-ID

Deploy project
$ gcloud app deploy"
