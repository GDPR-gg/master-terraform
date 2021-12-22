//
//  ResponderNavigationController.m
//  Represents the concrete implementation for the RepsonderNavigationController
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

#import "ResponderNavigationController.h"
#import "ViewTypes.m"
#import "FrameworkUIViewController.h"


@implementation ResponderNavigationController

- (id) init {
    self = [super init];
    if (self) {
        
        // Subscribe to the notification center for navigation events
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleNotification:)
                                                     name:kNavigateToNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleNotification:)
                                                     name:kNavigateBackNotification
                                                   object:nil];
    }
    return self;
}

// Called when a navigation notification is available
- (void) handleNotification:(NSNotification *) notification {
    NSDictionary *userInfo = [notification userInfo];
    
    if ([[notification name] isEqualToString:kNavigateToNotification] &&
        self.viewResolver){
        
        NSString *viewName = [notification object];
        //data below is used when the view being navigated to expects parameters
        NSObject *postData = userInfo[@"data"];
        NSNumber *num = userInfo[@"viewType"];
        int viewTypeIntValue = [num intValue];
        UIViewController *viewController = userInfo[@"viewController"];
        
        // If user didn't post a view controller, use the resolver
        if(!viewController){
            viewController = [self.viewResolver resolve:viewName type:viewTypeIntValue];
        }
        
        if(viewController)
        {
            //The boolean value clearBackstack represents a flag telling
            //the navigation controller if the new view should be at the
            //top of the navigation stack
            BOOL clearBackstack = [userInfo[@"clearBackstack"] boolValue];
            if(clearBackstack){
                if([[self viewControllers] containsObject:viewController]) {
                    [self popToViewController:viewController animated:YES];
                } else {
                    [self setViewControllers:@[viewController] animated:YES];
                }
            }
            else {
                [self pushViewController:viewController animated:YES];
            }
            
            if([viewController isKindOfClass:[FrameworkUIViewController class]])
            {
                [((FrameworkUIViewController *)viewController) onDataset:postData];
            }
        }
        else{
            NSLog (@"Navigation Failure for ViewName %@", viewName);
        }
    }else
        if ([[notification name] isEqualToString:kNavigateBackNotification]){
            NSLog (@"Navigating back");
            [self popToRootViewControllerAnimated:YES];
        }
}

@end
