//
//  SpeedSegmentView.m
//  VideoFrame
//
//  Created by Yinjing Li on 4/3/14.
//  Copyright (c) 2014 Yinjing Li. All rights reserved.
//

#import "SpeedSegmentView.h"

#define CIRCLE_PICKER_VISIT_TIME 0.2f

@implementation SpeedSegmentView

- (id)initWithFrame:(CGRect)frame type:(int)mediaType url:(NSURL*) meidaUrl
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        self.backgroundColor = [UIColor blackColor];

        isPlaying = NO;

        self.originalMediaUrl = meidaUrl;
        
        self.mediaAsset = nil;
        self.mediaAsset = [AVURLAsset assetWithURL:self.originalMediaUrl];

        self.motionValueOfSelectedSegment = 1.0f;
        self.startTime = 0.0f;
        self.stopTime = CMTimeGetSeconds(self.mediaAsset.duration);
       
        NSString* timeStr = [self timeToStr:(self.stopTime - self.startTime)/self.motionValueOfSelectedSegment];

        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        {
            if (mediaType == MEDIA_MUSIC)
            {
                self.seekSlider = [[UISlider alloc] initWithFrame:CGRectMake(60.0f, self.frame.size.height - 95.0f, self.frame.size.width - 120.0f, 30.0f)];
                self.seekCurrentTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, self.frame.size.height - 95.0f, 50.0f, 30.0f)];
                self.seekTotalTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width-50.0f, self.frame.size.height - 95.0f, 50.0f, 30.0f)];
            }
            else
            {
                self.seekSlider = [[UISlider alloc] initWithFrame:CGRectMake(60.0f, self.frame.size.height - 65.0f, self.frame.size.width - 120.0f, 30.0f)];
                self.seekCurrentTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, self.frame.size.height - 65.f, 50.0f, 30.0f)];
                self.seekTotalTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width-50.0f, self.frame.size.height - 65.f, 50.0f, 30.0f)];
            }
            
            [self.seekCurrentTimeLabel setFont:[UIFont fontWithName:MYRIADPRO size:11]];
            [self.seekTotalTimeLabel setFont:[UIFont fontWithName:MYRIADPRO size:11]];
        }
        else
        {
            if (mediaType == MEDIA_MUSIC)
            {
                self.seekSlider = [[UISlider alloc] initWithFrame:CGRectMake(80.0f, self.frame.size.height - 130.f, self.frame.size.width - 160.0f, 30.0f)];
                self.seekCurrentTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, self.frame.size.height - 130.f, 50.0f, 30.0f)];
                self.seekTotalTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width-50.0f, self.frame.size.height - 130.f, 50.0f, 30.0f)];
            }
            else
            {
                self.seekSlider = [[UISlider alloc] initWithFrame:CGRectMake(80.0f, self.frame.size.height - 100.0f, self.frame.size.width - 160.0f, 30.0f)];
                self.seekCurrentTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, self.frame.size.height - 100.0f, 50.0f, 30.0f)];
                self.seekTotalTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width-50.0f, self.frame.size.height - 100.0f, 50.0f, 30.0f)];
            }
            
            [self.seekCurrentTimeLabel setFont:[UIFont fontWithName:MYRIADPRO size:14]];
            [self.seekTotalTimeLabel setFont:[UIFont fontWithName:MYRIADPRO size:14]];
        }
        
        UIImage *minImage = [UIImage imageNamed:@"slider_min"];
        UIImage *maxImage = [UIImage imageNamed:@"slider_max"];
        UIImage *tumbImage = nil;
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
            tumbImage = [UIImage imageNamed:@"slider_thumb"];
        else
            tumbImage = [UIImage imageNamed:@"slider_thumb_ipad"];
        
        minImage = [minImage stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0];
        maxImage = [maxImage stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0];
        
        [self.seekSlider setMinimumTrackImage:minImage forState:UIControlStateNormal];
        [self.seekSlider setMaximumTrackImage:maxImage forState:UIControlStateNormal];
        [self.seekSlider setThumbImage:tumbImage forState:UIControlStateNormal];
        [self.seekSlider setThumbImage:tumbImage forState:UIControlStateHighlighted];
        [self.seekSlider setBackgroundColor:[UIColor clearColor]];
        [self.seekSlider setValue:0.0f];
        [self.seekSlider addTarget:self action:@selector(playerSeekPositionChanged) forControlEvents:UIControlEventValueChanged];
        [self.seekSlider setMinimumValue:self.startTime];
        [self.seekSlider setMaximumValue:self.stopTime];
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
        self.seekTotalTimeLabel.text = [NSString stringWithFormat:@"%@", timeStr];
        [self addSubview:self.seekTotalTimeLabel];
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            if (mediaType == MEDIA_MUSIC)
                self.myMediaRangeSlider = [[SAVideoRangeSlider alloc] initWithFrame:CGRectMake(10, self.frame.size.height - 90.0f, self.frame.size.width-70, 80) videoUrl:self.originalMediaUrl value:self.motionValueOfSelectedSegment type: mediaType];
            else
                self.myMediaRangeSlider = [[SAVideoRangeSlider alloc] initWithFrame:CGRectMake(10, self.frame.size.height - 60.0f, self.frame.size.width-70, 50) videoUrl:self.originalMediaUrl value:self.motionValueOfSelectedSegment type:mediaType];
        }
        else
        {
            if (mediaType == MEDIA_MUSIC)
                self.myMediaRangeSlider = [[SAVideoRangeSlider alloc] initWithFrame:CGRectMake(5, self.frame.size.height - 65.0f, self.frame.size.width-40, 60) videoUrl:self.originalMediaUrl value:self.motionValueOfSelectedSegment type:mediaType];
            else
                self.myMediaRangeSlider = [[SAVideoRangeSlider alloc] initWithFrame:CGRectMake(5, self.frame.size.height - 35.0f, self.frame.size.width-40, 30) videoUrl:self.originalMediaUrl value:self.motionValueOfSelectedSegment type:mediaType];
        }
        
        self.myMediaRangeSlider.delegate = self;
        [self addSubview:self.myMediaRangeSlider];
        [self.myMediaRangeSlider setLeftRight:self.startTime end:self.stopTime];

        if (mediaType == MEDIA_MUSIC)
        {
            self.waveform = [[FDWaveformView alloc] initWithFrame:CGRectMake(self.myMediaRangeSlider.frame.origin.x, self.myMediaRangeSlider.frame.origin.y, self.myMediaRangeSlider.frame.size.width, self.myMediaRangeSlider.frame.size.height)];
            self.waveform.delegate = self;
            self.waveform.alpha = 0.0f;
            self.waveform.audioURL = self.originalMediaUrl;
            self.waveform.progressSamples = 10000;
            self.waveform.doesAllowScrubbing = YES;
            [self addSubview:self.waveform];
            self.waveform.userInteractionEnabled = NO;
            [self.waveform createWaveform];
        }
        

        //play button
        CGFloat x = self.frame.size.width - (self.myMediaRangeSlider.frame.origin.x*2 + self.myMediaRangeSlider.frame.size.width);
        
        self.playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
            [self.playBtn setFrame:CGRectMake(self.frame.size.width - x, self.myMediaRangeSlider.frame.origin.y, 30.0f, 30.0f)];
        else
            [self.playBtn setFrame:CGRectMake(self.frame.size.width - x, self.myMediaRangeSlider.frame.origin.y, 50.0f, 50.0f)];
        
        self.playBtn.center = CGPointMake(self.playBtn.center.x, self.myMediaRangeSlider.center.y);
        [self.playBtn setBackgroundColor:[UIColor clearColor]];
        [self.playBtn setImage:[UIImage imageNamed:@"NewPlay"] forState:UIControlStateNormal];
        [self.playBtn addTarget:self action:@selector(playbackMotionMovie:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.playBtn];
        
        
        // apply button
        self.applyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.applyBtn setFrame:CGRectMake(10.0f, 5.0f, 50.0f, 30.0f)];
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
            [self.applyBtn.titleLabel setFont:[UIFont fontWithName:MYRIADPRO size:15]];
        else
            [self.applyBtn.titleLabel setFont:[UIFont fontWithName:MYRIADPRO size:20]];
        [self.applyBtn setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
        [self.applyBtn.titleLabel setLineBreakMode:NSLineBreakByWordWrapping];
        [self.applyBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        [self.applyBtn setBackgroundColor:UIColorFromRGB(0x53585f)];
        [self setSelectedBackgroundViewFor:self.applyBtn];
        [self.applyBtn.layer setMasksToBounds:YES];
        [self.applyBtn.layer setBorderColor:[UIColor whiteColor].CGColor];
        [self.applyBtn.layer setBorderWidth:1.0f];
        [self.applyBtn.layer setCornerRadius:3.0f];
        [self.applyBtn setTitle:@" Apply " forState:UIControlStateNormal];
        [self.applyBtn addTarget:self action:@selector(actionApplyButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.applyBtn];
        
        CGFloat labelWidth = [self.applyBtn.titleLabel.text sizeWithAttributes:@{NSFontAttributeName: self.applyBtn.titleLabel.font}].width;
        CGFloat labelHeight = [self.applyBtn.titleLabel.text sizeWithAttributes:@{NSFontAttributeName: self.applyBtn.titleLabel.font}].height;

        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
            [self.applyBtn setFrame:CGRectMake(5.0f, 5.0f, labelWidth + 10.0f, labelHeight + 15.0f)];
        else
            [self.applyBtn setFrame:CGRectMake(20.0f, 20.0f, labelWidth + 20.0f, labelHeight + 20.0f)];

        
        // media player
        self.mediaPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:[AVPlayer playerWithPlayerItem:[AVPlayerItem playerItemWithAsset:self.mediaAsset]]];

        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
            [_mediaPlayerLayer setFrame:CGRectMake(5.0f, self.applyBtn.frame.origin.y + self.applyBtn.frame.size.height + 5.0f, self.frame.size.width - 10.0f, self.myMediaRangeSlider.frame.origin.y - (self.applyBtn.frame.origin.y + self.applyBtn.frame.size.height) - 10.0f)];
        else
            [_mediaPlayerLayer setFrame:CGRectMake(10, self.applyBtn.frame.origin.y + self.applyBtn.frame.size.height + 10, self.frame.size.width - 20, self.myMediaRangeSlider.frame.origin.y - (self.applyBtn.frame.origin.y + self.applyBtn.frame.size.height) - 20)];

        [self.layer insertSublayer:_mediaPlayerLayer atIndex:0];
        
        [_mediaPlayerLayer.player setVolume:1.0f];
        [_mediaPlayerLayer.player seekToTime:CMTimeMakeWithSeconds(self.startTime, self.mediaAsset.duration.timescale)];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(mediaPlayDidFinish:)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:nil];

        CGFloat duration = self.mediaAsset.duration.value / 500;
        
        __weak typeof(self) weakSelf = self;
        
        [self.mediaPlayerLayer.player addPeriodicTimeObserverForInterval:CMTimeMake(MAX(1, duration), self.mediaAsset.duration.timescale) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
            
            __strong SpeedSegmentView *sself = weakSelf;
            
            if (!sself)
                return;
            
            if ([weakSelf.mediaPlayerLayer.player rate] != 0.0f)
            {
                CGFloat currentTime = CMTimeGetSeconds(time);

                if (currentTime > weakSelf.stopTime)
                {
                    currentTime = weakSelf.stopTime;
                    [sself performSelector:@selector(mediaDidFinish)];
                }
                
                weakSelf.seekSlider.value = currentTime;
            }
        }];
        
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        {
            if (self.frame.size.width > self.frame.size.height) //landscape
                self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 5.0f, self.frame.size.width, 30.0f)];
            else
                self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.applyBtn.frame.origin.x + self.applyBtn.frame.size.width), self.applyBtn.center.y - 15.0f, self.frame.size.width - (self.applyBtn.frame.origin.x + self.applyBtn.frame.size.width), 30.0f)];
            
            self.titleLabel.font = [UIFont fontWithName:MYRIADPRO size:21];
        }
        else
        {
            self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, self.applyBtn.center.y - 15.0f, self.frame.size.width, 30.0f)];
            self.titleLabel.font = [UIFont fontWithName:MYRIADPRO size:27];
        }
        
        [self.titleLabel setBackgroundColor:[UIColor clearColor]];
        [self.titleLabel setTextColor:[UIColor whiteColor]];
        [self.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [self.titleLabel setAdjustsFontSizeToFitWidth:YES];
        [self.titleLabel setMinimumScaleFactor:0.1f];
        [self.titleLabel setNumberOfLines:1];
        [self.titleLabel setShadowColor:[UIColor blackColor]];
        [self.titleLabel setShadowOffset:CGSizeMake(1.0f, 1.0f)];
        [self.titleLabel.layer setShadowOpacity:0.8f];
        [self addSubview:self.titleLabel];

        if (mediaType == MEDIA_VIDEO)
            self.titleLabel.text = @"Video Speed Segment";
        else if (mediaType == MEDIA_MUSIC)
            self.titleLabel.text = @"Music Speed Segment";
        
        labelWidth = [self.titleLabel.text sizeWithAttributes:@{NSFontAttributeName: self.titleLabel.font}].width;

        
        CGFloat segmentBtnWidth;
        CGFloat defaultHeight;
        CGFloat mfCircleProgressBarWidth;

        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        {
            mfCircleProgressBarWidth = 130.0f;
            defaultHeight = 25.0f;
            segmentBtnWidth = 20.0f;
        }
        else
        {
            mfCircleProgressBarWidth = 200.0f;
            defaultHeight = 50.0f;
            segmentBtnWidth = 30.0f;
        }


        self.addSegmentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.addSegmentBtn setFrame:CGRectMake(0.0f, self.titleLabel.frame.origin.y, segmentBtnWidth, segmentBtnWidth)];
        [self.addSegmentBtn.titleLabel setFont:self.titleLabel.font];
        [self.addSegmentBtn.titleLabel setTextColor:[UIColor whiteColor]];
        [self.addSegmentBtn setTitle:@"+" forState:UIControlStateNormal];
        [self.addSegmentBtn setTitle:@"+" forState:UIControlStateSelected];
        self.addSegmentBtn.layer.cornerRadius = segmentBtnWidth/2.0f;
        self.addSegmentBtn.layer.borderColor = [UIColor whiteColor].CGColor;
        self.addSegmentBtn.layer.borderWidth = 1.0f;
        [self.addSegmentBtn addTarget:self action:@selector(actionAddNewSegment:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.addSegmentBtn];
        self.addSegmentBtn.center = CGPointMake((self.bounds.size.width + self.titleLabel.center.x + labelWidth/2.0f)/2.0f, self.titleLabel.center.y);
        
        
        self.deleteSegmentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.deleteSegmentBtn setFrame:CGRectMake(0.0f, self.titleLabel.frame.origin.y, segmentBtnWidth, segmentBtnWidth)];
        [self.deleteSegmentBtn.titleLabel setFont:self.titleLabel.font];
        [self.deleteSegmentBtn.titleLabel setTextColor:[UIColor whiteColor]];
        [self.deleteSegmentBtn setTitle:@"-" forState:UIControlStateNormal];
        [self.deleteSegmentBtn setTitle:@"-" forState:UIControlStateSelected];
        self.deleteSegmentBtn.layer.cornerRadius = segmentBtnWidth/2.0f;
        self.deleteSegmentBtn.layer.borderColor = [UIColor whiteColor].CGColor;
        self.deleteSegmentBtn.layer.borderWidth = 1.0f;
        [self.deleteSegmentBtn addTarget:self action:@selector(deleteSegment:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.deleteSegmentBtn];
        self.deleteSegmentBtn.center = CGPointMake((self.applyBtn.frame.origin.x + self.applyBtn.frame.size.width + self.titleLabel.center.x - labelWidth/2.0f)/2.0f, self.titleLabel.center.y);
        self.deleteSegmentBtn.hidden = YES;


        self.myCircleProgressBar = [[CircleProgressBar alloc] initWithFrame:CGRectMake((self.bounds.size.width - mfCircleProgressBarWidth)/2.0f, (self.bounds.size.height - mfCircleProgressBarWidth)/2.0f, mfCircleProgressBarWidth, mfCircleProgressBarWidth)];
        self.myCircleProgressBar.delegate = self;
        [self.myCircleProgressBar setProgressBarWidth:(self.myCircleProgressBar.bounds.size.width*0.1f)];
        [self.myCircleProgressBar setHintViewSpacingForDrawing:(self.myCircleProgressBar.bounds.size.width*0.0833f)];
        [self addSubview:self.myCircleProgressBar];
        [self.myCircleProgressBar setProgress:self.motionValueOfSelectedSegment timeStr:timeStr];
        
        
        self.myMarkerView = [[MarkerView alloc] initWithFrame:CGRectMake(self.myMediaRangeSlider.frame.origin.x + 1.0f, self.seekSlider.frame.origin.y - defaultHeight, self.myMediaRangeSlider.frame.size.width - 2.0f, defaultHeight)];
        [self addSubview:self.myMarkerView];
        
        
        UIPanGestureRecognizer* panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panRecognized:)];
        [self addGestureRecognizer:panRecognizer];
        
        [self bringSubviewToFront:self.myMediaRangeSlider];
    }
    
    return self;
}

