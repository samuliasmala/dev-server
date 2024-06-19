#!/bin/bash

# Create own user if only root exists on server
useradd --shell /bin/bash --create-home samuli
passwd samuli
sudo usermod -aG sudo samuli
