#!/bin/bash
# Script to create development environment in Ubuntu

# Restore .ssh folder (id_rsa, id_rsa.pub and config files)

bash bootstrap-common.sh

# https://stackoverflow.com/questions/45437824/postgresql-warning-could-not-flush-dirty-data-function-not-implemented
# This fixes "WARNING: could not flush dirty data: Function not implemented" when creating a database
# Should be fixed in WSL2
echo "fsync = off
data_sync_retry = true" | sudo tee -a $(find /etc/postgresql -name postgresql.conf)
sudo service postgresql restart
