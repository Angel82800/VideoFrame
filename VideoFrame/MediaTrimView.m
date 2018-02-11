//
//  MusicTrimView.m
//  VideoFrame
//
//  Created by Yinjing Li on 1/21/14.
//  Copyright (c) 2014 Yinjing Li. All rights reserved.
//

#import "MediaTrimView.h"

#import "AudioQueuePlayer.h"

#define WAVEFORM_RESIZE_DELTA  50
#define DELTA_TIME_FROM_END    5

@import Photos;


@implementation MediaTrimView


typedef enum
{
    PortraitVideo,
    UpsideDownVideo,
    LandscapeLeftVideo,
    LandscapeRightVideo,
} Video_Orientation;


#pragma mark - 
#pragma mark - Init Function


- (id)initWithFrame:(CGRect)frame url:(NSURL*) meidaUrl type:(int)mediaType flag:(BOOL)isFromCamera
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
               
        self.backgroundColor = [UIColor blackColor];

        self.mnReverseFlag = NO;
        self.isPlaying = NO;
        self.isTempPlaying = NO;
        self.previousStartTime = 0.0f;
        self.previousEndTime = 0.0f;
        self.previousCenterTime = 0.0f;
        self.previousRealTime = 0.0f;
        self.showEndTime = 0.0f;
        self.showEndTime = 0.0f;
        self.lastScale = 1.0f;
        self.bReverse = false;
        
        self.originalMediaUrl = meidaUrl;
        mnMediaType = mediaType;
        mnSaveCopyFlag = NO;
        isCameraVideo = isFromCamera;
        
        self.clipsToBounds = YES;


    
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(mediaTrimPlayDidFinish:)
                                                         name:AVPlayerItemDidPlayToEndTimeNotification
                                                       object:nil];
        
        if (mediaType == MEDIA_VIDEO)
        {
            NSDate *myDate = [NSDate date];
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            [df setDateFormat:@"yyyyMMddhhmms"];
            NSString *dateForFilename = [df stringFromDate:myDate];
            NSString *folderDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
            NSString *folderPath = [folderDir stringByAppendingPathComponent:gstrCurrentProjectName];
            self.tmpMediaUrl = [NSURL fileURLWithPath:[folderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"TrimVideo-%@.m4v", dateForFilename]]];
            
            /* Seek Slider, Label */
            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
            {
                self.seekSlider = [[UISlider alloc] initWithFrame:CGRectMake(60.0f, self.frame.size.height - 65.0f, self.frame.size.width - 120.0f, 30.0f)];
                self.seekCurrentTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, self.frame.size.height - 65.f, 50.0f, 30.0f)];
                [self.seekCurrentTimeLabel setFont:[UIFont fontWithName:MYRIADPRO size:11]];
                self.seekTotalTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width-50.0f, self.frame.size.height - 65.f, 50.0f, 30.0f)];
                [self.seekTotalTimeLabel setFont:[UIFont fontWithName:MYRIADPRO size:11]];
            }
            else
            {
                self.seekSlider = [[UISlider alloc] initWithFrame:CGRectMake(80.0f, self.frame.size.height - 100.0f, self.frame.size.width - 160.0f, 30.0f)];
                self.seekCurrentTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, self.frame.size.height - 100.0f, 50.0f, 30.0f)];
                [self.seekCurrentTimeLabel setFont:[UIFont fontWithName:MYRIADPRO size:14]];
                self.seekTotalTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width-50.0f, self.frame.size.height - 100.0f, 50.0f, 30.0f)];
                [self.seekTotalTimeLabel setFont:[UIFont fontWithName:MYRIADPRO size:14]];
            }
            
            UIImage *minImage = [UIImage imageNamed:@"slider_min"];
            UIImage *maxImage = [UIImage imageNamed:@"slider_max"];
            UIImage *tumbImage = nil;
            
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
                tumbImage= [UIImage imageNamed:@"slider_thumb"];
            else
                tumbImage= [UIImage imageNamed:@"slider_thumb_ipad"];
            
            minImage=[minImage stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0];
            maxImage=[maxImage stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0];
            
            [self.seekSlider setMinimumTrackImage:minImage forState:UIControlStateNormal];
            [self.seekSlider setMaximumTrackImage:maxImage forState:UIControlStateNormal];
            [self.seekSlider setThumbImage:tumbImage forState:UIControlStateNormal];
            [self.seekSlider setThumbImage:tumbImage forState:UIControlStateHighlighted];
            [self.seekSlider setBackgroundColor:[UIColor clearColor]];
            [self.seekSlider setValue:0.0f];
            [self.seekSlider addTarget:self action:@selector(playerSeekPositionChanged) forControlEvents:UIControlEventValueChanged];
            [self.seekSlider setMinimumValue:0.0f];
            [self addSubview:self.seekSlider];

            [self.seekCurrentTimeLabel setBackgroundColor:[UIColor clearColor]];
            [self.seekCurrentTimeLabel setTextAlignment:NSTextAlignmentCenter];
            [self.seekCurrentTimeLabel setAdjustsFontSizeToFitWidth:YES];
            [self.seekCurrentTimeLabel setMinimumScaleFactor:0.1f];
            [self.seekCurrentTimeLabel setNumberOfLines:1];
            [self.seekCurrentTimeLabel setTextColor:[UIColor yellowColor]];
            [self.seekCurrentTimeLabel setText:@"00:00.000"];
            [self addSubview:self.seekCurrentTimeLabel];

            [self.seekTotalTimeLabel setBackgroundColor:[UIColor clearColor]];
            [self.seekTotalTimeLabel setTextAlignment:NSTextAlignmentCenter];
            [self.seekTotalTimeLabel setAdjustsFontSizeToFitWidth:YES];
            [self.seekTotalTimeLabel setMinimumScaleFactor:0.1f];
            [self.seekTotalTimeLabel setNumberOfLines:1];
            [self.seekTotalTimeLabel setTextColor:[UIColor yellowColor]];
            [self.seekTotalTimeLabel setText:@"00:00.000"];
            [self addSubview:self.seekTotalTimeLabel];
            
            /* range slider */
            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            {
                self.myMediaRangeSlider = [[SAVideoRangeSlider alloc] initWithFrame:CGRectMake(80.0f, self.frame.size.height - 60.0f, self.frame.size.width-160.0f, 50.0f) videoUrl:self.originalMediaUrl value:1.0f type:mediaType];
            }
            else
            {
                self.myMediaRangeSlider = [[SAVideoRangeSlider alloc] initWithFrame:CGRectMake(60.0f, self.frame.size.height - 35.0f, self.frame.size.width-120.0f, 30.0f) videoUrl:self.originalMediaUrl value:1.0f type:mediaType];
            }

            self.myMediaRangeSlider.delegate = self;
            [self addSubview:self.myMediaRangeSlider];
            
            /* play button */
            self.playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            CGFloat x ;
            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            {
                x = 65;
            }
            else
            {
                x = 45;
            }

            
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
                [self.playBtn setFrame:CGRectMake(self.frame.size.width - x, self.myMediaRangeSlider.frame.origin.y, 30.0f, 30.0f)];
            else
                [self.playBtn setFrame:CGRectMake(self.frame.size.width - x, self.myMediaRangeSlider.frame.origin.y, 50.0f, 50.0f)];
            
            [self.playBtn setBackgroundColor:[UIColor clearColor]];
            [self.playBtn setImage:[UIImage imageNamed:@"NewPlay"] forState:UIControlStateNormal];
            [self.playBtn addTarget:self action:@selector(playbackTrimMovie:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:self.playBtn];
            
            
            /* trim button */
            self.trimBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [self.trimBtn setFrame:CGRectMake(20.0f, 20.0f, 60.0f, 30.0f)];

            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
                [self.trimBtn.titleLabel setFont:[UIFont fontWithName:MYRIADPRO size:15]];
            else
                [self.trimBtn.titleLabel setFont:[UIFont fontWithName:MYRIADPRO size:20]];
            
            [self.trimBtn setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
            [self.trimBtn.titleLabel setLineBreakMode:NSLineBreakByWordWrapping];
            [self.trimBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
            [self.trimBtn setBackgroundColor:UIColorFromRGB(0x53585f)];
            [self setSelectedBackgroundViewFor:self.trimBtn];
            self.trimBtn.layer.masksToBounds = YES;
            self.trimBtn.layer.borderColor = [UIColor whiteColor].CGColor;
            self.trimBtn.layer.borderWidth = 1.0f;
            self.trimBtn.layer.cornerRadius = 5.0f;
            [self.trimBtn setTitle:@" Apply " forState:UIControlStateNormal];
            [self.trimBtn addTarget:self action:@selector(actionApplyButton:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:self.trimBtn];
            
            CGFloat labelWidth = [self.trimBtn.titleLabel.text sizeWithAttributes:@{NSFontAttributeName: self.trimBtn.titleLabel.font}].width;
            CGFloat labelHeight = [self.trimBtn.titleLabel.text sizeWithAttributes:@{NSFontAttributeName: self.trimBtn.titleLabel.font}].height;
            
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
                [self.trimBtn setFrame:CGRectMake(5.0f, 7.0f, labelWidth+10.0f, labelHeight+15.0f)];
            else
                [self.trimBtn setFrame:CGRectMake(20.0f, 20.0f, labelWidth+20.0f, labelHeight+20.0f)];
            
            
            /* Save Checkbox Button */
            self.saveCheckBoxBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
                [self.saveCheckBoxBtn setFrame:CGRectMake(labelWidth+30.0f, 7.0f, labelHeight+10.0f, labelHeight+10.0f)];
            else
                [self.saveCheckBoxBtn setFrame:CGRectMake(labelWidth+50.0f, 25.0f, labelHeight+10.0f, labelHeight+10.0f)];
            
            [self.saveCheckBoxBtn setBackgroundImage:[UIImage imageNamed:@"dark_check_off"] forState:UIControlStateNormal];
            [self.saveCheckBoxBtn setBackgroundImage:[UIImage imageNamed:@"dark_check_on"] forState:UIControlStateSelected];
            [self.saveCheckBoxBtn setBackgroundImage:[UIImage imageNamed:@"dark_check_on"] forState:UIControlStateHighlighted];
            [self.saveCheckBoxBtn addTarget:self action:@selector(onSaveCheckBox) forControlEvents:UIControlEventTouchUpInside];
            [self.saveCheckBoxBtn setSelected:mnSaveCopyFlag];
            [self addSubview:self.saveCheckBoxBtn];
            [self.saveCheckBoxBtn setCenter:CGPointMake(self.saveCheckBoxBtn.center.x, self.trimBtn.center.y)];
            

            
            /* Save Checkbox Label */
            UILabel* checkLabel;
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
            {
                checkLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.saveCheckBoxBtn.frame.origin.x+self.saveCheckBoxBtn.frame.size.width, self.saveCheckBoxBtn.frame.origin.y, 50.0f, self.saveCheckBoxBtn.frame.size.height)];
                checkLabel.font = [UIFont fontWithName:MYRIADPRO size:10];
            }
            else
            {
                checkLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.saveCheckBoxBtn.frame.origin.x+self.saveCheckBoxBtn.frame.size.width, self.saveCheckBoxBtn.frame.origin.y, 70.0f, self.saveCheckBoxBtn.frame.size.height)];
                checkLabel.font = [UIFont fontWithName:MYRIADPRO size:15];
            }
            
            checkLabel.backgroundColor = [UIColor clearColor];
            checkLabel.textAlignment = NSTextAlignmentCenter;
            checkLabel.adjustsFontSizeToFitWidth = YES;
            checkLabel.minimumScaleFactor = 0.1f;
            checkLabel.numberOfLines = 0;
            checkLabel.textColor = [UIColor lightGrayColor];
            checkLabel.text = @"Save to Photo Roll";
            [self addSubview:checkLabel];
            [checkLabel setCenter:CGPointMake(checkLabel.center.x, self.trimBtn.center.y)];

            
            /* Media Player */
            [self.mediaPlayerLayer.player pause];
            self.mediaPlayerLayer.player = nil;
            
            if (self.mediaPlayerLayer != nil)
            {
                [self.mediaPlayerLayer removeFromSuperlayer];
                self.mediaPlayerLayer = nil;
            }

            self.mediaAsset = nil;
            self.mediaAsset = [AVURLAsset assetWithURL:self.originalMediaUrl];
            self.mediaPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:[AVPlayer playerWithPlayerItem:[AVPlayerItem playerItemWithAsset:self.mediaAsset]]];
            
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
            {
                if (self.frame.size.width > self.frame.size.height) //landscape
                    [_mediaPlayerLayer setFrame:CGRectMake(5.0f, self.trimBtn.frame.origin.y+self.trimBtn.frame.size.height + 5.0f, self.frame.size.width - 10.0f, self.myMediaRangeSlider.frame.origin.y - (self.trimBtn.frame.origin.y+self.trimBtn.frame.size.height) - 10.0f)];
                else
                    [_mediaPlayerLayer setFrame:CGRectMake(5.0f, self.trimBtn.frame.origin.y+self.trimBtn.frame.size.height + 35.0f, self.frame.size.width - 10.0f, self.myMediaRangeSlider.frame.origin.y - (self.trimBtn.frame.origin.y+self.trimBtn.frame.size.height) - 40.0f)];
            }
            else
            {
                [_mediaPlayerLayer setFrame:CGRectMake(10.0f, self.trimBtn.frame.origin.y+self.trimBtn.frame.size.height + 10.0f, self.frame.size.width - 20.0f, self.myMediaRangeSlider.frame.origin.y - (self.trimBtn.frame.origin.y+self.trimBtn.frame.size.height) - 20.0f)];
            }
            
            [self.layer insertSublayer:_mediaPlayerLayer atIndex:0];

            if (isCameraVideo && (gnTemplateIndex == TEMPLATE_SQUARE))
            {
                AVAssetTrack *assetTrack = [[self.mediaAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
                CGAffineTransform firstTransform = assetTrack.preferredTransform;
                
                if (assetTrack.naturalSize.width > assetTrack.naturalSize.height)
                {
                    if((firstTransform.a == 0 && firstTransform.b == 1.0 && firstTransform.c == -1.0 && firstTransform.d == 0)||(firstTransform.a == 0 && firstTransform.b == -1.0 && firstTransform.c == 1.0 && firstTransform.d == 0))//portrait
                    {
                        CGFloat w = _mediaPlayerLayer.frame.size.width >= _mediaPlayerLayer.frame.size.height ? _mediaPlayerLayer.frame.size.height : _mediaPlayerLayer.frame.size.width;
                        CGPoint centerPnt = CGPointMake(_mediaPlayerLayer.frame.origin.x + _mediaPlayerLayer.frame.size.width/2.0f, _mediaPlayerLayer.frame.origin.y+_mediaPlayerLayer.frame.size.height/2.0f);
                        
                        [_mediaPlayerLayer setFrame:CGRectMake(centerPnt.x - w/2.0f, centerPnt.y - (assetTrack.naturalSize.width/assetTrack.naturalSize.height)*w/2.0f, w, (assetTrack.naturalSize.width/assetTrack.naturalSize.height)*w)];
                        
                        CALayer* maskLayer = [CALayer layer];
                        maskLayer.frame = CGRectMake((_mediaPlayerLayer.frame.size.width - w)/2.0f, (_mediaPlayerLayer.frame.size.height - w)/2.0f, w, w);
                        maskLayer.backgroundColor = [UIColor blackColor].CGColor;
                        _mediaPlayerLayer.mask = maskLayer;
                    }
                    else
                    {
                        CGFloat w = _mediaPlayerLayer.frame.size.width >= _mediaPlayerLayer.frame.size.height ? _mediaPlayerLayer.frame.size.height: _mediaPlayerLayer.frame.size.width;
                        CGPoint centerPnt = CGPointMake(_mediaPlayerLayer.frame.origin.x + _mediaPlayerLayer.frame.size.width/2.0f, _mediaPlayerLayer.frame.origin.y+_mediaPlayerLayer.frame.size.height/2.0f);
                        
                        [_mediaPlayerLayer setFrame:CGRectMake(centerPnt.x - (assetTrack.naturalSize.width/assetTrack.naturalSize.height)*w/2.0f, centerPnt.y - w/2.0f, (assetTrack.naturalSize.width/assetTrack.naturalSize.height)*w, w)];
                        
                        CALayer* maskLayer = [CALayer layer];
                        maskLayer.frame = CGRectMake((_mediaPlayerLayer.frame.size.width - w)/2.0f, (_mediaPlayerLayer.frame.size.height - w)/2.0f, w, w);
                        maskLayer.backgroundColor = [UIColor blackColor].CGColor;
                        _mediaPlayerLayer.mask = maskLayer;
                    }
                }
                else
                {
                    CGFloat w = _mediaPlayerLayer.frame.size.width >= _mediaPlayerLayer.frame.size.height ? _mediaPlayerLayer.frame.size.width : _mediaPlayerLayer.frame.size.height;
                    CGPoint centerPnt = CGPointMake(_mediaPlayerLayer.frame.origin.x + _mediaPlayerLayer.frame.size.width/2.0f, _mediaPlayerLayer.frame.origin.y+_mediaPlayerLayer.frame.size.height/2.0f);
                    
                    [_mediaPlayerLayer setFrame:CGRectMake(centerPnt.x - w/2.0f, centerPnt.y - (assetTrack.naturalSize.height/assetTrack.naturalSize.width)*w/2.0f, w, (assetTrack.naturalSize.height/assetTrack.naturalSize.width)*w)];
                    
                    CALayer* maskLayer = [CALayer layer];
                    maskLayer.frame = CGRectMake((_mediaPlayerLayer.frame.size.width - w)/2.0f, (_mediaPlayerLayer.frame.size.height - w)/2.0f, w, w);
                    maskLayer.backgroundColor = [UIColor blackColor].CGColor;
                    _mediaPlayerLayer.mask = maskLayer;
                }
            }
            
            self.startTime = 0.0f; self.showStartTime = 0.0f;
            self.stopTime = CMTimeGetSeconds(self.mediaAsset.duration);
            self.showEndTime = self.stopTime;
            
            CGFloat duration = self.mediaAsset.duration.value / 500.0f;
            
            __weak typeof(self) weakSelf = self;
            
            [self.mediaPlayerLayer.player addPeriodicTimeObserverForInterval:CMTimeMake(MAX(1, duration), self.mediaAsset.duration.timescale) queue:dispatch_get_main_queue() usingBlock:^(CMTime time)
             {
                 if (weakSelf.isPlaying)
                 {
                     CGFloat currentTime = CMTimeGetSeconds(time);
                     
                     if ((currentTime >= weakSelf.stopTime)&&(weakSelf.mnReverseFlag == NO))
                     {
                         currentTime = weakSelf.stopTime;
                         [weakSelf performSelector:@selector(mediaTrimPlayFinished)];
                     }
                     else if ((currentTime <= weakSelf.startTime)&&(weakSelf.mnReverseFlag == YES))
                     {
                         currentTime = weakSelf.startTime;
                         [weakSelf performSelector:@selector(mediaTrimPlayFinished)];
                     }
                     
                     weakSelf.seekSlider.value = currentTime;
                 }
            }];
            
            
            /* Reverse Checkbox Button */
            self.reverseCheckBoxBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
                [self.reverseCheckBoxBtn setFrame:CGRectMake(checkLabel.frame.origin.x + checkLabel.frame.size.width+10.0f, 7.0f, labelHeight+10.0f, labelHeight+10.0f)];
            else
                [self.reverseCheckBoxBtn setFrame:CGRectMake(checkLabel.frame.origin.x + checkLabel.frame.size.width+5.0f, 25.0f, labelHeight+10.0f, labelHeight+10.0f)];
            
            [self.reverseCheckBoxBtn setBackgroundImage:[UIImage imageNamed:@"dark_check_off"] forState:UIControlStateNormal];
            [self.reverseCheckBoxBtn setBackgroundImage:[UIImage imageNamed:@"dark_check_on"] forState:UIControlStateSelected];
            [self.reverseCheckBoxBtn setBackgroundImage:[UIImage imageNamed:@"dark_check_on"] forState:UIControlStateHighlighted];
            [self.reverseCheckBoxBtn addTarget:self action:@selector(onReverseCheckBox) forControlEvents:UIControlEventTouchUpInside];
            [self.reverseCheckBoxBtn setSelected:self.mnReverseFlag];
            [self addSubview:self.reverseCheckBoxBtn];
            [self.reverseCheckBoxBtn setCenter:CGPointMake(self.reverseCheckBoxBtn.center.x, self.trimBtn.center.y)];

            
            /* Reverse Checkbox Label */
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
            {
                checkLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.reverseCheckBoxBtn.frame.origin.x+self.reverseCheckBoxBtn.frame.size.width, self.reverseCheckBoxBtn.frame.origin.y, 45.0f, self.reverseCheckBoxBtn.frame.size.height)];
                checkLabel.font = [UIFont fontWithName:MYRIADPRO size:10];
            }
            else
            {
                checkLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.reverseCheckBoxBtn.frame.origin.x+self.reverseCheckBoxBtn.frame.size.width, self.reverseCheckBoxBtn.frame.origin.y, 60.0f, self.reverseCheckBoxBtn.frame.size.height)];
                checkLabel.font = [UIFont fontWithName:MYRIADPRO size:15];
            }
            
            checkLabel.backgroundColor = [UIColor clearColor];
            checkLabel.textAlignment = NSTextAlignmentCenter;
            checkLabel.adjustsFontSizeToFitWidth = YES;
            checkLabel.minimumScaleFactor = 0.1f;
            checkLabel.numberOfLines = 0;
            checkLabel.textColor = [UIColor lightGrayColor];
            checkLabel.text = @"Reverse Video";
            [self addSubview:checkLabel];
            [checkLabel setCenter:CGPointMake(checkLabel.center.x, self.trimBtn.center.y)];

            
            /* Title Label */
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
            {
                if (self.frame.size.width > self.frame.size.height) //landscape
                {
                    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(checkLabel.frame.origin.x + checkLabel.frame.size.width + 5.0f, checkLabel.frame.origin.y, self.frame.size.width - (checkLabel.frame.origin.x + checkLabel.frame.size.width + 5.0f), 30.0f)];
                    self.titleLabel.textAlignment = NSTextAlignmentLeft;
                    [self.titleLabel setCenter:CGPointMake(self.titleLabel.center.x, self.trimBtn.center.y)];
                }
                else
                {
                    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 35.0f, self.frame.size.width, 30.0f)];
                    self.titleLabel.textAlignment = NSTextAlignmentCenter;
                }
                
                self.titleLabel.font = [UIFont fontWithName:MYRIADPRO size:22];
            }
            else
            {
                if (self.frame.size.width > self.frame.size.height) //landscape
                {
                    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, checkLabel.frame.origin.y, self.frame.size.width, 30.0f)];
                }
                else
                {
                    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(checkLabel.frame.origin.x + checkLabel.frame.size.width + 5.0f, checkLabel.frame.origin.y, self.frame.size.width - (checkLabel.frame.origin.x + checkLabel.frame.size.width + 5.0f), 30.0f)];
                }
                
                self.titleLabel.font = [UIFont fontWithName:MYRIADPRO size:27];
                self.titleLabel.textAlignment = NSTextAlignmentCenter;
                
                [self.titleLabel setCenter:CGPointMake(self.titleLabel.center.x, self.trimBtn.center.y)];
            }
            
            [self.titleLabel setBackgroundColor:[UIColor clearColor]];
            [self.titleLabel setTextColor:[UIColor whiteColor]];
            self.titleLabel.adjustsFontSizeToFitWidth = YES;
            self.titleLabel.minimumScaleFactor = 0.1f;
            self.titleLabel.numberOfLines = 1;
            self.titleLabel.text = @"Video Trim Center";
            self.titleLabel.shadowColor = [UIColor blackColor];
            self.titleLabel.shadowOffset = CGSizeMake(1.0f, 1.0f);
            self.titleLabel.layer.shadowOpacity = 0.8f;
            [self addSubview:self.titleLabel];

            NSString* timeStr = [self timeToStr:(self.stopTime - self.startTime)];
            self.seekTotalTimeLabel.text = [NSString stringWithFormat:@"%@", timeStr];

            [self.seekSlider setMinimumValue:self.startTime];
            [self.seekSlider setMaximumValue:self.stopTime];
        }
        else if (mediaType == MEDIA_MUSIC) /* Object is Music */
        {
            NSDate *myDate = [NSDate date];
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            [df setDateFormat:@"yyyyMMddhhmms"];
            NSString *dateForFilename = [df stringFromDate:myDate];
            
            NSString *folderDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
            NSString *folderPath = [folderDir stringByAppendingPathComponent:gstrCurrentProjectName];

            self.tmpMediaUrl = [NSURL fileURLWithPath:[folderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"TrimMusic-%@.m4a", dateForFilename]]];
            self.originalUrl = [NSURL fileURLWithPath:[folderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"TrimMusicOrg-%@.wav", dateForFilename]]];
            self.reversedUrl = [NSURL fileURLWithPath:[folderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"TrimMusicRvs-%@.wav", dateForFilename]]];
            
            /* player seek Slider, Label */
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
            {
                self.seekSlider = [[UISlider alloc] initWithFrame:CGRectMake(60.0f, self.frame.size.height - 95.f - WAVEFORM_RESIZE_DELTA, self.frame.size.width - 120.0f, 30.0f)];
                
                self.seekCurrentTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, self.frame.size.height - 95.f - WAVEFORM_RESIZE_DELTA, 50.0f, 30.0f)];
                self.seekCurrentTimeLabel.font = [UIFont fontWithName:MYRIADPRO size:11];
                
                self.seekTotalTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width-50.0f, self.frame.size.height - 95.f - WAVEFORM_RESIZE_DELTA, 50.0f, 30.0f)];
                self.seekTotalTimeLabel.font = [UIFont fontWithName:MYRIADPRO size:11];
            }
            else
            {
                self.seekSlider = [[UISlider alloc] initWithFrame:CGRectMake(60.0f, self.frame.size.height - 130.f - WAVEFORM_RESIZE_DELTA, self.frame.size.width - 120.0f, 30.0f)];
                
                self.seekCurrentTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, self.frame.size.height - 130.f - WAVEFORM_RESIZE_DELTA, 50.0f, 30.0f)];
                self.seekCurrentTimeLabel.font = [UIFont fontWithName:MYRIADPRO size:14];
                
                self.seekTotalTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width-50.0f, self.frame.size.height - 130.f - WAVEFORM_RESIZE_DELTA, 50.0f, 30.0f)];
                self.seekTotalTimeLabel.font = [UIFont fontWithName:MYRIADPRO size:14];
            }
            
            UIImage *minImage = [UIImage imageNamed:@"slider_min"];
            UIImage *maxImage = [UIImage imageNamed:@"slider_max"];
            UIImage *tumbImage = nil;
            
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
                tumbImage= [UIImage imageNamed:@"slider_thumb"];
            else
                tumbImage= [UIImage imageNamed:@"slider_thumb_ipad"];
            
            minImage=[minImage stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0];
            maxImage=[maxImage stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0];
            
            [self.seekSlider setMinimumTrackImage:minImage forState:UIControlStateNormal];
            [self.seekSlider setMaximumTrackImage:maxImage forState:UIControlStateNormal];
            [self.seekSlider setThumbImage:tumbImage forState:UIControlStateNormal];
            [self.seekSlider setThumbImage:tumbImage forState:UIControlStateHighlighted];
            [self.seekSlider setBackgroundColor:[UIColor clearColor]];
            [self.seekSlider setValue:0.0f];
            [self.seekSlider addTarget:self action:@selector(playerSeekPositionChanged) forControlEvents:UIControlEventValueChanged];
            [self.seekSlider setMinimumValue:0.0f];
            [self addSubview:self.seekSlider];

            self.seekCurrentTimeLabel.backgroundColor = [UIColor clearColor];
            self.seekCurrentTimeLabel.textAlignment = NSTextAlignmentCenter;
            self.seekCurrentTimeLabel.adjustsFontSizeToFitWidth = YES;
            self.seekCurrentTimeLabel.minimumScaleFactor = 0.1f;
            self.seekCurrentTimeLabel.numberOfLines = 1;
            self.seekCurrentTimeLabel.textColor = [UIColor yellowColor];
            self.seekCurrentTimeLabel.text = @"00:00.000";
            [self addSubview:self.seekCurrentTimeLabel];

            self.seekTotalTimeLabel.backgroundColor = [UIColor clearColor];
            self.seekTotalTimeLabel.textAlignment = NSTextAlignmentCenter;
            self.seekTotalTimeLabel.adjustsFontSizeToFitWidth = YES;
            self.seekTotalTimeLabel.minimumScaleFactor = 0.1f;
            self.seekTotalTimeLabel.numberOfLines = 1;
            self.seekTotalTimeLabel.textColor = [UIColor yellowColor];
            self.seekTotalTimeLabel.text = @"00:00.000";
            [self addSubview:self.seekTotalTimeLabel];

            
            /* Range Slider */
            CGFloat x; // =  self.frame.size.width - (self.myMediaRangeSlider.frame.origin.x*2.0f + self.myMediaRangeSlider.frame.size.width);
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            {
                self.myMediaRangeSlider = [[SAVideoRangeSlider alloc] initWithFrame:CGRectMake(80.0f, self.frame.size.height - 90.0f - WAVEFORM_RESIZE_DELTA, self.frame.size.width-160.0f, 80.0f + WAVEFORM_RESIZE_DELTA) videoUrl:self.originalMediaUrl value:1.0f type:mediaType];
                x = 65;
            }
            else
            {
                self.myMediaRangeSlider = [[SAVideoRangeSlider alloc] initWithFrame:CGRectMake(60.0f, self.frame.size.height - 65.0f - WAVEFORM_RESIZE_DELTA, self.frame.size.width-120.0f, 60.0f + WAVEFORM_RESIZE_DELTA) videoUrl:self.originalMediaUrl value:1.0f type:mediaType];
                x = 45;
            }

            self.myMediaRangeSlider.delegate = self;
            [self addSubview:self.myMediaRangeSlider];
            
           

            /* Wave Form View */
            self.waveform = [[FDWaveformView alloc] initWithFrame:CGRectMake(self.myMediaRangeSlider.frame.origin.x, self.myMediaRangeSlider.frame.origin.y, self.myMediaRangeSlider.frame.size.width, self.myMediaRangeSlider.frame.size.height)];
            self.waveform.delegate = self;
            self.waveform.alpha = 0.0f;
            self.waveform.audioURL = self.originalMediaUrl;
            self.waveform.progressSamples = 10000;
            self.waveform.doesAllowScrubbing = YES;
            [self addSubview:self.waveform];
            self.waveform.userInteractionEnabled = NO;
            [self.waveform createWaveform];
            
            
            /* Play Button */
            self.playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
                [self.playBtn setFrame:CGRectMake(self.frame.size.width - x, self.myMediaRangeSlider.frame.origin.y, 30.0f, 30.0f)];
            else
                [self.playBtn setFrame:CGRectMake(self.frame.size.width - x, self.myMediaRangeSlider.frame.origin.y, 50.0f, 50.0f)];
            
            self.playBtn.center = CGPointMake(self.playBtn.center.x, self.myMediaRangeSlider.center.y);
            
            [self.playBtn setBackgroundColor:[UIColor clearColor]];
            [self.playBtn setImage:[UIImage imageNamed:@"NewPlay"] forState:UIControlStateNormal];
            [self.playBtn addTarget:self action:@selector(playbackTrimMovie:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:self.playBtn];
            
            /* Trim Button */
            self.trimBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [self.trimBtn setFrame:CGRectMake(20.0f, 20.0f, 60.0f, 30.0f)];

            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
                [self.trimBtn.titleLabel setFont:[UIFont fontWithName:MYRIADPRO size:15]];
            else
                [self.trimBtn.titleLabel setFont:[UIFont fontWithName:MYRIADPRO size:20]];
            
            [self.trimBtn setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
            self.trimBtn.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
            [self.trimBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
            self.trimBtn.backgroundColor = UIColorFromRGB(0x53585f);
            [self setSelectedBackgroundViewFor:self.trimBtn];
            self.trimBtn.layer.masksToBounds = YES;
            self.trimBtn.layer.borderColor = [UIColor whiteColor].CGColor;
            self.trimBtn.layer.borderWidth = 1.0f;
            self.trimBtn.layer.cornerRadius = 5.0f;
            [self.trimBtn setTitle:@" Apply " forState:UIControlStateNormal];
            [self.trimBtn addTarget:self action:@selector(actionApplyButton:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:self.trimBtn];
            
            CGFloat labelWidth = [self.trimBtn.titleLabel.text sizeWithAttributes:@{NSFontAttributeName: self.trimBtn.titleLabel.font}].width;
            CGFloat labelHeight = [self.trimBtn.titleLabel.text sizeWithAttributes:@{NSFontAttributeName: self.trimBtn.titleLabel.font}].height;
            
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
                [self.trimBtn setFrame:CGRectMake(5.0f, 7.0f, labelWidth+10.0f, labelHeight+15.0f)];
            else
                [self.trimBtn setFrame:CGRectMake(20.0f, 20.0f, labelWidth+20.0f, labelHeight+20.0f)];
            
            /* Save Checkbox Button */
            self.saveCheckBoxBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
            {
                if (self.frame.size.width > self.frame.size.height) //landscape
                    [self.saveCheckBoxBtn setFrame:CGRectMake(labelWidth + 30.0f, 7.0f, labelHeight + 10.0f, labelHeight + 10.0f)];
                else
                    [self.saveCheckBoxBtn setFrame:CGRectMake(labelWidth + 40.0f, 7.0f, labelHeight + 10.0f, labelHeight + 10.0f)];
            }
            else
            {
                if (self.frame.size.width > self.frame.size.height) //landscape
                    [self.saveCheckBoxBtn setFrame:CGRectMake(labelWidth + 80.0f, 25.0f, labelHeight + 10.0f, labelHeight + 10.0f)];
                else
                    [self.saveCheckBoxBtn setFrame:CGRectMake(labelWidth + 70.0f, 25.0f, labelHeight + 10.0f, labelHeight + 10.0f)];
            }
            
            [self.saveCheckBoxBtn setBackgroundImage:[UIImage imageNamed:@"dark_check_off"] forState:UIControlStateNormal];
            [self.saveCheckBoxBtn setBackgroundImage:[UIImage imageNamed:@"dark_check_on"] forState:UIControlStateSelected];
            [self.saveCheckBoxBtn setBackgroundImage:[UIImage imageNamed:@"dark_check_on"] forState:UIControlStateHighlighted];
            [self.saveCheckBoxBtn addTarget:self action:@selector(onSaveCheckBox) forControlEvents:UIControlEventTouchUpInside];
            [self.saveCheckBoxBtn setSelected:mnSaveCopyFlag];
            [self addSubview:self.saveCheckBoxBtn];
            [self.saveCheckBoxBtn setCenter:CGPointMake(self.saveCheckBoxBtn.center.x, self.trimBtn.center.y)];

            /* Save Checkbox Label */
            UILabel* checkLabel;
            
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
            {
                checkLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.saveCheckBoxBtn.frame.origin.x + self.saveCheckBoxBtn.frame.size.width + 5.0f, self.saveCheckBoxBtn.frame.origin.y, 150.0f, self.saveCheckBoxBtn.frame.size.height)];
                checkLabel.font = [UIFont fontWithName:MYRIADPRO size:12];
                checkLabel.textAlignment = NSTextAlignmentLeft;
            }
            else
            {
                checkLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.saveCheckBoxBtn.frame.origin.x+self.saveCheckBoxBtn.frame.size.width, self.saveCheckBoxBtn.frame.origin.y, 70.0f, self.saveCheckBoxBtn.frame.size.height)];
                checkLabel.font = [UIFont fontWithName:MYRIADPRO size:15];
                checkLabel.textAlignment = NSTextAlignmentCenter;
            }
            
            checkLabel.backgroundColor = [UIColor clearColor];
            checkLabel.adjustsFontSizeToFitWidth = YES;
            checkLabel.minimumScaleFactor = 0.1f;
            checkLabel.numberOfLines = 0;
            checkLabel.textColor = [UIColor lightGrayColor];
            checkLabel.text = @"Save to Library";
            [self addSubview:checkLabel];
            [checkLabel setCenter:CGPointMake(checkLabel.center.x, self.trimBtn.center.y)];

            
            
            /* Media Player */
            self.mediaAsset = nil;
            self.mediaAsset = [AVURLAsset assetWithURL:self.originalMediaUrl];
            self.mediaPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:[AVPlayer playerWithPlayerItem:[AVPlayerItem playerItemWithAsset:self.mediaAsset]]];
            
            self.startTime = 0.0f;
            self.stopTime = CMTimeGetSeconds(self.mediaAsset.duration);
            self.showStartTime = 0.0f;
            self.showEndTime = self.stopTime;
            
           

            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
                [_mediaPlayerLayer setFrame:CGRectMake(5.0f, self.trimBtn.frame.origin.y+self.trimBtn.frame.size.height + 5.0f, self.frame.size.width - 10.0f, self.myMediaRangeSlider.frame.origin.y - (self.trimBtn.frame.origin.y+self.trimBtn.frame.size.height) - 10.0f)];
            else
                [_mediaPlayerLayer setFrame:CGRectMake(10.0f, self.trimBtn.frame.origin.y+self.trimBtn.frame.size.height + 10.0f, self.frame.size.width - 20.0f, self.myMediaRangeSlider.frame.origin.y - (self.trimBtn.frame.origin.y+self.trimBtn.frame.size.height) - 20.0f)];
            
            [self.layer insertSublayer:_mediaPlayerLayer atIndex:0];
            
            
            /* Media Symbol ImageView */
            self.musicSymbolImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"musicSymbol"]];
            self.musicSymbolImageView.backgroundColor = [UIColor clearColor];
            self.musicSymbolImageView.frame = CGRectMake((self.mediaPlayerLayer.bounds.size.width-self.musicSymbolImageView.frame.size.width)/2.0f, (self.mediaPlayerLayer.bounds.size.height-self.musicSymbolImageView.frame.size.height)/2.0f, self.musicSymbolImageView.frame.size.width, self.musicSymbolImageView.frame.size.height);
            [self.mediaPlayerLayer addSublayer:self.musicSymbolImageView.layer];
            
            CGFloat duration = self.mediaAsset.duration.value / 500.0f;
            
            __weak typeof(self) weakSelf = self;
            
            [self.mediaPlayerLayer.player addPeriodicTimeObserverForInterval:CMTimeMake(MAX(0.001, duration), self.mediaAsset.duration.timescale) queue:dispatch_get_main_queue() usingBlock:^(CMTime time)
             {
                CGFloat currentTime = CMTimeGetSeconds(time);
//                 NSLog(@"Current Time = %f", currentTime);
                 if (currentTime > weakSelf.stopTime)
                 {
                     currentTime = weakSelf.stopTime;
                     [weakSelf performSelector:@selector(mediaTrimPlayFinished)];
                 }
                 
                 if ( weakSelf.isTempPlaying ) {
                     [weakSelf getShowTime:weakSelf.nDirection];
                 }
                 else{
                     CGRect rect  = [weakSelf.waveform getImageRect];
                     weakSelf.seekSlider.value = currentTime * rect.size.width / CMTimeGetSeconds(self.mediaAsset.duration);
                 }
                 
            }];
            
            
            /* Title Label */
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
            {
                if (self.frame.size.width > self.frame.size.height) //landscape
                {
                    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, checkLabel.center.y - 15.0f, self.frame.size.width, 30.0f)];
                }
                else
                {
                    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, checkLabel.frame.origin.y + checkLabel.frame.size.height + 5.0f, self.frame.size.width, 30.0f)];
                }
                
                self.titleLabel.font = [UIFont fontWithName:MYRIADPRO size:22];
            }
            else
            {
                self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, checkLabel.center.y - 15.0f, self.frame.size.width, 30.0f)];
                
                self.titleLabel.font = [UIFont fontWithName:MYRIADPRO size:27];
            }
            
            [self.titleLabel setBackgroundColor:[UIColor clearColor]];
            [self.titleLabel setTextColor:[UIColor whiteColor]];
            self.titleLabel.textAlignment = NSTextAlignmentCenter;
            self.titleLabel.adjustsFontSizeToFitWidth = YES;
            self.titleLabel.minimumScaleFactor = 0.1f;
            self.titleLabel.numberOfLines = 1;
            self.titleLabel.text = @"Music Trim Center";
            self.titleLabel.shadowColor = [UIColor blackColor];
            self.titleLabel.shadowOffset = CGSizeMake(1.0f, 1.0f);
            self.titleLabel.layer.shadowOpacity = 0.8f;
            [self addSubview:self.titleLabel];

            NSString* timeStr = [self timeToStr:(self.stopTime - self.startTime)];
            self.seekTotalTimeLabel.text = [NSString stringWithFormat:@"%@", timeStr];
            
            [self.seekSlider setMinimumValue:self.startTime];
            [self.seekSlider setMaximumValue:self.stopTime];
            
            // Reverse Audio
            volume = self.mediaPlayerLayer.player.volume;
            
            [self readAudioFromURL:self.originalMediaUrl originalToURL:self.originalUrl reverseToURL:self.reversedUrl];
            self.reverseMediaAsset = nil;
            self.reverseMediaAsset = [AVURLAsset assetWithURL:self.reversedUrl];
            self.reverseAudioPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:[AVPlayer playerWithPlayerItem:[AVPlayerItem playerItemWithAsset:self.reverseMediaAsset]]];
