//
//  ReflectionSettingView.m
//  VideoFrame
//
//  Created by Yinjing Li on 3/6/14.
//  Copyright (c) 2014 Yinjing Li. All rights reserved.
//


#import "ReflectionSettingView.h"
#import <QuartzCore/QuartzCore.h>

@implementation ReflectionSettingView


#pragma mark - init

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        
        CGFloat rFontSize = 0.0f;
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
            rFontSize = 12.0f;
        else
            rFontSize = 14.0f;
        
        self.isReflection = NO;
        self.reflectionScale = 0.5f;
        self.reflectionAlpha = 0.5f;
        self.reflectionGap = 0.0f;

        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        {
            //reflection view
            self.reflectionView = [[ReflectionView alloc] initWithFrame:CGRectMake(10.0f, 5.0f, self.frame.size.width - 20.0f, 65.0f)];
            self.reflectionView.backgroundColor = [UIColor clearColor];
            self.reflectionView.userInteractionEnabled = YES;
            [self addSubview:self.reflectionView];
            
            self.reflectionImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.frame.size.width - 20.0f, 65.0f)];
            [self.reflectionImageView setImage:[UIImage imageNamed:@"ReflectionImage"]];
            self.reflectionImageView.backgroundColor = [UIColor clearColor];
            self.reflectionImageView.userInteractionEnabled = NO;
            self.reflectionImageView.contentMode = UIViewContentModeScaleAspectFit;
            [self.reflectionView addSubview:self.reflectionImageView];
            
            //reflection switch
            self.switchView = [[UIView alloc] initWithFrame:CGRectMake(0, 135.0f, self.frame.size.width, 40.0f)];
            self.switchView.backgroundColor = [UIColor clearColor];
            self.switchView.layer.borderWidth = 1.0f;
            self.switchView.layer.borderColor = [UIColor whiteColor].CGColor;
            [self addSubview:self.switchView];
            
            self.switchTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0f, 10.0f, self.frame.size.width-5.0f, 20.0f)];
            self.switchTitleLabel.backgroundColor = [UIColor clearColor];
            self.switchTitleLabel.textAlignment = NSTextAlignmentLeft;
            self.switchTitleLabel.text = @"Reflection : ";
            self.switchTitleLabel.font = [UIFont fontWithName:MYRIADPRO size:rFontSize];
            self.switchTitleLabel.adjustsFontSizeToFitWidth = YES;
            self.switchTitleLabel.minimumScaleFactor = 0.1f;
            self.switchTitleLabel.numberOfLines = 0;
            self.switchTitleLabel.textColor = [UIColor whiteColor];
            [self.switchView addSubview:self.switchTitleLabel];
            
            self.reflectionSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(75.0f, 5.0f, 79.0f, 27.0f)];
            self.reflectionSwitch.on = NO;
            [self.reflectionSwitch addTarget:self action:@selector(reflectionSwitchChanged:) forControlEvents:UIControlEventValueChanged];
            [self.switchView addSubview:self.reflectionSwitch];

            //scale view
            self.scaleView = [[UIView alloc] initWithFrame:CGRectMake(0, 175.0f, self.frame.size.width, 40.0f)];
            self.scaleView.backgroundColor = [UIColor clearColor];
            self.scaleView.layer.borderWidth = 1.0f;
            self.scaleView.layer.borderColor = [UIColor whiteColor].CGColor;
            [self addSubview:self.scaleView];
            
            self.scaleTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0f, 0.0f, self.frame.size.width-5.0f, 20.0f)];
            self.scaleTitleLabel.backgroundColor = [UIColor clearColor];
            self.scaleTitleLabel.textAlignment = NSTextAlignmentLeft;
            self.scaleTitleLabel.text = [NSString stringWithFormat:@"Scale : %.2f", self.reflectionScale];
            self.scaleTitleLabel.font = [UIFont fontWithName:MYRIADPRO size:rFontSize];
            self.scaleTitleLabel.adjustsFontSizeToFitWidth = YES;
            self.scaleTitleLabel.minimumScaleFactor = 0.1f;
            self.scaleTitleLabel.numberOfLines = 0;
            self.scaleTitleLabel.textColor = [UIColor whiteColor];
            [self.scaleView addSubview:self.scaleTitleLabel];
            
            self.minScaleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 18.0f, 30.0f, 20.0f)];
            self.minScaleLabel.backgroundColor = [UIColor clearColor];
            self.minScaleLabel.textAlignment = NSTextAlignmentCenter;
            self.minScaleLabel.text = @"0.00";
            self.minScaleLabel.font = [UIFont fontWithName:MYRIADPRO size:rFontSize-2.0f];
            self.minScaleLabel.adjustsFontSizeToFitWidth = YES;
            self.minScaleLabel.minimumScaleFactor = 0.1f;
            self.minScaleLabel.numberOfLines = 0;
            self.minScaleLabel.textColor = [UIColor whiteColor];
            [self.scaleView addSubview:self.minScaleLabel];
            
            self.maxScaleLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width-30.0f, 18.0f, 30.0f, 20.0f)];
            self.maxScaleLabel.backgroundColor = [UIColor clearColor];
            self.maxScaleLabel.textAlignment = NSTextAlignmentCenter;
            self.maxScaleLabel.text = @"1.00";
            self.maxScaleLabel.font = [UIFont fontWithName:MYRIADPRO size:rFontSize-2.0f];
            self.maxScaleLabel.adjustsFontSizeToFitWidth = YES;
            self.maxScaleLabel.minimumScaleFactor = 0.1f;
            self.maxScaleLabel.numberOfLines = 0;
            self.maxScaleLabel.textColor = [UIColor whiteColor];
            [self.scaleView addSubview:self.maxScaleLabel];
            
            self.scaleSlider = [[KZColorPickerWidthSlider alloc] initWithFrame:CGRectMake(30.0f,
                                                                                                 18.0f,
                                                                                                 self.frame.size.width-60.0f,
                                                                                                 20.0f)];
            [self.scaleSlider addTarget:self action:@selector(scaleChanged:) forControlEvents:UIControlEventValueChanged];
            [self.scaleSlider setKeyColor:[UIColor redColor]];
            [self.scaleView addSubview:self.scaleSlider];
            
            //Alpha view
            self.alphaView = [[UIView alloc] initWithFrame:CGRectMake(0, 215.0f, self.frame.size.width, 40.0f)];
            self.alphaView.backgroundColor = [UIColor clearColor];
            self.alphaView.layer.borderWidth = 1.0f;
            self.alphaView.layer.borderColor = [UIColor whiteColor].CGColor;
            [self addSubview:self.alphaView];
            
            self.alphaTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0f, 0.0f, self.frame.size.width-5.0f, 20.0f)];
            self.alphaTitleLabel.backgroundColor = [UIColor clearColor];
            self.alphaTitleLabel.textAlignment = NSTextAlignmentLeft;
            self.alphaTitleLabel.text = [NSString stringWithFormat:@"Alpha : %.2f", self.reflectionAlpha];
            self.alphaTitleLabel.font = [UIFont fontWithName:MYRIADPRO size:rFontSize];
            self.alphaTitleLabel.adjustsFontSizeToFitWidth = YES;
            self.alphaTitleLabel.minimumScaleFactor = 0.1f;
            self.alphaTitleLabel.numberOfLines = 0;
            self.alphaTitleLabel.textColor = [UIColor whiteColor];
            [self.alphaView addSubview:self.alphaTitleLabel];
            
            self.minAlphaLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 18.0f, 30.0f, 20.0f)];
            self.minAlphaLabel.backgroundColor = [UIColor clearColor];
            self.minAlphaLabel.textAlignment = NSTextAlignmentCenter;
            self.minAlphaLabel.text = @"0.00";
            self.minAlphaLabel.font = [UIFont fontWithName:MYRIADPRO size:rFontSize-2.0f];
            self.minAlphaLabel.adjustsFontSizeToFitWidth = YES;
            self.minAlphaLabel.minimumScaleFactor = 0.1f;
            self.minAlphaLabel.numberOfLines = 0;
            self.minAlphaLabel.textColor = [UIColor whiteColor];
            [self.alphaView addSubview:self.minAlphaLabel];
            
            self.maxAlphaLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width-30.0f, 18.0f, 30.0f, 20.0f)];
            self.maxAlphaLabel.backgroundColor = [UIColor clearColor];
            self.maxAlphaLabel.textAlignment = NSTextAlignmentCenter;
            self.maxAlphaLabel.text = @"1.00";
            self.maxAlphaLabel.font = [UIFont fontWithName:MYRIADPRO size:rFontSize-2.0f];
            self.maxAlphaLabel.adjustsFontSizeToFitWidth = YES;
            self.maxAlphaLabel.minimumScaleFactor = 0.1f;
            self.maxAlphaLabel.numberOfLines = 0;
            self.maxAlphaLabel.textColor = [UIColor whiteColor];
            [self.alphaView addSubview:self.maxAlphaLabel];
            
            self.alphaSlider = [[KZColorPickerWidthSlider alloc] initWithFrame:CGRectMake(30.0f,
                                                                                                 18.0f,
                                                                                                 self.frame.size.width-60.0f,
                                                                                                 20.0f)];
            [self.alphaSlider addTarget:self action:@selector(alphaChanged:) forControlEvents:UIControlEventValueChanged];
            [self.alphaSlider setKeyColor:[UIColor greenColor]];
            [self.alphaView addSubview:self.alphaSlider];

            //gap view
            self.gapView = [[UIView alloc] initWithFrame:CGRectMake(0, 255.0f, self.frame.size.width, 40.0f)];
            self.gapView.backgroundColor = [UIColor clearColor];
            self.gapView.layer.borderWidth = 1.0f;
            self.gapView.layer.borderColor = [UIColor whiteColor].CGColor;
            [self addSubview:self.gapView];
            
            self.gapTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0f, 0.0f, self.frame.size.width-5.0f, 20.0f)];
            self.gapTitleLabel.backgroundColor = [UIColor clearColor];
            self.gapTitleLabel.textAlignment = NSTextAlignmentLeft;
            self.gapTitleLabel.text = [NSString stringWithFormat:@"Gap : %.1fpx", self.reflectionGap];
            self.gapTitleLabel.font = [UIFont fontWithName:MYRIADPRO size:rFontSize];
            self.gapTitleLabel.adjustsFontSizeToFitWidth = YES;
            self.gapTitleLabel.minimumScaleFactor = 0.1f;
            self.gapTitleLabel.numberOfLines = 0;
            self.gapTitleLabel.textColor = [UIColor whiteColor];
            [self.gapView addSubview:self.gapTitleLabel];
            
            self.maxGapLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width-30.0f, 18.0f, 30.0f, 20.0f)];
            self.maxGapLabel.backgroundColor = [UIColor clearColor];
            self.maxGapLabel.textAlignment = NSTextAlignmentCenter;
            self.maxGapLabel.text = @"100.0px";
            self.maxGapLabel.font = [UIFont fontWithName:MYRIADPRO size:rFontSize-2.0f];
            self.maxGapLabel.adjustsFontSizeToFitWidth = YES;
            self.maxGapLabel.minimumScaleFactor = 0.1f;
            self.maxGapLabel.numberOfLines = 0;
            self.maxGapLabel.textColor = [UIColor whiteColor];
            [self.gapView addSubview:self.maxGapLabel];
            
            self.gapSlider = [[KZColorPickerWidthSlider alloc] initWithFrame:CGRectMake(30.0f,
                                                                                         18.0f,
                                                                                         self.frame.size.width-60.0f,
                                                                                         20.0f)];
            [self.gapSlider addTarget:self action:@selector(gapChanged:) forControlEvents:UIControlEventValueChanged];
            [self.gapSlider setKeyColor:[UIColor yellowColor]];
            [self.gapView addSubview:self.gapSlider];
            
            //leftbox view
            self.leftBoxView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height-30, 30, 30)];
            self.leftBoxView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"leftBox"]];
            self.leftBoxView.userInteractionEnabled = YES;
            [self addSubview:self.leftBoxView];
            
            UIPanGestureRecognizer* moveGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(outlineMenuMove:)];
            [moveGesture setMinimumNumberOfTouches:1];
            [moveGesture setMaximumNumberOfTouches:1];
            moveGesture.delegate = self;
            [self.leftBoxView addGestureRecognizer:moveGesture];
        }
        else
        {
            //reflection view
            self.reflectionView = [[ReflectionView alloc] initWithFrame:CGRectMake(10.0f, 5.0f, self.frame.size.width - 20.0f, 130.0f)];
            self.reflectionView.backgroundColor = [UIColor clearColor];
            self.reflectionView.userInteractionEnabled = YES;
            [self addSubview:self.reflectionView];
            
            self.reflectionImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.frame.size.width - 20.0f, 130.0f)];
            [self.reflectionImageView setImage:[UIImage imageNamed:@"ReflectionImage"]];
            self.reflectionImageView.backgroundColor = [UIColor clearColor];
            self.reflectionImageView.userInteractionEnabled = NO;
            self.reflectionImageView.contentMode = UIViewContentModeScaleAspectFit;
            [self.reflectionView addSubview:self.reflectionImageView];
            
            //reflection switch
            self.switchView = [[UIView alloc] initWithFrame:CGRectMake(0, 260.0f, self.frame.size.width, 40.0f)];
            self.switchView.backgroundColor = [UIColor clearColor];
            self.switchView.layer.borderWidth = 1.0f;
            self.switchView.layer.borderColor = [UIColor whiteColor].CGColor;
            [self addSubview:self.switchView];
            
            self.switchTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0f, 10.0f, self.frame.size.width-5.0f, 20.0f)];
            self.switchTitleLabel.backgroundColor = [UIColor clearColor];
            self.switchTitleLabel.textAlignment = NSTextAlignmentLeft;
            self.switchTitleLabel.text = @"Reflection : ";
            self.switchTitleLabel.font = [UIFont fontWithName:MYRIADPRO size:rFontSize];
            self.switchTitleLabel.adjustsFontSizeToFitWidth = YES;
            self.switchTitleLabel.minimumScaleFactor = 0.1f;
            self.switchTitleLabel.numberOfLines = 0;
            self.switchTitleLabel.textColor = [UIColor whiteColor];
            [self.switchView addSubview:self.switchTitleLabel];

            self.reflectionSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(100.0f, 5.0f, 79.0f, 27.0f)];
            self.reflectionSwitch.on = NO;
            [self.reflectionSwitch addTarget:self action:@selector(reflectionSwitchChanged:) forControlEvents:UIControlEventValueChanged];
            [self.switchView addSubview:self.reflectionSwitch];

            //scale view
            self.scaleView = [[UIView alloc] initWithFrame:CGRectMake(0, 300.0f, self.frame.size.width, 50.0f)];
            self.scaleView.backgroundColor = [UIColor clearColor];
            self.scaleView.layer.borderWidth = 1.0f;
            self.scaleView.layer.borderColor = [UIColor whiteColor].CGColor;
            [self addSubview:self.scaleView];
            
            self.scaleTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0f, 0.0f, self.frame.size.width-5.0f, 20.0f)];
            self.scaleTitleLabel.backgroundColor = [UIColor clearColor];
            self.scaleTitleLabel.textAlignment = NSTextAlignmentLeft;
            self.scaleTitleLabel.text = [NSString stringWithFormat:@"Scale : %.2f", self.reflectionScale];
            self.scaleTitleLabel.font = [UIFont fontWithName:MYRIADPRO size:rFontSize];
            self.scaleTitleLabel.adjustsFontSizeToFitWidth = YES;
            self.scaleTitleLabel.minimumScaleFactor = 0.1f;
            self.scaleTitleLabel.numberOfLines = 0;
            self.scaleTitleLabel.textColor = [UIColor whiteColor];
            [self.scaleView addSubview:self.scaleTitleLabel];
            
            self.minScaleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 25.0f, 40.0f, 20.0f)];
            self.minScaleLabel.backgroundColor = [UIColor clearColor];
            self.minScaleLabel.textAlignment = NSTextAlignmentCenter;
            self.minScaleLabel.text = @"0.00";
            self.minScaleLabel.font = [UIFont fontWithName:MYRIADPRO size:rFontSize-2.0f];
            self.minScaleLabel.adjustsFontSizeToFitWidth = YES;
            self.minScaleLabel.minimumScaleFactor = 0.1f;
            self.minScaleLabel.numberOfLines = 0;
            self.minScaleLabel.textColor = [UIColor whiteColor];
            [self.scaleView addSubview:self.minScaleLabel];

            self.maxScaleLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width-40.0f, 25.0f, 40.0f, 20.0f)];
            self.maxScaleLabel.backgroundColor = [UIColor clearColor];
            self.maxScaleLabel.textAlignment = NSTextAlignmentCenter;
            self.maxScaleLabel.text = @"1.00";
            self.maxScaleLabel.font = [UIFont fontWithName:MYRIADPRO size:rFontSize-2.0f];
            self.maxScaleLabel.adjustsFontSizeToFitWidth = YES;
            self.maxScaleLabel.minimumScaleFactor = 0.1f;
            self.maxScaleLabel.numberOfLines = 0;
            self.maxScaleLabel.textColor = [UIColor whiteColor];
            [self.scaleView addSubview:self.maxScaleLabel];

            self.scaleSlider = [[KZColorPickerWidthSlider alloc] initWithFrame:CGRectMake(40.0f,
                                                                                                                    25.0f,
                                                                                                                    self.frame.size.width-80.0f,
                                                                                                                    20.0f)];
            [self.scaleSlider addTarget:self action:@selector(scaleChanged:) forControlEvents:UIControlEventValueChanged];
            [self.scaleSlider setKeyColor:[UIColor redColor]];
            [self.scaleView addSubview:self.scaleSlider];
            
            //alpha view
            self.alphaView = [[UIView alloc] initWithFrame:CGRectMake(0, 350.0f, self.frame.size.width, 50.0f)];
            self.alphaView.backgroundColor = [UIColor clearColor];
            self.alphaView.layer.borderWidth = 1.0f;
            self.alphaView.layer.borderColor = [UIColor whiteColor].CGColor;
            [self addSubview:self.alphaView];
            
            self.alphaTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0f, 0.0f, self.frame.size.width-5.0f, 20.0f)];
            self.alphaTitleLabel.backgroundColor = [UIColor clearColor];
            self.alphaTitleLabel.textAlignment = NSTextAlignmentLeft;
            self.alphaTitleLabel.text = [NSString stringWithFormat:@"Alpha : %.2f", self.reflectionAlpha];
            self.alphaTitleLabel.font = [UIFont fontWithName:MYRIADPRO size:rFontSize];
            self.alphaTitleLabel.adjustsFontSizeToFitWidth = YES;
            self.alphaTitleLabel.minimumScaleFactor = 0.1f;
            self.alphaTitleLabel.numberOfLines = 0;
            self.alphaTitleLabel.textColor = [UIColor whiteColor];
            [self.alphaView addSubview:self.alphaTitleLabel];
            
            self.minAlphaLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 25.0f, 40.0f, 20.0f)];
            self.minAlphaLabel.backgroundColor = [UIColor clearColor];
            self.minAlphaLabel.textAlignment = NSTextAlignmentCenter;
            self.minAlphaLabel.text = @"0.00";
            self.minAlphaLabel.font = [UIFont fontWithName:MYRIADPRO size:rFontSize-2.0f];
            self.minAlphaLabel.adjustsFontSizeToFitWidth = YES;
            self.minAlphaLabel.minimumScaleFactor = 0.1f;
            self.minAlphaLabel.numberOfLines = 0;
            self.minAlphaLabel.textColor = [UIColor whiteColor];
            [self.alphaView addSubview:self.minAlphaLabel];
            
            self.maxAlphaLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width-40.0f, 25.0f, 40.0f, 20.0f)];
            self.maxAlphaLabel.backgroundColor = [UIColor clearColor];
            self.maxAlphaLabel.textAlignment = NSTextAlignmentCenter;
            self.maxAlphaLabel.text = @"1.00";
            self.maxAlphaLabel.font = [UIFont fontWithName:MYRIADPRO size:rFontSize-2.0f];
            self.maxAlphaLabel.adjustsFontSizeToFitWidth = YES;
            self.maxAlphaLabel.minimumScaleFactor = 0.1f;
            self.maxAlphaLabel.numberOfLines = 0;
            self.maxAlphaLabel.textColor = [UIColor whiteColor];
            [self.alphaView addSubview:self.maxAlphaLabel];
            
            self.alphaSlider = [[KZColorPickerWidthSlider alloc] initWithFrame:CGRectMake(40.0f,
                                                                                                 25.0f,
                                                                                                 self.frame.size.width-80.0f,
                                                                                                 20.0f)];
            [self.alphaSlider addTarget:self action:@selector(alphaChanged:) forControlEvents:UIControlEventValueChanged];
            [self.alphaSlider setKeyColor:[UIColor greenColor]];
            [self.alphaView addSubview:self.alphaSlider];

            //gap view
            self.gapView = [[UIView alloc] initWithFrame:CGRectMake(0, 400.0f, self.frame.size.width, 50.0f)];
            self.gapView.backgroundColor = [UIColor clearColor];
            self.gapView.layer.borderWidth = 1.0f;
            self.gapView.layer.borderColor = [UIColor whiteColor].CGColor;
            [self addSubview:self.gapView];
            
            self.gapTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0f, 0.0f, self.frame.size.width-5.0f, 20.0f)];
            self.gapTitleLabel.backgroundColor = [UIColor clearColor];
            self.gapTitleLabel.textAlignment = NSTextAlignmentLeft;
            self.gapTitleLabel.text = [NSString stringWithFormat:@"Gap : %.1fpx", self.reflectionGap];
            self.gapTitleLabel.font = [UIFont fontWithName:MYRIADPRO size:rFontSize];
            self.gapTitleLabel.adjustsFontSizeToFitWidth = YES;
            self.gapTitleLabel.minimumScaleFactor = 0.1f;
            self.gapTitleLabel.numberOfLines = 0;
            self.gapTitleLabel.textColor = [UIColor whiteColor];
            [self.gapView addSubview:self.gapTitleLabel];
            
            self.maxGapLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width-40.0f, 25.0f, 40.0f, 20.0f)];
            self.maxGapLabel.backgroundColor = [UIColor clearColor];
            self.maxGapLabel.textAlignment = NSTextAlignmentCenter;
            self.maxGapLabel.text = @"100.0px";
            self.maxGapLabel.font = [UIFont fontWithName:MYRIADPRO size:rFontSize-2.0f];
            self.maxGapLabel.adjustsFontSizeToFitWidth = YES;
            self.maxGapLabel.minimumScaleFactor = 0.1f;
            self.maxGapLabel.numberOfLines = 0;
            self.maxGapLabel.textColor = [UIColor whiteColor];
            [self.gapView addSubview:self.maxGapLabel];
            
            self.gapSlider = [[KZColorPickerWidthSlider alloc] initWithFrame:CGRectMake(40.0f,
                                                                                           25.0f,
                                                                                           self.frame.size.width-80.0f,
                                                                                           20.0f)];
            [self.gapSlider addTarget:self action:@selector(gapChanged:) forControlEvents:UIControlEventValueChanged];
            [self.gapSlider setKeyColor:[UIColor yellowColor]];
            [self.gapView addSubview:self.gapSlider];

            //leftbox view
            self.leftBoxView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height-40, 40, 40)];
            self.leftBoxView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"leftBox"]];
            self.leftBoxView.userInteractionEnabled = YES;
            [self addSubview:self.leftBoxView];
            self.leftBoxView.alpha = 0.8f;
            
            UIPanGestureRecognizer* moveGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(outlineMenuMove:)];
            [moveGesture setMinimumNumberOfTouches:1];
            [moveGesture setMaximumNumberOfTouches:1];
            moveGesture.delegate = self;
            [self.leftBoxView addGestureRecognizer:moveGesture];
       }
    }
    
    return self;
}

