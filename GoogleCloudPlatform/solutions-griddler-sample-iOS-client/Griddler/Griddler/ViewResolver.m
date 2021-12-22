//
//  DefaultViewResolver.m
//
//  Represents an concrete implementation of the ViewResolver.h, which is used by
//  the framework's ResponderNavigationController instance to link up FrameworkIUViewController's
//  and xibs.
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

#import "ViewResolver.h"
#import "FrameworkUIViewController.h"
#import "ViewTypes.m"
#import "GTMOAuth2ViewControllerTouch.h"

@interface ViewResolver()

@end

@implementation ViewResolver

-(FrameworkUIViewController*) resolve:(NSString*)name type:(viewTypes)type{
    
    id viewController = nil;
    
    switch(type)
    {
        case SPLASH:
            viewController = [self manufactureViewController:@"Splash"];
            break;
        case LANDING:
            viewController = [self manufactureViewController:@"Landing"];
            break;
        case SUMMARY:
            viewController = [self manufactureViewController:@"Summary"];
            break;
        case OPPONENT_LIST:
            viewController = [self manufactureViewController:@"OpponentList"];
            break;
        case LOBBY:
            viewController = [self manufactureViewController:@"Lobby"];
            break;
        case GAME_BOARD:
            viewController = [self manufactureViewController:@"GameBoard"];
            break;
        case SETTINGS:
            viewController = [self manufactureViewController:@"Settings"];
            break;
        default:
            break;
    }
    
    return viewController;
}

// Used to manufacture type/resource names based on a common view name.
// Customize this to the strategy of resource naming conventions.
// Note: this also is responsible for nib selection based on device type
- (UIViewController*) manufactureViewController:(NSString *) viewName
{
    NSString *controllerName = [NSString stringWithFormat:@"Griddler%@ViewController", viewName];
    NSString *viewNibName = [NSString stringWithFormat:@"Griddler%@View_iPhone", viewName];
    return [[NSClassFromString(controllerName) alloc] initWithNibName:viewNibName bundle:nil];
}

@end
