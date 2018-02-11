//
//  OutlineView.m
//  VideoFrame
//
//  Created by Yinjing Li on 3/6/14.
//  Copyright (c) 2014 Yinjing Li. All rights reserved.
//


#import "OutlineView.h"
#import <QuartzCore/QuartzCore.h>


@implementation OutlineView


#pragma mark - init

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.objectBorderColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
        
        CGFloat rFontSize = 0.0f;
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
            rFontSize = 10.0f;
        else
            rFontSize = 14.0f;

        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        {
            //border style table view
            self.borderStyleScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.frame.size.width*0.4f, 70.0f)];
            self.borderStyleScrollView.backgroundColor = [UIColor clearColor];
            [self addSubview:self.borderStyleScrollView];
            self.borderStyleScrollView.delegate = self;
            self.borderStyleScrollView.scrollEnabled = YES;
            self.borderStyleScrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
            
            UIImageView* style_1_btn = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.borderStyleScrollView.frame.size.width, 20.0f)];
            style_1_btn.backgroundColor = [UIColor clearColor];
            style_1_btn.layer.masksToBounds = YES;
            style_1_btn.layer.borderColor = [UIColor whiteColor].CGColor;
            style_1_btn.layer.borderWidth = 0.5f;
            style_1_btn.layer.cornerRadius = 0.5f;
            style_1_btn.userInteractionEnabled = YES;
            [self.borderStyleScrollView addSubview:style_1_btn];
            style_1_btn.tag = 1;
            
            UILabel* label = [[UILabel alloc] initWithFrame:style_1_btn.bounds];
            label.lineBreakMode = NSLineBreakByWordWrapping;
            label.backgroundColor = [UIColor clearColor];
            label.textAlignment = NSTextAlignmentCenter;
            label.text = @"NO OUTLINE";
            label.textColor = [UIColor whiteColor];
            label.font = [UIFont fontWithName:MYRIADPRO size:rFontSize];
            label.adjustsFontSizeToFitWidth = YES;
            label.minimumScaleFactor = 0.1f;
            label.numberOfLines = 0;
            [style_1_btn addSubview:label];
            
            UITapGestureRecognizer *selectGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectBorderStyle:)];
            selectGesture.delegate = self;
            [style_1_btn addGestureRecognizer:selectGesture];
            [selectGesture setNumberOfTapsRequired:1];
           
            UIImageView* style_2_btn = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 20.0f, self.borderStyleScrollView.frame.size.width, 20.0f)];
            [style_2_btn setImage:[UIImage imageNamed:@"style_iphone_2"]];
            style_2_btn.layer.masksToBounds = YES;
            style_2_btn.layer.borderColor = [UIColor whiteColor].CGColor;
            style_2_btn.layer.borderWidth = 0.5f;
            style_2_btn.layer.cornerRadius = 0.5f;
            style_2_btn.userInteractionEnabled = YES;
            [self.borderStyleScrollView addSubview:style_2_btn];
            style_2_btn.tag = 2;
            
            selectGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectBorderStyle:)];
            selectGesture.delegate = self;
            [style_2_btn addGestureRecognizer:selectGesture];
            [selectGesture setNumberOfTapsRequired:1];

            UIImageView* style_3_btn = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 40.0f, self.borderStyleScrollView.frame.size.width, 20.0f)];
            [style_3_btn setImage:[UIImage imageNamed:@"style_iphone_3"]];
            style_3_btn.layer.masksToBounds = YES;
            style_3_btn.layer.borderColor = [UIColor whiteColor].CGColor;
            style_3_btn.layer.borderWidth = 0.5f;
            style_3_btn.layer.cornerRadius = 0.5f;
            style_3_btn.userInteractionEnabled = YES;
            [self.borderStyleScrollView addSubview:style_3_btn];
            style_3_btn.tag = 3;
            
            selectGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectBorderStyle:)];
            selectGesture.delegate = self;
            [style_3_btn addGestureRecognizer:selectGesture];
            [selectGesture setNumberOfTapsRequired:1];

            UIImageView* style_4_btn = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 60.0f, self.borderStyleScrollView.frame.size.width, 20.0f)];
            [style_4_btn setImage:[UIImage imageNamed:@"style_iphone_4"]];
            style_4_btn.layer.masksToBounds = YES;
            style_4_btn.layer.borderColor = [UIColor whiteColor].CGColor;
            style_4_btn.layer.borderWidth = 0.5f;
            style_4_btn.layer.cornerRadius = 0.5f;
            style_4_btn.userInteractionEnabled = YES;
            [self.borderStyleScrollView addSubview:style_4_btn];
            style_4_btn.tag = 4;

            selectGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectBorderStyle:)];
            selectGesture.delegate = self;
            [style_4_btn addGestureRecognizer:selectGesture];
            [selectGesture setNumberOfTapsRequired:1];
            
            UIImageView* style_5_btn = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 80.0f, self.borderStyleScrollView.frame.size.width, 20.0f)];
            [style_5_btn setImage:[UIImage imageNamed:@"style_iphone_5"]];
            style_5_btn.layer.masksToBounds = YES;
            style_5_btn.layer.borderColor = [UIColor whiteColor].CGColor;
            style_5_btn.layer.borderWidth = 0.5f;
            style_5_btn.layer.cornerRadius = 0.5f;
            style_5_btn.userInteractionEnabled = YES;
            [self.borderStyleScrollView addSubview:style_5_btn];
            style_5_btn.tag = 5;
            
            selectGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectBorderStyle:)];
            selectGesture.delegate = self;
            [style_5_btn addGestureRecognizer:selectGesture];
            [selectGesture setNumberOfTapsRequired:1];
            
            UIImageView* style_6_btn = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 100.0f, self.borderStyleScrollView.frame.size.width, 20.0f)];
            [style_6_btn setImage:[UIImage imageNamed:@"style_iphone_6"]];
            style_6_btn.layer.masksToBounds = YES;
            style_6_btn.layer.borderColor = [UIColor whiteColor].CGColor;
            style_6_btn.layer.borderWidth = 0.5f;
            style_6_btn.layer.cornerRadius = 0.5f;
            style_6_btn.userInteractionEnabled = YES;
            [self.borderStyleScrollView addSubview:style_6_btn];
            style_6_btn.tag = 6;
            
            selectGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectBorderStyle:)];
            selectGesture.delegate = self;
            [style_6_btn addGestureRecognizer:selectGesture];
            [selectGesture setNumberOfTapsRequired:1];

            UIImageView* style_7_btn = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 120.0f, self.borderStyleScrollView.frame.size.width, 20.0f)];
            [style_7_btn setImage:[UIImage imageNamed:@"style_iphone_7"]];
            style_7_btn.layer.masksToBounds = YES;
            style_7_btn.layer.borderColor = [UIColor whiteColor].CGColor;
            style_7_btn.layer.borderWidth = 0.5f;
            style_7_btn.layer.cornerRadius = 0.5f;
            style_7_btn.userInteractionEnabled = YES;
            [self.borderStyleScrollView addSubview:style_7_btn];
            style_7_btn.tag = 7;
            
            selectGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectBorderStyle:)];
            selectGesture.delegate = self;
            [style_7_btn addGestureRecognizer:selectGesture];
            [selectGesture setNumberOfTapsRequired:1];
            
            UIImageView* style_8_btn = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 140.0f, self.borderStyleScrollView.frame.size.width, 20.0f)];
            [style_8_btn setImage:[UIImage imageNamed:@"style_iphone_8"]];
            style_8_btn.layer.masksToBounds = YES;
            style_8_btn.layer.borderColor = [UIColor whiteColor].CGColor;
            style_8_btn.layer.borderWidth = 0.5f;
            style_8_btn.layer.cornerRadius = 0.5f;
            style_8_btn.userInteractionEnabled = YES;
            [self.borderStyleScrollView addSubview:style_8_btn];
            style_8_btn.tag = 8;
            
            selectGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectBorderStyle:)];
            selectGesture.delegate = self;
            [style_8_btn addGestureRecognizer:selectGesture];
            [selectGesture setNumberOfTapsRequired:1];
            
            UIImageView* style_9_btn = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 160.0f, self.borderStyleScrollView.frame.size.width, 20.0f)];
            [style_9_btn setImage:[UIImage imageNamed:@"style_iphone_9"]];
            style_9_btn.layer.masksToBounds = YES;
            style_9_btn.layer.borderColor = [UIColor whiteColor].CGColor;
            style_9_btn.layer.borderWidth = 0.5f;
            style_9_btn.layer.cornerRadius = 0.5f;
            style_9_btn.userInteractionEnabled = YES;
            [self.borderStyleScrollView addSubview:style_9_btn];
            style_9_btn.tag = 9;
            
            selectGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectBorderStyle:)];
            selectGesture.delegate = self;
            [style_9_btn addGestureRecognizer:selectGesture];
            [selectGesture setNumberOfTapsRequired:1];

            UIImageView* style_10_btn = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 180.0f, self.borderStyleScrollView.frame.size.width, 20.0f)];
            [style_10_btn setImage:[UIImage imageNamed:@"style_iphone_10"]];
            style_10_btn.layer.masksToBounds = YES;
            style_10_btn.layer.borderColor = [UIColor whiteColor].CGColor;
            style_10_btn.layer.borderWidth = 0.5f;
            style_10_btn.layer.cornerRadius = 0.5f;
            style_10_btn.userInteractionEnabled = YES;
            [self.borderStyleScrollView addSubview:style_10_btn];
            style_10_btn.tag = 10;
            
            selectGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectBorderStyle:)];
            selectGesture.delegate = self;
            [style_10_btn addGestureRecognizer:selectGesture];
            [selectGesture setNumberOfTapsRequired:1];
            
            self.borderStyleScrollView.contentSize = CGSizeMake(self.borderStyleScrollView.frame.size.width, 200.0f);
            
            //border width view
            self.borderWidthView = [[UIView alloc] initWithFrame:CGRectMake(0, 70.0f, self.frame.size.width, 40.0f)];
            self.borderWidthView.backgroundColor = [UIColor clearColor];
            self.borderWidthView.layer.borderWidth = 1.0f;
            self.borderWidthView.layer.borderColor = [UIColor whiteColor].CGColor;
            [self addSubview:self.borderWidthView];
            
            self.borderWidthTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0f, 0.0f, self.frame.size.width-5.0f, 20.0f)];
            self.borderWidthTitleLabel.backgroundColor = [UIColor clearColor];
            self.borderWidthTitleLabel.textAlignment = NSTextAlignmentLeft;
            self.borderWidthTitleLabel.text = [NSString stringWithFormat:@"Width : %.1fpx", self.objectBorderWidth];
            self.borderWidthTitleLabel.font = [UIFont fontWithName:MYRIADPRO size:rFontSize];
            self.borderWidthTitleLabel.adjustsFontSizeToFitWidth = YES;
            self.borderWidthTitleLabel.minimumScaleFactor = 0.1f;
            self.borderWidthTitleLabel.numberOfLines = 0;
            self.borderWidthTitleLabel.textColor = [UIColor whiteColor];
            [self.borderWidthView addSubview:self.borderWidthTitleLabel];
            
            self.minPixelLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 18.0f, 40.0f, 20.0f)];
            self.minPixelLabel.backgroundColor = [UIColor clearColor];
            self.minPixelLabel.textAlignment = NSTextAlignmentCenter;
            self.minPixelLabel.text = @"0.0px";
            self.minPixelLabel.font = [UIFont fontWithName:MYRIADPRO size:rFontSize-2.0f];
            self.minPixelLabel.adjustsFontSizeToFitWidth = YES;
            self.minPixelLabel.minimumScaleFactor = 0.1f;
            self.minPixelLabel.numberOfLines = 0;
            self.minPixelLabel.textColor = [UIColor whiteColor];
            [self.borderWidthView addSubview:self.minPixelLabel];
            
            self.maxPixelLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width-40.0f, 18.0f, 40.0f, 20.0f)];
            self.maxPixelLabel.backgroundColor = [UIColor clearColor];
            self.maxPixelLabel.textAlignment = NSTextAlignmentCenter;
            self.maxPixelLabel.text = @"50.0px";
            self.maxPixelLabel.font = [UIFont fontWithName:MYRIADPRO size:rFontSize-2.0f];
            self.maxPixelLabel.adjustsFontSizeToFitWidth = YES;
            self.maxPixelLabel.minimumScaleFactor = 0.1f;
            self.maxPixelLabel.numberOfLines = 0;
            self.maxPixelLabel.textColor = [UIColor whiteColor];
            [self.borderWidthView addSubview:self.maxPixelLabel];
            
            self.borderWidthSlider = [[KZColorPickerWidthSlider alloc] initWithFrame:CGRectMake(40.0f,
                                                                                                 18.0f,
                                                                                                 self.frame.size.width-80.0f,
                                                                                                 20.0f)];
            [self.borderWidthSlider addTarget:self action:@selector(widthChanged:) forControlEvents:UIControlEventValueChanged];
            [self.borderWidthView addSubview:self.borderWidthSlider];
            
            //corner view
            self.cornerView = [[UIView alloc] initWithFrame:CGRectMake(0, 110.0f, self.frame.size.width, 40.0f)];
            self.cornerView.backgroundColor = [UIColor clearColor];
            self.cornerView.layer.borderWidth = 1.0f;
            self.cornerView.layer.borderColor = [UIColor whiteColor].CGColor;
            [self addSubview:self.cornerView];
            
            self.cornerTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0f, 0.0f, self.frame.size.width-5.0f, 20.0f)];
            self.cornerTitleLabel.backgroundColor = [UIColor clearColor];
            self.cornerTitleLabel.textAlignment = NSTextAlignmentLeft;
            self.cornerTitleLabel.text = [NSString stringWithFormat:@"Corner : %.1fpx", self.objectCornerRadius];
            self.cornerTitleLabel.font = [UIFont fontWithName:MYRIADPRO size:rFontSize];
            self.cornerTitleLabel.adjustsFontSizeToFitWidth = YES;
            self.cornerTitleLabel.minimumScaleFactor = 0.1f;
            self.cornerTitleLabel.numberOfLines = 0;
            self.cornerTitleLabel.textColor = [UIColor whiteColor];
            [self.cornerView addSubview:self.cornerTitleLabel];
            
            self.minCornerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 18.0f, 40.0f, 20.0f)];
            self.minCornerLabel.backgroundColor = [UIColor clearColor];
            self.minCornerLabel.textAlignment = NSTextAlignmentCenter;
            self.minCornerLabel.text = @"0.0px";
            self.minCornerLabel.font = [UIFont fontWithName:MYRIADPRO size:rFontSize-2.0f];
            self.minCornerLabel.adjustsFontSizeToFitWidth = YES;
            self.minCornerLabel.minimumScaleFactor = 0.1f;
            self.minCornerLabel.numberOfLines = 0;
            self.minCornerLabel.textColor = [UIColor whiteColor];
            [self.cornerView addSubview:self.minCornerLabel];
            
            self.maxCornerLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width-40.0f, 18.0f, 40.0f, 20.0f)];
            self.maxCornerLabel.backgroundColor = [UIColor clearColor];
            self.maxCornerLabel.textAlignment = NSTextAlignmentCenter;
            self.maxCornerLabel.text = @"50.0px";
            self.maxCornerLabel.font = [UIFont fontWithName:MYRIADPRO size:rFontSize-2.0f];
            self.maxCornerLabel.adjustsFontSizeToFitWidth = YES;
            self.maxCornerLabel.minimumScaleFactor = 0.1f;
            self.maxCornerLabel.numberOfLines = 0;
            self.maxCornerLabel.textColor = [UIColor whiteColor];
            [self.cornerView addSubview:self.maxCornerLabel];
            
            self.cornerSlider = [[KZColorPickerWidthSlider alloc] initWithFrame:CGRectMake(40.0f,
                                                                                                 18.0f,
                                                                                                 self.frame.size.width-80.0f,
                                                                                                 20.0f)];
            [self.cornerSlider addTarget:self action:@selector(cornerChanged:) forControlEvents:UIControlEventValueChanged];
            [self.cornerView addSubview:self.cornerSlider];

            //border color picker
            self.colorLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0f, 150.0f, self.frame.size.width-5.0f, 20.0f)];
            self.colorLabel.backgroundColor = [UIColor clearColor];
            self.colorLabel.textAlignment = NSTextAlignmentLeft;
            self.colorLabel.text = @"Color";
            self.colorLabel.font = [UIFont fontWithName:MYRIADPRO size:rFontSize];
            self.colorLabel.adjustsFontSizeToFitWidth = YES;
            self.colorLabel.minimumScaleFactor = 0.1f;
            self.colorLabel.numberOfLines = 0;
            self.colorLabel.textColor = [UIColor whiteColor];
            [self addSubview:self.colorLabel];

            self.colorPickerView = [[KZColorPicker alloc] initWithFrame:CGRectMake(0, self.frame.size.height - (self.frame.size.width - 60), self.frame.size.width, self.frame.size.width - 60)];
            self.colorPickerView.selectedColor = self.objectBorderColor;
            self.colorPickerView.oldColor = self.objectBorderColor;
            [self.colorPickerView addTarget:self action:@selector(outlineColorPickerChanged:) forControlEvents:UIControlEventValueChanged];
            [self addSubview:self.colorPickerView];
            
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
            //border style table view
            self.borderStyleScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.frame.size.width*0.4f, 115.0f)];
            self.borderStyleScrollView.backgroundColor = [UIColor clearColor];
            [self addSubview:self.borderStyleScrollView];
            self.borderStyleScrollView.delegate = self;
            self.borderStyleScrollView.scrollEnabled = YES;
            self.borderStyleScrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;

            UIImageView* style_1_btn = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.borderStyleScrollView.frame.size.width, 30.0f)];
            style_1_btn.backgroundColor = [UIColor clearColor];
            style_1_btn.layer.masksToBounds = YES;
            style_1_btn.layer.borderColor = [UIColor whiteColor].CGColor;
            style_1_btn.layer.borderWidth = 0.5f;
            style_1_btn.layer.cornerRadius = 0.5f;
            style_1_btn.userInteractionEnabled = YES;
            [self.borderStyleScrollView addSubview:style_1_btn];
            style_1_btn.tag = 1;
            
            UILabel* label = [[UILabel alloc] initWithFrame:style_1_btn.bounds];
            label.lineBreakMode = NSLineBreakByWordWrapping;
            label.textAlignment = NSTextAlignmentCenter;
            label.backgroundColor = [UIColor clearColor];
            label.text = @"NO OUTLINE";
            label.textColor = [UIColor whiteColor];
            label.font = [UIFont fontWithName:MYRIADPRO size:rFontSize-2.0f];
            label.adjustsFontSizeToFitWidth = YES;
            label.minimumScaleFactor = 0.1f;
            label.numberOfLines = 0;
            [style_1_btn addSubview:label];
            
            UITapGestureRecognizer *selectGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectBorderStyle:)];
            selectGesture.delegate = self;
            [style_1_btn addGestureRecognizer:selectGesture];
            [selectGesture setNumberOfTapsRequired:1];
            
            UIImageView* style_2_btn = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 30.0f, self.borderStyleScrollView.frame.size.width, 30.0f)];
            [style_2_btn setImage:[UIImage imageNamed:@"style_ipad_2"]];
            style_2_btn.layer.masksToBounds = YES;
            style_2_btn.layer.borderColor = [UIColor whiteColor].CGColor;
            style_2_btn.layer.borderWidth = 0.5f;
            style_2_btn.layer.cornerRadius = 0.5f;
            style_2_btn.userInteractionEnabled = YES;
            [self.borderStyleScrollView addSubview:style_2_btn];
            style_2_btn.tag = 2;
            
            selectGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectBorderStyle:)];
            selectGesture.delegate = self;
            [style_2_btn addGestureRecognizer:selectGesture];
            [selectGesture setNumberOfTapsRequired:1];

            UIImageView* style_3_btn = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 60.0f, self.borderStyleScrollView.frame.size.width, 30.0f)];
            [style_3_btn setImage:[UIImage imageNamed:@"style_ipad_3"]];
            style_3_btn.layer.masksToBounds = YES;
            style_3_btn.layer.borderColor = [UIColor whiteColor].CGColor;
            style_3_btn.layer.borderWidth = 0.5f;
            style_3_btn.layer.cornerRadius = 0.5f;
            style_3_btn.userInteractionEnabled = YES;
            [self.borderStyleScrollView addSubview:style_3_btn];
            style_3_btn.tag = 3;

            selectGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectBorderStyle:)];
            selectGesture.delegate = self;
            [style_3_btn addGestureRecognizer:selectGesture];
            [selectGesture setNumberOfTapsRequired:1];
            
            UIImageView* style_4_btn = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 90.0f, self.borderStyleScrollView.frame.size.width, 30.0f)];
            [style_4_btn setImage:[UIImage imageNamed:@"style_ipad_4"]];
            style_4_btn.layer.masksToBounds = YES;
            style_4_btn.layer.borderColor = [UIColor whiteColor].CGColor;
            style_4_btn.layer.borderWidth = 0.5f;
            style_4_btn.layer.cornerRadius = 0.5f;
            style_4_btn.userInteractionEnabled = YES;
            [self.borderStyleScrollView addSubview:style_4_btn];
            style_4_btn.tag = 4;

            selectGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectBorderStyle:)];
            selectGesture.delegate = self;
            [style_4_btn addGestureRecognizer:selectGesture];
            [selectGesture setNumberOfTapsRequired:1];
            
            UIImageView* style_5_btn = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 120.0f, self.borderStyleScrollView.frame.size.width, 30.0f)];
            [style_5_btn setImage:[UIImage imageNamed:@"style_ipad_5"]];
            style_5_btn.layer.masksToBounds = YES;
            style_5_btn.layer.borderColor = [UIColor whiteColor].CGColor;
            style_5_btn.layer.borderWidth = 0.5f;
            style_5_btn.layer.cornerRadius = 0.5f;
            style_5_btn.userInteractionEnabled = YES;
            [self.borderStyleScrollView addSubview:style_5_btn];
            style_5_btn.tag = 5;

            selectGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectBorderStyle:)];
            selectGesture.delegate = self;
            [style_5_btn addGestureRecognizer:selectGesture];
            [selectGesture setNumberOfTapsRequired:1];
            
            UIImageView* style_6_btn = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 150.0f, self.borderStyleScrollView.frame.size.width, 30.0f)];
            [style_6_btn setImage:[UIImage imageNamed:@"style_ipad_6"]];
            style_6_btn.layer.masksToBounds = YES;
            style_6_btn.layer.borderColor = [UIColor whiteColor].CGColor;
            style_6_btn.layer.borderWidth = 0.5f;
            style_6_btn.layer.cornerRadius = 0.5f;
            style_6_btn.userInteractionEnabled = YES;
            [self.borderStyleScrollView addSubview:style_6_btn];
            style_6_btn.tag = 6;
            
            selectGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectBorderStyle:)];
            selectGesture.delegate = self;
            [style_6_btn addGestureRecognizer:selectGesture];
            [selectGesture setNumberOfTapsRequired:1];

            UIImageView* style_7_btn = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 180.0f, self.borderStyleScrollView.frame.size.width, 30.0f)];
            [style_7_btn setImage:[UIImage imageNamed:@"style_ipad_7"]];
            style_7_btn.layer.masksToBounds = YES;
            style_7_btn.layer.borderColor = [UIColor whiteColor].CGColor;
            style_7_btn.layer.borderWidth = 0.5f;
            style_7_btn.layer.cornerRadius = 0.5f;
            style_7_btn.userInteractionEnabled = YES;
            [self.borderStyleScrollView addSubview:style_7_btn];
            style_7_btn.tag = 7;
            
            selectGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectBorderStyle:)];
            selectGesture.delegate = self;
            [style_7_btn addGestureRecognizer:selectGesture];
            [selectGesture setNumberOfTapsRequired:1];
            
            UIImageView* style_8_btn = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 210.0f, self.borderStyleScrollView.frame.size.width, 30.0f)];
            [style_8_btn setImage:[UIImage imageNamed:@"style_ipad_8"]];
            style_8_btn.layer.masksToBounds = YES;
            style_8_btn.layer.borderColor = [UIColor whiteColor].CGColor;
            style_8_btn.layer.borderWidth = 0.5f;
            style_8_btn.layer.cornerRadius = 0.5f;
            style_8_btn.userInteractionEnabled = YES;
            [self.borderStyleScrollView addSubview:style_8_btn];
            style_8_btn.tag = 8;
            
            selectGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectBorderStyle:)];
            selectGesture.delegate = self;
            [style_8_btn addGestureRecognizer:selectGesture];
            [selectGesture setNumberOfTapsRequired:1];
            
            UIImageView* style_9_btn = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 240.0f, self.borderStyleScrollView.frame.size.width, 30.0f)];
            [style_9_btn setImage:[UIImage imageNamed:@"style_ipad_9"]];
            style_9_btn.layer.masksToBounds = YES;
            style_9_btn.layer.borderColor = [UIColor whiteColor].CGColor;
            style_9_btn.layer.borderWidth = 0.5f;
            style_9_btn.layer.cornerRadius = 0.5f;
            style_9_btn.userInteractionEnabled = YES;
            [self.borderStyleScrollView addSubview:style_9_btn];
            style_9_btn.tag = 9;
            
            selectGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectBorderStyle:)];
            selectGesture.delegate = self;
            [style_9_btn addGestureRecognizer:selectGesture];
            [selectGesture setNumberOfTapsRequired:1];
            
            UIImageView* style_10_btn = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 270.0f, self.borderStyleScrollView.frame.size.width, 30.0f)];
            [style_10_btn setImage:[UIImage imageNamed:@"style_ipad_10"]];
            style_10_btn.layer.masksToBounds = YES;
            style_10_btn.layer.borderColor = [UIColor whiteColor].CGColor;
            style_10_btn.layer.borderWidth = 0.5f;
            style_10_btn.layer.cornerRadius = 0.5f;
            style_10_btn.userInteractionEnabled = YES;
            [self.borderStyleScrollView addSubview:style_10_btn];
            style_10_btn.tag = 10;

            selectGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectBorderStyle:)];
            selectGesture.delegate = self;
            [style_10_btn addGestureRecognizer:selectGesture];
            [selectGesture setNumberOfTapsRequired:1];
            
            self.borderStyleScrollView.contentSize = CGSizeMake(self.borderStyleScrollView.frame.size.width, 300.0f);
            
            //border width view
            self.borderWidthView = [[UIView alloc] initWithFrame:CGRectMake(0, 115.0f, self.frame.size.width, 50.0f)];
            self.borderWidthView.backgroundColor = [UIColor clearColor];
            self.borderWidthView.layer.borderWidth = 1.0f;
            self.borderWidthView.layer.borderColor = [UIColor whiteColor].CGColor;
            [self addSubview:self.borderWidthView];
            
            self.borderWidthTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0f, 0.0f, self.frame.size.width-5.0f, 20.0f)];
            self.borderWidthTitleLabel.backgroundColor = [UIColor clearColor];
            self.borderWidthTitleLabel.textAlignment = NSTextAlignmentLeft;
            self.borderWidthTitleLabel.text = [NSString stringWithFormat:@"Width : %.1fpx", self.objectBorderWidth];
            self.borderWidthTitleLabel.font = [UIFont fontWithName:MYRIADPRO size:rFontSize];
            self.borderWidthTitleLabel.adjustsFontSizeToFitWidth = YES;
            self.borderWidthTitleLabel.minimumScaleFactor = 0.1f;
            self.borderWidthTitleLabel.numberOfLines = 0;
            self.borderWidthTitleLabel.textColor = [UIColor whiteColor];
            [self.borderWidthView addSubview:self.borderWidthTitleLabel];
            
            self.minPixelLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 25.0f, 40.0f, 20.0f)];
            self.minPixelLabel.backgroundColor = [UIColor clearColor];
            self.minPixelLabel.textAlignment = NSTextAlignmentCenter;
            self.minPixelLabel.text = @"0.0px";
            self.minPixelLabel.font = [UIFont fontWithName:MYRIADPRO size:rFontSize-2.0f];
            self.minPixelLabel.adjustsFontSizeToFitWidth = YES;
            self.minPixelLabel.minimumScaleFactor = 0.1f;
            self.minPixelLabel.numberOfLines = 0;
            self.minPixelLabel.textColor = [UIColor whiteColor];
            [self.borderWidthView addSubview:self.minPixelLabel];

            self.maxPixelLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width-40.0f, 25.0f, 40.0f, 20.0f)];
            self.maxPixelLabel.backgroundColor = [UIColor clearColor];
            self.maxPixelLabel.textAlignment = NSTextAlignmentCenter;
            self.maxPixelLabel.text = @"50.0px";
            self.maxPixelLabel.font = [UIFont fontWithName:MYRIADPRO size:rFontSize-2.0f];
            self.maxPixelLabel.adjustsFontSizeToFitWidth = YES;
            self.maxPixelLabel.minimumScaleFactor = 0.1f;
            self.maxPixelLabel.numberOfLines = 0;
            self.maxPixelLabel.textColor = [UIColor whiteColor];
            [self.borderWidthView addSubview:self.maxPixelLabel];

            self.borderWidthSlider = [[KZColorPickerWidthSlider alloc] initWithFrame:CGRectMake(40.0f,
                                                                                                                    25.0f,
                                                                                                                    self.frame.size.width-80.0f,
                                                                                                                    20.0f)];
            [self.borderWidthSlider addTarget:self action:@selector(widthChanged:) forControlEvents:UIControlEventValueChanged];
            [self.borderWidthView addSubview:self.borderWidthSlider];

            //corner view
            self.cornerView = [[UIView alloc] initWithFrame:CGRectMake(0, 165.0f, self.frame.size.width, 50.0f)];
            self.cornerView.backgroundColor = [UIColor clearColor];
            self.cornerView.layer.borderWidth = 1.0f;
            self.cornerView.layer.borderColor = [UIColor whiteColor].CGColor;
            [self addSubview:self.cornerView];
            
            self.cornerTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0f, 0.0f, self.frame.size.width-5.0f, 20.0f)];
            self.cornerTitleLabel.backgroundColor = [UIColor clearColor];
            self.cornerTitleLabel.textAlignment = NSTextAlignmentLeft;
            self.cornerTitleLabel.text = [NSString stringWithFormat:@"Corner : %.1fpx", self.objectCornerRadius];
            self.cornerTitleLabel.font = [UIFont fontWithName:MYRIADPRO size:rFontSize];
            self.cornerTitleLabel.adjustsFontSizeToFitWidth = YES;
            self.cornerTitleLabel.minimumScaleFactor = 0.1f;
            self.cornerTitleLabel.numberOfLines = 0;
            self.cornerTitleLabel.textColor = [UIColor whiteColor];
            [self.cornerView addSubview:self.cornerTitleLabel];
            
            self.minCornerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 25.0f, 40.0f, 20.0f)];
            self.minCornerLabel.backgroundColor = [UIColor clearColor];
            self.minCornerLabel.textAlignment = NSTextAlignmentCenter;
            self.minCornerLabel.text = @"0.0px";
            self.minCornerLabel.font = [UIFont fontWithName:MYRIADPRO size:rFontSize-2.0f];
            self.minCornerLabel.adjustsFontSizeToFitWidth = YES;
            self.minCornerLabel.minimumScaleFactor = 0.1f;
            self.minCornerLabel.numberOfLines = 0;
            self.minCornerLabel.textColor = [UIColor whiteColor];
            [self.cornerView addSubview:self.minCornerLabel];
            
            self.maxCornerLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width-40.0f, 25.0f, 40.0f, 20.0f)];
            self.maxCornerLabel.backgroundColor = [UIColor clearColor];
            self.maxCornerLabel.textAlignment = NSTextAlignmentCenter;
            self.maxCornerLabel.text = @"50.0px";
            self.maxCornerLabel.font = [UIFont fontWithName:MYRIADPRO size:rFontSize-2.0f];
            self.maxCornerLabel.adjustsFontSizeToFitWidth = YES;
            self.maxCornerLabel.minimumScaleFactor = 0.1f;
            self.maxCornerLabel.numberOfLines = 0;
            self.maxCornerLabel.textColor = [UIColor whiteColor];
            [self.cornerView addSubview:self.maxCornerLabel];
            
            self.cornerSlider = [[KZColorPickerWidthSlider alloc] initWithFrame:CGRectMake(40.0f,
                                                                                                 25.0f,
                                                                                                 self.frame.size.width-80.0f,
                                                                                                 20.0f)];
            [self.cornerSlider addTarget:self action:@selector(cornerChanged:) forControlEvents:UIControlEventValueChanged];
            [self.cornerView addSubview:self.cornerSlider];

            //color picker
            self.colorLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0f, 215.0f, self.frame.size.width-5.0f, 20.0f)];
            self.colorLabel.backgroundColor = [UIColor clearColor];
            self.colorLabel.textAlignment = NSTextAlignmentLeft;
            self.colorLabel.text = @"Color";
            self.colorLabel.font = [UIFont fontWithName:MYRIADPRO size:rFontSize];
            self.colorLabel.adjustsFontSizeToFitWidth = YES;
            self.colorLabel.minimumScaleFactor = 0.1f;
            self.colorLabel.numberOfLines = 0;
            self.colorLabel.textColor = [UIColor whiteColor];
            [self addSubview:self.colorLabel];

            self.colorPickerView = [[KZColorPicker alloc] initWithFrame:CGRectMake(0, self.frame.size.height - (self.frame.size.width - 70), self.frame.size.width, self.frame.size.width - 70)];
            self.colorPickerView.selectedColor = self.objectBorderColor;
            self.colorPickerView.oldColor = self.objectBorderColor;
            [self.colorPickerView addTarget:self action:@selector(outlineColorPickerChanged:) forControlEvents:UIControlEventValueChanged];
            [self addSubview:self.colorPickerView];

            //leftbox view
            self.leftBoxView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height-40, 40, 40)];
            self.leftBoxView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"leftBox"]];
            self.leftBoxView.userInteractionEnabled = YES;
            [self addSubview:self.leftBoxView];
            
            UIPanGestureRecognizer* moveGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(outlineMenuMove:)];
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
        
        self.recentColorScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(self.frame.size.width*0.4f + 5.0f, 20.0f + originY, self.frame.size.width*0.6f - 10.0f, self.borderWidthView.frame.origin.y - (22.0f + originY))];
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
    [self.borderWidthTitleLabel setText:[NSString stringWithFormat:@"Width : %.1fpx", self.objectBorderWidth]];
    [self.cornerTitleLabel setText:[NSString stringWithFormat:@"Corner : %.1fpx", self.objectCornerRadius]];
    [self.borderWidthSlider setValue:(1.0f-self.objectBorderWidth/50.0f)];
    [self.borderWidthSlider setKeyColor:self.objectBorderColor];
    [self.borderWidthSlider changeSliderRange];
    [self.cornerSlider setValue:(1.0f-self.objectCornerRadius/50.0f)];
    [self.cornerSlider setKeyColor:self.objectBorderColor];
    [self.cornerSlider changeSliderRange];
    [self.colorPickerView setOldColor:self.objectBorderColor];
    [self.colorPickerView setSelectedColor:self.objectBorderColor];
    self.leftBoxView.backgroundColor = [UIColor colorWithPatternImage:[[UIImage imageNamed:@"leftBox"] imageWithOverlayColor:self.objectBorderColor]];
    self.colorPreviewView.backgroundColor = self.objectBorderColor;

    NSString* hexString = [self.objectBorderColor hexStringFromColor];
    self.hexTextField.text = [hexString uppercaseString];

    for (UIImageView* imageView in self.borderStyleScrollView.subviews)
    {
        if ([imageView tag] > 0)
        {
            if ([imageView tag] == self.objectBorderStyle)
            {
                [imageView setBackgroundColor:UIColorFromRGB(0x9da1a0)];
                imageView.layer.borderColor = [UIColor whiteColor].CGColor;
                imageView.layer.borderWidth = 2.0f;
                imageView.layer.cornerRadius = 2.0f;
            }
            else
            {
                [imageView setBackgroundColor:[UIColor clearColor]];
                imageView.layer.borderColor = [UIColor whiteColor].CGColor;
                imageView.layer.borderWidth = 0.5f;
                imageView.layer.cornerRadius = 0.5f;
            }
        }
    }
    
    [self updateRecentColorScrollView];
}

