
#import "SASliderRight.h"

@implementation SASliderRight

- (id)initWithFrame:(CGRect)frame red:(CGFloat) redColor green:(CGFloat) greenColor blue:(CGFloat) blueColor
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        red = redColor;
        green = greenColor;
        blue = blueColor;
    }
    
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    UIColor* gradientColor2 = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f];
    UIColor* color5 = [UIColor colorWithRed:red green:green blue:blue alpha:1.0f];
    
    NSArray* gradient3Colors = [NSArray arrayWithObjects:
                                (id)gradientColor2.CGColor,
                                (id)[UIColor colorWithRed:red green:green blue:blue alpha:1.0f].CGColor,
                                (id)color5.CGColor, nil];
    
    CGFloat gradient3Locations[] = {0.0f, 0.0f, 0.49f};
    CGGradientRef gradient3 = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)gradient3Colors, gradient3Locations);
    
    CGRect bubbleFrame = self.bounds;
    CGRect roundedRectangleRect = CGRectMake(CGRectGetWidth(bubbleFrame) - 3.0f, CGRectGetMinY(bubbleFrame), 3.0f, CGRectGetHeight(bubbleFrame));
    
    UIBezierPath* roundedRectanglePath = [UIBezierPath bezierPathWithRoundedRect: roundedRectangleRect byRoundingCorners: UIRectCornerTopRight | UIRectCornerBottomRight cornerRadii: CGSizeMake(5, 5)];
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
    
    CGGradientRelease(gradient3);
    CGColorSpaceRelease(colorSpace);
}


@end
