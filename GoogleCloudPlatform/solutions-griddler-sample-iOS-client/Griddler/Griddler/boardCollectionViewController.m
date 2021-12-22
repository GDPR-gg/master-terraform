//
//  boardCollectionViewController.m
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

#import "boardCollectionViewController.h"
#import "cardCellView.h"
#import "boardLayout.h"
#import "viewTypes.m"

static NSString * const cardCellIdentifier = @"cardCell";

@interface boardCollectionViewController (){
@private
    bool isDragging;
    bool isTransitioning;
    
    // represents all questions/answers
    NSArray *questions;
    NSArray *answers;
    
    // board
    NSMutableArray *letters;
    NSMutableArray *cells;
    NSMutableArray *selectionQueue;
}

@property (nonatomic, readwrite) int selectedIndex;

@property (nonatomic, readwrite) int totalQuestions;

@property (nonatomic, readwrite) NSMutableArray *selectedIndexes;

@property (nonatomic, readwrite) NSString *currentQuestion;

@property (nonatomic, weak) IBOutlet boardLayout *boardLayout;

@property (nonatomic, readwrite) NSMutableArray *selectedLetters;

@end

@implementation boardCollectionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        isDragging = false;
        isTransitioning = false;
        self.selectedLetters = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    [self.view setBackgroundColor:[GriddlerColor lightAqua]];
    [self.collectionView setBackgroundColor:[GriddlerColor lightAqua]];
    
    [self.collectionView registerClass:[cardCellView class]
            forCellWithReuseIdentifier:cardCellIdentifier];

    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)skip
{
    isTransitioning = true;
    
    for(cardCellView * cellView in cells) {
        if(cellView.isSelected)
        {
            [cellView questionSkipped];
        }
    }
    
    int currentIndex = self.selectedIndex+1;
    if(currentIndex > answers.count-1)
        currentIndex = 0;
    while([self.selectedIndexes containsObject:[NSNumber numberWithInt:currentIndex]])
    {
        currentIndex++;
        if(currentIndex > answers.count-1)
            currentIndex = 0;
    }
    self.selectedIndex = currentIndex;
    self.currentQuestion = [questions objectAtIndex:self.selectedIndex];
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:kQuestionSkippedNotification
     object:self
     userInfo:nil];
    
    isTransitioning = false;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 25;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    cardCellView *photoCell =
    [collectionView dequeueReusableCellWithReuseIdentifier:cardCellIdentifier
                                              forIndexPath:indexPath];
    
    photoCell.boardCollectionViewController = self;
    [photoCell setLetterValue:[letters objectAtIndex:indexPath.section]];
    
    if([cells indexOfObject:photoCell] == NSNotFound)
        [cells addObject:photoCell];
    
    return photoCell;
}


