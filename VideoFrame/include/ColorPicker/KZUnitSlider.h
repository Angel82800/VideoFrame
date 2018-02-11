//
//  KZUnitSlider.h
//  VideoFrame
//
//  Created by Yinjing Li on 3/6/14.
//  Copyright (c) 2014 Yinjing Li. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface KZUnitSlider : UIControl 
{
    BOOL horizontal;
    
	CGFloat value;
}

@property(nonatomic) CGFloat value;

@property (nonatomic, strong) UIImageView *sliderKnobView;

@end
