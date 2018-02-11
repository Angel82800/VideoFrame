//
//  PreviewView.h
//  VideoFrame
//
//  Created by Yinjing Li on 12/3/13.
//  Copyright (c) 2013 Yinjing Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

#import "Definition.h"


@protocol PreviewViewVideoDelegate <NSObject>
@optional
-(void) previewPlayDidFinished;

@end


@interface  PreviewView:UIView<UIGestureRecognizerDelegate>
{
    BOOL isPlaying;
}

@property(nonatomic, weak) id <PreviewViewVideoDelegate> delegate;

@property(nonatomic, strong) AVPlayerLayer *videoPlayerLayer;

@property(nonatomic, strong) AVAsset *videoAsset;

@property(nonatomic, assign) CGFloat videoDuration;
@property(nonatomic, assign) CGFloat videoTimescale;

@property(nonatomic, strong) UIImageView* playingImageView;

@property(nonatomic, strong) UIButton* doneBtn;

@property(nonatomic, strong) UISlider* seekSlider;

@property(nonatomic, strong) UILabel* videoLegthLabel;
@property(nonatomic, strong) UILabel* videoPositionLabel;
@property(nonatomic, strong) UILabel* filterNameLabel;


-(void) playVideoInPreview:(NSURL*) videoUrl;

@end
