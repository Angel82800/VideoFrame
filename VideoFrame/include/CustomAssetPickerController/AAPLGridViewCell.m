//
//  AAPLGridViewCell.m
//  VideoFrame
//
//  Created by Yinjing Li on 9/22/14.
//  Copyright (c) 2014 Yinjing Li. All rights reserved.
//

#import "AAPLGridViewCell.h"
#import "Definition.h"


@interface AAPLGridViewCell ()

@property (strong, nonatomic) IBOutlet UIImageView* imageView;
@property (strong) IBOutlet UIImageView* selectedCheckImageView;

@property (strong) IBOutlet UIView* grayBgView;

@property (strong) IBOutlet UILabel* pixelLabel;
@property (strong) IBOutlet UILabel* sizeLabel;
@property (strong) IBOutlet UILabel* durationLabel;

@end


@implementation AAPLGridViewCell


- (void)awakeFromNib
{
    self.isSelected = NO;
    self.isSlowMo = NO;
    
    self.selectedCheckImageView.hidden = YES;

    self.pixelLabel.shadowColor = [UIColor blackColor];
    self.pixelLabel.shadowOffset = CGSizeMake(0.5f, 0.5f);

    self.sizeLabel.shadowColor = [UIColor blackColor];
    self.sizeLabel.shadowOffset = CGSizeMake(0.5f, 0.5f);
    
    self.durationLabel.shadowColor = [UIColor blackColor];
    self.durationLabel.shadowOffset = CGSizeMake(0.5f, 0.5f);

    self.videoNameLabel.shadowColor = [UIColor blackColor];
    self.videoNameLabel.shadowOffset = CGSizeMake(0.5f, 0.5f);

    self.videoNameLabel.minimumScaleFactor = 0.1f;
    self.videoNameLabel.adjustsFontSizeToFitWidth = YES;
    [super awakeFromNib];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.imageView.image = nil;
}

- (void)changeContentForShape
{
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
}

- (void)setThumbnailImage:(UIImage *)thumbnailImage
{
    _thumbnailImage = thumbnailImage;
    self.imageView.image = thumbnailImage;
}

- (void)setPixelLabelString:(NSString*) string
{
    self.pixelLabel.text = string;
}

- (void)setSizeLabelString:(NSString*) string
{
    self.sizeLabel.text = string;
}

- (void)setDurationLabelString:(NSString*) string
{
    self.durationLabel.text = string;
}

- (void)setFileNameLabelString:(NSString*) string
{
    self.videoNameLabel.text = string;
}

- (void)hideGrayBgView
{
    self.grayBgView.hidden = YES;
}

- (void)hideVideoThumbnailMenuBtn
{
    self.videoThumbMenuBtn.hidden = YES;
}

- (void)markSelectedCheck:(BOOL) selected
{
    self.isSelected = selected;
    
    if (selected) {
        self.selectedCheckImageView.hidden = NO;
    }
    else{
        self.selectedCheckImageView.hidden = YES;
    }
}

-(IBAction)actionVideoThumbMenu:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(didSelectedThumbMenuBtn:)])
    {
        [self.delegate didSelectedThumbMenuBtn:self];
    }
}


@end
