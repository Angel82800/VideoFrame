//
//  PhotoFilterThumbView.m
//  VideoFrame
//
//  Created by Yinjing Li on 6/20/14.
//  Copyright (c) 2014 Yinjing Li. All rights reserved.
//

#import "PhotoFilterThumbView.h"
#import "SHKActivityIndicator.h"
#import "Definition.h"
#import "UIImageExtras.h"


@implementation PhotoFilterThumbView


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
        
        self.thumbImageView = [[UIImageView alloc] initWithFrame:thumbBtnFrame];
        self.thumbImageView.backgroundColor = [UIColor clearColor];
        self.thumbImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.thumbImageView.layer.borderColor = [UIColor whiteColor].CGColor;
        self.thumbImageView.layer.borderWidth = 1.0f;
        self.thumbImageView.layer.cornerRadius = 5.0f;
        self.thumbImageView.layer.masksToBounds = YES;
        self.thumbImageView.userInteractionEnabled = YES;
        [self addSubview:self.thumbImageView];

        UITapGestureRecognizer *selectGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSelected:)];
        selectGesture.delegate = self;
        [self.thumbImageView addGestureRecognizer:selectGesture];
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

-(void) setName:(NSString*) name
{
    self.filterName = name;
    self.filterNameLabel.text = self.filterName;
}

-(void) setIndex:(NSInteger) index
{
    self.filterIndex = index;
}

-(void) setThumbImage:(UIImage*) image
{
    [self.thumbImageView setImage:image];
}

-(void) enableThumbBorder
{
    self.thumbImageView.layer.borderColor = [UIColor yellowColor].CGColor;
    self.thumbImageView.layer.borderWidth = 3.0f;

    self.filterNameLabel.layer.borderColor = [UIColor yellowColor].CGColor;
    [self.filterNameLabel setBackgroundColor:[UIColor grayColor]];
}

-(void) desableThumbBorder
{
    self.thumbImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.thumbImageView.layer.borderWidth = 1.0f;
    
    self.filterNameLabel.layer.borderColor = [UIColor whiteColor].CGColor;
    [self.filterNameLabel setBackgroundColor:[UIColor blackColor]];
}

-(void)onSelected:(UITapGestureRecognizer *)gestureRecognizer
{
    if ([self.delegate respondsToSelector:@selector(selectedFilter:)])
    {
        [self.delegate selectedFilter:self.filterIndex];
    }
}


@end


