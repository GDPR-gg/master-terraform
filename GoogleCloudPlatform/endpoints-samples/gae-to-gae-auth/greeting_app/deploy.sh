#!/usr/bin/env bash
# Copyright 2018 Google Inc. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


set -o nounset
set -o errexit

if [[ "$#" != "2" ]]; then
  echo "Usage: ./deploy <greeting-project-name> <relay-project-name>"
  exit 1
else
  PROJECT="$1"
  CLIENT_PROJECT="$2"
  SERVICE="${PROJECT}.appspot.com"
fi

gcloud auth login
gcloud config set project "$PROJECT"

rm -rf lib/
pip install --requirement requirements.txt --target lib --ignore-installed


sed -r \
  -e "s#YOUR_PROJECT_ID#${PROJECT}#g" \
  -e "s#CLIENT_PROJECT_ID#${CLIENT_PROJECT}#g" \
  main.py.template > main.py

# Generate OpenAPI spec from Python application code:
# The OpenAPI spec is written to `greetingv1openapi.json`.
python lib/endpoints/endpointscfg.py get_openapi_spec \
  --hostname="${SERVICE}" \
  main.GreetingApi

# Deploy the OpenAPI spec:
gcloud endpoints services deploy greetingv1openapi.json

# Get the latest config version of your service.
CONFIG_VERSION=$(gcloud endpoints configs list \
  --service="$SERVICE" \
  --sort-by="~config_id" --limit=1 --format="value(CONFIG_ID)" \
  | tr -d '[:space:]')

sed \
  -e "s#\${SERVICE}#${SERVICE}#g" \
  -e "s#\${CONFIG_VERSION}#${CONFIG_VERSION}#g" \
  app.yaml.template > app.yaml

gcloud app create --region "us-central" || true
gcloud app deploy $PWD --quiet
