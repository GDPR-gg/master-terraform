//
//  googleGameBoardViewController.h
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

#import <UIKit/UIKit.h>
#import "FrameworkUIViewController.h"
#import "BoardCollectionViewController.h"

@interface GriddlerGameBoardViewController : FrameworkUIViewController<UICollectionViewDelegate, UICollectionViewDataSource>
{
    boardCollectionViewController *boardCollectionViewController;
}

@property (nonatomic, retain) boardCollectionViewController *boardCollectionViewController;
@property (weak, nonatomic) IBOutlet UITextView *questionTextView;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UILabel *skipLabel;
@property (weak, nonatomic) IBOutlet UILabel *answerLettersLabel;

@property (weak, nonatomic) IBOutlet UILabel *paginationText;
@property (weak, nonatomic) IBOutlet UILabel *timeText;
@end


