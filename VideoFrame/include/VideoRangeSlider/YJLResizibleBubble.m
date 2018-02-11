
#import "YJLResizibleBubble.h"

@implementation YJLResizibleBubble

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        // Initialization code
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
    
    UIBezierPath* bubblePath = [UIBezierPath bezierPath];
    [bubblePath moveToPoint:CGPointMake(0, bubbleFrame.size.height)];
    [bubblePath addLineToPoint: CGPointMake(0, 1)];
    [bubblePath addCurveToPoint:CGPointMake(1, 0) controlPoint1:CGPointMake(0, 1) controlPoint2:CGPointMake(1, 0)];
    [bubblePath addLineToPoint: CGPointMake(bubbleFrame.size.width - 1, 0)];
    [bubblePath addCurveToPoint:CGPointMake(bubbleFrame.size.width, 1) controlPoint1:CGPointMake(bubbleFrame.size.width - 1, 0) controlPoint2:CGPointMake(bubbleFrame.size.width, 1)];
    [bubblePath addLineToPoint: CGPointMake(bubbleFrame.size.width, bubbleFrame.size.height - 6)];
    [bubblePath addCurveToPoint:CGPointMake(bubbleFrame.size.width - 1, bubbleFrame.size.height - 5) controlPoint1:CGPointMake(bubbleFrame.size.width, bubbleFrame.size.height - 6) controlPoint2:CGPointMake(bubbleFrame.size.width - 1, bubbleFrame.size.height - 5)];
    [bubblePath addLineToPoint: CGPointMake(5, bubbleFrame.size.height - 5)];
    [bubblePath addLineToPoint: CGPointMake(0, bubbleFrame.size.height)];
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