//            self.reverseAudioPlayerLayer.player.volume = 0;
            
//            self.play  = [[AudioPlayer alloc] init];
//            [self.play addSoundFromFile:[self.reversedUrl absoluteString]];
            
            // Add by Lee for test
            [[AudioQueuePlayer defaultPlayer] initWithFileCouple:self.originalUrl withFile:self.reversedUrl];
        }
        
        /* ProgressView */
        self.hudProgressView = [[ATMHud alloc] initWithDelegate:self];
        self.hudProgressView.delegate = self;
        [self addSubview:self.hudProgressView.view];
        self.hudProgressView.view.center = CGPointMake(self.bounds.size.width/2.0f, self.bounds.size.height/2.0f);
        
        self.leftView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 1.0f, self.myMediaRangeSlider.bounds.size.height)];
        self.leftView.backgroundColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.6f];
        [self.myMediaRangeSlider addSubview:self.leftView];
        
        UIPanGestureRecognizer *leftPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleCenterPan:)];
        [self.leftView addGestureRecognizer:leftPan];
        
        UIPinchGestureRecognizer *zoomGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handleZoom:)];
        zoomGesture.delegate = self;
        [self.leftView addGestureRecognizer:zoomGesture];

        self.rightView = [[UIView alloc] initWithFrame:CGRectMake(self.myMediaRangeSlider.bounds.size.width-1.0f, 0.0f, 1.0f, self.myMediaRangeSlider.bounds.size.height)];
        self.rightView.backgroundColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.6f];
        
        UIPanGestureRecognizer *rightPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleCenterPan:)];
        [self.rightView addGestureRecognizer:rightPan];
        
        UIPinchGestureRecognizer *zoomGesture1 = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handleZoom:)];
        zoomGesture.delegate = self;
        [self.rightView addGestureRecognizer:zoomGesture1];
        
        [self.myMediaRangeSlider addSubview:self.rightView];
        
        
    }
    
    return self;
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) setSelectedBackgroundViewFor:(UIButton *) button
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(button.bounds.size.width, button.bounds.size.height), NO, 0.0f);
    [UIColorFromRGB(0x9da1a0) set];
    CGContextFillRect(UIGraphicsGetCurrentContext(), CGRectMake(0.5f, 0.5f, button.bounds.size.width - 0.5f, button.bounds.size.height - 0.5f));
    UIImage* resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [button setBackgroundImage:resultImage forState:UIControlStateHighlighted];
    [button setBackgroundImage:resultImage forState:UIControlStateSelected|UIControlStateHighlighted];
}

