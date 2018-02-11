//
//  ProjectCell.m
//  VideoFrame
//
//  Created by YinjingLi on 1/14/15.
//  Copyright (c) 2015 Yinjing Li. All rights reserved.
//

#import "ProjectCell.h"

@implementation ProjectCell


- (void)awakeFromNib
{
    // Initialization code
    
    [self.projectNameLabel setAdjustsFontSizeToFitWidth:YES];
    [self.projectNameLabel setMinimumScaleFactor:0.1f];
    
    self.backgroundColor = [UIColor clearColor];
    
    self.isSelected = NO;
    [super awakeFromNib];
}

-(void) didSelected:(BOOL) select
{
    if (select)
    {
        [self.selectImageView setImage:[UIImage imageNamed:@"dark_check_on"]];
    }
    else
    {
        [self.selectImageView setImage:[UIImage imageNamed:@"dark_check_off"]];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    if (selected)
    {
        self.isSelected = !self.isSelected;

        [self didSelected:self.isSelected];
    }
}


@end
