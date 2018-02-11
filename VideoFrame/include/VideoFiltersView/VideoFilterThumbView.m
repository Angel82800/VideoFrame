//
//  VideoFilterThumbView.m
//  VideoFrame
//
//  Created by Yinjing Li on 02/20/15.
//  Copyright (c) 2015 Yinjing Li. All rights reserved.
//

#import "VideoFilterThumbView.h"
#import "SHKActivityIndicator.h"
#import "Definition.h"
#import "UIImageExtras.h"


@implementation VideoFilterThumbView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        CGRect thumbBtnFrame = CGRectZero;
        CGRect nameLabelFrame = CGRectZero;
        CGFloat fontsize = 1.0f;
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        {
            thumbBtnFrame = CGRectMake(0.0f, 0.0f, 60.0f, 60.0f);
            nameLabelFrame = CGRectMake(0.0f, 65.0f, 60.0f, 15.0f);
            fontsize = 9.0f;
        }
        else
        {
            thumbBtnFrame = CGRectMake(0.0f, 0.0f, 90.0f, 90.0f);
            nameLabelFrame = CGRectMake(0.0f, 95.0f, 90.0f, 25.0f);
            fontsize = 15.0f;
        }
        

        self.backgroundColor = [UIColor clearColor];
        
        self.videoThumbImageView = [[UIImageView alloc] initWithFrame:thumbBtnFrame];
        self.videoThumbImageView.backgroundColor = [UIColor clearColor];
        self.videoThumbImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.videoThumbImageView.layer.borderColor = [UIColor whiteColor].CGColor;
        self.videoThumbImageView.layer.borderWidth = 1.0f;
        self.videoThumbImageView.layer.cornerRadius = 5.0f;
        self.videoThumbImageView.layer.masksToBounds = YES;
        self.videoThumbImageView.userInteractionEnabled = YES;
        [self addSubview:self.videoThumbImageView];

        UITapGestureRecognizer *selectGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSelected:)];
        selectGesture.delegate = self;
        [self.videoThumbImageView addGestureRecognizer:selectGesture];
        [selectGesture setNumberOfTapsRequired:1];

        self.filterNameLabel = [[UILabel alloc] initWithFrame:nameLabelFrame];
        [self.filterNameLabel setTextColor:[UIColor whiteColor]];
        [self.filterNameLabel setBackgroundColor:[UIColor blackColor]];
        [self.filterNameLabel setFont:[UIFont fontWithName:MYRIADPRO size:fontsize]];
        [self.filterNameLabel setTextAlignment:NSTextAlignmentCenter];
        [self.filterNameLabel setMinimumScaleFactor:0.1f];
        self.filterNameLabel.adjustsFontSizeToFitWidth = YES;
        [self addSubview:self.filterNameLabel];
        self.filterNameLabel.layer.borderColor = [UIColor whiteColor].CGColor;
        self.filterNameLabel.layer.borderWidth = 1.0f;
        self.filterNameLabel.layer.cornerRadius = 2.0f;
        self.filterNameLabel.layer.masksToBounds = YES;
    }
    
    return self;
}

-(void) setIndex:(NSInteger) index
{
    self.filterIndex = index;
    
    switch (index)
    {
        case GPUIMAGE_NONE: self.filterNameLabel.text = @"Original"; break;
        case GPUIMAGE_SATURATION: self.filterNameLabel.text = @"Saturation"; break;
        case GPUIMAGE_CONTRAST: self.filterNameLabel.text = @"Contrast"; break;
        case GPUIMAGE_BRIGHTNESS: self.filterNameLabel.text = @"Brightness"; break;
        case GPUIMAGE_LEVELS: self.filterNameLabel.text = @"Levels"; break;
        case GPUIMAGE_EXPOSURE: self.filterNameLabel.text = @"Exposure"; break;
        case GPUIMAGE_RGB: self.filterNameLabel.text = @"RGB"; break;
        case GPUIMAGE_HUE: self.filterNameLabel.text = @"Hue"; break;
        case GPUIMAGE_COLORINVERT: self.filterNameLabel.text = @"Color invert"; break;
        case GPUIMAGE_WHITEBALANCE: self.filterNameLabel.text = @"White balance"; break;
        case GPUIMAGE_MONOCHROME: self.filterNameLabel.text = @"Monochrome"; break;
        case GPUIMAGE_SHARPEN: self.filterNameLabel.text = @"Sharpen"; break;
        case GPUIMAGE_UNSHARPMASK: self.filterNameLabel.text = @"Unsharp mask"; break;
        case GPUIMAGE_GAMMA: self.filterNameLabel.text = @"Gamma"; break;
        case GPUIMAGE_TONECURVE: self.filterNameLabel.text = @"Tone curve"; break;
        case GPUIMAGE_HIGHLIGHTSHADOW: self.filterNameLabel.text = @"Highlights and shadows"; break;
        case GPUIMAGE_HAZE: self.filterNameLabel.text = @"Haze"; break;
        case GPUIMAGE_GRAYSCALE: self.filterNameLabel.text = @"Grayscale"; break;
        case GPUIMAGE_SEPIA: self.filterNameLabel.text = @"Sepia tone"; break;
        case GPUIMAGE_SKETCH: self.filterNameLabel.text = @"Sketch"; break;
        case GPUIMAGE_SMOOTHTOON: self.filterNameLabel.text = @"Smooth toon"; break;
        case GPUIMAGE_TILTSHIFT: self.filterNameLabel.text = @"Tilt shift"; break;
        case GPUIMAGE_EMBOSS: self.filterNameLabel.text = @"Emboss"; break;
        case GPUIMAGE_POSTERIZE: self.filterNameLabel.text = @"Posterize"; break;
        case GPUIMAGE_PINCH: self.filterNameLabel.text = @"Pinch"; break;
        case GPUIMAGE_VIGNETTE: self.filterNameLabel.text = @"Vignette"; break;
        case GPUIMAGE_GAUSSIAN: self.filterNameLabel.text = @"Gaussian blur"; break;
        case GPUIMAGE_GAUSSIAN_SELECTIVE: self.filterNameLabel.text = @"Gaussian selective blur"; break;
        case GPUIMAGE_GAUSSIAN_POSITION: self.filterNameLabel.text = @"Gaussian (centered)"; break;
    }
}

-(void) setVideoThumbImage:(UIImage*) image
{
    [self.videoThumbImageView setImage:image];
}

-(void) enableThumbBorder
{
    self.videoThumbImageView.layer.borderColor = [UIColor yellowColor].CGColor;
    self.videoThumbImageView.layer.borderWidth = 3.0f;

    self.filterNameLabel.layer.borderColor = [UIColor yellowColor].CGColor;
    [self.filterNameLabel setBackgroundColor:[UIColor grayColor]];
}

-(void) disableThumbBorder
{
    self.videoThumbImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.videoThumbImageView.layer.borderWidth = 1.0f;
    
    self.filterNameLabel.layer.borderColor = [UIColor whiteColor].CGColor;
    [self.filterNameLabel setBackgroundColor:[UIColor blackColor]];
}

-(void)onSelected:(UITapGestureRecognizer *)gestureRecognizer
{
    if ([self.delegate respondsToSelector:@selector(selectedFilterThumb:)])
    {
        [self.delegate selectedFilterThumb:self.filterIndex];
    }
}


@end


