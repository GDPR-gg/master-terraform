# Griddler Mobile Game Android Client Sample

This project is an implementation of Android client that works with Griddler mobile game backend sample.

## Copyright
Copyright 2013 Google Inc. All Rights Reserved.

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

[http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0)

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

## Disclaimer
This sample application is not an official Google product. The purpose of this sample is to demonstrate how to power a mobile game with a game backend running on Google App Engine. The sample is not intended to represent best practices in Android application development.

## Supported Platform and Versions
This sample source code and project is designed to work with Eclipse. It was tested with Eclipse 3.8.

## Setup Instructions
1. Setup [Griddler mobile game backend](https://github.com/GoogleCloudPlatform/solutions-griddler-sample-backend-java).

2. Import the project into Eclipse into the same workspace with Griddler mobile game backend (File->Import->General->Existing Projects into Workspace and select the directory where you have unzipped the downloaded project).

3. Configure Google Play Services by following the Setup Google Play Services SDK section from [Android documentation](https://developer.android.com/google/play-services/setup.html). Copy google-play-services_lib directory such that it is a sibling of Griddler directory in the file system and then import google-play-services_lib to Eclipse as "Android->Existing Android Code into Workspace". This sample was tested with revision 10 of Google Play Services. If you see any compilation errors with GooglePlayServices this typically indidates that the version of the google-play-services_lib is not current.

4. Make sure that google-play-services.lib is referenced by Griddler project: select Griddler project in Project Explorer, choose Properties from the context menu and select Android node in the left panel. If google-play-services.lib is not listed as a library then click Add and choose google-play-services.lib and click OK.

5. In the Package Explorer, select "Griddler - App Engine" project and from the context menu select Google -> Generate Cloud Endpoint Client Library. This should automatically copy the generated endpoint client libraries to you Griddler Android project. If it didn't you can drag endpoint-libs from the "Griddler - App Engine" to your "Griddler" project in the Package Explorer.

6. If Eclipse reports a missing required source folder, remove it in Properties -> Java Build Path -> Source.

7. Edit GameBackendSettings.java in com.google.cloud.solutions.griddler.android package and update the following constants:

  String AUDIENCE_ID = "server:client_id:Your Web Client ID"; // Use the Web Client ID created when setting up Griddler Java backend. Keep "server:client_id:".

  String GCM_SENDER_ID = "Your project number from API Console"; // This is the numeric project number of your Google Cloud project that you created when setting up Griddler backend.

  String DEFAULT_ROOT_URL = "https://your_app_id.appspot.com/_ah/api/"; // Use alphanumeric project id of your Google Cloud project (which is also the app id of your App Engine application) that you created when setting up Griddler backend.

8. Connect your physical Android device with USB debugging enabled, select Griddler project and then Run As->Android Application.
