//
//  FrameworkUIViewController.h
//  Represents the interface for the base FrameworkUIViewController.
//  This controller differs from the UIViewController in that it allows data posting
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

/**
 * The purpose of this interface is to provide basic functionality
 * that the controllers need such as displaying alerts, handling
 * data passed to it, displaying a progress spinner etc.
 */
@interface FrameworkUIViewController : UIViewController

/**
 * This method is called when "data" is passed in the notification
 * to navigate to a new view
 */
- (void)onDataset:(NSObject*)data;

///This method is used to display a simple alert
- (void)displayAlert:(NSString*)title
             message:(NSString*)message
          buttonText:(NSString*)buttonText;

///this method is used to display a simple alert using the default title and button text
- (void)displayAlert:(NSString*)message;

///This method is called from inheriting controllers that need to customize how and if the navigation bar is displayed
- (void)showNavigationBar:(BOOL)isShown withBackEnabled:(BOOL)backEnabled withSettingsEnabled:(BOOL)settingsEnabled;

/**
 * This method is automatically called from the viewDidLoad method of 
 * FrameworkUIViewController. If the inheriting view needs styles customized this
 * method should be used
 */
 -(void)initViewStyles;

///Display the progress spinner
- (void)showSpinner;

///Display the progress spinner with text below
- (void)showSpinner:(NSString*)label;

///Hide the progress spinner
- (void)hideSpinner;

///The data passed in the notification to display the view
@property(nonatomic, retain, readonly) NSObject *data;

///The activity spinner
@property (nonatomic, retain) UIActivityIndicatorView *aSpinner;

///The label to display text below the spinner
@property (nonatomic, retain) UILabel *spinnerLabel;

@end
