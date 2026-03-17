#!/bin/bash
# Script to create development environment for Claude Code on Ubuntu

if [ ! -f ~/.config/github.pat ]; then
  echo "Error: ~/.config/github.pat not found."
  echo ""
  echo "To create a GitHub fine-grained personal access token:"
  echo "  1. Go to https://github.com/settings/tokens?type=beta"
  echo "  2. Click 'Generate new token'"
  echo "  3. Set a name and expiration"
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

# Authenticate GitHub CLI using the PAT
gh auth login --with-token < ~/.config/github.pat

cat >> ~/.bashrc_local <<"EOF"
# Override Git author and committer in .gitconfig
export GIT_AUTHOR_NAME="Samuli's Claude"
export GIT_COMMITTER_NAME="Samuli's Claude"
export GIT_AUTHOR_EMAIL="samuli.asmala@gmail.com"
export GIT_COMMITTER_EMAIL="samuli.asmala@gmail.com"
EOF
