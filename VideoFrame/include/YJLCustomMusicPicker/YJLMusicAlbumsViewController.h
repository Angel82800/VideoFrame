//
//  YJLMusicAlbumsViewController.h
//  VideoFrame
//
//  Created by Yinjing Li on 5/12/14.
//  Copyright (c) 2014 Yinjing Li. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <AssetsLibrary/AssetsLibrary.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>


@protocol YJLMusicAlbumsViewControllerDelegate;

@interface YJLMusicAlbumsViewController : UIViewController
{
    BOOL isEdit;
}

@property (nonatomic, weak) id <YJLMusicAlbumsViewControllerDelegate> delegate;
@property (nonatomic, strong) UITableView *collectionTableView;
@property (nonatomic, strong) UITableView *musicTableView;
@property (nonatomic, strong) UITabBar* albumsTabbar;
@property (nonatomic, strong) UIButton* sortBtn;
@property (nonatomic, strong) UIButton* editBtn;
@property (nonatomic, strong) NSURL* assetUrl;

@end


@protocol YJLMusicAlbumsViewControllerDelegate <NSObject>
- (void)musicSelected:(NSURL*) assetUrl;
- (void)musicAlbumsViewControllerDidCancel;
@end