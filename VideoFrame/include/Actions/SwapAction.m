//
//  SwapAction.m
//  VideoFrame
//
//  Created by Yinjing Li on 02/06/14.
//  Copyright (c) 2014 Yinjing Li. All rights reserved.
//

#import "SwapAction.h"


@implementation SwapAction


- (id)init
{
    self = [super init];
    
    if (self)
    {
        
    }
    
    return self;
}

- (CAAnimationGroup*) startSwapAction:(CFTimeInterval)startPosition duration:(CFTimeInterval)duration orientation:(ADTransitionOrientation)orientation sourceRect:(CGRect)sourceRect
{
    CGFloat viewWidth = sourceRect.size.width;
    CGFloat viewHeight = sourceRect.size.height;
    
    CATransform3D rightTransform = CATransform3DMakeTranslation(viewWidth, 0.0f, 0.0f);
    CATransform3D leftTransform = CATransform3DMakeTranslation(-viewWidth, 0.0f, 0.0f);
    CATransform3D topTransform = CATransform3DMakeTranslation(0.0f, -viewHeight, 0.0f);
    CATransform3D bottomTransform = CATransform3DMakeTranslation(0.0f, viewHeight, 0.0f);
    
    CAKeyframeAnimation * inPosition = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    
    switch (orientation)
    {
        case ADTransitionRightToLeft:
            inPosition.values = @[[NSValue valueWithCATransform3D:CATransform3DIdentity], [NSValue valueWithCATransform3D:rightTransform], [NSValue valueWithCATransform3D:CATransform3DIdentity]];
            break;
            
        case ADTransitionLeftToRight:
            inPosition.values = @[[NSValue valueWithCATransform3D:CATransform3DIdentity], [NSValue valueWithCATransform3D:leftTransform], [NSValue valueWithCATransform3D:CATransform3DIdentity]];
            break;
            
        case ADTransitionBottomToTop:
            inPosition.values = @[[NSValue valueWithCATransform3D:CATransform3DIdentity], [NSValue valueWithCATransform3D:topTransform], [NSValue valueWithCATransform3D:CATransform3DIdentity]];
            break;
            
        case ADTransitionTopToBottom:
            inPosition.values = @[[NSValue valueWithCATransform3D:CATransform3DIdentity], [NSValue valueWithCATransform3D:bottomTransform], [NSValue valueWithCATransform3D:CATransform3DIdentity]];
            break;
            
        case ADTransitionBottomLeft:
            inPosition.values = @[[NSValue valueWithCATransform3D:CATransform3DIdentity], [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(-viewWidth, -viewHeight, 0.0f)], [NSValue valueWithCATransform3D:CATransform3DIdentity]];
            break;
            
        case ADTransitionBottomRight:
            inPosition.values = @[[NSValue valueWithCATransform3D:CATransform3DIdentity], [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(viewWidth, -viewHeight, 0.0f)], [NSValue valueWithCATransform3D:CATransform3DIdentity]];
            break;
            
        case ADTransitionTopLeft:
            inPosition.values = @[[NSValue valueWithCATransform3D:CATransform3DIdentity], [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(-viewWidth, viewHeight, 0.0f)], [NSValue valueWithCATransform3D:CATransform3DIdentity]];
            break;
            
        case ADTransitionTopRight:
            inPosition.values = @[[NSValue valueWithCATransform3D:CATransform3DIdentity], [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(viewWidth, viewHeight, 0.0f)], [NSValue valueWithCATransform3D:CATransform3DIdentity]];
            break;

        default:
            NSAssert(FALSE, @"Unhandlded ADSwapTransitionOrientation!");
            break;
    }
    
    CAMediaTimingFunction * LinearFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    inPosition.timingFunction = LinearFunction;
    inPosition.additive = NO;
    inPosition.fillMode = kCAFillModeBackwards;
    
    CAKeyframeAnimation *scaleAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.values = @[[NSNumber numberWithFloat:0.001f], [NSNumber numberWithFloat:1.0f], [NSNumber numberWithFloat:1.0f]];
    scaleAnimation.additive = NO;
    scaleAnimation.fillMode = kCAFillModeBackwards;
    
    CAAnimationGroup * inAnimation = [CAAnimationGroup animation];
    [inAnimation setAnimations:@[inPosition, scaleAnimation]];
    inAnimation.beginTime = startPosition;
    inAnimation.duration = duration;
    inAnimation.removedOnCompletion = NO;
    inAnimation.fillMode = kCAFillModeBackwards;
    
    return inAnimation;
}

