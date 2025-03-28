FROM alpine:latest

RUN apk add --update --no-cache \
    nodejs \
    npm \
    nginx \
    openssh \
    bash \
    curl \
    wget \
    git \
    && rm -rf /var/cache/apk/*

# SSH Configuration
RUN mkdir -p /var/run/sshd && \
    ssh-keygen -A && \
    sed -i 's/#PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    echo "PermitRootLogin yes" >> /etc/ssh/sshd_config && \
    echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config

# User Setup
RUN adduser -D -s /bin/bash semem && \
    echo "semem:semem" | chpasswd && \
    echo "root:semem" | chpasswd

# Directory Setup
RUN mkdir -p /home/projects && \
    chown -R semem:semem /home/projects && \
    chmod 755 /home/projects

COPY config/scripts/setup-repos.sh /usr/local/bin/
# COPY projects/setup-repos.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/setup-repos.sh

# Create startup script
RUN echo '#!/bin/sh' > /start.sh && \
    echo 'echo "Configuring SSH for password auth..."' >> /start.sh && \
    echo 'sed -i "s/#PermitRootLogin.*/PermitRootLogin yes/" /etc/ssh/sshd_config' >> /start.sh && \
    echo 'sed -i "s/#PasswordAuthentication.*/PasswordAuthentication yes/" /etc/ssh/sshd_config' >> /start.sh && \
    echo 'sed -i "s/PasswordAuthentication no/PasswordAuthentication yes/" /etc/ssh/sshd_config' >> /start.sh && \
    echo 'echo "PermitRootLogin yes" >> /etc/ssh/sshd_config' >> /start.sh && \
    echo 'echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config' >> /start.sh && \
    echo 'echo "Running repository setup..."' >> /start.sh && \
    echo '/usr/local/bin/setup-repos.sh' >> /start.sh && \
    echo 'echo "Starting SSH daemon..."' >> /start.sh && \
    echo '/usr/sbin/sshd -D -e' >> /start.sh && \
    chmod +x /start.sh

EXPOSE 22 3770 8311
ENTRYPOINT ["/start.sh"]