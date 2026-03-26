#!/bin/bash

# Check that .ssh folder exists
if [ ! -e $HOME/.ssh/id_ed25519 ]; then
    echo "SSH key not found from $HOME/.ssh/id_ed25519. Please create SSH key pair and add the public key to Github before running this script."
    echo "ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -C \"$USER@$HOSTNAME\""
    exit 1
fi

# Check that git connection works
ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"
if [ $? -ne 0 ]; then
    echo "GitHub SSH connection failed. Please add your public key to GitHub before running this script:"
    echo "https://github.com/settings/keys"
    exit 1
fi

# Move to home directory, required at least to install dotfiles
cd

# Install dotfiles to customize shell
git clone git@github.com:samuliasmala/dotfiles.git dotfiles
echo 'nyyyyyyyyyy' | ./dotfiles/bootstrap.sh

# Source .profile to set ~/.local/bin in PATH
source ~/.profile

# Upgrade system
sudo apt update
sudo apt upgrade -y

# Disable root login and password authentication for better security.
sudo sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
sudo sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo systemctl restart ssh

# Add misc packages
sudo apt install -y tldr zip unzip build-essential ufw tmux mosh net-tools

# Configure firewall
sudo ufw default deny incoming
sudo ufw default allow outgoing
# Allow SSH
sudo ufw allow 22/tcp
# Allow Mosh
sudo ufw allow 60000:61000/udp
sudo yes | sudo ufw enable

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
wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" # This loads nvm

# Set Node default global packages which are installed with nvm install
echo "pm2" > $NVM_DIR/default-packages

# Install Node 24 and default packages
nvm install --no-progress 24

# Use Python3 as default Python
sudo ln -s /usr/bin/python3 /usr/bin/python

# DATABASES
# Install databases
sudo apt install -y postgresql-16 postgresql-contrib-16 postgresql-16-pgvector redis mysql-server
# Databases not started automatically after install in WSL
sudo service postgresql start
sudo service mysql start

# Configure Postgresql
# Create Postgres database and user
sudo -u postgres createuser -s $USER
sudo -u postgres psql -c "CREATE DATABASE $USER WITH ENCODING 'UTF8';"
sudo -u postgres psql -c "ALTER USER $USER WITH ENCRYPTED PASSWORD 'pswd';"
# Enable passwordless access
echo "localhost:5432:*:$USER:pswd" > ~/.pgpass && chmod 0600 ~/.pgpass

# Configure MySQL
sudo mysql -u root --execute="CREATE USER '$USER'@'localhost' IDENTIFIED BY 'pswd';"
sudo mysql -u root --execute="CREATE DATABASE $USER;"
sudo mysql -u root --execute="GRANT ALL PRIVILEGES ON * . * TO '$USER'@'localhost';"
sudo mysql -u root --execute="FLUSH PRIVILEGES;"
# Enable passwordless access
echo "[client]
user = $USER
password = pswd" > ~/.my.cnf && chmod 0600 ~/.my.cnf

# APP SPECIFIC SETTINGS
# Kuura
sudo -u postgres createuser -s kuura
sudo -u postgres psql -c "ALTER USER kuura WITH ENCRYPTED PASSWORD 'kuurataan_kunnolla';"
echo "localhost:5432:*:kuura:kuurataan_kunnolla" >> ~/.pgpass

# Restart Postgres to apply config changes
sudo service postgresql restart

# Install Docker
curl https://get.docker.com | bash
sudo usermod -aG docker $USER
# Install Docker completions (bash-completion package is required)
mkdir -p ~/.local/share/bash-completion/completions
docker completion bash > ~/.local/share/bash-completion/completions/docker

# Install GitHub CLI
sudo mkdir -p -m 755 /etc/apt/keyrings \
	&& out=$(mktemp) && wget -nv -O$out https://cli.github.com/packages/githubcli-archive-keyring.gpg \
	&& cat $out | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
	&& sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
	&& sudo mkdir -p -m 755 /etc/apt/sources.list.d \
	&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
	&& sudo apt update \
	&& sudo apt install gh -y

# Install Claude Code
curl -fsSL https://claude.ai/install.sh | bash

# Print instructions
echo "Run '. .profile' to source .profile (which sources .bashrc etc.) to enable nvm, node and npm. Alternatively start new shell session"
echo "Next:
- Login to GitHub CLI: gh auth login
- Login to Docker: docker login
- Login to Claude Code: claude login
