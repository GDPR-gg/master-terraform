//
//  googleOpponentListViewController.m
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

#import "GriddlerOpponentListViewController.h"

#import "DataProvider.h"
#import "enumerations.m"
#import "GTLGriddlerInvitation.h"
#import "LobbyParameters.h"
#import "UserSettingsProvider.h"
#import "ViewTypes.m"
#import "OpponentModel.h"

@interface GriddlerOpponentListViewController() {
@private
    NSNumber* currentInvitationId;
    NSNumber* currentGameId;
    OpponentModel* selectedPlayer;
    BOOL isCanceling;
    UIAlertView *sendInvitationAlertView;
    BOOL isDataLoading;
}

- (void) showNoOpponents;
- (void) showTableView;
- (void) dataLoadComplete;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewSpaceToTopConstraint;

@end

@implementation GriddlerOpponentListViewController

#pragma mark -

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        isDataLoading = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"OPPONENTS_TITLE", nil);
    [super showNavigationBar:YES withBackEnabled:YES withSettingsEnabled:NO];
    
    self.listFilterSegmentControl.selectedSegmentIndex = 0;
    
    if([[[UserSettingsProvider alloc] init] getIsUsingGooglePlus])
        [self loadListWithFriends];
    else{
        //stil takes up vertical space for some reason
         [self.listFilterSegmentControl setHidden:YES];
        [self.tableViewSpaceToTopConstraint setConstant:0.0];
        [self loadListWithPlayers];
    }
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
}



- (void)viewDidUnload {
    [super viewDidUnload];
    // While using code-generation of subView, making sure to clean this up in case ARC doesn't
}

