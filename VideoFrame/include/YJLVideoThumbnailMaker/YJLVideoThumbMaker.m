//
//  YJLVideoThumbMaker.m
//  VideoFrame
//
//  Created by YinjingLi on 12/22/14.
//  Copyright (c) 2014 Yinjing Li. All rights reserved.
//

#import "YJLVideoThumbMaker.h"


@implementation YJLVideoThumbMaker

@synthesize delegate = _delegate;
@synthesize myTitleLabel = _myTitleLabel;
@synthesize videoPlayerView = _videoPlayerView;
@synthesize useThisFrameBtn = _useThisFrameBtn;
@synthesize cancelBtn = _cancelBtn;


-(void) initFrame:(CGRect) frame
{
    self.frame = frame;
    
    self.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.layer.borderWidth = 1.0f;
    
    self.useThisFrameBtn.layer.cornerRadius = 5.0f;
    self.cancelBtn.layer.cornerRadius = 5.0f;
    self.myTitleLabel.layer.cornerRadius = 5.0f;
    self.myTitleLabel.clipsToBounds = YES;
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) freePlayer
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [videoPlayer pause];
    [videoPlayer.view removeFromSuperview];
    videoPlayer = nil;
}

-(void) initVideo:(PHAsset*) asset
{
    [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:nil resultHandler:^(AVAsset *avAsset, AVAudioMix *audioMix, NSDictionary *info) {
       
        if ([avAsset isKindOfClass:[AVURLAsset class]]) //normal video
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSURL* url = [(AVURLAsset*)avAsset URL];
                
                if (videoPlayer != nil)
                {
                    [[NSNotificationCenter defaultCenter] removeObserver:self];
                    
                    [videoPlayer pause];
                    [videoPlayer.view removeFromSuperview];
                    videoPlayer = nil;
                }
                
                videoPlayer = [[MPMoviePlayerController alloc] initWithContentURL:url];
                videoPlayer.view.frame = self.videoPlayerView.bounds;
                [self.videoPlayerView addSubview:videoPlayer.view];
                videoPlayer.repeatMode = MPMovieRepeatModeNone;
                [videoPlayer prepareToPlay];
                
                [[NSNotificationCenter defaultCenter] addObserver:self
                                                         selector:@selector(myMovieFinishedCallback:)
                                                             name:MPMoviePlayerPlaybackDidFinishNotification
                                                           object:videoPlayer];
                
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayerPlaybackStateDidChange:) name:MPMoviePlayerPlaybackStateDidChangeNotification object:videoPlayer];
            });
        }
        else  //Slow-Mo video
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [[PHImageManager defaultManager] requestImageDataForAsset:asset options:nil resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
                    
                    NSURL* url = [info objectForKey:@"PHImageFileURLKey"];
                    
                    if (url)
                    {
                        if (videoPlayer != nil)
                        {
                            [[NSNotificationCenter defaultCenter] removeObserver:self];
                            
                            [videoPlayer pause];
                            [videoPlayer.view removeFromSuperview];
                            videoPlayer = nil;
                        }
                        
                        videoPlayer = [[MPMoviePlayerController alloc] initWithContentURL:url];
                        videoPlayer.view.frame = self.videoPlayerView.bounds;
                        [self.videoPlayerView addSubview:videoPlayer.view];
                        videoPlayer.repeatMode = MPMovieRepeatModeNone;
                        [videoPlayer prepareToPlay];
                        
                        [[NSNotificationCenter defaultCenter] addObserver:self
                                                                 selector:@selector(myMovieFinishedCallback:)
                                                                     name:MPMoviePlayerPlaybackDidFinishNotification
                                                                   object:videoPlayer];
                        
                        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayerPlaybackStateDidChange:) name:MPMoviePlayerPlaybackStateDidChangeNotification object:videoPlayer];
                    }
                }];
            });
        }
    }];
}

-(void) initMovie:(NSURL*) url
{
    if (videoPlayer != nil)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        
        [videoPlayer pause];
        [videoPlayer.view removeFromSuperview];
        videoPlayer = nil;
    }
    
    videoPlayer = [[MPMoviePlayerController alloc] initWithContentURL:url];
    videoPlayer.view.frame = self.videoPlayerView.bounds;
    [self.videoPlayerView addSubview:videoPlayer.view];
    videoPlayer.repeatMode = MPMovieRepeatModeNone;
    [videoPlayer prepareToPlay];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(myMovieFinishedCallback:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:videoPlayer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayerPlaybackStateDidChange:) name:MPMoviePlayerPlaybackStateDidChangeNotification object:videoPlayer];
}


#pragma mark -
#pragma mark - MPMoviePlayerController Delegate

- (void) moviePlayerPlaybackStateDidChange: (NSNotification *) notification
{
    if (videoPlayer.playbackState == MPMoviePlaybackStateStopped)
    {
        [videoPlayer setContentURL:[videoPlayer contentURL]];
        [videoPlayer play];
    }
}

-(void)myMovieFinishedCallback:(NSNotification*)aNotification
{
    videoPlayer.currentPlaybackTime = 0.0f;
}


#pragma mark - 
#pragma mark - Actions

-(IBAction)actionUseThisFrame:(id)sender
{
    float time = videoPlayer.currentPlaybackTime;

    [self freePlayer];
    
    if ([self.delegate respondsToSelector:@selector(didSelectedFrame:)])
    {
        [self.delegate didSelectedFrame:time];
    }
}

-(IBAction)actionCancel:(id)sender
{
    [self freePlayer];
    
    if ([self.delegate respondsToSelector:@selector(didCancelVideoThumbMaker)])
    {
        [self.delegate didCancelVideoThumbMaker];
    }
}


@end
