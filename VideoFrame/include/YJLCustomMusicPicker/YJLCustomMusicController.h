//
//  YJLCustomMusicController.h
//  VideoFrame
//
//  Created by Yinjing Li on 5/12/14.
//  Copyright (c) 2014 Yinjing Li. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "YJLMusicAlbumsViewController.h"


@protocol YJLCustomMusicControllerDelegate;

@interface YJLCustomMusicController : UINavigationController<YJLMusicAlbumsViewControllerDelegate>
{
    YJLMusicAlbumsViewController* musicAlbumsVC;
}

@property(nonatomic, weak) id <YJLCustomMusicControllerDelegate, UINavigationControllerDelegate> customMusicDelegate;
@property(nonatomic, strong) NSURL* assetUrl;

@end


@protocol YJLCustomMusicControllerDelegate <NSObject>
- (void)musicPickerControllerDidSelected:(YJLCustomMusicController *)picker asset:(NSURL *)assetUrl;
- (void)musicPickerControllerDidCancel:(YJLCustomMusicController *)picker;
@end