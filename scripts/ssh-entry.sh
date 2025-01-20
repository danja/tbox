#!/bin/sh

# starts openssh (in the container)
/usr/sbin/sshd -D &
tail -f /dev/null