- (void)initViewStyles {
    [super initViewStyles];
    
    UIImage *segmentNormalImage = [[UIImage imageNamed:@"SegmentBackgroundUnselected.png" ] resizableImageWithCapInsets:UIEdgeInsetsMake(0,0,0,0)];
    UIImage *segmentHighlightedImage = [[UIImage imageNamed:@"SegmentBackgroundHighlighted" ] resizableImageWithCapInsets:UIEdgeInsetsMake(0,0,0,0)];
    UIImage *segmentSelectedImage = [[UIImage imageNamed:@"SegmentBackgroundSelected.png" ] resizableImageWithCapInsets:UIEdgeInsetsMake(0,0,3,0)];
    // UIImage *segmentSelectedImage2 = [[UIImage imageNamed:@"SegmentBackgroundSelected.png" ] resizableImageWithCapInsets:UIEdgeInsetsMake(0,0,3,0)];
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                [GriddlerFont defaultButtonFont], UITextAttributeFont,
                                [GriddlerColor white], UITextAttributeTextColor,
                                [UIColor clearColor], UITextAttributeTextShadowColor,
                                [NSValue valueWithUIOffset:UIOffsetMake(0, 0)], UITextAttributeTextShadowOffset, nil];
    [self.listFilterSegmentControl setTitleTextAttributes:attributes forState:UIControlStateNormal];
    NSDictionary *selectedAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [GriddlerFont defaultButtonFont], UITextAttributeFont,
                                        [GriddlerColor defaultLabelColor], UITextAttributeTextColor,
                                        [UIColor clearColor], UITextAttributeTextShadowColor,
                                        [NSValue valueWithUIOffset:UIOffsetMake(0, 0)], UITextAttributeTextShadowOffset, nil];
    [self.listFilterSegmentControl setTitleTextAttributes:selectedAttributes forState:UIControlStateSelected];
    NSDictionary *highlightedAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                           [GriddlerFont defaultButtonFont], UITextAttributeFont,
                                           [GriddlerColor white], UITextAttributeTextColor,
                                           [UIColor clearColor], UITextAttributeTextShadowColor,
                                           [NSValue valueWithUIOffset:UIOffsetMake(0, 0)], UITextAttributeTextShadowOffset, nil];
    
    
    [self.listFilterSegmentControl setTitleTextAttributes:highlightedAttributes forState:UIControlStateHighlighted];
    
    [self.listFilterSegmentControl setBackgroundImage:segmentNormalImage
                                             forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [self.listFilterSegmentControl setBackgroundImage:segmentSelectedImage
                                             forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
    [self.listFilterSegmentControl setBackgroundImage:segmentHighlightedImage
                                             forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
    
    
    UIImage *segmentMiddle_HS = [UIImage imageNamed:@"SegmentMiddleHS.png" ] ;
    [self.listFilterSegmentControl setDividerImage:segmentMiddle_HS
                               forLeftSegmentState:UIControlStateHighlighted
                                 rightSegmentState:UIControlStateSelected
                                        barMetrics:UIBarMetricsDefault];
    
    UIImage *segmentMiddle_SH = [UIImage imageNamed:@"SegmentMiddleSH.png" ] ;
    [self.listFilterSegmentControl setDividerImage:segmentMiddle_SH
                               forLeftSegmentState:UIControlStateSelected
                                 rightSegmentState:UIControlStateHighlighted
                                        barMetrics:UIBarMetricsDefault];
    
    UIImage *segmentMiddle_SU = [UIImage imageNamed:@"SegmentMiddleSU.png" ] ;
    [self.listFilterSegmentControl setDividerImage:segmentMiddle_SU
                               forLeftSegmentState:UIControlStateSelected
                                 rightSegmentState:UIControlStateNormal
                                        barMetrics:UIBarMetricsDefault];
    
    UIImage *segmentMiddle_US = [UIImage imageNamed:@"SegmentMiddleUS.png" ] ;
    [self.listFilterSegmentControl setDividerImage:segmentMiddle_US
                               forLeftSegmentState:UIControlStateNormal
                                 rightSegmentState:UIControlStateSelected
                                        barMetrics:UIBarMetricsDefault];
    
    UIImage *segmentMiddle_HU = [UIImage imageNamed:@"SegmentMiddleHU.png" ] ;
    [self.listFilterSegmentControl setDividerImage:segmentMiddle_HU
                               forLeftSegmentState:UIControlStateHighlighted
                                 rightSegmentState:UIControlStateNormal
                                        barMetrics:UIBarMetricsDefault];
    
    UIImage *segmentMiddle_UH = [UIImage imageNamed:@"SegmentMiddleUH.png" ] ;
    [self.listFilterSegmentControl setDividerImage:segmentMiddle_UH
                               forLeftSegmentState:UIControlStateNormal
                                 rightSegmentState:UIControlStateHighlighted
                                        barMetrics:UIBarMetricsDefault];
    
    [self.noOpponentsText setFont:[GriddlerFont robotoRegularAtSize:18.0]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onLobbyNavigateDown:(id)sender {
    
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
    userInfo[@"viewType"] = @(LOBBY);
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:kNavigateToNotification
     object:self
     userInfo:userInfo];
}

#pragma mark - Table view

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // return at least one row so we can display a message when no opponents were found
    return self.dataSource.count > 0 ? self.dataSource.count : 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    //Table Cell styles
    cell.textLabel.textColor       = [GriddlerColor defaultLabelColor];
    cell.textLabel.font            = [GriddlerFont robotoRegularAtSize:18.0];
    UIView *selectionColor         = [[UIView alloc] init];
    selectionColor.backgroundColor = [GriddlerColor pressColor];
    cell.selectedBackgroundView    = selectionColor;
    
    if(self.dataSource.count != 0)
    {
        OpponentModel* opponent = (self.dataSource)[indexPath.row];
        
        
        cell.textLabel.text  = opponent.displayName;
        cell.imageView.image = [UIImage imageNamed:@"AvatarSmall.png"];
        //[cell setUserInteractionEnabled:YES];
        
        if(opponent.cachedImage)
        {
            NSLog(@"loading image for %@ from cache", opponent.displayName);
            [cell.imageView setImage:[UIImage imageWithData:opponent.cachedImage]];
        }
        else
        {
            // defer new downloads until scrolling ends
            if (self.tableView.dragging == NO && self.tableView.decelerating == NO)
            {
                [self loadImageForOpponent:opponent inCell:cell];
            }
            
        }
    }
    return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(isCanceling){
        [super displayAlert:NSLocalizedString(@"INVITATION_STILL_CANCELING", nil)];
        return;
    }
    
    // Get the player
    NSInteger row = indexPath.row;
    
    selectedPlayer = (self.dataSource)[row];
    
    [self displaySendingInvitationDialog];
    
    [self sendInvitation];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell setSelected:NO];
}

- (void)sendInvitation {
    
    int boardLevel = 1;
    
    DataProvider *data = [[DataProvider alloc] init];
    
    if(selectedPlayer.isPlusUser){
        
        [data sendInvitation:boardLevel
                      plusId:selectedPlayer.playerId
                       block:^(GTLGriddlerInvitation *results) {
           if(results) {
               currentGameId = results.gameId;
               currentInvitationId = results.invitationId;
               
               [self checkInviteeResponse];
           } else {
               [self closeSendingInvitationDialog];
               [self displayAlert:NSLocalizedString(@"INVITATION_USER_NOT_FOUND",nil)];
           }

        }];
    
    }else{
        
        [data sendInvitation:boardLevel
                    playerId:[NSNumber numberWithLongLong:[selectedPlayer.playerId longLongValue]]
                       block:^void(GTLGriddlerInvitation *results) {
                           
                           currentGameId = results.gameId;
                           currentInvitationId = results.invitationId;
                           
                           [self checkInviteeResponse];
                           
                       }];
    }
}

- (void)checkInviteeResponse {
    
    if(!currentGameId || !currentInvitationId || isCanceling)
        return;
    
    DataProvider *data = [[DataProvider alloc] init];
    [data wasInvitationAccepted:currentGameId
                   invitationId:currentInvitationId
                          block:^(GTLGriddlerInvitation *results) {
                              
                              if([results.status isEqual: @"SENT"]) {
                                  
                                  //check again
                                  [NSTimer scheduledTimerWithTimeInterval:2.0
                                                                   target:self
                                                                 selector:@selector(pollForInvitationResponse:)
                                                                 userInfo: nil
                                                                  repeats:NO];
                                  
                                  
                              }else if([results.status isEqual: @"ACCEPTED"]){
                                  
                                  if(isCanceling == NO){
                                      [self closeSendingInvitationDialog];
                                      
                                      [self navigateToLobby];
                                  }

                                  
                              }else{
                                  
                                  [self closeSendingInvitationDialog];
                                  
                                  [self displayAlert:selectedPlayer.displayName
                                             message:NSLocalizedString(@"INVITATION_CHALLENGE_DECLINED", nil)
                                          buttonText:NSLocalizedString(@"ALERT_DEFAULT_BUTTON", nil)];
                              }
                              
                          }];
}

- (void)pollForInvitationResponse:(NSTimer *)theTimer {
    if(!isCanceling && currentGameId && currentInvitationId)
        [self checkInviteeResponse];
}

- (void)displaySendingInvitationDialog {
    
    if(sendInvitationAlertView){
        [sendInvitationAlertView setTitle:selectedPlayer.displayName];
    }else{
        sendInvitationAlertView = [[UIAlertView alloc] initWithTitle:selectedPlayer.displayName
                                                             message:NSLocalizedString(@"INVITATION_SENDING_CHALLENGE", nil)
                                                            delegate:self
                                                   cancelButtonTitle:NSLocalizedString(@"INVITATION_CANCEL", nil)
                                                   otherButtonTitles: nil];
        
    }
    
    [sendInvitationAlertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if(buttonIndex < 0)
        return;
    
    isCanceling = YES;
    
    [self closeSendingInvitationDialog];
    
    DataProvider *data = [[DataProvider alloc] init];
    [data cancelInvitation:currentGameId invitationId:currentInvitationId block:^(GTLObject *results) {
        
        if(!results){
            
            [self displayAlert:selectedPlayer.displayName
                       message:NSLocalizedString(@"OPPONENTS_UNABLE_CANCEL", nil)
                    buttonText:@"OK"];
            
            //check the response again because the invitee accepted
            [self navigateToLobby];
        }else{
            NSLog(@"%s", "invitation canceled");
            [self resetCurrentInvitationParameters];
        }
        
        isCanceling = NO;
        
    }];
}

- (void)navigateToLobby {
    
    //build the command
    LobbyParameters *parameters = [[LobbyParameters alloc] init:currentGameId
                                                       gameType:MultiPlayer];
    
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
    userInfo[@"viewType"] = @(LOBBY);
    userInfo[@"data"] = parameters;
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:kNavigateToNotification
     object:self
     userInfo:userInfo];
}

- (void)resetCurrentInvitationParameters {
    currentInvitationId = nil;
    currentGameId = nil;
    isCanceling = false;
}

- (void)closeSendingInvitationDialog {
    [sendInvitationAlertView dismissWithClickedButtonIndex:-1 animated:TRUE];
}

- (IBAction)listFilterSegmentValueChanged:(id)sender {
    // clear table
    isDataLoading = YES;
    [_tableView reloadData];
    
    UISegmentedControl *segmentedControl = (UISegmentedControl*) sender;
    switch ([segmentedControl selectedSegmentIndex]) {
        case 0:
            [self loadListWithFriends]; break;
        case 1:
            [self loadListWithPlayers]; break;
        case UISegmentedControlNoSegment:
            break;
        default:
            NSLog(@"No option for: %d", [segmentedControl selectedSegmentIndex]);
    }
}

#pragma mark - data services calls

- (void)loadListWithPlayers {
    [super showSpinner];
    
    DataProvider *data = [[DataProvider alloc] init];
    [data  getPlayers:^void(NSArray *results) {
        
        self.dataSource = [NSMutableArray arrayWithArray:results];
        
        [self dataLoadComplete];
    }];
}

-(void)dataLoadComplete{
    [super hideSpinner];
    if(self.dataSource.count > 0){
        [self showTableView];
        [_tableView reloadData];
        isDataLoading = NO;
    }
    else{
        [self showNoOpponents];
    }
}

- (void)loadListWithFriends {
    [super showSpinner];
    [GoogleService loadUserFriends:^(NSArray *friends) {
        self.dataSource = [NSMutableArray arrayWithArray:friends];
        [self dataLoadComplete];
    }];
}

#pragma mark - UIScrollViewDelegate protocol

// Load images for onscreen opponents when scrolling is finished
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        [self loadImagesForOnscreenOpponents];
    }
}

