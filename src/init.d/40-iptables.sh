#!/usr/bin/env bash
# 40-iptables.sh — DNAT: redirect 127.0.0.1:PORT(S) to host.docker.internal:PORT(S)
# Sourced by entrypoint.sh at container startup (runs as root).
#
# Configure via HOST_DOCKER_DNAT_PORTS: comma-separated ports and/or dash ranges.
# Examples: "8000"  |  "8000,5432,6379"  |  "9200-9300"  |  "8000-8100,9500-9600,2000"
#
# Requires: --sysctl net.ipv4.conf.all.route_localnet=1 and cap_add: NET_ADMIN
# (set in docker-compose.yml)

if [ -n "${HOST_DOCKER_DNAT_PORTS:-}" ]; then
  HOST_DOCKER_IP=$(getent hosts host.docker.internal | awk '{ print $1 }')
  if [ -n "$HOST_DOCKER_IP" ]; then
    IFS=',' read -ra _DNAT_ENTRIES <<< "$HOST_DOCKER_DNAT_PORTS"
    for _entry in "${_DNAT_ENTRIES[@]}"; do
      _entry="${_entry// /}"   # trim spaces
      [ -z "$_entry" ] && continue
      if [[ "$_entry" == *-* ]]; then
        # Range: "8000-8010" → iptables dport "8000:8010"
        _port_start="${_entry%-*}"
        _port_end="${_entry#*-}"
        _iptables_dport="${_port_start}:${_port_end}"
        _dest_port="${_port_start}-${_port_end}"
      else
        _iptables_dport="$_entry"
        _dest_port="$_entry"
      fi
      iptables -t nat -A OUTPUT \
        -p tcp -d 127.0.0.1 --dport "$_iptables_dport" \
        -j DNAT --to-destination "${HOST_DOCKER_IP}:${_dest_port}"
      iptables -t nat -A POSTROUTING \
        -p tcp -d "$HOST_DOCKER_IP" --dport "$_iptables_dport" \
        -j MASQUERADE
      echo "DNAT: 127.0.0.1:${_entry} -> ${HOST_DOCKER_IP}:${_entry}"
    done
  else
    echo "WARNING: host.docker.internal not resolved; HOST_DOCKER_DNAT_PORTS skipped" >&2
  fi
fi