- (NSString *)timeToStr:(CGFloat)time
{
    if(time < 0.0f)
        time = 0.0f;
    
    NSInteger min = floor(time / 60);
    NSInteger sec = floor(time - min * 60);
    NSInteger millisecond = roundf((time - (min*60 + sec))*1000);
    
    if (millisecond == 1000)
    {
        millisecond = 0;
        sec++;
    }

    NSString *minStr = [NSString stringWithFormat:min >= 10 ? @"%d" : @"0%d", (int)min];
    NSString *secStr = [NSString stringWithFormat:sec >= 10 ? @"%d" : @"0%d", (int)sec];
    NSString *millisecStr = nil;
    
    if (millisecond >= 100)
        millisecStr = [NSString stringWithFormat:@"%d", (int)millisecond];
    else if (millisecond >= 10)
        millisecStr = [NSString stringWithFormat:@"0%d", (int)millisecond];
    else
        millisecStr = [NSString stringWithFormat:@"00%d", (int)millisecond];
    
    return [NSString stringWithFormat:@"%@:%@.%@", minStr, secStr, millisecStr];
}


#pragma mark -
#pragma mark - PlayBack Movie

- (void) playbackTrimMovie:(id) sender
{
    if (self.isPlaying)
    {
        self.isPlaying = NO;
        [self.mediaPlayerLayer.player pause];
        [self.reverseAudioPlayerLayer.player pause];
        
        [self.playBtn setImage:[UIImage imageNamed:@"NewPlay"] forState:UIControlStateNormal];
    }
    else
    {
        self.isPlaying = YES;
        
//        CGRect rect  = [self.waveform getImageRect];
//        CGFloat currentTime = self.seekSlider.value * CMTimeGetSeconds(self.mediaAsset.duration) / rect.size.width;
//        
//  /*      if (self.mnReverseFlag && currentTime >= (self.stopTime - 0.1f))
//        {
//            [self.mediaPlayerLayer.player seekToTime:CMTimeMakeWithSeconds(self.stopTime - 0.1f, self.mediaAsset.duration.timescale) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
//        }*/
//       
//        CGFloat start;
//        if ( currentTime > self.startTime ) {
//            start = currentTime;
//        }
//        else{
//            start = self.startTime;
//        }
//        
//        if ( currentTime > self.stopTime ) {
//            start = self.startTime;
//        }
//        
//        [self.mediaPlayerLayer.player seekToTime:CMTimeMakeWithSeconds(start, self.mediaAsset.duration.timescale) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
//        [self.mediaPlayerLayer.player play];
//       
//        if (self.mnReverseFlag)
//        {
//            self.mediaPlayerLayer.player.rate = -1.0f;
//        }
        
        [self.play playQueue];
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
            [self.playBtn setImage:[UIImage imageNamed:@"NewPause_iPhone"] forState:UIControlStateNormal];
        else
            [self.playBtn setImage:[UIImage imageNamed:@"NewPause_iPad"] forState:UIControlStateNormal];
    }
}


