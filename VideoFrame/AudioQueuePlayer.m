//
//  AudioQueuePlayer.m
//  VideoFrame
//
//  Created by Admin on 11/04/2017.
//  Copyright © 2017 Yinjing Li. All rights reserved.
//

#import "AudioQueuePlayer.h"
#import <AudioToolbox/AudioToolbox.h>

#define AUDIO_BUFFERS 3
#define AUDIO_DURATION 0.1

@interface AudioQueuePlayer ()

@property (assign, nonatomic) AudioQueuePlayerState currentState;
@property (assign, nonatomic) AudioQueuePlayDirection currentDirection;

@property (assign, nonatomic) UInt64 totalPacket;
@property (assign, nonatomic) UInt64 currentPacket;
@property (assign, nonatomic) UInt32 numPacketsToRead;

@property (assign, nonatomic) AudioFileID audioFileOrg;
@property (assign, nonatomic) AudioFileID audioFileRvs;
@property (assign, nonatomic) AudioQueueRef audioQueue;
@property (assign, nonatomic) AudioStreamBasicDescription dataFormat;
@property (assign, nonatomic) AudioQueueBufferRef *audioBuffers;

@end

@implementation AudioQueuePlayer

static AudioQueuePlayer *sharedAudioPlayer = nil;

+ (AudioQueuePlayer *)defaultPlayer {
    if (sharedAudioPlayer != nil)
        return sharedAudioPlayer;
    
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        sharedAudioPlayer = [[AudioQueuePlayer alloc] init];
    });
    
    return sharedAudioPlayer;
}

- (id)init {
    if (!(self = [super init])) return nil;
    
    self.totalPacket = 0;
    self.currentPacket = 0;
    self.numPacketsToRead = 0;
    
    self.currentState = AudioQueuePlayerStateNone;
    self.audioBuffers = malloc(AUDIO_BUFFERS * sizeof(AudioQueueBufferRef));
    
    return self;
}

- (void)dealloc {
    [self uninit];
}

- (void)uninit {
    if (self.currentState != AudioQueuePlayerStateNone) {
        AudioQueueDispose(_audioQueue, true);
    }
    
    [self closeFiles];
}

void AudioQueueCallback(void * __nullable inUserData, AudioQueueRef inAQ, AudioQueueBufferRef inBuffer) {
    AudioQueuePlayer *player = (__bridge AudioQueuePlayer *)inUserData;

    if (player != nil && player.currentState == AudioQueuePlayerStatePlaying) {
        [player fillBuffer:inAQ queueBuffer:inBuffer];
    }
}

void isRunningProc(void * __nullable inUserData, AudioQueueRef inAQ, AudioQueuePropertyID inID) {
    AudioQueuePlayer *player = (__bridge AudioQueuePlayer *)inUserData;
    
    BOOL isRunning = NO;
    UInt32 size = sizeof(isRunning);
    OSStatus error = AudioQueueGetProperty(inAQ, kAudioQueueProperty_IsRunning, &isRunning, &size);
    
    if (!error && player.currentState != AudioQueuePlayerStatePlaying)
        [[NSNotificationCenter defaultCenter] postNotificationName: @"playbackQueueStopped" object: nil];
}

