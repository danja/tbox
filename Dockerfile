FROM alpine:latest
COPY config/scripts/setup-repos.sh /tmp/
CMD ["cat", "/tmp/setup-repos.sh"]

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

COPY config/scripts/startup.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/startup.sh

COPY config/scripts/setup-repos.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/setup-repos.sh

COPY config/scripts/setup-semem.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/setup-semem.sh

# Copy and set up startup script
COPY config/scripts/startup.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 22 3770 8311
ENTRYPOINT ["/start.sh"]