// Load images for onscreen opponents when scrolling is finished
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self loadImagesForOnscreenOpponents];
}

#pragma mark - opponent image methods

- (void)loadImagesForOnscreenOpponents {
    if ([self.dataSource count] > 0)
    {
        NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
        for (NSIndexPath *indexPath in visiblePaths)
        {
            OpponentModel* opponent = (self.dataSource)[indexPath.row];
            
            if (!opponent.cachedImage)
            {
                [self loadImageForOpponent:opponent
                                    inCell:[self.tableView cellForRowAtIndexPath:indexPath]];
            }
        }
    }
}

- (void)loadImageForOpponent:(OpponentModel*)opponent inCell:(UITableViewCell *)cell {
    NSLog(@"loading image for %@...", opponent.displayName);
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:opponent.imageUrl]]
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
         
         if (!error && [httpResponse statusCode] == 200)
         {
             NSLog(@"loading image for %@...Done!", opponent.displayName);
             if (self.view.window) {
                 [cell.imageView setImage:[UIImage imageWithData:data]];
                 opponent.cachedImage = data;
             }
         }
     }];
}

- (void)showNoOpponents{
    [self.tableView setHidden:YES];
    [self.noOpponentsImageView setHidden:NO];
    [self.noOpponentsText setHidden:NO];
}
- (void)showTableView{
    [self.tableView setHidden:NO];
    [self.noOpponentsImageView setHidden:YES];
    [self.noOpponentsText setHidden:YES];
}

@end