#pragma mark - PlayBackDidFinish Function

- (void) mediaTrimPlayDidFinish:(NSNotification*)notification
{
    self.isPlaying = NO;
   
    [self.mediaPlayerLayer.player pause];
  
    if (mnMediaType == MEDIA_VIDEO)
    {
        if (self.mnReverseFlag)
        {
            [self.mediaPlayerLayer.player seekToTime:CMTimeMakeWithSeconds(self.stopTime, self.mediaAsset.duration.timescale) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
            [self.seekSlider setValue:self.stopTime];
        }
        else
        {
            [self.mediaPlayerLayer.player seekToTime:CMTimeMakeWithSeconds(self.startTime, self.mediaAsset.duration.timescale) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
            [self.seekSlider setValue:self.startTime];
        }
    }
    else if (mnMediaType == MEDIA_MUSIC)
    {
        [self.mediaPlayerLayer.player seekToTime:CMTimeMakeWithSeconds(self.startTime, self.mediaAsset.duration.timescale) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
        [self.reverseAudioPlayerLayer.player seekToTime:CMTimeMakeWithSeconds(self.startTime, self.mediaAsset.duration.timescale) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];

        [self getShowTime:_nDirection];
    }
    [self.playBtn setImage:[UIImage imageNamed:@"NewPlay"] forState:UIControlStateNormal];
}

- (void) mediaTrimPlayFinished
{
    self.isPlaying = NO;
    [self.mediaPlayerLayer.player pause];
   
    
    if ( mnMediaType == MEDIA_MUSIC) {
        [self.reverseAudioPlayerLayer.player pause];
    }


    if (mnMediaType == MEDIA_VIDEO)
    {
        if (self.mnReverseFlag)
        {
            [self.mediaPlayerLayer.player seekToTime:CMTimeMakeWithSeconds(self.stopTime, self.mediaAsset.duration.timescale) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
            [self.seekSlider setValue:self.stopTime];
        }
        else
        {
            [self.mediaPlayerLayer.player seekToTime:CMTimeMakeWithSeconds(self.startTime, self.mediaAsset.duration.timescale) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
            [self.seekSlider setValue:self.startTime];
        }
    }
    else if (mnMediaType == MEDIA_MUSIC)
    {
        [self.mediaPlayerLayer.player seekToTime:CMTimeMakeWithSeconds(self.startTime, self.mediaAsset.duration.timescale) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
        [self.reverseAudioPlayerLayer.player seekToTime:CMTimeMakeWithSeconds(self.startTime, self.mediaAsset.duration.timescale) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
        [self getShowTime:_nDirection];
    }
    
    [self.playBtn setImage:[UIImage imageNamed:@"NewPlay"] forState:UIControlStateNormal];
}



//Changed By Yinjing 0328
-(void) playerSeekPositionChanged
{
    CGRect rect  = [self.waveform getImageRect];
    float time;
    if ( mnMediaType == MEDIA_MUSIC) {
        time = self.seekSlider.value * CMTimeGetSeconds(self.mediaAsset.duration) / rect.size.width;
    }
    else
        time = self.seekSlider.value;
    
    if ( time < self.startTime ) {
        time = self.startTime;
    }
    if ( time > self.stopTime ) {
        time = self.stopTime;
    }
    [self.mediaPlayerLayer.player seekToTime:CMTimeMakeWithSeconds(time , self.mediaAsset.duration.timescale) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    if ( mnMediaType == MEDIA_MUSIC) {
        [self.reverseAudioPlayerLayer.player seekToTime:CMTimeMakeWithSeconds(time , self.mediaAsset.duration.timescale) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    }
}


#pragma mark -
#pragma mark - Save Copy CheckBox

-(void) onSaveCheckBox
{
    if (self.saveCheckBoxBtn.selected)
    {
        [self.saveCheckBoxBtn setSelected:NO];
        mnSaveCopyFlag = NO;
    }
    else
    {
        [self.saveCheckBoxBtn setSelected:YES];
        mnSaveCopyFlag = YES;
    }
}


#pragma mark -
#pragma mark - Reverse CheckBox

-(void) onReverseCheckBox
{
    if (self.isPlaying)
    {
        [self.mediaPlayerLayer.player pause];
        self.isPlaying = NO;
        [self.playBtn setImage:[UIImage imageNamed:@"NewPlay"] forState:UIControlStateNormal];
    }

    if (self.reverseCheckBoxBtn.selected)
    {
        [self.reverseCheckBoxBtn setSelected:NO];
        self.mnReverseFlag = NO;
        
        [self.seekSlider setValue:self.startTime];
        [self.mediaPlayerLayer.player seekToTime:CMTimeMakeWithSeconds(self.startTime, self.mediaAsset.duration.timescale) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    }
    else
    {
        [self.reverseCheckBoxBtn setSelected:YES];
        self.mnReverseFlag = YES;
        
        [self.seekSlider setValue:self.stopTime];
        [self.mediaPlayerLayer.player seekToTime:CMTimeMakeWithSeconds(self.stopTime, self.mediaAsset.duration.timescale) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    }
}

- (int) getMediaType
{
    return mnMediaType;
}

- (void)hudWillDisappear:(ATMHud *)_hud
{
    isExpertCancelled = YES;
    
    if (self.mnReverseFlag && (self.assetWriter.status == AVAssetWriterStatusWriting))
    {
        [self.assetWriter cancelWriting];
        self.assetWriter = nil;
    }
    else
    {
        AVAssetExportSession* session = progressTimer.userInfo;
        [session cancelExport];
    }
    
    [progressTimer invalidate];
    progressTimer = nil;
}


#pragma mark -
#pragma mark - did action Apply button

- (void)actionApplyButton:(id)sender
{
    NSArray *menuItems =
    @[
      [YJLActionMenuItem menuItem:@"Apply Trim"
                            image:nil
                           target:self
                           action:@selector(applyTrim:)],
      
      [YJLActionMenuItem menuItem:@"Cancel"
                            image:nil
                           target:self
                           action:@selector(didCancelTrim:)],
      
      ];
    
    CGRect frame = [self.trimBtn convertRect:self.trimBtn.bounds toView:self];
    [YJLActionMenu showMenuInView:self
                         fromRect:frame
                        menuItems:menuItems isWhiteBG:NO];
}

- (void)didCancelTrim:(id) sender
{
    isExpertCancelled = YES;
    
    if (self.mnReverseFlag && (self.assetWriter.status == AVAssetWriterStatusWriting))
    {
        [self.assetWriter cancelWriting];
        self.assetWriter = nil;
    }
    else
    {
        AVAssetExportSession* session = progressTimer.userInfo;
        [session cancelExport];
    }
    
    [progressTimer invalidate];
    progressTimer = nil;
    
    [self.mediaPlayerLayer.player pause];
    if ( mnMediaType == MEDIA_MUSIC) {
        [self.reverseAudioPlayerLayer.player pause];
    }

    if ([self.delegate respondsToSelector:@selector(didCancelTrimUI)])
    {
        [self.delegate didCancelTrimUI];
    }
}

#pragma mark -
#pragma mark - Apply Trim

- (void)applyTrim:(id)sender
{
    isExpertCancelled = NO;
    [self.mediaPlayerLayer.player pause];

    CMTime mediaDuration = self.mediaAsset.duration;
    
    if (mnMediaType == MEDIA_VIDEO)
    {
        if (self.mnReverseFlag)  // Reverse
        {
            NSError *error = nil;

            AVMutableComposition* mixComposition = [[AVMutableComposition alloc] init];
            
            AVMutableCompositionTrack *videoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
            NSArray *videoDataSourceArray = [NSArray arrayWithArray:[self.mediaAsset tracksWithMediaType:AVMediaTypeVideo]];
            
            CMTime startTimeOnComposition = kCMTimeZero;
            
            for (int i=0; i<self.myMediaRangeSlider.videoRangeSliderArray.count; i++)
            {
                SASliderView* sliderView = [self.myMediaRangeSlider.videoRangeSliderArray objectAtIndex:i];
                
                CGFloat startPos = (sliderView.leftPos * CMTimeGetSeconds(self.mediaAsset.duration) / self.myMediaRangeSlider.frame.size.width);
                CGFloat stopPos = (sliderView.rightPos * CMTimeGetSeconds(self.mediaAsset.duration) / self.myMediaRangeSlider.frame.size.width);
                
                CMTime start = CMTimeMake(startPos * mediaDuration.timescale, mediaDuration.timescale);
                CMTime duration = CMTimeMake((stopPos - startPos) * mediaDuration.timescale, mediaDuration.timescale);
                
                [videoTrack insertTimeRange:CMTimeRangeMake(start, duration)
                                    ofTrack:([videoDataSourceArray count]>0)?[videoDataSourceArray objectAtIndex:0]:nil
                                     atTime:startTimeOnComposition
                                      error:&error];
                if(error)
                    NSLog(@"Insertion error: %@", error);
                
                startTimeOnComposition = CMTimeAdd(startTimeOnComposition, duration);
            }
            
            NSArray *audioDataSourceArray = [NSArray arrayWithArray: [self.mediaAsset tracksWithMediaType:AVMediaTypeAudio]];
            if ([audioDataSourceArray count] > 0)
            {
                AVMutableCompositionTrack *audioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
                error = nil;
                
                startTimeOnComposition = kCMTimeZero;
                
                for (int i=0; i<self.myMediaRangeSlider.videoRangeSliderArray.count; i++)
                {
                    SASliderView* sliderView = [self.myMediaRangeSlider.videoRangeSliderArray objectAtIndex:i];
                    
                    CGFloat startPos = (sliderView.leftPos * CMTimeGetSeconds(self.mediaAsset.duration) / self.myMediaRangeSlider.frame.size.width);
                    CGFloat stopPos = (sliderView.rightPos * CMTimeGetSeconds(self.mediaAsset.duration) / self.myMediaRangeSlider.frame.size.width);
                    
                    CMTime start = CMTimeMakeWithSeconds(startPos, mediaDuration.timescale);
                    CMTime duration = CMTimeMakeWithSeconds((stopPos - startPos), mediaDuration.timescale);
                    
                    [audioTrack insertTimeRange:CMTimeRangeMake(start, duration)
                                        ofTrack:[audioDataSourceArray objectAtIndex:0]
                                         atTime:startTimeOnComposition
                                          error:&error];
                    if(error)
                        NSLog(@"Insertion error: %@", error);
                    
                    startTimeOnComposition = CMTimeAdd(startTimeOnComposition, duration);
                }
            }
            
            progressTimer = [NSTimer scheduledTimerWithTimeInterval:.02f target:self selector:@selector(progressLandscapeVideoReverseUpdate:) userInfo:nil repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:progressTimer forMode:NSRunLoopCommonModes];
            [self.hudProgressView setCaption:@"Reversing Video..."];
            [self.hudProgressView setProgress:0.08];
            [self.hudProgressView show];
            [self.hudProgressView showDismissButton];

            AVAssetTrack *assetTrack = [[self.mediaAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
            CGAffineTransform firstTransform = assetTrack.preferredTransform;
            
            [[SHKActivityIndicator currentIndicator] displayActivity:@"Preparing..." isLock:YES];

            BOOL isNeedToFixAffinetransform = NO;
            
            if((firstTransform.a == 0) && (firstTransform.b == 1.0) && (firstTransform.c == -1.0) && (firstTransform.d == 0))//portrait
            {
                isNeedToFixAffinetransform = YES;
                mnVideoOrientation = PortraitVideo;
                reverseVideoSize = CGSizeMake(mixComposition.naturalSize.height, mixComposition.naturalSize.width);
            }
            else if((firstTransform.a == 0) && (firstTransform.b == -1.0) && (firstTransform.c == 1.0) && (firstTransform.d == 0))//upside down
            {
                isNeedToFixAffinetransform = YES;
                mnVideoOrientation = UpsideDownVideo;
                reverseVideoSize = CGSizeMake(mixComposition.naturalSize.height, mixComposition.naturalSize.width);
            }
            else if ((firstTransform.a == -1) && (firstTransform.b == 0.0) && (firstTransform.c == 0.0) && (firstTransform.d == -1.0))//landscape left
            {
                isNeedToFixAffinetransform = YES;
                mnVideoOrientation = LandscapeLeftVideo;
                reverseVideoSize = mixComposition.naturalSize;
            }
            else
            {
                isNeedToFixAffinetransform = NO;
                mnVideoOrientation = LandscapeRightVideo;
                reverseVideoSize = mixComposition.naturalSize;
            }
            
            cropVideoSize = reverseVideoSize;
            
            if (isCameraVideo || isNeedToFixAffinetransform)
            {
                if (isCameraVideo)
                {
                    if (gnTemplateIndex == TEMPLATE_SQUARE)
                    {
                        if (reverseVideoSize.width > reverseVideoSize.height)
                            cropVideoSize = CGSizeMake(reverseVideoSize.height, reverseVideoSize.height);
                        else if (reverseVideoSize.height > reverseVideoSize.width)
                            cropVideoSize = CGSizeMake(reverseVideoSize.width, reverseVideoSize.width);
                    }
                    else if (gnTemplateIndex == TEMPLATE_LANDSCAPE)
                    {
                        if((mnVideoOrientation == LandscapeLeftVideo)||(mnVideoOrientation == LandscapeRightVideo))//landscape left, right
                        {
                            CGSize workspaceSize = CGSizeZero;
                            
                            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
                            {
                                if (isIPhoneFive)
                                    workspaceSize = CGSizeMake(568.0f, 320.0f);
                                else
                                    workspaceSize = CGSizeMake(480.0f, 320.0f);
                            }
                            else
                                workspaceSize = CGSizeMake(1024.0f, 768.0f);
                            
                            cropVideoSize = CGSizeMake(reverseVideoSize.height*workspaceSize.width/workspaceSize.height, reverseVideoSize.height);
                        }
                    }
                    else if (gnTemplateIndex == TEMPLATE_1080P)
                    {
                        if((mnVideoOrientation == LandscapeLeftVideo)||(mnVideoOrientation == LandscapeRightVideo))//landscape left, right
                        {
                            CGSize workspaceSize = CGSizeZero;
                            
                            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
                            {
                                if (isIPhoneFive)
                                    workspaceSize = CGSizeMake(568.0f, 320.0f);
                                else
                                    workspaceSize = CGSizeMake(480.0f, 270.0f);
                            }
                            else
                                workspaceSize = CGSizeMake(1024.0f, 576.0f);
                            
                            cropVideoSize = CGSizeMake(reverseVideoSize.height*workspaceSize.width/workspaceSize.height, reverseVideoSize.height);
                        }
                    }
                    else if (gnTemplateIndex == TEMPLATE_PORTRAIT)
                    {
                        if((mnVideoOrientation == PortraitVideo)||(mnVideoOrientation == UpsideDownVideo))//portrait up, down
                        {
                            CGSize workspaceSize = CGSizeZero;
                            
                            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
                            {
                                if (isIPhoneFive)
                                    workspaceSize = CGSizeMake(320.0f, 568.0f);
                                else
                                    workspaceSize = CGSizeMake(320.0f, 480.0f);
                            }
                            else
                                workspaceSize = CGSizeMake(768.0f, 1024.0f);
                            
                            cropVideoSize = CGSizeMake(reverseVideoSize.width, reverseVideoSize.width*workspaceSize.height/workspaceSize.width);
                        }
                    }
                }

                [self performSelectorInBackground:@selector(createReverseVideoFromComposition:) withObject:mixComposition];
            }
            else
            {
                [self performSelectorInBackground:@selector(reverseComposition:) withObject:mixComposition];
            }
        }
        else    // Trim Only
        {
            AVMutableComposition* mixComposition = [[AVMutableComposition alloc] init];
            AVMutableVideoCompositionLayerInstruction *layerInstruction = nil;
            
            //Video Track
            AVMutableCompositionTrack *videoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
            NSArray *videoDataSourceArray = [NSArray arrayWithArray: [self.mediaAsset tracksWithMediaType:AVMediaTypeVideo]];
            NSError *error = nil;
            
            CMTime startTimeOnComposition = kCMTimeZero;
            
            for (int i=0; i<self.myMediaRangeSlider.videoRangeSliderArray.count; i++)
            {
                SASliderView* sliderView = [self.myMediaRangeSlider.videoRangeSliderArray objectAtIndex:i];
                
                CGFloat startPos = (sliderView.leftPos * CMTimeGetSeconds(self.mediaAsset.duration) / self.myMediaRangeSlider.frame.size.width);
                CGFloat stopPos = (sliderView.rightPos * CMTimeGetSeconds(self.mediaAsset.duration) / self.myMediaRangeSlider.frame.size.width);
                
                CMTime start = CMTimeMakeWithSeconds(startPos, mediaDuration.timescale);
                CMTime duration = CMTimeMakeWithSeconds((stopPos - startPos), mediaDuration.timescale);
                
                [videoTrack insertTimeRange:CMTimeRangeMake(start, duration)
                                    ofTrack:([videoDataSourceArray count]>0)?[videoDataSourceArray objectAtIndex:0]:nil
                                     atTime:startTimeOnComposition
                                      error:&error];
                if(error)
                    NSLog(@"Insertion error: %@", error);
                
                startTimeOnComposition = CMTimeAdd(startTimeOnComposition, duration);
            }
            
            //Audio Track
            NSArray *audioDataSourceArray = [NSArray arrayWithArray: [self.mediaAsset tracksWithMediaType:AVMediaTypeAudio]];
            if ([audioDataSourceArray count] > 0)
            {
                AVMutableCompositionTrack *audioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
                error = nil;
                
                CMTime startTimeOnComposition = kCMTimeZero;
                
                for (int i=0; i<self.myMediaRangeSlider.videoRangeSliderArray.count; i++)
                {
                    SASliderView* sliderView = [self.myMediaRangeSlider.videoRangeSliderArray objectAtIndex:i];
                    
                    CGFloat startPos = (sliderView.leftPos * CMTimeGetSeconds(self.mediaAsset.duration) / self.myMediaRangeSlider.frame.size.width);
                    CGFloat stopPos = (sliderView.rightPos * CMTimeGetSeconds(self.mediaAsset.duration) / self.myMediaRangeSlider.frame.size.width);
                    
                    CMTime start = CMTimeMakeWithSeconds(startPos, mediaDuration.timescale);
                    CMTime duration = CMTimeMakeWithSeconds((stopPos - startPos), mediaDuration.timescale);
                    
                    [audioTrack insertTimeRange:CMTimeRangeMake(start, duration)
                                        ofTrack:[audioDataSourceArray objectAtIndex:0]
                                         atTime:startTimeOnComposition
                                          error:&error];
                    if(error)
                        NSLog(@"Insertion error: %@", error);
                    
                    startTimeOnComposition = CMTimeAdd(startTimeOnComposition, duration);
                }
            }
            
            layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
            
            AVAssetTrack *assetTrack = [[self.mediaAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
            CGAffineTransform firstTransform = assetTrack.preferredTransform;
            CGSize videoSize = assetTrack.naturalSize;
            
            if (isCameraVideo && (gnTemplateIndex == TEMPLATE_SQUARE))
            {
                CGRect cropRect = CGRectZero;

                if(firstTransform.a == 0 && firstTransform.b == 1.0 && firstTransform.c == -1.0 && firstTransform.d == 0)//portrait
                {
                    videoSize = CGSizeMake(assetTrack.naturalSize.height, assetTrack.naturalSize.height);
                    cropRect = CGRectMake((assetTrack.naturalSize.width - assetTrack.naturalSize.height)/2.0f, 0.0f, assetTrack.naturalSize.height, assetTrack.naturalSize.height);

                    CGAffineTransform transform = CGAffineTransformIdentity;
                    transform = CGAffineTransformConcat(assetTrack.preferredTransform, transform);
                    transform = CGAffineTransformTranslate(transform, -(assetTrack.naturalSize.width - assetTrack.naturalSize.height)/2.0f, 0.0f);
                    [layerInstruction setTransform:transform atTime:kCMTimeZero];
                    [layerInstruction setOpacity:1.0 atTime:kCMTimeZero];
                }
                else if(firstTransform.a == 0 && firstTransform.b == -1.0 && firstTransform.c == 1.0 && firstTransform.d == 0)//portrait-home top
                {
                    videoSize = CGSizeMake(assetTrack.naturalSize.height, assetTrack.naturalSize.height);
                    cropRect = CGRectMake((assetTrack.naturalSize.width - assetTrack.naturalSize.height)/2, 0.0f, assetTrack.naturalSize.height, assetTrack.naturalSize.height);

                    CGAffineTransform transform = CGAffineTransformIdentity;
                    transform = CGAffineTransformTranslate(transform, 0.0f, -(assetTrack.naturalSize.width - assetTrack.naturalSize.height)/2);
                    transform = CGAffineTransformConcat(assetTrack.preferredTransform, transform);
                    [layerInstruction setTransform:transform atTime:kCMTimeZero];
                    [layerInstruction setOpacity:1.0 atTime:kCMTimeZero];
                }
                else if(firstTransform.a == -1 && firstTransform.b == 0.0 && firstTransform.c == 0.0 && firstTransform.d == -1.0)//landscape left
                {
                    videoSize = CGSizeMake(assetTrack.naturalSize.height, assetTrack.naturalSize.height);
                    cropRect = CGRectMake((assetTrack.naturalSize.width - assetTrack.naturalSize.height)/2, 0.0f, assetTrack.naturalSize.height, assetTrack.naturalSize.height);

                    CGAffineTransform transform = CGAffineTransformIdentity;
                    transform = CGAffineTransformConcat(assetTrack.preferredTransform, transform);
                    transform = CGAffineTransformTranslate(transform, (assetTrack.naturalSize.width - assetTrack.naturalSize.height)/2, 0.0f);
                    [layerInstruction setTransform:transform atTime:kCMTimeZero];
                    [layerInstruction setOpacity:1.0 atTime:kCMTimeZero];
                }
                else
                {
                    videoSize = CGSizeMake(assetTrack.naturalSize.height, assetTrack.naturalSize.height);
                    cropRect = CGRectMake((assetTrack.naturalSize.width - assetTrack.naturalSize.height)/2, 0.0f, assetTrack.naturalSize.height, assetTrack.naturalSize.height);

                    CGAffineTransform transform = CGAffineTransformIdentity;
                    transform = CGAffineTransformConcat(assetTrack.preferredTransform, transform);
                    transform = CGAffineTransformTranslate(transform, -(assetTrack.naturalSize.width - assetTrack.naturalSize.height)/2, 0.0f);
                    [layerInstruction setTransform:transform atTime:kCMTimeZero];
                    [layerInstruction setOpacity:1.0 atTime:kCMTimeZero];
                }

                [layerInstruction setCropRectangle:cropRect atTime:kCMTimeZero];
            }
            else if (isCameraVideo && (gnTemplateIndex == TEMPLATE_LANDSCAPE))
            {
                if((firstTransform.a == -1 && firstTransform.b == 0.0 && firstTransform.c == 0.0 && firstTransform.d == -1.0)||(firstTransform.a == 1 && firstTransform.b == 0.0 && firstTransform.c == 0.0 && firstTransform.d == 1.0))//landscape left, right
                {
                    CGRect cropRect = CGRectZero;
                    CGSize workspaceSize = CGSizeZero;
                    
                    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
                    {
                        if (isIPhoneFive)
                            workspaceSize = CGSizeMake(568.0f, 320.0f);
                        else
                            workspaceSize = CGSizeMake(480.0f, 320.0f);
                    }
                    else
                    {
                        workspaceSize = CGSizeMake(1024.0f, 768.0f);
                    }

                    videoSize = CGSizeMake(assetTrack.naturalSize.height*workspaceSize.width/workspaceSize.height, assetTrack.naturalSize.height);
                    cropRect = CGRectMake((assetTrack.naturalSize.width - videoSize.width)/2, 0.0f, videoSize.width, videoSize.height);
                    
                    CGAffineTransform transform = CGAffineTransformIdentity;
                    transform = CGAffineTransformConcat(assetTrack.preferredTransform, transform);
                    
                    if (firstTransform.a == -1 && firstTransform.b == 0.0 && firstTransform.c == 0.0 && firstTransform.d == -1.0)
                        transform = CGAffineTransformTranslate(transform, (assetTrack.naturalSize.width - videoSize.width)/2, 0.0f);
                    else if (firstTransform.a == 1 && firstTransform.b == 0.0 && firstTransform.c == 0.0 && firstTransform.d == 1.0)
                        transform = CGAffineTransformTranslate(transform, -(assetTrack.naturalSize.width - videoSize.width)/2, 0.0f);
                    
                    [layerInstruction setTransform:transform atTime:kCMTimeZero];
                    [layerInstruction setOpacity:1.0 atTime:kCMTimeZero];
                    [layerInstruction setCropRectangle:cropRect atTime:kCMTimeZero];
                }
                else
                {
                    if(firstTransform.a == 0 && firstTransform.b == 1.0 && firstTransform.c == -1.0 && firstTransform.d == 0)//portrait
                        videoSize = CGSizeMake(assetTrack.naturalSize.height, assetTrack.naturalSize.width);
                    else if(firstTransform.a == 0 && firstTransform.b == -1.0 && firstTransform.c == 1.0 && firstTransform.d == 0)//portrait-home top
                        videoSize = CGSizeMake(assetTrack.naturalSize.height, assetTrack.naturalSize.width);
                    
                    CGAffineTransform transform = CGAffineTransformIdentity;
                    [layerInstruction setTransform:CGAffineTransformConcat(assetTrack.preferredTransform, transform) atTime:kCMTimeZero];
                    [layerInstruction setOpacity:1.0 atTime:kCMTimeZero];
                }
            }
            else if (isCameraVideo && (gnTemplateIndex == TEMPLATE_1080P))
            {
                if((firstTransform.a == -1 && firstTransform.b == 0.0 && firstTransform.c == 0.0 && firstTransform.d == -1.0)||(firstTransform.a == 1 && firstTransform.b == 0.0 && firstTransform.c == 0.0 && firstTransform.d == 1.0))//landscape left, right
                {
                    CGRect cropRect = CGRectZero;
                    CGSize workspaceSize = CGSizeZero;
                    
                    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
                    {
                        if (isIPhoneFive)
                            workspaceSize = CGSizeMake(568.0f, 320.0f);
                        else
                            workspaceSize = CGSizeMake(480.0f, 270.0f);
                    }
                    else
                    {
                        workspaceSize = CGSizeMake(1024.0f, 576.0f);
                    }
                    
                    videoSize = CGSizeMake(assetTrack.naturalSize.height*workspaceSize.width/workspaceSize.height, assetTrack.naturalSize.height);
                    cropRect = CGRectMake((assetTrack.naturalSize.width - videoSize.width)/2, 0.0f, videoSize.width, videoSize.height);
                    
                    CGAffineTransform transform = CGAffineTransformIdentity;
                    transform = CGAffineTransformConcat(assetTrack.preferredTransform, transform);
                    
                    if (firstTransform.a == -1 && firstTransform.b == 0.0 && firstTransform.c == 0.0 && firstTransform.d == -1.0)
                        transform = CGAffineTransformTranslate(transform, (assetTrack.naturalSize.width - videoSize.width)/2, 0.0f);
                    else if (firstTransform.a == 1 && firstTransform.b == 0.0 && firstTransform.c == 0.0 && firstTransform.d == 1.0)
                        transform = CGAffineTransformTranslate(transform, -(assetTrack.naturalSize.width - videoSize.width)/2, 0.0f);

                    [layerInstruction setTransform:transform atTime:kCMTimeZero];
                    [layerInstruction setOpacity:1.0 atTime:kCMTimeZero];
                    [layerInstruction setCropRectangle:cropRect atTime:kCMTimeZero];
                }
                else
                {
                    if(firstTransform.a == 0 && firstTransform.b == 1.0 && firstTransform.c == -1.0 && firstTransform.d == 0)//portrait
                        videoSize = CGSizeMake(assetTrack.naturalSize.height, assetTrack.naturalSize.width);
                    else if(firstTransform.a == 0 && firstTransform.b == -1.0 && firstTransform.c == 1.0 && firstTransform.d == 0)//portrait-home top
                        videoSize = CGSizeMake(assetTrack.naturalSize.height, assetTrack.naturalSize.width);
                    
                    CGAffineTransform transform = CGAffineTransformIdentity;
                    [layerInstruction setTransform:CGAffineTransformConcat(assetTrack.preferredTransform, transform) atTime:kCMTimeZero];
                    [layerInstruction setOpacity:1.0 atTime:kCMTimeZero];
                }
            }
            else if (isCameraVideo && (gnTemplateIndex == TEMPLATE_PORTRAIT))
            {
                if((firstTransform.a == 0 && firstTransform.b == 1.0 && firstTransform.c == -1.0 && firstTransform.d == 0)||(firstTransform.a == 0 && firstTransform.b == -1.0 && firstTransform.c == 1.0 && firstTransform.d == 0))//portrait up, down
                {
                    CGRect cropRect = CGRectZero;
                    CGSize workspaceSize = CGSizeZero;
                    
                    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
                    {
                        if (isIPhoneFive)
                            workspaceSize = CGSizeMake(568.0f, 320.0f);
                        else
                            workspaceSize = CGSizeMake(480.0f, 320.0f);
                    }
                    else
                    {
                        workspaceSize = CGSizeMake(1024.0f, 768.0f);
                    }
                    
                    videoSize = CGSizeMake(assetTrack.naturalSize.height*workspaceSize.width/workspaceSize.height, assetTrack.naturalSize.height);
                    cropRect = CGRectMake((assetTrack.naturalSize.width - videoSize.width)/2, 0.0f, videoSize.width, videoSize.height);
                    
                    if(firstTransform.a == 0 && firstTransform.b == 1.0 && firstTransform.c == -1.0 && firstTransform.d == 0)//portrait
                    {
                        CGAffineTransform transform = CGAffineTransformIdentity;
                        transform = CGAffineTransformConcat(assetTrack.preferredTransform, transform);
                        transform = CGAffineTransformTranslate(transform, -(assetTrack.naturalSize.width - videoSize.width)/2, 0.0f);
                        [layerInstruction setTransform:transform atTime:kCMTimeZero];
                        [layerInstruction setOpacity:1.0 atTime:kCMTimeZero];
                    }
                    else if(firstTransform.a == 0 && firstTransform.b == -1.0 && firstTransform.c == 1.0 && firstTransform.d == 0)//portrait-home top
                    {
                        CGAffineTransform transform = CGAffineTransformIdentity;
                        transform = CGAffineTransformTranslate(transform, 0.0f, -(assetTrack.naturalSize.width - videoSize.width)/2);
                        transform = CGAffineTransformConcat(assetTrack.preferredTransform, transform);
                        [layerInstruction setTransform:transform atTime:kCMTimeZero];
                        [layerInstruction setOpacity:1.0 atTime:kCMTimeZero];
                    }

                    [layerInstruction setCropRectangle:cropRect atTime:kCMTimeZero];
                    videoSize = CGSizeMake(videoSize.height, videoSize.width);
                }
                else
                {
                    if(firstTransform.a == 0 && firstTransform.b == 1.0 && firstTransform.c == -1.0 && firstTransform.d == 0)//portrait
                        videoSize = CGSizeMake(assetTrack.naturalSize.height, assetTrack.naturalSize.width);
                    else if(firstTransform.a == 0 && firstTransform.b == -1.0 && firstTransform.c == 1.0 && firstTransform.d == 0)//portrait-home top
                        videoSize = CGSizeMake(assetTrack.naturalSize.height, assetTrack.naturalSize.width);
                    
                    CGAffineTransform transform = CGAffineTransformIdentity;
                    [layerInstruction setTransform:CGAffineTransformConcat(assetTrack.preferredTransform, transform) atTime:kCMTimeZero];
                    [layerInstruction setOpacity:1.0 atTime:kCMTimeZero];
                }
            }
            else
            {
                if(firstTransform.a == 0 && firstTransform.b == 1.0 && firstTransform.c == -1.0 && firstTransform.d == 0)//portrait
                    videoSize = CGSizeMake(assetTrack.naturalSize.height, assetTrack.naturalSize.width);
                else if(firstTransform.a == 0 && firstTransform.b == -1.0 && firstTransform.c == 1.0 && firstTransform.d == 0)//portrait-home top
                    videoSize = CGSizeMake(assetTrack.naturalSize.height, assetTrack.naturalSize.width);
                
                CGAffineTransform transform = CGAffineTransformIdentity;
                [layerInstruction setTransform:CGAffineTransformConcat(assetTrack.preferredTransform, transform) atTime:kCMTimeZero];
                [layerInstruction setOpacity:1.0 atTime:kCMTimeZero];
            }
            
            AVMutableVideoCompositionInstruction * MainInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
            MainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, mixComposition.duration);
            MainInstruction.backgroundColor = [UIColor clearColor].CGColor;
            MainInstruction.layerInstructions = @[layerInstruction];
            
            AVMutableVideoComposition *MainCompositionInst = [AVMutableVideoComposition videoComposition];
            MainCompositionInst.instructions = @[MainInstruction];
            MainCompositionInst.frameDuration = CMTimeMake(1.0f, 30.0f);
            MainCompositionInst.renderSize = videoSize;
            
            if (self.exportSession) {
                self.exportSession = nil;
            }

            self.exportSession = [[AVAssetExportSession alloc]
                                   initWithAsset:mixComposition presetName:AVAssetExportPresetHighestQuality];
            self.exportSession.outputURL = self.tmpMediaUrl;
            self.exportSession.outputFileType = AVFileTypeQuickTimeMovie;
            self.exportSession.videoComposition = MainCompositionInst;
            self.exportSession.shouldOptimizeForNetworkUse = YES;
            self.exportSession.timeRange = CMTimeRangeMake(kCMTimeZero, mixComposition.duration);
            
            prevPro = 0.0f;
            isSameProgress = NO;
            
            progressTimer = [NSTimer scheduledTimerWithTimeInterval:.02 target:self selector:@selector(progressSimpleUpdate:) userInfo:self.exportSession repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:progressTimer forMode:NSRunLoopCommonModes];
            [self.hudProgressView setCaption:@"Importing Video..."];
            [self.hudProgressView setProgress:0.08];
            [self.hudProgressView show];
            [self.hudProgressView showDismissButton];

            [self.exportSession exportAsynchronouslyWithCompletionHandler:^{
                
                dispatch_async(dispatch_get_main_queue(), ^{

                    switch ([self.exportSession status])
                    {
                        case AVAssetExportSessionStatusFailed:
                        {
                            NSLog(@"Export failed: %@", [[self.exportSession error] localizedDescription]);
                            
                            [self.exportSession cancelExport];
                            
                            [[SHKActivityIndicator currentIndicator] hide];
                            
                            [progressTimer invalidate];
                            progressTimer = nil;
                            
                            [self.hudProgressView hide];
                        }
                            break;
                            
                        case AVAssetExportSessionStatusCancelled:
                        {
                            NSLog(@"Export canceled");
                            
                            [self.exportSession cancelExport];

                            [[SHKActivityIndicator currentIndicator] hide];
                            
                            [progressTimer invalidate];
                            progressTimer = nil;
                            
                            [self.hudProgressView hide];
                            
                            self.exportSession = nil;
                        }
                            break;
                        case AVAssetExportSessionStatusUnknown:
                            
                            [[SHKActivityIndicator currentIndicator] hide];

                            NSLog(@"AVAssetExportSessionStatusUnknown");
                            
                            break;
                        case AVAssetExportSessionStatusWaiting:

                            [[SHKActivityIndicator currentIndicator] hide];

                            NSLog(@"AVAssetExportSessionStatusWaiting");
                            
                            break;
                        case AVAssetExportSessionStatusExporting:

                            [[SHKActivityIndicator currentIndicator] hide];

                            NSLog(@"AVAssetExportSessionStatusExporting");
                            
                            break;
                            
                        default:
                        {
                            [[SHKActivityIndicator currentIndicator] hide];
                            
                            if ((mnSaveCopyFlag) && (mnMediaType == MEDIA_VIDEO))
                                [self saveMovieToPhotoAlbum];
                            
                            if ([self.delegate respondsToSelector:@selector(didCompletedTrim:type:)])
                            {
                                [self.delegate didCompletedTrim:self.tmpMediaUrl type:mnMediaType];
                            }
                            
                            [progressTimer invalidate];
                            progressTimer = nil;
                            
                            [self.hudProgressView hide];
                            
                            self.mediaPlayerLayer.player = nil;
                            
                            if (self.mediaPlayerLayer != nil){
                                [self.mediaPlayerLayer removeFromSuperlayer];
                                self.mediaPlayerLayer = nil;
                            }
                            
                            self.exportSession = nil;
                        }
                            break;
                    }

                });

            }];
        }
    }
    else if(mnMediaType == MEDIA_MUSIC)
    {
        AVMutableComposition* mixComposition = [[AVMutableComposition alloc] init];
            
        NSArray *audioDataSourceArray = [NSArray arrayWithArray: [self.mediaAsset tracksWithMediaType:AVMediaTypeAudio]];
        
        if ([audioDataSourceArray count] > 0)
        {
            AVMutableCompositionTrack *audioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
            NSError* error = nil;
            
            CMTime startTimeOnComposition = kCMTimeZero;
            
            for (int i=0; i<self.myMediaRangeSlider.videoRangeSliderArray.count; i++)
            {
                SASliderView* sliderView = [self.myMediaRangeSlider.videoRangeSliderArray objectAtIndex:i];
                
                CGFloat startPos = (sliderView.leftPos * CMTimeGetSeconds(self.mediaAsset.duration) / self.myMediaRangeSlider.frame.size.width);
                CGFloat stopPos = (sliderView.rightPos * CMTimeGetSeconds(self.mediaAsset.duration) / self.myMediaRangeSlider.frame.size.width);
                
                CMTime start = CMTimeMakeWithSeconds(startPos, mediaDuration.timescale);
                CMTime duration = CMTimeMakeWithSeconds((stopPos - startPos), mediaDuration.timescale);
                
                [audioTrack insertTimeRange:CMTimeRangeMake(start, duration)
                                    ofTrack:[audioDataSourceArray objectAtIndex:0]
                                     atTime:startTimeOnComposition
                                      error:&error];
                if(error)
                    NSLog(@"Insertion error: %@", error);
                
                startTimeOnComposition = CMTimeAdd(startTimeOnComposition, duration);
            }
        }

        if (self.exportSession) {
            self.exportSession = nil;
        }
        
        self.exportSession = [[AVAssetExportSession alloc]
                              initWithAsset:mixComposition presetName:AVAssetExportPresetAppleM4A];
        self.exportSession.outputURL = self.tmpMediaUrl;
        self.exportSession.outputFileType = AVFileTypeAppleM4A;
        CGFloat totalDuration = CMTimeGetSeconds(mixComposition.duration);
        self.exportSession.timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMakeWithSeconds(totalDuration, mediaDuration.timescale));
        
        prevPro = 0.0f;
        isSameProgress = NO;
        
        [self.hudProgressView setProgress:0.01];
        progressTimer = [NSTimer scheduledTimerWithTimeInterval:.02 target:self selector:@selector(progressSimpleUpdate:) userInfo:self.exportSession repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:progressTimer forMode:NSRunLoopCommonModes];
        [self.hudProgressView setCaption:@"Importing Music..."];
        [self.hudProgressView setProgress:0.08];
        [self.hudProgressView show];
        [self.hudProgressView showDismissButton];
        
        [self.exportSession exportAsynchronouslyWithCompletionHandler:^{
            
            switch ([self.exportSession status])
            {
                case AVAssetExportSessionStatusFailed:
                {
                    NSLog(@"Export failed: %@", [[self.exportSession error] localizedDescription]);
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[SHKActivityIndicator currentIndicator] performSelectorOnMainThread:@selector(hide) withObject:nil waitUntilDone:NO];
                        
                        [progressTimer invalidate];
                        progressTimer = nil;
                        [self.hudProgressView hide];
                        
                        self.exportSession = nil;
                    });
                }
                    break;
                case AVAssetExportSessionStatusCancelled:
                {
                    NSLog(@"Export canceled");
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [[SHKActivityIndicator currentIndicator] performSelectorOnMainThread:@selector(hide) withObject:nil waitUntilDone:NO];
                        
                        [progressTimer invalidate];
                        progressTimer = nil;
                        [self.hudProgressView hide];
                        
                        self.exportSession = nil;
                    });
                }
                    break;
                    
                default:
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [[SHKActivityIndicator currentIndicator] hide];
                        
                        if ((mnSaveCopyFlag) && (mnMediaType == MEDIA_MUSIC))
                            [self saveToLibrary];
                        
                        if ([self.delegate respondsToSelector:@selector(didCompletedTrim:type:)])
                        {
                            [self.delegate didCompletedTrim:self.tmpMediaUrl type:mnMediaType];
                        }
                        
                        [progressTimer invalidate];
                        progressTimer = nil;
                        [self.hudProgressView hide];
                        
                        self.mediaPlayerLayer.player = nil;
                        self.reverseAudioPlayerLayer.player = nil;
                        if (self.mediaPlayerLayer != nil)
                        {
                            [self.mediaPlayerLayer removeFromSuperlayer];
                            self.mediaPlayerLayer = nil;
                            
                            [self.reverseAudioPlayerLayer removeFromSuperlayer];
                            self.reverseAudioPlayerLayer = nil;
                        }
                        
                        self.exportSession = nil;
                    });
                }
                    break;
            }
        }];
     }
}

- (void) saveMovieToPhotoAlbum
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0f)
    {
        ALAssetsLibrary* library = [[ALAssetsLibrary alloc] init];
        
        [library saveVideo:self.tmpMediaUrl toAlbum:@"Video Dreamer" withCompletionBlock:^(NSError *error)
         {
             if (error!=nil)
             {
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Video Saving Failed:%@", [error description]]  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil, nil];
                 [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
                 
                 [[SHKActivityIndicator currentIndicator] hide];
             }
             else
             {
                 NSLog(@"Video Saved!");
                 
                 [progressTimer invalidate];
                 progressTimer = nil;
                 [self.hudProgressView hide];
                 
                 [[SHKActivityIndicator currentIndicator] hide];
             }
         }];
    }
    else
    {
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^
         {
             PHFetchOptions *fetchOptions = [PHFetchOptions new];
             fetchOptions.predicate = [NSPredicate predicateWithFormat:@"title == %@", @"Video Dreamer"];
             
             PHFetchResult *fetchResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:fetchOptions];
             
             if (fetchResult.count == 0)//new create
             {
                 //create asset
                 PHAssetChangeRequest *videoRequest = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:self.tmpMediaUrl];
                 
                 //Create Album
                 PHAssetCollectionChangeRequest *albumRequest = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:@"Video Dreamer"];
                 
                 //get a placeholder for the new asset and add it to the album editing request
                 PHObjectPlaceholder* assetPlaceholder = [videoRequest placeholderForCreatedAsset];
                 
                 [albumRequest addAssets:@[assetPlaceholder]];
             }
             else //add video to album
             {
                 //create asset
                 PHAssetChangeRequest *videoRequest = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:self.tmpMediaUrl];
                 
                 //change Album
                 PHAssetCollection *assetCollection = (PHAssetCollection *)fetchResult[0];
                 PHAssetCollectionChangeRequest *albumRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:assetCollection];
                 
                 //get a placeholder for the new asset and add it to the album editing request
                 PHObjectPlaceholder* assetPlaceholder = [videoRequest placeholderForCreatedAsset];
                 
                 [albumRequest addAssets:@[assetPlaceholder]];
             }
             
         } completionHandler:^(BOOL success, NSError *error) {
             
             if (error!=nil)
             {
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Video Saving Failed:%@", [error description]]  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil, nil];
                 [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
                 
                 [[SHKActivityIndicator currentIndicator] hide];
             }
             else
             {
                 NSLog(@"Video Saved!");
                 
                 [progressTimer invalidate];
                 progressTimer = nil;
                 [self.hudProgressView hide];
                 
                 [[SHKActivityIndicator currentIndicator] hide];
             }
         }];
    }
}

