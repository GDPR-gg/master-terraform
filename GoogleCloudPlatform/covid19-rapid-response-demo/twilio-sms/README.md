# Twilio SMS Dialogflow gateway

This directory contains code for a simple webhook gateway between the [Twilio SMS](https://www.twilio.com/sms) product, and Dialogflow agents.

This assumes you have already deployed the Dialogflow agent in your project.

## Step by step instructions

Set up and establish a [Twilio account](https://www.twilio.com/try-twilio).

You will need to grab your SID and Auth Token from the [console](twilio.com/console).

Set up some env vars locally:

    export PROJECT=[your cloud project id]
    export TWILIO_ACCOUNT_SID="xxxxxxxxxxxxxxxxxxxxxxx"
    # Your Auth Token from twilio.com/console
    export TWILIO_AUTH_TOKEN="xxxxxxxxxxxxxxxxxxxxxx"

Build the service image (run from this directory)

    gcloud builds submit --tag gcr.io/$PROJECT/twilio-ccai .

Create a Service Account and grant it permission to call the Dialogflow API 

    gcloud iam service-accounts create twilio-sms
    gcloud projects add-iam-policy-binding $PROJECT \
            --member='serviceAccount:twilio-sms@$PROJECT.iam.gserviceaccount.com' --role='roles/dialogflow.client'

Deploy the bridge service

    gcloud run deploy twilio-ccai \
    --image gcr.io/$PROJECT/twilio-ccai \
    --platform=managed \
    --allow-unauthenticated \
    --service-account=twilio-sms@$PROJECT.iam.gserviceaccount.com \
    --set-env-vars=TWILIO_ACCOUNT_SID=$TWILIO_ACCOUNT_SID,TWILIO_AUTH_TOKEN=$TWILIO_AUTH_TOKEN,GOOGLE_CLOUD_PROJECT=$PROJECT

Once this service has deployed (you may be prompted for some details like regions) you will see a URL.

Copy this URL and go back to the Twilio console.

Create a new "messaging service" https://www.twilio.com/console/sms/services/

Name it "twilio-sms" and choose "mixed" for the use-case

Select the second radio button under **Inbound Settings** for "Send an incoming_message Webhook"

Using your copied URL from the deployed service, paste as

    [your URL]/sms

For primary and fallback

and 

    [your URL]/sms/callback

For the callback URL.  This should include the `https://` scheme portion as well. Leave as HTTP POST for the type.

You should now be able to interact with your agent via SMS - you can use the [Twilio debugger](https://www.twilio.com/console/debugger) and [Cloud Run service logs](https://cloud.google.com/run/docs/logging) to debug if you have issues.




