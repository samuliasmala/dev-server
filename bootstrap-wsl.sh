#!/bin/bash
# Script to create development environment in Ubuntu

# Check that .ssh folder exists
if [ ! -e $HOME/.ssh/id_rsa ]; then
    echo "Restore .ssh folder (id_rsa, id_rsa.pub and config files)"
    echo "To continue, $HOME/.ssh/id_rsa must exist"
    exit 1
fi

# https://github.com/microsoft/WSL/issues/352
# Note: Bash on Windows does not currently apply umask properly
# Should be fixed in WSL2
if [ "$(umask)" = "0000" ]; then
    echo >> $HOME/.bashrc
    echo "# Note: Bash on Windows does not currently apply umask properly" >> $HOME/.bashrc
    echo 'if [ "$(umask)" = "0000" ]; then umask 002; fi' >> $HOME/.bashrc
    umask 002
fi

bash bootstrap-common.sh

# https://stackoverflow.com/questions/45437824/postgresql-warning-could-not-flush-dirty-data-function-not-implemented
# This fixes "WARNING: could not flush dirty data: Function not implemented" when creating a database
# Should be fixed in WSL2
echo "fsync = off
data_sync_retry = true" | sudo tee -a $(find /etc/postgresql -name postgresql.conf)
sudo service postgresql restart

echo "Start new shell session to apply umask correctly "
