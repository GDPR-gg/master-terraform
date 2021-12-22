//
//  CountdownView.m
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
#import "CoundownView.h"

@interface CountdownView()
{
    CGContextRef *ctx;
}

#define DEGREES_TO_RADIANS(d) ((d) * 0.0174532925199432958f)
#define RADIANS_TO_DEGREES(r) ((r) * 57.29577951308232f)
@end

@implementation CountdownView


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
        [self setBackgroundColor:[UIColor clearColor]];
        self.contentMode = UIViewContentModeRedraw;
    }
    return self;
}


double _percent;
-(void)setRemainingTimePercent:(double)percent{
    if(percent > 0)
    {
        _percent = percent;
        [self setNeedsDisplay];
    }
}


- (void)drawRect:(CGRect)rect {
	CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGFloat kAngleOffset = -90.0f;
    
	// Background
    [[GriddlerColor white] set];
    CGContextFillEllipseInRect(context, rect);
    
	// Math
	CGPoint center = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
	CGFloat radius = center.y;
	CGFloat angle = DEGREES_TO_RADIANS((360.0f * _percent) + kAngleOffset);
	CGPoint points[3] = {
		CGPointMake(center.x, 0.0f),
		center,
		CGPointMake(center.x + radius * cosf(angle), center.y + radius * sinf(angle))
	};
    
	// Fill
    [[GriddlerColor red] set];
    if (_percent > 0.0f) {
        CGContextAddLines(context, points, sizeof(points) / sizeof(points[0]));
        CGContextAddArc(context, center.x, center.y, radius, DEGREES_TO_RADIANS(kAngleOffset), angle, false);
        CGContextDrawPath(context, kCGPathEOFill);
    }
    
    // inner sphere
    [[GriddlerColor aqua] set];
    CGRect innerCircle = CGRectMake(rect.origin.x + rect.size.width/5, rect.origin.y + rect.size.height /5,
                                    3 * rect.size.width/5, 3 * rect.size.height/5);
    CGContextFillEllipseInRect(context, innerCircle);
}

@end
