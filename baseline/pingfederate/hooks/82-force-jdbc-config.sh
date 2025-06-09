#!/usr/bin/env sh

# This hook script ensures that PingFederate is configured to use the JDBC data store,
# overriding any defaults from the initial data.zip deployment.

set -e

echo "Running custom hook: 82-force-jdbc-config.sh"

CONFIG_STORE_DIR="${SERVER_ROOT_DIR}/server/default/data/config-store"
CLIENT_MANAGER_CONFIG_FILE="${CONFIG_STORE_DIR}/org.sourceid.oauth20.domain.ClientManager.xml"
ACCESS_GRANT_MANAGER_CONFIG_FILE="${CONFIG_STORE_DIR}/org.sourceid.oauth20.token.AccessGrantManager.xml"

# --- Configure OAuth Client Manager to use JDBC ---
echo "Forcing JDBC config for Client Manager..."
cat > "${CLIENT_MANAGER_CONFIG_FILE}" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<c:config xmlns:c="http://www.sourceid.org/2004/05/config">
    <c:item name="PingFederateDSJNDIName">pingfederate-datasource</c:item>
    <c:item name="UseHashedClientSecret">true</c:item>
</c:config>
EOF

# --- Configure Access Grant Manager to use JDBC ---
echo "Forcing JDBC config for Access Grant Manager..."
cat > "${ACCESS_GRANT_MANAGER_CONFIG_FILE}" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<c:config xmlns:c="http://www.sourceid.org/2004/05/config">
    <c:item name="PingFederateDSJNDIName">pingfederate-datasource</c:item>
    <c:item name="DataStore-Type">JDBC</c:item>
</c:config>
EOF

echo "Forced JDBC data store configuration complete."