#pragma mark -
#pragma mark === Touch handling  ===
#pragma mark

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(!isTransitioning)
    {
        isDragging = true;
        
        for (UITouch* touch in event.allTouches)
        {
            CGPoint location = [touch locationInView: self.view];
            for(cardCellView * cellView in cells) {
                if(CGRectContainsPoint([cellView frame], location))
                {
                    if(!cellView.isSelected)
                    {
                        [cellView selected];
                        [self.selectedLetters addObject:cellView.letter];
                        [selectionQueue addObject:cellView];
                        [self qualifySelectedWords];
                        
                        [[NSNotificationCenter defaultCenter]
                         postNotificationName:kLetterSelectedNotification
                         object:self
                         userInfo:nil];
                    }
                }
            }
        }
        
        [super touchesBegan: touches withEvent: event];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(!isTransitioning)
    {
        for (UITouch* touch in event.allTouches)
        {
            CGPoint location = [touch locationInView: self.view];
            for(cardCellView * cellView in cells) {
                if(CGRectContainsPoint([cellView frame], location))
                {
                    if(!cellView.isSelected)
                    {
                        [cellView selected];
                        [self.selectedLetters addObject:cellView.letter];
                        [selectionQueue addObject:cellView];
                        [self qualifySelectedWords];
                        
                        [[NSNotificationCenter defaultCenter]
                         postNotificationName:kLetterSelectedNotification
                         object:self
                         userInfo:nil];
                    }
                }
            }
        }
        
        [super touchesMoved: touches withEvent: event];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(!isTransitioning)
    {
        for (UITouch* touch in event.allTouches)
        {
            for(cardCellView * cellView in cells) {
                if(cellView.isSelected)
                {
                    [cellView unselected];
                    [selectionQueue removeObject:cellView];
                    [self.selectedLetters removeObject:cellView.letter];
                    
                    [[NSNotificationCenter defaultCenter]
                     postNotificationName:kLetterUnselectedNotification
                     object:self
                     userInfo:nil];
                }
            }
        }
        
        isDragging = false;
        
        [super touchesEnded: touches withEvent: event];
    }
}


-(void)onTransitionCompletedAnswered:(NSTimer*) timer{
    
    [self.selectedLetters removeAllObjects];
    
    if(answers.count == self.selectedIndexes.count)
    {
        [[NSNotificationCenter defaultCenter]
         postNotificationName:kGameCompletedNotification
         object:self
         userInfo:nil];
    }
    else{
        int currentIndex = self.selectedIndex;
        while([self.selectedIndexes containsObject:[NSNumber numberWithInt:currentIndex]])
        {
            currentIndex++;
            if(currentIndex > answers.count-1)
                currentIndex = 0;
        }
        self.selectedIndex = currentIndex;
        self.currentQuestion = [questions objectAtIndex:self.selectedIndex];
        
        [[NSNotificationCenter defaultCenter]
         postNotificationName:kQuestionAnsweredNotification
         object:self
         userInfo:nil];
    }
    
    isTransitioning = false;
}

-(void)onQuestionAnswered:(NSNumber*)matchedIndex{
    isTransitioning = true;

    [selectionQueue removeAllObjects];
    [self.selectedIndexes addObject:matchedIndex];
    
    for(cardCellView * cellView in cells) {
        if(cellView.isSelected)
        {
            [cellView questionAnswered];
        }
    }
    
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
    userInfo[@"matchedIndex"] = matchedIndex;
    [NSTimer scheduledTimerWithTimeInterval:1.0
                                     target:self
                                   selector:@selector(onTransitionCompletedAnswered:)
                                   userInfo:userInfo
                                    repeats:NO];
}

-(void)qualifySelectedWords{
    NSNumber* matchedIndex;
    for(int p=0; p<=answers.count-1; p++){
        if(![self.selectedIndexes containsObject:[NSNumber numberWithInt:p]] && p == [self selectedIndex])
        {
            NSString *pendingWord = [answers objectAtIndex:p];
            if(selectionQueue.count == pendingWord.length)
            {
                bool allLettersMatch= true;
                for(int i=0; i<=pendingWord.length-1; i++)
                {
                    NSString* letterAtCell = [[selectionQueue objectAtIndex:i] letter];
                    NSString* letterInPendingWord = [pendingWord substringWithRange:NSMakeRange(i, 1)];
                    if(![letterAtCell.lowercaseString isEqualToString:letterInPendingWord.lowercaseString])
                    {
                        allLettersMatch = false;
                        break;
                    }
                }
                
                if(allLettersMatch)
                {
                    matchedIndex = [NSNumber numberWithInt:p];
                    break;
                }
            }
        }
    }
    if(matchedIndex)
        [self onQuestionAnswered:matchedIndex];
}

-(void)setData:(GTLGriddlerBoard*)model{
    cells = [[NSMutableArray alloc] init];
    selectionQueue = [[NSMutableArray alloc] init];
    
    letters = [[NSMutableArray alloc] init];
    
    for(int i=0; i<=model.gridDefinition.count-1; i++)
    {
        NSString *row = [model.gridDefinition objectAtIndex:i];
        for(int p=0;p<=[row length]-1; p++)
        {
            [letters addObject:[row substringWithRange:NSMakeRange(p, 1)]];
        }
    }
    
    answers = model.answers;
    questions = model.riddles;
    
    self.selectedIndexes = [[NSMutableArray alloc] init];
    
    self.selectedIndex = 0;
    self.currentQuestion = [questions objectAtIndex:self.selectedIndex];
    self.totalQuestions = questions.count;
}

@end
