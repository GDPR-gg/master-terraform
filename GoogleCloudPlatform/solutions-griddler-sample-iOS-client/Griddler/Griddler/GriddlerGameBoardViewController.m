//
//  googleGameBoardViewController.m
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

#import "GriddlerGameBoardViewController.h"
#import "viewTypes.m"
#import "GriddlerAppDelegate.h"
#import "GameModel.h"
#import "CoundownView.h"
#import "cardCellView.h"

@interface GriddlerGameBoardViewController ()
{
    GameModel *model;
    NSTimer *loopTimer;
    NSTimer *countdownTimer;
    NSDate *startTime;
    NSDate *endTime;
    CountdownView *countdownView;
}
@end

@implementation GriddlerGameBoardViewController
@synthesize boardCollectionViewController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self.view setBackgroundColor:[GriddlerColor gameboardBackground]];
        
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat screenWidth = screenRect.size.width;
        
        CGFloat iPadOffset = 0;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            iPadOffset = 90;
        }
   
        [self.headerView setBackgroundColor:[GriddlerColor aqua]];
        
        countdownView = [[CountdownView alloc] init];
        [self.view addSubview:countdownView];
        int timerHeight = 21;
        CGRect countdownViewFrame = CGRectMake(screenWidth/2 - timerHeight/2,29 + iPadOffset,timerHeight,timerHeight);
        [countdownView setFrame:countdownViewFrame];
        
        if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
            self.edgesForExtendedLayout = UIRectEdgeNone;
        
        //Add the board
        self.boardCollectionViewController = [[boardCollectionViewController alloc] initWithNibName:@"boardCollectionView_iPhone" bundle:nil];
        [self.view addSubview:self.boardCollectionViewController.view];
        
        CGFloat startBoard = 0;
        if(screenWidth > 320) {
            startBoard = (screenWidth - 320)/2;
            screenWidth = 320;
        }
        
        CGRect newFrame = CGRectMake(startBoard,140 + iPadOffset,screenWidth,400);
        [self.boardCollectionViewController.view setFrame:newFrame];
        [self.boardCollectionViewController.view setAutoresizingMask:UIViewAutoresizingNone];
        //[self.boardCollectionViewController.view setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin];
        
        
        self.questionTextView.font = [GriddlerFont gameboardQuestion];
        self.questionTextView.backgroundColor = [UIColor clearColor];
        
        self.skipLabel.font = [GriddlerFont gameboardSkip];
        
        self.paginationText.textColor =[GriddlerColor white];
        self.timeText.textColor =[GriddlerColor white];
        
        self.answerLettersLabel.textColor = [GriddlerColor red];
        self.answerLettersLabel.contentMode = UIViewContentModeScaleAspectFill;
        self.answerLettersLabel.clipsToBounds = YES;
        [self.answerLettersLabel setBackgroundColor:[UIColor clearColor]];
        self.answerLettersLabel.font = [GriddlerFont gameboardAnswerLetter];
        [self.answerLettersLabel setTextAlignment:NSTextAlignmentCenter];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onGameCompletedNotification:)
                                                     name:kGameCompletedNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onQuestionSkippedNotification:)
                                                     name:kQuestionSkippedNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onQuestionAnsweredNotification:)
                                                     name:kQuestionAnsweredNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onLetterSelectedNotification:)
                                                     name:kLetterSelectedNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onLetterUnselectedNotification:)
                                                     name:kLetterUnselectedNotification
                                                   object:nil];
        
        [self updateUI];
        [self updateAnswerLetters];
    }
    return self;
}

-(void)updateAnswerLetters{
    if(self.boardCollectionViewController)
    {
        NSMutableString* content = [NSMutableString string];
        for (int aa=0; aa < self.boardCollectionViewController.selectedLetters.count; aa++){
            [content appendString:[NSString stringWithFormat:@"%@ ",[self.boardCollectionViewController.selectedLetters objectAtIndex:aa]]];
        }
        self.answerLettersLabel.text = content;
    }
}

-(void)onLetterSelectedNotification:(NSNotification *) notification
{
    [self updateAnswerLetters];
}

