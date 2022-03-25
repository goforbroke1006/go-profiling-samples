#!/bin/bash

sudo apt update
sudo apt install -y curl

curl -L -O https://hey-release.s3.us-east-2.amazonaws.com/hey_linux_amd64
chmod +x hey_linux_amd64
sudo mv hey_linux_amd64 /usr/local/bin/hey


chmod +x profiling-web.sh
