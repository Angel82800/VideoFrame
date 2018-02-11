//
//  SelectTemplateVC.h
//  VideoFrame
//
//  Created by Yinjing Li on 11/13/13.
//  Copyright (c) 2013 Yinjing Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@import Photos;

@class MakeVideoVC;
@class CustomModalView;
@class SettingsView;
@class iCarousel;
@class CustomAssetPickerController;
@class ProjectGalleryPickerController;


@interface SelectTemplateVC : UIViewController
{
    BOOL isDeleteBtnShow;
    
    CustomAssetPickerController* customAssetPicker;
    ProjectGalleryPickerController* projectGalleryPicker;
}

@property(nonatomic, strong) IBOutlet UIButton* tempLandscapeBtn;
@property(nonatomic, strong) IBOutlet UIButton* tempPortraitBtn;
@property(nonatomic, strong) IBOutlet UIButton* tempInstagramBtn;
@property(nonatomic, strong) IBOutlet UIButton* settingsBtn;
@property(nonatomic, strong) IBOutlet UIButton* infoBtn;
@property(nonatomic, strong) IBOutlet UIButton* playBtn;

@property(nonatomic, strong) IBOutlet UILabel* settingLbl;
@property(nonatomic, strong) IBOutlet UILabel* infoLbl;

@property(nonatomic, strong) IBOutlet UIView* projectView;

@property(nonatomic, strong) IBOutlet UILabel* templateLabel;
@property(nonatomic, strong) IBOutlet UILabel* playLabel;
@property(nonatomic, strong) IBOutlet UILabel* savedProjectLabel;
@property(nonatomic, strong) IBOutlet UILabel* versionLabel;

@property(nonatomic, strong) MakeVideoVC* makeVideoVC;
@property(nonatomic, strong) CustomModalView* customModalView;
@property(nonatomic, strong) SettingsView* settingsView;
@property(nonatomic, strong) iCarousel* projectCarousel;

@property(nonatomic, strong) NSMutableArray* projectNamesArray;
@property(nonatomic, strong) NSMutableArray* projectThumbViewArray;

@property(nonatomic, strong) PHAsset* openInProjectVideoAsset;
@property(nonatomic, strong) NSURL* openInProjectVideoUrl;

@property(nonatomic, strong) MPMoviePlayerController* infoVideoPlayer;


-(void) detectFramePerSec;

@end
