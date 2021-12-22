//
//  Constants.m
//  Griddler
//
//  Copyright 2013 Google Inc. All Rights Reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "Constants.h"

// notifications
NSString* const kSignOutNotification          = @"SignOutNotification";
NSString* const kNavigateToNotification       = @"NavigateToNotification";
NSString* const kNavigateBackNotification     = @"NavigateBackNotification";
NSString* const kSignedInNotification         = @"SignedInNotification";
NSString* const kLetterSelectedNotification   = @"LetterSelectedNotification";
NSString* const kQuestionSkippedNotification  = @"QuestionSkippedNotification";
NSString* const kLetterUnselectedNotification = @"LetterUnselectedNotification";
NSString* const kGameCompletedNotification    = @"GameCompletedNotification";
NSString* const kQuestionAnsweredNotification = @"QuestionAnsweredNotification";
NSString* const kEnableGooglePlusNotification = @"EnableGooglePlusNotification";
NSString* const kGameStartedNotification      = @"GameStartedNotification";

// authentication
NSString* const kAuthKeychainName = @"Google Griddler";
NSString* const kAuthClientID     = @"Your iOS Client ID";
NSString* const kAuthClientSecret = @"Your iOS Client Secret";

// Griddler Cloud Endpoint base Url
NSString* const kGriddlerServiceUrl = @"https://yourappid.appspot.com/_ah/api/rpc?prettyPrint=false";

// Urls for Google+
NSString* const UserInfoUrl  = @"https://www.googleapis.com/plus/v1/people/me";
NSString* const UserEmailUrl = @"https://www.googleapis.com/oauth2/v2/userinfo";
