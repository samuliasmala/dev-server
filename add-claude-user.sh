#!/bin/bash
# Script to add a user to a claude-type server

if [ $# -ne 1 ]; then
  echo "Usage: $0 <username>"
  exit 1
fi

USERNAME=$1

# Create Linux user with bash shell (password left unset)
sudo useradd --shell /bin/bash --create-home "$USERNAME"
sudo usermod -aG sudo "$USERNAME"
sudo usermod -aG docker "$USERNAME"

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
sudo -u "$USERNAME" ssh-keygen -t ed25519 -C "$USERNAME@$(hostname)" -f "/home/$USERNAME/.ssh/id_ed25519"

# Set GitHub CLI to use SSH when cloning repositories
gh config set git_protocol ssh --host github.com

# Install Claude Code for the new user
sudo -u "$USERNAME" bash -c "curl -fsSL https://claude.ai/install.sh | bash"

# Install nvm and Node 24
sudo -u "$USERNAME" bash -c "wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash"
sudo -u "$USERNAME" bash -c "nvm install --no-progress 24"

# Write TODO.md with GitHub PAT setup instructions for the new user
sudo -u "$USERNAME" tee "/home/$USERNAME/TODO.md" > /dev/null <<"EOF"
# TODO

- Login to GitHub CLI: gh auth login
- Login to Claude Code: claude login
EOF