-(void) changeMaxCornerValue:(CGFloat) maxValue
{
    self.maxCornerValue = maxValue;
    self.maxCornerLabel.text = [NSString stringWithFormat:@"%.1fpx", self.maxCornerValue];
    self.cornerTitleLabel.text = [NSString stringWithFormat:@"Corner : %.1fpx", self.objectCornerRadius];
    [self.cornerSlider setValue:(1.0f-self.objectCornerRadius/self.maxCornerValue)];
    [self.cornerSlider changeSliderRange];
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
#pragma mark - ColorPicker Changed

- (void) outlineColorPickerChanged:(KZColorPicker *)cp
{
    self.objectBorderColor = cp.selectedColor;
	[self.borderWidthSlider setKeyColor:self.objectBorderColor];
	[self.cornerSlider setKeyColor:self.objectBorderColor];
    self.leftBoxView.backgroundColor = [UIColor colorWithPatternImage:[[UIImage imageNamed:@"leftBox"] imageWithOverlayColor:self.objectBorderColor]];
    self.colorPreviewView.backgroundColor = self.objectBorderColor;
    
    NSString* hexString = [self.objectBorderColor hexStringFromColor];
    self.hexTextField.text = [hexString uppercaseString];
    
    [self changeBorder];
    [self deleteDesabled];
}


#pragma mark -
#pragma mark - Border Width Slider Changed

- (void) widthChanged:(KZColorPickerWidthSlider *)slider
{
    [self.borderWidthSlider changeSliderRange];
    self.objectBorderWidth = (1.0f-self.borderWidthSlider.value)*50.0f;
    self.borderWidthTitleLabel.text = [NSString stringWithFormat:@"Width : %.1fpx", self.objectBorderWidth];
    [self changeBorder];
}


#pragma mark -
#pragma mark - Corner Slider Changed

- (void) cornerChanged:(KZColorPickerWidthSlider *)slider
{
    [self.cornerSlider changeSliderRange];
    self.objectCornerRadius = (1.0f-self.cornerSlider.value)*self.maxCornerValue;
    self.cornerTitleLabel.text = [NSString stringWithFormat:@"Corner : %.1fpx", self.objectCornerRadius];
    [self changeBorder];
}


#pragma mark -
#pragma mark - Border Style Changed

- (void) selectBorderStyle:(UITapGestureRecognizer*) recognizer
{
    self.objectBorderStyle = (int)[(UIImageView*)recognizer.view tag];
    
    for (UIImageView* imageView in self.borderStyleScrollView.subviews)
    {
        if ([imageView tag] > 0)
        {
            if ([imageView tag] == self.objectBorderStyle)
            {
                [imageView setBackgroundColor:UIColorFromRGB(0x9da1a0)];
                imageView.layer.borderColor = [UIColor whiteColor].CGColor;
                imageView.layer.borderWidth = 2.0f;
                imageView.layer.cornerRadius = 2.0f;
            }
            else
            {
                [imageView setBackgroundColor:[UIColor clearColor]];
                imageView.layer.borderColor = [UIColor whiteColor].CGColor;
                imageView.layer.borderWidth = 0.5f;
                imageView.layer.cornerRadius = 0.5f;
            }
        }
    }
    
    [self changeBorder];
}

- (void) changeBorder
{
    if ([self.delegate respondsToSelector:@selector(changeBorder:borderColor:borderWidth:cornerRadius:)])
    {
        [self.delegate changeBorder:self.objectBorderStyle borderColor:self.objectBorderColor borderWidth:self.objectBorderWidth cornerRadius:self.objectCornerRadius];
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
    
    self.objectBorderColor = [UIColor colorWithHexString:textField.text];
    [self.colorPickerView setOldColor:self.objectBorderColor];
    [self.colorPickerView setSelectedColor:self.objectBorderColor];
    [self.borderWidthSlider setKeyColor:self.objectBorderColor];
    [self.cornerSlider setKeyColor:self.objectBorderColor];
    self.leftBoxView.backgroundColor = [UIColor colorWithPatternImage:[[UIImage imageNamed:@"leftBox"] imageWithOverlayColor:self.objectBorderColor]];
    self.colorPreviewView.backgroundColor = self.objectBorderColor;
    
    NSString* hexString = [self.objectBorderColor hexStringFromColor];
    self.hexTextField.text = [hexString uppercaseString];
    
    [self changeBorder];
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
        {
            return YES;
        }
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
    NSString* hexString = [self.objectBorderColor hexStringFromColor];
    hexString = [hexString uppercaseString];

    //if current hex string is exist on recent color array, then return. else if then add current hex string to recent color array
    for (int i=0; i<gaRecentColorArray.count; i++)
    {
        NSString* recentString = [gaRecentColorArray objectAtIndex:i];
        
        if ([hexString isEqualToString:recentString])
        {
            return;
        }
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
    {
        height = height*2.0f;
    }
    
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
    
    self.objectBorderColor = [UIColor colorWithHexString:colorString];
    [self.borderWidthSlider setKeyColor:self.objectBorderColor];
    [self.cornerSlider setKeyColor:self.objectBorderColor];
    self.leftBoxView.backgroundColor = [UIColor colorWithPatternImage:[[UIImage imageNamed:@"leftBox"] imageWithOverlayColor:self.objectBorderColor]];
    self.colorPreviewView.backgroundColor = self.objectBorderColor;
    [self.colorPickerView setOldColor:self.objectBorderColor];
    [self.colorPickerView setSelectedColor:self.objectBorderColor];
    self.hexTextField.text = colorString;
    
    [self changeBorder];
}

-(void) deleteColor:(NSInteger) colorIndex
{
    [gaRecentColorArray removeObjectAtIndex:(colorIndex-1)];

    [self updateRecentColorScrollView];
    
    for (RecentColorView* view in self.recentColorScrollView.subviews)
    {
        if (view.tag > 0)
        {
            view.deleteBtn.hidden = NO;
        }
    }
}

-(void) deleteColorEnabled
{
    for (RecentColorView* view in self.recentColorScrollView.subviews)
    {
        if (view.tag > 0)
        {
            view.deleteBtn.hidden = NO;
        }
    }
}

-(void) deleteDesabled
{
    for (RecentColorView* view in self.recentColorScrollView.subviews)
    {
        if (view.tag > 0)
        {
            view.deleteBtn.hidden = YES;
        }
    }
}

-(void) tapGesture:(UITapGestureRecognizer*) gesture
{
    [self deleteDesabled];
}

@end