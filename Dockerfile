FROM debian:bookworm-slim AS base

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

# Switch to non-root user
USER agent

# Set environment variables for .NET
ENV DOTNET_ROOT=/home/agent/.dotnet
ENV PATH=$PATH:$DOTNET_ROOT:$DOTNET_ROOT/tools

RUN node -v \
    npm -v \
    yarn -v \
    pnpm -v \
    dotnet --version \
    git --version 

# Drop to shell or your desired command
CMD ["/bin/bash"]