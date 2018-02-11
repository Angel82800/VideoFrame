//
//  KZColorWheelView.h
//  VideoFrame
//
//  Created by Yinjing Li on 3/6/14.
//  Copyright (c) 2014 Yinjing Li. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KZColorPickerHSWheel;
@class KZColorPickerBrightnessSlider;
@class KZColorPickerAlphaSlider;

@interface KZColorPicker : UIControl
{
	KZColorPickerHSWheel *colorWheel;
    
	KZColorPickerBrightnessSlider *brightnessSlider;
    
	KZColorPickerAlphaSlider *alphaSlider;
    
	UIColor *selectedColor;
}

@property(nonatomic, strong) UIColor *selectedColor;
@property(nonatomic, strong) UIColor *oldColor;


-(void) hideAlphaSlider;
-(void) setSelectedColor:(UIColor *)color animated:(BOOL)animated;

@end
