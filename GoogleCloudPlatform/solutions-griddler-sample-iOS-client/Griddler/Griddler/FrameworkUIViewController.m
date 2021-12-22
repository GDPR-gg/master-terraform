//
//  FrameworkUIViewController.m
//  Represents the concrete implementation of the FrameworkUIViewController
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

#import "FrameworkUIViewController.h"
#import "viewTypes.m"
#import "UIHelper.h"

@interface FrameworkUIViewController ()

@property(nonatomic, retain, readwrite) NSObject *data;

@end

@implementation FrameworkUIViewController

- (void)onDataset:(NSObject*)thedata {
    self.data = thedata;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self showNavigationBar:NO withBackEnabled:NO withSettingsEnabled:NO];
    
    [self initViewStyles];
}

- (void)showNavigationBar:(BOOL)isShown withBackEnabled:(BOOL)backEnabled withSettingsEnabled:(BOOL)settingsEnabled {
    if(isShown)
    {
        // Create a negative spacer to go next to the custom buttons
        // and pull it right to the edge:
        UIBarButtonItem *spacer = [[UIBarButtonItem alloc]
                                   initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                   target:nil action:nil];
        // Note: We use 9 b/c iOS adds 5 by default.
        spacer.width = 9;
        if(backEnabled)
        {
            UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
            UIImage *backButtonImage = [UIImage imageNamed:@"NavBack.png"]  ;
            [backButton setBackgroundImage:backButtonImage forState:UIControlStateNormal];
            [backButton addTarget:self action:@selector(navigateBack) forControlEvents:UIControlEventTouchUpInside];
            backButton.frame = CGRectMake(0, 0, 20, 20);
            UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];

            self.navigationItem.leftBarButtonItems = @[spacer, backButtonItem];
        }
        if(settingsEnabled)
        {
            UIButton *settingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
            UIImage *settingsButtonImage = [UIImage imageNamed:@"NavSettings.png"]  ;
            [settingsButton setBackgroundImage:settingsButtonImage forState:UIControlStateNormal];
            [settingsButton addTarget:self action:@selector(navigateSettings) forControlEvents:UIControlEventTouchUpInside];
            settingsButton.frame = CGRectMake(0, 0, 20, 20);
            UIBarButtonItem *settingsButtonItem = [[UIBarButtonItem alloc] initWithCustomView:settingsButton];
            self.navigationItem.rightBarButtonItems = @[spacer, settingsButtonItem];
        }
        [self.navigationController  setNavigationBarHidden:NO];
    }
    else
    {
        [self.navigationController setNavigationBarHidden:YES];
    }
}

- (void)navigateBack {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)navigateSettings {
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
    userInfo[@"viewType"] = @(SETTINGS);
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:kNavigateToNotification
     object:self
     userInfo:userInfo];
}

- (void)initViewStyles {
    // Background color for all screens
    self.view.backgroundColor = [GriddlerColor background];
}

- (void)showSpinner {
    [self showSpinner:nil];
}

- (void)showSpinner:(NSString*)label{

    if(!self.aSpinner) {
        self.aSpinner = [[UIActivityIndicatorView alloc]  initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [self.view addSubview:self.aSpinner];
        
        [self.aSpinner setBounds:self.view.frame];
        [self.aSpinner setCenter:self.view.center];
        
        self.aSpinner.autoresizingMask = (UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin);
    }

    if(label){
        
        if(!self.spinnerLabel){
            
            CGPoint point = self.view.center;
            point.y = point.y + 50;
            
            self.spinnerLabel = [[UILabel alloc] initWithFrame:self.view.frame];
            [self.spinnerLabel setCenter:point];
            
            self.spinnerLabel.autoresizingMask = (UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin);
            
            self.spinnerLabel.textAlignment = NSTextAlignmentCenter;
            self.spinnerLabel.font = [GriddlerFont defaultLabelFont];
            self.spinnerLabel.numberOfLines = 1;
        
            self.spinnerLabel.backgroundColor = [UIColor clearColor];
            self.spinnerLabel.textColor = [GriddlerColor navy];
            
            [self.view addSubview:self.spinnerLabel];
        }
        
        //set the background color because we're showing text
        [self.aSpinner setBackgroundColor:[GriddlerColor background]];

        self.spinnerLabel.text = label;
        [self.spinnerLabel setHidden:NO];
    }else{
        //reset to clear
        [self.aSpinner setBackgroundColor:[UIColor clearColor]];
    }

    [self.view setUserInteractionEnabled:NO];
    [self.aSpinner startAnimating];
    
}

- (void)hideSpinner {
    [self.aSpinner stopAnimating];
    [self.view setUserInteractionEnabled:YES];
    
    if(self.spinnerLabel){
        [self.spinnerLabel setHidden:YES];
    }
}

- (void)displayAlert:(NSString*)title
             message:(NSString*)message
          buttonText:(NSString*)buttonText {

    [UIHelper displayAlert:title message:message buttonText:buttonText];
}

- (void)displayAlert:(NSString*)message {

    NSString *title = NSLocalizedString(@"ALERT_DEFAULT_TITLE", nil);
    NSString *button = NSLocalizedString(@"ALERT_DEFAULT_BUTTON", nil);

    [self displayAlert:title message:message buttonText:button];
}

@end
