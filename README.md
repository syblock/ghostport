
# 👻 GhostPort

**GhostPort** is a lightweight tunneling tool to forward TCP ports or SOCKS proxies between two remote servers **via a relay node**, using Docker and SSH-based tunneling. It supports:

- Forwarding any TCP service from Server A to Server B
- Creating a local SOCKS5 proxy from a remote server
- Automatic tunnel recovery with `autossh`
- Environment-based configuration
- Fully containerized setup using Docker Compose

## ⚙️ How It Works

1. **ghostport-relay**
   Creates a tunnel from the source server.

   * If `GHOSTPORT_SOURCE_IP=localhost`: acts as a SOCKS5 proxy
   * Else: forwards a port from the source server to local

2. **ghostport-endpoint**
   Connects to the target server and exposes the local tunnel there via reverse SSH.

So effectively:

```bash
[Source Server] ──> [Relay Node / GhostPort] ──> [Target Server]
```

## 🚀 Quick Start

### 1. Clone the repository

```bash
git clone https://github.com/syblock/ghostport.git
cd ghostport
```

### 2. Copy and edit `.env`

```bash
cp .env.example .env
nano .env
```

### 3. Run with Docker Compose

```bash
docker compose up --build -d
```

This will:

* Start the `ghostport-relay` container
* Start the `ghostport-endpoint` container (after relay is ready)
* Establish the appropriate tunnel

## 🧾 Example `.env`

```ini
# Source (where the original service runs)
GHOSTPORT_SOURCE_IP=1.2.3.4
GHOSTPORT_SOURCE_USER=root
GHOSTPORT_SOURCE_PASS=my-password
GHOSTPORT_SOURCE_PORT=22
GHOSTPORT_SOURCE_SERVICE_PORT=10086

# Local binding (optional)
GHOSTPORT_LOCAL_FORWARD_PORT=3002

# Target (where you want to expose the forwarded port)
GHOSTPORT_TARGET_IP=5.6.7.8
GHOSTPORT_TARGET_USER=root
GHOSTPORT_TARGET_PASS=other-password
GHOSTPORT_TARGET_PORT=22
GHOSTPORT_TARGET_FORWARD_PORT=2078
```

## 🧰 Modes Supported

| Mode         | Behavior                                                                 |
| ------------ | ------------------------------------------------------------------------ |
| SOCKS Proxy  | Creates a local SOCKS5 proxy via SSH and forwards it to target via relay |
| Port Forward | Forwards a specific TCP port from source to target via relay             |

To switch between modes, just change the `GHOSTPORT_SOURCE_IP` to localhost or server ip

## 📦 Requirements

* Docker
* Docker Compose
* SSH access to both source and target servers

## 🧪 Example Use Cases

* Expose a private **Proxy** port on a different VPS
* Share your local network as a SOCKS5 proxy
* Access a port on a server behind NAT or CGNAT
* Bypass network limitation by routing traffic through a trusted server

## 📖 License

[MIT License](LICENSE)