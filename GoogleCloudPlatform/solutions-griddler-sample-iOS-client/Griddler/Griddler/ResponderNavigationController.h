//
//  ResponderNavigationController.h
//  Represents the interface for the RepsonderNavigationController
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
#import "ViewResolver.h"

/**
 * The purpose of this interface is to manage all navigation
 * notification requests of the application
 */
@interface ResponderNavigationController : UINavigationController

/// Represents the View Resolution strategy
@property(nonatomic, retain, readwrite) ViewResolver *viewResolver;

@end
