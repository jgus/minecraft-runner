#!/bin/bash
set -e

# Default UID/GID for minecraft user
MINECRAFT_UID=${MINECRAFT_UID:-1000}
MINECRAFT_GID=${MINECRAFT_GID:-1000}

# Create group if it doesn't exist
if ! getent group minecraft >/dev/null 2>&1; then
    echo "Creating minecraft group with GID $MINECRAFT_GID"
    groupadd --gid "$MINECRAFT_GID" minecraft
else
    echo "Group minecraft already exists"
fi

# Create user if it doesn't exist
if ! id minecraft >/dev/null 2>&1; then
    echo "Creating minecraft user with UID $MINECRAFT_UID"
    useradd --uid "$MINECRAFT_UID" --gid "$MINECRAFT_GID" --create-home --shell /bin/bash minecraft
    passwd -d minecraft
else
    echo "User minecraft already exists"
fi

# Ensure home directory exists and has correct ownership
mkdir -p /home/minecraft
chown minecraft:minecraft /home/minecraft

# SSH keys injection directory
SSH_KEYS_DIR="/ssh-keys-inject"

# Check for SSH host keys
if [ ! -d "$SSH_KEYS_DIR" ]; then
    echo "ERROR: SSH keys directory not found at $SSH_KEYS_DIR"
    echo "Please mount your SSH keys directory to $SSH_KEYS_DIR"
    echo "See README.md for setup instructions"
    exit 1
fi

# Check for required host keys
REQUIRED_HOST_KEYS=(
    "ssh_host_rsa_key"
    "ssh_host_rsa_key.pub"
    "ssh_host_ecdsa_key"
    "ssh_host_ecdsa_key.pub"
    "ssh_host_ed25519_key"
    "ssh_host_ed25519_key.pub"
)

for key in "${REQUIRED_HOST_KEYS[@]}"; do
    if [ ! -f "$SSH_KEYS_DIR/$key" ]; then
        echo "ERROR: Required SSH host key not found: $key"
        exit 1
    fi
done

# Check for authorized_keys
if [ ! -f "$SSH_KEYS_DIR/authorized_keys" ]; then
    echo "ERROR: authorized_keys not found at $SSH_KEYS_DIR/authorized_keys"
    exit 1
fi

# Copy SSH host keys to /etc/ssh
echo "Copying SSH host keys..."
cp "$SSH_KEYS_DIR"/ssh_host_* /etc/ssh/
chmod 600 /etc/ssh/ssh_host_*_key
chmod 644 /etc/ssh/ssh_host_*.pub

# Copy authorized_keys to minecraft user's .ssh directory
echo "Copying authorized_keys..."
mkdir -p /home/minecraft/.ssh
cp "$SSH_KEYS_DIR/authorized_keys" /home/minecraft/.ssh/
chmod 600 /home/minecraft/.ssh/authorized_keys
chown -R minecraft:minecraft /home/minecraft/.ssh
chmod 700 /home/minecraft/.ssh

echo "SSH keys configured successfully"

# Start Minecraft server
sudo -u minecraft -i /usr/local/bin/start.sh

function cleanup()
{
    sudo -u minecraft -i /usr/local/bin/stop.sh
}
trap cleanup EXIT

# Start SSH daemon
mkdir -p /var/run/sshd
/usr/sbin/sshd -D -e
