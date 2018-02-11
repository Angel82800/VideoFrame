//
//  GIFGalleryPickerController.h
//  VideoFrame
//
//  Created by Yinjing Li on 6/18/15.
//  Copyright (c) 2015 Yinjing Li. All rights reserved.
//

#import <UIKit/UIKit.h>

@import Photos;


@protocol GIFGalleryPickerControllerDelegate;


@interface GIFGalleryPickerController : UINavigationController

@property (nonatomic, weak) id <GIFGalleryPickerControllerDelegate, UINavigationControllerDelegate> gifGalleryDelegate;

@end


@protocol GIFGalleryPickerControllerDelegate <NSObject>
- (void)gifGalleryPickerController:(GIFGalleryPickerController *)picker didFinishPickingGifPath:(NSString*) gifPath;
- (void)gifGalleryPickerControllerDidCancel:(GIFGalleryPickerController *)picker;
- (void)gifGalleryPickerController:(GIFGalleryPickerController *)picker failedWithError:(NSError *)error;
@end