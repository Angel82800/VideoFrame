//
//  RotateAction.h
//  VideoFrame
//
//  Created by Yinjing Li on 2/9/14.
//  Copyright (c) 2014 Yinjing Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Definition.h"

@interface RotateAction : NSObject

-(CAAnimationGroup*) startRotateAction:(CFTimeInterval)startPosition duration:(CFTimeInterval)duration sourceRect:(CGRect)sourceRect;
-(CAAnimationGroup*) endRotateAction:(CFTimeInterval)endPosition duration:(CFTimeInterval)duration sourceRect:(CGRect)sourceRect fromTransform:(CATransform3D) fromTransform fromZoomValue:(CGFloat) fromZoomValue;

@end
