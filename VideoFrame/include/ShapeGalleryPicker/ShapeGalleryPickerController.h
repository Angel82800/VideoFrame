//
//  ShapeGalleryPickerController.h
//  VideoFrame
//
//  Created by Yinjing Li on 9/22/14.
//  Copyright (c) 2014 Yinjing Li. All rights reserved.
//

#import <UIKit/UIKit.h>

@import Photos;


@protocol ShapeGalleryPickerControllerDelegate;


@interface ShapeGalleryPickerController : UINavigationController

@property (nonatomic, weak) id <ShapeGalleryPickerControllerDelegate, UINavigationControllerDelegate> shapeGalleryDelegate;

@end


@protocol ShapeGalleryPickerControllerDelegate <NSObject>
- (void)shapeGalleryPickerController:(ShapeGalleryPickerController *)picker didFinishPickingIndex:(NSInteger)index;
- (void)shapeGalleryPickerControllerDidCancel:(ShapeGalleryPickerController *)picker;
- (void)shapeGalleryPickerController:(ShapeGalleryPickerController *)picker failedWithError:(NSError *)error;
@end