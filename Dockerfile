FROM alpine:latest

# Install Node.js, npm, and nginx
RUN apk add --update nodejs npm nginx

# Install any other packages you need
RUN apk add --no-cache bash curl wget

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
