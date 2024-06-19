#!/bin/bash
# Run script as root

# Disable prompts during package updates/installations
export DEBIAN_FRONTEND=noninteractive

# Upgrade system
apt update
apt upgrade -y

# Add main packages
apt install -y apache2 redis postgresql postgresql-contrib build-essential inotify-tools python3-pip python

# Add misc packages
apt install -y tldr zip unzip nano screen

# Set timezone to Helsinki
echo "Europe/Helsinki" | tee /etc/timezone
unlink /etc/localtime
ln -s /usr/share/zoneinfo/Europe/Helsinki /etc/localtime

# Disable bash bell
sed -i 's/# set bell-style none/set bell-style none/' /etc/inputrc

# Locale generation has to be done before postgresql installation, or it should be restarted:
locale-gen fi_FI.UTF-8 en_US.UTF-8

# Set max_user_watches higher to avoid "Error: ENOSPC: System limit for number of file watchers reached" when using Gulp
echo fs.inotify.max_user_watches=524288 | tee -a /etc/sysctl.conf && sysctl -p

# Add kuura postgres user and database
echo 'Create postgres user and database'
sudo -u postgres createuser -s kuura
sudo -u postgres psql -c "ALTER USER kuura WITH ENCRYPTED PASSWORD 'kuurataan_kunnolla';"
sudo -u postgres psql -c "CREATE DATABASE kuura WITH ENCODING 'UTF8' LC_COLLATE = 'fi_FI.UTF-8' LC_CTYPE = 'fi_FI.UTF-8' TEMPLATE template0;"

# Configure Apache
echo 'Configure Apache (enable mpm event mode and configure threads etc.)'
a2dismod php7.2 mpm_prefork
a2enmod mpm_event proxy proxy_http ssl rewrite proxy_wstunnel headers expires
sed -i '/^\tStartServers.*/i \\tServerLimit \t\t 32' /etc/apache2/mods-enabled/mpm_event.conf
sed -i 's/^\tThreadLimit.*/\tThreadLimit \t\t 256/' /etc/apache2/mods-enabled/mpm_event.conf
sed -i 's/^\tThreadsPerChild.*/\tThreadsPerChild \t 128/' /etc/apache2/mods-enabled/mpm_event.conf
sed -i 's/^\tMaxRequestWorkers.*/\tMaxRequestWorkers \t 4096/' /etc/apache2/mods-enabled/mpm_event.conf
systemctl restart apache2

# Install Certbot
snap install --classic certbot
ln -s /snap/bin/certbot /usr/bin/certbot

# Add pgvector extension
# Add apt.postgresql.org to sources.list
/usr/share/postgresql-common/pgdg/apt.postgresql.org.sh
# Install pgvector (replace 14 with corresponding psql version)
PG_VERSION=$(psql --version | cut -d' ' -f3 | cut -d. -f1)
apt install postgresql-$PG_VERSION-pgvector

# Create pm user to run services
useradd --create-home pm
passwd pm
mkdir /opt/www
sudo chown pm:pm /opt/www
