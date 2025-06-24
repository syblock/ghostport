#!/bin/sh
set -e

log() {
  echo "[GhostPort-Endpoint] $(date '+%Y-%m-%d %H:%M:%S') - $1"
}

export AUTOSSH_GATETIME=0
export AUTOSSH_PIDFILE="/var/run/endpoint_autossh.pid"

if [ "$GHOSTPORT_SOURCE_IP" = "localhost" ] && [ -n "$GHOSTPORT_SOURCE_SERVICE_PORT" ] && [ "$GHOSTPORT_SOURCE_SERVICE_PORT" -ne 0 ]; then
  FORWARD_ADDR="host.docker.internal:$GHOSTPORT_SOURCE_SERVICE_PORT"
else
  FORWARD_ADDR="ghostport-relay:2080"
fi

SSH_OPTS="-M 57260 -N \
  -o StrictHostKeyChecking=no \
  -o UserKnownHostsFile=/dev/null \
  -o ServerAliveInterval=60 \
  -o ServerAliveCountMax=3 \
  -o PreferredAuthentications=password \
  -o PubkeyAuthentication=no \
  -o ExitOnForwardFailure=yes"

log "Starting GhostPort endpoint..."
log "Connecting to target server: $GHOSTPORT_TARGET_USER@$GHOSTPORT_TARGET_IP:$GHOSTPORT_TARGET_PORT"
log "Forwarding local $FORWARD_ADDR to remote port $GHOSTPORT_TARGET_FORWARD_PORT"

while true; do
    log "Attempting to establish remote forward..."
    
    sshpass -p "$GHOSTPORT_TARGET_PASS" autossh $SSH_OPTS \
      -R "$GHOSTPORT_TARGET_FORWARD_PORT:$FORWARD_ADDR" \
      -p "$GHOSTPORT_TARGET_PORT" "$GHOSTPORT_TARGET_USER@$GHOSTPORT_TARGET_IP"

    log "❌ ERROR: autossh failed or tunnel was terminated. Restarting in 10 seconds."
    sleep 10
done