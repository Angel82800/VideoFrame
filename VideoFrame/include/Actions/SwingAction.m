//
//  SwingAction.m
//  VideoFrame
//
//  Created by Yinjing Li on 2/10/14.
//  Copyright (c) 2014 Yinjing Li. All rights reserved.
//

#import "SwingAction.h"

@implementation SwingAction

- (id)init
{
    self = [super init];
    
    if (self)
    {
        
    }
    
    return self;
}

- (CAAnimationGroup*) startSwingAction:(CFTimeInterval)startPosition duration:(CFTimeInterval)duration orientation:(ADTransitionOrientation)orientation sourceRect:(CGRect)sourceRect
{
    CGFloat viewWidth = sourceRect.size.width;
    CGFloat viewHeight = sourceRect.size.height;
    
    CABasicAnimation * cubeRotation = [CABasicAnimation animationWithKeyPath:@"transform"];
    
    CATransform3D rotation = CATransform3DIdentity;
    
    if (orientation == ADTransitionRightToLeft)
    {
        rotation = CATransform3DTranslate(rotation, viewWidth * 0.5f, 0.0f, 0.0f);
        rotation = CATransform3DRotate(rotation, M_PI * 0.5f, 0.0f, 1.0f, 0.0f);
        rotation.m34 = 1.0 / 1000;
    }
    else if (orientation == ADTransitionLeftToRight)
    {
        rotation = CATransform3DTranslate(rotation, - viewWidth * 0.5f, 0.0f, 0.0f);
        rotation = CATransform3DRotate(rotation, -M_PI * 0.5f, 0.0f, 1.0f, 0.0f);
        rotation.m34 = 1.0 / 1000;
    }
    else if (orientation == ADTransitionTopToBottom)
    {
        rotation = CATransform3DTranslate(rotation, 0.0f, viewHeight * 0.5f, 0.0f);
        rotation = CATransform3DRotate(rotation, - M_PI * 0.5f, 1.0f, 0.0f, 0.0f);
        rotation.m34 = 1.0 / 1000;
    }
    else if (orientation == ADTransitionBottomToTop)
    {
        rotation = CATransform3DTranslate(rotation, 0.0f, - viewHeight * 0.5f, 0.0f);
        rotation = CATransform3DRotate(rotation, M_PI * 0.5f, 1.0f, 0.0f, 0.0f);
        rotation.m34 = 1.0 / 1000;
    }
    else
    {
        NSAssert(FALSE, @"Unhandled ADTransitionOrientation!");
    }
    
    cubeRotation.fromValue = [NSValue valueWithCATransform3D:rotation];
    cubeRotation.toValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];

    CAKeyframeAnimation * zTranslationAnimation = [CAKeyframeAnimation animationWithKeyPath:@"zPosition"];
    zTranslationAnimation.values = @[@1000.0f, @1000.0f];
    zTranslationAnimation.timingFunctions = [self getCircleApproximationTimingFunctions];

    CAAnimationGroup* animation = [CAAnimationGroup animation];
    [(CAAnimationGroup *)animation setAnimations:@[cubeRotation, zTranslationAnimation]];
    animation.beginTime = startPosition;
    animation.duration = duration;
    
    return animation;
}

- (CAAnimationGroup*) endSwingAction:(CFTimeInterval)endPosition duration:(CFTimeInterval)duration orientation:(ADTransitionOrientation)orientation  sourceRect:(CGRect)sourceRect fromTransform:(CATransform3D) fromTransform fromZoomValue:(CGFloat) fromZoomValue
{
    CGFloat viewWidth = sourceRect.size.width;
    CGFloat viewHeight = sourceRect.size.height;
    
    CABasicAnimation * cubeRotation = [CABasicAnimation animationWithKeyPath:@"transform"];
    CATransform3D outLayerTransform = CATransform3DIdentity;

    if (orientation == ADTransitionRightToLeft)
    {
        outLayerTransform = CATransform3DTranslate(outLayerTransform, - viewWidth * 0.5f, 0.0f, 0.0f);
        outLayerTransform = CATransform3DRotate(outLayerTransform, -M_PI * 0.5f, 0.0f, 1.0f, 0.0f);
        outLayerTransform.m34 = 1.0 / 1000;
    }
    else if (orientation == ADTransitionLeftToRight)
    {
        outLayerTransform = CATransform3DTranslate(outLayerTransform, viewWidth * 0.5f, 0.0f, 0.0f);
        outLayerTransform = CATransform3DRotate(outLayerTransform, M_PI * 0.5f, 0.0f, 1.0f, 0.0f);
        outLayerTransform.m34 = 1.0 / 1000;
    }
    else if (orientation == ADTransitionTopToBottom)
    {
        outLayerTransform = CATransform3DTranslate(outLayerTransform, 0.0f, -viewHeight * 0.5f, 0.0f);
        outLayerTransform = CATransform3DRotate(outLayerTransform, M_PI * 0.5f, 1.0f, 0.0f, 0.0f);
        outLayerTransform.m34 = 1.0 / 1000;
    }
    else if (orientation == ADTransitionBottomToTop)
    {
        outLayerTransform = CATransform3DTranslate(outLayerTransform, 0.0f, viewHeight * 0.5f, 0.0f);
        outLayerTransform = CATransform3DRotate(outLayerTransform, - M_PI * 0.5f, 1.0f, 0.0f, 0.0f);
        outLayerTransform.m34 = 1.0 / 1000;
    }
    else
    {
        NSAssert(FALSE, @"Unhandled ADTransitionOrientation!");
    }
    
    cubeRotation.fromValue = [NSValue valueWithCATransform3D:fromTransform];
    cubeRotation.toValue = [NSValue valueWithCATransform3D:outLayerTransform];
    
    CAKeyframeAnimation * zTranslationAnimation = [CAKeyframeAnimation animationWithKeyPath:@"zPosition"];
    zTranslationAnimation.values = @[@1000.0f, @1000.0f];
    zTranslationAnimation.timingFunctions = [self getCircleApproximationTimingFunctions];
    
    CAKeyframeAnimation *scaleAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.values = @[[NSNumber numberWithFloat:fromZoomValue]];

    CAAnimationGroup* animation = [CAAnimationGroup animation];
    [(CAAnimationGroup *)animation setAnimations:@[cubeRotation, zTranslationAnimation, scaleAnimation]];
    animation.beginTime = endPosition;
    animation.duration = duration;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;

    return animation;
}

- (NSArray *)getCircleApproximationTimingFunctions
{
    const double kappa = 4.0/3.0 * (sqrt(2.0)-1.0) / sqrt(2.0);

    CAMediaTimingFunction *firstQuarterCircleApproximationFuction = [CAMediaTimingFunction functionWithControlPoints:kappa /(M_PI/2.0f) :kappa :1.0-kappa :1.0];
    CAMediaTimingFunction * secondQuarterCircleApproximationFuction = [CAMediaTimingFunction functionWithControlPoints:kappa :0.0 :1.0-(kappa /(M_PI/2.0f)) :1.0-kappa];
    
    return @[firstQuarterCircleApproximationFuction, secondQuarterCircleApproximationFuction];
}


@end