# iOS Push Notification Sample iOS Client

## Copyright
Copyright 2013 Google Inc. All Rights Reserved.

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

[http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0)

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

## Disclaimer
This sample application is not an official Google product.

## Support Platform and Versions
This sample source code and project is designed to work with Xcode 4.6.  The application runs on iOS 6.1 and is tested on iPhone 5.

## Overview
This iOS Push Notification Sample iOS Client (iOS Client) is designed to work with [iOS Push Notification Sample Backend Java (Java Backend)](https://github.com/GoogleCloudPlatform/solutions-ios-push-notification-sample-backend-java).

## Download Instruction
Download this sample code from [Google Cloud Platform Github](https://github.com/GoogleCloudPlatform/solutions-ios-push-notification-sample-ios-client).

## Developer Guide
This section provides a step-by-step guide so you can get the sample up and running in Xcode.

### Prerequisites
1. Download and install [Xcode 4.6](https://developer.apple.com/xcode/) on your Mac computer if you don't have it installed.  If you don't have subversion (i.e. SVN) installed on your machine, you may choose to install Xcode command line tools as well via Xcode Preferences.

2. You have a valid SSL certificate that is APNS enabled (for the Java Backend), a corresponding Provisioning Profile installed on your Mac computer.  Otherwise, please follow the [Apple documentation](http://developer.apple.com/library/mac/#documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/Chapters/ProvisioningDevelopment.html#//apple_ref/doc/uid/TP40008194-CH104-SW1) to obtain them.

3. Follow the [iOS Push Notification Sample Backend Java](https://github.com/GoogleCloudPlatform/solutions-ios-push-notification-sample-backend-java) instruction to deploy the backend.  Take a note of the `iOS Client ID` you configured in com.google.cloud.solutions.mobilepushnotification.Configuration.java.

4. You have an iPhone, that is provisioned for development and runs iOS version 6.1.

### Set up Xcode Project

#### Open dev.xcodeproj in Xcode
1. Open a new Finder window and navigate to the directory you extract the sample client code.  Double click on the dev.xcodeproj file. It will open the project in Xcode automatically.

2. There are missing files, which are displayed in red in Xcode, under dev/CloudPushSample/GTLibrary file group.  Follow [this instruction](https://developers.google.com/appengine/docs/java/endpoints/consume_ios#adding-required-files) to download and import the Google APIs Client Library for iOS.  The dev Xcode project expects the missing files to be located at folder `[directory where you unzipped the downloaded file]/CloudPushSample/GTLibrary`.  Copy the downloaded files to the expected folder.  You will need to create *GTLibrary* folder under `[directory where you unzipped the downloaded file]/CloudPushSample` manually.

3. For missing files, which are displayed in red in Xcode, under dev/CloudPushSample/API file group, navigate to the following URL in a web browser:

   *https://{{YOUR_APP_ID}}.appspot.com/_ah/api/discovery/v1/apis/deviceregistration/v1/rpc*

   Right click to save the file as `deviceregistration-v1-rpc.discovery`.  With the discovery file, follow [this instruction](https://developers.google.com/appengine/docs/java/endpoints/consume_ios#compiling-the-client-library-generator) to generate and import the missing files. dev Xcode project expects the missing files to be located at folder `[directory where you unzipped the downloaded file]/CloudPushSample/API`.  Copy the generated files into the expected folder.  You will need to create *API* folder under `[directory where you unzipped the downloaded file]/CloudPushSample` manually.

#### Rename the bundle ID
1. The iOS client application bundle ID has to match the one you used for creating the SSL certificate and the Provisioning Profile.  Out-of-the-box bundle ID is `com.google.CloudPushSample.dev`.  Please rename the bundle ID accordingly via project TARGETS in Xcode.

#### Update Code Signing Identity
1. Under the TARGETS' build settings, update the code signing identity to a valid provisioning profile.

#### Update the Client ID and Client Secret
1. Fill in the kClientID and kClientSecret values in NotificationViewController.m.  The kClientID here has to match with the Client ID you used in the Java Backend as described in step 3 of the Prerequisites.

### Build and Execute CloudPushSample iOS Client
1. On the top left corner of the toolbar, select `[Your bundle ID] > [Your iPhone name]`.  Then click the `Run` button to execute the app.

2. The application "CloudPushSample" should open up in your iPhone. Sign in with any Google account login if prompted.

3. When the application opens up, you should find logs such as the following in your Xcode debug area:

    Registering for push notifications...
    content---
    xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

4. The long string after "content--" is the device token.  You should see from the Xcode debug area that the iOS client makes a web service call to Java Backend to register the device using this device token.

### Testing the Backend and iOS Client Altogether
1. Make sure your device focuses on the CloudPushSample iOS application.

2. Follow the backend instruction and send an "alert message".

3. You should see the background color of CloudPushSample app changes, and the alert message is displayed.  Send a few different alert messages from the backend.  Each time when an alert message arrives, the background color will change.

4. Hit the "Home" key of the iPhone to navigate away from the CloudPushSample app.

5. Send another "alert message" from the backend.

6. You should now see a pop up alert with the message.  It prompts you to relaunch the CloudPushSample app.
