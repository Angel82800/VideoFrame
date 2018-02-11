//
//  ShadowView.h
//  VideoFrame
//
//  Created by Yinjing Li on 3/6/14.
//  Copyright (c) 2014 Yinjing Li. All rights reserved.
//


#import <Foundation/Foundation.h>

#import "Definition.h"
#import "AppDelegate.h"
#import "KZColorPicker.h"
#import "KZColorPickerWidthSlider.h"
#import "UIImageExtras.h"
#import "BSKeyboardControls.h"
#import "UIColor-Expanded.h"
#import "RecentColorView.h"


@class BSKeyboardControls;


@protocol ShadowViewDelegate <NSObject>

-(void) changeShadow:(CGFloat)shadowOffset shadowBlur:(CGFloat)blur shadowColor:(UIColor*)color shadowStyle:(int)style;

@end


@interface ShadowView : UIView<UIScrollViewDelegate, UIGestureRecognizerDelegate, UITextFieldDelegate, BSKeyboardControlsDelegate, RecentColorViewDelegate>
{
    CGFloat firstX;
    CGFloat firstY;
}

@property(nonatomic, weak) id<ShadowViewDelegate> delegate;

@property(nonatomic, strong) UIView* shadowWidthView;
@property(nonatomic, strong) UIView* shadowOffsetView;
@property(nonatomic, strong) UIView* leftBoxView;
@property(nonatomic, strong) UIView* colorPreviewView;

@property(nonatomic, strong) UIScrollView* recentColorScrollView;

@property(nonatomic, strong) UIButton* noShadowBtn;
@property(nonatomic, strong) UIButton* shadowBtn;

@property(nonatomic, strong) UILabel* shadowWidthTitleLabel;
@property(nonatomic, strong) UILabel* shadowWidthMinPixelLabel;
@property(nonatomic, strong) UILabel* shadowWidthMaxPixelLabel;
@property(nonatomic, strong) UILabel* shadowOffsetTitleLabel;
@property(nonatomic, strong) UILabel* shadowOffsetMinPixelLabel;
@property(nonatomic, strong) UILabel* shadowOffsetMaxPixelLabel;
@property(nonatomic, strong) UILabel* shadowColorLabel;
@property(nonatomic, strong) UILabel* xLabel;
@property(nonatomic, strong) UILabel* addLabel;

@property(nonatomic, strong) UITextField* hexTextField;

@property(nonatomic, strong) UIColor *objectShadowColor;

@property(nonatomic, strong) KZColorPickerWidthSlider *shadowWidthSlider;
@property(nonatomic, strong) KZColorPickerWidthSlider *shadowOffsetSlider;
@property(nonatomic, strong) KZColorPicker *shadowColorPickerView;
@property(nonatomic, strong) BSKeyboardControls* iPhoneKeyboard;

@property(nonatomic, assign) int objectShadowStyle;//1-none, 2-shadow

@property(nonatomic, assign) CGFloat objectShadowBlur;
@property(nonatomic, assign) CGFloat objectShadowOffset;

-(void) initialize;
-(void) saveCurrentColorToRecent;

@end