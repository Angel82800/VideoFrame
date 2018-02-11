//
//  MusicTrimView.h
//  VideoFrame
//
//  Created by Yinjing Li on 1/21/14.
//  Copyright (c) 2014 Yinjing Li. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <MediaPlayer/MediaPlayer.h>
#import <AssetsLibrary/AssetsLibrary.h>

#import "ALAssetsLibrary+CustomPhotoAlbum.h"
#import "SAVideoRangeSlider.h"
#import "CustomModalView.h"
#import "Definition.h"
#import "FDWaveformView.h"
#import "SHKActivityIndicator.h"
#import "ATMHudDelegate.h"
#import "ATMHud.h"
#import "ATMHudQueueItem.h"
#import "UIImageExtras.h"
#import "AppDelegate.h"
#import "YJLActionMenu.h"
#import "AudioPlayer.h"

@import CoreFoundation;


@protocol MediaTrimViewDelegate <NSObject>

@optional
-(void) didCompletedTrim:(NSURL*) mediaUrl type:(int)mediaType;
-(void) didCancelTrimUI;

@end


@interface MediaTrimView : UIView<SAVideoRangeSliderDelegate, UIGestureRecognizerDelegate, FDWaveformViewDelegate, ATMHudDelegate, CustomModalViewDelegate>
{
    int mnMediaType;
    int nCount;
    int mnVideoOrientation;
    
    BOOL mnSaveCopyFlag;
    BOOL isCameraVideo;
    BOOL isSameProgress;
    BOOL isExpertCancelled;
    
    CGFloat percentageDone;
    CGFloat prevPro;
    Float64 fakeTimeElapsed;
    
    CGSize reverseVideoSize;
    CGSize cropVideoSize;
    
    NSMutableArray* timesArray;
    
    NSTimer* progressTimer;
    
    NSTimeInterval prevTimeInterval;
    
    float lastPtForMusic;  
    float volume;

    
    //0408 Added By Yinjing
    BOOL isSeekInProgress;
    CMTime chaseTime;
    AVPlayerStatus playerCurrentItemStatus;
}



@property(nonatomic, weak) id <MediaTrimViewDelegate> delegate;

@property(nonatomic, strong) UIButton *trimBtn;
@property(nonatomic, strong) UIButton *playBtn;
@property(nonatomic, strong) UIButton *saveCheckBoxBtn;
@property(nonatomic, strong) UIButton *reverseCheckBoxBtn;

@property(nonatomic, strong) UIView* leftView;
@property(nonatomic, strong) UIView* rightView;

@property(nonatomic, strong) UIImageView* musicSymbolImageView;

@property(nonatomic, strong) UILabel* titleLabel;
@property(nonatomic, strong) UILabel* seekCurrentTimeLabel;
@property(nonatomic, strong) UILabel* seekTotalTimeLabel;

@property(nonatomic, strong) UISlider* seekSlider;

@property(nonatomic, strong) AVPlayerLayer *mediaPlayerLayer;
@property(nonatomic, strong) AVAsset *mediaAsset;
@property(nonatomic, strong) AVAssetExportSession *exportSession;

@property(nonatomic, strong) AVPlayerLayer *reverseAudioPlayerLayer;
@property(nonatomic, strong) AVAsset *reverseMediaAsset;

@property(nonatomic, strong) AudioPlayer * play;


@property(nonatomic, strong) AVAssetWriter *assetWriter;
@property(nonatomic, strong) AVAssetWriterInput* assetWriterInput;
@property(nonatomic, strong) AVAssetWriterInputPixelBufferAdaptor* assetWriterPixelBufferAdaptor;
@property(nonatomic, strong) AVAssetImageGenerator *imageGenerator;

@property(nonatomic, strong) NSURL *originalMediaUrl;
@property(nonatomic, strong) NSURL *tmpMediaUrl;
@property(nonatomic, strong) NSURL *originalUrl;
@property(nonatomic, strong) NSURL *reversedUrl;

@property(nonatomic, assign) CGFloat startTime;
@property(nonatomic, assign) CGFloat stopTime;

@property(nonatomic, assign) CGFloat showStartTime;
@property(nonatomic, assign) CGFloat showEndTime;
@property(nonatomic, assign) CGFloat lastScale;

@property(nonatomic, assign) CGFloat previousStartTime;
@property(nonatomic, assign) CGFloat previousEndTime;
@property(nonatomic, assign) CGFloat previousCenterTime;
@property(nonatomic, assign) double previousRealTime;


@property(nonatomic, assign) BOOL mnReverseFlag;
@property(nonatomic, assign) BOOL isPlaying;
@property(nonatomic, assign) BOOL isTempPlaying;
@property(nonatomic, assign)   int   nDirection;
@property(nonatomic, assign)     BOOL  bReverse;


@property(nonatomic, strong) SAVideoRangeSlider *myMediaRangeSlider;
@property(nonatomic, strong) FDWaveformView *waveform;
@property(nonatomic, strong) ATMHud *hudProgressView;
@property(nonatomic, strong) CustomModalView* customModalView;


-(id) initWithFrame:(CGRect)frame url:(NSURL*) mediaUrl type:(int)mediaType flag:(BOOL)isFromCamera;
-(int) getMediaType;

@end
