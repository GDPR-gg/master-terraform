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

import os
from datetime import datetime, timedelta, timezone
from flask import Flask, abort, request, redirect, session, send_file, jsonify
from functools import wraps
import logging
from agent import detect_intent

from twilio.twiml.messaging_response import MessagingResponse
from twilio.request_validator import RequestValidator
from twilio.rest import Client

# TODO add as env var
SECRET_KEY = 'a secret key'

app = Flask(__name__)
app.config.from_object(__name__)

# this is an attempt to preserve URL scheme for Twilio signature validation, it doesn't seem to work
app.config.update(dict(
  PREFERRED_URL_SCHEME = 'https'
))
logging.basicConfig(level=logging.INFO)

client = Client(os.environ.get('TWILIO_ACCOUNT_SID'), os.environ.get('TWILIO_AUTH_TOKEN'))

callback_base = 'http://b49e1580.ngrok.io/sms/action/'

def validate_twilio_request(f):
    """Validates that incoming requests genuinely originated from Twilio"""
    @wraps(f)
    def decorated_function(*args, **kwargs):
        # Create an instance of the RequestValidator class
        validator = RequestValidator(os.environ.get('TWILIO_AUTH_TOKEN'))

        # Validate the request using its URL, POST data,
        # and X_TWILIO_SIGNATURE header
        # the scheme replace is a hack to reflect the scheme that is being used
        # to generate the signature - which flask seems determined to reflect as http
        # even for services running at https
        request_valid = validator.validate(
            str(request.url).replace('http', 'https'),
            request.form,
            request.headers.get('X-TWILIO-SIGNATURE', ''))

        # Continue processing the request if it's valid, return a 403 error if
        # it's not
        if request_valid:
            return f(*args, **kwargs)
        else:
            logging.info(request.url)
            logging.info(request.headers)
            return abort(403)
    return decorated_function

@app.route("/sms", methods=['GET', 'POST'])
@validate_twilio_request
def sms_reply():
    sender = request.values.get('From')
    sender_msg = request.values.get('Body')
    try:
        response = detect_intent(sender_msg, sender)
    except Exception as e:
        logging.error(e)
        response = "I'm sorry - I wasn't able to process that message"

    resp = MessagingResponse()
    # the callback here is not strictly needed
    resp.message(response)

    return str(resp)

@app.route("/sms/callback", methods=['POST'])
@validate_twilio_request
def incoming_sms():
    message_sid = request.values.get('MessageSid', None)
    message_status = request.values.get('MessageStatus', None)
    logging.info('SID: {}, Status: {}, counter: {}'.format(message_sid, message_status, counter))
    return ('', 204)

if __name__ == "__main__":
    port = os.getenv("PORT", "8080")
    app.run(debug=True, port=port)