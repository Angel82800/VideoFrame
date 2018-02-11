//
//  KZColorPickerWheel.m
//  VideoFrame
//
//  Created by Yinjing Li on 3/6/14.
//  Copyright (c) 2014 Yinjing Li. All rights reserved.
//


#import <QuartzCore/QuartzCore.h>

#import "KZColorPickerHSWheel.h"


@interface KZColorPickerHSWheel()
@property (nonatomic, strong) UIImageView *wheelImageView;
@property (nonatomic, strong) UIImageView *wheelKnobView;
@end


@implementation KZColorPickerHSWheel

@synthesize wheelImageView;
@synthesize wheelKnobView;
@synthesize currentHSV;

-(id) initAtOrigin:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
	{
        // Initialization code
		// add the imageView for the color wheel
        UIImageView *wheel = [[UIImageView alloc] initWithFrame:self.bounds];
        [wheel setImage:[UIImage imageNamed:@"pickerColorWheel"]];
		wheel.contentMode = UIViewContentModeScaleToFill;
		[self addSubview:wheel];
		self.wheelImageView = wheel;
        
        UIImageView *wheelKnob = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 25.0f, 25.0f)];
        [wheelKnob setImage:[UIImage imageNamed:@"colorPickerKnob"]];
		[self addSubview:wheelKnob];
        wheelKnob.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
		self.wheelKnobView = wheelKnob;
		
		self.userInteractionEnabled = YES;		
		self.currentHSV = HSVTypeMake(0, 0, 1);
    }
    return self;
}

-(void) mapPointToColor:(CGPoint) point
{	
	CGPoint center = CGPointMake(self.wheelImageView.bounds.size.width * 0.5, 
								 self.wheelImageView.bounds.size.height * 0.5);
    double radius = self.wheelImageView.bounds.size.width * 0.5;
    double dx = ABS(point.x - center.x);
    double dy = ABS(point.y - center.y);
    double angle = atan(dy / dx);
	if (isnan(angle))
		angle = 0.0;
	
    double dist = sqrt(pow(dx, 2) + pow(dy, 2));
    double saturation = MIN(dist/radius, 1.0);
	
	if (dist < 10)
        saturation = 0; // snap to center	
	
    if (point.x < center.x)
        angle = M_PI - angle;
	
    if (point.y > center.y)
        angle = 2.0 * M_PI - angle;
	
	self.currentHSV = HSVTypeMake(angle / (2.0 * M_PI), saturation, 1.0);	
	[self sendActionsForControlEvents:UIControlEventValueChanged];
}

-(void) setCurrentHSV:(HSVType)hsv
{
	currentHSV = hsv;
	currentHSV.v = 0.0;
	double angle = currentHSV.h * 2.0 * M_PI;
	CGPoint center = CGPointMake(self.wheelImageView.bounds.size.width * 0.5, 
								 self.wheelImageView.bounds.size.height * 0.5);
	double radius = self.wheelImageView.bounds.size.width * 0.5 - 3.0f;
	radius *= currentHSV.s;
	
	CGFloat x = center.x + cosf(angle) * radius;
	CGFloat y = center.y - sinf(angle) * radius;
	
	x = roundf(x - self.wheelKnobView.bounds.size.width * 0.5) + self.wheelKnobView.bounds.size.width * 0.5;
	y = roundf(y - self.wheelKnobView.bounds.size.height * 0.5) + self.wheelKnobView.bounds.size.height * 0.5;
	self.wheelKnobView.center = CGPointMake(x + self.wheelImageView.frame.origin.x, y + self.wheelImageView.frame.origin.y);
}

-(CGFloat) hue
{
	return currentHSV.h;
}

-(CGFloat) saturation
{
	return currentHSV.s;
}

-(CGFloat) brightness
{
	return currentHSV.v;
}

#pragma mark -
#pragma mark Touches
-(BOOL) beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
	CGPoint mousepoint = [touch locationInView:self];
	if (!CGRectContainsPoint(self.wheelImageView.frame, mousepoint)) 
		return NO;
	
	[self mapPointToColor:[touch locationInView:self.wheelImageView]];
	return YES;
}

-(BOOL) continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
	[self mapPointToColor:[touch locationInView:self.wheelImageView]];
	return YES;
}

-(void) endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
	[self continueTrackingWithTouch:touch withEvent:event];
}

@end
