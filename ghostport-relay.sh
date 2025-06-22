#!/bin/sh
set -e

# Utility: Log function with timestamp
log() {
    echo "[GhostPort-Relay] $(date '+%Y-%m-%d %H:%M:%S') - $1"
}

# Shared SSH options
SSH_OPTS="-M 0 -N -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
          -o ServerAliveInterval=60 -o ServerAliveCountMax=3 \
          -o PreferredAuthentications=password -o PubkeyAuthentication=no"

# Main logic
if [ "$GHOSTPORT_SOURCE_IP" = "localhost" ]; then
    log "Mode: SOCKS proxy"
    log "Starting SSH server locally..."
    /usr/sbin/sshd

    log "Starting autossh SOCKS proxy on 0.0.0.0:2080 (via localhost:$GHOSTPORT_SOURCE_PORT)"
    sshpass -p 'root' autossh $SSH_OPTS -D 0.0.0.0:2080 -p "$GHOSTPORT_SOURCE_PORT" root@localhost \
        && log "SOCKS proxy started successfully." \
        || log "❌ Failed to start SOCKS proxy tunnel"
else
    log "Mode: Port forward"
    log "Forwarding remote port $GHOSTPORT_SOURCE_SERVICE_PORT from $GHOSTPORT_SOURCE_IP to local :2080"

    sshpass -p "$GHOSTPORT_SOURCE_PASS" autossh $SSH_OPTS \
        -L 0.0.0.0:2080:127.0.0.1:$GHOSTPORT_SOURCE_SERVICE_PORT \
        -p "$GHOSTPORT_SOURCE_PORT" "$GHOSTPORT_SOURCE_USER@$GHOSTPORT_SOURCE_IP" \
        && log "Forward tunnel started successfully." \
        || log "❌ Failed to start port forward tunnel"
fi
