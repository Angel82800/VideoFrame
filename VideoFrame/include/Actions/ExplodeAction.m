
#import <QuartzCore/QuartzCore.h>
#import "ExplodeAction.h"


@implementation ExplodeAction


- (id)init
{
    self = [super init];
    
    if (self)
    {
        // Initialize self.
        
    }
    
    return self;
}

#pragma mark -
#pragma mark - Start Explode Action

- (NSMutableArray*) startExplodeAction:(UIImage*)image startPosition:(CFTimeInterval)startPosition duration:(CFTimeInterval)duration sourceRect:(CGRect)sourceRect
{
    NSMutableArray* layers = [self explodeTransitionWithDuration:image
                                                        position:startPosition
                                                      duration:duration
                                                          rect:sourceRect
                                                       start:YES];

    return layers;
}


#pragma mark -
#pragma mark - End Explode Action

- (NSMutableArray*) endExplodeAction:(UIImage*)image endPosition:(CFTimeInterval)endPosition duration:(CFTimeInterval)duration sourceRect:(CGRect)sourceRect
{
    NSMutableArray* layers = [self explodeTransitionWithDuration:image
                                                        position:endPosition
                                                      duration:duration
                                                          rect:sourceRect
                                                       start:NO];
    return layers;
}


#pragma mark -

- (NSMutableArray*) explodeTransitionWithDuration:(UIImage*) image position:(CFTimeInterval)position duration:(CFTimeInterval) duration rect:(CGRect)sourceRect start:(BOOL)isStart
{
    NSMutableArray *slices = [self sliceImage:image];
    
    CGFloat xFactor = 10.0f;
    CGFloat yFactor = xFactor * image.size.height / image.size.width;
    
    int nCount = 0;
    
    for (CGFloat x=0; x < image.size.width; x+= image.size.width / xFactor)
    {
        for (CGFloat y=0; y < image.size.height; y+= image.size.height / yFactor)
        {
            CALayer* layer = [slices objectAtIndex:nCount];
            
            CGFloat xOffset = [self randomFloatBetween:-100.0 and:100.0];
            CGFloat yOffset = [self randomFloatBetween:-100.0 and:100.0];
            
            //move, rotate
            CAKeyframeAnimation * outPosition = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
            
            if (isStart)
            {
                outPosition.values = @[[NSValue valueWithCATransform3D:CATransform3DRotate(CATransform3DMakeTranslation(xOffset,  yOffset, 0.0f), [self randomFloatBetween:-10.0 and:10.0], 0.0f, 0.0f, 1.0f)], [NSValue valueWithCATransform3D:CATransform3DIdentity]];
            }
            else
            {
                outPosition.values = @[[NSValue valueWithCATransform3D:CATransform3DIdentity], [NSValue valueWithCATransform3D:CATransform3DRotate(CATransform3DMakeTranslation(xOffset, yOffset, 0.0f), [self randomFloatBetween:-10.0 and:10.0], 0.0f, 0.0f, 1.0f)]];
            }

            outPosition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
           
            
            //scale
            CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
            
            if (isStart)
            {
                scaleAnimation.fromValue = [NSNumber numberWithFloat:0.001f];
                scaleAnimation.toValue = [NSNumber numberWithFloat:1.0f];
            }
            else
            {
                scaleAnimation.fromValue = [NSNumber numberWithFloat:1.0f];
                scaleAnimation.toValue = [NSNumber numberWithFloat:0.0f];
            }
            
            
            CAAnimationGroup * inAnimation = [CAAnimationGroup animation];
            [inAnimation setAnimations:@[outPosition, scaleAnimation]];
            inAnimation.beginTime = position;
            inAnimation.duration = duration;
            inAnimation.removedOnCompletion = NO;
            inAnimation.fillMode = kCAFillModeForwards;
            
            [layer addAnimation:inAnimation forKey:nil];
            
            nCount++;
        }
    }
    
    return slices;
}


- (float)randomFloatBetween:(float)smallNumber and:(float)bigNumber
{
    float diff = bigNumber - smallNumber;
    return (((float) (arc4random() % ((unsigned)RAND_MAX + 1)) / RAND_MAX) * diff) + smallNumber;
}


- (NSMutableArray *) sliceImage: (UIImage *) image
{
    NSMutableArray *slices = [[NSMutableArray alloc] init];
    
    CGFloat xFactor = 10.0f;
    CGFloat yFactor = xFactor * image.size.height / image.size.width;
    
    for (CGFloat x=0; x < image.size.width; x+= image.size.width / xFactor)
    {
        for (CGFloat y=0; y < image.size.height; y+= image.size.height / yFactor)
        {
            @autoreleasepool
            {
                CGRect snapshotRegion = CGRectMake(x, image.size.height - image.size.height / yFactor - y, image.size.width / xFactor, image.size.height / yFactor);
                
                CGImageRef imageRef = CGImageCreateWithImageInRect(image.CGImage, snapshotRegion);
                
                UIImage *sliceImage = [UIImage imageWithCGImage:imageRef
                                                          scale:image.scale
                                                    orientation:image.imageOrientation];
                CGImageRelease(imageRef);
                
                CALayer *layer = [CALayer layer];
                layer.anchorPoint = CGPointZero;
                layer.frame = CGRectMake(x, y, sliceImage.size.width, sliceImage.size.height);
                layer.contents = (__bridge id)(sliceImage.CGImage);
                [slices addObject:layer];
            }
        }
    }
    
    return slices;
}



@end
