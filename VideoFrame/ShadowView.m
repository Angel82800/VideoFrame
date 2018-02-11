//
//  ShadowView.h
//  VideoFrame
//
//  Created by Yinjing Li on 3/6/14.
//  Copyright (c) 2014 Yinjing Li. All rights reserved.
//


#import "ShadowView.h"
#import <QuartzCore/QuartzCore.h>

@implementation ShadowView


#pragma mark - init

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        
        self.objectShadowColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
        
        CGFloat rFontSize = 0.0f;
    
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
            rFontSize = 10.0f;
        else
            rFontSize = 14.0f;

        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        {
            //no shadow button
            self.noShadowBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [self.noShadowBtn setFrame:CGRectMake(0.0f, 0.0f, self.frame.size.width*0.4f, 35.0f)];
            [self.noShadowBtn setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
            self.noShadowBtn.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
            [self.noShadowBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
            self.noShadowBtn.backgroundColor = [UIColor clearColor];
            [self setSelectedBackgroundViewFor:self.noShadowBtn];
            self.noShadowBtn.layer.masksToBounds = YES;
            [self.noShadowBtn setTitle:@"NO SHADOW" forState:UIControlStateNormal];
            self.noShadowBtn.titleLabel.font = [UIFont fontWithName:MYRIADPRO size:rFontSize];
            self.noShadowBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
            self.noShadowBtn.titleLabel.minimumScaleFactor = 0.1f;
            self.noShadowBtn.titleLabel.numberOfLines = 0;
            self.noShadowBtn.layer.borderColor = [UIColor whiteColor].CGColor;
            self.noShadowBtn.layer.borderWidth = 1.0f;
            self.noShadowBtn.layer.cornerRadius = 1.0f;
            [self.noShadowBtn addTarget:self action:@selector(selectNoShadow:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:self.noShadowBtn];

            //shadow button
            self.shadowBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [self.shadowBtn setFrame:CGRectMake(0.0f, 35.0f, self.frame.size.width*0.4f, 35.0f)];
            [self.shadowBtn setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
            self.shadowBtn.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
            [self.shadowBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
            self.shadowBtn.backgroundColor = [UIColor clearColor];
            [self setSelectedBackgroundViewFor:self.shadowBtn];
            self.shadowBtn.layer.masksToBounds = YES;
            [self.shadowBtn setTitle:@"SHADOW" forState:UIControlStateNormal];
            self.shadowBtn.titleLabel.font = [UIFont fontWithName:MYRIADPRO size:rFontSize];
            self.shadowBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
            self.shadowBtn.titleLabel.minimumScaleFactor = 0.1f;
            self.shadowBtn.titleLabel.numberOfLines = 0;
            self.shadowBtn.layer.borderColor = [UIColor whiteColor].CGColor;
            self.shadowBtn.layer.borderWidth = 1.0f;
            self.shadowBtn.layer.cornerRadius = 1.0f;
            [self.shadowBtn addTarget:self action:@selector(selectShadow:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:self.shadowBtn];

            //shadow width(blur) view
            self.shadowWidthView = [[UIView alloc] initWithFrame:CGRectMake(0, 70.0f, self.frame.size.width, 40.0f)];
            self.shadowWidthView.backgroundColor = [UIColor clearColor];
            self.shadowWidthView.layer.borderWidth = 1.0f;
            self.shadowWidthView.layer.borderColor = [UIColor whiteColor].CGColor;
            [self addSubview:self.shadowWidthView];
            
            self.shadowWidthTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0f, 0.0f, self.frame.size.width-5.0f, 20.0f)];
            self.shadowWidthTitleLabel.backgroundColor = [UIColor clearColor];
            self.shadowWidthTitleLabel.textAlignment = NSTextAlignmentLeft;
            self.shadowWidthTitleLabel.text = [NSString stringWithFormat:@"Blur : %.1fpx", self.objectShadowBlur];
            self.shadowWidthTitleLabel.font = [UIFont fontWithName:MYRIADPRO size:rFontSize];
            self.shadowWidthTitleLabel.adjustsFontSizeToFitWidth = YES;
            self.shadowWidthTitleLabel.minimumScaleFactor = 0.1f;
            self.shadowWidthTitleLabel.numberOfLines = 0;
            self.shadowWidthTitleLabel.textColor = [UIColor whiteColor];
            [self.shadowWidthView addSubview:self.shadowWidthTitleLabel];
            
            self.shadowWidthMinPixelLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 18.0f, 40.0f, 20.0f)];
            self.shadowWidthMinPixelLabel.backgroundColor = [UIColor clearColor];
            self.shadowWidthMinPixelLabel.textAlignment = NSTextAlignmentCenter;
            self.shadowWidthMinPixelLabel.text = @"0.0px";
            self.shadowWidthMinPixelLabel.font = [UIFont fontWithName:MYRIADPRO size:rFontSize-2.0f];
            self.shadowWidthMinPixelLabel.adjustsFontSizeToFitWidth = YES;
            self.shadowWidthMinPixelLabel.minimumScaleFactor = 0.1f;
            self.shadowWidthMinPixelLabel.numberOfLines = 0;
            self.shadowWidthMinPixelLabel.textColor = [UIColor whiteColor];
            [self.shadowWidthView addSubview:self.shadowWidthMinPixelLabel];
            
            self.shadowWidthMaxPixelLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width-40.0f, 18.0f, 40.0f, 20.0f)];
            self.shadowWidthMaxPixelLabel.backgroundColor = [UIColor clearColor];
            self.shadowWidthMaxPixelLabel.textAlignment = NSTextAlignmentCenter;
            self.shadowWidthMaxPixelLabel.text = @"100.0px";
            self.shadowWidthMaxPixelLabel.font = [UIFont fontWithName:MYRIADPRO size:rFontSize-2.0f];
            self.shadowWidthMaxPixelLabel.adjustsFontSizeToFitWidth = YES;
            self.shadowWidthMaxPixelLabel.minimumScaleFactor = 0.1f;
            self.shadowWidthMaxPixelLabel.numberOfLines = 0;
            self.shadowWidthMaxPixelLabel.textColor = [UIColor whiteColor];
            [self.shadowWidthView addSubview:self.shadowWidthMaxPixelLabel];
            
            self.shadowWidthSlider = [[KZColorPickerWidthSlider alloc] initWithFrame:CGRectMake(40.0f,
                                                                                                 18.0f,
                                                                                                 self.frame.size.width-80.0f,
                                                                                                 20.0f)];
            [self.shadowWidthSlider addTarget:self action:@selector(shadowWidthChanged:) forControlEvents:UIControlEventValueChanged];
            [self.shadowWidthView addSubview:self.shadowWidthSlider];

            //shadow offset view
            self.shadowOffsetView = [[UIView alloc] initWithFrame:CGRectMake(0, 110.0f, self.frame.size.width, 40.0f)];
            self.shadowOffsetView.backgroundColor = [UIColor clearColor];
            self.shadowOffsetView.layer.borderWidth = 1.0f;
            self.shadowOffsetView.layer.borderColor = [UIColor whiteColor].CGColor;
            [self addSubview:self.shadowOffsetView];
            
            self.shadowOffsetTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0f, 0.0f, self.frame.size.width-5.0f, 20.0f)];
            self.shadowOffsetTitleLabel.backgroundColor = [UIColor clearColor];
            self.shadowOffsetTitleLabel.textAlignment = NSTextAlignmentLeft;
            self.shadowOffsetTitleLabel.text = [NSString stringWithFormat:@"Offset : %.1fpx", self.objectShadowBlur];
            self.shadowOffsetTitleLabel.font = [UIFont fontWithName:MYRIADPRO size:rFontSize];
            self.shadowOffsetTitleLabel.adjustsFontSizeToFitWidth = YES;
            self.shadowOffsetTitleLabel.minimumScaleFactor = 0.1f;
            self.shadowOffsetTitleLabel.numberOfLines = 0;
            self.shadowOffsetTitleLabel.textColor = [UIColor whiteColor];
            [self.shadowOffsetView addSubview:self.shadowOffsetTitleLabel];
            
            self.shadowOffsetMinPixelLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 18.0f, 40.0f, 20.0f)];
            self.shadowOffsetMinPixelLabel.backgroundColor = [UIColor clearColor];
            self.shadowOffsetMinPixelLabel.textAlignment = NSTextAlignmentCenter;
            self.shadowOffsetMinPixelLabel.text = @"0.0px";
            self.shadowOffsetMinPixelLabel.font = [UIFont fontWithName:MYRIADPRO size:rFontSize-2.0f];
            self.shadowOffsetMinPixelLabel.adjustsFontSizeToFitWidth = YES;
            self.shadowOffsetMinPixelLabel.minimumScaleFactor = 0.1f;
            self.shadowOffsetMinPixelLabel.numberOfLines = 0;
            self.shadowOffsetMinPixelLabel.textColor = [UIColor whiteColor];
            [self.shadowOffsetView addSubview:self.shadowOffsetMinPixelLabel];
            
            self.shadowOffsetMaxPixelLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width-40.0f, 18.0f, 40.0f, 20.0f)];
            self.shadowOffsetMaxPixelLabel.backgroundColor = [UIColor clearColor];
            self.shadowOffsetMaxPixelLabel.textAlignment = NSTextAlignmentCenter;
            self.shadowOffsetMaxPixelLabel.text = @"50.0px";
            self.shadowOffsetMaxPixelLabel.font = [UIFont fontWithName:MYRIADPRO size:rFontSize-2.0f];
            self.shadowOffsetMaxPixelLabel.adjustsFontSizeToFitWidth = YES;
            self.shadowOffsetMaxPixelLabel.minimumScaleFactor = 0.1f;
            self.shadowOffsetMaxPixelLabel.numberOfLines = 0;
            self.shadowOffsetMaxPixelLabel.textColor = [UIColor whiteColor];
            [self.shadowOffsetView addSubview:self.shadowOffsetMaxPixelLabel];
            
            self.shadowOffsetSlider = [[KZColorPickerWidthSlider alloc] initWithFrame:CGRectMake(40.0f,
                                                                                                 18.0f,
                                                                                                 self.frame.size.width-80.0f,
                                                                                                 20.0f)];
            [self.shadowOffsetSlider addTarget:self action:@selector(shadowOffsetChanged:) forControlEvents:UIControlEventValueChanged];
            [self.shadowOffsetView addSubview:self.shadowOffsetSlider];

            //shadow color
            self.shadowColorLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0f, 150.0f, self.frame.size.width-5.0f, 20.0f)];
            self.shadowColorLabel.backgroundColor = [UIColor clearColor];
            self.shadowColorLabel.textAlignment = NSTextAlignmentLeft;
            self.shadowColorLabel.text = @"Color";
            self.shadowColorLabel.font = [UIFont fontWithName:MYRIADPRO size:rFontSize];
            self.shadowColorLabel.adjustsFontSizeToFitWidth = YES;
            self.shadowColorLabel.minimumScaleFactor = 0.1f;
            self.shadowColorLabel.numberOfLines = 0;
            self.shadowColorLabel.textColor = [UIColor whiteColor];
            [self addSubview:self.shadowColorLabel];

            //color picker
            self.shadowColorPickerView = [[KZColorPicker alloc] initWithFrame:CGRectMake(0, self.frame.size.height - (self.frame.size.width - 60), self.frame.size.width, self.frame.size.width - 60)];
            self.shadowColorPickerView.selectedColor = self.objectShadowColor;
            self.shadowColorPickerView.oldColor = self.objectShadowColor;
            [self.shadowColorPickerView addTarget:self action:@selector(shadowColorPickerChanged:) forControlEvents:UIControlEventValueChanged];
            [self addSubview:self.shadowColorPickerView];
            
            //leftbox view
            self.leftBoxView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height-30, 30, 30)];
            self.leftBoxView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"leftBox"]];
            self.leftBoxView.userInteractionEnabled = YES;
            [self addSubview:self.leftBoxView];
            
            UIPanGestureRecognizer* moveGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(shadowMenuMove:)];
            [moveGesture setMinimumNumberOfTouches:1];
            [moveGesture setMaximumNumberOfTouches:1];
            moveGesture.delegate = self;
            [self.leftBoxView addGestureRecognizer:moveGesture];
        }
        else
        {
            //no shadow button
            self.noShadowBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [self.noShadowBtn setFrame:CGRectMake(0.0f, 0.0f, self.frame.size.width*0.4f, 57.5f)];
            [self.noShadowBtn setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
            self.noShadowBtn.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
            [self.noShadowBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
            self.noShadowBtn.backgroundColor = [UIColor clearColor];
            [self setSelectedBackgroundViewFor:self.noShadowBtn];
            self.noShadowBtn.layer.masksToBounds = YES;
            [self.noShadowBtn setTitle:@"NO SHADOW" forState:UIControlStateNormal];
            self.noShadowBtn.titleLabel.font = [UIFont fontWithName:MYRIADPRO size:rFontSize];
            self.noShadowBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
            self.noShadowBtn.titleLabel.minimumScaleFactor = 0.1f;
            self.noShadowBtn.titleLabel.numberOfLines = 0;
            self.noShadowBtn.layer.borderColor = [UIColor whiteColor].CGColor;
            self.noShadowBtn.layer.borderWidth = 1.0f;
            self.noShadowBtn.layer.cornerRadius = 1.0f;
            [self.noShadowBtn addTarget:self action:@selector(selectNoShadow:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:self.noShadowBtn];
            
            //shadow button
            self.shadowBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [self.shadowBtn setFrame:CGRectMake(0.0f, 57.5f, self.frame.size.width*0.4f, 57.5f)];
            [self.shadowBtn setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
            self.shadowBtn.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
            [self.shadowBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
            self.shadowBtn.backgroundColor = [UIColor clearColor];
            [self setSelectedBackgroundViewFor:self.shadowBtn];
            self.shadowBtn.layer.masksToBounds = YES;
            [self.shadowBtn setTitle:@"SHADOW" forState:UIControlStateNormal];
            self.shadowBtn.titleLabel.font = [UIFont fontWithName:MYRIADPRO size:rFontSize];
            self.shadowBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
            self.shadowBtn.titleLabel.minimumScaleFactor = 0.1f;
            self.shadowBtn.titleLabel.numberOfLines = 0;
            self.shadowBtn.layer.borderColor = [UIColor whiteColor].CGColor;
            self.shadowBtn.layer.borderWidth = 1.0f;
            self.shadowBtn.layer.cornerRadius = 1.0f;
            [self.shadowBtn addTarget:self action:@selector(selectShadow:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:self.shadowBtn];

            //shadow width view
            self.shadowWidthView = [[UIView alloc] initWithFrame:CGRectMake(0, 115.0f, self.frame.size.width, 50.0f)];
            self.shadowWidthView.backgroundColor = [UIColor clearColor];
            self.shadowWidthView.layer.borderWidth = 1.0f;
            self.shadowWidthView.layer.borderColor = [UIColor whiteColor].CGColor;
            [self addSubview:self.shadowWidthView];
            
            self.shadowWidthTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0f, 0.0f, self.frame.size.width-5.0f, 20.0f)];
            self.shadowWidthTitleLabel.backgroundColor = [UIColor clearColor];
            self.shadowWidthTitleLabel.textAlignment = NSTextAlignmentLeft;
            self.shadowWidthTitleLabel.text = [NSString stringWithFormat:@"Blur : %.1fpx", self.objectShadowBlur];
            self.shadowWidthTitleLabel.font = [UIFont fontWithName:MYRIADPRO size:rFontSize];
            self.shadowWidthTitleLabel.adjustsFontSizeToFitWidth = YES;
            self.shadowWidthTitleLabel.minimumScaleFactor = 0.1f;
            self.shadowWidthTitleLabel.numberOfLines = 0;
            self.shadowWidthTitleLabel.textColor = [UIColor whiteColor];
            [self.shadowWidthView addSubview:self.shadowWidthTitleLabel];
            
            self.shadowWidthMinPixelLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 25.0f, 40.0f, 20.0f)];
            self.shadowWidthMinPixelLabel.backgroundColor = [UIColor clearColor];
            self.shadowWidthMinPixelLabel.textAlignment = NSTextAlignmentCenter;
            self.shadowWidthMinPixelLabel.text = @"0.0px";
            self.shadowWidthMinPixelLabel.font = [UIFont fontWithName:MYRIADPRO size:rFontSize-2.0f];
            self.shadowWidthMinPixelLabel.adjustsFontSizeToFitWidth = YES;
            self.shadowWidthMinPixelLabel.minimumScaleFactor = 0.1f;
            self.shadowWidthMinPixelLabel.numberOfLines = 0;
            self.shadowWidthMinPixelLabel.textColor = [UIColor whiteColor];
            [self.shadowWidthView addSubview:self.shadowWidthMinPixelLabel];

            self.shadowWidthMaxPixelLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width-40.0f, 25.0f, 40.0f, 20.0f)];
            self.shadowWidthMaxPixelLabel.backgroundColor = [UIColor clearColor];
            self.shadowWidthMaxPixelLabel.textAlignment = NSTextAlignmentCenter;
            self.shadowWidthMaxPixelLabel.text = @"100.0px";
            self.shadowWidthMaxPixelLabel.font = [UIFont fontWithName:MYRIADPRO size:rFontSize-2.0f];
            self.shadowWidthMaxPixelLabel.adjustsFontSizeToFitWidth = YES;
            self.shadowWidthMaxPixelLabel.minimumScaleFactor = 0.1f;
            self.shadowWidthMaxPixelLabel.numberOfLines = 0;
            self.shadowWidthMaxPixelLabel.textColor = [UIColor whiteColor];
            [self.shadowWidthView addSubview:self.shadowWidthMaxPixelLabel];

            self.shadowWidthSlider = [[KZColorPickerWidthSlider alloc] initWithFrame:CGRectMake(40.0f,
                                                                                                                    25.0f,
                                                                                                                    self.frame.size.width-80.0f,
                                                                                                                    20.0f)];
            [self.shadowWidthSlider addTarget:self action:@selector(shadowWidthChanged:) forControlEvents:UIControlEventValueChanged];
            [self.shadowWidthView addSubview:self.shadowWidthSlider];

            //shadow offset view
            self.shadowOffsetView = [[UIView alloc] initWithFrame:CGRectMake(0, 165.0f, self.frame.size.width, 50.0f)];
            self.shadowOffsetView.backgroundColor = [UIColor clearColor];
            self.shadowOffsetView.layer.borderWidth = 1.0f;
            self.shadowOffsetView.layer.borderColor = [UIColor whiteColor].CGColor;
            [self addSubview:self.shadowOffsetView];
            
            self.shadowOffsetTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0f, 0.0f, self.frame.size.width-5.0f, 20.0f)];
            self.shadowOffsetTitleLabel.backgroundColor = [UIColor clearColor];
            self.shadowOffsetTitleLabel.textAlignment = NSTextAlignmentLeft;
            self.shadowOffsetTitleLabel.text = [NSString stringWithFormat:@"Offset : %.1fpx", self.objectShadowOffset];
            self.shadowOffsetTitleLabel.font = [UIFont fontWithName:MYRIADPRO size:rFontSize];
            self.shadowOffsetTitleLabel.adjustsFontSizeToFitWidth = YES;
            self.shadowOffsetTitleLabel.minimumScaleFactor = 0.1f;
            self.shadowOffsetTitleLabel.numberOfLines = 0;
            self.shadowOffsetTitleLabel.textColor = [UIColor whiteColor];
            [self.shadowOffsetView addSubview:self.shadowOffsetTitleLabel];
            
            self.shadowOffsetMinPixelLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 25.0f, 40.0f, 20.0f)];
            self.shadowOffsetMinPixelLabel.backgroundColor = [UIColor clearColor];
            self.shadowOffsetMinPixelLabel.textAlignment = NSTextAlignmentCenter;
            self.shadowOffsetMinPixelLabel.text = @"0.0px";
            self.shadowOffsetMinPixelLabel.font = [UIFont fontWithName:MYRIADPRO size:rFontSize-2.0f];
            self.shadowOffsetMinPixelLabel.adjustsFontSizeToFitWidth = YES;
            self.shadowOffsetMinPixelLabel.minimumScaleFactor = 0.1f;
            self.shadowOffsetMinPixelLabel.numberOfLines = 0;
            self.shadowOffsetMinPixelLabel.textColor = [UIColor whiteColor];
            [self.shadowOffsetView addSubview:self.shadowOffsetMinPixelLabel];
            
            self.shadowOffsetMaxPixelLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width-40.0f, 25.0f, 40.0f, 20.0f)];
            self.shadowOffsetMaxPixelLabel.backgroundColor = [UIColor clearColor];
            self.shadowOffsetMaxPixelLabel.textAlignment = NSTextAlignmentCenter;
            self.shadowOffsetMaxPixelLabel.text = @"50.0px";
            self.shadowOffsetMaxPixelLabel.font = [UIFont fontWithName:MYRIADPRO size:rFontSize-2.0f];
            self.shadowOffsetMaxPixelLabel.adjustsFontSizeToFitWidth = YES;
            self.shadowOffsetMaxPixelLabel.minimumScaleFactor = 0.1f;
            self.shadowOffsetMaxPixelLabel.numberOfLines = 0;
            self.shadowOffsetMaxPixelLabel.textColor = [UIColor whiteColor];
            [self.shadowOffsetView addSubview:self.shadowOffsetMaxPixelLabel];
            
            self.shadowOffsetSlider = [[KZColorPickerWidthSlider alloc] initWithFrame:CGRectMake(40.0f,
                                                                                                 25.0f,
                                                                                                 self.frame.size.width-80.0f,
                                                                                                 20.0f)];
            [self.shadowOffsetSlider addTarget:self action:@selector(shadowOffsetChanged:) forControlEvents:UIControlEventValueChanged];
            [self.shadowOffsetView addSubview:self.shadowOffsetSlider];

            //shadow color
            self.shadowColorLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0f, 215.0f, self.frame.size.width-5.0f, 20.0f)];
            self.shadowColorLabel.backgroundColor = [UIColor clearColor];
            self.shadowColorLabel.textAlignment = NSTextAlignmentLeft;
            self.shadowColorLabel.text = @"Color";
            self.shadowColorLabel.font = [UIFont fontWithName:MYRIADPRO size:rFontSize];
            self.shadowColorLabel.adjustsFontSizeToFitWidth = YES;
            self.shadowColorLabel.minimumScaleFactor = 0.1f;
            self.shadowColorLabel.numberOfLines = 0;
            self.shadowColorLabel.textColor = [UIColor whiteColor];
            [self addSubview:self.shadowColorLabel];

            //color picker
            self.shadowColorPickerView = [[KZColorPicker alloc] initWithFrame:CGRectMake(0, self.frame.size.height - (self.frame.size.width - 70), self.frame.size.width, self.frame.size.width - 70)];
            self.shadowColorPickerView.selectedColor = self.objectShadowColor;
            self.shadowColorPickerView.oldColor = self.objectShadowColor;
            [self.shadowColorPickerView addTarget:self action:@selector(shadowColorPickerChanged:) forControlEvents:UIControlEventValueChanged];
            [self addSubview:self.shadowColorPickerView];
            
            //leftbox view
            self.leftBoxView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height-40, 40, 40)];
            self.leftBoxView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"leftBox"]];
            self.leftBoxView.userInteractionEnabled = YES;
            [self addSubview:self.leftBoxView];
            
            UIPanGestureRecognizer* moveGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(shadowMenuMove:)];
            [moveGesture setMinimumNumberOfTouches:1];
            [moveGesture setMaximumNumberOfTouches:1];
            moveGesture.delegate = self;
            [self.leftBoxView addGestureRecognizer:moveGesture];
       }
        
        
        CGFloat originY = 20.0f;
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
            originY = 15.0f;
        
        //color preview
        self.colorPreviewView = [[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width*0.4f + 5.0f, 5.0f, self.frame.size.width*0.2f, originY)];
        self.colorPreviewView.backgroundColor = [UIColor whiteColor];
        self.colorPreviewView.userInteractionEnabled = YES;
        [self addSubview:self.colorPreviewView];
        
        UITapGestureRecognizer *selectGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionColorPreviewToRecent:)];
        selectGesture.delegate = self;
        [self.colorPreviewView addGestureRecognizer:selectGesture];
        [selectGesture setNumberOfTapsRequired:1];
        
        self.addLabel = [[UILabel alloc] initWithFrame:self.colorPreviewView.bounds];
        self.addLabel.backgroundColor = [UIColor clearColor];
        self.addLabel.text = @"+";
        self.addLabel.font = [UIFont fontWithName:MYRIADPRO size:rFontSize*1.2f];
        self.addLabel.adjustsFontSizeToFitWidth = YES;
        self.addLabel.minimumScaleFactor = 0.1f;
        self.addLabel.textAlignment = NSTextAlignmentCenter;
        self.addLabel.textColor = [UIColor whiteColor];
        self.addLabel.layer.shadowColor = [UIColor blackColor].CGColor;
        self.addLabel.layer.shadowOffset = CGSizeMake(0.5f, 0.5f);
        self.addLabel.layer.shadowOpacity = 1.0f;
        [self.colorPreviewView addSubview:self.addLabel];
        
        self.xLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.colorPreviewView.frame.origin.x + self.colorPreviewView.frame.size.width + 5.0f, 5.0f, 10.0f, originY)];
        self.xLabel.backgroundColor = [UIColor whiteColor];
        self.xLabel.text = @"#";
        self.xLabel.font = [UIFont fontWithName:MYRIADPRO size:rFontSize*1.2f];
        self.xLabel.adjustsFontSizeToFitWidth = YES;
        self.xLabel.minimumScaleFactor = 0.1f;
        self.xLabel.textAlignment = NSTextAlignmentRight;
        self.xLabel.textColor = [UIColor blackColor];
        [self addSubview:self.xLabel];
        
        self.hexTextField = [[UITextField alloc] initWithFrame:CGRectMake(self.xLabel.frame.origin.x + self.xLabel.frame.size.width, 5.0f, self.frame.size.width - (self.xLabel.frame.origin.x + self.xLabel.frame.size.width) - 5.0f, originY)];
        self.hexTextField.backgroundColor = [UIColor whiteColor];
        self.hexTextField.text = @"FFFFFF";
        self.hexTextField.font = [UIFont fontWithName:MYRIADPRO size:rFontSize*1.2f];
        self.hexTextField.adjustsFontSizeToFitWidth = YES;
        self.hexTextField.textAlignment = NSTextAlignmentLeft;
        self.hexTextField.textColor = [UIColor blackColor];
        self.hexTextField.keyboardAppearance = UIKeyboardAppearanceDark;
        self.hexTextField.delegate = self;
        [self addSubview:self.hexTextField];
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        {
            [self setIPhoneKeyboard:[[BSKeyboardControls alloc] initWithFields:@[self.hexTextField,]]];
            [self.iPhoneKeyboard setDelegate:self];
        }
        
        UILabel* recentTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width*0.4f + 5.0f, 10.0f + originY, self.frame.size.width*0.2f, 10.0f)];
        recentTitleLabel.backgroundColor = [UIColor clearColor];
        recentTitleLabel.text = @"Recent";
        recentTitleLabel.textColor = [UIColor whiteColor];
        recentTitleLabel.font = [UIFont fontWithName:MYRIADPRO size:10.0f];
        recentTitleLabel.adjustsFontSizeToFitWidth = YES;
        recentTitleLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:recentTitleLabel];
        
        self.recentColorScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(self.frame.size.width*0.4f + 5.0f, 20.0f + originY, self.frame.size.width*0.6f - 10.0f, self.shadowWidthView.frame.origin.y - (22.0f + originY))];
        self.recentColorScrollView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.recentColorScrollView];
        self.recentColorScrollView.delegate = self;
        self.recentColorScrollView.scrollEnabled = YES;
        self.recentColorScrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
        
        [self updateRecentColorScrollView];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
        tapGesture.delegate = self;
        [self addGestureRecognizer:tapGesture];
        [tapGesture setNumberOfTapsRequired:1];
    }
    
    return self;
}

