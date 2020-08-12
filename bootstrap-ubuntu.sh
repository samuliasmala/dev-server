#!/bin/bash
# Script to create development environment in Ubuntu

bash bootstrap-common.sh

# Restart Postgres to apply config changes
sudo systemctl restart postgresql

# Install Docker
curl https://get.docker.com | bash
sudo usermod -aG docker $USER
