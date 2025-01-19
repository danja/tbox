# Base image
FROM node:18-alpine

# Install required packages
RUN apk add --no-cache openssh git && \
    npm install -g pm2

# Create persistent directories
RUN mkdir -p /app /root/.ssh /root/.npm

# Set working directory
WORKDIR /app

# Add volumes for persistence
VOLUME ["/app", "/root/.ssh", "/root/.npm"]

# Copy PM2 ecosystem config
COPY ecosystem.config.js /app/

# Expose SSH port
EXPOSE 22

# Start PM2 in runtime mode
CMD ["pm2-runtime", "start", "/app/ecosystem.config.js"]

COPY setup-repos.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/setup-repos.sh