-(void) saveToLibrary
{
    NSFileManager *localFileManager = [NSFileManager defaultManager];
    
    NSString* toFolderName = @"Music Library";
    NSString *toFolderDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Library"];
    NSString *toFolderPath = [toFolderDir stringByAppendingPathComponent:toFolderName];
    
    if (![localFileManager createDirectoryAtPath:toFolderPath withIntermediateDirectories:NO attributes:nil error:nil])
    {
        [localFileManager createDirectoryAtPath:toFolderPath withIntermediateDirectories:NO attributes:nil error:nil];
    }
    
    NSString* musicFileName = [self.tmpMediaUrl lastPathComponent];
    
    NSError* error = nil;
    
    [localFileManager copyItemAtPath:[self.tmpMediaUrl path] toPath:[toFolderPath stringByAppendingPathComponent:musicFileName] error:&error];
}


#pragma mark -
#pragma mark FDWaveformViewDelegate

- (void)waveformViewDidRender:(FDWaveformView *)waveformView
{
    [UIView animateWithDuration:0.02f animations:^{
        waveformView.alpha = 1.0f;
    }];
}


// Changed By Yinjing 0328

#pragma mark -
#pragma mark - SAVideoRangeSliderDelegate

- (void)videoRange:(SAVideoRangeSlider *)videoRange didChangeLeftPosition:(CGFloat)leftPosition rightPosition:(CGFloat)rightPosition LCR:(int)leftCenterRight value:(CGFloat)motionValue
{
    self.startTime = leftPosition;
    self.stopTime = rightPosition;
    
    self.isTempPlaying = TRUE;
    
    double delta2 = 0;
    NSTimeInterval timeInMiliseconds = [[NSDate date] timeIntervalSince1970];
    if ( self.previousRealTime != 0 ) {
        delta2 =  self.startTime - self.previousStartTime;
        if ( mnMediaType == MEDIA_MUSIC) {
            if ( delta2 < 0 ){
                self.bReverse = true;
            }
            else{
                self.bReverse = false;
            }
        }
    }
  
    if (leftCenterRight == LEFT)    [self actuallySeekToTime:LEFT];
    else if (leftCenterRight == RIGHT)    [self actuallySeekToTime:RIGHT];
    else    [self actuallySeekToTime:CENTER];
    
    [self.myMediaRangeSlider updateSelectedRangeBubble];
    
    // left, right opacity view
    CGFloat leftPoint;
    CGFloat rightPoint;
    
    if( mnMediaType == MEDIA_MUSIC )
    {
        float x = self.myMediaRangeSlider.mySASliderView.frame.origin.x;
        float size = self.myMediaRangeSlider.frame.size.width - (x + self.myMediaRangeSlider.mySASliderView.frame.size.width);
        
        if( x < 0) x = 0;
        [self.leftView setFrame:CGRectMake(0, 0.0f, x, self.leftView.bounds.size.height)];
        
        if( size < 0){
            size = self.myMediaRangeSlider.bounds.size.width;
            [self.rightView setFrame:CGRectMake(size, 0.0f, self.myMediaRangeSlider.bounds.size.width - size, self.rightView.bounds.size.height)];
        }
        else{
            [self.rightView setFrame:CGRectMake(self.myMediaRangeSlider.bounds.size.width - size, 0.0f, size, self.rightView.bounds.size.height)];
        }
        [self getShowTime:leftCenterRight];
    }
    else{
        leftPoint = leftPosition * self.myMediaRangeSlider.frame.size.width / CMTimeGetSeconds(self.mediaAsset.duration);
        rightPoint = rightPosition * self.myMediaRangeSlider.frame.size.width / CMTimeGetSeconds(self.mediaAsset.duration);
        [self.leftView setFrame:CGRectMake(0.0f, 0.0f, leftPoint, self.leftView.bounds.size.height)];
        [self.rightView setFrame:CGRectMake(rightPoint, 0.0f, self.myMediaRangeSlider.bounds.size.width - rightPoint, self.rightView.bounds.size.height)];
    }
    
    self.previousRealTime = timeInMiliseconds;
    self.previousStartTime = self.startTime;
}

