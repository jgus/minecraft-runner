# SSH Keys Directory

This directory contains SSH keys that are injected into the Minecraft runner container at runtime.

## Required Files

The following files must be present in this directory:

### Host Keys (Required)

| File | Description |
|------|-------------|
| `ssh_host_rsa_key` | RSA private host key (4096-bit recommended) |
| `ssh_host_rsa_key.pub` | RSA public host key |
| `ssh_host_ecdsa_key` | ECDSA private host key |
| `ssh_host_ecdsa_key.pub` | ECDSA public host key |
| `ssh_host_ed25519_key` | Ed25519 private host key |
| `ssh_host_ed25519_key.pub` | Ed25519 public host key |

### User Authentication (Required)

| File | Description |
|------|-------------|
| `authorized_keys` | Public keys allowed to SSH into the container |

## Setup Instructions

### 1. Generate Host Keys

Run these commands from the parent directory:

```bash
# Generate RSA host key (4096-bit)
ssh-keygen -t rsa -b 4096 -f ssh-keys/ssh_host_rsa_key -N ""

# Generate ECDSA host key
ssh-keygen -t ecdsa -b 256 -f ssh-keys/ssh_host_ecdsa_key -N ""

# Generate Ed25519 host key
ssh-keygen -t ed25519 -f ssh-keys/ssh_host_ed25519_key -N ""
```

### 2. Add Your Public Key

Copy your SSH public key to `authorized_keys`:

```bash
# If you have an existing SSH key
cp ~/.ssh/id_rsa.pub ssh-keys/authorized_keys

# Or generate a new key pair for this server
ssh-keygen -t ed25519 -f ~/.ssh/minecraft_server -N ""
cp ~/.ssh/minecraft_server.pub ssh-keys/authorized_keys
```

### 3. Verify Files

Ensure all required files exist:

```bash
ls -la ssh-keys/
```

Expected output:
```
-rw-------  ssh_host_rsa_key
-rw-r--r--  ssh_host_rsa_key.pub
-rw-------  ssh_host_ecdsa_key
-rw-r--r--  ssh_host_ecdsa_key.pub
-rw-------  ssh_host_ed25519_key
-rw-r--r--  ssh_host_ed25519_key.pub
-rw-------  authorized_keys
```

## Security Notes

- **Never commit these files** to version control
- **Keep private keys secure** - they are excluded by `.gitignore`
- **Use strong key types** - Ed25519 or 4096-bit RSA recommended
- **Rotate keys periodically** for best security practices

## Connecting to the Server

After starting the container, connect via SSH:

```bash
ssh -p 22 minecraft@localhost
```

If you generated a specific key for this server:

```bash
ssh -i ~/.ssh/minecraft_server -p 22 minecraft@localhost
```

## Troubleshooting

### Container fails to start

Check that all required files exist:

```bash
ls ssh-keys/ssh_host_* ssh-keys/authorized_keys
```

### Permission denied on SSH

Verify your public key is in `authorized_keys`:

```bash
cat ssh-keys/authorized_keys
```

### Host key verification warnings

If you see a host key verification warning, you may need to update your `known_hosts`:

```bash
ssh-keygen -R [localhost]:22
```
