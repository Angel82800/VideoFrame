//
//  SpinAction.h
//  VideoFrame
//
//  Created by Yinjing Li on 2/10/14.
//  Copyright (c) 2014 Yinjing Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Definition.h"

@interface SpinAction : NSObject

-(CAAnimationGroup*) startSpinAction:(CFTimeInterval)startPosition duration:(CFTimeInterval)duration;
-(CAAnimationGroup*) endSpinAction:(CFTimeInterval)endPosition duration:(CFTimeInterval)duration fromTransform:(CATransform3D) fromTransform fromZoomValue:(CGFloat) fromZoomValue;

@end
