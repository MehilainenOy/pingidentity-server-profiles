#!/usr/bin/env sh

# This hook script configures PingFederate to use the JDBC data store (PostgreSQL)
# for OAuth client management and Access Grant storage, instead of the default
# which looks for a PingDirectory (LDAP) server.

set -e

echo "Running custom hook: 02-configure-jdbc-datastore.sh"

CONFIG_STORE_DIR="${SERVER_ROOT_DIR}/server/default/data/config-store"
CLIENT_MANAGER_CONFIG_FILE="${CONFIG_STORE_DIR}/org.sourceid.oauth20.domain.ClientManager.xml"
ACCESS_GRANT_MANAGER_CONFIG_FILE="${CONFIG_STORE_DIR}/org.sourceid.oauth20.token.AccessGrantManager.xml"

# --- Configure OAuth Client Manager to use JDBC ---
echo "Creating ${CLIENT_MANAGER_CONFIG_FILE}..."
cat > "${CLIENT_MANAGER_CONFIG_FILE}" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<c:config xmlns:c="http://www.sourceid.org/2004/05/config">
    <c:item name="PingFederateDSJNDIName">pingfederate-datasource</c:item>
    <c:item name="UseHashedClientSecret">true</c:item>
</c:config>
EOF

# --- Configure Access Grant Manager to use JDBC ---
echo "Creating ${ACCESS_GRANT_MANAGER_CONFIG_FILE}..."
cat > "${ACCESS_GRANT_MANAGER_CONFIG_FILE}" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<c:config xmlns:c="http://www.sourceid.org/2004/05/config">
    <c:item name="PingFederateDSJNDIName">pingfederate-datasource</c:item>
    <c:item name="DataStore-Type">JDBC</c:item>
</c:config>
EOF

echo "JDBC data store configuration complete."