- (CAAnimationGroup*) endSwapAction:(CFTimeInterval)endPosition duration:(CFTimeInterval)duration orientation:(ADTransitionOrientation)orientation sourceRect:(CGRect)sourceRect fromTransform:(CATransform3D) fromTransform fromZoomValue:(CGFloat) fromZoomValue
{
    CGFloat viewWidth = sourceRect.size.width;
    CGFloat viewHeight = sourceRect.size.height;
    
    CATransform3D rightTransform = CATransform3DMakeTranslation(viewWidth, 0.0f, 0.0f);
    CATransform3D leftTransform = CATransform3DMakeTranslation(-viewWidth, 0.0f, 0.0f);
    CATransform3D topTransform = CATransform3DMakeTranslation(0.0f, -viewHeight, 0.0f);
    CATransform3D bottomTransform = CATransform3DMakeTranslation(0.0f, viewHeight, 0.0f);

    CAKeyframeAnimation * outPosition = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    
    switch (orientation)
    {
        case ADTransitionRightToLeft:
            outPosition.values = @[[NSValue valueWithCATransform3D:fromTransform], [NSValue valueWithCATransform3D:leftTransform], [NSValue valueWithCATransform3D:CATransform3DIdentity]];
            break;
            
        case ADTransitionLeftToRight:
            outPosition.values = @[[NSValue valueWithCATransform3D:fromTransform], [NSValue valueWithCATransform3D:rightTransform], [NSValue valueWithCATransform3D:CATransform3DIdentity]];
            break;
            
        case ADTransitionBottomToTop:
            outPosition.values = @[[NSValue valueWithCATransform3D:fromTransform], [NSValue valueWithCATransform3D:bottomTransform], [NSValue valueWithCATransform3D:CATransform3DIdentity]];
            break;
            
        case ADTransitionTopToBottom:
            outPosition.values = @[[NSValue valueWithCATransform3D:fromTransform], [NSValue valueWithCATransform3D:topTransform], [NSValue valueWithCATransform3D:CATransform3DIdentity]];
            break;

        case ADTransitionBottomLeft:
            outPosition.values = @[[NSValue valueWithCATransform3D:fromTransform], [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(-viewWidth, -viewHeight, 0.0f)], [NSValue valueWithCATransform3D:CATransform3DIdentity]];
            break;

        case ADTransitionBottomRight:
            outPosition.values = @[[NSValue valueWithCATransform3D:fromTransform], [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(viewWidth, -viewHeight, 0.0f)], [NSValue valueWithCATransform3D:CATransform3DIdentity]];
            break;
            
        case ADTransitionTopLeft:
            outPosition.values = @[[NSValue valueWithCATransform3D:fromTransform], [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(-viewWidth, viewHeight, 0.0f)], [NSValue valueWithCATransform3D:CATransform3DIdentity]];
            break;

        case ADTransitionTopRight:
            outPosition.values = @[[NSValue valueWithCATransform3D:fromTransform], [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(viewWidth, viewHeight, 0.0f)], [NSValue valueWithCATransform3D:CATransform3DIdentity]];
            break;


        default:
            NSAssert(FALSE, @"Unhandlded ADSwapTransitionOrientation!");
            break;
    }
    
    CAMediaTimingFunction * LinearFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    outPosition.timingFunction = LinearFunction;
    outPosition.additive = NO;
    outPosition.fillMode = kCAFillModeForwards;

    CAKeyframeAnimation *scaleAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.values = @[[NSNumber numberWithFloat:fromZoomValue], [NSNumber numberWithFloat:fromZoomValue], [NSNumber numberWithFloat:0.001f]];
    scaleAnimation.additive = NO;
    scaleAnimation.fillMode = kCAFillModeForwards;

    CAAnimationGroup * outAnimation = [CAAnimationGroup animation];
    [outAnimation setAnimations:@[outPosition, scaleAnimation]];
    outAnimation.beginTime = endPosition;
    outAnimation.duration = duration;
    outAnimation.removedOnCompletion = NO;
    outAnimation.fillMode = kCAFillModeForwards;
    
    return outAnimation;
}

@end
