//
//  KZUnitSlider.m
//  VideoFrame
//
//  Created by Yinjing Li on 3/6/14.
//  Copyright (c) 2014 Yinjing Li. All rights reserved.
//

#import "KZUnitSlider.h"

#define ROUND_WIDTH 25.0f



@implementation KZUnitSlider


-(id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) 
    {
        horizontal = frame.size.width > frame.size.height;
		
        UIImageView *knob = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, ROUND_WIDTH, ROUND_WIDTH)];
        [knob setImage:[UIImage imageNamed:@"colorPickerKnob"]];
        [self addSubview:knob];
        knob.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
        self.sliderKnobView = knob;
		
		self.backgroundColor = [UIColor clearColor];
		self.userInteractionEnabled = YES;
		self.value = 0.0;
    }
    return self;
}

-(CGFloat) value
{
	return value;
}

-(void) setValue:(CGFloat)val
{	
	value = MAX(MIN(val, 1.0), 0.0);
	
	CGFloat x = horizontal ? 
    roundf((1 - value) * (self.frame.size.width - 10.0f) - self.sliderKnobView.bounds.size.width * 0.5) + self.sliderKnobView.bounds.size.width * 0.5:
    roundf((self.bounds.size.width - self.sliderKnobView.bounds.size.width) * 0.5) + self.sliderKnobView.bounds.size.width * 0.5;
    
	CGFloat y = horizontal ?
    roundf((self.bounds.size.height - self.sliderKnobView.bounds.size.height) * 0.5) + self.sliderKnobView.bounds.size.height * 0.5:
    roundf((1 - value) * (self.frame.size.height - 10.0f) - self.sliderKnobView.bounds.size.height * 0.5) + self.sliderKnobView.bounds.size.height * 0.5;
	
    if(horizontal)
        x += 5;
    else
        y += 5;
    
	self.sliderKnobView.center = CGPointMake(x, y);
}

-(void) mapPointToValue:(CGPoint)point
{
	CGFloat val = horizontal ? 1 - ((point.x - 5) / (self.frame.size.width - 10.0f)) : 1 - ((point.y - 5) / (self.frame.size.height - 10.0f));
	self.value = val;
	
	[self sendActionsForControlEvents:UIControlEventValueChanged];
}

-(BOOL) beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
	[self mapPointToValue:[touch locationInView:self]];
	return YES;
}

-(BOOL) continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
	[self mapPointToValue:[touch locationInView:self]];
	return YES;
}

-(void) endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
	[self continueTrackingWithTouch:touch withEvent:event];
}

-(void) didAddSubview:(UIView *)subview
{
    [self bringSubviewToFront:self.sliderKnobView];
}

@end
