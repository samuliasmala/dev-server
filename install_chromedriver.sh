#!/bin/bash

# Find the URL of the ChromeDriver version that matches your Chrome version
# and replace below: https://chromedriver.chromium.org/

wget https://chromedriver.storage.googleapis.com/88.0.4324.96/chromedriver_linux64.zip
unzip chromedriver_linux64.zip
sudo mv chromedriver /usr/bin/chromedriver
sudo chown root:root /usr/bin/chromedriver
sudo chmod +x /usr/bin/chromedriver
chromedriver --version
