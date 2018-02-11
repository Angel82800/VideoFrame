//
//  ProjectCell.h
//  VideoFrame
//
//  Created by YinjingLi on 1/14/15.
//  Copyright (c) 2015 Yinjing Li. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProjectCell : UITableViewCell


@property(nonatomic, strong) IBOutlet UIImageView* projectThumbImageView;
@property(nonatomic, strong) IBOutlet UILabel* projectNameLabel;
@property(nonatomic, strong) IBOutlet UIImageView* selectImageView;

@property(nonatomic, assign) BOOL isSelected;


-(void) didSelected:(BOOL) select;

@end
