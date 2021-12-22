#!/usr/bin/env python

# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import logging
import os
import dialogflow_v2 as dialogflow

logging.basicConfig(level=logging.INFO)

def detect_intent(msg, session_id):
    session_client = dialogflow.SessionsClient()

    session = session_client.session_path(os.environ.get('GOOGLE_CLOUD_PROJECT'), session_id)
    # print('Session path: {}\n'.format(session))

    text_input = dialogflow.types.TextInput(
        text=msg, language_code="en-US")

    query_input = dialogflow.types.QueryInput(text=text_input)

    response = session_client.detect_intent(
        session=session, query_input=query_input)

    logging.info('Detected intent: {} (confidence: {})\n'.format(
        response.query_result.intent.display_name,
        response.query_result.intent_detection_confidence))
    
    return response.query_result.fulfillment_text

