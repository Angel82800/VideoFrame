//
//  AAPLAssetGridViewController.h
//  VideoFrame
//
//  Created by Yinjing Li on 9/22/14.
//  Copyright (c) 2014 Yinjing Li. All rights reserved.
//

@import UIKit;
@import Photos;

@class ShapeGalleryPickerController;

@interface ShapeGalleryGridViewController : UICollectionViewController <UICollectionViewDelegateFlowLayout>
{
    
}

@property(nonatomic, weak) ShapeGalleryPickerController* shapeGalleryPickerController;


@end
