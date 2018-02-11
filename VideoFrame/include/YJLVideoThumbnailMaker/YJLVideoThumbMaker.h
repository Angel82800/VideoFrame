//
//  YJLVideoThumbMaker.h
//  VideoFrame
//
//  Created by YinjingLi on 12/22/14.
//  Copyright (c) 2014 Yinjing Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

@import Photos;


/**************************************************/
@protocol YJLVideoThumbMakerDelegate <NSObject>

@optional
-(void) didSelectedFrame:(CGFloat) time;
-(void) didCancelVideoThumbMaker;
@end
/**************************************************/


@interface YJLVideoThumbMaker : UIView
{
    MPMoviePlayerController *videoPlayer;
}

@property(nonatomic, assign) id <YJLVideoThumbMakerDelegate> delegate;

@property(nonatomic, strong) IBOutlet UILabel* myTitleLabel;
@property(nonatomic, strong) IBOutlet UIView* videoPlayerView;
@property(nonatomic, strong) IBOutlet UIButton* useThisFrameBtn;
@property(nonatomic, strong) IBOutlet UIButton* cancelBtn;

-(void) initFrame:(CGRect) frame;
-(void) initVideo:(PHAsset*) asset;
-(void) initMovie:(NSURL*) url;
-(void) freePlayer;

@end
