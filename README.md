# Minecraft Runner

A Docker-based Minecraft server runner with SSH access. SSH keys are injected at runtime for security and flexibility.

## Features

- Docker containerized Minecraft server
- SSH access with public key authentication only
- Runtime SSH key injection (no keys in the image)
- Persistent server data via Docker volumes
- Easy deployment with Docker Compose

## Quick Start

### 1. Generate SSH Keys

Create a `ssh-keys` directory and generate the required SSH host keys:

```bash
mkdir -p ssh-keys

# Generate RSA host key
ssh-keygen -t rsa -b 4096 -f ssh-keys/ssh_host_rsa_key -N ""

# Generate ECDSA host key
ssh-keygen -t ecdsa -b 256 -f ssh-keys/ssh_host_ecdsa_key -N ""

# Generate Ed25519 host key
ssh-keygen -t ed25519 -f ssh-keys/ssh_host_ed25519_key -N ""

# Add your public SSH key for authentication
cp ~/.ssh/id_rsa.pub ssh-keys/authorized_keys
```

### 2. Build the Docker Image

```bash
docker build -t your-username/minecraft-runner:latest .
```

### 3. Update docker-compose.yml

Edit [`docker-compose.yml`](docker-compose.yml) and replace `your-username` with your Docker Hub username:

```yaml
services:
  minecraft:
    image: your-username/minecraft-runner:latest
    # ... rest of configuration
```

### 4. Start the Server

```bash
docker-compose up -d
```

### 5. Connect via SSH

```bash
ssh -p 22 minecraft@localhost
```

## SSH Key Injection

SSH keys are injected at runtime via a volume mount to `/ssh-keys-inject`. This approach:

- **Keeps keys out of the image** - No secrets in the Docker image
- **Maintains key stability** - Host keys persist between container restarts
- **Handles permissions correctly** - Keys are copied with proper permissions

### Required Files

The `ssh-keys` directory must contain:

| File | Description |
|------|-------------|
| `ssh_host_rsa_key` | RSA private host key |
| `ssh_host_rsa_key.pub` | RSA public host key |
| `ssh_host_ecdsa_key` | ECDSA private host key |
| `ssh_host_ecdsa_key.pub` | ECDSA public host key |
| `ssh_host_ed25519_key` | Ed25519 private host key |
| `ssh_host_ed25519_key.pub` | Ed25519 public host key |
| `authorized_keys` | Public keys allowed to SSH in |

### Error Handling

The container will fail to start if:
- The `ssh-keys` directory is not mounted
- Any required host key is missing
- The `authorized_keys` file is missing

## Ports

| Port | Protocol | Description |
|------|----------|-------------|
| 22 | TCP | SSH access |
| 25565 | TCP/UDP | Minecraft server |
| 8123 | TCP | Additional Minecraft port |
| 19132 | UDP | Minecraft Bedrock |
| 19133 | UDP | Minecraft Bedrock |

## Volumes

| Volume | Description |
|--------|-------------|
| `./ssh-keys:/ssh-keys-inject:ro` | SSH keys (read-only) |
| `minecraft-data:/home/minecraft/config` | Minecraft server data |

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `MINECRAFT_UID` | 1000 | UID for minecraft user |
| `MINECRAFT_GID` | 1000 | GID for minecraft user |

Set these in [`docker-compose.yml`](docker-compose.yml) to match your host user for better volume permissions:

```yaml
environment:
  - MINECRAFT_UID=1000
  - MINECRAFT_GID=1000
```

## Build Arguments

| Argument | Default | Description |
|----------|---------|-------------|
| `java_ver` | 21 | Java version to install |

Example:

```bash
docker build --build-arg java_ver=21 -t minecraft-runner .
```

## Docker Compose Commands

```bash
# Start the server
docker-compose up -d

# View logs
docker-compose logs -f

# Stop the server
docker-compose down

# Restart the server
docker-compose restart
```

## SSH Configuration

SSH is configured with:
- Password authentication: **disabled**
- Public key authentication: **enabled**

See [`auth.conf`](auth.conf) for SSH configuration.

## Security Notes

1. **Never commit SSH keys** to version control - they are excluded by [`.gitignore`](.gitignore)
2. **Mount SSH keys read-only** to prevent accidental modification
3. **Use strong SSH keys** - at least 4096-bit RSA or Ed25519
4. **Rotate keys periodically** for best security practices

## Troubleshooting

### Container fails to start

Check the logs for SSH key errors:

```bash
docker-compose logs minecraft
```

### SSH connection refused

Ensure:
- The container is running: `docker-compose ps`
- Port 22 is not in use by another service
- Your public key is in `ssh-keys/authorized_keys`

### Permission denied on SSH

Verify:
- Your private key matches the public key in `authorized_keys`
- SSH is using the correct identity file: `ssh -i ~/.ssh/id_rsa -p 22 minecraft@localhost`

## License

See LICENSE file for details.
