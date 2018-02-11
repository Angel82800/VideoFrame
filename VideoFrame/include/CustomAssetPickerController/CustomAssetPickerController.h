//
//  CustomAssetPickerController.h
//  VideoFrame
//
//  Created by Yinjing Li on 9/22/14.
//  Copyright (c) 2014 Yinjing Li. All rights reserved.
//

#import <UIKit/UIKit.h>


@import Photos;


@protocol CustomAssetPickerControllerDelegate;


@interface CustomAssetPickerController : UINavigationController

@property (nonatomic, weak) id <CustomAssetPickerControllerDelegate, UINavigationControllerDelegate> customAssetDelegate;
@property (nonatomic) PHAssetMediaType filterType;
@property (nonatomic) BOOL isSingleOnly;


@end


@protocol CustomAssetPickerControllerDelegate <NSObject>

@optional

- (void)customAssetsPickerController:(CustomAssetPickerController *)picker didFinishPickingAssets:(NSArray *)assets;
- (void)customAssetsPickerController:(CustomAssetPickerController *)picker didFinishPickingMovies:(NSArray *)movies;
- (void)customAssetsPickerController:(CustomAssetPickerController *)picker didFinishPickingShapes:(NSArray *)indexArray;
- (void)customAssetsPickerControllerDidCancel:(CustomAssetPickerController *)picker;
- (void)customAssetsPickerController:(CustomAssetPickerController *)picker failedWithError:(NSError *)error;

@end