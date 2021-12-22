//
//  googleLobbyViewController.m
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

#import "GriddlerLobbyViewController.h"
#import "ViewTypes.m"
#import "enumerations.m"
#import "LobbyParameters.h"
#import "DataProvider.h"
#import "GameModel.h"

@interface GriddlerLobbyViewController ()
{
    @private
    NSTimer *countdownTimer;
    GameModel *game;
    int countdown; 
}


@end

@implementation GriddlerLobbyViewController

const int COUNTDOWN = 3;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.countdownLabel setHidden:YES];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.loadingImage.animationImages = [NSArray arrayWithObjects:
                                            [UIImage imageNamed:@"Interactive-1.png"],
                                            [UIImage imageNamed:@"Interactive-2.png"],
                                            [UIImage imageNamed:@"Interactive-3.png"],
                                            [UIImage imageNamed:@"Interactive-4.png"],
                                            [UIImage imageNamed:@"Interactive-5.png"],
                                            [UIImage imageNamed:@"Interactive-6.png"],
                                            [UIImage imageNamed:@"Interactive-7.png"],
                                            [UIImage imageNamed:@"Interactive-8.png"],
                                            [UIImage imageNamed:@"Interactive-0.png"],
                                            [UIImage imageNamed:@"Interactive-0.png"],
                                            [UIImage imageNamed:@"Interactive-0.png"],
                                            nil];
    }
    else{
        self.loadingImage.animationImages = [NSArray arrayWithObjects:
                                            [UIImage imageNamed:@"Interactive-1@2x.png"],
                                            [UIImage imageNamed:@"Interactive-2@2x.png"],
                                            [UIImage imageNamed:@"Interactive-3@2x.png"],
                                            [UIImage imageNamed:@"Interactive-4@2x.png"],
                                            [UIImage imageNamed:@"Interactive-5@2x.png"],
                                            [UIImage imageNamed:@"Interactive-6@2x.png"],
                                            [UIImage imageNamed:@"Interactive-7@2x.png"],
                                            [UIImage imageNamed:@"Interactive-8@2x.png"],
                                            [UIImage imageNamed:@"Interactive-0@2x.png"],
                                            [UIImage imageNamed:@"Interactive-0@2x.png"],
                                            [UIImage imageNamed:@"Interactive-0@2x.png"],
                                            nil];
    }
    
    self.loadingImage.animationDuration = 1.2f;
    self.loadingImage.animationRepeatCount = 0;
    [self.loadingImage startAnimating];
    //self.loadingImage.contentMode = UIViewContentModeScaleAspectFit;
    
    [super showNavigationBar:NO withBackEnabled:NO withSettingsEnabled:NO];
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onDataset:(NSObject*)data{
    [super onDataset:data];
    
    //send a notification that the game is about the start
    //this is set so the application knows not to show
    //notifications during game play
    [[NSNotificationCenter defaultCenter]
     postNotificationName:kGameStartedNotification
     object:self
     userInfo:nil];
    
    if(!data)
        return;
    
    self.statusLabel.text = NSLocalizedString(@"LOBBY_BUILDING_GAME_BOARD", nil);
    
    countdown = COUNTDOWN;
    
    LobbyParameters *parameters = (LobbyParameters *)data;
    
    switch(parameters.gameType){
        case SinglePlayer:
            [self startNewSinglePlayerGame];
            break;
        case MultiPlayer:
            [self getGame:parameters.gameId];
            break;
    }
}

- (void)initViewStyles {
    [self.view setBackgroundColor:[GriddlerColor interactiveBackground ]];
    [self.countdownLabel setFont:[GriddlerFont robotoRegularAtSize:140.0]];
    [self.countdownLabel setTextColor:[GriddlerColor white]];
    [self.statusLabel setFont:[GriddlerFont robotoLightAtSize:13.0]];
    [self.statusLabel setTextColor:[GriddlerColor white] ];
}

- (void)displayLoadingImage{
}

- (void)startNewSinglePlayerGame{
    
    int boardLevel = 1;
    
    //get a new single player game
    DataProvider *data = [[DataProvider alloc] init];    
    [data startNewSinglePlayerGame:boardLevel
                             block:^void(GameModel *results) {
                                  
                                 
                                 self.loadingImage.hidden = YES;
                                 
                                  self.statusLabel.text = NSLocalizedString(@"LOBBY_GET_READY_TO_PLAY", nil);
                                  
                                  game = results;
                                  [self startCountdownTimer];
        
    }];
}

-(void)getGame:(NSNumber*)gameId{
    
    DataProvider *data = [[DataProvider alloc] init];
    
    [data getGame:gameId block:^(GameModel *results) {
        
        game = results;
        
        self.loadingImage.hidden = YES;
        
        self.statusLabel.text = [NSString stringWithFormat:NSLocalizedString(@"LOBBY_GET_READY_TO_PLAY_OPPONET", nil), [game getOpponent].player.nickname];
        
        [self startCountdownTimer];
    }];
}

- (void)startCountdownTimer{
    
    [self.countdownLabel setHidden:NO];
    self.countdownLabel.text = [NSString stringWithFormat:@"%d", countdown];
    
    countdownTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                                      target:self
                                                    selector:@selector(onTimeCompleted)
                                                    userInfo:nil
                                                     repeats:YES];
}

-(void)onTimeCompleted
{
    countdown--;
    
    if(countdown == 0){
        [countdownTimer invalidate];
        countdownTimer = nil;
        
        [self navigateToGame];
    }else{
        self.countdownLabel.text = [NSString stringWithFormat:@"%d", countdown];
    }
}

-(void)navigateToGame{
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
    userInfo[@"viewType"] = @(GAME_BOARD);
    userInfo[@"data"] = game;
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:kNavigateToNotification
     object:self
     userInfo:userInfo];
}

@end
