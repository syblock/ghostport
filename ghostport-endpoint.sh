#!/bin/sh
set -e

log() {
  echo "[GhostPort-Endpoint] $(date '+%Y-%m-%d %H:%M:%S') - $1"
}

log "Starting GhostPort endpoint..."

log "Connecting to target server: $GHOSTPORT_TARGET_USER@$GHOSTPORT_TARGET_IP:$GHOSTPORT_TARGET_PORT"
log "Forwarding remote port $GHOSTPORT_TARGET_FORWARD_PORT to local ghostport-relay:2080"

SSH_OPTS="-M 0 -N \
  -o StrictHostKeyChecking=no \
  -o ServerAliveInterval=60 \
  -o ServerAliveCountMax=3 \
  -o PreferredAuthentications=password \
  -o PubkeyAuthentication=no"

COMMAND="sshpass -p \"$GHOSTPORT_TARGET_PASS\" autossh $SSH_OPTS \
  -R $GHOSTPORT_TARGET_FORWARD_PORT:ghostport-relay:2080 \
  -p $GHOSTPORT_TARGET_PORT $GHOSTPORT_TARGET_USER@$GHOSTPORT_TARGET_IP"

log "Running command: autossh -R $GHOSTPORT_TARGET_FORWARD_PORT:ghostport-relay:2080 ..."

eval $COMMAND || log "ERROR: autossh failed to start or exited unexpectedly."
