//
//  ReflectionSettingView.h
//  VideoFrame
//
//  Created by Yinjing Li on 3/22/14.
//  Copyright (c) 2014 Yinjing Li. All rights reserved.
//


#import <Foundation/Foundation.h>

#import "Definition.h"
#import "AppDelegate.h"
#import "UIImageExtras.h"
#import "KZColorPickerWidthSlider.h"
#import "ReflectionView.h"


@class ReflectionSettingView;

@protocol ReflectionSettingViewDelegate <NSObject>

-(void) changeReflection:(BOOL) isReflection scale:(CGFloat)reflectionScale alpha:(CGFloat)reflectionAlpha gap:(CGFloat)reflectionGap;

@end


@interface ReflectionSettingView : UIView<UIGestureRecognizerDelegate>
{
    CGFloat firstX;
    CGFloat firstY;
}

@property(nonatomic, weak) id<ReflectionSettingViewDelegate> delegate;

@property(nonatomic, strong) ReflectionView *reflectionView;

@property(nonatomic, strong) UIView* switchView;
@property(nonatomic, strong) UIView* scaleView;
@property(nonatomic, strong) UIView* alphaView;
@property(nonatomic, strong) UIView* gapView;
@property(nonatomic, strong) UIView* leftBoxView;

@property(nonatomic, strong) UIImageView* reflectionImageView;

@property(nonatomic, strong) UISwitch* reflectionSwitch;

@property(nonatomic, strong) UILabel* switchTitleLabel;
@property(nonatomic, strong) UILabel* scaleTitleLabel;
@property(nonatomic, strong) UILabel* minScaleLabel;
@property(nonatomic, strong) UILabel* maxScaleLabel;
@property(nonatomic, strong) UILabel* alphaTitleLabel;
@property(nonatomic, strong) UILabel* minAlphaLabel;
@property(nonatomic, strong) UILabel* maxAlphaLabel;
@property(nonatomic, strong) UILabel* gapTitleLabel;
@property(nonatomic, strong) UILabel* maxGapLabel;

@property(nonatomic, strong) KZColorPickerWidthSlider *scaleSlider;
@property(nonatomic, strong) KZColorPickerWidthSlider *alphaSlider;
@property(nonatomic, strong) KZColorPickerWidthSlider *gapSlider;

@property(nonatomic, assign) BOOL isReflection;

@property(nonatomic, assign) CGFloat reflectionScale;
@property(nonatomic, assign) CGFloat reflectionAlpha;
@property(nonatomic, assign) CGFloat reflectionGap;


-(void) initialize;

@end