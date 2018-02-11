//
//  VolumeView.h
//  VideoFrame
//
//  Created by Yinjing Li on 5/2/14.
//  Copyright (c) 2014 Yinjing Li. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppDelegate.h"


@protocol VolumeViewDelegate <NSObject>

-(void) changeVolume:(CGFloat) volumeValue;

@end


@interface VolumeView : UIView

@property(nonatomic, weak) id<VolumeViewDelegate> delegate;

@property(nonatomic, strong) UILabel* titleLabel;

@property(nonatomic, strong) UISlider* volumeSlider;


-(void) setVolumeValue:(CGFloat) value;

@end
