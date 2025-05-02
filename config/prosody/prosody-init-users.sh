#!/bin/bash
# prosody-init-users.sh: Create default XMPP users for Prosody
set -e

# Wait for Prosody to be ready
sleep 3

# Add users (idempotent: will not overwrite existing users)
add_user() {
  local jid="$1"
  local password="$2"
  if prosodyctl user info "$jid" > /dev/null 2>&1; then
    echo "User $jid already exists."
  else
    echo -e "$password\n$password" | prosodyctl adduser "$jid"
    echo "User $jid created."
  fi
}

add_user danja@localhost Claudiopup
add_user alice@localhost wonderland
add_user bob@localhost builder

exit 0
