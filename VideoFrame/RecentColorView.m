//
//  RecentColorView.m
//  VideoFrame
//
//  Created by Yinjing Li on 6/20/14.
//  Copyright (c) 2014 Yinjing Li. All rights reserved.
//

#import "RecentColorView.h"


@implementation RecentColorView


-(id) initWithFrame:(CGRect)frame index:(NSInteger) tagColor string:(NSString*) strColor
{
    self = [super initWithFrame:frame];

    if (self)
    {
        self.userInteractionEnabled = YES;
        self.tag = tagColor;
        colorIndex = tagColor;
        
        self.backgroundColor = [UIColor colorWithHexString:strColor];
        
        UITapGestureRecognizer *selectGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSelected:)];
        selectGesture.delegate = self;
        [self addGestureRecognizer:selectGesture];
        [selectGesture setNumberOfTapsRequired:1];
        
        self.deleteBtn = [[ColorDeleteButton alloc] init];
        self.deleteBtn.center = CGPointMake(self.bounds.size.width/2.0f, self.bounds.size.height/2.0f);
        [self.deleteBtn addTarget:self action:@selector(onDelete:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.deleteBtn];
        self.deleteBtn.hidden = YES;
        
        UILongPressGestureRecognizer *pressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longGesture:)];
        pressGesture.delegate = self;
        [self addGestureRecognizer:pressGesture];
    }
    
    return self;
}

-(void)onSelected:(UITapGestureRecognizer*) recognize
{
    if ([self.delegate respondsToSelector:@selector(selectColor:)])
    {
        [self.delegate selectColor:colorIndex];
    }
}

-(void)onDelete:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(deleteColor:)])
    {
        [self.delegate deleteColor:colorIndex];
    }
}

-(void)longGesture:(UILongPressGestureRecognizer*) gesture
{
    if ((gesture.state == UIGestureRecognizerStateBegan) && [self.delegate respondsToSelector:@selector(deleteColorEnabled)])
    {
        [self.delegate deleteColorEnabled];
    }
}


@end


@implementation ColorDeleteButton

- (id)init
{
    CGFloat deleteBtnSize = 16.0f;
    
    if(!(self = [super initWithFrame:(CGRect){0, 0, deleteBtnSize, deleteBtnSize}]))
    {
        return nil;
    }
    
    UIImage *closeButtonImage = [self closeButtonImage];
    
    [self setBackgroundImage:closeButtonImage forState:UIControlStateNormal];
    
    self.accessibilityTraits |= UIAccessibilityTraitButton;
    self.accessibilityLabel = NSLocalizedString(@"Dismiss Alert", @"Dismiss Alert Close Button");
    self.accessibilityHint = NSLocalizedString(@"Dismisses this alert.",@"Dismiss Alert close button hint");
    return self;
}

- (UIImage *)closeButtonImage
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(16.0f, 16.0f), NO, 0);
    
    //// General Declarations
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //// Color Declarations
    UIColor *topGradient = [UIColor colorWithRed:0.21 green:0.21 blue:0.21 alpha:0.9];
    UIColor *bottomGradient = [UIColor colorWithRed:0.03 green:0.03 blue:0.03 alpha:0.9];
    
    //// Gradient Declarations
    NSArray *gradientColors = @[(id)topGradient.CGColor,
                                (id)bottomGradient.CGColor];
    CGFloat gradientLocations[] = {0, 1};
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)gradientColors, gradientLocations);
    
    //// Shadow Declarations
    CGColorRef shadow = [UIColor blackColor].CGColor;
    CGSize shadowOffset = CGSizeMake(0, 1);
    CGFloat shadowBlurRadius = 2;
    CGColorRef shadow2 = [UIColor blackColor].CGColor;
    CGSize shadow2Offset = CGSizeMake(0, 1);
    CGFloat shadow2BlurRadius = 0;
    
    
    //// Oval Drawing
    UIBezierPath *ovalPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(2, 1.5, 12, 12)];
    CGContextSaveGState(context);
    [ovalPath addClip];
    CGContextDrawLinearGradient(context, gradient, CGPointMake(8, 1.5), CGPointMake(8, 13.5), 0);
    CGContextRestoreGState(context);
    
    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, shadowOffset, shadowBlurRadius, shadow);
    [[UIColor whiteColor] setStroke];
    ovalPath.lineWidth = 1;
    [ovalPath stroke];
    CGContextRestoreGState(context);
    
    
    //// Bezier Drawing
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint:CGPointMake(11.18, 5.73)];
    [bezierPath addLineToPoint:CGPointMake(9.41, 7.5)];
    [bezierPath addLineToPoint:CGPointMake(11.18, 9.27)];
    [bezierPath addLineToPoint:CGPointMake(9.77, 10.68)];
    [bezierPath addLineToPoint:CGPointMake(8, 8.96)];
    [bezierPath addLineToPoint:CGPointMake(6.23, 10.68)];
    [bezierPath addLineToPoint:CGPointMake(4.82, 9.27)];
    [bezierPath addLineToPoint:CGPointMake(6.58, 7.5)];
    [bezierPath addLineToPoint:CGPointMake(4.82, 5.73)];
    [bezierPath addLineToPoint:CGPointMake(6.23, 4.32)];
    [bezierPath addLineToPoint:CGPointMake(8, 6.08)];
    [bezierPath addLineToPoint:CGPointMake(9.77, 4.32)];
    [bezierPath addLineToPoint:CGPointMake(11.18, 5.73)];
    [bezierPath closePath];
    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, shadow2Offset, shadow2BlurRadius, shadow2);
    [[UIColor whiteColor] setFill];
    [bezierPath fill];
    CGContextRestoreGState(context);
    
    
    //// Cleanup
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end