- (void) initialize
{
    self.shadowWidthTitleLabel.text = [NSString stringWithFormat:@"Blur : %.1fpx", self.objectShadowBlur];
    self.shadowOffsetTitleLabel.text = [NSString stringWithFormat:@"Offset : %.1fpx", self.objectShadowOffset];

    [self.shadowWidthSlider setValue:(1.0f-self.objectShadowBlur/100.0f)];
    [self.shadowWidthSlider setKeyColor:self.objectShadowColor];
    [self.shadowWidthSlider changeSliderRange];

    [self.shadowOffsetSlider setValue:(1.0f-self.objectShadowOffset/50.0f)];
    [self.shadowOffsetSlider setKeyColor:self.objectShadowColor];
    [self.shadowOffsetSlider changeSliderRange];

    [self.shadowColorPickerView setOldColor:self.objectShadowColor];
    [self.shadowColorPickerView setSelectedColor:self.objectShadowColor];
    
    if (self.objectShadowStyle == 1)
    {
        [self.noShadowBtn setBackgroundColor:UIColorFromRGB(0x9da1a0)];
        [self.shadowBtn setBackgroundColor:[UIColor clearColor]];
    }
    else if (self.objectShadowStyle == 2)
    {
        [self.noShadowBtn setBackgroundColor:[UIColor clearColor]];
        [self.shadowBtn setBackgroundColor:UIColorFromRGB(0x9da1a0)];
    }
    
    self.colorPreviewView.backgroundColor = self.objectShadowColor;
    
    NSString* hexString = [self.objectShadowColor hexStringFromColor];
    self.hexTextField.text = [hexString uppercaseString];
    
    [self updateRecentColorScrollView];
}


