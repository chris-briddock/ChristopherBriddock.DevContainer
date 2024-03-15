FROM debian:bookworm-slim AS base

# Mount the host's docker socket
VOLUME "/var/run/docker.sock"

# Install dependencies
RUN apt-get update -y && apt-get install -y \
    lsb-release \
    jq \
    gnupg \
    git \
    curl \
    ca-certificates \
    libc6 \
    libgcc-s1 \
    libgssapi-krb5-2 \
    libicu72 \
    libssl3 \
    libstdc++6 \
    zlib1g \
    apt-transport-https \
    software-properties-common \
    unzip

# Install docker
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg && \
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt-get update && \
    apt-get install -y docker-ce docker-ce-cli containerd.io 

# Install node.js
RUN curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
    && NODE_MAJOR=20 \
    && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list \
    && apt update -y \
    && apt install -y nodejs

# Download the Microsoft GPG key and save it to a file
RUN curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /etc/apt/keyrings/microsoft.gpg  && \
    # Define the OS version
    OS_VERSION=$(lsb_release -r | awk '{print $2}') && \
    # Get the distribution codename
    OS_CODENAME=$(lsb_release -cs) && \
    # Get the OS name e.g Debian, Ubuntu
    OS_NAME=$(lsb_release -i | cut -f2 | tr '[:upper:]' '[:lower:]') && \
    # Add the Microsoft repository to the system's sources list
    echo "deb [signed-by=/etc/apt/keyrings/microsoft.gpg] https://packages.microsoft.com/$OS_NAME/$OS_VERSION/prod $OS_CODENAME main" | tee /etc/apt/sources.list.d/microsoft-prod.list

# Install .NET
RUN apt-get update -y && apt-get upgrade -y && \
    apt-get install dotnet-sdk-8.0 -y && \
    apt-get install dotnet-runtime-8.0 -y

# Download PowerShell package
RUN curl -fsSL -o powershell.deb https://github.com/PowerShell/PowerShell/releases/download/v7.4.1/powershell_7.4.1-1.deb_amd64.deb && \
    # Install PowerShell package
    dpkg -i powershell.deb && \
    # Install any missing dependencies
    apt-get install -f && \
    # Clean up downloaded package
    rm powershell.deb

# Clean up
RUN apt-get autoremove -y && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/*

# Create agent user and set up home directory
RUN useradd -m -d /home/agent agent && \
    mkdir /home/agent/.dotnet && \
    mkdir /home/agent/.dotnet/tools

# Own the user home directory
RUN chown -R agent:agent /home/agent
# Own the dotnet directory
RUN chown -R agent:agent /usr/share/dotnet/sdk
# Own the global node_modules to enable global installations
RUN chown -R agent:agent /usr/lib/node_modules
# Own the global executable folder which npm symlinks to.
RUN chown -R agent:agent /usr/bin

# Add user to docker group
RUN usermod -aG docker agent && \
    newgrp docker

# Switch to non-root user
USER agent

# Set environment variables for .NET
ENV DOTNET_ROOT=/home/agent/.dotnet
ENV PATH=$PATH:$DOTNET_ROOT:$DOTNET_ROOT/tools
ENV PATH="/usr/lib/node_modules/:${PATH}"
ENV PATH="/usr/bin:${PATH}"

# Check versions for each tool
RUN node -v
RUN npm -v 
RUN dotnet --version
RUN git --version

# Install npm dependencies
RUN npm i -g @angular/cli yarn pnpm vite

RUN yarn -v
RUN pnpm -v
RUN vite --version

# Drop to shell
CMD ["/bin/bash"]