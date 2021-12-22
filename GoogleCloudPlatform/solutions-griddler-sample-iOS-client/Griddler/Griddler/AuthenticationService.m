//
//  authenticationService.c
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

#import "AuthenticationService.h"

#import "ViewTypes.m"
#import "UserSettingsProvider.h"
#import "GTMOAuth2ViewControllerTouch.h"
#import "DataProvider.h"
#import "GTLPlusConstants.h"
#import "GTLGriddlerConstants.h"
#import "GTLGriddlerPlayer.h"
#import "UIHelper.h"

@implementation AuthenticationService

#pragma mark -

- (id) init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleSignOutNotification:)
                                                     name:kSignOutNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleEnableGooglePlusNotificaton:)
                                                     name:kEnableGooglePlusNotification
                                                   object:nil];
    }
    return self;
}

- (void)authenticate {
    UserSettingsProvider* settings = [[UserSettingsProvider alloc] init];
    if(self.isLoggedIn && [settings getPlayerId] != nil) {
        
        //get the user record
        DataProvider *data = [[DataProvider alloc] init];
        [data getPlayerRecord:^void(GTLGriddlerPlayer *results) {
            
            if(results) {
                NSDictionary *userInfo = @{@"viewType":@(LANDING),
                                           @"clearBackstack":@YES,
                                           @"data":results};

                [[NSNotificationCenter defaultCenter]
                 postNotificationName:kNavigateToNotification
                 object:self
                 userInfo:userInfo];
                
            }else{
                BOOL isPlusUser = [[[UserSettingsProvider alloc] init] getIsUsingGooglePlus];
                [self signOut:isPlusUser];
            }
        }];
    }
    else {
        NSLog(@"authenticating...");
        [self startGoogleAuth];
    }
}

#pragma mark - Google Plus authentication

- (void)startGoogleAuth {
    GTMOAuth2ViewControllerTouch *viewController;

    BOOL isPlusUser = [[[UserSettingsProvider alloc] init] getIsUsingGooglePlus];
    
    viewController = [[GTMOAuth2ViewControllerTouch alloc] initWithScope:isPlusUser ? kGTLAuthScopePlusLogin : kGTLAuthScopeGriddlerUserinfoEmail
                                                                clientID:kAuthClientID
                                                            clientSecret:kAuthClientSecret
                                                        keychainItemName:kAuthKeychainName
                                                                delegate:self
                                                        finishedSelector:@selector(viewController:finishedWithAuth:error:)];
    
    viewController.showsInitialActivityIndicator=YES;

    NSDictionary *userInfo = @{@"viewType":@(LOGON),
                               @"viewController":viewController,
                               @"clearBackstack":@YES};

    [[NSNotificationCenter defaultCenter]
     postNotificationName:kNavigateToNotification
     object:self
     userInfo:userInfo];
}

- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController
      finishedWithAuth:(GTMOAuth2Authentication *)auth
                 error:(NSError *)error {

    
    NSLog(@"authenticating...Done!");
    if(!error) {
        [GoogleService loadUserProfile:^(GTLPlusPerson *profile) {

            BOOL isPlusUser = (profile) ? [profile.isPlusUser boolValue] : NO;

            [[[UserSettingsProvider alloc] init] setUsingGooglePlus: isPlusUser];

            DataProvider *data = [[DataProvider alloc] init];
            
            if(isPlusUser){
                
                [data registerPlayerWithPlusId:profile.identifier
                                         block:^void(GTLGriddlerPlayer *results)
                 {
                     [[NSNotificationCenter defaultCenter] postNotificationName:kSignedInNotification
                                                                         object:self
                                                                       userInfo:nil];
                     
                     UserSettingsProvider *settings = [UserSettingsProvider alloc];
                     [settings setPlayerId:results.identifier];
                     
                     [self authenticate];
                 }];
                
            }else{

                [data registerPlayer:^void(GTLGriddlerPlayer *results)
                 {
                     [[NSNotificationCenter defaultCenter] postNotificationName:kSignedInNotification
                                                                         object:self
                                                                       userInfo:nil];
                     
                     UserSettingsProvider *settings = [UserSettingsProvider alloc];
                     [settings setPlayerId:results.identifier];
                     
                     [self authenticate];
                 }];
                
            }
        }];

        return;
    }

    UIAlertView *popup = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ALERT_DEFAULT_TITLE", nil)
                                                    message:NSLocalizedString(@"AUTHENTICATION_GOOGLE_PLUS_ERROR", nil)
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"AUTHENTICATION_TRY_AGAIN", nil)
                                          otherButtonTitles:NSLocalizedString(@"AUTHENTICATION_NO_GPLUS_LOGIN", nil), nil];
    
    [popup show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if(buttonIndex < 0)
        return;
    
    switch (buttonIndex) {
        case 0:
            [self signOut:YES];
            break;
        case 1:
            [self signOut:NO];
            break;
    }
}

- (BOOL)isLoggedIn {
    GTMOAuth2Authentication *auth = [self authFromKeychain];
    return auth.canAuthorize;
}

- (void)handleEnableGooglePlusNotificaton:(NSNotification*)notification{

    if ([[notification name] isEqualToString:kEnableGooglePlusNotification]) {
        [self signOut:YES];
    }
}

- (void)handleSignOutNotification:(NSNotification *) notification {
    if ([[notification name] isEqualToString:kSignOutNotification]) {
        [self signOut:YES];
    }
}

- (void)signOut:(BOOL)usingPlus {
    NSLog(@"Signing out");
    GTMOAuth2Authentication *auth = [self authFromKeychain];
    [GTMOAuth2ViewControllerTouch removeAuthFromKeychainForName:kAuthKeychainName];
    [GTMOAuth2ViewControllerTouch revokeTokenForGoogleAuthentication:auth];

    //reset all user settings
    [[[UserSettingsProvider alloc] init]  resetWithPlusFlag:usingPlus];

    [self authenticate];
}

- (GTMOAuth2Authentication*)authFromKeychain {
    return [AuthenticationService authFromKeychain];
}

#pragma mark - Class methods

+ (GTMOAuth2Authentication*)authFromKeychain {
    return [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:kAuthKeychainName
                                                                 clientID:kAuthClientID
                                                             clientSecret:kAuthClientSecret];
}

+ (NSString *)googleAccountEmail {
    GTMOAuth2Authentication *auth = [self authFromKeychain];
    return auth.canAuthorize ? auth.userEmail : nil;
}

@end