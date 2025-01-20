FROM alpine:latest

# Install Node.js, npm, and nginx
RUN apk add --update nodejs npm nginx openssh-server bash curl wget

# Install any other packages you need
# RUN apk add --no-cache bash curl wget

RUN ssh-keygen -A

RUN mkdir /var/run/sshd
RUN addgroup -S semem && adduser -S -G semem -s /bin/sh semem
RUN echo "semem:semem" | chpasswd
# root login needs the container run as root?
RUN echo 'root:semem' | chpasswd
RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

COPY scripts/ssh-entry.sh /ssh-entry.sh
RUN chmod +x /ssh-entry.sh
ENTRYPOINT ["/ssh-entry.sh"]

EXPOSE 22

# script instead of RUN /usr/sbin/sshd -D

# Set up nginx
COPY nginx.conf /etc/nginx/nginx.conf
EXPOSE 3770 8311

# Set up a non-root user
RUN adduser -D myuser

# Create necessary directories and set permissions
RUN mkdir -p /home/myuser/app /home/myuser/data

# Set up working directory
WORKDIR /home/myuser/app

# Copy package.json and package-lock.json (if available)
COPY package*.json ./

# Install Node.js dependencies
RUN npm install && chown -R myuser:myuser /home/myuser/app

# Copy your application files
COPY app .

# Change ownership of the app directory to myuser
RUN chown -R myuser:myuser /home/myuser/app

# Create a script to start both nginx and the Node.js app
RUN echo "#!/bin/sh" > /start.sh && \
    echo "nginx" >> /start.sh && \
    echo "su -c 'node app.js > /home/myuser/app/node.log 2>&1' myuser &" >> /start.sh && \
    echo "tail -f /var/log/nginx/access.log /var/log/nginx/error.log /home/myuser/app/node.log" >> /start.sh && \
    chmod +x /start.sh

# Run the start script
CMD ["/start.sh"]
