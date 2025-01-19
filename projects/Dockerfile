# Base image
FROM node:18-alpine

# Install required packages
RUN apk add --no-cache openssh git

# Create persistent directories
RUN mkdir -p /app /root/.ssh /root/.npm

# Set working directory
WORKDIR /app

# Add volumes for persistence
VOLUME ["/app", "/root/.ssh", "/root/.npm"]

# Expose SSH port
EXPOSE 22

# Start SSH service and keep container running
CMD ["sh", "-c", "/usr/sbin/sshd && tail -f /dev/null"]

COPY setup-repos.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/setup-repos.sh