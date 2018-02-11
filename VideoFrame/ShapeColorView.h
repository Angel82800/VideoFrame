//
//  ShadowView.h
//  VideoFrame
//
//  Created by Yinjing Li on 12/2/14.
//  Copyright (c) 2014 Yinjing Li. All rights reserved.
//


#import <Foundation/Foundation.h>

#import "Definition.h"
#import "AppDelegate.h"
#import "KZColorPicker.h"
#import "UIImageExtras.h"
#import "BSKeyboardControls.h"
#import "UIColor-Expanded.h"
#import "RecentColorView.h"


@class BSKeyboardControls;

@class ShapeColorView;


@protocol ShapeColorViewDelegate <NSObject>

-(void) changeShapeColor:(UIColor*) color style:(int) shapeOverlayStyle;

@end


@interface ShapeColorView : UIView<UIScrollViewDelegate, UIGestureRecognizerDelegate, UITextFieldDelegate, BSKeyboardControlsDelegate, RecentColorViewDelegate>
{
    CGFloat firstX;
    CGFloat firstY;
}

@property(nonatomic, weak) id<ShapeColorViewDelegate> delegate;

@property(nonatomic, strong) UIButton* originalBtn;
@property(nonatomic, strong) UIButton* overlayBtn;

@property(nonatomic, strong) UIView* leftBoxView;
@property(nonatomic, strong) UIView* colorPreviewView;

@property(nonatomic, strong) UIScrollView* recentColorScrollView;

@property(nonatomic, strong) UILabel* overlayColorLabel;
@property(nonatomic, strong) UILabel* xLabel;
@property(nonatomic, strong) UILabel* addLabel;

@property(nonatomic, strong) UITextField* hexTextField;

@property(nonatomic, strong) UIColor *shapeOverlayColor;

@property(nonatomic, strong) KZColorPicker *overlayColorPickerView;
@property(nonatomic, strong) BSKeyboardControls* iPhoneKeyboard;

@property(nonatomic, assign) int shapeOverlayStyle;//1-none, 2-shadow


- (void) initialize;

@end