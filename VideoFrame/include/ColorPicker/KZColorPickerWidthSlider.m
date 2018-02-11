//
//  KZColorPickerBrightnessSlider.m
//  VideoFrame
//
//  Created by Yinjing Li on 3/6/14.
//  Copyright (c) 2014 Yinjing Li. All rights reserved.
//


#import "KZColorPickerWidthSlider.h"

@implementation KZColorPickerWidthSlider

- (id)initWithFrame:(CGRect)frame 
{
    if ((self = [super initWithFrame:frame])) 
	{		
        // Initialization code
        
        self.layer.cornerRadius = 6.0;
		self.layer.borderWidth = 2.0;
		self.layer.borderColor = [[UIColor whiteColor] CGColor];

        gradientLayer = [[CALayer alloc] init];
        gradientLayer.frame = self.bounds;
		gradientLayer.cornerRadius = 6.0;
        gradientLayer.position = CGPointMake(frame.size.width * 0.5, frame.size.height * 0.5);
        
		if ([self respondsToSelector:@selector(contentScaleFactor)])
			self.contentScaleFactor = [[UIScreen mainScreen] scale];
        
        [self.layer insertSublayer:gradientLayer atIndex:0];
        
		[self setKeyColor:[UIColor whiteColor]];
    }
    return self;
}

-(void) setKeyColor:(UIColor *)c
{
    [gradientLayer setBackgroundColor:c.CGColor];
}

-(void) changeSliderRange
{
    gradientLayer.frame = CGRectMake(0.0f, 0.0f, self.bounds.size.width*(1.0f-self.value), self.bounds.size.height);
}

-(void) setFrame:(CGRect)frame
{
    [super setFrame:frame];
    self.value = self.value;
}

@end
