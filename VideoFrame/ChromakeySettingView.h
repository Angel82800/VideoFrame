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
#import "UIImageExtras.h"
#import "UIColor-Expanded.h"


@class BSKeyboardControls;


@protocol ChromakeySettingViewDelegate <NSObject>

-(void) changeChromakeyColor:(UIColor*) color;

@end


@interface ChromakeySettingView : UIView<UIScrollViewDelegate,  UITextFieldDelegate>

@property(nonatomic, weak) id<ChromakeySettingViewDelegate> delegate;

@property(nonatomic, strong) UIColor *selectedChromakeyColor;

@property(nonatomic, strong) UIView* selectedColorView;

@property(nonatomic, strong) UILabel* titleLabel;
@property(nonatomic, strong) UILabel* selectedColorLabel;

@property(nonatomic, strong) UIButton* redBtn;
@property(nonatomic, strong) UIButton* greenBtn;
@property(nonatomic, strong) UIButton* blueBtn;


-(void) initialize;

@end