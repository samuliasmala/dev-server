#!/bin/bash
# Script to create development environment in WSL Ubuntu

# Create wsl.conf file
sudo tee /etc/wsl.conf <<EOF
[automount]
# https://github.com/microsoft/WSL/issues/4778
# fmask cannot be 111 because then code and explorer.exe wouldn't work from WSL
options = "metadata,umask=002,fmask=011"
EOF

# https://github.com/microsoft/WSL/issues/352
# Note: Bash on Windows does not currently apply umask properly
# Should be fixed in WSL2
if [ "$(umask)" = "0000" ]; then
    echo >> $HOME/.bashrc_local
    echo "# Note: Bash on Windows does not currently apply umask properly" >> $HOME/.bashrc_local
    echo 'if [ "$(umask)" = "0000" ]; then umask 002; fi' >> $HOME/.bashrc_local
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
