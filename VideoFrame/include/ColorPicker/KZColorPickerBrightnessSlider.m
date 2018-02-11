//
//  KZColorPickerBrightnessSlider.m
//  VideoFrame
//
//  Created by Yinjing Li on 3/6/14.
//  Copyright (c) 2014 Yinjing Li. All rights reserved.
//


#import "KZColorPickerBrightnessSlider.h"


@implementation KZColorPickerBrightnessSlider

-(id) initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) 
	{		
        // Initialization code
        gradientLayer = [[CAGradientLayer alloc] init];
        gradientLayer.frame = self.bounds;
        gradientLayer.startPoint = CGPointMake(0.5, 0.0);
        gradientLayer.endPoint = CGPointMake(0.5, 1.0);
		gradientLayer.cornerRadius = 6.0;
		gradientLayer.borderWidth = 2.0;
		gradientLayer.borderColor = [[UIColor whiteColor] CGColor];
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
	[CATransaction begin];
	[CATransaction setValue:(id)kCFBooleanTrue
					 forKey:kCATransactionDisableActions];
	gradientLayer.colors =  [NSArray arrayWithObjects:	 
							 (id)c.CGColor,
							 (id)[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0].CGColor,		 		 
							 nil];
	[CATransaction commit];
}

-(void) setFrame:(CGRect)frame
{
    [super setFrame:frame];
    self.value = self.value;
}

@end
