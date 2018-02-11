//
//  RotateAction.m
//  VideoFrame
//
//  Created by Yinjing Li on 2/9/14.
//  Copyright (c) 2014 Yinjing Li. All rights reserved.
//

#import "RotateAction.h"


@implementation RotateAction


- (id)init
{
    self = [super init];
    
    if (self)
    {
        
    }
    
    return self;
}


- (CAAnimationGroup*) startRotateAction:(CFTimeInterval)startPosition duration:(CFTimeInterval)duration sourceRect:(CGRect)sourceRect
{
    CATransform3D inPivotTransform = CATransform3DRotate(CATransform3DIdentity, M_PI - 0.001, 0.0f, 0.0f, 1.0f);

    CAKeyframeAnimation * inRotateAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    inRotateAnimation.values = @[[NSValue valueWithCATransform3D:inPivotTransform], [NSValue valueWithCATransform3D:CATransform3DIdentity]];
    inRotateAnimation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    inRotateAnimation.additive = NO;
    inRotateAnimation.fillMode = kCAFillModeBackwards;
    
//    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
//    animation.fromValue = [NSNumber numberWithFloat:0.0f];
//    animation.toValue = [NSNumber numberWithFloat:1.0f];
//    animation.additive = NO;
//    animation.fillMode = kCAFillModeBackwards;
    
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.fromValue = [NSNumber numberWithFloat:0.001f];
    scaleAnimation.toValue = [NSNumber numberWithFloat:1.0f];
    scaleAnimation.additive = NO;
    scaleAnimation.fillMode = kCAFillModeBackwards;

    CAAnimationGroup * inAnimation = [CAAnimationGroup animation];
    [inAnimation setAnimations:@[inRotateAnimation,/* animation,*/ scaleAnimation]];
    inAnimation.beginTime = startPosition;
    inAnimation.duration = duration;
    inAnimation.removedOnCompletion = NO;
    inAnimation.fillMode = kCAFillModeBackwards;

    return inAnimation;
}

- (CAAnimationGroup*) endRotateAction:(CFTimeInterval)endPosition duration:(CFTimeInterval)duration sourceRect:(CGRect)sourceRect fromTransform:(CATransform3D) fromTransform fromZoomValue:(CGFloat) fromZoomValue
{
    CATransform3D outPivotTransform = CATransform3DRotate(CATransform3DIdentity, -M_PI + 0.001, 0.0f, 0.0f, 1.0f);

    CAKeyframeAnimation * outFlipAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    outFlipAnimation.values = @[[NSValue valueWithCATransform3D:fromTransform], [NSValue valueWithCATransform3D:outPivotTransform]];
    outFlipAnimation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    outFlipAnimation.additive = NO;
    outFlipAnimation.fillMode = kCAFillModeForwards;

//    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
//    animation.fromValue = [NSNumber numberWithFloat:1.0];
//    animation.toValue = [NSNumber numberWithFloat:0.0];
//    animation.additive = NO;
//    animation.fillMode = kCAFillModeForwards;
    
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.fromValue = [NSNumber numberWithFloat:fromZoomValue];
    scaleAnimation.toValue = [NSNumber numberWithFloat:0.001f];
    scaleAnimation.additive = NO;
    scaleAnimation.fillMode = kCAFillModeBackwards;

    CAAnimationGroup * outAnimation = [CAAnimationGroup animation];
    [outAnimation setAnimations:@[outFlipAnimation,/* animation,*/ scaleAnimation]];
    outAnimation.beginTime = endPosition;
    outAnimation.duration = duration;
    outAnimation.removedOnCompletion = NO;
    outAnimation.fillMode = kCAFillModeForwards;

    return outAnimation;
}


@end
