//
//  UIColor+YJL.m
//  VideoFrame
//
//  Created by Yinjing Li on 1/14/14.
//  Copyright (c) 2014 Yinjing Li. All rights reserved.
//

#import "UIColor+YJL.h"

@implementation UIColor(UIColor_YJL)

+ (UIColor*) gradientFromColor:(int) height colorIndex:(NSInteger) colorIndex
{
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    //// Color Declarations
    UIColor* color5;
    UIColor* gradientColor2;
    UIColor* color6;
    CGGradientRef gradient3;
    
    if (colorIndex == 1){
        color5 = [UIColor colorWithRed: 0.692 green: 0.602 blue: 0.004 alpha: 0.7f];
        gradientColor2 = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 0.7f];
        
        NSArray* gradient3Colors = [NSArray arrayWithObjects:
                                    (id)gradientColor2.CGColor,
                                    (id)[UIColor colorWithRed: 0.996 green: 0.951 blue: 0.502 alpha: 0.7f].CGColor,
                                    (id)color5.CGColor, nil];
        CGFloat gradient3Locations[] = {0, 0, 0.49};
        
        gradient3 = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)gradient3Colors, gradient3Locations);
    }
    else if (colorIndex == 2) {
        color5 = [UIColor colorWithRed: 0.535 green: 0.329 blue: 0.707 alpha: 0.7f];
        gradientColor2 = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 0.7f];
        
        NSArray* gradient3Colors = [NSArray arrayWithObjects:
                                    (id)gradientColor2.CGColor,
                                    (id)[UIColor colorWithRed: 0.768 green: 0.665 blue: 0.853 alpha: 0.7f].CGColor,
                                    (id)color5.CGColor, nil];
        CGFloat gradient3Locations[] = {0, 0, 1};
        gradient3 = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)gradient3Colors, gradient3Locations);
    }
    else if (colorIndex == 3){
        color5 = [UIColor colorWithRed: 0.449 green: 0.758 blue: 0.489 alpha: 0.7f];
        gradientColor2 = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 0.7f];
        
        //// Gradient Declarations
        NSArray* gradientPurpleColors = [NSArray arrayWithObjects:
                                         (id)gradientColor2.CGColor,
                                         (id)[UIColor colorWithRed: 0.725 green: 0.879 blue: 0.745 alpha: 0.7f].CGColor,
                                         (id)color5.CGColor, nil];
        CGFloat gradientPurpleLocations[] = {0, 0, 1};
        gradient3 = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)gradientPurpleColors, gradientPurpleLocations);
        
    }
    else if (colorIndex == 4){
        color5 = [UIColor colorWithRed: 0.9 green: 0.9 blue: 0.9 alpha: 0.7f];
        gradientColor2 = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 0.7f];
        color6 = [UIColor colorWithRed: 0.8 green: 0.8 blue: 0.8 alpha: 0.7f];
        
        //// Gradient Declarations
        NSArray* bubbleGradientColors = [NSArray arrayWithObjects:
                                         (id)color5.CGColor,
                                         (id)gradientColor2.CGColor,
                                         (id)color6.CGColor, nil];
        CGFloat bubbleGradientLocations[] = {0, 0.5, 1};
        gradient3 = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)bubbleGradientColors, bubbleGradientLocations);
    }
    else{
        color5 = [UIColor colorWithRed: 0.36 green: 0.38 blue: 0.39 alpha: 0.7f];
        gradientColor2 = [UIColor colorWithRed: 0.26 green: 0.28 blue: 0.29 alpha: 0.7f];
        color6 = [UIColor colorWithRed: 0.36 green: 0.38 blue: 0.39 alpha: 0.7f];

        //// Gradient Declarations
        NSArray* bubbleGradientColors = [NSArray arrayWithObjects:
                                         (id)color5.CGColor,
                                         (id)gradientColor2.CGColor,
                                         (id)color6.CGColor, nil];
        CGFloat bubbleGradientLocations[] = {0, 0.5, 1};
        gradient3 = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)bubbleGradientColors, bubbleGradientLocations);
    }
    
    
    CGSize size = CGSizeMake(1, height);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawLinearGradient(context, gradient3, CGPointMake(0, 0), CGPointMake(0, size.height), kCGGradientDrawsBeforeStartLocation);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    CGGradientRelease(gradient3);
    CGColorSpaceRelease(colorSpace);
    UIGraphicsEndImageContext();
    
    return [UIColor colorWithPatternImage:image];
}

@end