- (void) initialize
{
    [self.scaleTitleLabel setText:[NSString stringWithFormat:@"Scale : %.2f", self.reflectionScale]];
    [self.alphaTitleLabel setText:[NSString stringWithFormat:@"Alpha : %.2f", self.reflectionAlpha]];
    [self.gapTitleLabel setText:[NSString stringWithFormat:@"Gap : %.1fpx", self.reflectionGap]];
    
    [self.scaleSlider setValue:(1.0f-self.reflectionScale)];
    [self.scaleSlider changeSliderRange];
    
    [self.alphaSlider setValue:(1.0f-self.reflectionAlpha)];
    [self.alphaSlider changeSliderRange];

    [self.gapSlider setValue:(1.0f-self.reflectionGap/100.0f)];
    [self.gapSlider changeSliderRange];
    
    self.reflectionSwitch.on = self.isReflection;
    
    self.reflectionView.reflectionScale = self.reflectionScale;
    self.reflectionView.reflectionAlpha = self.reflectionAlpha;
    self.reflectionView.reflectionGap = self.reflectionGap;
    self.reflectionView.isReflection = self.isReflection;
    [self.reflectionView update];
}


- (void) setSelectedBackgroundViewFor:(UIButton *) button
{
    // Create a new image context
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(button.bounds.size.width, button.bounds.size.height), NO, 0.0);
    
    // Fill Highlight Color
    [UIColorFromRGB(0x9da1a0) set];
    CGContextFillRect(UIGraphicsGetCurrentContext(), CGRectMake(0.5f, 0.5f, button.bounds.size.width - 0.5f, button.bounds.size.height - 0.5f));
    
    // Generate a new image
    UIImage* resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [button setBackgroundImage:resultImage forState:UIControlStateHighlighted];
    [button setBackgroundImage:resultImage forState:UIControlStateSelected|UIControlStateHighlighted];
}

