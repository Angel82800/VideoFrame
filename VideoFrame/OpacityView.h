//
//  OpacityView.h
//  VideoFrame
//
//  Created by Yinjing Li on 5/2/14.
//  Copyright (c) 2014 Yinjing Li. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppDelegate.h"
#import "Definition.h"


@protocol OpacityViewDelegate <NSObject>

-(void) changeOpacity:(CGFloat) opacityValue;

@end


@interface OpacityView : UIView

@property(nonatomic, weak) id<OpacityViewDelegate> delegate;

@property(nonatomic, strong) UILabel* titleLabel;

@property(nonatomic, strong) UISlider* opacitySlider;


-(void) setOpacityValue:(CGFloat) value;

@end
