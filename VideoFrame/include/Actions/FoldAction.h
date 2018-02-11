//
//  FoldAction.h
//  VideoFrame
//
//  Created by Yinjing Li on 1/29/14.
//  Copyright (c) 2014 Yinjing Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Definition.h"


@interface FoldAction : NSObject


-(CAAnimationGroup*) startFoldAction:(CFTimeInterval)startPosition duration:(CFTimeInterval)duration orientation:(ADTransitionOrientation)orientation sourceRect:(CGRect)sourceRect;
-(CAAnimationGroup*) endFoldAction:(CFTimeInterval)endPosition duration:(CFTimeInterval)duration orientation:(ADTransitionOrientation)orientation sourceRect:(CGRect)sourceRect fromTransform:(CATransform3D) fromTransform fromZoomValue:(CGFloat) fromZoomValue;

@end
