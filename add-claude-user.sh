#!/bin/bash
# Script to add a user to a claude-type server

if [ $# -ne 4 ]; then
  echo "Usage: $0 <username> <git-name> <git-email> <dotfiles-path>"
  exit 1
fi

USERNAME=$1
GIT_NAME=$2
GIT_EMAIL=$3
DOTFILES=$(realpath "$4")

# Helper function to run commands as the new user
run_as_user() {
  sudo -iu "$USERNAME" "$@"
}

# Create Linux user with bash shell (password left unset)
sudo useradd --shell /bin/bash --create-home "$USERNAME"
sudo usermod -aG sudo "$USERNAME"
sudo usermod -aG docker "$USERNAME"

# Install Oh my tmux (must be before dotfiles since it requires it))
run_as_user bash -c "curl -fsSL 'https://github.com/gpakosz/.tmux/raw/refs/heads/master/install.sh#$(date +%s)' | bash"

# Install dotfiles for the new user
run_as_user bash -c "cd '$DOTFILES' && ./install --all"

# Create Postgres database and user
sudo -u postgres createuser -s "$USERNAME"
sudo -u postgres psql -c "CREATE DATABASE $USERNAME WITH ENCODING 'UTF8';"
sudo -u postgres psql -c "ALTER USER $USERNAME WITH ENCRYPTED PASSWORD 'pswd';"
# Enable passwordless access
sudo -u "$USERNAME" bash -c "echo 'localhost:5432:*:$USERNAME:pswd' > ~/.pgpass && chmod 0600 ~/.pgpass"

# Configure MySQL
sudo mysql -u root --execute="CREATE USER '$USERNAME'@'localhost' IDENTIFIED BY 'pswd';"
sudo mysql -u root --execute="CREATE DATABASE $USERNAME;"
sudo mysql -u root --execute="GRANT ALL PRIVILEGES ON * . * TO '$USERNAME'@'localhost';"
sudo mysql -u root --execute="FLUSH PRIVILEGES;"
# Enable passwordless access
sudo -u "$USERNAME" bash -c "cat > ~/.my.cnf <<EOF
[client]
user = $USERNAME
password = pswd
EOF
chmod 0600 ~/.my.cnf"

# Generate SSH key pair for the new user
run_as_user ssh-keygen -t ed25519 -C "$USERNAME@$(hostname)" -f "/home/$USERNAME/.ssh/id_ed25519" -N ""

# Set GitHub CLI to use SSH when cloning repositories
run_as_user gh config set git_protocol ssh --host github.com

# Install Claude Code for the new user
run_as_user bash -c "curl -fsSL https://claude.ai/install.sh | bash"

# Install nvm
run_as_user bash -c "wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash"

# Append user section to .gitconfig
sudo -u "$USERNAME" tee -a "/home/$USERNAME/.gitconfig" > /dev/null <<EOF
[user]
  name  = $GIT_NAME
  email = $GIT_EMAIL
EOF

# Write TODO.md with instructions for the new user
sudo -u "$USERNAME" tee "/home/$USERNAME/TODO.md" > /dev/null <<"EOF"
# TODO

- Login to GitHub CLI: gh auth login
- Login to Claude Code: claude login
EOF
