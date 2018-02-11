//
//  TextSettingView.h
//  VideoFrame
//
//  Created by Yinjing Li on 3/6/14.
//  Copyright (c) 2014 Yinjing Li. All rights reserved.
//


#import <Foundation/Foundation.h>

#import "Definition.h"
#import "AppDelegate.h"
#import "CustomModalView.h"
#import "KZColorPicker.h"
#import "KZColorPickerWidthSlider.h"
#import "UIImageExtras.h"
#import "BSKeyboardControls.h"
#import "UIColor-Expanded.h"
#import "RecentColorView.h"


@class BSKeyboardControls;


@class TextSettingView;

@protocol TextSettingViewDelegate <NSObject>

-(void) changeTextColor:(UIColor*) color;
-(void) changeTextAlignment:(NSTextAlignment) alignment;
-(void) changeTextUnderline:(BOOL) isUnderline;
-(void) changeTextStroke:(BOOL) isStroke;
-(void) changeTextFont:(NSString*)fontName size:(CGFloat)fontSize bold:(BOOL)isBold italic:(BOOL)isItalic;

@end


@interface TextSettingView : UIView<UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, BSKeyboardControlsDelegate, RecentColorViewDelegate>
{
    CGFloat lastScaleFactor;
    CGFloat firstX;
    CGFloat firstY;
    CGPoint lastPoint;
}

@property(nonatomic, weak) id<TextSettingViewDelegate> delegate;

@property(nonatomic, strong) UIView* alignmentView;
@property(nonatomic, strong) UIView* leftBoxView;
@property(nonatomic, strong) UIView* fontSizeView;
@property(nonatomic, strong) UIView* colorPreviewView;

@property(nonatomic, strong) UITableView* fontNameTableView;

@property(nonatomic, strong) UIScrollView* recentColorScrollView;

@property(nonatomic, strong) UIButton* alignmentLeftBtn;
@property(nonatomic, strong) UIButton* alignmentCenterBtn;
@property(nonatomic, strong) UIButton* alignmentRightBtn;
@property(nonatomic, strong) UIButton* boldBtn;
@property(nonatomic, strong) UIButton* italicBtn;
@property(nonatomic, strong) UIButton* underlineBtn;
@property(nonatomic, strong) UIButton* strokeBtn;

@property(nonatomic, strong) UILabel* colorLabel;
@property(nonatomic, strong) UILabel* fontSizeLabel;
@property(nonatomic, strong) UILabel* xLabel;
@property(nonatomic, strong) UILabel* addLabel;

@property(nonatomic, strong) UITextField* hexTextField;
@property(nonatomic, strong) UISlider* fontSizeSlider;
@property(nonatomic, strong) UIColor *textColor;
@property(nonatomic, strong) UITapGestureRecognizer* removeTapGesture;

@property(nonatomic, strong) NSString* strFontName;
@property(nonatomic, assign) NSTextAlignment alignment;

@property(nonatomic, strong) KZColorPicker *colorPickerView;
@property(nonatomic, strong) BSKeyboardControls* iPhoneKeyboard;

@property(nonatomic, assign) BOOL isBold;
@property(nonatomic, assign) BOOL isItalic;
@property(nonatomic, assign) BOOL isUnderline;
@property(nonatomic, assign) BOOL isStroke;
@property(nonatomic, assign) CGFloat textFontSize;

- (void) initialize;

@end