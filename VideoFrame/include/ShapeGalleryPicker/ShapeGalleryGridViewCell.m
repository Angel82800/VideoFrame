//
//  AAPLGridViewCell.m
//  VideoFrame
//
//  Created by Yinjing Li on 9/22/14.
//  Copyright (c) 2014 Yinjing Li. All rights reserved.
//

#import "ShapeGalleryGridViewCell.h"
#import "Definition.h"

@interface ShapeGalleryGridViewCell ()

@property (strong) IBOutlet UIImageView* imageView;

@end


@implementation ShapeGalleryGridViewCell


- (void)awakeFromNib
{

    [super awakeFromNib];
}

- (void)setThumbnailImage:(UIImage *)thumbnailImage
{
    _thumbnailImage = thumbnailImage;
    self.imageView.image = thumbnailImage;
}



@end
