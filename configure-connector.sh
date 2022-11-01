#!/bin/bash

default_connector_title="Urban Dataspace Connector Title"
default_connector_description="Urban Dataspace Connector Description"
default_connector_password="password"
default_postgres_password="password"

echo -n "Please enter the URL of the connector [e.g. uds.example.com]: "
read connector_url
if [ -z $connector_url ]; then
    echo "Connector URL cannot be empty"
    exit -1
fi

echo -n "Please enter the connector title [$default_connector_title]: "
read connector_title
if [ -z $connector_title ]; then
    connector_title=$default_connector_title
fi

echo -n "Please enter the connector description [$default_connector_description]: "
read connector_description
if [ -z $connector_description ]; then
    connector_description=$default_connector_description
fi

echo -n "Please enter the connector password [$default_connector_password]: "
read connector_password
if [ -z $connector_password ]; then
    connector_password=$default_connector_password
fi

echo -n "Please enter the postgres password [$default_postgres_password]: "
read postgres_password
if [ -z $postgres_password ]; then
    postgres_password=$default_postgres_password
fi

cat > ./.env <<EOF
CONNECTOR_URL=$connector_url
CONNECTOR_TITLE=$connector_title
CONNECTOR_DESCRIPTION=$connector_description
CONNECTOR_PASSWORD=$connector_password
POSTGRES_PASSWORD=$postgres_password
DAPS_URL=https://pilotds-infra.gate-ai.eu
EOF

cat > ./conf/config.json <<EOF
{
  "@context" : {
    "ids" : "https://w3id.org/idsa/core/",
    "idsc" : "https://w3id.org/idsa/code/"
  },
  "@type" : "ids:ConfigurationModel",
  "@id" : "https://w3id.org/idsa/autogen/configurationModel/7672b568-7878-4f62-8032-5c73de969414",
  "ids:configurationModelLogLevel" : {
    "@id" : "idsc:MINIMAL_LOGGING"
  },
  "ids:connectorDeployMode" : {
    "@id" : "idsc:PRODUCTIVE_DEPLOYMENT"
  },
  "ids:connectorDescription" : {
    "@type" : "ids:BaseConnector",
    "@id" : "https://${connector_url}",
    "ids:description" : [ {
      "@value" : "$connector_description",
      "@type" : "http://www.w3.org/2001/XMLSchema#string"
    } ],
    "ids:title" : [ {
      "@value" : "$connector_title",
      "@type" : "http://www.w3.org/2001/XMLSchema#string"
    } ],
    "ids:securityProfile" : {
      "@id" : "idsc:BASE_SECURITY_PROFILE"
    },
    "ids:curator" : {
      "@id" : "https://gate-ai.eu/en/home/"
    },
    "ids:maintainer" : {
      "@id" : "https://gate-ai.eu/en/home/"
    },
    "ids:hasDefaultEndpoint" : {
      "@type" : "ids:ConnectorEndpoint",
      "@id" : "https://${connector_url}/api/ids/data",
      "ids:accessURL" : {
        "@id" : "https://${connector_url}/api/ids/data"
      }
    },
    "ids:inboundModelVersion" : [ "4.0.0", "4.1.0", "4.1.2", "4.2.0", "4.2.1", "4.2.2", "4.2.3", "4.2.4", "4.2.5", "4.2.6", "4.2.7" ],
    "ids:outboundModelVersion" : "4.2.7"
  },
  "ids:trustStore" : {
    "@id" : "file:///config/truststore.p12"
  },
  "ids:connectorStatus" : {
    "@id" : "idsc:CONNECTOR_ONLINE"
  },
  "ids:keyStore" : {
    "@id" : "file:///config/keystore.p12"
  }
}
EOF

echo
echo "The connector was configured with the following parameters:"
echo 
echo "Connector URL         : $connector_url"
echo "Connector Title       : $connector_title"
echo "Connector Description : $connector_description"
echo "Connector Password    : $connector_password"
echo "Postgres Password     : $postgres_password"
echo
echo "Further steps:"
echo
echo "1. Copy keystore.p12 you received into ./conf directory"
echo
echo "2. Copy your server certificate to ./nginx/certs/${connector_url}.crt"
echo
echo "3. Copy your server key to ./nginx/certs/${connector_url}.key"
echo
echo "4. The command 'sudo docker-compose up -d' will run your connector"
