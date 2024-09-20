#!/bin/bash
# Script to create development environment in Ubuntu

bash bootstrap-common.sh

# Restart Postgres to apply config changes
sudo systemctl restart postgresql

# Install Docker
curl https://get.docker.com | bash
sudo usermod -aG docker $USER
# Install Docker completions (bash-completion package is required)
mkdir -p ~/.local/share/bash-completion/completions
docker completion bash > ~/.local/share/bash-completion/completions/docker
