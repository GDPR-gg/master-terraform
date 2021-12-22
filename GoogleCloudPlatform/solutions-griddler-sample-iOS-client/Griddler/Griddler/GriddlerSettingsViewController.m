//
//  GoogleSettingsViewController.m
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

#import "GriddlerSettingsViewController.h"
#import "UserSettingsProvider.h"

@interface GriddlerSettingsViewController ()

- (IBAction)onLogoutAction:(id)sender;
- (IBAction)onEnableGooglePlusAction:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentUserLabel;
@property (weak, nonatomic) IBOutlet UIView *buttonView;
@property (weak, nonatomic) IBOutlet UIButton *signOutButton;
@property (weak, nonatomic) IBOutlet UIButton *enableGooglePlusButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonViewHeightConstraint;

- (void)updateSignedInText:(NSString *)text;
- (NSString*) version;

- (void)refreshGooglePlusLayout;

@end

@implementation GriddlerSettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    
    return self;
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"SETTINGS_TITLE", nil);
    
    [self updateSignedInText:AuthenticationService.googleAccountEmail];
    
    self.versionLabel.text = [NSString stringWithFormat:@"%@, Google Inc.", self.version];
    
    [self showNavigationBar:YES withBackEnabled:YES withSettingsEnabled:NO];
    
    
    [self.signOutButton setTitleEdgeInsets:UIEdgeInsetsMake(2.5f, 0.0f, 0.0f, 0.0f)];
    [self.enableGooglePlusButton setTitleEdgeInsets:UIEdgeInsetsMake(2.5f, 0.0f, 0.0f, 0.0f)];
    
    [self refreshGooglePlusLayout];
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
}

-(void)refreshGooglePlusLayout{
    
    UserSettingsProvider* settings = [[UserSettingsProvider alloc] init];
    Boolean isEnabled = [settings getIsUsingGooglePlus];
    if(isEnabled){
        [self.enableGooglePlusButton setHidden:YES];
        [self.buttonViewHeightConstraint setConstant:118.0];
    }
    else{
        [self.enableGooglePlusButton setHidden:NO];
        [self.buttonViewHeightConstraint setConstant:172.0];
    }
}

-(void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self showNavigationBar:YES withBackEnabled:YES withSettingsEnabled:NO];
    
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

- (IBAction)onEnableGooglePlusAction:(id)sender {
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:kEnableGooglePlusNotification
     object:self
     userInfo:nil];
}

- (IBAction)onLogoutAction:(id)sender {
    
    UserSettingsProvider* settings = [[UserSettingsProvider alloc] init];
    [settings reset];
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:kSignOutNotification
     object:self
     userInfo:nil];
}

#pragma mark - private methods

- (void)initViewStyles {
    
    [super initViewStyles];
    [self.currentUserLabel setFont:[GriddlerFont robotoRegularAtSize:13]];
    [self.currentUserLabel setTextColor:[GriddlerColor navy]];
    
    [self.versionLabel setFont:[GriddlerFont robotoLightAtSize:13]];
    [self.versionLabel setTextColor:[GriddlerColor navy]];
    
    [self.buttonView setBackgroundColor:[GriddlerColor aqua]];
    
}

-(void)updateSignedInText:(NSString *)text {
    
    NSString *prefix = @"Signed in to";
    
    NSString *infoString = [NSString stringWithFormat:@"%@ %@", prefix, text];
    
    NSMutableAttributedString *attString=[[NSMutableAttributedString alloc] initWithString:infoString];
    
    UIFont *prefixFont = [GriddlerFont robotoLightAtSize:13];
    
    [attString addAttribute:NSFontAttributeName value:prefixFont range:NSMakeRange(0, prefix.length)];
    
    self.currentUserLabel.attributedText = attString;
    
}

- (NSString*) version {
    
    NSString *version = [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"];
    return [NSString stringWithFormat:@"Version %@", version];
    // NSString *build = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    // return [NSString stringWithFormat:@"Version %@ build %@", version, build];
    
}

@end
