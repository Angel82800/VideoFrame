//
//  KZColorPickerBrightnessSlider.h
//  VideoFrame
//
//  Created by Yinjing Li on 3/6/14.
//  Copyright (c) 2014 Yinjing Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "KZUnitSlider.h"


@interface KZColorPickerWidthSlider : KZUnitSlider
{
    CALayer *gradientLayer;
}

-(void) setKeyColor:(UIColor *)c;
-(void) changeSliderRange;

@end