- (void) setSelectedBackgroundViewFor:(UIButton *) button
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(button.bounds.size.width, button.bounds.size.height), NO, 0.0);
    [UIColorFromRGB(0x9da1a0) set];
    CGContextFillRect(UIGraphicsGetCurrentContext(), CGRectMake(0.5f, 0.5f, button.bounds.size.width - 0.5f, button.bounds.size.height - 0.5f));
    UIImage* resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [button setBackgroundImage:resultImage forState:UIControlStateHighlighted];
    [button setBackgroundImage:resultImage forState:UIControlStateSelected|UIControlStateHighlighted];
}

- (void)shadowMenuMove:(UIPanGestureRecognizer *)gestureRecognizer
{
    CGPoint translatedPoint = [gestureRecognizer translationInView:self.superview];
    
    if([gestureRecognizer state] == UIGestureRecognizerStateBegan)
    {
        firstX = self.superview.center.x;
        firstY = self.superview.center.y;
    }
    
    translatedPoint = CGPointMake(firstX+translatedPoint.x, firstY+translatedPoint.y);
    [self.superview setCenter:translatedPoint];
}


#pragma mark -
#pragma mark - ColorPicker Changed

- (void) shadowColorPickerChanged:(KZColorPicker *)cp
{
    self.objectShadowColor = cp.selectedColor;
	[self.shadowWidthSlider setKeyColor:self.objectShadowColor];
	[self.shadowOffsetSlider setKeyColor:self.objectShadowColor];
    self.leftBoxView.backgroundColor = [UIColor colorWithPatternImage:[[UIImage imageNamed:@"leftBox"] imageWithOverlayColor:self.objectShadowColor]];
    self.colorPreviewView.backgroundColor = self.objectShadowColor;
    
    NSString* hexString = [self.objectShadowColor hexStringFromColor];
    self.hexTextField.text = [hexString uppercaseString];

    [self changeShadow];
    [self deleteDesabled];
}


