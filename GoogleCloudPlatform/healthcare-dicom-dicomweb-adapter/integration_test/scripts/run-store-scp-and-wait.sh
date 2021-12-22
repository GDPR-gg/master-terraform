#!/bin/bash

set -e
set -o pipefail

export PATH=/opt/apache-maven-3.6.3/bin:$PATH
cd /workspace/dcm4che/dcm4che-tool/dcm4che-tool-storescp
mvn exec:java -ntp -Dexec.mainClass=org.dcm4che3.tool.storescp.StoreSCP -Dexec.args='--bind STORESCP@'$1':'$2' --directory /workspace/integration_test/storescp-data --accept-unknown' &
apt-get -qq update
apt-get -qq install -y netcat-openbsd
echo 'Waiting for connection on port '$3' to finish store-scp step'
echo 'Finishing store-scp step'
