#!/bin/bash

# Copyright 2013 Google Inc. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

GRITS_HOME=/grits
mkdir $GRITS_HOME
cd $GRITS_HOME

# Download required packages from Google Cloud Storage
gsutil -m cp {{ cloud_storage }}/google_appengine_*.tar.gz  \
             {{ cloud_storage }}/node-v0.*-linux-x64.tar.gz  \
             {{ cloud_storage }}/gritsgame.tar.gz .

# Set up AppEngine SDK and development server.
tar zxf google_appengine_*.tar.gz

# Set up node.js
tar zxf node-v0.*-linux-x64.tar.gz
ln -s node-v0.*-linux-x64 node_js

export PATH=$GRITS_HOME/google_appengine:$GRITS_HOME/node_js/bin:$PATH

# Extract GRITS game files.
tar zxf gritsgame.tar.gz
perl -pi -e 's/MATCHER_HOST = "localhost"/MATCHER_HOST = "{{ ip_address }}"/' \
    gritsgame/src/games-server/main.js

# Start game.
cd gritsgame/src/
npm install socket.io express
./games-server.sh &
./client.sh &
