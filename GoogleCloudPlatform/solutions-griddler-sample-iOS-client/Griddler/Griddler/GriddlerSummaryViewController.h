//
//  googleSummaryViewController.h
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

@interface GriddlerSummaryViewController : FrameworkUIViewController<UITableViewDataSource, UITableViewDelegate>

- (IBAction)onLandingNavigationDown:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *mainMenuButton;

@property (weak, nonatomic) IBOutlet UILabel *mainLabel;

@property (weak, nonatomic) IBOutlet UILabel *subLabel;

@property (weak, nonatomic) IBOutlet UILabel *rightHeaderLabel;

@property (weak, nonatomic) IBOutlet UILabel *leftHeaderLabel;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong,atomic) NSMutableArray* dataSource;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollViewer;

@property (strong, nonatomic) IBOutlet UIView *headerDivider;

@property (weak, nonatomic) IBOutlet UIView *headerContainer;

@end
