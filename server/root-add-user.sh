#!/bin/bash

# Create own user if only root exists on server
echo "Creating user samuli"
useradd --shell /bin/bash --create-home samuli
echo "Changing password for user samuli"
passwd samuli
sudo usermod -aG sudo samuli

# Create Postgres database and user
sudo -u postgres createuser -s samuli
sudo -u postgres psql -c "CREATE DATABASE samuli WITH ENCODING 'UTF8' LC_COLLATE = 'fi_FI.UTF-8' LC_CTYPE = 'fi_FI.UTF-8' TEMPLATE template0;"
