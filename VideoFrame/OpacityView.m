//
//  OpacityView.m
//  VideoFrame
//
//  Created by Yinjing Li on 5/2/14.
//  Copyright (c) 2014 Yinjing Li. All rights reserved.
//

#import "OpacityView.h"

@implementation OpacityView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        // title label
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 10.0f, self.frame.size.width, 30)];
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.text = @"Opacity";
        self.titleLabel.font = [UIFont fontWithName:MYRIADPRO size:15];
        self.titleLabel.adjustsFontSizeToFitWidth = YES;
        self.titleLabel.minimumScaleFactor = 0.1f;
        self.titleLabel.numberOfLines = 0;
        self.titleLabel.textColor = [UIColor whiteColor];
        [self addSubview:self.titleLabel];
        
        
        UIImage *minImage = [UIImage imageNamed:@"slider_min"];
        UIImage *maxImage = [UIImage imageNamed:@"slider_max"];
        UIImage *tumbImage = nil;
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
            tumbImage= [UIImage imageNamed:@"slider_thumb"];
        else
            tumbImage= [UIImage imageNamed:@"slider_thumb_ipad"];
        
        minImage=[minImage stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0];
        maxImage=[maxImage stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0];
        
        self.opacitySlider = [[UISlider alloc] initWithFrame:CGRectMake(30, 45, self.frame.size.width - 60, 20)];
        [self.opacitySlider setMinimumTrackImage:minImage forState:UIControlStateNormal];
        [self.opacitySlider setMaximumTrackImage:maxImage forState:UIControlStateNormal];
        [self.opacitySlider setThumbImage:tumbImage forState:UIControlStateNormal];
        [self.opacitySlider setThumbImage:tumbImage forState:UIControlStateHighlighted];
        
        [self.opacitySlider setMinimumValue:0.0f];
        [self.opacitySlider setMaximumValue:1.0f];
        [self.opacitySlider setValue:1.0f];
        [self addSubview:self.opacitySlider];
        [self.opacitySlider addTarget:self action:@selector(changeOpacitySlider:) forControlEvents:UIControlEventValueChanged];

        UILabel* minLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 45, 30, 20)];
        minLabel.backgroundColor = [UIColor clearColor];
        minLabel.textAlignment = NSTextAlignmentCenter;
        minLabel.text = @"0%";
        minLabel.font = [UIFont fontWithName:MYRIADPRO size:15];
        minLabel.adjustsFontSizeToFitWidth = YES;
        minLabel.minimumScaleFactor = 0.1f;
        minLabel.numberOfLines = 0;
        minLabel.textColor = [UIColor whiteColor];
        [self addSubview:minLabel];

        UILabel* maxLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width-30.0f, 45, 30, 20)];
        maxLabel.backgroundColor = [UIColor clearColor];
        maxLabel.textAlignment = NSTextAlignmentCenter;
        maxLabel.text = @"100%";
        maxLabel.font = [UIFont fontWithName:MYRIADPRO size:15];
        maxLabel.adjustsFontSizeToFitWidth = YES;
        maxLabel.minimumScaleFactor = 0.1f;
        maxLabel.numberOfLines = 0;
        maxLabel.textColor = [UIColor whiteColor];
        [self addSubview:maxLabel];
    }
    
    return self;
}


-(void) changeOpacitySlider:(id) sender
{
    if ([self.delegate respondsToSelector:@selector(changeOpacity:)])
    {
        [self.delegate changeOpacity:self.opacitySlider.value];
    }
}

-(void) setOpacityValue:(CGFloat) value
{
    [self.opacitySlider setValue:value];
}

@end
