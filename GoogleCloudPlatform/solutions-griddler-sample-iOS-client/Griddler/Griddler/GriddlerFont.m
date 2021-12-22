//
//  GriddlerFont.m
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

#import "GriddlerFont.h"

@implementation GriddlerFont

+ (UIFont *) defaultLabelFont{
    return [GriddlerFont robotoRegularAtSize:17.0];
}

+ (UIFont *) defaultButtonFont{
    return [GriddlerFont robotoRegularAtSize:13.0];
}

+ (UIFont *) defaultSubheadingFont{
    return [GriddlerFont robotoLightAtSize:13.0];
}

+ (UIFont *) robotoRegularAtSize:(CGFloat)size{
    return [UIFont fontWithName:@"Roboto" size:size];
}

+ (UIFont *) robotoBoldAtSize:(CGFloat)size{
    return [UIFont fontWithName:@"Roboto-Bold" size:size];
}

+ (UIFont *) robotoLightAtSize:(CGFloat)size{
    return [UIFont fontWithName:@"Roboto-Light" size:size];
}

+(UIFont* )navTitleFont{
    return [UIFont fontWithName:@"HelveticaNeue-Light" size:20.0];
}

+(UIFont* )gameboardLetter{
    return [GriddlerFont robotoBoldAtSize:32.0];
}

+(UIFont* )gameboardAnswerLetter{
    return [GriddlerFont robotoBoldAtSize:28.0];
}

+(UIFont* )gameboardQuestion{
    return [GriddlerFont robotoRegularAtSize:21.0];
}

+(UIFont* )gameboardHeader{
    return [GriddlerFont robotoLightAtSize:15.0];
}

+(UIFont* )gameboardSkip{
    return [GriddlerFont robotoBoldAtSize:27.0];
}

@end
