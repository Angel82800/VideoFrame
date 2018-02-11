//
//  FlipAction.m
//  VideoFrame
//
//  Created by Yinjing Li on 2/9/14.
//  Copyright (c) 2014 Yinjing Li. All rights reserved.
//

#import "FlipAction.h"


@implementation FlipAction


- (id)init
{
    self = [super init];
    
    if (self)
    {
        // Initialize self.
        
    }
    
    return self;
}


- (NSArray *)getCircleApproximationTimingFunctions
{
    const double kappa = 4.0/3.0 * (sqrt(2.0)-1.0) / sqrt(2.0);

    CAMediaTimingFunction *firstQuarterCircleApproximationFuction = [CAMediaTimingFunction functionWithControlPoints:kappa /(M_PI/2.0f) :kappa :1.0-kappa :1.0];
    
    CAMediaTimingFunction * secondQuarterCircleApproximationFuction = [CAMediaTimingFunction functionWithControlPoints:kappa :0.0 :1.0-(kappa /(M_PI/2.0f)) :1.0-kappa];
    
    return @[firstQuarterCircleApproximationFuction, secondQuarterCircleApproximationFuction];
}

- (CAAnimationGroup*) startFlipAction:(CFTimeInterval)startPosition duration:(CFTimeInterval)duration orientation:(ADTransitionOrientation)orientation sourceRect:(CGRect)sourceRect
{
    CATransform3D inPivotTransform = CATransform3DIdentity;

    inPivotTransform.m34 = 1.0 / 1000;

    switch (orientation)
    {
        case ADTransitionRightToLeft:
        {
            inPivotTransform = CATransform3DRotate(inPivotTransform, M_PI - 0.001, 0.0f, 1.0f, 0.0f);
        }
            break;
        case ADTransitionLeftToRight:
        {
            inPivotTransform = CATransform3DRotate(inPivotTransform, M_PI + 0.001, 0.0f, 1.0f, 0.0f);
        }
            break;
        case ADTransitionBottomToTop:
        {
            inPivotTransform = CATransform3DRotate(inPivotTransform, M_PI + 0.001, 1.0f, 0.0f, 0.0f);
        }
            break;
        case ADTransitionTopToBottom:
        {
            inPivotTransform = CATransform3DRotate(inPivotTransform, M_PI - 0.001, 1.0f, 0.0f, 0.0f);
        }
            break;
        default:
            NSAssert(FALSE, @"Unhandled ADFlipTransitionOrientation!");
            break;
    }
    
    CAKeyframeAnimation * inFlipAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    inFlipAnimation.values = @[[NSValue valueWithCATransform3D:inPivotTransform], [NSValue valueWithCATransform3D:CATransform3DIdentity]];
    inFlipAnimation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.fromValue = [NSNumber numberWithFloat:0.0];
    animation.toValue = [NSNumber numberWithFloat:1.0];
    
    CAKeyframeAnimation * zTranslationAnimation = [CAKeyframeAnimation animationWithKeyPath:@"zPosition"];
    zTranslationAnimation.values = @[@1000.0f, @1000.0f];
    zTranslationAnimation.timingFunctions = [self getCircleApproximationTimingFunctions];

    CAAnimationGroup * inAnimation = [CAAnimationGroup animation];
    [inAnimation setAnimations:@[inFlipAnimation, animation, zTranslationAnimation]];
    inAnimation.beginTime = startPosition;
    inAnimation.duration = duration;
    
    return inAnimation;
}

- (CAAnimationGroup*) endFlipAction:(CFTimeInterval)endPosition duration:(CFTimeInterval)duration orientation:(ADTransitionOrientation)orientation sourceRect:(CGRect)sourceRect fromTransform:(CATransform3D) fromTransform fromZoomValue:(CGFloat) fromZoomValue
{
    CATransform3D outPivotTransform = CATransform3DIdentity;
    
    switch (orientation)
    {
        case ADTransitionRightToLeft:
        {
            outPivotTransform.m34 = 1.0 / 1000;
            outPivotTransform = CATransform3DRotate(outPivotTransform, -M_PI + 0.001, 0.0f, 1.0f, 0.0f);
        }
            break;
        case ADTransitionLeftToRight:
        {
            outPivotTransform.m34 = 1.0 / 1000;
            outPivotTransform = CATransform3DRotate(outPivotTransform, - M_PI - 0.001, 0.0f, 1.0f, 0.0f);
        }
            break;
        case ADTransitionBottomToTop:
        {
            outPivotTransform.m34 = 1.0 / 1000;
            outPivotTransform = CATransform3DRotate(outPivotTransform, - M_PI - 0.001, 1.0f, 0.0f, 0.0f);
        }
            break;
        case ADTransitionTopToBottom:
        {
            outPivotTransform.m34 = 1.0 / 1000;
            outPivotTransform = CATransform3DRotate(outPivotTransform, - M_PI + 0.001, 1.0f, 0.0f, 0.0f);
        }
            break;
        default:
            NSAssert(FALSE, @"Unhandled ADFlipTransitionOrientation!");
            break;
    }
    
    CAKeyframeAnimation * outFlipAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    outFlipAnimation.values = @[[NSValue valueWithCATransform3D:fromTransform], [NSValue valueWithCATransform3D:outPivotTransform]];
    outFlipAnimation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];

    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.fromValue = [NSNumber numberWithFloat:1.0f];
    animation.toValue = [NSNumber numberWithFloat:0.0f];
    
    CAKeyframeAnimation * zTranslationAnimation = [CAKeyframeAnimation animationWithKeyPath:@"zPosition"];
    zTranslationAnimation.values = @[@1000.0f, @1000.0f];
    zTranslationAnimation.timingFunctions = [self getCircleApproximationTimingFunctions];
    
    CAKeyframeAnimation *scaleAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.values = @[[NSNumber numberWithFloat:fromZoomValue]];

    CAAnimationGroup * outAnimation = [CAAnimationGroup animation];
    [outAnimation setAnimations:@[outFlipAnimation, animation, zTranslationAnimation, scaleAnimation]];
    outAnimation.beginTime = endPosition;
    outAnimation.duration = duration;
    outAnimation.removedOnCompletion = NO;
    outAnimation.fillMode = kCAFillModeForwards;

    return outAnimation;
}

@end
