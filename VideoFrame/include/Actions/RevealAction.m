//
//  RevealAction.m
//  VideoFrame
//
//  Created by Yinjing Li on 9/1/14.
//  Copyright (c) 2014 Yinjing Li. All rights reserved.
//

#import "RevealAction.h"

@implementation RevealAction

- (id)init
{
    self = [super init];
    
    if (self)
    {
        
    }
    
    return self;
}

- (CAAnimationGroup*) startRevealAction:(CFTimeInterval)startPosition duration:(CFTimeInterval)duration orientation:(ADTransitionOrientation)orientation sourceRect:(CGRect)sourceRect
{
    const CGFloat viewWidth = sourceRect.size.width;
    const CGFloat viewHeight = sourceRect.size.height;
    
    CATransform3D inTranslationTransform = CATransform3DIdentity;
    
    switch (orientation) {
        case ADTransitionRightToLeft:
        {
            inTranslationTransform = CATransform3DTranslate(CATransform3DIdentity, viewWidth, 0, 0);
        }
            break;
        case ADTransitionLeftToRight:
        {
            inTranslationTransform = CATransform3DTranslate(CATransform3DIdentity, -viewWidth, 0, 0);
        }
            break;
        case ADTransitionTopToBottom:
        {
            inTranslationTransform = CATransform3DTranslate(CATransform3DIdentity, 0, viewHeight, 0);
        }
            break;
        case ADTransitionBottomToTop:
        {
            inTranslationTransform = CATransform3DTranslate(CATransform3DIdentity, 0, -viewHeight, 0);
        }
            break;
        default:
            NSAssert(FALSE, @"Unhandled ADTransitionOrientation");
            break;
    }
    
    CAKeyframeAnimation * inKeyFrameTransformAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    inKeyFrameTransformAnimation.values = @[[NSValue valueWithCATransform3D:inTranslationTransform],
                                            [NSValue valueWithCATransform3D:CATransform3DIdentity]];
    inKeyFrameTransformAnimation.additive = NO;
    inKeyFrameTransformAnimation.fillMode = kCAFillModeBackwards;
    

    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.fromValue = [NSNumber numberWithFloat:0.0];
    animation.byValue = [NSNumber numberWithFloat:1.0];
    animation.toValue = [NSNumber numberWithFloat:1.0];

    
    CAAnimationGroup * inAnimation = [CAAnimationGroup animation];
    inAnimation.animations = @[inKeyFrameTransformAnimation, animation];
    inAnimation.beginTime = startPosition;
    inAnimation.duration = duration;
    inAnimation.removedOnCompletion = NO;
    inAnimation.fillMode = kCAFillModeBackwards;

    return inAnimation;
}

- (CAAnimationGroup*) endRevealAction:(CFTimeInterval)endPosition duration:(CFTimeInterval)duration orientation:(ADTransitionOrientation)orientation sourceRect:(CGRect)sourceRect fromTransform:(CATransform3D) fromTransform fromZoomValue:(CGFloat) fromZoomValue
{
    const CGFloat viewWidth = sourceRect.size.width;
    const CGFloat viewHeight = sourceRect.size.height;
    CATransform3D outTranslationTransform = CATransform3DIdentity;
    
    switch (orientation) {
        case ADTransitionRightToLeft:
        {
            outTranslationTransform = CATransform3DTranslate(CATransform3DIdentity, -viewWidth, 0, 0);
        }
            break;
        case ADTransitionLeftToRight:
        {
            outTranslationTransform = CATransform3DTranslate(CATransform3DIdentity, viewWidth, 0, 0);
        }
            break;
        case ADTransitionTopToBottom:
        {
            outTranslationTransform = CATransform3DTranslate(CATransform3DIdentity, 0, -viewHeight, 0);
        }
            break;
        case ADTransitionBottomToTop:
        {
            outTranslationTransform = CATransform3DTranslate(CATransform3DIdentity, 0, viewHeight, 0);
        }
            break;
        default:
            NSAssert(FALSE, @"Unhandled ADTransitionOrientation");
            break;
    }
    
    CAKeyframeAnimation * outKeyFrameTransformAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    outKeyFrameTransformAnimation.values = @[[NSValue valueWithCATransform3D:fromTransform],
                                             [NSValue valueWithCATransform3D:outTranslationTransform]];
    outKeyFrameTransformAnimation.additive = NO;
    outKeyFrameTransformAnimation.fillMode = kCAFillModeForwards;
    
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.fromValue = [NSNumber numberWithFloat:1.0f];
    animation.byValue = [NSNumber numberWithFloat:1.0f];
    animation.toValue = [NSNumber numberWithFloat:0.0f];
    
    
    CAKeyframeAnimation *scaleAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.values = @[[NSNumber numberWithFloat:fromZoomValue], [NSNumber numberWithFloat:fromZoomValue]];


    CAAnimationGroup * outAnimation = [CAAnimationGroup animation];
    outAnimation.animations = @[outKeyFrameTransformAnimation, animation, scaleAnimation];
    outAnimation.beginTime = endPosition;
    outAnimation.duration = duration;
    outAnimation.removedOnCompletion = NO;
    outAnimation.fillMode = kCAFillModeForwards;
    
    return outAnimation;
}


@end
