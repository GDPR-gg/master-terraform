//
//  GoogleAppDelegate.m
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

#import "GriddlerAppDelegate.h"
#import "DataProvider.h"
#import "LobbyParameters.h"
#import "UIHelper.h"
#import "GPPURLHandler.h"
#import "UserSettingsProvider.h"

@interface GriddlerAppDelegate (){
@private
    NSDictionary *currentInvite;
    BOOL currentlyPlayingGame;
    UIAlertView *acceptingInvitationAlertView;
}
@end

@implementation GriddlerAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window setNeedsDisplay];
    [self.window makeKeyAndVisible];
    
    // Services
    self.authenticationService = [[AuthenticationService alloc] init];
    
    // Create the view controller
    ViewResolver *viewResolver = [ViewResolver alloc];
    
    // Configure the primary navigation controller
    self.responderNavigationController = [[ResponderNavigationController alloc] initWithRootViewController:[viewResolver resolve:@"Griddler" type:SPLASH]];
    self.responderNavigationController.viewResolver = viewResolver;
    self.window.rootViewController = [self.responderNavigationController init];
    
    
    [self setApplicationStyles];
    
    //Register to listen to when a game has started
    //This message is sent from the GoogleLobbyViewController
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleGameStartedNotification:)
                                                 name:kGameStartedNotification
                                               object:nil];

    //Register to listen for when a game has completed
    //This message is sent from the GoogleGameBoardViewController
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleGameCompletedNotification:)
                                                 name:kGameCompletedNotification
                                               object:nil];

    
    //Register to listen for signed in
    //This message is sent from the AuthenticationService
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleSignedInNotification:)
                                                 name:kSignedInNotification
                                               object:nil];
    
    //Allow the splash screen to show for 2 seconds prior to
    //starting authentication
    [NSTimer scheduledTimerWithTimeInterval:2.0
                                     target:self
                                   selector:@selector(delayedAuthentication:)
                                   userInfo:nil
                                    repeats:NO];
    
    // Check for remote notification on launchs
    NSDictionary* notificationUserInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (notificationUserInfo) {
        [self application:application didReceiveRemoteNotification:notificationUserInfo];
    }
    
    
    return YES;
}

- (void)delayedAuthentication:(NSTimer *)theTimer{
    // Start the authentication process
    [self.authenticationService authenticate];
}

- (void) handleGameStartedNotification:(NSNotification *) notification{
    
    if ([[notification name] isEqualToString:kGameStartedNotification]){
        currentlyPlayingGame = YES;
    }
}

- (void) handleGameCompletedNotification:(NSNotification *) notification{
    if ([[notification name] isEqualToString:kGameCompletedNotification]){
        currentlyPlayingGame = NO;
    }
}

- (void) handleSignedInNotification:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:kSignedInNotification]){
        [[UIApplication sharedApplication]
         registerForRemoteNotificationTypes:
         (UIRemoteNotificationTypeAlert |
          UIRemoteNotificationTypeBadge |
          UIRemoteNotificationTypeSound)];
    }
}

- (void) setApplicationStyles{
    //Set appearance of all labels to use Roboto
    [[UILabel appearance] setFont:[GriddlerFont defaultLabelFont]];
    [[UILabel appearance] setTextColor:[GriddlerColor defaultLabelColor]];
    [[UILabel appearanceWhenContainedIn:[UIButton class], nil]
     setFont:[GriddlerFont defaultButtonFont]];
    
    //Nav Bar
    [[UINavigationBar appearance] setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setBackgroundColor:[GriddlerColor navy]];
    NSDictionary *navbarTitleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                               [GriddlerFont navTitleFont], UITextAttributeFont,
                                               [GriddlerColor white],UITextAttributeTextColor,
                                               [GriddlerColor clearColor], UITextAttributeTextShadowColor,
                                               [NSValue valueWithUIOffset:UIOffsetMake(0, 0)], UITextAttributeTextShadowOffset, nil];
    
    [[UINavigationBar appearance] setTitleTextAttributes:navbarTitleTextAttributes];
    [[UINavigationBar appearance]setShadowImage:[[UIImage alloc] init]];
    
    // UITableView
    [[UITableView appearance] setBackgroundColor: [UIColor clearColor]];
    //[[UITableView appearance] setOpaque: NO];
    [[UITableView appearance ]setSeparatorColor:[GriddlerColor aqua]];
    
    
    UIImage *resizableButton = [[UIImage imageNamed:@"resizableButton.png" ] resizableImageWithCapInsets:UIEdgeInsetsMake(3,3,4,3)];
    UIImage *resizableButtonHighlighted = [[UIImage imageNamed:@"resizableButtonHighlighted.png" ] resizableImageWithCapInsets:UIEdgeInsetsMake(3,3,4,3)];
    
    [[UIButton appearanceWhenContainedIn:[FrameworkUIViewController class], nil] setBackgroundImage:resizableButton forState:UIControlStateNormal];
    [[UIButton appearanceWhenContainedIn:[FrameworkUIViewController class], nil] setBackgroundImage:resizableButtonHighlighted forState:UIControlStateHighlighted];
    [[UIButton appearanceWhenContainedIn:[FrameworkUIViewController class], nil] setTitleColor:[GriddlerColor defaultLabelColor] forState:UIControlStateNormal];
}

- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    const char* data = [deviceToken bytes];
    NSMutableString* token = [NSMutableString string];
    
    for (int i = 0; i < [deviceToken length]; i++) {
        [token appendFormat:@"%02.2hhX", data[i]];
    }
    
    NSString *deviceId = [NSString stringWithString:token];

    [self registerDevice:deviceId];
}

- (void)registerDevice:(NSString*)deviceId{
    
    DataProvider *dataProvider = [[DataProvider alloc] init];
    [dataProvider registerDevice:deviceId block:^(GTLObject *results) {
        
        if(!results){
            [UIHelper displayAlert:NSLocalizedString(@"ALERT_DEFAULT_TITLE", nil)
                           message:@"Failed to register device."
                        buttonText:NSLocalizedString(@"ALERT_DEFAULT_BUTTON", nil)];
        }
    }];
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err
{
    NSLog(@"Failed to register for remote notifications : %@", err);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    currentInvite = userInfo;
    
    UserSettingsProvider* settings = [[UserSettingsProvider alloc] init];

    //** Payload description **
    //invitationId  - The id of the invitation
    //gameId        - The id of the game
    //playerId      - The id of the player who should receive the invitation
    //nickName      - The nickname of the player who should receive the invitation
    
    
    //get the invited player Id and the current player id
    long invitedPlayerId = [[currentInvite valueForKey:@"playerId"] longLongValue];
    long currentPlayerId = [[settings getPlayerId] longLongValue];
    BOOL playersMatch = invitedPlayerId == currentPlayerId;
    

    //ensure that a game isn't currently being played and that the invite matches the id of the player
    if (!currentlyPlayingGame && playersMatch)
    {
        NSString *message = [[userInfo valueForKey:@"aps"] valueForKey:@"alert"];
        
        
        UIAlertView *notification = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ALERT_DEFAULT_TITLE", nil)
                                                               message:message
                                                              delegate:self
                                                     cancelButtonTitle:NSLocalizedString(@"INVITATION_DECLINE", nil)
                                                     otherButtonTitles:NSLocalizedString(@"INVITATION_ACCEPT", nil), nil];
        
        [notification show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    NSNumber *invitationId = [currentInvite valueForKey:@"invitationId"];
    NSNumber *gameId = [currentInvite valueForKey:@"gameId"];
    
    switch(buttonIndex){
        case 0: //decline
            [self declineInvitation:invitationId
                             gameId:gameId];
            break;
        case 1: //play
            [self acceptInvitation:invitationId
                            gameId:gameId];
            break;
    }
}

-(void)declineInvitation:(NSNumber*)invitationId
                  gameId:(NSNumber*)gameId{
    
    DataProvider *dataProvider = [[DataProvider alloc] init];
    
    [dataProvider declineInvitation:gameId invitationId:invitationId block:^(GTLObject * results) {
        //do nothing
    }];
}

-(void)acceptInvitation:(NSNumber*)invitationId
                 gameId:(NSNumber*)gameId{
    
    [self showAcceptingInvitationStatus];
    
    DataProvider *dataProvider = [[DataProvider alloc] init];
    
    [dataProvider acceptInvitation:gameId invitationId:invitationId block:^(GTLObject * results) {
        
        [self closeAcceptingInvitationStatus];
        
        if(results){
            [self navigateToLobby:gameId];
        }else{
            //display message that challenger must have canceled
            [UIHelper displayAlert:NSLocalizedString(@"ALERT_DEFAULT_TITLE", nil)
                           message:NSLocalizedString(@"INVITATION_CHALLENGER_CANCELED", nil)
                        buttonText:NSLocalizedString(@"ALERT_DEFAULT_BUTTON", nil)];
        }
        
    }];
}

-(void)showAcceptingInvitationStatus{
    
    if(!acceptingInvitationAlertView){
        acceptingInvitationAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ALERT_DEFAULT_TITLE", nil)
                                                             message:NSLocalizedString(@"INVITATION_ACCEPTING_CHALLENGE", nil)
                                                            delegate:self
                                                   cancelButtonTitle:nil
                                                   otherButtonTitles: nil];
        
    }
    
    [acceptingInvitationAlertView show];
}

- (void)closeAcceptingInvitationStatus {
    [acceptingInvitationAlertView dismissWithClickedButtonIndex:-1 animated:TRUE];
}

-(void)navigateToLobby:(NSNumber*)gameId{
    
    //build the command
    LobbyParameters *parameters = [[LobbyParameters alloc] init:gameId
                                                       gameType:MultiPlayer];
    
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
    userInfo[@"viewType"] = @(LOBBY);
    userInfo[@"data"] = parameters;
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:kNavigateToNotification
     object:self
     userInfo:userInfo];
}

- (BOOL)application: (UIApplication *)application
            openURL: (NSURL *)url
  sourceApplication: (NSString *)sourceApplication
         annotation: (id)annotation {
    return [GPPURLHandler handleURL:url
                  sourceApplication:sourceApplication
                         annotation:annotation];
}

@end
