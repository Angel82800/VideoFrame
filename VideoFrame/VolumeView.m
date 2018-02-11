//
//  VolumeView.m
//  VideoFrame
//
//  Created by Yinjing Li on 5/2/14.
//  Copyright (c) 2014 Yinjing Li. All rights reserved.
//

#import "VolumeView.h"
#import "Definition.h"

@implementation VolumeView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        // title label
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 10.0f, self.frame.size.width, 30)];
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.text = @"Volume";
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
        
        self.volumeSlider = [[UISlider alloc] initWithFrame:CGRectMake(25, 45, self.frame.size.width - 60, 20)];
        [self.volumeSlider setMinimumTrackImage:minImage forState:UIControlStateNormal];
        [self.volumeSlider setMaximumTrackImage:maxImage forState:UIControlStateNormal];
        [self.volumeSlider setThumbImage:tumbImage forState:UIControlStateNormal];
        [self.volumeSlider setThumbImage:tumbImage forState:UIControlStateHighlighted];
        [self.volumeSlider setMinimumValue:0.0f];
        [self.volumeSlider setMaximumValue:1.0f];
        [self.volumeSlider setValue:1.0f];
        [self addSubview:self.volumeSlider];
        [self.volumeSlider addTarget:self action:@selector(changeVolumeSlider:) forControlEvents:UIControlEventValueChanged];

        UIImageView* minVolumeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5.0f, 45, 25, 20)];
        [minVolumeImageView setImage:[UIImage imageNamed:@"player_icon_vol_off_ipad"]];
        minVolumeImageView.backgroundColor = [UIColor clearColor];
        [self addSubview:minVolumeImageView];

        UIImageView* maxVolumeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width-30.0f, 45, 25, 20)];
        [maxVolumeImageView setImage:[UIImage imageNamed:@"player_icon_vol_ipad"]];
        maxVolumeImageView.backgroundColor = [UIColor clearColor];
        [self addSubview:maxVolumeImageView];
    }
    
    return self;
}

-(void) changeVolumeSlider:(id) sender
{
    if ([self.delegate respondsToSelector:@selector(changeVolume:)])
    {
        [self.delegate changeVolume:self.volumeSlider.value];
    }

}

-(void) setVolumeValue:(CGFloat) value
{
    [self.volumeSlider setValue:value];
}

@end
