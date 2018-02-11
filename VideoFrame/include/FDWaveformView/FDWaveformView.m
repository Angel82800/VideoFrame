//
//  FDWaveformView
//  VideoFrame
//
//  Created by Yinjing Li on 3/6/14.
//  Copyright (c) 2014 Yinjing Li. All rights reserved.
//


// FROM http://stackoverflow.com/questions/5032775/drawing-waveform-with-avassetreader
// AND http://stackoverflow.com/questions/8298610/waveform-on-ios
// DO SEE http://stackoverflow.com/questions/1191868/uiimageview-scaling-interpolation
// see http://stackoverflow.com/questions/3514066/how-to-tint-a-transparent-png-image-in-iphone

#import "FDWaveformView.h"
#import <UIKit/UIKit.h>

#define absX(x) (x<0?0-x:x)
#define minMaxX(x,mn,mx) (x<=mn?mn:(x>=mx?mx:x))
#define noiseFloor (-50.0)
#define decibel(amplitude) (20.0 * log10(absX(amplitude)/32767.0))
#define imgExt @"png"
#define imageToData(x) UIImagePNGRepresentation(x)
#define targetOverDraw 180 // Will make image that is more pixels than screen can show
#define minimumOverDraw 2

#define ShowPercent   1

@interface FDWaveformView()
@property (nonatomic, strong) UIImageView *image;
@property (nonatomic, strong) UIView *clipping;
@property (nonatomic, strong) AVURLAsset *asset;
@property (nonatomic, assign) unsigned long int totalSamples;
@property (nonatomic, assign) unsigned long int cachedStartSamples;
@property (nonatomic, assign) unsigned long int cachedEndSamples;

@end

@implementation FDWaveformView


- (void)initialize
{
    self.image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    self.image.contentMode = UIViewContentModeScaleToFill;
    [self addSubview:self.image];
    
    self.clipping = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    self.clipping.clipsToBounds = YES;
    [self addSubview:self.clipping];
    
    self.wavesColor = [UIColor yellowColor];
    self.progressColor = [UIColor grayColor];
    
    gContext = nil; renderFirst = true;
    
    self.clipsToBounds = true;
    
   

}



- (void)changeWaveFrame
{
    self.image.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    self.clipping.frame = CGRectMake(0,0,self.frame.size.width, self.frame.size.height);
}

- (id)initWithCoder:(NSCoder *)aCoder
{
    if (self = [super initWithCoder:aCoder])
        [self initialize];
    return self;
}

- (id)initWithFrame:(CGRect)rect
{
    if (self = [super initWithFrame:rect])
        [self initialize];
    return self;
}

- (void)setAudioURL:(NSURL *)audioURL
{
    _audioURL = audioURL;
    self.asset = [AVURLAsset URLAssetWithURL:audioURL options:nil];
    self.image.image = nil;
    self.totalSamples = (unsigned long int) self.asset.duration.value;
    _progressSamples = 0; // skip custom setter
    _startSamples = 0; // skip custom setter
    _endSamples = (unsigned long int) self.asset.duration.value; // skip custom setter
    [self setNeedsDisplay];
}

- (void)setProgressSamples:(unsigned long)progressSamples
{
    _progressSamples = progressSamples;
    float progress = (float)self.progressSamples / self.totalSamples;
    self.clipping.frame = CGRectMake(0,0,self.frame.size.width*progress,self.frame.size.height);
    [self setNeedsLayout];
}

- (void)changeStartEndSamples:(unsigned long int) startSample end:(unsigned long int) endSample
{
    _startSamples = startSample;
    _endSamples = endSample;
    [self setNeedsLayout];
}

-(void) createWaveform
{
  
    if ([self.delegate respondsToSelector:@selector(waveformViewWillRender:)])
    {
        [self.delegate waveformViewWillRender:self];
    }
    
    float progress = self.totalSamples ? (float)self.progressSamples / self.totalSamples : 0;
    self.image.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    self.clipping.frame = CGRectMake(0, 0, self.frame.size.width*progress, self.frame.size.height);

    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self renderPNGAudioPictogramLogForAsset:self.asset
                                            done:^(UIImage *image, UIImage *selectedImage) {
                                                
                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                    
                                                    [[SHKActivityIndicator currentIndicator] hide];
                                            
                                                    self.image.image = image;
                                                    CGAffineTransform transform = CGAffineTransformScale([self.image transform], ShowPercent, 1);
                                                    self.image.transform = transform;
                                                    if ([self.delegate respondsToSelector:@selector(waveformViewDidRender:)])
                                                    {
                                                        [self setFirstPosOfWaveform];
                                                        [self.delegate waveformViewDidRender:self];
                                                    }
                                                    
                                                });
                                                
                                            }];
        
    });
}

