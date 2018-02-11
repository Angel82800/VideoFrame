//
//  VideoEditor.h
//  VideoFrame
//
//  Created by Yinjing Li on 11/20/13.
//  Copyright (c) 2013 Yinjing Li. All rights reserved.
//
//  Description
//  This NSObject is a sub class for generation a video from a photo and video on userinterface.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AssetsLibrary/AssetsLibrary.h>

#import "AppDelegate.h"
#import "Definition.h"
#import "GPUImage.h"
#import "GPUImageMovie.h"
#import "SHKActivityIndicator.h"
#import "ALAssetsLibrary+CustomPhotoAlbum.h"
#import "MediaObjectView.h"
#import "FoldAction.h"
#import "SwapAction.h"
#import "FlipAction.h"
#import "RotateAction.h"
#import "SwingAction.h"
#import "SpinAction.h"
#import "GenieAction.h"
#import "RevealAction.h"
#import "SuckAction.h"
#import "ExplodeAction.h"
#import "THImageMovie.h"
#import "THImageMovieWriter.h"


@protocol VideoEditorDelegate <NSObject>

- (void)didCompletedPreview;
- (void)didFailedPreview;
- (void)didCompleteOutput:(int)index;
- (void)didFailedOutput;
- (void)didCompleteProgressbar;
- (void)startAllNormalProgress:(AVAssetExportSession*) session current:(int) currentCount total:(int) totalCount;
- (void)startAllChromakeyProgress:(int) currentCount total:(int) totalCount;
- (void)updateChromakeyVideoExporting:(CGFloat) progress;
- (void)saveToAlbumProgress;

@end


@interface VideoEditor : NSObject {
    
    BOOL isPreview; // yes-preview, no-create
    BOOL isFailed; // yes-failed, no-success
    
    CGSize videoSize;
    
    CGFloat outputScaleFactor;
    
    int mnProcessingCount;
    int mnProcessingIndex;
    
    NSTimer* timer;
}

@property(nonatomic, weak) id <VideoEditorDelegate> delegate;

@property(nonatomic, assign) int currentProcessingIdx;

@property(nonatomic, strong) NSString *pathToMovie;

@property(nonatomic, strong) NSMutableArray* objectArray;
@property(nonatomic, strong) NSMutableArray* musicObjectArray;
@property(nonatomic, strong) NSMutableArray* layerInstructionArray;

@property(nonatomic, strong) AVAsset* asset1;
@property(nonatomic, strong) AVAsset* asset2;
@property(nonatomic, strong) AVAssetExportSession *exporter;
@property(nonatomic, strong) AVMutableComposition* mixComposition;
@property(nonatomic, strong) AVAssetWriter *videoWriter;

@property(nonatomic, strong) GPUImageOutput<GPUImageInput> *filter;
@property(nonatomic, retain) THImageMovie *thMovieFX;
@property(nonatomic, retain) THImageMovie *thMovieA;
@property(nonatomic, retain) THImageMovieWriter *thMovieWriter;


-(void) setPreviewFlag:(BOOL) flag;
-(void) setVideoSize:(CGSize) size;
-(void) setInputObjectArray:(NSMutableArray*) array;
-(void) createNormalVideo;
-(void) createChromaKeyFilterOutput;
-(void) didFinishedOutputVideoWrite;
-(void) didFailedOutputVideoWrite;
-(void) didFinishedPreviewVideoWrite;
-(void) didFailedPreviewVideoWrite;

- (void) removeAllObjects;

@end


