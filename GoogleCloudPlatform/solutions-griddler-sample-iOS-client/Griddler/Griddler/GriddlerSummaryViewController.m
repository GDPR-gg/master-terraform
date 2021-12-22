//
//  googleSummaryViewController.m
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

#import "GriddlerSummaryViewController.h"
#import "viewTypes.m"
#import "GameModel.h"
#import "DataProvider.h"
#import "ResultTableCell.h"

@interface GriddlerSummaryViewController () {
 @private
    GameModel* game;
    UINib *cellLoader;
    NSArray *currentPlayerAnswers;
}
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewHeightConstraint;

@end

@implementation GriddlerSummaryViewController

static NSString *CellClassName = @"ResultTableCell";

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        cellLoader = [UINib nibWithNibName:CellClassName bundle:[NSBundle mainBundle]];
        currentPlayerAnswers = [[NSArray alloc]init];
    }
    return self;
}

- (void)initViewStyles {
    [super initViewStyles];
    [self.mainLabel setFont:[GriddlerFont robotoRegularAtSize:20.0]];
    [self.subLabel setFont:[GriddlerFont defaultLabelFont]];
    [self.subLabel setTextColor:[GriddlerColor white]];
    [self.leftHeaderLabel setFont:[GriddlerFont robotoRegularAtSize:15.0]];
    [self.rightHeaderLabel setFont:[GriddlerFont robotoRegularAtSize:15.0]];
    [self.headerDivider setBackgroundColor:[GriddlerColor aqua]];
    [self.headerContainer setBackgroundColor:[GriddlerColor aqua]];
    [self.mainMenuButton setTitleEdgeInsets:UIEdgeInsetsMake(2.5f, 0.0f, 0.0f, 0.0f)];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onLandingNavigationDown:(id)sender {
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
    userInfo[@"viewType"] = @(LANDING);
    userInfo[@"clearBackstack"] = @YES;
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:kNavigateToNotification
     object:self
     userInfo:userInfo];
}

- (void)onDataset:(NSObject*)data {
    [super onDataset:data];
    
    [super showSpinner:@"Submitting Answers..."];

    game = (GameModel*)data;
    
    DataProvider *dataProvider = [[DataProvider alloc] init];
    
    GTLGriddlerGamePlay *gamePlay = [GTLGriddlerGamePlay alloc];
    gamePlay.correctAnswers = [game getCurrentPlayer].correctAnswers;
    gamePlay.timeLeft = [game getCurrentPlayer].timeLeft;
    
    [dataProvider submitAnswers:game.gameId
                        answers:gamePlay
                          block:^(GTLObject *results) {
        if([game isSinglePlayerGame] == YES){
            //just use the game that is declared above
            [self refreshView];
            
        }else{
            [self checkIfOpponentIsFinished];
        }
    }];
}


- (void)checkIfOpponentIsFinished {
    
    [super showSpinner:@"Waiting for opponent to finish..."];
    
    DataProvider *data = [[DataProvider alloc] init];
    
    [data getGame:game.gameId block:^(GameModel *results) {
        if([results havePlayersFinished] == YES){
            //populate data
            game = results;
            [self refreshView];
        }else{
            //start a timer to check again
            [NSTimer scheduledTimerWithTimeInterval:2.0
                                             target:self
                                           selector:@selector(pollForCompletedGame:)
                                           userInfo: nil
                                            repeats:NO];
        }
    }];
}

- (void)pollForCompletedGame:(NSTimer *)theTimer {
    [self checkIfOpponentIsFinished];
}

