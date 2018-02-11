//
//  SwingAction.h
//  VideoFrame
//
//  Created by Yinjing Li on 2/10/14.
//  Copyright (c) 2014 Yinjing Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Definition.h"

@interface SwingAction : NSObject

-(CAAnimationGroup*) startSwingAction:(CFTimeInterval)startPosition duration:(CFTimeInterval)duration orientation:(ADTransitionOrientation)orientation sourceRect:(CGRect)sourceRect;
-(CAAnimationGroup*) endSwingAction:(CFTimeInterval)endPosition duration:(CFTimeInterval)duration orientation:(ADTransitionOrientation)orientation  sourceRect:(CGRect)sourceRect fromTransform:(CATransform3D) fromTransform fromZoomValue:(CGFloat) fromZoomValue;

@end
