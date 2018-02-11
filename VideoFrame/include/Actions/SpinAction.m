//
//  SpinAction.m
//  VideoFrame
//
//  Created by Yinjing Li on 2/10/14.
//  Copyright (c) 2014 Yinjing Li. All rights reserved.
//

#import "SpinAction.h"

@implementation SpinAction

- (id)init
{
    self = [super init];
    
    if (self)
    {
        
    }
    
    return self;
}

- (CAAnimationGroup*) startSpinAction:(CFTimeInterval)startPosition duration:(CFTimeInterval)duration
{
    CABasicAnimation* rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
	rotationAnimation.toValue = @((2 * M_PI) * 3);
	rotationAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];

	CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
	scaleAnimation.fromValue = @0.0f;
	scaleAnimation.toValue = @1.0f;
	scaleAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
	CAAnimationGroup *animation = [CAAnimationGroup animation];
    animation.beginTime = startPosition;
	animation.duration = duration;
	[animation setAnimations:@[rotationAnimation, scaleAnimation]];
    
    return animation;
}

- (CAAnimationGroup*) endSpinAction:(CFTimeInterval)endPosition duration:(CFTimeInterval)duration fromTransform:(CATransform3D) fromTransform fromZoomValue:(CGFloat) fromZoomValue
{
    CABasicAnimation* rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
	rotationAnimation.toValue = @(-(2 * M_PI) * 3);
	rotationAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	
	CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
	scaleAnimation.fromValue = @[[NSNumber numberWithFloat:fromZoomValue]];
	scaleAnimation.toValue = @0.0f;
	scaleAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
	CAAnimationGroup *animation = [CAAnimationGroup animation];
    animation.beginTime = endPosition;
	animation.duration = duration;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    [animation setAnimations:@[rotationAnimation, scaleAnimation]];
    

    return animation;
}

@end