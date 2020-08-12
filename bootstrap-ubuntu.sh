#!/bin/bash
# Script to create development environment in Ubuntu

bash bootstrap-common.sh

# Restart Postgres to apply config changes
sudo systemctl restart postgresql

# Install Docker
curl https://get.docker.com | bash
sudo usermod -aG docker $USER

# Install Docker-compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.25.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
