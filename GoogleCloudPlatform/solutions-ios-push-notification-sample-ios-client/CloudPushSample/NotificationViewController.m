/* Copyright (c) 2013 Google Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "GTMHTTPFetcherLogging.h"
#import "GTMOAuth2Authentication.h"
#import "GTMOAuth2ViewControllerTouch.h"
#import "NotificationViewController.h"
#import "ViewHelper.h"


@interface NotificationViewController() {
  GTMOAuth2Authentication *_oauth;
  AppDelegate *_appDelegate;
}
@end


@implementation NotificationViewController
@synthesize messageView = _messageView;
@synthesize registered = _registered;
@synthesize service = _service;

// Obtain credential from https://code.google.com/apis/console
static NSString *kClientID = @"{{{ INSERT ID }}}";
static NSString *kClientSecret = @"{{{ INSERT SECRET }}}";
static NSString *kKeyChainName = @"CloudPushSample";

- (void)viewDidLoad {
  [super viewDidLoad];

  // Link this controller to application
  _appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
  _appDelegate.mainControllerDelegate = self;

  // Set up message view
  UITextView *myMessageView = self.messageView;
  myMessageView.editable = NO;
  myMessageView.scrollEnabled = YES;

  // Set up devcie registartion service
  self.service = [[GTLServiceDeviceregistration alloc] init];
  self.service.retryEnabled = YES;
#if DEBUG
  [GTMHTTPFetcher setLoggingEnabled:YES];
#endif

  // Authenticate user
  [self authenticateUser];
}

- (UIColor *)randomColor {
  CGFloat greenRandom = (arc4random() % 100) *.01;
  CGFloat blueRandom = (arc4random() % 100) * .01;
  CGFloat redRandom = (arc4random() % 100) *.01;
  return [UIColor colorWithRed:redRandom
                         green:greenRandom
                          blue:blueRandom
                         alpha:1];
}

- (void)updateMessageLabel:(NSString *)newMessage {
  [self.messageView setBackgroundColor:[self randomColor]];
  // Prepend the new message to the previous message text.
  self.messageView.text = [NSString stringWithFormat:@"%@\n\n%@", newMessage,
                               self.messageView.text];
}

- (void)registerDeviceWithToken:(NSString *)token {
  GTLDeviceregistrationDeviceRegistration *registry =
      [[GTLDeviceregistrationDeviceRegistration alloc] init];
  registry.deviceToken = token;

  GTLQueryDeviceregistration *query =
      [GTLQueryDeviceregistration queryForDeviceRegistrationEndpointRegisterDeviceWithObject:registry];

  if (self.service) {
    [self.service executeQuery:query completionHandler:
        ^(GTLServiceTicket *ticket, id object, NSError *error) {
          if (error) {
            NSLog(@"%@", error);
          } else {
            NSLog(@"Device token registration done: %@", object);
            self.registered = YES;
          }
    }];
  }
}

#pragma mark - Authentication model

- (IBAction)pressSignout:(id)sender {
  [self unAuthenticateUser];
  [ViewHelper showSigninToolBarButtonForViewController:self];
}

- (IBAction)pressSignin:(id)sender {
  [self authenticateUser];
  [ViewHelper showSignoutToolBarButtonForViewController:self];
}

// Show user sign in view.
- (void)showUserSignInView {
  GTMOAuth2ViewControllerTouch *oauthViewController;
  oauthViewController =
      [[GTMOAuth2ViewControllerTouch alloc]
             initWithScope:@""
                  clientID:kClientID
              clientSecret:kClientSecret
          keychainItemName:kKeyChainName
                  delegate:self
          finishedSelector:@selector(viewController:finishedWithAuth:error:)];

  [self presentViewController:oauthViewController animated:YES completion:nil];
}

// Callback method after user finished the sign in.
- (void)viewController:(GTMOAuth2ViewControllerTouch *)oauthViewController
      finishedWithAuth:(GTMOAuth2Authentication *)auth
                 error:(NSError *)error {
  [self dismissViewControllerAnimated:YES completion:nil];
  _oauth = auth;

  if (error) {
    [ViewHelper showPopup:@"Error"
                  message:@"Failed to authenticate user"
                   button:@"OK"];
    NSLog(@"%@", error);
  } else {
    [self registerDeviceWithAuthentication];
    NSLog(@"%@", auth);
  }
}

- (void)authenticateUser {
  if (!_oauth) {
    // Instance doesn't have an authentication object, attempt to fetch from
    // keychain.  This method call always returns an authentication object.
    // If nothing is returned from keychain, this will return an invalid
    // authentication
    _oauth = [GTMOAuth2ViewControllerTouch
                authForGoogleFromKeychainForName:kKeyChainName
                                        clientID:kClientID
                                    clientSecret:kClientSecret];
  }

  // Now instance has an authentication object, check if it's valid
  if ([_oauth canAuthorize]) {
    // Looks like token is good, register the device using the oauth
    [self registerDeviceWithAuthentication];
    NSLog(@"%@", _oauth);
  } else {
    // If there is some sort of error when validating the previous
    // authentication, reset the authentication and force user to login
    _oauth = nil;
    [self showUserSignInView];
  }
}

// Reset access token value for authentication object for Cloud Endpoint.
- (void)registerDeviceWithAuthentication {
  if (_oauth) {
    _oauth.authorizationTokenKey = @"id_token";
    [self.service setAuthorizer:_oauth];

    // Register device if it hasn't happend yet and device token is available
    if (!self.registered && _appDelegate.tokenString) {
      [self registerDeviceWithToken:_appDelegate.tokenString];
    }
  }

  // Add a sign out button
  [ViewHelper showSignoutToolBarButtonForViewController:self];

  // Reload the view
  [self.messageView reloadInputViews];
}

// Signing user out and revoke token
- (void)unAuthenticateUser {
  [GTMOAuth2ViewControllerTouch removeAuthFromKeychainForName:kKeyChainName];
  [GTMOAuth2ViewControllerTouch revokeTokenForGoogleAuthentication:_oauth];
}

@end
