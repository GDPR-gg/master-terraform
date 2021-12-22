//
//  googleSplashViewController.m
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

#import "GriddlerSplashViewController.h"
#import "ViewTypes.m"

@implementation GriddlerSplashViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.navigationItem.title = @"Splash View";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.splashImage.animationImages = [NSArray arrayWithObjects:
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
        self.splashImage.animationImages = [NSArray arrayWithObjects:
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
    
    self.splashImage.animationDuration = 1.2f;
    self.splashImage.animationRepeatCount = 0;
    [self.splashImage startAnimating];
    self.splashImage.contentMode = UIViewContentModeScaleAspectFit;
    
    self.view.backgroundColor = [GriddlerColor interactiveBackground];
    
    [super showNavigationBar:NO withBackEnabled:NO withSettingsEnabled:NO];
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //[ self.navigationController  setNavigationBarHidden:YES ];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onDataset:(NSObject*)data{
    [super onDataset:data];
}

@end
