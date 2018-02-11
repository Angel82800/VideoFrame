//
//  FoldAction.m
//  VideoFrame
//
//  Created by Yinjing Li on 1/29/14.
//  Copyright (c) 2014 Yinjing Li. All rights reserved.
//

#import "FoldAction.h"


@implementation FoldAction

- (id)init
{
    self = [super init];

    if (self)
    {
        
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

- (CAAnimationGroup*) startFoldAction:(CFTimeInterval)startPosition duration:(CFTimeInterval)duration orientation:(ADTransitionOrientation)orientation sourceRect:(CGRect)sourceRect
{
    const CGFloat viewWidth = sourceRect.size.width;
    const CGFloat viewHeight = sourceRect.size.height;
    const CGFloat inAngle = M_PI - 0.001f; // epsilon for modulo
    
    CGPoint inAnchorPoint = CGPointZero;
    CATransform3D inStartTranslation = CATransform3DMakeTranslation(-viewWidth * 0.5f, 0, 0);
    CATransform3D inRotation = CATransform3DRotate(inStartTranslation, -inAngle, 0, 1.0f, 0);
    
    switch (orientation)
    {
        case ADTransitionRightToLeft:
        {
            inAnchorPoint = CGPointMake(1.0f, 0.5f);
            inStartTranslation =  CATransform3DMakeTranslation(-viewWidth * 0.5f, 0, 0);
            inStartTranslation = CATransform3DConcat(inStartTranslation, CATransform3DMakeRotation(inAngle, 0, 1.0f, 0));
            inStartTranslation.m34 = 1.0 / 1000; // greater the denominator lesser will be the transformation
            inRotation = CATransform3DRotate(inStartTranslation, -inAngle, 0, 1.0f, 0);
        }
            break;
        case ADTransitionLeftToRight:
        {
            inAnchorPoint = CGPointMake(0.0f, 0.5f);
            inStartTranslation =  CATransform3DMakeTranslation(viewWidth * 0.5f, 0, 0);
            inStartTranslation = CATransform3DConcat(inStartTranslation, CATransform3DMakeRotation(-inAngle, 0, 1.0f, 0));
            inStartTranslation.m34 = 1.0 / 1000; // greater the denominator lesser will be the transformation
            inRotation = CATransform3DRotate(inStartTranslation, inAngle, 0, 1.0f, 0);
        }
            break;
        case ADTransitionTopToBottom:
        {
            inAnchorPoint = CGPointMake(0.5f, 1.0f);
            inStartTranslation =  CATransform3DMakeTranslation(0, -viewHeight * 0.5f, 0);
            inStartTranslation = CATransform3DConcat(inStartTranslation, CATransform3DMakeRotation(-inAngle, 1.0f, 0, 0));
            inStartTranslation.m34 = 1.0 / 1000; // greater the denominator lesser will be the transformation
            inRotation = CATransform3DRotate(inStartTranslation, inAngle, 1.0f, 0, 0);
        }
            break;
        case ADTransitionBottomToTop:
        {
            inAnchorPoint = CGPointMake(0.5f, 0.0f);
            inStartTranslation =  CATransform3DMakeTranslation(0, viewHeight * 0.5f, 0);
            inStartTranslation = CATransform3DConcat(inStartTranslation, CATransform3DMakeRotation(inAngle, 1.0f, 0, 0));
            inStartTranslation.m34 = 1.0 / 1000; // greater the denominator lesser will be the transformation
            inRotation = CATransform3DRotate(inStartTranslation, -inAngle, 1.0f, 0, 0);
        }
            break;
        default:
            NSAssert(FALSE, @"Unhandled ADTransitionOrientation");
            break;
    }
    
    CABasicAnimation * inAnchorPointAnimation = [CABasicAnimation animationWithKeyPath:@"anchorPoint"];
    inAnchorPointAnimation.fromValue = [NSValue valueWithCGPoint:inAnchorPoint];
    inAnchorPointAnimation.toValue = [NSValue valueWithCGPoint:inAnchorPoint];
    
    CABasicAnimation * inRotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    inRotationAnimation.fromValue = [NSValue valueWithCATransform3D:inStartTranslation];
    inRotationAnimation.toValue = [NSValue valueWithCATransform3D:inRotation];
    
    CAKeyframeAnimation * zTranslationAnimation = [CAKeyframeAnimation animationWithKeyPath:@"zPosition"];
    zTranslationAnimation.values = @[@1000.0f, @1000.0f];
    zTranslationAnimation.timingFunctions = [self getCircleApproximationTimingFunctions];

    CAAnimationGroup* inAnimation = [CAAnimationGroup animation];
    [inAnimation setAnimations:@[inRotationAnimation, inAnchorPointAnimation, zTranslationAnimation]];
    inAnimation.beginTime = startPosition;
    inAnimation.duration = duration;

    return inAnimation;
}

- (CAAnimationGroup*) endFoldAction:(CFTimeInterval)endPosition duration:(CFTimeInterval)duration orientation:(ADTransitionOrientation)orientation sourceRect:(CGRect)sourceRect fromTransform:(CATransform3D) fromTransform fromZoomValue:(CGFloat) fromZoomValue
{
    const CGFloat viewWidth = sourceRect.size.width;
    const CGFloat viewHeight = sourceRect.size.height;
    const CGFloat outAngle = M_PI - 0.001f; // epsilon for modulo
    
    //fix By Yinjing 0403
    CGPoint outAnchorPoint = CGPointZero;
    CATransform3D outStartTranslation = CATransform3DTranslate(fromTransform, viewWidth * 0.5f, 0, 0);
    CATransform3D outRotation = CATransform3DRotate(outStartTranslation, outAngle, 0, 1.0f, 0);
    
    switch (orientation)
    {
        case ADTransitionRightToLeft:
        {
            outAnchorPoint = CGPointMake(0.0f, 0.5f);
            
            outStartTranslation = CATransform3DTranslate(fromTransform, viewWidth * 0.5f, 0, 0);
            outStartTranslation = CATransform3DConcat(outStartTranslation, CATransform3DMakeRotation(-outAngle, 0, 1.0f, 0));
            outStartTranslation.m34 = 1.0 / 1000; // greater the denominator lesser will be the transformation
            outRotation = CATransform3DRotate(outStartTranslation, outAngle, 0, 1.0f, 0);
        }
            break;
        case ADTransitionLeftToRight:
        {
            outAnchorPoint = CGPointMake(1.0f, 0.5f);
            
            outStartTranslation = CATransform3DTranslate(fromTransform, -viewWidth * 0.5f, 0, 0);
            outStartTranslation = CATransform3DConcat(outStartTranslation, CATransform3DMakeRotation(outAngle, 0, 1.0f, 0));
            outStartTranslation.m34 = 1.0 / 1000; // greater the denominator lesser will be the transformation
            outRotation = CATransform3DRotate(outStartTranslation, -outAngle, 0, 1.0f, 0);
        }
            break;
        case ADTransitionTopToBottom:
        {
            outAnchorPoint = CGPointMake(0.5f, 0.0f);
            
            outStartTranslation = CATransform3DTranslate(fromTransform, 0, viewHeight * 0.5f, 0);
            outStartTranslation = CATransform3DConcat(outStartTranslation, CATransform3DMakeRotation(outAngle, 1.0f, 0, 0));
            outStartTranslation.m34 = 1.0 / 1000; // greater the denominator lesser will be the transformation
            outRotation = CATransform3DRotate(outStartTranslation, -outAngle, 1.0f, 0, 0);
        }
            break;
        case ADTransitionBottomToTop:
        {
            outAnchorPoint = CGPointMake(0.5f, 1.0f);
            
            outStartTranslation = CATransform3DTranslate(fromTransform, 0, -viewHeight * 0.5f, 0);
            outStartTranslation = CATransform3DConcat(outStartTranslation, CATransform3DMakeRotation(-outAngle, 1.0f, 0, 0));
            outStartTranslation.m34 = 1.0 / 1000; // greater the denominator lesser will be the transformation
            outRotation = CATransform3DRotate(outStartTranslation, outAngle, 1.0f, 0, 0);
        }
            break;
            
        default:
            NSAssert(FALSE, @"Unhandled ADTransitionOrientation");
            break;
    }
    
    CABasicAnimation * outAnchorPointAnimation = [CABasicAnimation animationWithKeyPath:@"anchorPoint"];
    outAnchorPointAnimation.fromValue = [NSValue valueWithCGPoint:outAnchorPoint];
    outAnchorPointAnimation.toValue = [NSValue valueWithCGPoint:outAnchorPoint];
    
    CABasicAnimation * outRotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    outRotationAnimation.fromValue = [NSValue valueWithCATransform3D:outRotation];
    outRotationAnimation.toValue = [NSValue valueWithCATransform3D:outStartTranslation];

    CAKeyframeAnimation *scaleAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.values = @[[NSNumber numberWithFloat:fromZoomValue]];
    
    CAKeyframeAnimation * zTranslationAnimation = [CAKeyframeAnimation animationWithKeyPath:@"zPosition"];
    zTranslationAnimation.values = @[@1000.0f, @1000.0f];
    zTranslationAnimation.timingFunctions = [self getCircleApproximationTimingFunctions];

    CAAnimationGroup * outAnimation = [CAAnimationGroup animation];
    [outAnimation setAnimations:@[outRotationAnimation, outAnchorPointAnimation, zTranslationAnimation, scaleAnimation]];
    outAnimation.beginTime = endPosition;
    outAnimation.duration = duration;
    outAnimation.removedOnCompletion = NO;
    outAnimation.fillMode = kCAFillModeForwards;
    
    return outAnimation;
}


@end
