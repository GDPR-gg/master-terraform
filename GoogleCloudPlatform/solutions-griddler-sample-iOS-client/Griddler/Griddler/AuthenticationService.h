//
//  authenticationService.h
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

#import <UIKit/UIKit.h>
#import "GTMOAuth2Authentication.h"
#import "GPPSignIn.h"

/**
 * The purpose of this intface is to expose functionality
 * around authenticating with a Google account
 **/
@interface AuthenticationService : NSObject

///Returns YES if the current user is logged in
- (BOOL)isLoggedIn;

///Begin the authentication process
- (void)authenticate;

///Get the authorization keychain
+ (GTMOAuth2Authentication*)authFromKeychain;

///Get the currently logged in user's email address
+ (NSString *)googleAccountEmail;

@end