- (void)outlineMenuMove:(UIPanGestureRecognizer *)gestureRecognizer
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
#pragma mark - Reflection Switch Changed

-(void) reflectionSwitchChanged:(id) sender
{
    self.isReflection = self.reflectionSwitch.on;
    self.reflectionView.isReflection = self.reflectionSwitch.on;
    [self.reflectionView update];
    [self reflectionChanged];
}


#pragma mark -
#pragma mark - Scale Slider Changed

- (void) scaleChanged:(KZColorPickerWidthSlider *)slider
{
    [self.scaleSlider changeSliderRange];
    self.reflectionScale = 1.0f - self.scaleSlider.value;
    self.scaleTitleLabel.text = [NSString stringWithFormat:@"Scale : %.2f", self.reflectionScale];
    self.reflectionView.reflectionScale = self.reflectionScale;
    [self.reflectionView update];
    [self reflectionChanged];
}


#pragma mark -
#pragma mark - Alpha Slider Changed

- (void) alphaChanged:(KZColorPickerWidthSlider *)slider
{
    [self.alphaSlider changeSliderRange];
    self.reflectionAlpha = 1.0f - self.alphaSlider.value;
    self.alphaTitleLabel.text = [NSString stringWithFormat:@"Alpha : %.2f", self.reflectionAlpha];
    self.reflectionView.reflectionAlpha = self.reflectionAlpha;
    [self.reflectionView update];
    [self reflectionChanged];
}


#pragma mark -
#pragma mark - Gap Slider Changed

- (void) gapChanged:(KZColorPickerWidthSlider *)slider
{
    [self.gapSlider changeSliderRange];
    self.reflectionGap = (1.0f-self.gapSlider.value)*100.0f;
    self.gapTitleLabel.text = [NSString stringWithFormat:@"Gap : %.1fpx", self.reflectionGap];
    self.reflectionView.reflectionGap = self.reflectionGap;
    [self.reflectionView update];
    [self reflectionChanged];
}


- (void) reflectionChanged
{
    if ([self.delegate respondsToSelector:@selector(changeReflection:scale:alpha:gap:)])
    {
        [self.delegate changeReflection:self.isReflection scale:self.reflectionScale alpha:self.reflectionAlpha gap:self.reflectionGap];
    }
}


@end