#!/bin/bash

set -e

# Update and install dependencies
apt-get update -y
apt-get install -y lsb-release jq gnupg git curl ca-certificates libc6 libgcc-s1 libgssapi-krb5-2 libicu72 libssl3 libstdc++6 zlib1g

# Install Node.js
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
NODE_MAJOR=20
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list
apt update -y && apt install -y nodejs

# Install Yarn and PNPM
npm install -g yarn pnpm @angular/cli vite
npm cache clean --force

# Download the Microsoft GPG key and save it to a file
curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /etc/apt/keyrings/microsoft.gpg
# Define the OS version
OS_VERSION=$(lsb_release -r | awk '{print $2}')
# Get the distribution codename
OS_CODENAME=$(lsb_release -cs)
# Get the OS name e.g Debian, Ubuntu
OS_NAME=$(lsb_release -i | cut -f2 | tr '[:upper:]' '[:lower:]')
# Add the Microsoft repository to the system's sources list
echo "deb [signed-by=/etc/apt/keyrings/microsoft.gpg] https://packages.microsoft.com/$OS_NAME/$OS_VERSION/prod $OS_CODENAME main" | tee /etc/apt/sources.list.d/microsoft-prod.list

# Install .NET
apt-get update -y && apt-get upgrade -y
apt-get install dotnet-sdk-8.0 -y
apt-get install dotnet-runtime-8.0 -y

# Install .NET tools
dotnet workload update
dotnet tool install --global dotnet-ef
dotnet tool install --global dotnet-reportgenerator-globaltool

# Install PowerShell
sudo apt-get install -y powershell

# Clean up
apt-get autoremove -y && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/*