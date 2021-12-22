//
//  GriddlerColor.m
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

#import "GriddlerColor.h"

@implementation GriddlerColor

+(UIColor *)pressColor{
    return [GriddlerColor red];
}

+(UIColor *)background {
    return [GriddlerColor lightAqua];
}

+(UIColor *)interactiveBackground {
    return [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"Interactive-Backgound.png"]];
}

+(UIColor *)defaultLabelColor {
    return [GriddlerColor navy];
}

+(UIColor *)gameboardBackground{
    return [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"Gameboard-Background.png"]];
}


+(UIColor *) lightAqua{
    return [UIColor colorWithRed:188/255.0 green:224/255.0 blue:235/255.0 alpha:1];
}// #bce0eb

+(UIColor *) aqua{
    return [UIColor colorWithRed:162/255.0 green:207/255.0 blue:219/255.0 alpha:1];
}// #a2cfdb

+(UIColor *) navy{
    return [UIColor colorWithRed:8/255.0 green:31/255.0 blue:51/255.0 alpha:1];
}// #081f33

+(UIColor *) red{
    return [UIColor colorWithRed:214/255.0 green:34/255.0 blue:35/255.0 alpha:1];
}//#d622237

+(UIColor *) white{
    return [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1];
}// #ffffff

@end
