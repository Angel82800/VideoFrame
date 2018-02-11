//
//  GIFGalleryGridViewCell.h
//  VideoFrame
//
//  Created by Yinjing Li on 6/18/15.
//  Copyright (c) 2015 Yinjing Li. All rights reserved.
//

@import UIKit;
@import Photos;

@interface GIFGalleryGridViewCell : UICollectionViewCell

@property (nonatomic, assign) BOOL isSelected;

- (void)setThumbnailImageForGif:(UIImage *) thumbnailGIFImage;
- (void)didSelectedGIF:(BOOL) selected;

@end
