//
//  RevealAction.h
//  VideoFrame
//
//  Created by Yinjing Li on 9/1/14.
//  Copyright (c) 2014 Yinjing Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Definition.h"

@interface RevealAction : NSObject

- (CAAnimationGroup*) startRevealAction:(CFTimeInterval)startPosition duration:(CFTimeInterval)duration orientation:(ADTransitionOrientation)orientation sourceRect:(CGRect)sourceRect;
- (CAAnimationGroup*) endRevealAction:(CFTimeInterval)endPosition duration:(CFTimeInterval)duration orientation:(ADTransitionOrientation)orientation sourceRect:(CGRect)sourceRect fromTransform:(CATransform3D) fromTransform fromZoomValue:(CGFloat) fromZoomValue;

@end