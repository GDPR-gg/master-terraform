//
//  cardCellView.m
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

#import "cardCellView.h"
#import <QuartzCore/QuartzCore.h>
#import <AudioToolbox/AudioServices.h>
#import <AudioToolbox/AudioToolbox.h>

@interface cardCellView()


@property (nonatomic, strong, readwrite) UILabel *letterView;
@property (nonatomic, readwrite) bool isSelected;
@property (nonatomic, strong, readwrite) NSString *letter;

@end

@implementation cardCellView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.isSelected = false;
        
        self.letterView = [[UILabel alloc] initWithFrame:self.bounds];
        [self.letterView.layer setCornerRadius:7.0f];
        self.letterView.backgroundColor = [GriddlerColor white];
        self.letterView.textColor = [GriddlerColor navy];
        self.letterView.contentMode = UIViewContentModeScaleAspectFill;
        self.letterView.clipsToBounds = YES;
        self.letterView.font = [GriddlerFont gameboardLetter];
        [self.letterView setTextAlignment:NSTextAlignmentCenter];
        
        
        [self.contentView addSubview:self.letterView];
    }
    return self;
}

-(void)setLetterValue:(NSString*)letterValue{
    self.letter = letterValue;
    self.letterView.text = letterValue;
}


#pragma mark -
#pragma mark === Touch handling  ===
#pragma mark

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.boardCollectionViewController touchesBegan: touches withEvent: event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.boardCollectionViewController touchesMoved: touches withEvent: event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded: touches withEvent: event];
    
    [self.boardCollectionViewController touchesEnded: touches withEvent: event];
}

#define DEGREES_TO_RADIANS(d) ((d) * 0.0174532925199432958f)

-(void)selected{
    if(!self.isSelected)
    {
        self.isSelected = true;
        
        NSMutableDictionary* dict = [NSMutableDictionary dictionary];
        [dict setObject:[NSNumber numberWithDouble:0.25] forKey:@"Intensity"];
        NSMutableArray* arr = [NSMutableArray array ];
        [arr addObject:[NSNumber numberWithBool:YES]]; //vibrate for 2000ms
        [arr addObject:[NSNumber numberWithInt:60]];
        [dict setObject:arr forKey:@"VibePattern"];
        AudioServicesPlaySystemSoundWithVibration(kSystemSoundID_Vibrate,nil,dict);
        
        CATransform3D perspective = CATransform3DIdentity;
        perspective.m34 = 1.0/400;
        CATransform3D transform = CATransform3DRotate(perspective, DEGREES_TO_RADIANS(30), 0, 1, 0);
        self.layer.transform = transform;
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.y"];
        CGFloat startValue = 0.0;
        CGFloat endValue = DEGREES_TO_RADIANS(30);
        animation.fromValue = [NSNumber numberWithDouble:startValue];
        animation.toValue = [NSNumber numberWithDouble:endValue];
        animation.duration = 0.25;
        animation.removedOnCompletion = NO;
        animation.fillMode = kCAFillModeForwards;
        [self.layer addAnimation:animation forKey:@"flipForward"];
        
        [CATransaction begin]; {
            [CATransaction setCompletionBlock:^{
                self.letterView.backgroundColor = [GriddlerColor red];
                self.letterView.textColor = [GriddlerColor white];
            }];
        } [CATransaction commit];
    }
}

-(void)unselected{
    if(self.isSelected){
        // run animation to unselect
        self.isSelected = false;
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.y"];
        CGFloat startValue = DEGREES_TO_RADIANS(30);
        CGFloat endValue = 0.0;
        animation.fromValue = [NSNumber numberWithDouble:startValue];
        animation.toValue = [NSNumber numberWithDouble:endValue];
        animation.duration = 0.25;
        animation.removedOnCompletion = NO;
        animation.fillMode = kCAFillModeForwards;
        [self.layer addAnimation:animation forKey:@"flipBack"];
        
        [CATransaction begin]; {
            [CATransaction setCompletionBlock:^{
                self.letterView.backgroundColor = [GriddlerColor white];
                self.letterView.textColor = [GriddlerColor navy];
            }];
        } [CATransaction commit];
        
    }
}

-(void)questionAnswered{
    if(self.isSelected){
        // run animation to unselect
        self.isSelected = false;
        
        [NSTimer scheduledTimerWithTimeInterval:0.25
                                         target:self
                                       selector:@selector(delayedResetAnimation)
                                       userInfo:nil
                                        repeats:NO];
    }
}


-(void)questionSkipped{
    if(self.isSelected){
        // run animation to unselect
        self.isSelected = false;
        
        [NSTimer scheduledTimerWithTimeInterval:0.25
                                         target:self
                                       selector:@selector(delayedResetAnimation)
                                       userInfo:nil
                                        repeats:NO];
    }
}

-(void) delayedResetAnimation
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.y"];
    CGFloat startValue = M_PI * 2;
    CGFloat endValue = 0.0;
    animation.fromValue = [NSNumber numberWithDouble:startValue];
    animation.toValue = [NSNumber numberWithDouble:endValue];
    animation.duration = 0.5;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    [self.layer addAnimation:animation forKey:@"flipBack"];
    
    [CATransaction begin]; {
        [CATransaction setCompletionBlock:^{
            self.letterView.backgroundColor = [GriddlerColor white];
            self.letterView.textColor = [GriddlerColor navy];
        }];
    } [CATransaction commit];
}

@end
