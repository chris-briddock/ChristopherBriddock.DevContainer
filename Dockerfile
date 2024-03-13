FROM debian:bookworm-slim AS base

# Expose Docker socket
VOLUME /var/run/docker.sock

# Copy script
COPY ./init.sh ./

# Create agent user and set up home directory
RUN useradd -m -d /home/agent agent && \
    mkdir /home/agent/.dotnet && \
    mkdir /home/agent/.dotnet/tools

# Own the directory
RUN chown -R agent:agent /home/agent

# Run init script as root
RUN chmod +x ./init.sh && \
    ./init.sh && \
    rm ./init.sh

RUN chown -R agent:agent /usr/share/dotnet/sdk

RUN groupadd docker \
    usermod -aG docker agent \
    newgrp docker 

# Switch to non-root user
USER agent

# Set environment variables for .NET
ENV DOTNET_ROOT=/home/agent/.dotnet
ENV PATH=$PATH:$DOTNET_ROOT:$DOTNET_ROOT/tools
ENV PATH="/usr/lib/node_modules/:${PATH}"

RUN node -v \
    npm -v \
    yarn -v \
    pnpm -v \
    dotnet --version \
    git --version

# Drop to shell
CMD ["/bin/bash"]