#pragma mark -
#pragma mark - Shadow Width Slider Changed

- (void) shadowWidthChanged:(KZColorPickerWidthSlider *)slider
{
    [self.shadowWidthSlider changeSliderRange];
    self.objectShadowBlur = (1.0f-self.shadowWidthSlider.value)*100.0f;
    self.shadowWidthTitleLabel.text = [NSString stringWithFormat:@"Blur : %.1fpx", self.objectShadowBlur];
    [self changeShadow];
}


#pragma mark -
#pragma mark - Shadow Offset Slider Changed

- (void) shadowOffsetChanged:(KZColorPickerWidthSlider *)slider
{
    [self.shadowOffsetSlider changeSliderRange];
    self.objectShadowOffset = (1.0f-self.shadowOffsetSlider.value)*50.0f;
    self.shadowOffsetTitleLabel.text = [NSString stringWithFormat:@"Offset : %.1fpx", self.objectShadowOffset];
    [self changeShadow];
}


#pragma mark -
#pragma mark - selected No Shadow

- (void) selectNoShadow:(id) sender
{
    self.objectShadowStyle = 1;
    [self.noShadowBtn setBackgroundColor:UIColorFromRGB(0x9da1a0)];
    [self.shadowBtn setBackgroundColor:[UIColor clearColor]];
    [self changeShadow];
}