#pragma mark Smooth Video And Music scrubbing


- (void)actuallySeekToTime:(int) LCR
{
    NSLog( @"Start Time  = %f", self.startTime);
    NSLog(@"Driection = %d", (int)self.bReverse);
    if ( LCR == LEFT ) {
        if (!self.bReverse)
            [[AudioQueuePlayer defaultPlayer] seekToTime:self.startTime withDirection:self.bReverse];
        else
            [[AudioQueuePlayer defaultPlayer] seekToTime:CMTimeGetSeconds(self.mediaAsset.duration) - self.startTime withDirection:self.bReverse];
    }
    else if( LCR == RIGHT ){
        if (!self.bReverse)
            [[AudioQueuePlayer defaultPlayer] seekToTime:self.stopTime withDirection:self.bReverse];
        else
            [[AudioQueuePlayer defaultPlayer] seekToTime:CMTimeGetSeconds(self.mediaAsset.duration) - self.stopTime withDirection:self.bReverse];
    }
    else if ( LCR == CENTER ){
        [self.mediaPlayerLayer.player seekToTime:CMTimeMakeWithSeconds(self.startTime, self.mediaAsset.duration.timescale) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
        [self.reverseAudioPlayerLayer.player seekToTime:CMTimeMakeWithSeconds(CMTimeGetSeconds(self.mediaAsset.duration) - self.startTime, self.mediaAsset.duration.timescale) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    }
}

- (void) stopVideoAndMusic:(int) LCR
{
    self.mediaPlayerLayer.player.rate = 1;
    [self.mediaPlayerLayer.player pause];
    [self.reverseAudioPlayerLayer.player pause];
    
    [[AudioQueuePlayer defaultPlayer] stopPlaying];
    
    self.previousRealTime = 0;
    self.isTempPlaying = NO;
    self.isPlaying = NO;
    [self.playBtn setImage:[UIImage imageNamed:@"NewPlay"] forState:UIControlStateNormal];
    
    [self getShowTime:LCR];
    
    if ( LCR == LEFT) {
        [self.mediaPlayerLayer.player seekToTime:CMTimeMakeWithSeconds(self.startTime, self.mediaAsset.duration.timescale) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
        if ( mnMediaType == MEDIA_MUSIC) {
            [self.reverseAudioPlayerLayer.player seekToTime:CMTimeMakeWithSeconds( CMTimeGetSeconds(self.mediaAsset.duration) - self.startTime, self.mediaAsset.duration.timescale) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
        }
    }
    else if ( LCR == RIGHT ){
        [self.mediaPlayerLayer.player seekToTime:CMTimeMakeWithSeconds(self.stopTime, self.mediaAsset.duration.timescale) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
        if ( mnMediaType == MEDIA_MUSIC) {
            [self.reverseAudioPlayerLayer.player seekToTime:CMTimeMakeWithSeconds( CMTimeGetSeconds(self.mediaAsset.duration) - self.stopTime, self.mediaAsset.duration.timescale) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
        }
    }
}

- (float) calcBasePos :(float) scale
{
    float len = self.waveform.frame.size.width;
    CGRect rect = [self.waveform getImageRect];
    float x0 = len/2 - (len/2 - rect.origin.x) * scale;
    float x1 = len/2 + (rect.origin.x + rect.size.width - len/2) * scale;
    
    if ( x0 > 0 ) {
        x0 = 0;
    }
    if ( x1 < self.waveform.frame.size.width ) {
        x1 = self.waveform.frame.size.width;
        x0 = x1 - rect.size.width * scale;
    }
    
    return x0;
}

- (void)handleZoom:(UIPinchGestureRecognizer *)gestureRecognizer
{
    if( ([gestureRecognizer state] == UIGestureRecognizerStateBegan) || ([gestureRecognizer state] == UIGestureRecognizerStateChanged) )
    {
        float scale = [gestureRecognizer scale];
        [self scaleWaveform:scale];
    }
}

- (void) scaleWaveform:(float)scale
{
    scale = [self.waveform checkScale:scale];
    float pos = [self calcBasePos:scale];
    
    [self.waveform redrawWaveform:scale position:pos];
    [self.myMediaRangeSlider redrawSlider:scale position:pos];
    
    CGRect rect = [self.waveform getImageRect];
    self.myMediaRangeSlider.mySASliderView.BaseSize = rect.size.width;
    self.myMediaRangeSlider.mySASliderView.BasePos = rect.origin.x;
    
    [self.myMediaRangeSlider.mySASliderView setNeedsLayout];
    
    [self getShowTime:LEFT];
}

- (void) moveWaveform:(float)delta
{
    CGRect rect = [self.waveform getImageRect];
    if ( rect.size.width == self.waveform.frame.size.width) {
        return;
    }
    
    float checkPos = [self.waveform checkMovePos:delta];
    [self.waveform moveWaveform:checkPos];
    [self.myMediaRangeSlider moveSlider:checkPos];
    
    float x = self.myMediaRangeSlider.mySASliderView.frame.origin.x;
    float size = self.myMediaRangeSlider.frame.size.width - (x + self.myMediaRangeSlider.mySASliderView.frame.size.width);
    
    if( x < 0) x = 0;
    [self.leftView setFrame:CGRectMake(0, 0.0f, x, self.leftView.bounds.size.height)];
    
    if( size < 0){
        size = self.myMediaRangeSlider.bounds.size.width;
        [self.rightView setFrame:CGRectMake(size, 0.0f, self.myMediaRangeSlider.bounds.size.width - size, self.rightView.bounds.size.height)];
    }
    else{
        [self.rightView setFrame:CGRectMake(self.myMediaRangeSlider.bounds.size.width - size, 0.0f, size, self.rightView.bounds.size.height)];
    }
    self.myMediaRangeSlider.mySASliderView.BasePos += checkPos;
    
    [self getShowTime:LEFT];
}

- (void) sendWaveMoveDelta:(float)delta
{
    float checkPos = [self.waveform checkMovePos:delta];
    [self.waveform moveWaveform:checkPos];
    [self.myMediaRangeSlider moveSlider:checkPos];
    
    float x = self.myMediaRangeSlider.mySASliderView.frame.origin.x;
    float size = self.myMediaRangeSlider.frame.size.width - (x + self.myMediaRangeSlider.mySASliderView.frame.size.width);
    
    if( x < 0) x = 0;
    [self.leftView setFrame:CGRectMake(0, 0.0f, x, self.leftView.bounds.size.height)];
    
    if( size < 0){
        size = self.myMediaRangeSlider.bounds.size.width;
        [self.rightView setFrame:CGRectMake(size, 0.0f, self.myMediaRangeSlider.bounds.size.width - size, self.rightView.bounds.size.height)];
    }
    else{
        [self.rightView setFrame:CGRectMake(self.myMediaRangeSlider.bounds.size.width - size, 0.0f, size, self.rightView.bounds.size.height)];
    }
    CGRect rect = [self.waveform getImageRect];
    self.myMediaRangeSlider.mySASliderView.BasePos = rect.origin.x;
}

- (void) getShowTime:(int) dir
{
    CGRect rect  = [self.waveform getImageRect];
    float leftPosition  = - rect.origin.x;
    float rightPosition = self.waveform.frame.size.width - rect.origin.x;
    
    CGFloat start = leftPosition * CMTimeGetSeconds(self.mediaAsset.duration) / rect.size.width;
    CGFloat end = rightPosition * CMTimeGetSeconds(self.mediaAsset.duration) / rect.size.width;
    
    NSString* timeStr = [self timeToStr:end];
    self.seekTotalTimeLabel.text = [NSString stringWithFormat:@"%@", timeStr];
    timeStr = [self timeToStr:start];
    self.seekCurrentTimeLabel.text = [NSString stringWithFormat:@"%@", timeStr];
    
    //  Slider
    self.seekSlider.minimumValue = leftPosition;
    self.seekSlider.maximumValue = rightPosition;
    
    float leftVal =  self.myMediaRangeSlider.mySASliderView.leftPos; // - rect.origin.x);
    float rightVal = self.myMediaRangeSlider.mySASliderView.rightPos;
    
    if ( leftVal < 0 )  leftVal = 0;
    if ( leftVal > rightPosition )  leftVal = rightPosition;
    
    if ( dir == LEFT ) {
        [self.seekSlider setValue:leftVal];
    }
    else if(dir == RIGHT){
        [self.seekSlider setValue:rightVal];
    }
    
    self.startTime = leftVal * CMTimeGetSeconds(self.mediaAsset.duration) / rect.size.width;
    self.stopTime = rightVal * CMTimeGetSeconds(self.mediaAsset.duration) / rect.size.width;
}


- (void)handleCenterPan:(UIPanGestureRecognizer *)gesture
{
    
    if (gesture.state == UIGestureRecognizerStateBegan || gesture.state == UIGestureRecognizerStateChanged)
    {
        if (gesture.state == UIGestureRecognizerStateBegan)
        {
            lastPtForMusic = 0;
        }
        CGPoint translation = [gesture translationInView:self.superview];
        {
            float delta = translation.x - lastPtForMusic;
            [self sendWaveMoveDelta:delta];
            lastPtForMusic = translation.x;
        }
        
    }
}


- (void) setClipViews
{
    float x = self.myMediaRangeSlider.mySASliderView.frame.origin.x;
    float size = self.myMediaRangeSlider.frame.size.width - (x + self.myMediaRangeSlider.mySASliderView.frame.size.width);
    
    if( x < 0) x = 0;
    [self.leftView setFrame:CGRectMake(0, 0.0f, x, self.leftView.bounds.size.height)];
    
    if( size < 0){
        size = self.myMediaRangeSlider.bounds.size.width;
        [self.rightView setFrame:CGRectMake(size, 0.0f, self.myMediaRangeSlider.bounds.size.width - size, self.rightView.bounds.size.height)];
    }
    else{
        [self.rightView setFrame:CGRectMake(self.myMediaRangeSlider.bounds.size.width - size, 0.0f, size, self.rightView.bounds.size.height)];
    }
}

/***************************************  Reverse Processing!!!  *****************************************************/

#pragma mark -
#pragma mark - create reverse music

- (void)readAudioFromURL:(NSURL*)inURL originalToURL:(NSURL *)orgURL reverseToURL:(NSURL*)rsvURL {
    
    //prepare the in and outfiles
    
    AVAudioFile* inFile =
    [[AVAudioFile alloc] initForReading:inURL error:nil];
    
    AVAudioFormat* format = inFile.processingFormat;
    AVAudioFrameCount frameCount =(UInt32)inFile.length;
    NSDictionary* outSettings = @{ AVNumberOfChannelsKey:@(format.channelCount)
                                  ,AVSampleRateKey:@(format.sampleRate)};

    NSError *error;
    AVAudioFile* outFileOrg = [[AVAudioFile alloc] initForWriting:orgURL settings:outSettings error:&error];
    AVAudioFile* outFileRvs = [[AVAudioFile alloc] initForWriting:rsvURL settings:outSettings error:&error];
    
    //prepare the forward and reverse buffers
    AVAudioPCMBuffer *forwaredBuffer =
    [[AVAudioPCMBuffer alloc] initWithPCMFormat:format
                                  frameCapacity:frameCount];
    AVAudioPCMBuffer *reverseBuffer =
    [[AVAudioPCMBuffer alloc] initWithPCMFormat:format
                                  frameCapacity:frameCount];
    
    //read file into forwardBuffer
    
    [inFile readIntoBuffer:forwaredBuffer error:&error];
    //set frameLength of reverseBuffer to forwardBuffer framelength
    AVAudioFrameCount frameLength = forwaredBuffer.frameLength;
    reverseBuffer.frameLength = frameLength;
    
    //iterate over channels
    
    //stride is 1 or 2 depending on interleave format
    NSInteger stride = forwaredBuffer.stride;
    
    for (AVAudioChannelCount channelIdx = 0;
         channelIdx < forwaredBuffer.format.channelCount;
         channelIdx++) {
        float* forwaredChannelData =
        forwaredBuffer.floatChannelData[channelIdx];
        float* reverseChannelData =
        reverseBuffer.floatChannelData[channelIdx];
        int32_t reverseIdx = 0;
        
        //iterate over samples, allocate to reverseBuffer in reverse order
        for (AVAudioFrameCount frameIdx = frameLength;
             frameIdx >0;
             frameIdx--) {
            float sample = forwaredChannelData[frameIdx*stride];
            reverseChannelData[reverseIdx*stride] = sample;
            reverseIdx++;
        }
    }
    
    //write reverseBuffer to outFile
    [outFileOrg writeFromBuffer:forwaredBuffer error:&error];
    [outFileRvs writeFromBuffer:reverseBuffer error:&error];
}


#pragma mark -
#pragma mark - create reverse video

- (void) reverseComposition:(AVMutableComposition*) composition
{
    percentageDone = 0.0f;

    NSError *error;
    
    AVAssetReader *assetReader = [[AVAssetReader alloc] initWithAsset:composition error:&error];
    AVAssetTrack *videoTrack = [[composition tracksWithMediaType:AVMediaTypeVideo] lastObject];
    NSDictionary *readerOutputSettings = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange], kCVPixelBufferPixelFormatTypeKey, nil];
    AVAssetReaderTrackOutput* readerVideoTrackOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:videoTrack outputSettings:readerOutputSettings];
    [assetReader addOutput:readerVideoTrackOutput];
    readerVideoTrackOutput.supportsRandomAccess = YES;
    [assetReader startReading];
    
    [self startRecording];
    
    CMSampleBufferRef sample;
    timesArray = [[NSMutableArray alloc] init];
    while((sample = [readerVideoTrackOutput copyNextSampleBuffer]))
    {
        CMTime presentationTime = CMSampleBufferGetPresentationTimeStamp(sample);
        NSValue *frameTimeValue = [NSValue valueWithCMTime:presentationTime];
        [timesArray addObject:frameTimeValue];
        CFRelease(sample);
    }
    
    [[SHKActivityIndicator currentIndicator] performSelectorOnMainThread:@selector(hide) withObject:nil waitUntilDone:NO];
    
    CMTime newPresentationTime = kCMTimeZero;
    CMTime lastSamplePresentationTime = kCMTimeZero;
    BOOL isFirstEmpty = NO;
    
    // write reversed video frames
    for (int i=0; i<timesArray.count; i++)
    {
        if (isExpertCancelled)
            return;
        
        percentageDone = ((Float32)i / (Float32)timesArray.count);

        NSValue *frameTimeValue = [timesArray objectAtIndex:(timesArray.count - 1 - i)];
        CMTime presentationTime = [frameTimeValue CMTimeValue];
        CMTime nextSamplePresentationTime = kCMTimeZero;
        
        if (i == 0)
        {
            nextSamplePresentationTime = composition.duration;
            lastSamplePresentationTime = presentationTime;
            
            if (nextSamplePresentationTime.value == presentationTime.value)
            {
                isFirstEmpty = YES;
                continue;
            }
        }
        else
        {
            NSValue *nextFrameTimeValue = [timesArray objectAtIndex:(timesArray.count - i)];
            nextSamplePresentationTime = [nextFrameTimeValue CMTimeValue];
            
            if ((i == 1)&&(isFirstEmpty == YES))
            {
                lastSamplePresentationTime = presentationTime;
            }
        }
        
        CMTime frameDuration = CMTimeSubtract(nextSamplePresentationTime, presentationTime);
        
        CMTimeRange range = CMTimeRangeMake(presentationTime, frameDuration);
        NSValue *resetframeTimeValue = [NSValue valueWithCMTimeRange:range];
        [readerVideoTrackOutput resetForReadingTimeRanges:[NSArray arrayWithObject:resetframeTimeValue]];
        
        newPresentationTime = CMTimeSubtract(lastSamplePresentationTime, presentationTime);
        
        CMSampleBufferRef sample;
        
        while((sample = [readerVideoTrackOutput copyNextSampleBuffer]))
        {
            CVPixelBufferRef imageBufferRef = CMSampleBufferGetImageBuffer(sample);
            
            if (self.assetWriterInput.readyForMoreMediaData)
            {
                if(![self.assetWriterPixelBufferAdaptor appendPixelBuffer:imageBufferRef withPresentationTime:newPresentationTime])
                    NSLog(@"asset write failed");
            }
            
            CFRelease(sample);
        }
    }
    
    [self stopRecording];
}


-(void) startRecording
{
    NSError *movieError = nil;
    
    self.assetWriter = [[AVAssetWriter alloc] initWithURL:self.tmpMediaUrl
                                                 fileType: AVFileTypeQuickTimeMovie
                                                    error: &movieError];
    NSDictionary *assetWriterInputSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                              AVVideoCodecH264, AVVideoCodecKey,
                                              [NSNumber numberWithInt:cropVideoSize.width], AVVideoWidthKey,
                                              [NSNumber numberWithInt:cropVideoSize.height], AVVideoHeightKey,
                                              nil];
    self.assetWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType: AVMediaTypeVideo outputSettings:assetWriterInputSettings];
    self.assetWriterInput.expectsMediaDataInRealTime = YES;
    [self.assetWriter addInput:self.assetWriterInput];
    self.assetWriterPixelBufferAdaptor = [AVAssetWriterInputPixelBufferAdaptor
                                          assetWriterInputPixelBufferAdaptorWithAssetWriterInput:self.assetWriterInput
                                          sourcePixelBufferAttributes:nil];
    [self.assetWriter startWriting];
    [_assetWriter startSessionAtSourceTime: CMTimeMake(0.0f, 600.0f)];
}

-(void) stopRecording
{
    if (isExpertCancelled)
        return;

    if (_assetWriter.status == AVAssetWriterStatusWriting)
    {
        [_assetWriter finishWritingWithCompletionHandler:^{
            _assetWriter = nil;
            [self performSelectorOnMainThread:@selector(completedTrimReverse) withObject:nil waitUntilDone:NO];
        }];
    }
}

- (void) completedTrimReverse
{
    [timesArray removeAllObjects];
    timesArray = nil;
    
    [_imageGenerator cancelAllCGImageGeneration];
    _imageGenerator = nil;
    
    if (isExpertCancelled)
        return;
        
    if ([self.delegate respondsToSelector:@selector(didCompletedTrim:type:)])
    {
        [self.delegate didCompletedTrim:self.tmpMediaUrl type:mnMediaType];
    }
    
    if ((mnSaveCopyFlag) && (mnMediaType == MEDIA_VIDEO))
    {
        [self.hudProgressView setCaption:@"Save video to gallery..."];
        [self saveMovieToPhotoAlbum];
    }
    else
    {
        [progressTimer invalidate];
        progressTimer = nil;
        [self.hudProgressView hide];
        
        [[SHKActivityIndicator currentIndicator] hide];
    }
    
    self.mediaPlayerLayer.player = nil;
    
    if (self.mediaPlayerLayer != nil)
    {
        [self.mediaPlayerLayer removeFromSuperlayer];
        self.mediaPlayerLayer = nil;
    }
}

#pragma mark - old code for reverse

- (void) createReverseVideoFromComposition:(AVMutableComposition*) composition
{
    timesArray = [[NSMutableArray alloc] init];
    
    percentageDone = 0.0f;
    fakeTimeElapsed = 0.0f;
    nCount = 0;

    Float64 clipTime = (Float64)1.0f/grFrameRate;
    Float64 assetDuration = CMTimeGetSeconds(composition.duration);
    
    self.imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:composition];
    self.imageGenerator.maximumSize = composition.naturalSize;
    
    while(clipTime < assetDuration)
    {
        CMTime frameTime = CMTimeMakeWithSeconds(assetDuration - clipTime, 600.0f);
        NSValue *frameTimeValue = [NSValue valueWithCMTime:frameTime];
        [timesArray addObject:frameTimeValue];
        clipTime += (Float64)1.0f/grFrameRate;
    };
    
    [self startRecording];

    [[SHKActivityIndicator currentIndicator] performSelectorOnMainThread:@selector(hide) withObject:nil waitUntilDone:NO];

    [self.imageGenerator generateCGImagesAsynchronouslyForTimes:timesArray
                                              completionHandler:^(CMTime requestedTime, CGImageRef image, CMTime actualTime,
                                                                  AVAssetImageGeneratorResult result, NSError *error) {
                                                  
      if (result == AVAssetImageGeneratorSucceeded)
      {
          percentageDone = ((Float32)nCount / (Float32)[timesArray count]);
          
          @autoreleasepool
          {
              if(mnVideoOrientation == PortraitVideo)//portrait
                  image = [self rotateFrameImage:image];
              else if(mnVideoOrientation == UpsideDownVideo)//upside down
                  image = [self rotateFrameImage:image];
              else if (mnVideoOrientation == LandscapeLeftVideo)//landscape left
                  image = [self rotateFrameImage:image];
              
              if (isCameraVideo)
              {
                  if (gnTemplateIndex == TEMPLATE_SQUARE)
                  {
                      UIImage* cropImage = [UIImage imageWithCGImage:image];
                      CGRect rect = CGRectMake((cropImage.size.width-cropVideoSize.width)/2.0f, (cropImage.size.height-cropVideoSize.height)/2.0f, cropVideoSize.width, cropVideoSize.height);
                      cropImage = [cropImage cropImageToRect:rect];
                      image = cropImage.CGImage;
                  }
                  else if (gnTemplateIndex == TEMPLATE_LANDSCAPE)
                  {
                      if((mnVideoOrientation == LandscapeLeftVideo)||(mnVideoOrientation == LandscapeRightVideo))//landscape left, right
                      {
                          UIImage* cropImage = [UIImage imageWithCGImage:image];
                          CGRect rect = CGRectMake((cropImage.size.width-cropVideoSize.width)/2.0f, (cropImage.size.height-cropVideoSize.height)/2.0f, cropVideoSize.width, cropVideoSize.height);
                          cropImage = [cropImage cropImageToRect:rect];
                          image = cropImage.CGImage;
                      }
                  }
                  else if (gnTemplateIndex == TEMPLATE_1080P)
                  {
                      if((mnVideoOrientation == LandscapeLeftVideo)||(mnVideoOrientation == LandscapeRightVideo))//landscape left, right
                      {
                          UIImage* cropImage = [UIImage imageWithCGImage:image];
                          CGRect rect = CGRectMake((cropImage.size.width-cropVideoSize.width)/2.0f, (cropImage.size.height-cropVideoSize.height)/2.0f, cropVideoSize.width, cropVideoSize.height);
                          cropImage = [cropImage cropImageToRect:rect];
                          image = cropImage.CGImage;
                      }
                  }
                  else if (gnTemplateIndex == TEMPLATE_PORTRAIT)
                  {
                      if((mnVideoOrientation == PortraitVideo)||(mnVideoOrientation == UpsideDownVideo))//portrait, upside down
                      {
                          UIImage* cropImage = [UIImage imageWithCGImage:image];
                          CGRect rect = CGRectMake((cropImage.size.width-cropVideoSize.width)/2.0f, (cropImage.size.height-cropVideoSize.height)/2.0f, cropVideoSize.width, cropVideoSize.height);
                          cropImage = [cropImage cropImageToRect:rect];
                          image = cropImage.CGImage;
                      }
                  }
              }
              
              [self writeSample:image];
          }
          
          nCount++;
          
          if (nCount == [timesArray count])
              [self stopRecording];
      }
    }];
}

