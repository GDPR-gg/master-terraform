//
//  GoogleService.h
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

#import <Foundation/Foundation.h>
#import "GTLPlusPerson.h"

/** 
 * The pupose of this interface is to support Google+ functionality
 */
@interface GoogleService : NSObject

/**
 * request the profile information of the currently signed-in user from Google/Google+ API
 */
+ (void)loadUserProfile:(void (^)(GTLPlusPerson *))callback;

/**
 * requests the list of people who the signed-in user has added to one or more circles,
 * which is limited to the circles the user made visible to this app
 */
 + (void)loadUserFriends:(void (^)(NSArray/* of OpponentModel*/ *))callback;

@end
