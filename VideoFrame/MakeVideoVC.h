//
//  MakeVideoVC.h
//  VideoFrame
//
//  Created by Yinjing Li on 11/13/13.
//  Copyright (c) 2013 Yinjing Li. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>

@import Photos;


@class CustomModalView;
@class VideoEditor;
@class PreviewView;
@class MediaTrimView;
@class TimelineView;
@class OutlineView;
@class ShadowView;
@class TextSettingView;
@class ReflectionSettingView;
@class AVChooseView;
@class SpeedSegmentView;
@class JogEditView;
@class SettingsView;
@class ATMHud;
@class OpacityView;
@class VolumeView;
@class YJLCameraPickerController;
@class ProjectManager;
@class TimelineHorizontalView;
@class TimelineVerticalView;
@class PhotoFiltersView;
@class KBSettingsView;
@class ShapeColorView;
@class ProjectGalleryPickerController;
@class VideoFiltersView;
@class FilterListView;
@class ChromakeySettingView;
@class EditTrimView;


@interface MakeVideoVC : UIViewController
{
    BOOL isMultiplePhotos;
    BOOL isReplace;
    
    int nGifProcessingIndex;
    int mnPlaybackCount;
    
    NSMutableArray* gifProcessingIndexArray;
    
    ProjectGalleryPickerController* projectGalleryPicker;
    
    NSTimer* playbackTimer;
}


@property(nonatomic, strong) IBOutlet UIView* workspaceView;
@property(nonatomic, strong) IBOutlet UIView* editBtnsView;
@property(nonatomic, strong) IBOutlet UIView* editScrollBgView;

@property(nonatomic, strong) IBOutlet UIButton* timelineBtn;
@property(nonatomic, strong) IBOutlet UIButton* playingBtn;
@property(nonatomic, strong) IBOutlet UIButton* gridBtn;
@property(nonatomic, strong) IBOutlet UIButton* settingsBtn;
@property(nonatomic, strong) IBOutlet UIButton* infoBtn;
@property(nonatomic, strong) IBOutlet UIButton* saveBtn;
@property(nonatomic, strong) IBOutlet UIButton* a_vBtn;
@property(nonatomic, strong) IBOutlet UIButton* editRightBtn;
@property(nonatomic, strong) IBOutlet UIButton* editLeftBtn;

@property(nonatomic, strong) IBOutlet UILabel* totalTimeLabel;
@property(nonatomic, strong) IBOutlet UILabel* projectNameLabel;

@property(nonatomic, strong) IBOutlet UIScrollView* editScrollView;

@property(nonatomic, strong) IBOutlet KBSettingsView* kenBurnsSettingsView;

@property(nonatomic, strong) CAShapeLayer* gridLayer;
@property(nonatomic, strong) AVPlayer *videoPlayer;
@property(nonatomic, strong) AVPlayerLayer* videoPlayerLayer;
@property(nonatomic, strong) AVPlayerItem *playerItem;

@property(nonatomic, strong) CustomModalView* customModalView;
@property(nonatomic, strong) VideoEditor* videoEditor;
@property(nonatomic, strong) PreviewView* previewView;
@property(nonatomic, strong) MediaTrimView* mediaTrimView;
@property(nonatomic, strong) TimelineView* timelineView;
@property(nonatomic, strong) ShapeColorView* shapeColorView;
@property(nonatomic, strong) OutlineView* outlineView;
@property(nonatomic, strong) ChromakeySettingView* chromakeySettingView;
@property(nonatomic, strong) ShadowView* shadowView;
@property(nonatomic, strong) TextSettingView* textSettingView;
@property(nonatomic, strong) ReflectionSettingView* reflectionSettingView;
@property(nonatomic, strong) AVChooseView* avChooseView;
@property(nonatomic, strong) FilterListView* filterListView;
@property(nonatomic, strong) SpeedSegmentView* speedSegmentView;
@property(nonatomic, strong) JogEditView* jogEditView;
@property(nonatomic, strong) EditTrimView* editTrimView;
@property(nonatomic, strong) SettingsView* settingsView;
@property(nonatomic, strong) ATMHud *hudProgressView;
@property(nonatomic, strong) OpacityView* opacityView;
@property(nonatomic, strong) VolumeView* volumeView;
@property(nonatomic, strong) ProjectManager* projectManager;
@property(nonatomic, strong) TimelineHorizontalView* horizontalBgView;
@property(nonatomic, strong) TimelineVerticalView* verticalBgView;
@property(nonatomic, strong) PhotoFiltersView* photoFiltersView;
@property(nonatomic, strong) VideoFiltersView* videoFiltersView;
@property(nonatomic, strong) YJLCameraPickerController* cameraPickerController;

@property(nonatomic, strong) NSMutableArray* mediaObjectArray;
@property(nonatomic, strong) NSMutableArray* multiplePhotosArray;
@property(nonatomic, strong) NSMutableArray* editThumbnailArray;

@property(nonatomic, strong) NSURL* openInProjectVideoUrl;

@property(nonatomic, strong) MPMoviePlayerController* infoVideoPlayer;


-(void) fixAppOrientationAfterDismissImagePickerController;
-(void) fixDeviceOrientation;

@end
