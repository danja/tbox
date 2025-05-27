#!/bin/sh

echo "Configuring SSH for password auth..."
sed -i "s/#PermitRootLogin.*/PermitRootLogin yes/" /etc/ssh/sshd_config
sed -i "s/#PasswordAuthentication.*/PasswordAuthentication yes/" /etc/ssh/sshd_config
sed -i "s/PasswordAuthentication no/PasswordAuthentication yes/" /etc/ssh/sshd_config
echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config

echo "Running repository setup..."
/usr/local/bin/setup-repos.sh

echo "Running SEMEM setup..."
/usr/local/bin/setup-semem.sh

echo "Starting SSH daemon..."
exec /usr/sbin/sshd -D -e
