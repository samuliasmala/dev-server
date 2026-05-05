#!/bin/bash
# Script to create development environment for Claude Code on Ubuntu

if [ ! -f ~/.config/github.pat ]; then
  echo "Error: ~/.config/github.pat not found."
  echo ""
  echo "To create a GitHub fine-grained personal access token:"
  echo "  1. Go to https://github.com/settings/tokens?type=beta"
  echo "  2. Click 'Generate new token'"
  echo "  3. Set a name, resource owner (kuura-health organization) and expiration"
  echo "  4. Repository access: select 'All repositories' (or specific ones if preferred)"
  echo "  5. Under 'Repository permissions', enable:"
  echo "     - Contents: Read and write"
  echo "     - Pull requests: Read and write"
  echo "     - Issues: Read and write"
  echo "     - Metadata: Read-only (selected automatically)"
  echo "  6. Click 'Generate token' and copy the token"
  echo "  7. Save it to ~/.config/github.pat:"
  echo "     mkdir -p ~/.config && echo 'github_pat_...' > ~/.config/github.pat && chmod 600 ~/.config/github.pat"
  exit 1
fi

bash bootstrap-common.sh

# Proactively handle out-of-memory situations
sudo apt-get install systemd-oomd

# Authenticate GitHub CLI using the PAT
gh auth login --with-token < ~/.config/github.pat

# Set GitHub CLI to use SSH when cloning repositories
gh config set git_protocol ssh --host github.com

# Add 8 GB swap file to avoid out of memory errors when running multiple applications
sudo fallocate -l 8G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
grep -q '^/swapfile ' /etc/fstab || echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

# Set swappiness to 10 to reduce swap usage and improve performance
sudo sysctl vm.swappiness=10
echo 'vm.swappiness=10' | sudo tee /etc/sysctl.d/99-swappiness.conf

cat >> ~/.bashrc_local <<"EOF"
# Override Git author and committer in .gitconfig
export GIT_AUTHOR_NAME="Samuli's Claude"
export GIT_COMMITTER_NAME="Samuli's Claude"
export GIT_AUTHOR_EMAIL="samuli.asmala@gmail.com"
export GIT_COMMITTER_EMAIL="samuli.asmala@gmail.com"
EOF
