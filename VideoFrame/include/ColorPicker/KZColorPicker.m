//
//  KZColorWheelView.m
//  VideoFrame
//
//  Created by Yinjing Li on 3/6/14.
//  Copyright (c) 2014 Yinjing Li. All rights reserved.
//


#import <QuartzCore/QuartzCore.h>

#import "KZColorPicker.h"
#import "KZColorPickerHSWheel.h"
#import "KZColorPickerBrightnessSlider.h"
#import "KZColorPickerAlphaSlider.h"
#import "HSV.h"
#import "UIColor-Expanded.h"

#define IS_IPAD ([[UIDevice currentDevice] respondsToSelector:@selector(userInterfaceIdiom)] && [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)


@interface KZColorPicker()
@property (nonatomic, retain) KZColorPickerHSWheel *colorWheel;
@property (nonatomic, retain) KZColorPickerBrightnessSlider *brightnessSlider;
@property (nonatomic, retain) KZColorPickerAlphaSlider *alphaSlider;
@end


@implementation KZColorPicker

@synthesize colorWheel;
@synthesize brightnessSlider;
@synthesize alphaSlider;
@synthesize selectedColor;
@synthesize oldColor = _oldColor;

-(void) setup
{
	self.backgroundColor = [UIColor clearColor];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        self.colorWheel = [[KZColorPickerHSWheel alloc] initAtOrigin:CGRectMake(5.0f, 0.0f, self.frame.size.height-5.0f, self.frame.size.height-5.0f)];
        [self.colorWheel addTarget:self action:@selector(colorWheelColorChanged:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:self.colorWheel];
        
        
        // brightness slider
        self.brightnessSlider = [[KZColorPickerBrightnessSlider alloc] initWithFrame:CGRectMake(self.frame.size.height+5.0f,
                                                                                                                0.0f,
                                                                                                                20.0f,
                                                                                                                self.frame.size.height-5.0f)];
        [self.brightnessSlider addTarget:self action:@selector(brightnessChanged:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:self.brightnessSlider];

        
        self.alphaSlider = [[KZColorPickerAlphaSlider alloc] initWithFrame:CGRectMake(self.frame.size.height+32.0f,
                                                                                                     0.0f,
                                                                                                     20.0f,
                                                                                                     self.frame.size.height-5.0f)];
        [self.alphaSlider addTarget:self action:@selector(alphaChanged:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:self.alphaSlider];
    }
    else
    {
        self.colorWheel = [[KZColorPickerHSWheel alloc] initAtOrigin:CGRectMake(5.0f, 0.0f, self.frame.size.height, self.frame.size.height-5.0f)];
        [self.colorWheel addTarget:self action:@selector(colorWheelColorChanged:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:self.colorWheel];
        
        // brightness slider
        self.brightnessSlider = [[KZColorPickerBrightnessSlider alloc] initWithFrame:CGRectMake(self.frame.size.height+10.0f,
                                                                                                                0.0f,
                                                                                                                20.0f,
                                                                                                                self.frame.size.height-5.0f)];
        [self.brightnessSlider addTarget:self action:@selector(brightnessChanged:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:self.brightnessSlider];
        
        self.alphaSlider = [[KZColorPickerAlphaSlider alloc] initWithFrame:CGRectMake(self.frame.size.height+40.0f,
                                                                                                     0.0f,
                                                                                                     20.0f,
                                                                                                     self.frame.size.height-5.0f)];
        [self.alphaSlider addTarget:self action:@selector(alphaChanged:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:self.alphaSlider];
    }

}

-(id) initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
	{
        // Initialization code
		[self setup];
    }
    return self;
}


-(void) awakeFromNib
{
	[self setup];
    [super awakeFromNib];
}

-(void) hideAlphaSlider
{
    self.alphaSlider.hidden = YES;
}

RGBType rgbWithUIColor(UIColor *color)
{
	const CGFloat *components = CGColorGetComponents(color.CGColor);
	
	CGFloat r,g,b;
	
	switch (CGColorSpaceGetModel(CGColorGetColorSpace(color.CGColor))) 
	{
		case kCGColorSpaceModelMonochrome:
			r = g = b = components[0];
			break;
		case kCGColorSpaceModelRGB:
			r = components[0];
			g = components[1];
			b = components[2];
			break;
		default:	// We don't know how to handle this model
			return RGBTypeMake(1, 1, 1);
	}
	
	return RGBTypeMake(r, g, b);
}

-(void) setSelectedColor:(UIColor *)color animated:(BOOL)animated
{
	if (animated) 
	{
		[UIView beginAnimations:nil context:nil];
		self.selectedColor = color;
		[UIView commitAnimations];
	}
	else 
	{
		self.selectedColor = color;
	}
}

-(void) setOldColor:(UIColor *)col
{
    _oldColor = col;
}

-(void) setSelectedColor:(UIColor *)c
{
	selectedColor = c;
	
	RGBType rgb = rgbWithUIColor(c);
	HSVType hsv = RGB_to_HSV(rgb);
	
	self.colorWheel.currentHSV = hsv;
	self.brightnessSlider.value = hsv.v;
    self.alphaSlider.value = [c alpha];

    UIColor *keyColor = [UIColor colorWithHue:hsv.h 
                                   saturation:hsv.s
                                   brightness:1.0
                                        alpha:1.0];
	[self.brightnessSlider setKeyColor:keyColor];
    
    keyColor = [UIColor colorWithHue:hsv.h
                          saturation:hsv.s
                          brightness:hsv.v
                               alpha:1.0];
    [self.alphaSlider setKeyColor:keyColor];

    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

-(void) colorWheelColorChanged:(KZColorPickerHSWheel *)wheel
{
	HSVType hsv = wheel.currentHSV;
	self.selectedColor = [UIColor colorWithHue:hsv.h
									saturation:hsv.s
									brightness:self.brightnessSlider.value
										 alpha:self.alphaSlider.value];
}

-(void) brightnessChanged:(KZColorPickerBrightnessSlider *)slider
{
	HSVType hsv = self.colorWheel.currentHSV;
	self.selectedColor = [UIColor colorWithHue:hsv.h
									saturation:hsv.s
									brightness:self.brightnessSlider.value
										 alpha:self.alphaSlider.value];
}

-(void) alphaChanged:(KZColorPickerAlphaSlider *)slider
{
	HSVType hsv = self.colorWheel.currentHSV;
	
	self.selectedColor = [UIColor colorWithHue:hsv.h
									saturation:hsv.s
									brightness:self.brightnessSlider.value
										 alpha:self.alphaSlider.value];
}

-(void) layoutSubviews
{
    [UIView beginAnimations:nil context:nil];
    
    [UIView commitAnimations];
}

@end
