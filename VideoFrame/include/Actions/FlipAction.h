//
//  FlipAction.h
//  VideoFrame
//
//  Created by Yinjing Li on 2/9/14.
//  Copyright (c) 2014 Yinjing Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Definition.h"

@interface FlipAction : NSObject

-(CAAnimationGroup*) startFlipAction:(CFTimeInterval)startPosition duration:(CFTimeInterval)duration orientation:(ADTransitionOrientation)orientation sourceRect:(CGRect)sourceRect;
-(CAAnimationGroup*) endFlipAction:(CFTimeInterval)endPosition duration:(CFTimeInterval)duration orientation:(ADTransitionOrientation)orientation sourceRect:(CGRect)sourceRect fromTransform:(CATransform3D) fromTransform fromZoomValue:(CGFloat) fromZoomValue;

@end