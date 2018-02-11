//
//  GIFGalleryGridViewCell.m
//  VideoFrame
//
//  Created by Yinjing Li on 6/18/15.
//  Copyright (c) 2015 Yinjing Li. All rights reserved.
//

#import "GIFGalleryGridViewCell.h"
#import "Definition.h"

@interface GIFGalleryGridViewCell ()

@property (strong) IBOutlet UIImageView* imageView;
@property (strong) IBOutlet UIImageView* selectedImageView;

@end


@implementation GIFGalleryGridViewCell


- (void)awakeFromNib
{
    self.isSelected = NO;
    self.selectedImageView.hidden = YES;
    [super awakeFromNib];
}

- (void)setThumbnailImageForGif:(UIImage *) thumbnailGIFImage
{
    self.imageView.image = thumbnailGIFImage;
}

- (void)didSelectedGIF:(BOOL) selected
{
    self.isSelected = selected;
    
    if (self.isSelected)
        self.selectedImageView.hidden = NO;
    else
        self.selectedImageView.hidden = YES;
}



@end
