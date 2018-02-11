//
//  MarkerView.m
//  VideoFrame
//
//  Created by YinjingLi on 1/16/16.
//  Copyright © 2016 Yinjing Li. All rights reserved.
//

#import "MarkerView.h"

@implementation MarkerView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        
    }
    return self;
}


- (void)drawRect:(CGRect)rect
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    UIColor* bubbleGradientTop = [UIColor colorWithRed: 1 green: 0.939 blue: 0.743 alpha: 1];
    UIColor* bubbleGradientBottom = [UIColor colorWithRed: 1 green: 0.817 blue: 0.053 alpha: 1];
    
    NSArray* bubbleGradientColors = [NSArray arrayWithObjects:
                                     (id)bubbleGradientTop.CGColor,
                                     (id)bubbleGradientBottom.CGColor, nil];
    CGFloat bubbleGradientLocations[] = {0, 1};
    CGGradientRef bubbleGradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)bubbleGradientColors, bubbleGradientLocations);
    
    CGRect bubbleFrame = self.bounds;
    
    CGFloat distance = bubbleFrame.size.height;
    
    if (bubbleFrame.size.width < distance*8.0f/3.0f)
        distance = bubbleFrame.size.width * 3.0f / 8.0f;
    
    UIBezierPath* bubblePath = [UIBezierPath bezierPath];
    [bubblePath moveToPoint: CGPointMake(bubbleFrame.size.width/2.0f, 0.0f)];
    
    [bubblePath addCurveToPoint:CGPointMake(bubbleFrame.size.width/2.0f - distance/3.0f, bubbleFrame.size.height/3.0f) controlPoint1:CGPointMake(bubbleFrame.size.width/2.0f, bubbleFrame.size.height/3.0f) controlPoint2:CGPointMake(bubbleFrame.size.width/2.0f - distance/3.0f, bubbleFrame.size.height/3.0f)];

    [bubblePath addLineToPoint: CGPointMake(distance/3.0f, bubbleFrame.size.height/3.0f)];
    
    [bubblePath addCurveToPoint:CGPointMake(0.0f, bubbleFrame.size.height) controlPoint1:CGPointMake(distance/3.0f, bubbleFrame.size.height/3.0f) controlPoint2:CGPointMake(0.0f, bubbleFrame.size.height/3.0f)];
    
    [bubblePath addCurveToPoint:CGPointMake(distance/3.0f, bubbleFrame.size.height*2.0f/3.0f) controlPoint1:CGPointMake(0.0f, bubbleFrame.size.height*2.0f/3.0f) controlPoint2:CGPointMake(distance/3.0f, bubbleFrame.size.height*2.0f/3.0f)];
    
    [bubblePath addLineToPoint: CGPointMake(bubbleFrame.size.width/2.0f - distance*2.0f/3.0f, bubbleFrame.size.height*2.0f/3.0f)];

    [bubblePath addCurveToPoint:CGPointMake(bubbleFrame.size.width/2.0f, bubbleFrame.size.height/3.0f) controlPoint1:CGPointMake(bubbleFrame.size.width/2.0f - distance*2.0f/3.0f, bubbleFrame.size.height*2.0f/3.0f) controlPoint2:CGPointMake(bubbleFrame.size.width/2.0f, bubbleFrame.size.height*2.0f/3.0f)];

    [bubblePath addCurveToPoint:CGPointMake(bubbleFrame.size.width/2.0f + distance*2.0f/3.0f, bubbleFrame.size.height*2.0f/3.0f) controlPoint1:CGPointMake(bubbleFrame.size.width/2.0f, bubbleFrame.size.height*2.0f/3.0f) controlPoint2:CGPointMake(bubbleFrame.size.width/2.0f + distance*2.0f/3.0f, bubbleFrame.size.height*2.0f/3.0f)];

    [bubblePath addLineToPoint: CGPointMake(bubbleFrame.size.width - distance/3.0f, bubbleFrame.size.height*2.0f/3.0f)];
    
    [bubblePath addCurveToPoint:CGPointMake(bubbleFrame.size.width, bubbleFrame.size.height) controlPoint1:CGPointMake(bubbleFrame.size.width - distance/3.0f, bubbleFrame.size.height*2.0f/3.0f) controlPoint2:CGPointMake(bubbleFrame.size.width, bubbleFrame.size.height*2.0f/3.0f)];

    [bubblePath addCurveToPoint:CGPointMake(bubbleFrame.size.width - distance/3.0f, bubbleFrame.size.height/3.0f) controlPoint1:CGPointMake(bubbleFrame.size.width, bubbleFrame.size.height/3.0f) controlPoint2:CGPointMake(bubbleFrame.size.width - distance/3.0f, bubbleFrame.size.height/3.0f)];

    [bubblePath addLineToPoint: CGPointMake(bubbleFrame.size.width/2.0f + distance/3.0f, bubbleFrame.size.height/3.0f)];
    
    [bubblePath addCurveToPoint:CGPointMake(bubbleFrame.size.width/2.0f, 0.0f) controlPoint1:CGPointMake(bubbleFrame.size.width/2.0f + distance/3.0f, bubbleFrame.size.height/3.0f) controlPoint2:CGPointMake(bubbleFrame.size.width/2.0f, bubbleFrame.size.height/3.0f)];

    [bubblePath closePath];
    
    CGContextSaveGState(context);
    
    CGContextBeginTransparencyLayer(context, NULL);
    
    [bubblePath addClip];
    
    CGRect bubbleBounds = CGPathGetPathBoundingBox(bubblePath.CGPath);
    
    CGContextDrawLinearGradient(context, bubbleGradient,
                                CGPointMake(CGRectGetMidX(bubbleBounds), CGRectGetMinY(bubbleBounds)),
                                CGPointMake(CGRectGetMidX(bubbleBounds), CGRectGetMaxY(bubbleBounds)),
                                0);
    
    CGContextEndTransparencyLayer(context);
    
    CGGradientRelease(bubbleGradient);
    CGColorSpaceRelease(colorSpace);
}


@end
