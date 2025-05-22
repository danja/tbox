#!/bin/sh
set -e # Exit immediately if a command exits with a non-zero status.

PROSODY_CONFIG_DIR="/etc/prosody"
PROSODY_CERTS_DIR="${PROSODY_CONFIG_DIR}/certs"
PROSODY_DATA_DIR="/var/lib/prosody" # Often where Prosody stores data and certs by default

# Use PROSODY_DOMAIN from environment or default to localhost
TARGET_DOMAIN="${PROSODY_DOMAIN:-localhost}"

KEY_FILE="${PROSODY_CERTS_DIR}/${TARGET_DOMAIN}.key"
CERT_FILE="${PROSODY_CERTS_DIR}/${TARGET_DOMAIN}.crt"
DH_PARAMS_FILE="${PROSODY_CERTS_DIR}/dh.pem" # Prosody often looks for dh.pem

echo "==> ensure-prosody-certs.sh: Running as user: $(id)"
echo "==> ensure-prosody-certs.sh: PROSODY_DOMAIN as seen by script: '${PROSODY_DOMAIN}'"
echo "==> ensure-prosody-certs.sh: TARGET_DOMAIN is being set to: '${TARGET_DOMAIN}'"
echo "==> ensure-prosody-certs.sh: Ensuring Prosody certificate and DH parameters for domain: ${TARGET_DOMAIN}"
echo "==> ensure-prosody-certs.sh: Target certs directory: ${PROSODY_CERTS_DIR}"

# Ensure certs directory exists and has correct permissions
# Prosody usually runs as 'prosody' user.
mkdir -p "${PROSODY_CERTS_DIR}"
# Permissions on the mount point itself are less critical than on the files within.

# Also ensure data directory exists if Prosody needs to write certs there initially
mkdir -p "${PROSODY_DATA_DIR}"
chown -R prosody:prosody "${PROSODY_DATA_DIR}"

# Generate Diffie-Hellman parameters if they don't exist
if [ ! -f "${DH_PARAMS_FILE}" ]; then
    echo "==> ensure-prosody-certs.sh: Diffie-Hellman parameters not found at ${DH_PARAMS_FILE}."
    echo "==> ensure-prosody-certs.sh: Generating Diffie-Hellman parameters (2048 bits)... This may take a few minutes."
    echo "==> ensure-prosody-certs.sh: Current directory listing for ${PROSODY_CERTS_DIR} before generation:"
    ls -la "${PROSODY_CERTS_DIR}"
    # Use a temporary file to avoid permission issues if openssl runs as root
    TEMP_DH_PARAMS_FILE=$(mktemp)
    openssl dhparam -out "${TEMP_DH_PARAMS_FILE}" 2048
    mv "${TEMP_DH_PARAMS_FILE}" "${DH_PARAMS_FILE}"
    chown prosody:prosody "${DH_PARAMS_FILE}"
    chmod 600 "${DH_PARAMS_FILE}"
    echo "==> ensure-prosody-certs.sh: Diffie-Hellman parameters generated at ${DH_PARAMS_FILE}."
    echo "==> ensure-prosody-certs.sh: Current directory listing for ${PROSODY_CERTS_DIR} after generation:"
    ls -la "${PROSODY_CERTS_DIR}"
else
    echo "==> ensure-prosody-certs.sh: Diffie-Hellman parameters already exist at ${DH_PARAMS_FILE}."
fi

# Generate self-signed certificate if key or cert file doesn't exist
if [ ! -f "${KEY_FILE}" ] || [ ! -f "${CERT_FILE}" ]; then
    echo "==> ensure-prosody-certs.sh: Generating self-signed certificate for ${TARGET_DOMAIN}..."
    rm -f "${KEY_FILE}" "${CERT_FILE}" # Clean up any partial certs

    openssl genrsa -out "${KEY_FILE}" 2048
    openssl req -new -x509 -key "${KEY_FILE}" -out "${CERT_FILE}" -days 3650 \
        -subj "/CN=${TARGET_DOMAIN}" \
        -addext "subjectAltName = DNS:${TARGET_DOMAIN}"
    chown prosody:prosody "${KEY_FILE}" "${CERT_FILE}"
    chmod 600 "${KEY_FILE}"    # Private key should be restricted
    chmod 644 "${CERT_FILE}"   # Certificate can be world-readable
    echo "==> ensure-prosody-certs.sh: Self-signed certificate generated: ${KEY_FILE}, ${CERT_FILE}"
else
    echo "==> ensure-prosody-certs.sh: Certificate and key files already exist: ${KEY_FILE}, ${CERT_FILE}"
fi