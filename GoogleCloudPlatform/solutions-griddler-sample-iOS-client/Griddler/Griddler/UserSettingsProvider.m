//
//  UserSettingsProvider.m
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

#import "UserSettingsProvider.h"

@implementation UserSettingsProvider

static NSString* const PlayerIdKey = @"playerIdKey";
static NSString* const UsingGooglePlusKey = @"usingGooglePlusKey";

- (NSNumber*)getPlayerId {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    NSObject *storedPlayerId = [prefs objectForKey:PlayerIdKey];
    if(storedPlayerId == nil){ return nil; }
    
    return (NSNumber*)storedPlayerId;
}

- (void)setPlayerId:(NSNumber*)playerId {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:playerId forKey:PlayerIdKey];
}

- (void)setUsingGooglePlus:(BOOL)usingGooglePlus {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:@(usingGooglePlus) forKey:UsingGooglePlusKey];
}

- (BOOL)getIsUsingGooglePlus {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    NSObject *storedUsingGooglePlus = [prefs objectForKey:UsingGooglePlusKey];
    if(storedUsingGooglePlus == nil){ return YES; }
    
    return [(NSNumber*)storedUsingGooglePlus boolValue];
}

- (void)reset{
    [self setPlayerId:nil];
    [self setUsingGooglePlus:YES];
}

- (void)resetWithPlusFlag:(BOOL)usingGooglePlus{
    [self setPlayerId:nil];
    [self setUsingGooglePlus:usingGooglePlus];
}

@end