- (float) checkScale:(float)scale
{
    float size = self.image.frame.size.width * scale;
    if ( size < self.frame.size.width) {
        scale = self.frame.size.width / self.image.frame.size.width;
    }
    return  scale;
}

- (BOOL) redrawWaveform:(float)scale position:(float) pos
{
    CGRect rect = self.image.frame;
    self.image.frame = CGRectMake( pos, rect.origin.y, rect.size.width * scale, rect.size.height);
    return  true;
}

- (CGRect) getImageRect
{
    return self.image.frame;
}

- (BOOL) moveWaveform:(float) delta
{
    CGRect  rect = self.image.frame;
    self.image.frame = CGRectMake( rect.origin.x +delta, rect.origin.y, rect.size.width, rect.size.height);
    return true;
}

- (void) setChangeBasePos:(float) pt
{
    CGRect rect  = self.image.frame;
    self.image.frame = CGRectMake(pt, rect.origin.y, rect.size.width, rect.size.height);
}

- (void) setFirstPosOfWaveform
{
    CGRect  rect = self.image.frame;
    self.image.frame = CGRectMake( 0, rect.origin.y, rect.size.width, rect.size.height);
}

- (float) checkMovePos:(float) delta
{
    CGRect  rect = self.image.frame;
    float size = self.frame.size.width;
    
    float oriX = rect.origin.x;
    float width = oriX + rect.size.width;
    if ( (oriX + delta) > 0) {
        return -oriX;
    }
    
    if ( width + delta < size) {
       return width-size;
    }

    return delta;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

- (void) plotLogGraph:(Float32 *) samples
             maximumValue:(Float32) normalizeMax
             mimimumValue:(Float32) normalizeMin
              sampleCount:(NSInteger) sampleCount
              imageHeight:(float) imageHeight
                     done:(void(^)(UIImage *image, UIImage *selectedImage))done
{
    // TODO: switch to a synchronous function that paints onto a given context? (for issue #2)
    CGSize imageSize = CGSizeMake(sampleCount, imageHeight);
    UIGraphicsBeginImageContext(imageSize);
    
    if (renderFirst) {
        gContext = UIGraphicsGetCurrentContext();
        renderFirst = FALSE;
    }
    
    CGContextSetAlpha(gContext,1.0);
    CGContextSetLineWidth(gContext, 1.0);
    CGContextSetStrokeColorWithColor(gContext, [self.wavesColor CGColor]);
    
    float halfGraphHeight = (imageHeight / 2);
    float centerLeft = halfGraphHeight;
    float sampleAdjustmentFactor = imageHeight / (normalizeMax - noiseFloor) / 2;
    
    for (NSInteger intSample=0; intSample<sampleCount; intSample++)
    {
        Float32 sample = *samples++;
        float pixels = (sample - noiseFloor) * sampleAdjustmentFactor;
    
        CGContextMoveToPoint(gContext, intSample, centerLeft-pixels);
        CGContextAddLineToPoint(gContext, intSample, centerLeft+pixels);
        CGContextStrokePath(gContext);
    }

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    CGRect drawRect = CGRectMake(0, 0, image.size.width, image.size.height);
    [self.progressColor set];
    UIRectFillUsingBlendMode(drawRect, kCGBlendModeSourceAtop);
    UIImage *tintedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    done(image, tintedImage);
}

- (void)renderPNGAudioPictogramLogForAsset:(AVURLAsset *)songAsset
                                      done:(void(^)(UIImage *image, UIImage *selectedImage))done

{
    // TODO: break out subsampling code
    CGFloat widthInPixels = self.frame.size.width * [UIScreen mainScreen].scale * targetOverDraw;
    CGFloat heightInPixels = self.frame.size.height * [UIScreen mainScreen].scale;
    
    NSError *error = nil;
    AVAssetReader *reader = [[AVAssetReader alloc] initWithAsset:songAsset error:&error];
    AVAssetTrack *songTrack = [songAsset.tracks objectAtIndex:0];
    
    self.outputSettingsDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                               [NSNumber numberWithInt:kAudioFormatLinearPCM],AVFormatIDKey,
                               //     [NSNumber numberWithInt:44100.0],AVSampleRateKey, /*Not Supported*/
                               //     [NSNumber numberWithInt: 2],AVNumberOfChannelsKey,    /*Not Supported*/
                               [NSNumber numberWithInt:16],AVLinearPCMBitDepthKey,
                               [NSNumber numberWithBool:NO],AVLinearPCMIsBigEndianKey,
                               [NSNumber numberWithBool:NO],AVLinearPCMIsFloatKey,
                               [NSNumber numberWithBool:NO],AVLinearPCMIsNonInterleaved,
                               nil];
    
    self.output = [[AVAssetReaderTrackOutput alloc] initWithTrack:songTrack outputSettings:self.outputSettingsDict];
    [reader addOutput:self.output];
    
    UInt32 channelCount = 1;
    NSArray *formatDesc = songTrack.formatDescriptions;
    
    for(unsigned int i = 0; i < [formatDesc count]; ++i)
    {
        CMAudioFormatDescriptionRef item = (__bridge CMAudioFormatDescriptionRef)[formatDesc objectAtIndex:i];
        const AudioStreamBasicDescription* fmtDesc = CMAudioFormatDescriptionGetStreamBasicDescription(item);
        
        if (!fmtDesc)
            return;
        
        channelCount = fmtDesc->mChannelsPerFrame;
    }
    
    UInt32 bytesPerInputSample = 2 * channelCount;
    Float32 maximum = noiseFloor;
    Float64 tally = 0;
    Float32 tallyCount = 0;
    Float32 outSamples = 0;
    NSInteger downsampleFactor = self.totalSamples / widthInPixels;
    
    downsampleFactor = downsampleFactor<1 ? 1 : downsampleFactor;
    
    
    
    self.fullSongData = [[NSMutableData alloc] initWithCapacity:self.totalSamples/downsampleFactor*2]; // 16-bit samples
    
    
    //20150703 by Yinjing Li
    CMTimeRange timeRange = CMTimeRangeMake(CMTimeMake(self.startSamples*songAsset.duration.timescale, songAsset.duration.timescale), CMTimeMake(self.endSamples*songAsset.duration.timescale, songAsset.duration.timescale));
    reader.timeRange = timeRange;
    
    [reader startReading];
    
    while (reader.status == AVAssetReaderStatusReading) {
        AVAssetReaderTrackOutput * trackOutput = (AVAssetReaderTrackOutput *)[reader.outputs objectAtIndex:0];
        CMSampleBufferRef sampleBufferRef = [trackOutput copyNextSampleBuffer];
        if (sampleBufferRef)                   {
            CMBlockBufferRef blockBufferRef = CMSampleBufferGetDataBuffer(sampleBufferRef);
            size_t bufferLength = CMBlockBufferGetDataLength(blockBufferRef);
            void *data = malloc(bufferLength);
            CMBlockBufferCopyDataBytes(blockBufferRef, 0, bufferLength, data);
            
            SInt16 *samples = (SInt16 *)data;
            int sampleCount = (int)(bufferLength / bytesPerInputSample);
            
            for (int i=0; i<sampleCount; i++)
            {
                Float32 sample = (Float32) *samples++;
                sample = decibel(sample);
                sample = minMaxX(sample,noiseFloor,0);
                tally += sample; // Should be RMS?
                for (int j=1; j<channelCount; j++)
                    samples++;
                tallyCount++;
                
                if (tallyCount == downsampleFactor)
                {
                    sample = tally / tallyCount;
                    maximum = maximum > sample ? maximum : sample;
                    [self.fullSongData appendBytes:&sample length:sizeof(sample)];
                    tally = 0;
                    tallyCount = 0;
                    outSamples++;
                }
            }
            
            CMSampleBufferInvalidate(sampleBufferRef);
            CFRelease(sampleBufferRef);
            free(data);
        }
    }
    
    // if (reader.status == AVAssetReaderStatusFailed || reader.status == AVAssetReaderStatusUnknown)
    // Something went wrong. Handle it.
    if (reader.status == AVAssetReaderStatusCompleted){
        [self plotLogGraph:(Float32 *)self.fullSongData.bytes
              maximumValue:maximum
              mimimumValue:noiseFloor
               sampleCount:outSamples
               imageHeight:heightInPixels
                      done:done];
    }
}


#pragma mark - Interaction

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!self.doesAllowScrubbing)
        return;
    UITouch *touch = [touches anyObject];
    self.progressSamples = (float)self.totalSamples * [touch locationInView:self].x / self.bounds.size.width;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!self.doesAllowScrubbing)
        return;
    UITouch *touch = [touches anyObject];
    self.progressSamples = (float)self.totalSamples * [touch locationInView:self].x / self.bounds.size.width;
}

@end