#pragma mark -
#pragma mark - selected Shadow

- (void) selectShadow:(id) sender
{
    self.objectShadowStyle = 2;
    [self.noShadowBtn setBackgroundColor:[UIColor clearColor]];
    [self.shadowBtn setBackgroundColor:UIColorFromRGB(0x9da1a0)];
    [self changeShadow];
}

- (void) changeShadow
{
    if ([self.delegate respondsToSelector:@selector(changeShadow:shadowBlur:shadowColor:shadowStyle:)])
    {
        [self.delegate changeShadow:self.objectShadowOffset shadowBlur:self.objectShadowBlur shadowColor:self.objectShadowColor shadowStyle:self.objectShadowStyle];
    }
}


#pragma mark -
#pragma mark - BSKeyboardControls Delegate

- (void)keyboardControlsDonePressed:(BSKeyboardControls *)keyboardControls
{
    [self.hexTextField resignFirstResponder];
}


#pragma mark -
#pragma mark - UITextField Delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    textField.text = [textField.text uppercaseString];
    
    self.objectShadowColor = [UIColor colorWithHexString:textField.text];
    [self.shadowColorPickerView setOldColor:self.objectShadowColor];
    [self.shadowColorPickerView setSelectedColor:self.objectShadowColor];
    [self.shadowWidthSlider setKeyColor:self.objectShadowColor];
    [self.shadowOffsetSlider setKeyColor:self.objectShadowColor];
    self.leftBoxView.backgroundColor = [UIColor colorWithPatternImage:[[UIImage imageNamed:@"leftBox"] imageWithOverlayColor:self.objectShadowColor]];
    self.colorPreviewView.backgroundColor = self.objectShadowColor;
    
    NSString* hexString = [self.objectShadowColor hexStringFromColor];
    self.hexTextField.text = [hexString uppercaseString];
    
    [self changeShadow];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string length] == 0)
        return YES;
    
    if (range.location >= 8)
        return NO;
    
    string = [string uppercaseString];
    
    //compare string with A-F, 0-9
    NSCharacterSet* myCharSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789ABCDEF"];
    
    for (int i=0; i<[string length]; i++)
    {
        unichar c = [string characterAtIndex:i];
        
        if ([myCharSet characterIsMember:c])
            return YES;
    }
    
    return NO;
}


