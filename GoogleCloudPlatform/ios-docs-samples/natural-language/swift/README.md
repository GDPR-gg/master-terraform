# Cloud Natural Language gRPC Swift Sample

This app demonstrates how to make gRPC connections to the [Cloud natural Language API](https://cloud.google.com/natural-language/) 

The app demonstrates how to Analyze below for the user entered text:
- Entity
- Sentiment Analysis
- Syntax
- Category

To call the APIs from iOS, you need to provide authorization tokens with each request for authentication. To get this token, this sample uses AuthLibrary to generate these tokens on behalf of service account.

## Prerequisites

- An OSX machine or emulator
- [Xcode 10][xcode] or higher
- [Cocoapods][cocoapods] 

## Setup

- Create a project (or use an existing one) in the [Google Cloud Console][cloud-console]
- Enable the [Cloud Natural Language API](https://console.cloud.google.com/apis/library/language.googleapis.com)
- Enable the [IAM Service Account Credentials API](https://console.cloud.google.com/apis/library/iamcredentials.googleapis.com).
- [Enable billing][billing]
- [Create a Service account](https://cloud.google.com/iam/docs/creating-managing-service-accounts) with the following IAM role: `Owner`. Example name: `natural-language`. ([For more info on: how to add roles to a Service Account](https://cloud.google.com/iam/docs/granting-roles-to-service-accounts#granting_access_to_a_service_account_for_a_resource))


###  Setup the app
- Clone this repository `git clone https://github.com/GoogleCloudPlatform/ios-docs-samples.git` 
- `cd ios-docs-samples/natural-language/swift/` 
- Run `./INSTALL-COCOAPODS` to install app dependencies (this can take few minutes to run). When it finishes, it will open the SpeechtoSpeech workspace in Xcode. Since we are using Cocoapods, be sure to open the `NaturalLanguage.xcworkspace` and not `NaturalLanguage.xcodeproj`.
- Go to the project editor for your target and then click on the `Capabilities` tab. Look for `Push Notifications` and toggle its value to ON

###  Setup Firebase on the application:

- Complete the steps for [Add Firebase to your app](https://firebase.google.com/docs/ios/setup#add_firebase_to_your_app) and expand the "Create a Firebase project" section for instructions on how to add project to your Firebase console. Note: No need to complete any other sections, they are already done. 
- Complete the steps to [Configuring APNs with FCM](https://firebase.google.com/docs/cloud-messaging/ios/certs).
- Use `iOS bundle ID` which has push notifications enabled and select your development team in 'General->Signing' before building the application in an iOS device.
Note: as we were going to get the token in notifications, Please run the sample in iOS device instead of running it in the simulator. 
- In the [Firebase console][Firebase], open the "Authentication" section under Develop.
- On the **Sign-in Methods** page, enable the **Anonymous** sign-in method.

###  Setup and Deploy the Firebase Function 
The Firebase Function provides auth tokens to your app, You'll be using a provided sample function to be run with this app.

- Follow the steps in this [guide](https://firebase.google.com/docs/functions/get-started) for: 
- "1. Set up Node.js and the Firebase CLI"
- "2. Initialize Firebase SDK for Cloud Functions". 
- Replace `index.js` file with the [provided index.js](https://github.com/GoogleCloudPlatform/nodejs-docs-samples/blob/master/functions/tokenservice/functions/index.js).
- Replace scope in line 79 with `scope: ['https://www.googleapis.com/auth/cloud-language'],`
- Open `index.js`, go to function "generateAccessToken", and replace “SERVICE-ACCOUNT-NAME@YOUR_PROJECT_ID.iam.gserviceaccount.com” with your Service account name (`natural-language`) and project id. 
- Deploy getOAuthToken method by running command:
```
firebase deploy -—only functions
```
- For your "App Engine Default Service Account" add the following IAM role: `Service Account Token Creator` . ([For more info on: how to add roles to a Service Account](https://cloud.google.com/iam/docs/granting-roles-to-service-accounts#granting_access_to_a_service_account_for_a_resource))

- For more info please refer (https://firebase.google.com/docs/functions/get-started).

## Run the app

- You are now ready to build and run the project. In Xcode you can do this by clicking the 'Play' button in the top left. This will launch the app on the simulator or on the device you've selected. Be sure that the 'NaturalLanguage' target is selected in the popup near the top left of the Xcode window. 
- By tapping on the Menu button in top left corner of the application, user can select options from the picker view.
- Tap on `Type your input` text field and enter the text you want to analyze. Tapping on `enter` sends the text to the `NaturalLanguageService` class.
- Based on your selection (`Entity`, `Sentiment`, `Syntax`, `Category`) respective service will be called. 
- The viewcontroller extracts the results and displays on the screen using below responses.
      `AnalyzeEntitiesResponse`
      `AnalyzeSentimentResponse`
      `AnalyzeSyntaxResponse`
      `ClassifyTextResponse`
- The chosen options will be stored in the user defaults for subsequent visits, and the fields will be prepopulated.


[cloud-console]: https://console.cloud.google.com
[git]: https://git-scm.com/
[xcode]: https://developer.apple.com/xcode/
[billing]: https://console.cloud.google.com/billing?project=_
[cocoapods]: https://cocoapods.org/
[Firebase]: https://console.firebase.google.com/