- (void)refreshView {
    GTLGriddlerBoard *boardDetail = [game board];
    
  
    self.dataSource = [[NSMutableArray alloc] init];
    for (NSString *answer in boardDetail.answers)
        [self.dataSource addObject:answer];
    float newHeight = self.dataSource.count * 47.0;
    [self.tableViewHeightConstraint setConstant:newHeight];
    [self.tableView reloadData];

    GTLGriddlerGamePlay *currentPlayer = [game getCurrentPlayer];
    NSUInteger questionCount = boardDetail.answers.count;
    currentPlayerAnswers = [currentPlayer correctAnswers];
    NSUInteger currentCorrectCount = currentPlayerAnswers.count;

if (currentCorrectCount == questionCount) {
        self.mainLabel.text = NSLocalizedString(@"SUMMARY_PERFECT", nil);
    } else {
        self.mainLabel.text = NSLocalizedString(@"SUMMARY_TIMES_UP", nil);
    }
    self.subLabel.text = [NSString stringWithFormat:NSLocalizedString(@"SUMMARY_YOU_GOT_CORRECT", nil), currentCorrectCount, questionCount];

  if([game isSinglePlayerGame] == NO) {
      GTLGriddlerGamePlay *opponent = [game getOpponent];
      NSUInteger opponentCorrectCount = [opponent correctAnswers].count;
      NSString* currentPlayerName = NSLocalizedString(@"SUMMARY_HEADER_YOU", nill);
      [self.leftHeaderLabel setText:currentPlayerName];
      NSString* opponentName = [opponent.player nickname];
      [self.rightHeaderLabel setText:opponentName];
      if([currentPlayer.isWinner boolValue]){
          self.mainLabel.text = NSLocalizedString(@"SUMMARY_YOU_WON", nil);
          self.subLabel.text = [NSString stringWithFormat:NSLocalizedString(@"SUMMARY_BEAT_SOMEONE", nil), currentPlayerName, opponentName,currentCorrectCount, opponentCorrectCount];
          if(currentCorrectCount == opponentCorrectCount)
              self.subLabel.text = [NSString stringWithFormat:NSLocalizedString(@"SUMMARY_YOU_FINISHED_BEFORE", nil), opponentName];
      }
      else {
          self.mainLabel.text = NSLocalizedString(@"SUMMARY_YOU_LOST", nil);
          self.subLabel.text = [NSString stringWithFormat:NSLocalizedString(@"SUMMARY_BEAT_SOMEONE", nil), opponentName, currentPlayerName,currentCorrectCount, opponentCorrectCount];
          if(currentCorrectCount == opponentCorrectCount)
              self.subLabel.text = [NSString stringWithFormat:NSLocalizedString(@"SUMMARY_FINISHED_BEFORE_YOU", nil), opponentName];
      }
      if(currentCorrectCount == opponentCorrectCount
         && [opponent timeLeft] == [currentPlayer timeLeft])
          self.mainLabel.text = NSLocalizedString(@"SUMMARY_TIE", nil);
  }
    
    [super hideSpinner];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Note: I set the cell's Identifier property in Interface Builder to DemoTableViewCell.
    ResultTableCell *cell = (ResultTableCell *)[tableView dequeueReusableCellWithIdentifier:CellClassName];
    if (!cell)
    {
        NSArray *topLevelItems = [cellLoader instantiateWithOwner:self options:nil];
        cell = [topLevelItems objectAtIndex:0];
    }

    //Table Cell styles
    [cell.wordLabel setTextColor:[GriddlerColor red]];
    [cell.wordLabel setFont:[GriddlerFont robotoBoldAtSize:20.0]];
    [cell.centerWordLabel setTextColor:[GriddlerColor red]];
    [cell.centerWordLabel setFont:[GriddlerFont robotoBoldAtSize:20.0]];
    [cell setUserInteractionEnabled:NO];

    // Configure the cell...
    NSInteger row = indexPath.row;
    NSString *answer = [[self.dataSource objectAtIndex:row] uppercaseString];

    if ([game isSinglePlayerGame]) {
        for (NSNumber *indexNumber in currentPlayerAnswers)
        {
            NSInteger index = [indexNumber integerValue];
            if (row == index)
                [cell.imageView setHidden:NO];
        }
        cell.wordLabel.text = answer;
    }
    else {
        [cell.wordLabel setHidden:YES];
        [cell.centerWordLabel setHidden:NO];
        for (NSNumber *indexNumber in currentPlayerAnswers)
        {
            NSInteger index = [indexNumber integerValue];
            if (row == index)
                [cell.leftIMageView setHidden:NO];
        }
        for (NSNumber *indexNumber in [game getOpponent].correctAnswers)
        {
            NSInteger index = [indexNumber integerValue];
            if (row == index)
                [cell.imageView setHidden:NO];
        }
        cell.centerWordLabel.text = answer;
    }

    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

}

@end