-(CGImageRef) rotateFrameImage:(CGImageRef)image
{
    UIImage* rotateImage = [UIImage imageWithCGImage:image];
    
    if (mnVideoOrientation == LandscapeLeftVideo)//landscape left
    {
        CGRect rect = CGRectMake(0.0f, 0.0f, rotateImage.size.width, rotateImage.size.height);
        UIGraphicsBeginImageContext(rect.size);

        CGAffineTransform transform = CGAffineTransformIdentity;
        transform = CGAffineTransformMakeTranslation(rotateImage.size.width, rotateImage.size.height);
        transform = CGAffineTransformRotate(transform, M_PI);
        CGContextConcatCTM(UIGraphicsGetCurrentContext(), transform);
        
        [rotateImage drawInRect:rect];
        rotateImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    else if (mnVideoOrientation == PortraitVideo)//portrait
    {
        CGRect rect = CGRectMake(0.0f, 0.0f, rotateImage.size.height, rotateImage.size.width);
        UIGraphicsBeginImageContext(rect.size);
        
        CGAffineTransform transform = CGAffineTransformIdentity;
        transform = CGAffineTransformMakeTranslation(rotateImage.size.height, 0);
        transform = CGAffineTransformRotate(transform, M_PI/2);
        CGContextConcatCTM(UIGraphicsGetCurrentContext(), transform);
        
        rect = CGRectMake(0.0f, 0.0f, rotateImage.size.width, rotateImage.size.height);
        
        [rotateImage drawInRect:rect];
        rotateImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    else if (mnVideoOrientation == UpsideDownVideo)//upside down
    {
        CGRect rect = CGRectMake(0.0f, 0.0f, rotateImage.size.height, rotateImage.size.width);
        UIGraphicsBeginImageContext(rect.size);
        
        CGAffineTransform transform = CGAffineTransformIdentity;
        transform = CGAffineTransformMakeTranslation(0.0f, rotateImage.size.width);
        transform = CGAffineTransformRotate(transform, 3.0f * M_PI / 2.0f);
        CGContextConcatCTM(UIGraphicsGetCurrentContext(), transform);
        
        rect = CGRectMake(0.0f, 0.0f, rotateImage.size.width, rotateImage.size.height);
        
        [rotateImage drawInRect:rect];
        rotateImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    return rotateImage.CGImage;
}


- (CVPixelBufferRef) pixelBufferFromCGImage: (CGImageRef) image
{
    CGSize size = CGSizeZero;
    
    if((mnVideoOrientation == PortraitVideo)||(mnVideoOrientation == UpsideDownVideo))//portrait, upside down
        size = CGSizeMake(reverseVideoSize.height, reverseVideoSize.width);
    else if ((mnVideoOrientation == LandscapeLeftVideo)||(mnVideoOrientation == LandscapeRightVideo))//landscape left, right
        size = reverseVideoSize;
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey,
                             nil];
    CVPixelBufferRef pxbuffer = NULL;
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault,
                                          size.width,
                                          size.height,
                                          kCVPixelFormatType_32ARGB,
                                          (__bridge CFDictionaryRef) options,
                                          &pxbuffer);
    if (status != kCVReturnSuccess)
        NSLog(@"Failed to create pixel buffer");
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pxdata, size.width,
                                                 size.height, 8, CVPixelBufferGetBytesPerRow(pxbuffer), rgbColorSpace,
                                                 (CGBitmapInfo)kCGImageAlphaPremultipliedFirst);
    
    CGContextConcatCTM(context, CGAffineTransformMakeRotation(0));
    CGContextDrawImage(context, CGRectMake(0, 0, size.width, size.height), image);
    
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    
    return pxbuffer;
}

