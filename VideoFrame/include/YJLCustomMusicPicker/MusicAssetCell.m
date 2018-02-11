//
//  MusicAssetCell.m
//  VideoFrame
//
//  Created by Yinjing Li on 5/12/14.
//  Copyright (c) 2014 Yinjing Li. All rights reserved.
//

#import "MusicAssetCell.h"

@implementation MusicAssetCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
