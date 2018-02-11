//
//  OutlineView.h
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


@protocol OutlineViewDelegate <NSObject>

-(void) changeBorder:(int)style borderColor:(UIColor*) color borderWidth:(CGFloat)width cornerRadius:(CGFloat)radius;

@end


@interface OutlineView : UIView<UIScrollViewDelegate, UIGestureRecognizerDelegate, UITextFieldDelegate, BSKeyboardControlsDelegate, RecentColorViewDelegate>
{
    CGFloat firstX;
    CGFloat firstY;
}

@property(nonatomic, weak) id<OutlineViewDelegate> delegate;

@property(nonatomic, strong) UIView* borderWidthView;
@property(nonatomic, strong) UIView* cornerView;
@property(nonatomic, strong) UIView* leftBoxView;
@property(nonatomic, strong) UIView* colorPreviewView;

@property(nonatomic, strong) UIScrollView* borderStyleScrollView;
@property(nonatomic, strong) UIScrollView* recentColorScrollView;

@property(nonatomic, strong) UILabel* borderWidthTitleLabel;
@property(nonatomic, strong) UILabel* minPixelLabel;
@property(nonatomic, strong) UILabel* maxPixelLabel;
@property(nonatomic, strong) UILabel* cornerTitleLabel;
@property(nonatomic, strong) UILabel* minCornerLabel;
@property(nonatomic, strong) UILabel* maxCornerLabel;
@property(nonatomic, strong) UILabel* colorLabel;
@property(nonatomic, strong) UILabel* xLabel;
@property(nonatomic, strong) UILabel* addLabel;

@property(nonatomic, strong) UITextField* hexTextField;

@property(nonatomic, strong) UIColor *objectBorderColor;

@property(nonatomic, strong) KZColorPickerWidthSlider *borderWidthSlider;
@property(nonatomic, strong) KZColorPickerWidthSlider *cornerSlider;
@property(nonatomic, strong) KZColorPicker *colorPickerView;
@property(nonatomic, strong) BSKeyboardControls* iPhoneKeyboard;

@property(nonatomic, assign) int objectBorderStyle;

@property(nonatomic, assign) CGFloat objectBorderWidth;
@property(nonatomic, assign) CGFloat objectCornerRadius;
@property(nonatomic, assign) CGFloat maxCornerValue;


-(void) initialize;
-(void) changeMaxCornerValue:(CGFloat) maxValue;
-(void) saveCurrentColorToRecent;

@end