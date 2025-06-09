#!/usr/bin/env sh
#
# DESCRIPTION:
#  This script configures PingFederate to use a PostgreSQL backend.
#

# shellcheck source=./pingcommon.lib.sh
. "${HOOKS_DIR}/pingcommon.lib.sh"

echo "Running custom hook: 01-configure-postgresql.sh"

#
# - Determine the driver version for the database.
# - Download the driver if it does not exist.
#
test -n "${PF_DB_DRIVER_VERSION}" || PF_DB_DRIVER_VERSION=42.2.18
DRIVER_JAR_PATH="${SERVER_ROOT_DIR}/server/default/lib/postgresql-${PF_DB_DRIVER_VERSION}.jar"
if ! test -f "${DRIVER_JAR_PATH}"; then
    echo "Downloading PostgreSQL driver..."
    download_and_verify \
        "https://repo1.maven.org/maven2/org/postgresql/postgresql/${PF_DB_DRIVER_VERSION}/postgresql-${PF_DB_DRIVER_VERSION}.jar" \
        "${DRIVER_JAR_PATH}"
fi

#
# Add the JDBC settings to the main configuration file
#
HIVE_PROPERTIES_FILE="${SERVER_ROOT_DIR}/server/default/conf/META-INF/hivemodule.xml"
echo "Writing hibernate config to ${HIVE_PROPERTIES_FILE}"

cat <<EOF > "${HIVE_PROPERTIES_FILE}"
<config>
  <service-point id="pingfederate-entity-manager-factory" interface="org.hibernate.internal.SessionFactoryImpl">
    <invoke-factory>
      <construct class="org.sourceid.config.PingFederateEmbeddedEntityManagerFactory">
        <set-property name="persistenceUnitName" value="pingfederate-local-ds"/>
        <set-property name="connectionUserName" value="${PF_DB_USERNAME}"/>
        <set-property name="connectionPassword" value="${PF_DB_PASSWORD}"/>
        <set-property name="driverClass" value="org.postgresql.Driver"/>
        <set-property name="connectionURL" value="jdbc:postgresql://${PF_DB_HOST}:${PF_DB_PORT}/${PF_DB_NAME}"/>
        <set-property name="adapter" value="Postgres"/>
      </construct>
    </invoke-factory>
  </service-point>
</config>
EOF

echo "Finished configuring PostgreSQL."
