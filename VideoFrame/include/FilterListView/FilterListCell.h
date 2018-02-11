//
//  FilterListCell.h
//  VideoFrame
//
//  Created by Yinjing Li on 12/1/13.
//  Copyright (c) 2013 Yinjing Li. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol filterSelectDelegate <NSObject>
@optional
-(void) filterPreviewDidSelected:(NSInteger) index;
-(void) filterApplyDidSelected:(NSInteger) index;

@end


@interface FilterListCell:UITableViewCell
{
    
}

@property(nonatomic, weak) id <filterSelectDelegate> delegate;

@property(nonatomic, strong) UIImageView* bgImageView;

@property(nonatomic, strong) UILabel* filterNameLabel;

@property(nonatomic, strong) UIButton* applyBtn;
@property(nonatomic, strong) UIButton* previewBtn;


-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier index:(NSInteger) nIndex;

-(void) reloadCell:(NSInteger) nIndex;


@end
