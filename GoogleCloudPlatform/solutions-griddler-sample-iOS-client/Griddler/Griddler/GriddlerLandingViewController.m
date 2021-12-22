//
//  googleLandingViewController.m
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

#import <QuartzCore/QuartzCore.h>
#import "GTLGriddlerPlayerStatistics.h"
#import "GriddlerLandingViewController.h"
#import "LobbyParameters.h"
#import "viewTypes.m"
#import "DataProvider.h"


@implementation GriddlerLandingViewController

static NSString *profileImageUrl = nil;
static NSString *profileDisplayName = nil;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {

    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.navigationItem.title = @"Griddler";
        
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        
        //register to listen for signed in
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleSignedOutNotification:)
                                                     name:kSignOutNotification
                                                   object:nil];
        
    }
    return self;
}

- (void)handleSignedOutNotification:(NSNotification *) notification {
    if ([[notification name] isEqualToString:kSignOutNotification]) {
       
        profileImageUrl = nil;
        profileDisplayName = nil;
        
    }
}

- (void)viewDidLoad {

    [super viewDidLoad];

    [self showNavigationBar:YES withBackEnabled:NO withSettingsEnabled:YES];
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
}

- (void)initViewStyles {

    [super initViewStyles];
    [self.mainLabel setFont:[GriddlerFont defaultLabelFont]];
    [self.subLabel setFont:[GriddlerFont defaultSubheadingFont]];
    [self.buttonView setBackgroundColor:[GriddlerColor aqua]];

    //To fix font issues
    [self.singlePlayerButton setTitleEdgeInsets:UIEdgeInsetsMake(2.5f, 0.0f, 0.0f, 30.0f)];
    [self.twoPlayerButton setTitleEdgeInsets:UIEdgeInsetsMake(2.5f, 0.0f, 0.0f, 30.0f)];
}

- (void)setImage:(NSString *)imageUrl {

    UIImage *image = [[UIImage alloc] initWithData:
                      [NSData dataWithContentsOfURL:
                       [NSURL URLWithString:[self processImageUrl:imageUrl]]]];
    CALayer *imageLayer = self.avatarImageView.layer;
    [imageLayer setCornerRadius:56];
    [imageLayer setBorderWidth:0];
    [imageLayer setMasksToBounds:YES];
    [self.avatarImageView setImage:image];
}

// change querystring to get the image with size 96
- (NSString*)processImageUrl:(NSString*)imageUrl {

    NSMutableString *url = [NSMutableString stringWithString:imageUrl];

    //the default size of the image is 50. Change it to 96
    if([url rangeOfString:@"sz"].location == NSNotFound){
        if([url rangeOfString:@"?"].location == NSNotFound){
            [url appendString:@"?sz=112"];
        }else{
            [url appendString:@"&sz=112"];
        }
    }else{
        //the querystring value exists so replace it with 96
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"([?&]sz)=[^?&]+"
                                                                               options:0
                                                                                 error:nil];
        [regex replaceMatchesInString:url
                              options:0
                                range:NSMakeRange(0, [url length])
                         withTemplate:@"$1=112"];
    }

    return url;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onLobbyNavigationDown:(id)sender {

    LobbyParameters *parameters = [[LobbyParameters alloc] init:nil
                                                       gameType:SinglePlayer];

    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
    userInfo[@"viewType"] = @(LOBBY);
    userInfo[@"data"] = parameters;

    [[NSNotificationCenter defaultCenter]
     postNotificationName:kNavigateToNotification
     object:self
     userInfo:userInfo];
}

- (IBAction)onOpponentListNavigateDown:(id)sender {

    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
    userInfo[@"viewType"] = @(OPPONENT_LIST);

    [[NSNotificationCenter defaultCenter]
     postNotificationName:kNavigateToNotification
     object:self
     userInfo:userInfo];

}

- (IBAction)onSettingsAction:(id)sender {

    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
    userInfo[@"viewType"] = @(SETTINGS);

    [[NSNotificationCenter defaultCenter]
     postNotificationName:kNavigateToNotification
     object:self
     userInfo:userInfo];

}

- (void)refreshView:(NSObject*)data {

}

- (void)onDataset:(NSObject*)data {
    [super onDataset:data];
    
    [super showSpinner];
    
    if(!profileDisplayName || !profileImageUrl){
        // get google profile
        [GoogleService loadUserProfile:^(GTLPlusPerson *profile) {
            if(profile) {
                
                profileDisplayName = profile.displayName;
                profileImageUrl = profile.image.url;
                
                if(profile.image) [self setImage:profile.image.url];
                if(profile.displayName) [self.mainLabel setText:profile.displayName];
            }else{
                [self.mainLabel setText:[AuthenticationService googleAccountEmail]];
            }
        }];
    }else{
        [self setImage:profileImageUrl];
        [self.mainLabel setText:profileDisplayName];
    }
    
    if(!self.data){
        //get the user record
        DataProvider *data = [[DataProvider alloc] init];
        [data getPlayerRecord:^void(GTLGriddlerPlayer *results) {
            if(results) {
                [self displayRecord:results];
            }
            [super hideSpinner];
        }];
    }else{
        [self displayRecord:(GTLGriddlerPlayer*)self.data];
        [super hideSpinner];
    }

}

- (void)displayRecord:(GTLGriddlerPlayer*)record{
    
    if(!record)
        return;
    
    int games = [record.statistics.numberOfGames intValue];
    int wins = [record.statistics.numberOfWins intValue];
    
    if(games != 0) {
        self.subLabel.text =
        [NSString stringWithFormat:NSLocalizedString(@"LANDING_YOUVE_WON", nil), wins, games];
    }
    else {
        self.subLabel.text =
        NSLocalizedString(@"LANDING_NO_GAMES_YET", nil);
    }
}

@end
