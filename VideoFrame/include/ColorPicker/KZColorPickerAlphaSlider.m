//
//  KZColorPickerAlphaSlider.m
//  VideoFrame
//
//  Created by Yinjing Li on 3/6/14.
//  Copyright (c) 2014 Yinjing Li. All rights reserved.
//

#import "KZColorPickerAlphaSlider.h"


@implementation KZColorPickerAlphaSlider

-(id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) 
    {
        // Initialization code
        checkerboard = [[UIView alloc] initWithFrame:self.bounds];
        checkerboard.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"checkerboard"]];
        checkerboard.layer.cornerRadius = 6.0;
        checkerboard.clipsToBounds = YES;
        checkerboard.userInteractionEnabled = NO;
        [self addSubview:checkerboard];
        
        gradientLayer = [[CAGradientLayer alloc] init];
        gradientLayer.bounds = self.bounds;
        gradientLayer.position = CGPointMake(checkerboard.bounds.size.width * 0.5, checkerboard.bounds.size.height * 0.5);
		gradientLayer.cornerRadius = 6.0;
		gradientLayer.borderWidth = 2.0;
		gradientLayer.borderColor = [[UIColor whiteColor] CGColor];
        
		if ([self respondsToSelector:@selector(contentScaleFactor)])
			self.contentScaleFactor = [[UIScreen mainScreen] scale];
        
        gradientLayer.startPoint = CGPointMake(0.5, 0.0);
        gradientLayer.endPoint = CGPointMake(0.5, 1.0);
        [checkerboard.layer addSublayer:gradientLayer];
        
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
							 (id)[c colorWithAlphaComponent:0.0].CGColor,		 		 
							 nil];
	[CATransaction commit];
}

-(void) setFrame:(CGRect)frame
{
    [super setFrame:frame];
    gradientLayer.bounds = self.bounds;
    checkerboard.frame = gradientLayer.bounds;
    gradientLayer.position = CGPointMake(checkerboard.bounds.size.width * 0.5, checkerboard.bounds.size.height * 0.5);
    self.value = self.value;
}

@end