#pragma mark -
#pragma mark - Action Tap Color Preview to Add Recent

- (void) actionColorPreviewToRecent:(UITapGestureRecognizer*) recognizer
{
    [self saveCurrentColorToRecent];
    [self updateRecentColorScrollView];
}


#pragma mark - Save color to Recent

-(void) saveCurrentColorToRecent
{
    //get hex string
    NSString* hexString = [self.objectShadowColor hexStringFromColor];
    hexString = [hexString uppercaseString];
    
    //if current hex string is exist on recent color array, then return. else if then add current hex string to recent color array
    for (int i=0; i<gaRecentColorArray.count; i++)
    {
        NSString* recentString = [gaRecentColorArray objectAtIndex:i];
        
        if ([hexString isEqualToString:recentString])
            return;
    }
    
    [gaRecentColorArray addObject:hexString];
    
    //Save hex color string to plist
    NSFileManager *localFileManager = [NSFileManager defaultManager];
    NSString *folderDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Library"];
    NSString *folderPath = [folderDir stringByAppendingPathComponent:@"Preferences"];
    NSError *error;
    
    NSString* plistFileName = [folderPath stringByAppendingPathComponent:@"RecentColor.plist"];
    
    if (![localFileManager fileExistsAtPath:plistFileName])
        [localFileManager removeItemAtPath:plistFileName error:&error ];
    [localFileManager createFileAtPath:plistFileName contents:nil attributes:nil];
    
    NSMutableDictionary *plistDict = [NSMutableDictionary dictionary];
    
    [plistDict setObject:[NSNumber numberWithInt:(int)gaRecentColorArray.count] forKey:@"RecentColorCount"];
    
    for (int i=0; i<gaRecentColorArray.count; i++)
    {
        NSString* recentString = [gaRecentColorArray objectAtIndex:i];
        
        [plistDict setObject:recentString forKey:[NSString stringWithFormat:@"%d-RecentColorString", i]];
    }
    
    [plistDict writeToFile:plistFileName atomically:YES];
}