-(void) removeSegmentUI
{
    [self.myCircleProgressBar removeFromSuperview];
    [self.myMarkerView removeFromSuperview];
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) setSelectedBackgroundViewFor:(UIButton *) button
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(button.bounds.size.width, button.bounds.size.height), NO, 0.0);
    [UIColorFromRGB(0x9da1a0) set];
    CGContextFillRect(UIGraphicsGetCurrentContext(), CGRectMake(0.5f, 0.5f, button.bounds.size.width - 0.5f, button.bounds.size.height - 0.5f));
    UIImage* resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [button setBackgroundImage:resultImage forState:UIControlStateHighlighted];
    [button setBackgroundImage:resultImage forState:UIControlStateSelected|UIControlStateHighlighted];
}

- (NSString *)timeToStr:(CGFloat)time
{
    // time - seconds
    NSInteger min = floor(time / 60);
    NSInteger sec = floor(time - min * 60);
    NSInteger millisecond = roundf((time - (min*60 + sec))*1000);
    
    if (millisecond == 1000)
    {
        millisecond = 0;
        sec++;
    }

    NSString *minStr = [NSString stringWithFormat:min >= 10 ? @"%i" : @"0%d", (int)min];
    NSString *secStr = [NSString stringWithFormat:sec >= 10 ? @"%i" : @"0%d", (int)sec];
    
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
#pragma mark - Playback

- (void) playbackMotionMovie:(id) sender
{
    if (isPlaying)
    {
        isPlaying = NO;
        
        [self.mediaPlayerLayer.player pause];
        
        [self.playBtn setImage:[UIImage imageNamed:@"NewPlay"] forState:UIControlStateNormal];
        
        [playbackTimer invalidate];
        playbackTimer = nil;
        
        [UIView animateWithDuration:CIRCLE_PICKER_VISIT_TIME animations:^{
            
            self.myCircleProgressBar.alpha = 1.0f;
            
        }];
    }
    else
    {
        isPlaying = YES;
        
        CGFloat currentTime = CMTimeGetSeconds(self.mediaPlayerLayer.player.currentTime);
        
        if ((currentTime - 0.1f) <= self.startTime)
        {
            [self.mediaPlayerLayer.player seekToTime:CMTimeMake(self.startTime*self.mediaAsset.duration.timescale, self.mediaAsset.duration.timescale) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
        }
        else if ((currentTime + 0.1f) >= self.stopTime)
        {
            [self.mediaPlayerLayer.player seekToTime:CMTimeMake(self.startTime*self.mediaAsset.duration.timescale, self.mediaAsset.duration.timescale) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
        }
        
        mnPlaybackCount = -1;
        
        if (playbackTimer)
        {
            [playbackTimer invalidate];
            playbackTimer = nil;
        }
        
        playbackTimer = [NSTimer scheduledTimerWithTimeInterval:.02f target:self selector:@selector(playbackTimeUpdate:) userInfo:nil repeats:YES];
        
        [self.mediaPlayerLayer.player play];
        self.mediaPlayerLayer.player.rate = self.motionValueOfSelectedSegment;
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
            [self.playBtn setImage:[UIImage imageNamed:@"NewPause_iPhone"] forState:UIControlStateNormal];
        else
            [self.playBtn setImage:[UIImage imageNamed:@"NewPause_iPad"] forState:UIControlStateNormal];
        
        [UIView animateWithDuration:CIRCLE_PICKER_VISIT_TIME animations:^{
            
            self.myCircleProgressBar.alpha = 0.0f;

        }];
    }
}

- (void)playbackTimeUpdate:(NSTimer*)timer
{
    CGFloat currentTime = CMTimeGetSeconds(self.mediaPlayerLayer.player.currentTime);
    
    for (int i=0; i<self.myMediaRangeSlider.videoRangeSliderArray.count; i++)
    {
        SASliderView* sliderView = [self.myMediaRangeSlider.videoRangeSliderArray objectAtIndex:i];
        
        CGFloat startTime = (sliderView.leftPos * CMTimeGetSeconds(self.mediaAsset.duration) / self.myMediaRangeSlider.frame.size.width);
        CGFloat stopTime = (sliderView.rightPos * CMTimeGetSeconds(self.mediaAsset.duration) / self.myMediaRangeSlider.frame.size.width);
        
        if ((currentTime > startTime)&&(currentTime < stopTime))
        {
            if (i != mnPlaybackCount)
            {
                mnPlaybackCount = i;
                self.mediaPlayerLayer.player.rate = sliderView.motionValue;
            }
            
            break;
        }
    }
}

- (void) mediaPlayDidFinish:(NSNotification*)notification
{
    [playbackTimer invalidate];
    playbackTimer = nil;

    [self.mediaPlayerLayer.player pause];
    [self.mediaPlayerLayer.player seekToTime:CMTimeMake(self.startTime*self.mediaAsset.duration.timescale, self.mediaAsset.duration.timescale) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    
    [self.seekSlider setValue:self.startTime];

    isPlaying = NO;
    
    [self.playBtn setImage:[UIImage imageNamed:@"NewPlay"] forState:UIControlStateNormal];
    
    [UIView animateWithDuration:CIRCLE_PICKER_VISIT_TIME animations:^{
        
        self.myCircleProgressBar.alpha = 1.0f;

    }];
}

- (void) mediaDidFinish
{
    [playbackTimer invalidate];
    playbackTimer = nil;

    [self.mediaPlayerLayer.player pause];
    [self.mediaPlayerLayer.player seekToTime:CMTimeMake(self.startTime*self.mediaAsset.duration.timescale, self.mediaAsset.duration.timescale) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    
    [self.seekSlider setValue:self.startTime];

    isPlaying = NO;
    
    [self.playBtn setImage:[UIImage imageNamed:@"NewPlay"] forState:UIControlStateNormal];
    
    [UIView animateWithDuration:CIRCLE_PICKER_VISIT_TIME animations:^{
        
        self.myCircleProgressBar.alpha = 1.0f;

    }];
}

-(void) playerSeekPositionChanged
{
    if (isPlaying)
    {
        [self.mediaPlayerLayer.player pause];
        
        isPlaying = NO;
        
        [self.playBtn setImage:[UIImage imageNamed:@"NewPlay"] forState:UIControlStateNormal];
        
        [UIView animateWithDuration:CIRCLE_PICKER_VISIT_TIME animations:^{
            
            self.myCircleProgressBar.alpha = 1.0f;

        }];
    }
    
    float time = self.seekSlider.value;
    [self.mediaPlayerLayer.player seekToTime:CMTimeMakeWithSeconds(time, self.mediaAsset.duration.timescale) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}


#pragma mark -
#pragma mark - action Apply button

- (void)actionApplyButton:(id)sender
{
    NSArray *menuItems =
    @[
      [YJLActionMenuItem menuItem:@"Apply Speed"
                            image:nil
                           target:self
                           action:@selector(applySpeedSegment:)],
      
      [YJLActionMenuItem menuItem:@"Cancel"
                            image:nil
                           target:self
                           action:@selector(cancelSpeedSegment:)],
      ];
    
    CGRect frame = [self.applyBtn convertRect:self.applyBtn.bounds toView:self];
    [YJLActionMenu showMenuInView:self
                         fromRect:frame
                        menuItems:menuItems isWhiteBG:NO];
}


#pragma mark - 
#pragma mark - Apply / Cancel Motion

-(void) applySpeedSegment:(id) sender
{
    [playbackTimer invalidate];
    playbackTimer = nil;
    
    [self.mediaPlayerLayer.player pause];
    self.mediaPlayerLayer.player = nil;
    
    if (self.mediaPlayerLayer != nil)
    {
        [self.mediaPlayerLayer removeFromSuperlayer];
        self.mediaPlayerLayer = nil;
    }
    
    [UIView animateWithDuration:CIRCLE_PICKER_VISIT_TIME animations:^{
        
        self.myCircleProgressBar.alpha = 1.0f;

    }];

    if (self.startTimeArray)
    {
        [self.startTimeArray removeAllObjects];
        [self.stopTimeArray removeAllObjects];
        [self.motionValueArray removeAllObjects];
        
        self.startTimeArray = nil;
        self.stopTimeArray = nil;
        self.motionValueArray = nil;
    }
    
    self.startTimeArray = [[NSMutableArray alloc] init];
    self.stopTimeArray = [[NSMutableArray alloc] init];
    self.motionValueArray = [[NSMutableArray alloc] init];
    
    for (int i=0; i<self.myMediaRangeSlider.videoRangeSliderArray.count; i++)
    {
        SASliderView* sliderView = [self.myMediaRangeSlider.videoRangeSliderArray objectAtIndex:i];

        CGFloat startPos = (sliderView.leftPos * CMTimeGetSeconds(self.mediaAsset.duration) / self.myMediaRangeSlider.frame.size.width);
        CGFloat stopPos = (sliderView.rightPos * CMTimeGetSeconds(self.mediaAsset.duration) / self.myMediaRangeSlider.frame.size.width);
        CGFloat motion = sliderView.motionValue;
        
        if (i == 0)
        {
            if ((int)startPos != 0)
            {
                NSNumber* startTimeValue = [NSNumber numberWithFloat:0.0f];
                [self.startTimeArray addObject:startTimeValue];
                
                NSNumber* stopTimeValue = [NSNumber numberWithFloat:startPos];
                [self.stopTimeArray addObject:stopTimeValue];
                
                NSNumber* motionValue = [NSNumber numberWithFloat:1.0f];
                [self.motionValueArray addObject:motionValue];
            }
            
            NSNumber* startTimeValue = [NSNumber numberWithFloat:startPos];
            [self.startTimeArray addObject:startTimeValue];
            
            NSNumber* stopTimeValue = [NSNumber numberWithFloat:stopPos];
            [self.stopTimeArray addObject:stopTimeValue];
            
            NSNumber* motionValue = [NSNumber numberWithFloat:motion];
            [self.motionValueArray addObject:motionValue];
        }
        else if (i == (self.myMediaRangeSlider.videoRangeSliderArray.count-1))
        {
            SASliderView* prevSliderView = [self.myMediaRangeSlider.videoRangeSliderArray objectAtIndex:i-1];
            
            CGFloat prevStopPos = (prevSliderView.rightPos * CMTimeGetSeconds(self.mediaAsset.duration) / self.myMediaRangeSlider.frame.size.width);
            
            if ((int)prevStopPos != (int)startPos)
            {
                NSNumber* startTimeValue = [NSNumber numberWithFloat:prevStopPos];
                [self.startTimeArray addObject:startTimeValue];
                
                NSNumber* stopTimeValue = [NSNumber numberWithFloat:startPos];
                [self.stopTimeArray addObject:stopTimeValue];
                
                NSNumber* motionValue = [NSNumber numberWithFloat:1.0f];
                [self.motionValueArray addObject:motionValue];
            }

            NSNumber* startTimeValue = [NSNumber numberWithFloat:startPos];
            [self.startTimeArray addObject:startTimeValue];
            
            NSNumber* stopTimeValue = [NSNumber numberWithFloat:stopPos];
            [self.stopTimeArray addObject:stopTimeValue];
            
            NSNumber* motionValue = [NSNumber numberWithFloat:motion];
            [self.motionValueArray addObject:motionValue];

            if (((int)stopPos != (int)CMTimeGetSeconds(self.mediaAsset.duration)))
            {
                NSNumber* startTimeValue = [NSNumber numberWithFloat:stopPos];
                [self.startTimeArray addObject:startTimeValue];
                
                NSNumber* stopTimeValue = [NSNumber numberWithFloat:CMTimeGetSeconds(self.mediaAsset.duration)];
                [self.stopTimeArray addObject:stopTimeValue];
                
                NSNumber* motionValue = [NSNumber numberWithFloat:1.0f];
                [self.motionValueArray addObject:motionValue];
            }
        }
        else
        {
            SASliderView* prevSliderView = [self.myMediaRangeSlider.videoRangeSliderArray objectAtIndex:i-1];
            
            CGFloat prevStopPos = (prevSliderView.rightPos * CMTimeGetSeconds(self.mediaAsset.duration) / self.myMediaRangeSlider.frame.size.width);
            
            if ((int)prevStopPos != (int)startPos)
            {
                NSNumber* startTimeValue = [NSNumber numberWithFloat:prevStopPos];
                [self.startTimeArray addObject:startTimeValue];
                
                NSNumber* stopTimeValue = [NSNumber numberWithFloat:startPos];
                [self.stopTimeArray addObject:stopTimeValue];
                
                NSNumber* motionValue = [NSNumber numberWithFloat:1.0f];
                [self.motionValueArray addObject:motionValue];
            }

            NSNumber* startTimeValue = [NSNumber numberWithFloat:startPos];
            [self.startTimeArray addObject:startTimeValue];
            
            NSNumber* stopTimeValue = [NSNumber numberWithFloat:stopPos];
            [self.stopTimeArray addObject:stopTimeValue];
            
            NSNumber* motionValue = [NSNumber numberWithFloat:motion];
            [self.motionValueArray addObject:motionValue];
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(didSelectedMotion:starts:ends:)])
    {
        [self.delegate didSelectedMotion:self.motionValueArray starts:self.startTimeArray ends:self.stopTimeArray];
    }
}

-(void) cancelSpeedSegment:(id) sender
{
    [playbackTimer invalidate];
    playbackTimer = nil;
    
    [self.mediaPlayerLayer.player pause];
    self.mediaPlayerLayer.player = nil;
    
    if (self.mediaPlayerLayer != nil)
    {
        [self.mediaPlayerLayer removeFromSuperlayer];
        self.mediaPlayerLayer = nil;
    }
    
    [UIView animateWithDuration:CIRCLE_PICKER_VISIT_TIME animations:^{
        
        self.myCircleProgressBar.alpha = 1.0f;

    }];
    
    if ([self.delegate respondsToSelector:@selector(didCancelSpeed)])
    {
        [self.delegate didCancelSpeed];
    }
}


#pragma mark -
#pragma mark - SAVideoRangeSliderDelegate

- (void)videoRange:(SAVideoRangeSlider *)videoRange didChangeLeftPosition:(CGFloat)leftPosition rightPosition:(CGFloat)rightPosition LCR:(int)leftCenterRight value:(CGFloat)motionValue
{
    [playbackTimer invalidate];
    playbackTimer = nil;

    self.motionValueOfSelectedSegment = motionValue;

    if (isPlaying)
    {
        [self.mediaPlayerLayer.player pause];
        
        isPlaying = NO;
        
        [self.playBtn setImage:[UIImage imageNamed:@"NewPlay"] forState:UIControlStateNormal];
        
        [UIView animateWithDuration:CIRCLE_PICKER_VISIT_TIME animations:^{
            
            self.myCircleProgressBar.alpha = 1.0f;

        }];
    }
    
    self.startTime = leftPosition;
    self.stopTime = rightPosition;

    NSString* timeStr = [self timeToStr:(self.stopTime - self.startTime)/self.motionValueOfSelectedSegment];
    self.seekTotalTimeLabel.text = [NSString stringWithFormat:@"%@", timeStr];

    [self.seekSlider setMinimumValue:self.startTime];
    [self.seekSlider setMaximumValue:self.stopTime];

    if (leftCenterRight == 1)//LEFT
    {
        [self.seekSlider setValue:self.startTime];
        [self.mediaPlayerLayer.player seekToTime:CMTimeMakeWithSeconds(self.startTime, self.mediaAsset.duration.timescale) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    }
    else if (leftCenterRight == 2)//CENTER
    {
        [self.seekSlider setValue:self.startTime];
        [self.mediaPlayerLayer.player seekToTime:CMTimeMakeWithSeconds(self.startTime, self.mediaAsset.duration.timescale) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    }
    else if (leftCenterRight == 3)//RIGHT
    {
        [self.seekSlider setValue:self.stopTime];
        [self.mediaPlayerLayer.player seekToTime:CMTimeMakeWithSeconds(self.stopTime, self.mediaAsset.duration.timescale) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    }

    [self.myMediaRangeSlider updateSelectedRangeBubble];
    
    
    SASliderView* mySASliderView = [self.myMediaRangeSlider.videoRangeSliderArray objectAtIndex:self.myMediaRangeSlider.nSelectedSliderIndex];

    CGFloat fStartPos = mySASliderView.leftPos;
    CGFloat fEndPos = mySASliderView.rightPos;
    
    self.myMarkerView.frame = CGRectMake(self.myMediaRangeSlider.frame.origin.x + fStartPos + 1.0f, self.myMarkerView.frame.origin.y, (fEndPos-fStartPos) - 2.0f, self.myMarkerView.frame.size.height);
    [self.myMarkerView setNeedsDisplay];

    [self.myCircleProgressBar setProgress:self.motionValueOfSelectedSegment timeStr:timeStr];
}

-(void) fetchSASliderViews
{
    if (self.myMediaRangeSlider.videoRangeSliderArray.count == 1)
    {
        self.deleteSegmentBtn.hidden = YES;
    }
}


#pragma mark -
#pragma mark FDWaveformViewDelegate

- (void)waveformViewDidRender:(FDWaveformView *)waveformView
{
    [UIView animateWithDuration:0.02f animations:^{
        waveformView.alpha = 1.0f;
    }];
}


#pragma mark -
#pragma mark - Add new Segment

-(void) actionAddNewSegment:(id) sender
{
    BOOL isAddedNewSegment = NO;
    
    isAddedNewSegment = [self.myMediaRangeSlider addNewVideoRangeSlider];
    
    [self bringSubviewToFront:self.myMediaRangeSlider];
    
    if (isAddedNewSegment)
    {
        self.deleteSegmentBtn.hidden = NO;
    }
    else if (self.myMediaRangeSlider.videoRangeSliderArray.count > 1)
    {
        self.deleteSegmentBtn.hidden = NO;
    }
}


-(void) deleteSegment:(id) sender
{
    UIAlertView *msg=[[UIAlertView alloc] initWithTitle:@"Video Dreamer" message:@"Delete this segment?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    [msg performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)//delete this segment
    {
        if (self.myMediaRangeSlider.videoRangeSliderArray.count > 1)
        {
            [self.myMediaRangeSlider deleteVideoRangeSlider:self.myMediaRangeSlider.nSelectedSliderIndex];
        }
        
        if (self.myMediaRangeSlider.videoRangeSliderArray.count == 1)
        {
            self.deleteSegmentBtn.hidden = YES;
        }
    }
}


#pragma mark -
#pragma mark - pan gesture

-(void)panRecognized:(UIPanGestureRecognizer*)sender
{
    if (self.myCircleProgressBar)
    {
        [self.myCircleProgressBar panGestureRecognized:sender];
    }
}


#pragma mark -
#pragma mark - CircleProgressBarDelegate

- (void) didSelectedCircleProgressBar:(NSInteger) index
{
    [self.myMediaRangeSlider didSelectedSASliderView:index];
}

- (void) didChangedProgress:(CGFloat) progress
{
    self.motionValueOfSelectedSegment = progress;

    NSString* timeStr = [self timeToStr:(self.stopTime - self.startTime)/self.motionValueOfSelectedSegment];
    self.seekTotalTimeLabel.text = [NSString stringWithFormat:@"%@", timeStr];

    [self.myMediaRangeSlider setChangedMotionValue:self.motionValueOfSelectedSegment];

    if (isPlaying)
    {
        [playbackTimer invalidate];
        playbackTimer = nil;

        isPlaying = NO;
        
        [self.mediaPlayerLayer.player pause];
        
        [self.playBtn setImage:[UIImage imageNamed:@"NewPlay"] forState:UIControlStateNormal];
        
        [UIView animateWithDuration:CIRCLE_PICKER_VISIT_TIME animations:^{
            
            self.myCircleProgressBar.alpha = 1.0f;
            
        }];
    }

    [self.myCircleProgressBar setProgress:self.motionValueOfSelectedSegment timeStr:timeStr];
}


@end
