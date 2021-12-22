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

#import "AppDelegate.h"


@implementation AppDelegate
@synthesize mainControllerDelegate = _mainControllerDelegate;
@synthesize tokenString = _tokenString;

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  // Register for push notification
  UIRemoteNotificationType types =
      (UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert);
  [[UIApplication sharedApplication] registerForRemoteNotificationTypes:types];

  return YES;
}

- (void)application:(UIApplication *)application
    didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
  // Format the returned token from "<xxxx xxxx xxxx ....>" to
  // "xxxxxxxxx......"
  NSCharacterSet *removeSet =
      [NSCharacterSet characterSetWithCharactersInString:@"<> "];
  NSString *token = [self hexStringFromData:deviceToken];
  token = [[token componentsSeparatedByCharactersInSet:removeSet]
              componentsJoinedByString:@""];
  NSLog(@"content---%@", token);

  // Register device if it's not registered and authentication is completed
  NotificationViewController *controller = self.mainControllerDelegate;
  if (controller && !controller.registered && controller.service.authorizer) {
    [self.mainControllerDelegate registerDeviceWithToken:token];
  } else {
    // otherwise, save the token and register device after authentication is
    // completed
    self.tokenString = token;
  }
}

- (NSString *)hexStringFromData:(NSData *)data {
  NSUInteger dataLength = [data length];
  NSMutableString *stringBuffer =
      [NSMutableString stringWithCapacity:dataLength * 2];
  const unsigned char *dataBuffer = [data bytes];
  for (int i=0; i<dataLength; i++) {
    [stringBuffer appendFormat:@"%02x", (NSUInteger)dataBuffer[i]];
  }

  return stringBuffer;
}

- (void)application:(UIApplication *)app
    didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
  NSLog(@"%@", err);
}

- (void)application:(UIApplication *)application
    didReceiveRemoteNotification:(NSDictionary *)userInfo {
  NSLog(@"Alert: %@", userInfo);

  NSString *message = [userInfo valueForKeyPath:@"aps.alert"];
  [self.mainControllerDelegate updateMessageLabel:message];
}

@end
