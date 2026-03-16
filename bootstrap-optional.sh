#!/bin/bash
# Optional packages not installed by default

# Install Conda
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh
bash ~/miniconda.sh -b -p $HOME/.miniconda3
rm ~/miniconda.sh
# The installer will not prompt you for anything, including setup of your shell to activate conda. To add this activation in your current shell session:
eval "$($HOME/.miniconda3/bin/conda shell.bash hook)"
# With this activated shell, you can then install conda’s shell functions for easier access in the future:
conda init
# If you’d prefer that conda’s base environment not be activated on startup, set the auto_activate_base parameter to false:
conda config --set auto_activate_base false
# Add conda-forge - a community effort that provides conda packages for a wide range of software
conda config --add channels conda-forge
conda config --set channel_priority strict

# Install Pypy (faster Python interpreter)
sudo add-apt-repository -y ppa:pypy/ppa
sudo apt install -y pypy3

# Install Google Cloud SDK
# Add the Cloud SDK distribution URI as a package source:
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
# Make sure you have apt-transport-https installed:
sudo apt install -y apt-transport-https ca-certificates
# Import the Google Cloud public key:
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
# Update and install the Cloud SDK:
sudo apt update && sudo apt install -y google-cloud-sdk

# Install Heroku cli
curl https://cli-assets.heroku.com/install-ubuntu.sh | sh
heroku --version

# Print instructions how to login to cli accounts
echo "Login to Heroku account
$ heroku login

Login to Google account
$ gcloud auth login

List projects
$ gcloud projects list

Select project
$ gcloud config set project PROJECT-ID

Deploy project
$ gcloud app deploy"
