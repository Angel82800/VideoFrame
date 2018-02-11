/*
 * YJLSliderLeft
 * created by Yinjing Li at 2014/01/12
 */

#import "YJLSliderLeft.h"

@implementation YJLSliderLeft

- (id)initWithFrame:(CGRect)frame type:(int)mediaType
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        type = mediaType;
    }
    
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    //// General Declarations
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //// Color Declarations
    UIColor* color5;
    UIColor* gradientColor2;
    UIColor* color6;
    CGGradientRef gradient3;
    
    if (type == MEDIA_VIDEO)
    {
        color5 = [UIColor colorWithRed: 0.535 green: 0.329 blue: 0.707 alpha: 0.7f];
        gradientColor2 = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 0.7f];
        color6 = [UIColor colorWithRed: 0.196 green: 0.161 blue: 0.047 alpha: 0.7f];
        
        NSArray* gradient3Colors = [NSArray arrayWithObjects:
                                         (id)gradientColor2.CGColor,
                                         (id)[UIColor colorWithRed: 0.768 green: 0.665 blue: 0.853 alpha: 0.7f].CGColor,
                                         (id)color5.CGColor, nil];
        CGFloat gradient3Locations[] = {0, 0, 1};
        gradient3 = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)gradient3Colors, gradient3Locations);
    }
    else if (type == MEDIA_MUSIC)
    {
        color5 = [UIColor colorWithRed: 0.449 green: 0.758 blue: 0.489 alpha: 0.7f];
        gradientColor2 = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 0.7f];
        color6 = [UIColor colorWithRed: 0.196 green: 0.161 blue: 0.047 alpha: 0.7f];
        
        //// Gradient Declarations
        NSArray* gradientPurpleColors = [NSArray arrayWithObjects:
                                         (id)gradientColor2.CGColor,
                                         (id)[UIColor colorWithRed: 0.725 green: 0.879 blue: 0.745 alpha: 0.7f].CGColor,
                                         (id)color5.CGColor, nil];
        CGFloat gradientPurpleLocations[] = {0, 0, 1};
        gradient3 = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)gradientPurpleColors, gradientPurpleLocations);

    }
    else if(type == MEDIA_PHOTO)
    {
        color5 = [UIColor colorWithRed: 0.692 green: 0.602 blue: 0.004 alpha: 0.7f];
        gradientColor2 = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 0.7f];
        color6 = [UIColor colorWithRed: 0.196 green: 0.161 blue: 0.047 alpha: 0.7f];

        NSArray* gradient3Colors = [NSArray arrayWithObjects:
                                    (id)gradientColor2.CGColor,
                                    (id)[UIColor colorWithRed: 0.996 green: 0.951 blue: 0.502 alpha: 0.7f].CGColor,
                                    (id)color5.CGColor, nil];
        CGFloat gradient3Locations[] = {0, 0, 0.49};

        gradient3 = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)gradient3Colors, gradient3Locations);
    }
    else if (type == MEDIA_TEXT)
    {
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
    else
    {
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
    
    //// Frames
    CGRect bubbleFrame = self.bounds;
    
    //// Rounded Rectangle Drawing
    CGRect roundedRectangleRect = CGRectMake(CGRectGetMinX(bubbleFrame), CGRectGetMinY(bubbleFrame), CGRectGetWidth(bubbleFrame), CGRectGetHeight(bubbleFrame));
    UIBezierPath* roundedRectanglePath = [UIBezierPath bezierPathWithRoundedRect: roundedRectangleRect byRoundingCorners: UIRectCornerTopLeft | UIRectCornerBottomLeft cornerRadii: CGSizeMake(5, 5)];
    [roundedRectanglePath closePath];
    CGContextSaveGState(context);
    [roundedRectanglePath addClip];
    CGContextDrawLinearGradient(context, gradient3,
                                CGPointMake(CGRectGetMidX(roundedRectangleRect), CGRectGetMinY(roundedRectangleRect)),
                                CGPointMake(CGRectGetMidX(roundedRectangleRect), CGRectGetMaxY(roundedRectangleRect)),
                                0);
    CGContextRestoreGState(context);
    [[UIColor clearColor] setStroke];
    roundedRectanglePath.lineWidth = 0.5;
    [roundedRectanglePath stroke];
    
    //// Bezier 3 Drawing
    UIBezierPath* bezier3Path = [UIBezierPath bezierPath];
    [bezier3Path moveToPoint: CGPointMake(CGRectGetMinX(bubbleFrame) + 0.42806 * CGRectGetWidth(bubbleFrame), CGRectGetMinY(bubbleFrame) + 0.22486 * CGRectGetHeight(bubbleFrame))];
    [bezier3Path addCurveToPoint: CGPointMake(CGRectGetMinX(bubbleFrame) + 0.42806 * CGRectGetWidth(bubbleFrame), CGRectGetMinY(bubbleFrame) + 0.74629 * CGRectGetHeight(bubbleFrame)) controlPoint1: CGPointMake(CGRectGetMinX(bubbleFrame) + 0.42806 * CGRectGetWidth(bubbleFrame), CGRectGetMinY(bubbleFrame) + 0.69415 * CGRectGetHeight(bubbleFrame)) controlPoint2: CGPointMake(CGRectGetMinX(bubbleFrame) + 0.42806 * CGRectGetWidth(bubbleFrame), CGRectGetMinY(bubbleFrame) + 0.69415 * CGRectGetHeight(bubbleFrame))];
    [bezier3Path addLineToPoint: CGPointMake(CGRectGetMinX(bubbleFrame) + 0.35577 * CGRectGetWidth(bubbleFrame), CGRectGetMinY(bubbleFrame) + 0.74629 * CGRectGetHeight(bubbleFrame))];
    [bezier3Path addCurveToPoint: CGPointMake(CGRectGetMinX(bubbleFrame) + 0.35577 * CGRectGetWidth(bubbleFrame), CGRectGetMinY(bubbleFrame) + 0.22486 * CGRectGetHeight(bubbleFrame)) controlPoint1: CGPointMake(CGRectGetMinX(bubbleFrame) + 0.35577 * CGRectGetWidth(bubbleFrame), CGRectGetMinY(bubbleFrame) + 0.69415 * CGRectGetHeight(bubbleFrame)) controlPoint2: CGPointMake(CGRectGetMinX(bubbleFrame) + 0.35577 * CGRectGetWidth(bubbleFrame), CGRectGetMinY(bubbleFrame) + 0.69415 * CGRectGetHeight(bubbleFrame))];
    [bezier3Path addLineToPoint: CGPointMake(CGRectGetMinX(bubbleFrame) + 0.42806 * CGRectGetWidth(bubbleFrame), CGRectGetMinY(bubbleFrame) + 0.22486 * CGRectGetHeight(bubbleFrame))];
    [bezier3Path closePath];
    bezier3Path.miterLimit = 19;
    
    [color6 setFill];
    [bezier3Path fill];
    
    //// Bezier Drawing
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint: CGPointMake(CGRectGetMinX(bubbleFrame) + 0.66944 * CGRectGetWidth(bubbleFrame), CGRectGetMinY(bubbleFrame) + 0.22486 * CGRectGetHeight(bubbleFrame))];
    [bezierPath addCurveToPoint: CGPointMake(CGRectGetMinX(bubbleFrame) + 0.66944 * CGRectGetWidth(bubbleFrame), CGRectGetMinY(bubbleFrame) + 0.74629 * CGRectGetHeight(bubbleFrame)) controlPoint1: CGPointMake(CGRectGetMinX(bubbleFrame) + 0.66944 * CGRectGetWidth(bubbleFrame), CGRectGetMinY(bubbleFrame) + 0.69415 * CGRectGetHeight(bubbleFrame)) controlPoint2: CGPointMake(CGRectGetMinX(bubbleFrame) + 0.66944 * CGRectGetWidth(bubbleFrame), CGRectGetMinY(bubbleFrame) + 0.69415 * CGRectGetHeight(bubbleFrame))];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(bubbleFrame) + 0.59715 * CGRectGetWidth(bubbleFrame), CGRectGetMinY(bubbleFrame) + 0.74629 * CGRectGetHeight(bubbleFrame))];
    [bezierPath addCurveToPoint: CGPointMake(CGRectGetMinX(bubbleFrame) + 0.59715 * CGRectGetWidth(bubbleFrame), CGRectGetMinY(bubbleFrame) + 0.22486 * CGRectGetHeight(bubbleFrame)) controlPoint1: CGPointMake(CGRectGetMinX(bubbleFrame) + 0.59715 * CGRectGetWidth(bubbleFrame), CGRectGetMinY(bubbleFrame) + 0.69415 * CGRectGetHeight(bubbleFrame)) controlPoint2: CGPointMake(CGRectGetMinX(bubbleFrame) + 0.59715 * CGRectGetWidth(bubbleFrame), CGRectGetMinY(bubbleFrame) + 0.69415 * CGRectGetHeight(bubbleFrame))];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(bubbleFrame) + 0.66944 * CGRectGetWidth(bubbleFrame), CGRectGetMinY(bubbleFrame) + 0.22486 * CGRectGetHeight(bubbleFrame))];
    [bezierPath closePath];
    bezierPath.miterLimit = 19;
    
    [color6 setFill];
    [bezierPath fill];
    
    //// Cleanup
    CGGradientRelease(gradient3);
    CGColorSpaceRelease(colorSpace);
}


@end
