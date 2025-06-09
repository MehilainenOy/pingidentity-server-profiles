#!/usr/bin/env sh
#
# DESCRIPTION:
# This script modifies the PingFederate configuration to use a JDBC data store
# for various services, replacing the default LDAP implementations.
#

# shellcheck source=./pingcommon.lib.sh
. "${HOOKS_DIR}/pingcommon.lib.sh"

echo "Running custom hook: 02-configure-jdbc-datastore.sh"

# This is the PingFederate internal ID for the JDBC data source we are creating.
DATA_STORE_ID="pf.jwk.jdbc.data.store"

# The file containing the component configurations.
DATA_STORE_FILE="${SERVER_ROOT_DIR}/server/default/data/config-store/org.sourceid.oauth20.domain.ClientManager.xml"

if [ -f "${DATA_STORE_FILE}" ]; then
    echo "Updating ClientManager to use JDBC data store..."
    # Use sed to find the line with item name="PingFederateDSJNDIName" and replace its value with our JDBC data store ID.
    sed -i "s|<item name=\"PingFederateDSJNDIName\">.*</item>|<item name=\"PingFederateDSJNDIName\">${DATA_STORE_ID}</item>|g" "${DATA_STORE_FILE}"
else
    echo "WARN: ${DATA_STORE_FILE} not found. Skipping ClientManager update."
fi

ACCESS_GRANT_FILE="${SERVER_ROOT_DIR}/server/default/data/config-store/org.sourceid.oauth20.token.AccessGrantManager.xml"

if [ -f "${ACCESS_GRANT_FILE}" ]; then
    echo "Updating AccessGrantManager to use JDBC data store..."
    # Use sed to switch the implementation class from LDAP to JDBC.
    sed -i 's|org.sourceid.oauth20.token.AccessGrantManagerLDAPPingDirectoryImpl|org.sourceid.oauth20.token.AccessGrantManagerJdbcImpl|g' "${ACCESS_GRANT_FILE}"
    # Use sed to replace the LDAP data store reference with our JDBC one.
    sed -i "s|<item name=\"PingFederateDSJNDIName\">.*</item>|<item name=\"PingFederateDSJNDIName\">${DATA_STORE_ID}</item>|g" "${ACCESS_GRANT_FILE}"
else
    echo "WARN: ${ACCESS_GRANT_FILE} not found. Skipping AccessGrantManager update."
fi

echo "Finished configuring JDBC data store."
