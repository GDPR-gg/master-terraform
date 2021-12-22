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
#import "GTLDeviceregistration.h"

// Control the display of received remote notifications in the application
@interface NotificationViewController : UIViewController

// View to display messages
@property(nonatomic, weak) IBOutlet UITextView *messageView;

// Flag to check if device token is registered
@property(nonatomic, assign, getter=isRegistered) BOOL registered;
@property(nonatomic, strong) GTLServiceDeviceregistration *service;

// Update text view with the input message
- (void)updateMessageLabel:(NSString *)newMessage;

// Register device with APNS provider
- (void)registerDeviceWithToken:(NSString *)token;

@end