-(void)onLetterUnselectedNotification:(NSNotification *) notification
{
    [self updateAnswerLetters];
}

-(void)onQuestionSkippedNotification:(NSNotification *) notification
{
    [self updateUI];
    [self updateAnswerLetters];
}

- (void) onGameCompletedNotification:(NSNotification *) notification
{
    // Finished Game
    [NSTimer scheduledTimerWithTimeInterval:1.0
                                     target:self
                                   selector:@selector(navigateToSummary)
                                   userInfo:nil
                                    repeats:NO];
}

-(void)updateUI{
    // update visual states
    
    self.questionTextView.text = self.boardCollectionViewController.currentQuestion;
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineHeightMultiple =20.0f;
    paragraphStyle.maximumLineHeight = 20.0f;
    paragraphStyle.minimumLineHeight = 20.0f;
    [paragraphStyle setAlignment:NSTextAlignmentCenter];
    
    NSString *string = self.questionTextView.text;
    NSDictionary *ats = @{
                          NSFontAttributeName : [UIFont fontWithName:@"Roboto" size:20.0f],
                          NSParagraphStyleAttributeName : paragraphStyle,
                          };
    
    self.questionTextView.attributedText = [[NSAttributedString alloc] initWithString:string attributes:ats];
    
    double totalTime = [endTime timeIntervalSinceDate:startTime];
    double remaining = [endTime timeIntervalSinceDate:[NSDate date]];
    double percent =  1 - (remaining / totalTime);
    [countdownView setRemainingTimePercent:percent];
    
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"m:ss"];
    NSDate *date = [NSDate dateWithTimeIntervalSinceReferenceDate:remaining];
    NSString *formattedDateString = [dateFormatter stringFromDate:date];
    
    self.timeText.text = formattedDateString;
    self.paginationText.text = [NSString stringWithFormat:@"%d of %d",self.boardCollectionViewController.selectedIndex + 1, self.boardCollectionViewController.totalQuestions ];
}




- (void) onQuestionAnsweredNotification:(NSNotification *) notification
{
    [self updateUI];
    [self updateAnswerLetters];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [ self.navigationController  setNavigationBarHidden:YES ];
}


-(void)navigateToSummary {
    
    [loopTimer invalidate];
    loopTimer = nil;
    
    [countdownTimer invalidate];
    countdownTimer = nil;
    
    
    
    // save game state
    long long remaining = [endTime timeIntervalSinceDate:[NSDate date]] * 1000;
    [model assignAnswersAndTimeLeft:self.boardCollectionViewController.selectedIndexes
                           timeLeft:[NSNumber numberWithLongLong:remaining]];
    
    
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
    userInfo[@"viewType"] = @(SUMMARY);
    userInfo[@"data"] = model;
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:kNavigateToNotification
     object:self
     userInfo:userInfo];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [ self.navigationController  setNavigationBarHidden:NO ];
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
    
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onDataset:(NSObject*)data{
    [super onDataset:data];
    
    model = (GameModel*)data;
    [self.boardCollectionViewController setData:model.board];
    
    loopTimer  = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(updateUI) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:loopTimer forMode:NSRunLoopCommonModes];
    
    double seconds = [model.board.allottedTime doubleValue] / 1000.0;
    countdownTimer = [NSTimer scheduledTimerWithTimeInterval:seconds
                                                      target:self
                                                    selector:@selector(onTimeCompleted)
                                                    userInfo:nil
                                                     repeats:NO];
    
    startTime = [NSDate date];
    endTime = [startTime dateByAddingTimeInterval:seconds];
    
    [self updateUI];
}

-(void)onTimeCompleted
{
    [loopTimer invalidate];
    loopTimer = nil;
 
    [countdownTimer invalidate];
    countdownTimer = nil;
    
    // save the game
    [[NSNotificationCenter defaultCenter]
     postNotificationName:kGameCompletedNotification
     object:self
     userInfo:nil];

}

-(void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event{
    UITouch *touch = [touches anyObject];
    
    if(touch.view.tag == 1)
    {
        [self.boardCollectionViewController skip];
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    return nil;
}

@end