-(void) writeSample: (CGImageRef)imageRef
{
    if (self.assetWriterInput.readyForMoreMediaData)
    {
        CVPixelBufferRef pixelBuffer = [self pixelBufferFromCGImage:imageRef];
        
        CFTimeInterval elapsedTime = fakeTimeElapsed;
        CMTime presentationTime =  CMTimeMake(elapsedTime * 600.0f, 600.0f);
        
        [self.assetWriterPixelBufferAdaptor appendPixelBuffer:pixelBuffer withPresentationTime:presentationTime];
        
        CVPixelBufferRelease(pixelBuffer);
        
        fakeTimeElapsed += (Float64)1.0f/grFrameRate;
    }
}


#pragma mark-
#pragma mark-

- (void)progressSimpleUpdate:(NSTimer*)timer
{
    AVAssetExportSession* session = (AVAssetExportSession*)timer.userInfo;

    [self.hudProgressView setProgress:[session progress]];
    
    //process exception of bad frames video
    float currentPro = [session progress];
    if (currentPro == prevPro)
    {
        if (isSameProgress)
        {
            NSTimeInterval currentTimeInterval = [NSDate timeIntervalSinceReferenceDate];
            
            if ((currentTimeInterval - prevTimeInterval) > 5.0f)
            {
                if (mnMediaType == MEDIA_VIDEO)
                {
                    UIAlertView *errormsg=[[UIAlertView alloc] initWithTitle:@"Video Dreamer" message:@"This video may have damaged frames. You may change the Trim range and try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [errormsg show];
                }
                else if (mnMediaType == MEDIA_MUSIC)
                {
                    UIAlertView *errormsg=[[UIAlertView alloc] initWithTitle:@"Video Dreamer" message:@"This music may have damaged frames. You may change the Trim range and try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [errormsg show];
                }
                
                AVAssetExportSession* session = progressTimer.userInfo;
                [session cancelExport];
                
                [progressTimer invalidate];
                progressTimer = nil;
            }
        }
        else
        {
            isSameProgress = YES;
            prevTimeInterval = [NSDate timeIntervalSinceReferenceDate];
        }
    }
    else
    {
        prevPro = currentPro;
        isSameProgress = NO;
    }
}

- (void)progressLandscapeVideoReverseUpdate:(NSTimer*)timer
{
    [self.hudProgressView setProgress:percentageDone];
}

- (void)progressAudioReverseUpdate:(NSTimer*)timer
{
    [self.hudProgressView setProgress:percentageDone];
}


@end
