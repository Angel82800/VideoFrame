//
//  AudioQueuePlayer.h
//  VideoFrame
//
//  Created by Admin on 11/04/2017.
//  Copyright © 2017 Yinjing Li. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, AudioQueuePlayerState) {
    AudioQueuePlayerStateNone,
    AudioQueuePlayerStateLoaded,
    AudioQueuePlayerStatePlaying,
};

typedef NS_ENUM(NSInteger, AudioQueuePlayDirection) {
    AudioQueuePlayDirectionForward,
    AudioQueuePlayDirectionReverse,
};

@protocol AudioQueuePlayerDelegate <NSObject>

- (void)stateChanged:(AudioQueuePlayerState)newState;

@end

@interface AudioQueuePlayer : NSObject

+ (AudioQueuePlayer*)defaultPlayer;

- (void)initWithFileCouple:(NSURL *)originalFileURL withFile:(NSURL *)reverseFileURL;

- (void)seekToTime:(float)seekTime withDirection:(BOOL)isForward;

- (void)stopPlaying;

@end
