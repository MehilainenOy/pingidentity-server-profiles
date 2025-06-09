#!/usr/bin/env sh

# This hook script downloads the PostgreSQL JDBC driver and configures 
# PingFederate to use PostgreSQL as its data store.

set -e

# --- This section downloads the PostgreSQL driver ---
# The version of the PostgreSQL JDBC driver to download.
JDBC_DRIVER_VERSION="42.7.3"

# The URL to download the PostgreSQL JDBC driver from.
JDBC_DRIVER_URL="https://jdbc.postgresql.org/download/postgresql-${JDBC_DRIVER_VERSION}.jar"

# The directory where the JDBC driver will be placed inside the container.
LIB_DIR="${SERVER_ROOT_DIR}/server/default/lib"

# The PingFederate datasource configuration file.
PF_DATASOURCE_XML_FILE="${SERVER_ROOT_DIR}/server/default/data/config-store/pf.datasource.xml"

# The Hibernate properties file for PingFederate.
PF_HIBERNATE_PROPERTIES_FILE="${SERVER_ROOT_DIR}/server/default/conf/pf.cluster.hibernate.properties"

echo "Running custom hook: 01-configure-postgresql.sh"

# Download the PostgreSQL JDBC driver if it doesn't already exist.
if ! [ -f "${LIB_DIR}/postgresql-${JDBC_DRIVER_VERSION}.jar" ]; then
    echo "Downloading PostgreSQL JDBC driver version ${JDBC_DRIVER_VERSION}..."
    wget -q -O "${LIB_DIR}/postgresql-${JDBC_DRIVER_VERSION}.jar" "${JDBC_DRIVER_URL}"
else
    echo "PostgreSQL JDBC driver already exists."
fi

# --- This section creates the main database connection file ---
# Create the pf.datasource.xml file to configure the PostgreSQL connection.
echo "Creating ${PF_DATASOURCE_XML_FILE}..."
cat > "${PF_DATASOURCE_XML_FILE}" <<EOF
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans.xsd">

    <bean id="pingfederate-datasource"
          class="org.springframework.jdbc.datasource.DriverManagerDataSource">
        <property name="driverClassName" value="org.postgresql.Driver"/>
        <property name="url" value="jdbc:postgresql://\${PF_DB_HOST}:\${PF_DB_PORT}/\${PF_DB_NAME}"/>
        <property name="username" value="\${PF_DB_USERNAME}"/>
        <property name="password" value="\${PF_DB_PASSWORD}"/>
    </bean>
</beans>
EOF

# --- This section tells PingFederate how to talk to PostgreSQL ---
# Create the pf.cluster.hibernate.properties file to configure the Hibernate dialect.
echo "Creating ${PF_HIBERNATE_PROPERTIES_FILE}..."
cat > "${PF_HIBERNATE_PROPERTIES_FILE}" <<EOF
hibernate.dialect=org.hibernate.dialect.PostgreSQLDialect
EOF

echo "PostgreSQL configuration complete."
