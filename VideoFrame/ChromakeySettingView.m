//
//  OutlineView.m
//  VideoFrame
//
//  Created by Yinjing Li on 3/6/14.
//  Copyright (c) 2014 Yinjing Li. All rights reserved.
//


#import "ChromakeySettingView.h"
#import <QuartzCore/QuartzCore.h>


@implementation ChromakeySettingView


#pragma mark - init

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.selectedChromakeyColor = [UIColor greenColor];
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 10.0f, 250.0f, 20.0f)];
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.text = @"Chromakey Color";
        self.titleLabel.font = [UIFont fontWithName:MYRIADPRO size:14.0f];
        self.titleLabel.adjustsFontSizeToFitWidth = YES;
        self.titleLabel.minimumScaleFactor = 0.1f;
        self.titleLabel.numberOfLines = 0;
        self.titleLabel.textColor = [UIColor whiteColor];
        [self addSubview:self.titleLabel];
        
        self.selectedColorLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 45.0f, 100.0f, 20.0f)];
        self.selectedColorLabel.backgroundColor = [UIColor clearColor];
        self.selectedColorLabel.textAlignment = NSTextAlignmentCenter;
        self.selectedColorLabel.text = @"Selected Color:";
        self.selectedColorLabel.font = [UIFont fontWithName:MYRIADPRO size:12.0f];
        self.selectedColorLabel.adjustsFontSizeToFitWidth = YES;
        self.selectedColorLabel.minimumScaleFactor = 0.1f;
        self.selectedColorLabel.numberOfLines = 0;
        self.selectedColorLabel.textColor = [UIColor whiteColor];
        [self addSubview:self.selectedColorLabel];
        
        self.selectedColorView = [[UIView alloc] initWithFrame:CGRectMake(100.0f, 40.0f, 30.0f, 30.0f)];
        self.selectedColorView.backgroundColor = [UIColor greenColor];
        self.selectedColorView.layer.borderColor = [UIColor whiteColor].CGColor;
        self.selectedColorView.layer.borderWidth = 1.0f;
        [self addSubview:self.selectedColorView];
        
        self.redBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.redBtn setFrame:CGRectMake(35.0f, 90.0f, 40.0f, 40.0f)];
        [self.redBtn setBackgroundColor:[UIColor redColor]];
        [self.redBtn addTarget:self action:@selector(actionRed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.redBtn];

        self.greenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.greenBtn setFrame:CGRectMake(105.0f, 90.0f, 40.0f, 40.0f)];
        [self.greenBtn setBackgroundColor:[UIColor greenColor]];
        [self.greenBtn addTarget:self action:@selector(actionGreen:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.greenBtn];
        self.greenBtn.layer.borderWidth = 1.0f;
        self.greenBtn.layer.borderColor = [UIColor whiteColor].CGColor;

        self.blueBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.blueBtn setFrame:CGRectMake(175.0f, 90.0f, 40.0f, 40.0f)];
        [self.blueBtn setBackgroundColor:[UIColor blueColor]];
        [self.blueBtn addTarget:self action:@selector(actionBlue:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.blueBtn];
    }
    
    return self;
}

-(void) actionRed:(id) sender
{
    self.redBtn.layer.borderWidth = 1.0f;
    self.redBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    
    self.greenBtn.layer.borderColor = [UIColor clearColor].CGColor;
    self.blueBtn.layer.borderColor = [UIColor clearColor].CGColor;

    self.selectedColorView.backgroundColor = [UIColor redColor];

    self.selectedChromakeyColor = [UIColor redColor];
    
    [self changeColor];
}

-(void) actionGreen:(id) sender
{
    self.greenBtn.layer.borderWidth = 1.0f;
    self.greenBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    
    self.redBtn.layer.borderColor = [UIColor clearColor].CGColor;
    self.blueBtn.layer.borderColor = [UIColor clearColor].CGColor;

    self.selectedColorView.backgroundColor = [UIColor greenColor];

    self.selectedChromakeyColor = [UIColor greenColor];

    [self changeColor];
}

-(void) actionBlue:(id) sender
{
    self.blueBtn.layer.borderWidth = 1.0f;
    self.blueBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    
    self.redBtn.layer.borderColor = [UIColor clearColor].CGColor;
    self.greenBtn.layer.borderColor = [UIColor clearColor].CGColor;

    self.selectedColorView.backgroundColor = [UIColor blueColor];

    self.selectedChromakeyColor = [UIColor blueColor];

    [self changeColor];
}

- (void) initialize
{
    [self.selectedColorView setBackgroundColor:self.selectedChromakeyColor];

    const CGFloat* components = CGColorGetComponents(self.selectedChromakeyColor.CGColor);

    if ((components[0] == 1.0f)&&(components[1] == 0.0f) &&(components[2] == 0.0f))     //red
    {
        self.redBtn.layer.borderWidth = 1.0f;
        self.redBtn.layer.borderColor = [UIColor whiteColor].CGColor;
        
        self.greenBtn.layer.borderColor = [UIColor clearColor].CGColor;
        self.blueBtn.layer.borderColor = [UIColor clearColor].CGColor;
    }
    else if ((components[0] == 0.0f)&&(components[1] == 1.0f) &&(components[2] == 0.0f))    //green
    {
        self.greenBtn.layer.borderWidth = 1.0f;
        self.greenBtn.layer.borderColor = [UIColor whiteColor].CGColor;
        
        self.redBtn.layer.borderColor = [UIColor clearColor].CGColor;
        self.blueBtn.layer.borderColor = [UIColor clearColor].CGColor;
    }
    else if ((components[0] == 0.0f)&&(components[1] == 0.0f) &&(components[2] == 1.0f))    //blue
    {
        self.blueBtn.layer.borderWidth = 1.0f;
        self.blueBtn.layer.borderColor = [UIColor whiteColor].CGColor;
        
        self.redBtn.layer.borderColor = [UIColor clearColor].CGColor;
        self.greenBtn.layer.borderColor = [UIColor clearColor].CGColor;
    }

}

- (void) changeColor
{
    if ([self.delegate respondsToSelector:@selector(changeChromakeyColor:)])
    {
        [self.delegate changeChromakeyColor:self.selectedChromakeyColor];
    }
}


@end