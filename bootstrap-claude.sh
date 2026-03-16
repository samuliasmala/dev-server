#!/bin/bash
# Script to create development environment for Claude Code on Ubuntu

bash bootstrap-common.sh

cat >> ~/.bashrc_local <<"EOF"
# Override Git author and committer in .gitconfig
export GIT_AUTHOR_NAME="Samuli's Claude"
export GIT_COMMITTER_NAME="Samuli's Claude"
export GIT_AUTHOR_EMAIL="samuli.asmala@gmail.com"
export GIT_COMMITTER_EMAIL="samuli.asmala@gmail.com"
EOF
