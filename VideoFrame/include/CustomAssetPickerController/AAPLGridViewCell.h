//
//  AAPLGridViewCell.h
//  VideoFrame
//
//  Created by Yinjing Li on 9/22/14.
//  Copyright (c) 2014 Yinjing Li. All rights reserved.
//

@import UIKit;
@import Photos;


@protocol AAPLGridViewCellDelegate;

@interface AAPLGridViewCell : UICollectionViewCell
{

}

@property (nonatomic, weak) id <AAPLGridViewCellDelegate> delegate;

@property (nonatomic, strong) IBOutlet UIButton* videoThumbMenuBtn;
@property (strong, nonatomic) IBOutlet UILabel* videoNameLabel;

@property (nonatomic, strong) UIImage *thumbnailImage;
@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, assign) BOOL isSlowMo;

@property (nonatomic, assign) NSInteger cellIndex;

- (void)setPixelLabelString:(NSString*) string;
- (void)setSizeLabelString:(NSString*) string;
- (void)setDurationLabelString:(NSString*) string;
- (void)setFileNameLabelString:(NSString*) string;
- (void)hideGrayBgView;
- (void)markSelectedCheck:(BOOL) selected;
- (void)changeContentForShape;
- (void)hideVideoThumbnailMenuBtn;

@end

@protocol AAPLGridViewCellDelegate <NSObject>
- (void)didSelectedThumbMenuBtn:(AAPLGridViewCell*) cell;

@end