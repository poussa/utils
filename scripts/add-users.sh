#!/bin/bash

# Script to add a new user with SSH keys to a remote Linux system

# Check if the correct number of arguments is provided
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <remote_host> <username> <public_key_file>"
    exit 1
fi

REMOTE_HOST=$1
USERNAME=$2
PUBLIC_KEY_FILE=$3

# Check if the public key file exists
if [ ! -f "$PUBLIC_KEY_FILE" ]; then
    echo "Error: Public key file '$PUBLIC_KEY_FILE' not found."
    exit 1
fi

# Add the user and set up SSH keys on the remote host
ssh -o StrictHostKeyChecking=no root@"$REMOTE_HOST" bash -s <<EOF
# Create the user if it doesn't exist
if ! id -u "$USERNAME" >/dev/null 2>&1; then
    useradd -m -s /bin/bash "$USERNAME"
    echo "User $USERNAME created."
else
    echo "User $USERNAME already exists."
fi

# Set up the .ssh directory and authorized_keys file
USER_HOME="/home/$USERNAME"
mkdir -p "\$USER_HOME/.ssh"
chmod 700 "\$USER_HOME/.ssh"

# Add the public key to authorized_keys
cat >> "\$USER_HOME/.ssh/authorized_keys" <<KEY
$(cat "$PUBLIC_KEY_FILE")
KEY

chmod 600 "\$USER_HOME/.ssh/authorized_keys"
chown -R "$USERNAME:$USERNAME" "\$USER_HOME/.ssh"

# Grant sudo access without password
echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$USERNAME
chmod 440 /etc/sudoers.d/$USERNAME

echo "SSH key added and sudo access granted for user $USERNAME."
EOF
