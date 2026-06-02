# 20-certs.sh — Register user-supplied CA certificates
# Sourced by entrypoint.sh (inherits: set -euo pipefail)
# Exports: NODE_EXTRA_CA_CERTS (only when certs are present)

USER_CERTS_DIR=/etc/sandbox/certs
NODE_CA_BUNDLE=/tmp/node-ca-bundle.pem

if [ -d "$USER_CERTS_DIR" ]; then
  for cert in "$USER_CERTS_DIR"/*.crt "$USER_CERTS_DIR"/*.pem; do
    [ -f "$cert" ] || continue
    fname=$(basename "$cert")
    cp "$cert" "/usr/local/share/ca-certificates/${fname%.*}.crt"
    cat "$cert" >> "$NODE_CA_BUNDLE"
    echo "Registered CA certificate: $fname"
  done
  update-ca-certificates --fresh > /dev/null 2>&1
fi

[ -f "$NODE_CA_BUNDLE" ] && export NODE_EXTRA_CA_CERTS="$NODE_CA_BUNDLE"
