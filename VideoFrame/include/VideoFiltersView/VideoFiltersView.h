//
//  VideoFiltersView.h
//  VideoFrame
//
//  Created by Yinjing Li on 02/20/15.
//  Copyright (c) 2015 Yinjing Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/UTCoreTypes.h>

#import "GPUImage.h"
#import "GPUImageMovieComposition.h"
#import "VideoFilterThumbView.h"
#import "ATMHudDelegate.h"
#import "ATMHud.h"
#import "ATMHudQueueItem.h"
#import "AppDelegate.h"
#import "CustomModalView.h"
#import <MediaPlayer/MediaPlayer.h>


@import Photos;

@protocol VideoFiltersViewDelegate <NSObject>

@optional
-(void) didCancelVideoFilterUI;
-(void) didApplyVideoFilter:(NSURL*) url;
@end


#define APPLY_NONE 0
#define APPLY_FILTER 1

@interface VideoFiltersView : UIView<UINavigationControllerDelegate, VideoFilterThumbViewDelegate, ATMHudDelegate, CustomModalViewDelegate>
{
    CGFloat thumbWidth;
    CGFloat thumbHeight;
    
    BOOL isPhotoTake;
}

@property(nonatomic, weak) id <VideoFiltersViewDelegate> delegate;

@property(nonatomic, strong) GPUImageView* filterView;
@property(nonatomic, strong) GPUImageMovie *movieFile;

@property(nonatomic, strong) GPUImageOutput<GPUImageInput> *filter;
@property(nonatomic, strong) GPUImageMovieWriter *movieWriter;
@property(nonatomic, strong) GPUImageFilterPipeline* samplePipeline;

@property(nonatomic, strong) ATMHud *hudProgressView;

@property(nonatomic, strong) CustomModalView* customModalView;

@property(nonatomic, strong) UIButton* applyBtn;
@property(nonatomic, strong) UIButton* playBtn;

@property(nonatomic, strong) UILabel* titleLabel;
@property(nonatomic, strong) UILabel* videoLegthLabel;
@property(nonatomic, strong) UILabel* videoPositionLabel;

@property(nonatomic, strong) UISlider* seekSlider;
@property(nonatomic, strong) UISlider* filterSlider;

@property(nonatomic, strong) UIScrollView* filterScrollView;

@property(nonatomic, strong) AVPlayerItem* playerItem;
@property(nonatomic, strong) AVPlayer* player;

@property(nonatomic, strong) NSTimer *timer;

@property(nonatomic, strong) NSURL* originalVideoUrl;

@property(nonatomic, strong) NSMutableArray* thumbArray;

@property(nonatomic, assign) NSInteger filterIndex;
@property(nonatomic, assign) float filterValue;

@property(nonatomic, assign) BOOL isPlaying;

@property(nonatomic, strong) id observer;


-(void) initParams:(NSURL*) originVideoUrl image:(UIImage*) thumbImage;


@end