-(void) updateRecentColorScrollView
{
    for (RecentColorView* view in self.recentColorScrollView.subviews)
    {
        if (view.tag > 0)
        {
            [view removeFromSuperview];
        }
    }
    
    CGFloat width = (self.recentColorScrollView.frame.size.width - 7.0f)/6.0f;
    CGFloat height = (self.recentColorScrollView.frame.size.height - 5.0f)/4.0f;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        height = height*2.0f;
    
    for (int i=0; i<gaRecentColorArray.count; i++)
    {
        NSString* colorString = [gaRecentColorArray objectAtIndex:i];
        
        RecentColorView* recentView = [[RecentColorView alloc] initWithFrame:CGRectMake(1.0f + (width+1.0f)*(i%6), 1.0f + (height+1.0f)*(i/6), width, height) index:i+1 string:colorString];
        recentView.delegate = self;
        [self.recentColorScrollView addSubview:recentView];
    }
    
    [self.recentColorScrollView setContentSize:CGSizeMake(self.recentColorScrollView.bounds.size.width, 1.0f + (height+1.0f)*(gaRecentColorArray.count/6 + 1))];
}


#pragma mark -
#pragma mark - RecentColorViewDelegate

-(void) selectColor:(NSInteger) colorIndex
{
    NSString* colorString = [gaRecentColorArray objectAtIndex:colorIndex-1];
    
    self.objectShadowColor = [UIColor colorWithHexString:colorString];
    [self.shadowWidthSlider setKeyColor:self.objectShadowColor];
    [self.shadowOffsetSlider setKeyColor:self.objectShadowColor];
    self.leftBoxView.backgroundColor = [UIColor colorWithPatternImage:[[UIImage imageNamed:@"leftBox"] imageWithOverlayColor:self.objectShadowColor]];
    self.colorPreviewView.backgroundColor = self.objectShadowColor;
    [self.shadowColorPickerView setOldColor:self.objectShadowColor];
    [self.shadowColorPickerView setSelectedColor:self.objectShadowColor];
    
    self.hexTextField.text = colorString;
    
    [self changeShadow];
}

-(void) deleteColor:(NSInteger) colorIndex
{
    [gaRecentColorArray removeObjectAtIndex:(colorIndex-1)];
    
    [self updateRecentColorScrollView];
    
    for (RecentColorView* view in self.recentColorScrollView.subviews)
    {
        if (view.tag > 0)
            view.deleteBtn.hidden = NO;
    }
}

-(void) deleteColorEnabled
{
    for (RecentColorView* view in self.recentColorScrollView.subviews)
    {
        if (view.tag > 0)
            view.deleteBtn.hidden = NO;
    }
}

-(void) deleteDesabled
{
    for (RecentColorView* view in self.recentColorScrollView.subviews)
    {
        if (view.tag > 0)
            view.deleteBtn.hidden = YES;
    }
}

-(void) tapGesture:(UITapGestureRecognizer*) gesture
{
    [self deleteDesabled];
}

@end