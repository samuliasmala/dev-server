#!/bin/bash

# Create own user if only root exists on server
echo "Creating user samuli"
useradd --shell /bin/bash --create-home samuli
echo "Changing password for user samuli"
passwd samuli
sudo usermod -aG sudo samuli
