//
//  ProjectGalleryPickerController.h
//  VideoFrame
//
//  Created by YinjingLi on 1/14/15.
//  Copyright (c) 2015 Yinjing Li. All rights reserved.
//

#import <UIKit/UIKit.h>


@import Photos;


@protocol ProjectGalleryPickerControllerDelegate;


@interface ProjectGalleryPickerController : UINavigationController

@property (nonatomic, weak) id <ProjectGalleryPickerControllerDelegate, UINavigationControllerDelegate> projectGalleryPickerDelegate;

@property(nonatomic, assign) BOOL isBackup;

@end


@protocol ProjectGalleryPickerControllerDelegate <NSObject>

@optional

-(void) projectGalleryPickerControllerDidCancel:(ProjectGalleryPickerController *)picker;

@end