- (void)initWithFileCouple:(NSURL *)originalFileURL withFile:(NSURL *)reverseFileURL {
    if (originalFileURL == nil || reverseFileURL == nil) {
        return;
    }
    
    if (self.currentState != AudioQueuePlayerStateNone) {
        [self uninit];
    }
    
    OSStatus error;
    error = AudioFileOpenURL((__bridge CFURLRef)originalFileURL, kAudioFileReadPermission, 0, &_audioFileOrg);
    error = AudioFileOpenURL((__bridge CFURLRef)reverseFileURL, kAudioFileReadPermission, 0, &_audioFileRvs);
    
    UInt32 size;
    error = AudioFileGetPropertyInfo(_audioFileOrg, kAudioFilePropertyFormatList, &size, NULL);
    UInt32 numFormats = size / sizeof(AudioFormatListItem);
    AudioFormatListItem *formatList = malloc(numFormats * sizeof(AudioFormatListItem));
    error = AudioFileGetProperty(_audioFileOrg, kAudioFilePropertyFormatList, &size, formatList);
    numFormats = size / sizeof(AudioFormatListItem);
    if (numFormats != 1) {
        [self closeFiles];
        return;
    }
    
    self.dataFormat = formatList[0].mASBD;
    free(formatList);
    
    size = sizeof(_totalPacket);
    error = AudioFileGetProperty(_audioFileOrg, kAudioFilePropertyAudioDataPacketCount, &size, &_totalPacket);
    
    error = AudioQueueNewOutput(&_dataFormat, AudioQueueCallback, (__bridge void *)(self), CFRunLoopGetCurrent(), kCFRunLoopCommonModes, 0, &_audioQueue);
    
    UInt32 maxPacketSize;
    size = sizeof(maxPacketSize);
    error = AudioFileGetProperty(_audioFileOrg, kAudioFilePropertyPacketSizeUpperBound, &size, &maxPacketSize);
    
    static const int maxBufferSize = 0x10000;
    static const int minBufferSize = 0x4000;
    
    UInt32 bufferByteSize;
    if (_dataFormat.mFramesPerPacket) {
        Float64 numPacketsForTime = _dataFormat.mSampleRate / _dataFormat.mFramesPerPacket * AUDIO_DURATION;
        bufferByteSize = numPacketsForTime * maxPacketSize;
    } else {
        // if frames per packet is zero, then the codec has no predictable packet == time
        // so we can't tailor this (we don't know how many Packets represent a time period
        // we'll just return a default buffer size
        bufferByteSize = maxBufferSize > maxPacketSize ? maxBufferSize : maxPacketSize;
    }
    
    // we're going to limit our size to our default
    if (bufferByteSize > maxBufferSize && bufferByteSize > maxPacketSize)
        bufferByteSize = maxBufferSize;
    else {
        // also make sure we're not too small - we don't want to go the disk for too small chunks
        if (bufferByteSize < minBufferSize)
            bufferByteSize = minBufferSize;
    }
    
    _numPacketsToRead = bufferByteSize / maxPacketSize;

    error = AudioFileGetPropertyInfo(_audioFileOrg, kAudioFilePropertyMagicCookieData, &size, NULL);
    if (!error && size > 0) {
        char *cookie = malloc(size);
        error = AudioFileGetProperty(_audioFileOrg, kAudioFilePropertyMagicCookieData, &size, cookie);
        error = AudioQueueSetProperty(_audioQueue, kAudioQueueProperty_MagicCookie, cookie, size);
        free(cookie);
    }
    
    error = AudioFileGetPropertyInfo(_audioFileOrg, kAudioFilePropertyChannelLayout, &size, NULL);
    if (!error && size > 0) {
        AudioChannelLayout *acl = (AudioChannelLayout *)malloc(size);
        error = AudioFileGetProperty(_audioFileOrg, kAudioFilePropertyChannelLayout, &size, acl);
        error = AudioQueueSetProperty(_audioQueue, kAudioQueueProperty_ChannelLayout, acl, size);
        free(acl);
    }
    
    error = AudioQueueAddPropertyListener(_audioQueue, kAudioQueueProperty_IsRunning, isRunningProc, (__bridge void *)(self));
    
    bool isFormatVBR = (self.dataFormat.mBytesPerPacket == 0 || self.dataFormat.mFramesPerPacket == 0);
    for (int i = 0; i < AUDIO_BUFFERS; ++i) {
        error = AudioQueueAllocateBufferWithPacketDescriptions(_audioQueue, bufferByteSize, (isFormatVBR ? _numPacketsToRead : 0), &_audioBuffers[i]);
    }
    
    error = AudioQueueSetParameter(_audioQueue, kAudioQueueParam_Volume, 1.0);
    
    self.currentState = AudioQueuePlayerStateLoaded;
    self.currentDirection = AudioQueuePlayDirectionForward;
}

- (void)startPlaying {
    for (int i = 0; i < AUDIO_BUFFERS; ++i) {
        [self fillBuffer:_audioQueue queueBuffer:_audioBuffers[i]];
    }
    
    if (self.currentState != AudioQueuePlayerStatePlaying) {
        AudioQueueStart(_audioQueue, NULL);
    }
    
    self.currentState = AudioQueuePlayerStatePlaying;
}

- (void)fillBuffer:(AudioQueueRef)queue queueBuffer:(AudioQueueBufferRef)buffer {
    if (self.currentPacket >= self.totalPacket) {
        self.currentState = AudioQueuePlayerStateLoaded;
        AudioQueueStop(queue, true);
        return;
    }
    
    UInt32 numBytes = buffer->mAudioDataBytesCapacity;
    UInt32 nPackets = self.numPacketsToRead;
    OSStatus error;
    if (self.currentDirection == AudioQueuePlayDirectionForward) {
        error = AudioFileReadPacketData(self.audioFileOrg, false, &numBytes, buffer->mPacketDescriptions, self.currentPacket, &nPackets, buffer->mAudioData);
    } else {
        error = AudioFileReadPacketData(self.audioFileRvs, false, &numBytes, buffer->mPacketDescriptions, self.currentPacket, &nPackets, buffer->mAudioData);
    }
    
    if (nPackets > 0) {
        buffer->mAudioDataByteSize = numBytes;
        buffer->mPacketDescriptionCount = nPackets;
        error = AudioQueueEnqueueBuffer(queue, buffer, 0, NULL);
        self.currentPacket += nPackets;
    } else {
        self.currentState = AudioQueuePlayerStateLoaded;
        AudioQueueStop(queue, true);
    }
}

- (void)closeFiles {
    AudioFileClose(self.audioFileOrg);
    AudioFileClose(self.audioFileRvs);
}


- (void)seekToTime:(float)seekTime withDirection:(BOOL)isForward {
    if (self.currentState == AudioQueuePlayerStateNone) {
        return;
    }
    
    if (!isForward) {
        self.currentDirection = AudioQueuePlayDirectionForward;
    } else {
        self.currentDirection = AudioQueuePlayDirectionReverse;
    }
    
//    if (self.currentState == AudioQueuePlayerStatePlaying) {
//        AudioQueueReset(_audioQueue);
//    }
    
    _currentPacket = _dataFormat.mSampleRate / _dataFormat.mFramesPerPacket * seekTime;
    if (_currentPacket > _totalPacket) {
        _currentPacket = _totalPacket;
    }
    
//    if (self.currentState == AudioQueuePlayerStateLoaded)
        [self startPlaying];
}

- (void)stopPlaying {
    if (self.currentState != AudioQueuePlayerStatePlaying) {
        return;
    }
    
    OSStatus result = AudioQueueStop(_audioQueue, true);
    if (!result) {
        self.currentState = AudioQueuePlayerStateLoaded;
    }
}

@end
