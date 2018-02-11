#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "GPUImageContext.h"
#import "GPUImageOutput.h"
#import "THImageMovieWriter.h"


@protocol THImageMovieDelegate <NSObject>

- (void)didCompletePlayingMovie;
@end


@interface THImageMovie : GPUImageOutput

@property (readwrite, retain) AVAsset *asset;
@property (readwrite, retain) AVPlayerItem *playerItem;
@property (readwrite, retain) NSURL *url;

@property (readwrite, nonatomic) BOOL runBenchmark;
@property (readwrite, nonatomic) BOOL playAtActualSpeed;
@property (readwrite, nonatomic) BOOL shouldRepeat;

@property (readonly, nonatomic) float progress;

@property (readwrite, nonatomic, assign) id <THImageMovieDelegate>delegate;

@property (readonly, nonatomic) AVAssetReader *assetReader;
@property (readonly, nonatomic) BOOL audioEncodingIsFinished;
@property (readonly, nonatomic) BOOL videoEncodingIsFinished;


- (id)initWithAsset:(AVAsset *)asset;
- (id)initWithPlayerItem:(AVPlayerItem *)playerItem;
- (id)initWithURL:(NSURL *)url;

- (void)yuvConversionSetup;
- (void)enableSynchronizedEncodingUsingMovieWriter:(GPUImageMovieWriter *)movieWriter;
- (void)startProcessing;
- (void)endProcessing;
- (void)cancelProcessing;
- (void)processMovieFrame:(CMSampleBufferRef)movieSampleBuffer;

- (BOOL)readNextVideoFrameFromOutput:(AVAssetReaderOutput *)readerVideoTrackOutput;
- (BOOL)readNextAudioSampleFromOutput:(AVAssetReaderOutput *)readerAudioTrackOutput;
- (BOOL)renderNextFrame;

@end
