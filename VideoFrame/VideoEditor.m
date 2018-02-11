//
//  VideoEditor.m
//  VideoFrame
//
//  Created by Yinjing Li on 11/20/13.
//  Copyright (c) 2013 Yinjing Li. All rights reserved.
//

#import "VideoEditor.h"
#import "UIImageExtras.h"

@import Photos;


@interface VideoEditor ()

@end

@implementation VideoEditor


- (id)init
{
    self = [super init];
    
    if (self)
    {
        self.filter = nil;
        self.thMovieA = nil;
        self.thMovieFX = nil;
        self.asset1 = nil;
        self.asset2 = nil;
        self.exporter = nil;
        self.mixComposition = nil;
        self.layerInstructionArray = nil;
        self.currentProcessingIdx = 0;
    }
    
    return self;
}

- (void) setPreviewFlag:(BOOL) flag
{
    isPreview = flag;
}


/*
 set output video size.
 iphone - @2x of workspace size.
 ipad - @1.5x of workspace size.
 */
- (void) setVideoSize:(CGSize) size
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        switch (gnTemplateIndex)
        {
            case TEMPLATE_LANDSCAPE:
                if (gnOutputQuality == OUTPUT_HD)
                    outputScaleFactor = 1080.0f / size.height;
                else if (gnOutputQuality == OUTPUT_UNIVERSAL)
                    outputScaleFactor = 640.0f / size.height;
                else if (gnOutputQuality == OUTPUT_SDTV)
                    outputScaleFactor = 1.0f;
                
                break;
            case TEMPLATE_PORTRAIT:
                if (gnOutputQuality == OUTPUT_HD)
                    outputScaleFactor = 1080.0f / size.width;
                else if (gnOutputQuality == OUTPUT_UNIVERSAL)
                    outputScaleFactor = 640.0f / size.width;
                else if (gnOutputQuality == OUTPUT_SDTV)
                    outputScaleFactor = 1.0f;
                
                break;
            case TEMPLATE_1080P:
                if (gnOutputQuality == OUTPUT_HD)
                {
                    CGSize mainSize = [UIScreen mainScreen].bounds.size;

                    outputScaleFactor = 1920.0f/(mainSize.width-130.0f);
                }
                else if (gnOutputQuality == OUTPUT_UNIVERSAL)
                {
                    CGSize mainSize = [UIScreen mainScreen].bounds.size;
                    
                    outputScaleFactor = 1280.0f/(mainSize.width-130.0f);
                }
                else if (gnOutputQuality == OUTPUT_SDTV)
                {
                    CGSize mainSize = [UIScreen mainScreen].bounds.size;
                    
                    outputScaleFactor = mainSize.height/(mainSize.width-130.0f);
                }
                
                break;
            case TEMPLATE_SQUARE:
                if (gnOutputQuality == OUTPUT_HD)
                {
                    outputScaleFactor = 1024.0f / size.width;
                }
                else if (gnOutputQuality == OUTPUT_UNIVERSAL)
                {
                    outputScaleFactor = 912.0f / size.width;
                }
                else if (gnOutputQuality == OUTPUT_SDTV)
                {
                    outputScaleFactor = 640.0f / size.width;
                }
                
                break;
                
            default:
                break;
        }
    }
    else
    {
        switch (gnTemplateIndex)
        {
            case TEMPLATE_LANDSCAPE:
                if (gnOutputQuality == OUTPUT_HD)
                {
                    outputScaleFactor = 1.5f;
                }
                else if (gnOutputQuality == OUTPUT_UNIVERSAL)
                {
                    outputScaleFactor = 1.0f;
                }
                else if (gnOutputQuality == OUTPUT_SDTV)
                {
                    outputScaleFactor = 0.9375f;
                }
                
                break;
            case TEMPLATE_PORTRAIT:
                if (gnOutputQuality == OUTPUT_HD)
                {
                    outputScaleFactor = 1.5f;
                }
                else if (gnOutputQuality == OUTPUT_UNIVERSAL)
                {
                    outputScaleFactor = 1.0f;
                }
                else if (gnOutputQuality == OUTPUT_SDTV)
                {
                    outputScaleFactor = 0.9375f;
                }

                break;
            case TEMPLATE_1080P:
                if (gnOutputQuality == OUTPUT_HD)
                {
                    outputScaleFactor = 2.0f;
                }
                else if (gnOutputQuality == OUTPUT_UNIVERSAL)
                {
                    outputScaleFactor = 2.0f*1280.0f/1920.0f;
                }
                else if (gnOutputQuality == OUTPUT_SDTV)
                {
                    outputScaleFactor = 1.0f;
                }

                break;
            case TEMPLATE_SQUARE:
                if (gnOutputQuality == OUTPUT_HD)
                {
                    outputScaleFactor = 1024.0f / size.width;
                }
                else if (gnOutputQuality == OUTPUT_UNIVERSAL)
                {
                    outputScaleFactor = 912.0f / size.width;
                }
                else if (gnOutputQuality == OUTPUT_SDTV)
                {
                    outputScaleFactor = 640.0f / size.width;
                }

                break;
                
            default:
                break;
        }
    }

    videoSize = CGSizeMake(size.width*outputScaleFactor, size.height*outputScaleFactor);
}


- (void) removeAllObjects
{
    if (self.objectArray != nil)
    {
        [self.objectArray removeAllObjects];
        self.objectArray = nil;
    }
}

- (void) setInputObjectArray:(NSMutableArray*) array
{
    [self removeAllObjects];
    
    self.objectArray = [[NSMutableArray alloc] init];
    
    for (int i=0; i<array.count; i++)
    {
        @autoreleasepool {
    
            MediaObjectView* object = [array objectAtIndex:i];
            
            CGFloat objectDuration = object.mfEndPosition - object.mfStartPosition;
            
            int nStart = (int)(object.mfStartPosition*10.0f);
            object.mfStartPosition = nStart / 10.0f;
            object.mfEndPosition = object.mfStartPosition + objectDuration;
            
            if ((objectDuration - MIN_DURATION*2.0f) < (object.mfStartAnimationDuration + object.mfEndAnimationDuration))
            {
                if (object.startActionType != ACTION_NONE)
                    object.mfStartAnimationDuration = objectDuration/2.0f - MIN_DURATION;
                else
                    object.mfStartAnimationDuration = 0.0f;
                
                if (object.endActionType != ACTION_NONE)
                    object.mfEndAnimationDuration = objectDuration/2.0f - MIN_DURATION;
                else
                    object.mfEndAnimationDuration = 0.0f;
            }
            
            if (object.mfEndPosition > grNormalFilterOutputTotalTime)
                object.mfEndPosition = grNormalFilterOutputTotalTime;
            
            if ((object.mediaType == MEDIA_VIDEO)||(object.mediaType == MEDIA_GIF))
            {
                UIImage* renderedImage = [object renderingImageView];
                object.renderedImage = renderedImage;
                
                if ((object.startActionType == ACTION_SWAP_ALL)&&(object.endActionType == ACTION_SWAP_ALL))
                {
                    MediaObjectView *obj1 = [[MediaObjectView alloc] init];
                    [obj1 objectCopy:object];
                    obj1.isExistAudioTrack = YES;
                    obj1.startActionType = ACTION_SWAP_RL;
                    obj1.endActionType = ACTION_SWAP_RL;
                    obj1.renderedImage = renderedImage;
                    [self.objectArray addObject:obj1];
                    
                    MediaObjectView *obj2 = [[MediaObjectView alloc] init];
                    [obj2 objectCopy:object];
                    obj2.startActionType = ACTION_SWAP_LR;
                    obj2.endActionType = ACTION_SWAP_LR;
                    obj2.renderedImage = renderedImage;
                    [self.objectArray addObject:obj2];
                    
                    MediaObjectView *obj3 = [[MediaObjectView alloc] init];
                    [obj3 objectCopy:object];
                    obj3.startActionType = ACTION_SWAP_TB;
                    obj3.endActionType = ACTION_SWAP_TB;
                    obj3.renderedImage = renderedImage;
                    [self.objectArray addObject:obj3];
                    
                    MediaObjectView *obj4 = [[MediaObjectView alloc] init];
                    [obj4 objectCopy:object];
                    obj4.startActionType = ACTION_SWAP_BT;
                    obj4.endActionType = ACTION_SWAP_BT;
                    obj4.renderedImage = renderedImage;
                    [self.objectArray addObject:obj4];
                }
                else if ((object.startActionType == ACTION_SWAP_ALL)&&(object.endActionType == ACTION_ZOOM_ALL))
                {
                    MediaObjectView *obj1 = [[MediaObjectView alloc] init];
                    [obj1 objectCopy:object];
                    obj1.isExistAudioTrack = YES;
                    obj1.startActionType = ACTION_SWAP_RL;
                    obj1.endActionType = ACTION_ZOOM_RL;
                    obj1.renderedImage = renderedImage;
                    [self.objectArray addObject:obj1];
                    
                    MediaObjectView *obj2 = [[MediaObjectView alloc] init];
                    [obj2 objectCopy:object];
                    obj2.startActionType = ACTION_SWAP_LR;
                    obj2.endActionType = ACTION_ZOOM_LR;
                    obj2.renderedImage = renderedImage;
                    [self.objectArray addObject:obj2];
                    
                    MediaObjectView *obj3 = [[MediaObjectView alloc] init];
                    [obj3 objectCopy:object];
                    obj3.startActionType = ACTION_SWAP_TB;
                    obj3.endActionType = ACTION_ZOOM_TB;
                    obj3.renderedImage = renderedImage;
                    [self.objectArray addObject:obj3];
                    
                    MediaObjectView *obj4 = [[MediaObjectView alloc] init];
                    [obj4 objectCopy:object];
                    obj4.startActionType = ACTION_SWAP_BT;
                    obj4.endActionType = ACTION_ZOOM_BT;
                    obj4.renderedImage = renderedImage;
                    [self.objectArray addObject:obj4];
                    
                    MediaObjectView *obj5 = [[MediaObjectView alloc] init];
                    [obj5 objectCopy:object];
                    obj5.startActionType = ACTION_SWAP_BT;
                    obj5.endActionType = ACTION_ZOOM_CC;
                    obj5.renderedImage = renderedImage;
                    [self.objectArray addObject:obj5];
                }
                else if ((object.startActionType == ACTION_ZOOM_ALL)&&(object.endActionType == ACTION_ZOOM_ALL))
                {
                    MediaObjectView *obj1 = [[MediaObjectView alloc] init];
                    [obj1 objectCopy:object];
                    obj1.isExistAudioTrack = YES;
                    obj1.startActionType = ACTION_ZOOM_RL;
                    obj1.endActionType = ACTION_ZOOM_RL;
                    obj1.renderedImage = renderedImage;
                    [self.objectArray addObject:obj1];
                    
                    MediaObjectView *obj2 = [[MediaObjectView alloc] init];
                    [obj2 objectCopy:object];
                    obj2.startActionType = ACTION_ZOOM_LR;
                    obj2.endActionType = ACTION_ZOOM_LR;
                    obj2.renderedImage = renderedImage;
                    [self.objectArray addObject:obj2];
                    
                    MediaObjectView *obj3 = [[MediaObjectView alloc] init];
                    [obj3 objectCopy:object];
                    obj3.startActionType = ACTION_ZOOM_TB;
                    obj3.endActionType = ACTION_ZOOM_TB;
                    obj3.renderedImage = renderedImage;
                    [self.objectArray addObject:obj3];
                    
                    MediaObjectView *obj4 = [[MediaObjectView alloc] init];
                    [obj4 objectCopy:object];
                    obj4.startActionType = ACTION_ZOOM_BT;
                    obj4.endActionType = ACTION_ZOOM_BT;
                    obj4.renderedImage = renderedImage;
                    [self.objectArray addObject:obj4];
                    
                    MediaObjectView *obj5 = [[MediaObjectView alloc] init];
                    [obj5 objectCopy:object];
                    obj5.startActionType = ACTION_ZOOM_CC;
                    obj5.endActionType = ACTION_ZOOM_CC;
                    obj5.renderedImage = renderedImage;
                    [self.objectArray addObject:obj5];
                }
                else if ((object.startActionType == ACTION_ZOOM_ALL)&&(object.endActionType == ACTION_SWAP_ALL))
                {
                    MediaObjectView *obj1 = [[MediaObjectView alloc] init];
                    [obj1 objectCopy:object];
                    obj1.isExistAudioTrack = YES;
                    obj1.startActionType = ACTION_ZOOM_RL;
                    obj1.endActionType = ACTION_SWAP_RL;
                    obj1.renderedImage = renderedImage;
                    [self.objectArray addObject:obj1];
                    
                    MediaObjectView *obj2 = [[MediaObjectView alloc] init];
                    [obj2 objectCopy:object];
                    obj2.startActionType = ACTION_ZOOM_LR;
                    obj2.endActionType = ACTION_SWAP_LR;
                    obj2.renderedImage = renderedImage;
                    [self.objectArray addObject:obj2];
                    
                    MediaObjectView *obj3 = [[MediaObjectView alloc] init];
                    [obj3 objectCopy:object];
                    obj3.startActionType = ACTION_ZOOM_TB;
                    obj3.endActionType = ACTION_SWAP_TB;
                    obj3.renderedImage = renderedImage;
                    [self.objectArray addObject:obj3];
                    
                    MediaObjectView *obj4 = [[MediaObjectView alloc] init];
                    [obj4 objectCopy:object];
                    obj4.startActionType = ACTION_ZOOM_BT;
                    obj4.endActionType = ACTION_SWAP_BT;
                    obj4.renderedImage = renderedImage;
                    [self.objectArray addObject:obj4];
                    
                    MediaObjectView *obj5 = [[MediaObjectView alloc] init];
                    [obj5 objectCopy:object];
                    obj5.startActionType = ACTION_ZOOM_CC;
                    obj5.endActionType = ACTION_NONE;
                    obj5.mfEndPosition = obj5.mfStartPosition+obj5.mfStartAnimationDuration;
                    obj5.mfEndAnimationDuration = MIN_DURATION;
                    obj5.renderedImage = renderedImage;
                    [self.objectArray addObject:obj5];
                }
                else
                {
                    if (object.startActionType == ACTION_SWAP_ALL)
                    {
                        MediaObjectView *obj1 = [[MediaObjectView alloc] init];
                        [obj1 objectCopy:object];
                        obj1.startActionType = ACTION_SWAP_RL;
                        obj1.endActionType = ACTION_NONE;
                        obj1.mfEndPosition = obj1.mfStartPosition + obj1.mfStartAnimationDuration;
                        obj1.mfEndAnimationDuration = MIN_DURATION;
                        obj1.renderedImage = renderedImage;
                        [self.objectArray addObject:obj1];
                        
                        MediaObjectView *obj2 = [[MediaObjectView alloc] init];
                        [obj2 objectCopy:object];
                        obj2.startActionType = ACTION_SWAP_LR;
                        obj2.endActionType = ACTION_NONE;
                        obj2.mfEndPosition = obj2.mfStartPosition + obj2.mfStartAnimationDuration;
                        obj2.mfEndAnimationDuration = MIN_DURATION;
                        obj2.renderedImage = renderedImage;
                        [self.objectArray addObject:obj2];
                        
                        MediaObjectView *obj3 = [[MediaObjectView alloc] init];
                        [obj3 objectCopy:object];
                        obj3.startActionType = ACTION_SWAP_TB;
                        obj3.endActionType = ACTION_NONE;
                        obj3.mfEndPosition = obj3.mfStartPosition + obj3.mfStartAnimationDuration;
                        obj3.mfEndAnimationDuration = MIN_DURATION;
                        obj3.renderedImage = renderedImage;
                        [self.objectArray addObject:obj3];
                        
                        object.startActionType = ACTION_SWAP_BT;
                    }
                    
                    if (object.startActionType == ACTION_ZOOM_ALL)
                    {
                        MediaObjectView *obj1 = [[MediaObjectView alloc] init];
                        [obj1 objectCopy:object];
                        obj1.startActionType = ACTION_ZOOM_RL;
                        obj1.endActionType = ACTION_NONE;
                        obj1.mfEndPosition = obj1.mfStartPosition+obj1.mfStartAnimationDuration;
                        obj1.mfEndAnimationDuration = MIN_DURATION;
                        obj1.renderedImage = renderedImage;
                        [self.objectArray addObject:obj1];
                        
                        MediaObjectView *obj2 = [[MediaObjectView alloc] init];
                        [obj2 objectCopy:object];
                        obj2.startActionType = ACTION_ZOOM_LR;
                        obj2.endActionType = ACTION_NONE;
                        obj2.mfEndPosition = obj2.mfStartPosition+obj2.mfStartAnimationDuration;
                        obj2.mfEndAnimationDuration = MIN_DURATION;
                        obj2.renderedImage = renderedImage;
                        [self.objectArray addObject:obj2];
                        
                        MediaObjectView *obj3 = [[MediaObjectView alloc] init];
                        [obj3 objectCopy:object];
                        obj3.startActionType = ACTION_ZOOM_TB;
                        obj3.endActionType = ACTION_NONE;
                        obj3.mfEndPosition = obj3.mfStartPosition+obj3.mfStartAnimationDuration;
                        obj3.mfEndAnimationDuration = MIN_DURATION;
                        obj3.renderedImage = renderedImage;
                        [self.objectArray addObject:obj3];
                        
                        MediaObjectView *obj4 = [[MediaObjectView alloc] init];
                        [obj4 objectCopy:object];
                        obj4.startActionType = ACTION_ZOOM_BT;
                        obj4.endActionType = ACTION_NONE;
                        obj4.mfEndPosition = obj4.mfStartPosition+obj4.mfStartAnimationDuration;
                        obj4.mfEndAnimationDuration = MIN_DURATION;
                        obj4.renderedImage = renderedImage;
                        [self.objectArray addObject:obj4];
                        
                        object.startActionType = ACTION_ZOOM_CC;
                    }
                    
                    if (object.endActionType == ACTION_SWAP_ALL)
                    {
                        MediaObjectView *obj1 = [[MediaObjectView alloc] init];
                        [obj1 objectCopy:object];
                        obj1.startActionType = ACTION_NONE;
                        obj1.mfStartPosition = obj1.mfEndPosition - obj1.mfEndAnimationDuration - MIN_DURATION;
                        obj1.mfStartAnimationDuration = MIN_DURATION;
                        obj1.endActionType = ACTION_SWAP_RL;
                        obj1.renderedImage = renderedImage;
                        [self.objectArray addObject:obj1];
                        
                        MediaObjectView *obj2 = [[MediaObjectView alloc] init];
                        [obj2 objectCopy:object];
                        obj2.startActionType = ACTION_NONE;
                        obj2.mfStartPosition = obj2.mfEndPosition - obj2.mfEndAnimationDuration - MIN_DURATION;
                        obj2.mfStartAnimationDuration = MIN_DURATION;
                        obj2.endActionType = ACTION_SWAP_LR;
                        obj2.renderedImage = renderedImage;
                        [self.objectArray addObject:obj2];
                        
                        MediaObjectView *obj3 = [[MediaObjectView alloc] init];
                        [obj3 objectCopy:object];
                        obj3.startActionType = ACTION_NONE;
                        obj3.mfStartPosition = obj3.mfEndPosition - obj3.mfEndAnimationDuration - MIN_DURATION;
                        obj3.mfStartAnimationDuration = MIN_DURATION;
                        obj3.endActionType = ACTION_SWAP_TB;
                        obj3.renderedImage = renderedImage;
                        [self.objectArray addObject:obj3];
                        
                        object.endActionType = ACTION_SWAP_BT;
                    }
                    
                    if (object.endActionType == ACTION_ZOOM_ALL)
                    {
                        MediaObjectView *obj1 = [[MediaObjectView alloc] init];
                        [obj1 objectCopy:object];
                        obj1.startActionType = ACTION_NONE;
                        obj1.mfStartPosition = obj1.mfEndPosition - obj1.mfEndAnimationDuration - MIN_DURATION;
                        obj1.mfStartAnimationDuration = MIN_DURATION;
                        obj1.endActionType = ACTION_ZOOM_RL;
                        obj1.renderedImage = renderedImage;
                        [self.objectArray addObject:obj1];
                        
                        MediaObjectView *obj2 = [[MediaObjectView alloc] init];
                        [obj2 objectCopy:object];
                        obj2.startActionType = ACTION_NONE;
                        obj2.mfStartPosition = obj2.mfEndPosition - obj2.mfEndAnimationDuration - MIN_DURATION;
                        obj2.mfStartAnimationDuration = MIN_DURATION;
                        obj2.endActionType = ACTION_ZOOM_LR;
                        obj2.renderedImage = renderedImage;
                        [self.objectArray addObject:obj2];
                        
                        MediaObjectView *obj3 = [[MediaObjectView alloc] init];
                        [obj3 objectCopy:object];
                        obj3.startActionType = ACTION_NONE;
                        obj3.mfStartPosition = obj3.mfEndPosition - obj3.mfEndAnimationDuration - MIN_DURATION;
                        obj3.mfStartAnimationDuration = MIN_DURATION;
                        obj3.endActionType = ACTION_ZOOM_TB;
                        obj3.renderedImage = renderedImage;
                        [self.objectArray addObject:obj3];
                        
                        MediaObjectView *obj4 = [[MediaObjectView alloc] init];
                        [obj4 objectCopy:object];
                        obj4.startActionType = ACTION_NONE;
                        obj4.mfStartPosition = obj4.mfEndPosition - obj4.mfEndAnimationDuration - MIN_DURATION;
                        obj4.mfStartAnimationDuration = MIN_DURATION;
                        obj4.endActionType = ACTION_ZOOM_BT;
                        obj4.renderedImage = renderedImage;
                        [self.objectArray addObject:obj4];
                        
                        object.endActionType = ACTION_ZOOM_CC;
                    }
                    
                    [self.objectArray addObject:object];
                    
                    if ((((object.startActionType >= ACTION_GENIE_BL)&&(object.startActionType <= ACTION_GENIE_TR)) || ((object.endActionType >= ACTION_GENIE_BL)&&(object.endActionType <= ACTION_GENIE_TR))) && (gnOutputVideoFilterIndex == 0))
                    {
                        if ((object.startActionType >= ACTION_GENIE_BL)&&(object.startActionType <= ACTION_GENIE_TR))
                        {
                            MediaObjectView *obj1 = [[MediaObjectView alloc] init];
                            [obj1 objectCopy:object];
                            obj1.mediaType = MEDIA_PHOTO;
                            obj1.isPhotoFromVideo = YES;
                            obj1.endActionType = ACTION_NONE;
                            obj1.mfEndPosition = obj1.mfStartPosition + obj1.mfStartAnimationDuration;
                            obj1.mfEndAnimationDuration = MIN_DURATION;
                            obj1.renderedImage = renderedImage;
                            [self.objectArray addObject:obj1];
                        }
                        
                        if ((object.endActionType >= ACTION_GENIE_BL)&&(object.endActionType <= ACTION_GENIE_TR))
                        {
                            MediaObjectView *obj2 = [[MediaObjectView alloc] init];
                            [obj2 objectCopy:object];
                            obj2.mediaType = MEDIA_PHOTO;
                            obj2.isPhotoFromVideo = YES;
                            obj2.startActionType = ACTION_NONE;
                            obj2.mfStartPosition = obj2.mfEndPosition - obj2.mfEndAnimationDuration;
                            obj2.mfStartAnimationDuration = MIN_DURATION;
                            obj2.renderedImage = renderedImage;
                            [self.objectArray addObject:obj2];
                        }
                    }
                    
                    if (((object.startActionType == ACTION_EXPLODE)||(object.endActionType == ACTION_EXPLODE)) && (gnOutputVideoFilterIndex == 0))
                    {
                        if (object.startActionType == ACTION_EXPLODE)
                        {
                            MediaObjectView *obj1 = [[MediaObjectView alloc] init];
                            [obj1 objectCopy:object];
                            obj1.mediaType = MEDIA_PHOTO;
                            obj1.isPhotoFromVideo = YES;
                            obj1.mfStartAnimationDuration += MIN_DURATION;
                            obj1.endActionType = ACTION_NONE;
                            obj1.mfEndPosition = obj1.mfStartPosition + obj1.mfStartAnimationDuration;
                            obj1.mfEndAnimationDuration = MIN_DURATION;
                            obj1.renderedImage = renderedImage;
                            [self.objectArray addObject:obj1];
                        }
                        
                        if (object.endActionType == ACTION_EXPLODE)
                        {
                            MediaObjectView *obj2 = [[MediaObjectView alloc] init];
                            [obj2 objectCopy:object];
                            obj2.mediaType = MEDIA_PHOTO;
                            obj2.isPhotoFromVideo = YES;
                            obj2.startActionType = ACTION_NONE;
                            obj2.mfStartPosition = obj2.mfEndPosition - obj2.mfEndAnimationDuration;
                            obj2.mfStartAnimationDuration = MIN_DURATION;
                            obj2.renderedImage = renderedImage;
                            [self.objectArray addObject:obj2];
                        }
                    }
                    
                    if (((object.startActionType == ACTION_ROTATE)||(object.endActionType == ACTION_ROTATE)) && (gnOutputVideoFilterIndex == 0))
                    {
                        if (object.startActionType == ACTION_ROTATE)
                        {
                            MediaObjectView *obj1 = [[MediaObjectView alloc] init];
                            [obj1 objectCopy:object];
                            obj1.mediaType = MEDIA_PHOTO;
                            obj1.endActionType = ACTION_NONE;
                            obj1.mfEndPosition = obj1.mfStartPosition + obj1.mfStartAnimationDuration;
                            obj1.mfEndAnimationDuration = MIN_DURATION;
                            obj1.renderedImage = renderedImage;
                            [self.objectArray addObject:obj1];
                        }
                        
                        if (object.endActionType == ACTION_ROTATE)
                        {
                            MediaObjectView *obj2 = [[MediaObjectView alloc] init];
                            [obj2 objectCopy:object];
                            obj2.mediaType = MEDIA_PHOTO;
                            
                            if (object.startActionType == ACTION_ROTATE)
                                obj2.startActionType = ACTION_BLACK;
                            else
                                obj2.startActionType = ACTION_NONE;
                            
                            obj2.mfStartPosition = obj2.mfEndPosition - obj2.mfEndAnimationDuration;
                            obj2.mfStartAnimationDuration = MIN_DURATION;
                            obj2.renderedImage = renderedImage;
                            [self.objectArray addObject:obj2];
                        }
                    }
                }
                
                /****************************************
                 * Create an Imitation Photo Object from a Video(If that video have a shadow or outline, or video have a corner).
                 *****************************************/
                
                if (gnOutputVideoFilterIndex == 0)    //normal output
                {
                    if ((object.objectBorderStyle != 1)||(object.objectShadowStyle == 2)||(object.objectCornerRadius != 0.0f))
                    {
                        MediaObjectView *copiedObject = [[MediaObjectView alloc] init];
                        [copiedObject objectCopy:object];
                        copiedObject.mediaType = MEDIA_PHOTO;
                        copiedObject.isImitationPhoto = YES;
                        copiedObject.objectChromaColor = [UIColor blackColor];
                        copiedObject.renderedImage = [copiedObject renderingImageView];
                        [self.objectArray addObject:copiedObject];
                    }
                }
                else if (gnOutputVideoFilterIndex == 1)   //chromakey output
                {
                    if ((object.objectBorderStyle != 1)||(object.objectShadowStyle == 2))
                    {
                        MediaObjectView *copiedObject = [[MediaObjectView alloc] init];
                        [copiedObject objectCopy:object];
                        copiedObject.mediaType = MEDIA_PHOTO;
                        copiedObject.isImitationPhoto = YES;
                        
                        if ((copiedObject.startActionType == ACTION_ROTATE) || (copiedObject.startActionType == ACTION_EXPLODE) || ((object.startActionType >= ACTION_GENIE_BL)&&(object.startActionType <= ACTION_GENIE_TR)))
                        {
                            copiedObject.startActionType = ACTION_NONE;
                            copiedObject.mfStartPosition = copiedObject.mfStartPosition + copiedObject.mfStartAnimationDuration;
                        }
                        
                        if ((copiedObject.endActionType == ACTION_ROTATE) || (copiedObject.endActionType == ACTION_EXPLODE) || ((object.endActionType >= ACTION_GENIE_BL)&&(object.endActionType <= ACTION_GENIE_TR)))
                        {
                            copiedObject.endActionType = ACTION_NONE;
                            copiedObject.mfEndPosition = copiedObject.mfEndPosition - copiedObject.mfEndAnimationDuration;
                        }
                        
                        copiedObject.renderedImage = [copiedObject renderingImageView];
                        [self.objectArray addObject:copiedObject];
                    }
                }
            }
            else if (object.mediaType == MEDIA_PHOTO)
            {
                if (object.isReflection && object.isKbEnabled)
                    object.isKbEnabled = NO;
                
                object.renderedImage = [object renderingImageView];
                [self.objectArray addObject:object];
            }
            else if (object.mediaType == MEDIA_TEXT)
            {
                if (object.isReflection && object.isKbEnabled)
                    object.isKbEnabled = NO;
                
                object.renderedImage = [object renderingTextView];
                [self.objectArray addObject:object];
            }
            else if (object.mediaType == MEDIA_MUSIC)
            {
                [self.objectArray addObject:object];
            }
        }
    }
}


#pragma mark -
#pragma mark - Normal Filter Processing
/*
 * created by Yinjing Li at 2014/01/12
 */
- (void) createNormalVideo
{
    isFailed = NO;
    self.currentProcessingIdx = 0;
    self.filter = nil;
    
    
    if (self.mixComposition != nil)
        self.mixComposition = nil;
    self.mixComposition = [[AVMutableComposition alloc] init];
    
    
    if(self.layerInstructionArray != nil)
    {
        [self.layerInstructionArray removeAllObjects];
        self.layerInstructionArray = nil;
    }
    
    self.layerInstructionArray = [[NSMutableArray alloc] init];
    
    
    MediaObjectView* firstObject = [self getFirstObjectFromObjectArray];
    
    /* first object is a video */
    if ((firstObject.mediaType == MEDIA_VIDEO)||(firstObject.mediaType == MEDIA_GIF))
    {
        int index = [self getFirstProcessingIndexWhenFirstObjectIsVideo];
        
        mnProcessingCount = [self getProgressTotalCountInFirstVideo];
        mnProcessingIndex = 0;
        
        if (index == self.objectArray.count)
        {
            [self procNormalFilterFromAllObjects];
        }
        else // objects (0, index-1) are videos+photos.
        {
            self.currentProcessingIdx = index;
            [self procNormalFilterFromSomeObjects];
        }
    }
    else if ((firstObject.mediaType == MEDIA_PHOTO)||(firstObject.mediaType == MEDIA_TEXT))
    {
        mnProcessingCount = [self getProgressTotalCountInFirstVideo] + 1;
        mnProcessingIndex = 0;

        // first object is photo
        self.currentProcessingIdx = [self getFirstProcessingIndexWhenFirstObjectIsPhoto];
        
        [self firstPhotoToVideo:firstObject];
    }
}


- (void) procNormalFilterFromAllObjects
{
    NSMutableArray *allAudioParams = [[NSMutableArray alloc] init];
    
    for (int i = (int)[self.objectArray count] - 1; i>=0; i--)
    {
        @autoreleasepool
        {
            MediaObjectView* object = [self.objectArray objectAtIndex:i];
            
            if ((object.mediaType == MEDIA_VIDEO)||(object.mediaType == MEDIA_GIF))
            {
                AVURLAsset* inputAsset = [AVURLAsset assetWithURL:object.mediaUrl];
                
                if(inputAsset != nil)
                {
                    //duration
                    CMTime duration = inputAsset.duration;
                    
                    //VIDEO TRACK
                    AVMutableCompositionTrack *videoTrack = [self.mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
                    videoTrack = [self setVideoTrackTimeRange:inputAsset object:object track:videoTrack];
                    
                    if (object.isExistAudioTrack)
                    {
                        //AUDIO TRACK
                        NSArray *audioDataSourceArray = [NSArray arrayWithArray: [inputAsset tracksWithMediaType:AVMediaTypeAudio]];
                        if ([audioDataSourceArray count] > 0)
                        {
                            AVMutableCompositionTrack *audioTrack = [self.mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
                            
                            audioTrack = [self setAudioTrackTimeRange:inputAsset object:object track:audioTrack];
                            
                            //volume
                            CGFloat volume = [object getVolume];
                            
                            AVMutableAudioMixInputParameters *params;
                            params =[AVMutableAudioMixInputParameters audioMixInputParameters];
                            [params setVolume:volume atTime:kCMTimeZero];
                            [params setTrackID:[audioTrack trackID]];
                            [allAudioParams addObject:params];
                        }
                    }
                    
                    AVMutableVideoCompositionLayerInstruction *layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
                    
                    AVAssetTrack *assetTrack = [[inputAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
                    
                    CGRect cropRect = object.normalFilterVideoCropRect;
                    [layerInstruction setCropRectangle:cropRect atTime:kCMTimeZero];
                    
                    CGAffineTransform transform = object.nationalVideoTransformOutputValue;
                    transform = CGAffineTransformScale(transform, outputScaleFactor, outputScaleFactor);
                    transform = CGAffineTransformMake(transform.a, transform.b, transform.c, transform.d, transform.tx*outputScaleFactor, transform.ty*outputScaleFactor);
                    [layerInstruction setTransform:CGAffineTransformConcat(assetTrack.preferredTransform, transform) atTime:kCMTimeZero];
                    
                    CGFloat totalDuration = [object getVideoTotalDuration];
                    
                    if ((object.mfStartPosition + totalDuration) > grNormalFilterOutputTotalTime)
                    {
                        [layerInstruction setOpacity:0.0 atTime:CMTimeMake(grNormalFilterOutputTotalTime*inputAsset.duration.timescale, inputAsset.duration.timescale)];
                    }
                    else
                    {
                        [layerInstruction setOpacity:0.0 atTime:CMTimeMake((object.mfStartPosition + totalDuration)*duration.timescale, duration.timescale)];
                    }
                    
                    // video animations - 2014/02/03 by Yinjing Li
                    layerInstruction = [self setVideoAnimation:layerInstruction mediaObject:object asset:inputAsset];
                    
                    [self.layerInstructionArray addObject:layerInstruction];
                }
                
                inputAsset = nil;
            }
            else if (object.mediaType == MEDIA_MUSIC)
            {
                AVURLAsset* inputAsset = [AVURLAsset assetWithURL:object.mediaUrl];
                
                if(inputAsset != nil)
                {
                    //AUDIO TRACK
                    NSArray *audioDataSourceArray = [NSArray arrayWithArray: [inputAsset tracksWithMediaType:AVMediaTypeAudio]];
                    if ([audioDataSourceArray count] > 0)
                    {
                        AVMutableCompositionTrack *audioTrack = [self.mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
                        
                        CMTime startTimeOnComposition = CMTimeMake(object.mfStartPosition * inputAsset.duration.timescale, inputAsset.duration.timescale);
                        
                        for (int i=0; i<object.motionArray.count; i++)
                        {
                            NSError *error = nil;
                            
                            NSNumber* motionNum = [object.motionArray objectAtIndex:i];
                            NSNumber* startPosNum = [object.startPositionArray objectAtIndex:i];
                            NSNumber* endPosNum = [object.endPositionArray objectAtIndex:i];
                            
                            CGFloat motionValue = [motionNum floatValue];
                            CGFloat startPosition = [startPosNum floatValue];
                            CGFloat endPosition = [endPosNum floatValue];
                            
                            CMTime duration = CMTimeMakeWithSeconds((endPosition - startPosition), inputAsset.duration.timescale);
                            
                            [audioTrack insertTimeRange:CMTimeRangeMake(CMTimeMake(startPosition*inputAsset.duration.timescale, inputAsset.duration.timescale), duration)
                                                ofTrack:[audioDataSourceArray objectAtIndex:0]
                                                 atTime:startTimeOnComposition
                                                  error:&error];
                            if(error)
                                NSLog(@"Insertion error: %@", error);
                            
                            /************************** slow/fast motion *******************************/
                            if (motionValue != 1.0f)
                                [audioTrack scaleTimeRange:CMTimeRangeMake(startTimeOnComposition, duration)
                                                toDuration:CMTimeMake(duration.value/motionValue, inputAsset.duration.timescale)];
                            
                            startTimeOnComposition = CMTimeAdd(startTimeOnComposition, CMTimeMakeWithSeconds((endPosition - startPosition)/motionValue, inputAsset.duration.timescale));
                        }
                        
                        
                        //volume
                        CGFloat volume = [object getVolume];
                        
                        AVMutableAudioMixInputParameters *params;
                        params =[AVMutableAudioMixInputParameters audioMixInputParameters];
                        
                        if ((object.startActionType == ACTION_NONE)&&(object.endActionType == ACTION_NONE)) //[none, none]
                        {
                            [params setVolume:volume atTime:kCMTimeZero];
                        }
                        else if ((object.startActionType != ACTION_NONE)&&(object.endActionType != ACTION_NONE))    //[fade, fade]
                        {
                            [params setVolumeRampFromStartVolume:0.0
                                                     toEndVolume:volume
                                                       timeRange:CMTimeRangeMake(CMTimeMake(object.mfStartPosition*inputAsset.duration.timescale, inputAsset.duration.timescale), CMTimeMake(object.mfStartAnimationDuration*inputAsset.duration.timescale, inputAsset.duration.timescale))];
                            [params setVolumeRampFromStartVolume:volume
                                                     toEndVolume:0.0
                                                       timeRange:CMTimeRangeMake(CMTimeMake((object.mfEndPosition - object.mfEndAnimationDuration)*inputAsset.duration.timescale, inputAsset.duration.timescale), CMTimeMake(object.mfEndAnimationDuration*inputAsset.duration.timescale, inputAsset.duration.timescale))];
                        }
                        else if ((object.startActionType == ACTION_NONE)&&(object.endActionType != ACTION_NONE))    //[none, fade]
                        {
                            [params setVolumeRampFromStartVolume:volume
                                                     toEndVolume:volume
                                                       timeRange:CMTimeRangeMake(CMTimeMake(object.mfStartPosition*inputAsset.duration.timescale, inputAsset.duration.timescale), CMTimeMake(object.mfStartAnimationDuration*inputAsset.duration.timescale, inputAsset.duration.timescale))];
                            [params setVolumeRampFromStartVolume:volume
                                                     toEndVolume:0.0
                                                       timeRange:CMTimeRangeMake(CMTimeMake((object.mfEndPosition - object.mfEndAnimationDuration)*inputAsset.duration.timescale, inputAsset.duration.timescale), CMTimeMake(object.mfEndAnimationDuration*inputAsset.duration.timescale, inputAsset.duration.timescale))];
                            
                        }
                        else if ((object.startActionType != ACTION_NONE)&&(object.endActionType == ACTION_NONE))    //[fade, none]
                        {
                            [params setVolumeRampFromStartVolume:0.0
                                                     toEndVolume:volume
                                                       timeRange:CMTimeRangeMake(CMTimeMake(object.mfStartPosition*inputAsset.duration.timescale, inputAsset.duration.timescale), CMTimeMake(object.mfStartAnimationDuration*inputAsset.duration.timescale, inputAsset.duration.timescale))];
                            [params setVolumeRampFromStartVolume:volume
                                                     toEndVolume:volume
                                                       timeRange:CMTimeRangeMake(CMTimeMake((object.mfEndPosition - object.mfEndAnimationDuration)*inputAsset.duration.timescale, inputAsset.duration.timescale), CMTimeMake(object.mfEndAnimationDuration*inputAsset.duration.timescale, inputAsset.duration.timescale))];
                        }
                        
                        [params setTrackID:[audioTrack trackID]];
                        [allAudioParams addObject:params];
                    }
                }
                
                inputAsset = nil;
            }
        }
    }
    
    AVMutableAudioMix * audioMix = [AVMutableAudioMix audioMix];
    [audioMix setInputParameters:allAudioParams];
    
    AVMutableVideoCompositionInstruction * MainInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    CGFloat scale = [self getTimeScale];
    MainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMake(grNormalFilterOutputTotalTime*scale, scale));
    MainInstruction.backgroundColor = [UIColor clearColor].CGColor;
    MainInstruction.layerInstructions = self.layerInstructionArray;
    
    AVMutableVideoComposition *MainCompositionInst = [AVMutableVideoComposition videoComposition];
    MainCompositionInst.instructions = [NSArray arrayWithObject:MainInstruction];
    MainCompositionInst.frameDuration = CMTimeMake(1, grFrameRate);
    MainCompositionInst.renderSize = videoSize;
    
    // photo animations - 2014/02/03 by Yinjing Li
    MainCompositionInst.animationTool = [self setPhotoAnimation:0 index:(int)self.objectArray.count];

    if (isPreview)
        self.pathToMovie = [NSTemporaryDirectory() stringByAppendingPathComponent:@"VideoDreamer-Preview.m4v"];
    else
        self.pathToMovie = [NSTemporaryDirectory() stringByAppendingPathComponent:@"VideoDreamer.m4v"];

    unlink([self.pathToMovie UTF8String]); // If a file already exists, AVAssetWriter won't let you record new frames, so delete the old movie
    NSURL *url = [NSURL fileURLWithPath:self.pathToMovie];
    
    if (self.exporter != nil)
        self.exporter = nil;
    
    self.exporter = [[AVAssetExportSession alloc] initWithAsset:self.mixComposition presetName:AVAssetExportPresetHighestQuality];
    self.exporter.outputURL = url;
    self.exporter.outputFileType = AVFileTypeQuickTimeMovie;
    self.exporter.videoComposition = MainCompositionInst;
    [self.exporter setAudioMix:audioMix];//for volume
    
    if (isPreview && (grNormalFilterOutputTotalTime > grPreviewDuration))
        self.exporter.timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMake(grPreviewDuration*scale, scale));
    else
        self.exporter.timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMake(grNormalFilterOutputTotalTime*scale, scale));
    
    self.exporter.shouldOptimizeForNetworkUse = YES;
    
    //normal processing progress bar
    mnProcessingIndex++;

    dispatch_async(dispatch_get_main_queue(), ^{
        
        if ([self.delegate respondsToSelector:@selector(startAllNormalProgress:current:total:)])
            [self.delegate startAllNormalProgress:self.exporter current:mnProcessingIndex total:mnProcessingCount];
        
    });
   
    [self.exporter exportAsynchronouslyWithCompletionHandler:^
     {
         switch ([self.exporter status])
         {
            [self removeAllObjects];
                 
             case AVAssetExportSessionStatusFailed:
             {
                 NSLog(@"merge input videos - failed: %@", [[self.exporter error] localizedDescription]);
                 
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [[SHKActivityIndicator currentIndicator] performSelectorOnMainThread:@selector(hide) withObject:nil waitUntilDone:NO];
                     
                     if (isPreview) {//preview
                         if ([self.delegate respondsToSelector:@selector(didFailedPreview)]) {
                             [self.delegate didFailedPreview];
                         }
                     }else{//output faield
                         if ([self.delegate respondsToSelector:@selector(didFailedOutput)]) {
                             [self.delegate didFailedOutput];
                         }
                     }
                 });
             }
                 break;
                 
             case AVAssetExportSessionStatusCancelled:
             {
                 NSLog(@"merge input videos - canceled");
                 
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [[SHKActivityIndicator currentIndicator] performSelectorOnMainThread:@selector(hide) withObject:nil waitUntilDone:NO];
                     
                     if (isPreview) {//preview
                         if ([self.delegate respondsToSelector:@selector(didFailedPreview)]) {
                             [self.delegate didFailedPreview];
                         }
                     }else{//output faield
                         if ([self.delegate respondsToSelector:@selector(didFailedOutput)]) {
                             [self.delegate didFailedOutput];
                         }
                     }
                 });
             }
                 break;
                 
             default:
                 
                 dispatch_async(dispatch_get_main_queue(), ^{
                     
                     self.exporter = nil;
                     
                     if (isPreview)
                     {
                         [[SHKActivityIndicator currentIndicator] performSelectorOnMainThread:@selector(hide) withObject:nil waitUntilDone:NO];
                         
                         //make output video from temp videos
                         if ([self.delegate respondsToSelector:@selector(didCompletedPreview)])
                         {
                             [self.delegate didCompletedPreview];
                         }
                     }
                     else
                     {
                         NSLog(@"Video Save to Photo Album...");
                         
                         if ([self.delegate respondsToSelector:@selector(saveToAlbumProgress)])
                             [self.delegate saveToAlbumProgress];

                         [self saveMovieToPhotoAlbum];
                     }
                 });
                 
                 break;
         }
     }];
}

- (void) procNormalFilterFromSomeObjects
{
    NSMutableArray *allAudioParams = [[NSMutableArray alloc] init];
    
    for (int i=self.currentProcessingIdx-1; i>=0; i--)
    {
        @autoreleasepool
        {
            MediaObjectView* object = [self.objectArray objectAtIndex:i];
            
            if ((object.mediaType == MEDIA_VIDEO)||(object.mediaType == MEDIA_GIF))
            {
                AVURLAsset* inputAsset = [AVURLAsset assetWithURL:object.mediaUrl];
                
                if(inputAsset != nil)
                {
                    //duration
                    CMTime duration = inputAsset.duration;
                    
                    //VIDEO TRACK
                    AVMutableCompositionTrack *videoTrack = [self.mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
                    videoTrack = [self setVideoTrackTimeRange:inputAsset object:object track:videoTrack];
                    
                    if (object.isExistAudioTrack)
                    {
                        //AUDIO TRACK
                        NSArray *audioDataSourceArray = [NSArray arrayWithArray: [inputAsset tracksWithMediaType:AVMediaTypeAudio]];
                        if ([audioDataSourceArray count] > 0)
                        {
                            AVMutableCompositionTrack *audioTrack = [self.mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
                            
                            audioTrack = [self setAudioTrackTimeRange:inputAsset object:object track:audioTrack];
                            
                            //volume
                            CGFloat volume = [object getVolume];
                            
                            AVMutableAudioMixInputParameters *params;
                            params =[AVMutableAudioMixInputParameters audioMixInputParameters];
                            [params setVolume:volume atTime:kCMTimeZero];
                            [params setTrackID:[audioTrack trackID]];
                            [allAudioParams addObject:params];
                        }
                    }
                    
                    //fix orientation, transform//
                    AVMutableVideoCompositionLayerInstruction *layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
                    
                    AVAssetTrack *assetTrack = [[inputAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
                    
                    CGRect cropRect = object.normalFilterVideoCropRect;
                    [layerInstruction setCropRectangle:cropRect atTime:kCMTimeZero];
                    
                    CGAffineTransform transform = object.nationalVideoTransformOutputValue;
                    transform = CGAffineTransformScale(transform, outputScaleFactor, outputScaleFactor);
                    transform = CGAffineTransformMake(transform.a, transform.b, transform.c, transform.d, transform.tx*outputScaleFactor, transform.ty*outputScaleFactor);
                    [layerInstruction setTransform:CGAffineTransformConcat(assetTrack.preferredTransform, transform) atTime:kCMTimeZero];
                    
                    CGFloat totalDuration = [object getVideoTotalDuration];
                    
                    if ((object.mfStartPosition + totalDuration) > grNormalFilterOutputTotalTime)
                    {
                        [layerInstruction setOpacity:0.0 atTime:CMTimeMake(grNormalFilterOutputTotalTime*inputAsset.duration.timescale, inputAsset.duration.timescale)];
                    }
                    else
                    {
                        [layerInstruction setOpacity:0.0 atTime:CMTimeMake((object.mfStartPosition + totalDuration)*duration.timescale, duration.timescale)];
                    }
                    
                    // video animations - 2014/02/03 by Yinjing Li
                    layerInstruction = [self setVideoAnimation:layerInstruction mediaObject:object asset:inputAsset];
                    
                    [self.layerInstructionArray addObject:layerInstruction];
                }
                
                inputAsset = nil;
            }
            else if (object.mediaType == MEDIA_MUSIC)
            {
                AVURLAsset* inputAsset = [AVURLAsset assetWithURL:object.mediaUrl];
                
                if(inputAsset != nil)
                {
                    //AUDIO TRACK
                    NSArray *audioDataSourceArray = [NSArray arrayWithArray: [inputAsset tracksWithMediaType:AVMediaTypeAudio]];
                    
                    if ([audioDataSourceArray count] > 0)
                    {
                        AVMutableCompositionTrack *audioTrack = [self.mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
                        
                        CMTime startTimeOnComposition = CMTimeMake(object.mfStartPosition * inputAsset.duration.timescale, inputAsset.duration.timescale);
                        
                        for (int i=0; i<object.motionArray.count; i++)
                        {
                            NSError *error = nil;
                            
                            NSNumber* motionNum = [object.motionArray objectAtIndex:i];
                            NSNumber* startPosNum = [object.startPositionArray objectAtIndex:i];
                            NSNumber* endPosNum = [object.endPositionArray objectAtIndex:i];
                            
                            CGFloat motionValue = [motionNum floatValue];
                            CGFloat startPosition = [startPosNum floatValue];
                            CGFloat endPosition = [endPosNum floatValue];
                            
                            CMTime duration = CMTimeMakeWithSeconds((endPosition - startPosition), inputAsset.duration.timescale);
                            
                            [audioTrack insertTimeRange:CMTimeRangeMake(CMTimeMake(startPosition*inputAsset.duration.timescale, inputAsset.duration.timescale), duration)
                                                ofTrack:[audioDataSourceArray objectAtIndex:0]
                                                 atTime:startTimeOnComposition
                                                  error:&error];
                            if(error)
                                NSLog(@"Insertion error: %@", error);
                            
                            /************************** slow/fast motion *******************************/
                            if (motionValue != 1.0f)
                                [audioTrack scaleTimeRange:CMTimeRangeMake(startTimeOnComposition, duration)
                                                toDuration:CMTimeMake(duration.value/motionValue, inputAsset.duration.timescale)];
                            
                            startTimeOnComposition = CMTimeAdd(startTimeOnComposition, CMTimeMakeWithSeconds((endPosition - startPosition)/motionValue, inputAsset.duration.timescale));
                        }
                        
                        //volume
                        CGFloat volume = [object getVolume];
                        
                        AVMutableAudioMixInputParameters *params;
                        params =[AVMutableAudioMixInputParameters audioMixInputParameters];
                        
                        if ((object.startActionType == ACTION_NONE)&&(object.endActionType == ACTION_NONE)) //[none, none]
                        {
                            [params setVolume:volume atTime:kCMTimeZero];
                        }
                        else if ((object.startActionType != ACTION_NONE)&&(object.endActionType != ACTION_NONE))    //[fade, fade]
                        {
                            [params setVolumeRampFromStartVolume:0.0
                                                     toEndVolume:volume
                                                       timeRange:CMTimeRangeMake(CMTimeMake(object.mfStartPosition*inputAsset.duration.timescale, inputAsset.duration.timescale), CMTimeMake(object.mfStartAnimationDuration*inputAsset.duration.timescale, inputAsset.duration.timescale))];
                            [params setVolumeRampFromStartVolume:volume
                                                     toEndVolume:0.0
                                                       timeRange:CMTimeRangeMake(CMTimeMake((object.mfEndPosition - object.mfEndAnimationDuration)*inputAsset.duration.timescale, inputAsset.duration.timescale), CMTimeMake(object.mfEndAnimationDuration*inputAsset.duration.timescale, inputAsset.duration.timescale))];
                        }
                        else if ((object.startActionType == ACTION_NONE)&&(object.endActionType != ACTION_NONE))    //[none, fade]
                        {
                            [params setVolumeRampFromStartVolume:volume
                                                     toEndVolume:volume
                                                       timeRange:CMTimeRangeMake(CMTimeMake(object.mfStartPosition*inputAsset.duration.timescale, inputAsset.duration.timescale), CMTimeMake(object.mfStartAnimationDuration*inputAsset.duration.timescale, inputAsset.duration.timescale))];
                            [params setVolumeRampFromStartVolume:volume
                                                     toEndVolume:0.0
                                                       timeRange:CMTimeRangeMake(CMTimeMake((object.mfEndPosition - object.mfEndAnimationDuration)*inputAsset.duration.timescale, inputAsset.duration.timescale), CMTimeMake(object.mfEndAnimationDuration*inputAsset.duration.timescale, inputAsset.duration.timescale))];
                            
                        }
                        else if ((object.startActionType != ACTION_NONE)&&(object.endActionType == ACTION_NONE))    //[fade, none]
                        {
                            [params setVolumeRampFromStartVolume:0.0
                                                     toEndVolume:volume
                                                       timeRange:CMTimeRangeMake(CMTimeMake(object.mfStartPosition*inputAsset.duration.timescale, inputAsset.duration.timescale), CMTimeMake(object.mfStartAnimationDuration*inputAsset.duration.timescale, inputAsset.duration.timescale))];
                            [params setVolumeRampFromStartVolume:volume
                                                     toEndVolume:volume
                                                       timeRange:CMTimeRangeMake(CMTimeMake((object.mfEndPosition - object.mfEndAnimationDuration)*inputAsset.duration.timescale, inputAsset.duration.timescale), CMTimeMake(object.mfEndAnimationDuration*inputAsset.duration.timescale, inputAsset.duration.timescale))];
                        }
                        
                        [params setTrackID:[audioTrack trackID]];
                        [allAudioParams addObject:params];
                    }
                }
                
                inputAsset = nil;
            }
        }
    }
    
    AVMutableAudioMix * audioMix = [AVMutableAudioMix audioMix];
    [audioMix setInputParameters:allAudioParams];
    
    AVMutableVideoCompositionInstruction * MainInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    CGFloat scale = [self getTimeScale];
    MainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMake(grNormalFilterOutputTotalTime*scale, scale));
    MainInstruction.backgroundColor = [UIColor clearColor].CGColor;
    MainInstruction.layerInstructions = self.layerInstructionArray;
    
    AVMutableVideoComposition *MainCompositionInst = [AVMutableVideoComposition videoComposition];
    MainCompositionInst.instructions = [NSArray arrayWithObject:MainInstruction];
    MainCompositionInst.frameDuration = CMTimeMake(1, grFrameRate);
    MainCompositionInst.renderSize = videoSize;
    
    // photo animations - 2014/02/03 by Yinjing Li
    MainCompositionInst.animationTool = [self setPhotoAnimation:0 index:self.currentProcessingIdx];
    
    if (isPreview)
        self.pathToMovie = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"VideoDreamer-Preview%d.m4v", self.currentProcessingIdx]];
    else
        self.pathToMovie = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"VideoDreamer%d.m4v", self.currentProcessingIdx]];
    
    unlink([self.pathToMovie UTF8String]); // If a file already exists, AVAssetWriter won't let you record new frames, so delete the old movie
    NSURL *url = [NSURL fileURLWithPath:self.pathToMovie];
    
    if (self.exporter != nil)
        self.exporter = nil;
    
    self.exporter = [[AVAssetExportSession alloc] initWithAsset:self.mixComposition presetName:AVAssetExportPresetHighestQuality];
    self.exporter.outputURL = url;
    self.exporter.outputFileType = AVFileTypeQuickTimeMovie;
    self.exporter.videoComposition = MainCompositionInst;
    [self.exporter setAudioMix:audioMix];//for volume
    
    if (isPreview && (grNormalFilterOutputTotalTime > grPreviewDuration))
        self.exporter.timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMake(grPreviewDuration*scale, scale));
    else
        self.exporter.timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMake(grNormalFilterOutputTotalTime*scale, scale));
    
    self.exporter.shouldOptimizeForNetworkUse = YES;
    
    //normal processing progress bar
    mnProcessingIndex++;

    dispatch_async(dispatch_get_main_queue(), ^{
        
        if ([self.delegate respondsToSelector:@selector(startAllNormalProgress:current:total:)])
            [self.delegate startAllNormalProgress:self.exporter current:mnProcessingIndex total:mnProcessingCount];
        
    });
    
    [self.exporter exportAsynchronouslyWithCompletionHandler:^
     {
         switch ([self.exporter status])
         {
             case AVAssetExportSessionStatusFailed:
             {
                 NSLog(@"merge input videos - failed: %@", [[self.exporter error] localizedDescription]);
                 
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [[SHKActivityIndicator currentIndicator] performSelectorOnMainThread:@selector(hide) withObject:nil waitUntilDone:NO];
                     
                     [self removeAllObjects];

                     if (isPreview) {//preview
                         if ([self.delegate respondsToSelector:@selector(didFailedPreview)]) {
                             [self.delegate didFailedPreview];
                         }
                     }else{//output faield
                         if ([self.delegate respondsToSelector:@selector(didFailedOutput)]) {
                             [self.delegate didFailedOutput];
                         }
                     }
                 });
             }
                 break;
                 
             case AVAssetExportSessionStatusCancelled:
             {
                 NSLog(@"merge input videos - canceled");
                 
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [[SHKActivityIndicator currentIndicator] performSelectorOnMainThread:@selector(hide) withObject:nil waitUntilDone:NO];
                     
                     [self removeAllObjects];

                     if (isPreview) {//preview
                         if ([self.delegate respondsToSelector:@selector(didFailedPreview)]) {
                             [self.delegate didFailedPreview];
                         }
                     }else{//output faield
                         if ([self.delegate respondsToSelector:@selector(didFailedOutput)]) {
                             [self.delegate didFailedOutput];
                         }
                     }
                 });
             }
                 break;
                 
             default:
             {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [self performSelectorOnMainThread:@selector(nextNormalFilter) withObject:nil waitUntilDone:NO];
                 });
             }
                 break;
         }
     }];
}


- (void)nextNormalFilter
{
    if (self.mixComposition != nil)
        self.mixComposition = nil;
    self.mixComposition = [[AVMutableComposition alloc] init];
    
    if(self.layerInstructionArray != nil)
    {
        [self.layerInstructionArray removeAllObjects];
        self.layerInstructionArray = nil;
    }
    
    self.layerInstructionArray = [[NSMutableArray alloc] init];
    
    int prevIdx = self.currentProcessingIdx;
    int index = self.currentProcessingIdx;
    BOOL isProcessingStart = NO;
    int photoTextCount = 0;
    
    while (!isProcessingStart)
    {
        MediaObjectView* object = [self.objectArray objectAtIndex:index];
        
        if ((object.mediaType == MEDIA_VIDEO)||(object.mediaType == MEDIA_GIF)||(object.mediaType == MEDIA_MUSIC))
        {
            index++;
            
            if (index == self.objectArray.count)
            {
                isProcessingStart = YES;
            }
            else if (index >= (VIDEO_COMPOSITING_MAX_COUNT + prevIdx))
            {
                isProcessingStart = YES;
            }
        }
        else if ((object.mediaType == MEDIA_PHOTO)||(object.mediaType == MEDIA_TEXT))
        {
            BOOL isVideo = NO;
            
            while (!isVideo)
            {
                MediaObjectView* object_ = [self.objectArray objectAtIndex:index];
                
                if ((object_.mediaType == MEDIA_VIDEO)||(object_.mediaType == MEDIA_GIF))
                {
                    isVideo = YES;
                    isProcessingStart = YES;
                }
                else if ((object_.mediaType == MEDIA_PHOTO)||(object_.mediaType == MEDIA_TEXT)||(object_.mediaType == MEDIA_MUSIC))
                {
                    index++;
                    
                    if ((object_.mediaType == MEDIA_PHOTO)||(object_.mediaType == MEDIA_TEXT))
                    {
                        if ((object_.startActionType == ACTION_EXPLODE)||
                            ((object_.startActionType >= ACTION_GENIE_BL)&&(object_.startActionType <= ACTION_GENIE_TR))||
                            (object_.startActionType == ACTION_SWAP_ALL)||
                            (object_.startActionType == ACTION_ZOOM_ALL)||
                            (object_.endActionType == ACTION_EXPLODE)||
                            ((object_.endActionType >= ACTION_GENIE_BL)&&(object_.endActionType <= ACTION_GENIE_TR))||
                            (object_.endActionType == ACTION_SWAP_ALL)||
                            (object_.endActionType == ACTION_ZOOM_ALL))
                        {
                            photoTextCount++;
                        }
                        
                        if (photoTextCount >= PHOTO_COMPOSITING_MAX_COUNT) {
                            isVideo = YES;
                            isProcessingStart = YES;
                        }
                    }
                    
                    if (index == self.objectArray.count)
                    {
                        isVideo = YES;
                        isProcessingStart = YES;
                    }
                }
            }
        }
    }
    
    self.currentProcessingIdx = index;
    
    if (self.currentProcessingIdx == self.objectArray.count) // all objects are videos.
    {
        NSMutableArray *allAudioParams = [[NSMutableArray alloc] init];
        NSURL* prevMovieURL = [NSURL fileURLWithPath:self.pathToMovie];
        AVURLAsset* prevAsset = [AVURLAsset assetWithURL:prevMovieURL];
        
        for (int i = (int)[self.objectArray count] - 1; i>=prevIdx; i--)
        {
            @autoreleasepool
            {
                MediaObjectView* object = [self.objectArray objectAtIndex:i];
                
                if ((object.mediaType == MEDIA_VIDEO)||(object.mediaType == MEDIA_GIF))
                {
                    AVURLAsset* inputAsset = [AVURLAsset assetWithURL:object.mediaUrl];
                    
                    if(inputAsset != nil)
                    {
                        //duration
                        CMTime duration = inputAsset.duration;
                        
                        //VIDEO TRACK
                        AVMutableCompositionTrack *videoTrack = [self.mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
                        
                        videoTrack = [self setVideoTrackTimeRange:inputAsset object:object track:videoTrack];
                        
                        if (object.isExistAudioTrack)
                        {
                            //AUDIO TRACK
                            NSArray *audioDataSourceArray = [NSArray arrayWithArray: [inputAsset tracksWithMediaType:AVMediaTypeAudio]];
                            if ([audioDataSourceArray count] > 0)
                            {
                                AVMutableCompositionTrack *audioTrack = [self.mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
                                
                                audioTrack = [self setAudioTrackTimeRange:inputAsset object:object track:audioTrack];
                                
                                //volume
                                CGFloat volume = [object getVolume];
                                
                                AVMutableAudioMixInputParameters *params;
                                params =[AVMutableAudioMixInputParameters audioMixInputParameters];
                                [params setVolume:volume atTime:kCMTimeZero];
                                [params setTrackID:[audioTrack trackID]];
                                [allAudioParams addObject:params];
                            }
                        }
                        
                        //fix orientation, transform//
                        AVMutableVideoCompositionLayerInstruction *layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
                        
                        AVAssetTrack *assetTrack = [[inputAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
                        
                        CGRect cropRect = object.normalFilterVideoCropRect;
                        [layerInstruction setCropRectangle:cropRect atTime:kCMTimeZero];
                        
                        CGAffineTransform transform = object.nationalVideoTransformOutputValue;
                        transform = CGAffineTransformScale(transform, outputScaleFactor, outputScaleFactor);
                        transform = CGAffineTransformMake(transform.a, transform.b, transform.c, transform.d, transform.tx*outputScaleFactor, transform.ty*outputScaleFactor);
                        [layerInstruction setTransform:CGAffineTransformConcat(assetTrack.preferredTransform, transform) atTime:kCMTimeZero];
                        
                        CGFloat totalDuration = [object getVideoTotalDuration];
                        
                        if ((object.mfStartPosition + totalDuration) > grNormalFilterOutputTotalTime)
                        {
                            [layerInstruction setOpacity:0.0 atTime:CMTimeMake(grNormalFilterOutputTotalTime*inputAsset.duration.timescale, inputAsset.duration.timescale)];
                        }
                        else
                        {
                            [layerInstruction setOpacity:0.0 atTime:CMTimeMake((object.mfStartPosition + totalDuration)*duration.timescale, duration.timescale)];
                        }
                        
                        // video animations - 2014/02/03 by Yinjing Li
                        layerInstruction = [self setVideoAnimation:layerInstruction mediaObject:object asset:inputAsset];
                        
                        [self.layerInstructionArray addObject:layerInstruction];
                    }
                    
                    inputAsset = nil;
                }
                else if (object.mediaType == MEDIA_MUSIC)
                {
                    AVURLAsset* inputAsset = [AVURLAsset assetWithURL:object.mediaUrl];
                    
                    if(inputAsset != nil)
                    {
                        //AUDIO TRACK
                        NSArray *audioDataSourceArray = [NSArray arrayWithArray: [inputAsset tracksWithMediaType:AVMediaTypeAudio]];
                        if ([audioDataSourceArray count] > 0)
                        {
                            AVMutableCompositionTrack *audioTrack = [self.mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
                            
                            CMTime startTimeOnComposition = CMTimeMake(object.mfStartPosition * inputAsset.duration.timescale, inputAsset.duration.timescale);
                            
                            for (int i=0; i<object.motionArray.count; i++)
                            {
                                NSError *error = nil;
                                
                                NSNumber* motionNum = [object.motionArray objectAtIndex:i];
                                NSNumber* startPosNum = [object.startPositionArray objectAtIndex:i];
                                NSNumber* endPosNum = [object.endPositionArray objectAtIndex:i];
                                
                                CGFloat motionValue = [motionNum floatValue];
                                CGFloat startPosition = [startPosNum floatValue];
                                CGFloat endPosition = [endPosNum floatValue];
                                
                                CMTime duration = CMTimeMakeWithSeconds((endPosition - startPosition), inputAsset.duration.timescale);
                                
                                [audioTrack insertTimeRange:CMTimeRangeMake(CMTimeMake(startPosition*inputAsset.duration.timescale, inputAsset.duration.timescale), duration)
                                                    ofTrack:[audioDataSourceArray objectAtIndex:0]
                                                     atTime:startTimeOnComposition
                                                      error:&error];
                                if(error)
                                    NSLog(@"Insertion error: %@", error);
                                
                                /************************** slow/fast motion *******************************/
                                if (motionValue != 1.0f)
                                    [audioTrack scaleTimeRange:CMTimeRangeMake(startTimeOnComposition, duration)
                                                    toDuration:CMTimeMake(duration.value/motionValue, inputAsset.duration.timescale)];
                                
                                startTimeOnComposition = CMTimeAdd(startTimeOnComposition, CMTimeMakeWithSeconds((endPosition - startPosition)/motionValue, inputAsset.duration.timescale));
                            }
                            
                            //volume
                            CGFloat volume = [object getVolume];
                            
                            AVMutableAudioMixInputParameters *params;
                            params =[AVMutableAudioMixInputParameters audioMixInputParameters];
                            
                            if ((object.startActionType == ACTION_NONE)&&(object.endActionType == ACTION_NONE)) //[none, none]
                            {
                                [params setVolume:volume atTime:kCMTimeZero];
                            }
                            else if ((object.startActionType != ACTION_NONE)&&(object.endActionType != ACTION_NONE))    //[fade, fade]
                            {
                                [params setVolumeRampFromStartVolume:0.0
                                                         toEndVolume:volume
                                                           timeRange:CMTimeRangeMake(CMTimeMake(object.mfStartPosition*inputAsset.duration.timescale, inputAsset.duration.timescale), CMTimeMake(object.mfStartAnimationDuration*inputAsset.duration.timescale, inputAsset.duration.timescale))];
                                [params setVolumeRampFromStartVolume:volume
                                                         toEndVolume:0.0
                                                           timeRange:CMTimeRangeMake(CMTimeMake((object.mfEndPosition - object.mfEndAnimationDuration)*inputAsset.duration.timescale, inputAsset.duration.timescale), CMTimeMake(object.mfEndAnimationDuration*inputAsset.duration.timescale, inputAsset.duration.timescale))];
                            }
                            else if ((object.startActionType == ACTION_NONE)&&(object.endActionType != ACTION_NONE))    //[none, fade]
                            {
                                [params setVolumeRampFromStartVolume:volume
                                                         toEndVolume:volume
                                                           timeRange:CMTimeRangeMake(CMTimeMake(object.mfStartPosition*inputAsset.duration.timescale, inputAsset.duration.timescale), CMTimeMake(object.mfStartAnimationDuration*inputAsset.duration.timescale, inputAsset.duration.timescale))];
                                [params setVolumeRampFromStartVolume:volume
                                                         toEndVolume:0.0
                                                           timeRange:CMTimeRangeMake(CMTimeMake((object.mfEndPosition - object.mfEndAnimationDuration)*inputAsset.duration.timescale, inputAsset.duration.timescale), CMTimeMake(object.mfEndAnimationDuration*inputAsset.duration.timescale, inputAsset.duration.timescale))];
                                
                            }
                            else if ((object.startActionType != ACTION_NONE)&&(object.endActionType == ACTION_NONE))    //[fade, none]
                            {
                                [params setVolumeRampFromStartVolume:0.0
                                                         toEndVolume:volume
                                                           timeRange:CMTimeRangeMake(CMTimeMake(object.mfStartPosition*inputAsset.duration.timescale, inputAsset.duration.timescale), CMTimeMake(object.mfStartAnimationDuration*inputAsset.duration.timescale, inputAsset.duration.timescale))];
                                [params setVolumeRampFromStartVolume:volume
                                                         toEndVolume:volume
                                                           timeRange:CMTimeRangeMake(CMTimeMake((object.mfEndPosition - object.mfEndAnimationDuration)*inputAsset.duration.timescale, inputAsset.duration.timescale), CMTimeMake(object.mfEndAnimationDuration*inputAsset.duration.timescale, inputAsset.duration.timescale))];
                            }
                            
                            [params setTrackID:[audioTrack trackID]];
                            [allAudioParams addObject:params];
                        }
                    }
                    
                    inputAsset = nil;
                }
            }
        }
        
        if(prevAsset != nil)
        {
            //duration
            CMTime duration = prevAsset.duration;
            
            //VIDEO TRACK
            AVMutableCompositionTrack *videoTrack = [self.mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
            NSArray *videoDataSourceArray = [NSArray arrayWithArray: [prevAsset tracksWithMediaType:AVMediaTypeVideo]];
            NSError *error = nil;
            [videoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, duration)
                                ofTrack:([videoDataSourceArray count]>0)?[videoDataSourceArray objectAtIndex:0]:nil
                                 atTime:kCMTimeZero
                                  error:&error];
            if(error)
                NSLog(@"Insertion error: %@", error);
            
            
            //AUDIO TRACK
            NSArray *audioDataSourceArray = [NSArray arrayWithArray: [prevAsset tracksWithMediaType:AVMediaTypeAudio]];
            if ([audioDataSourceArray count] > 0)
            {
                AVMutableCompositionTrack *audioTrack = [self.mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
                error = nil;
                [audioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, duration)
                                    ofTrack:[audioDataSourceArray objectAtIndex:0]
                                     atTime:kCMTimeZero
                                      error:&error];
                if(error)
                    NSLog(@"Insertion error: %@", error);
                
                //volume
                CGFloat volume = 1.0f;
                
                AVMutableAudioMixInputParameters *params;
                params =[AVMutableAudioMixInputParameters audioMixInputParameters];
                [params setVolumeRampFromStartVolume:volume
                                         toEndVolume:volume
                                           timeRange:CMTimeRangeMake(kCMTimeZero, duration)];
                
                [params setTrackID:[audioTrack trackID]];
                [allAudioParams addObject:params];
            }
            
            //fix orientation, transform//
            AVMutableVideoCompositionLayerInstruction *layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
            
            AVAssetTrack *assetTrack = [[prevAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
            CGAffineTransform transfrom = CGAffineTransformIdentity;
            [layerInstruction setTransform:CGAffineTransformConcat(assetTrack.preferredTransform, transfrom) atTime:kCMTimeZero];
            
            if (duration.value / duration.timescale > grNormalFilterOutputTotalTime)
            {
                [layerInstruction setOpacity:0.0 atTime:CMTimeMake(grNormalFilterOutputTotalTime*duration.timescale, duration.timescale)];
            }
            else
            {
                [layerInstruction setOpacity:0.0 atTime:duration];
            }
            
            [self.layerInstructionArray addObject:layerInstruction];
        }
        
        AVMutableAudioMix * audioMix = [AVMutableAudioMix audioMix];
        [audioMix setInputParameters:allAudioParams];
        
        AVMutableVideoCompositionInstruction * MainInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
        CGFloat scale = [self getTimeScale];
        MainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMake(grNormalFilterOutputTotalTime*scale, scale));
        MainInstruction.backgroundColor = [UIColor clearColor].CGColor;
        MainInstruction.layerInstructions = self.layerInstructionArray;
        
        AVMutableVideoComposition *MainCompositionInst = [AVMutableVideoComposition videoComposition];
        MainCompositionInst.instructions = [NSArray arrayWithObject:MainInstruction];
        MainCompositionInst.frameDuration = CMTimeMake(1, grFrameRate);
        MainCompositionInst.renderSize = videoSize;
        
        // photo animations - 2014/02/03 by Yinjing Li
        MainCompositionInst.animationTool = [self setPhotoAnimation:prevIdx index:(int)self.objectArray.count];
        
        if (isPreview)
            self.pathToMovie = [NSTemporaryDirectory() stringByAppendingPathComponent:@"VideoDreamer-Preview.m4v"];
        else
            self.pathToMovie = [NSTemporaryDirectory() stringByAppendingPathComponent:@"VideoDreamer.m4v"];
        
        unlink([self.pathToMovie UTF8String]); // If a file already exists, AVAssetWriter won't let you record new frames, so delete the old movie
        NSURL *url = [NSURL fileURLWithPath:self.pathToMovie];
        
        if (self.exporter != nil)
            self.exporter = nil;
        
        self.exporter = [[AVAssetExportSession alloc] initWithAsset:self.mixComposition presetName:AVAssetExportPresetHighestQuality];
        self.exporter.outputURL=url;
        self.exporter.outputFileType = AVFileTypeQuickTimeMovie;
        self.exporter.videoComposition = MainCompositionInst;
        [self.exporter setAudioMix:audioMix];//for volume
        
        if (isPreview && (grNormalFilterOutputTotalTime > grPreviewDuration))
            self.exporter.timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMake(grPreviewDuration*scale, scale));
        else
            self.exporter.timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMake(grNormalFilterOutputTotalTime*scale, scale));
        
        self.exporter.shouldOptimizeForNetworkUse = YES;
        
        
        //normal processing progress bar
        mnProcessingIndex++;

        dispatch_async(dispatch_get_main_queue(), ^{
            
            if ([self.delegate respondsToSelector:@selector(startAllNormalProgress:current:total:)])
                [self.delegate startAllNormalProgress:self.exporter current:mnProcessingIndex total:mnProcessingCount];
            
        });

        [self.exporter exportAsynchronouslyWithCompletionHandler:^
         {
             switch ([self.exporter status])
             {
                [self removeAllObjects];

                 case AVAssetExportSessionStatusFailed:
                 {
                     NSLog(@"merge input videos - failed: %@", [[self.exporter error] localizedDescription]);
                     
                     dispatch_async(dispatch_get_main_queue(), ^{
                         
                         unlink([prevMovieURL.path UTF8String]);

                         [[SHKActivityIndicator currentIndicator] performSelectorOnMainThread:@selector(hide) withObject:nil waitUntilDone:NO];
                         
                         if (isPreview) //preview
                         {
                             if ([self.delegate respondsToSelector:@selector(didFailedPreview)])
                             {
                                 [self.delegate didFailedPreview];
                             }
                         }
                         else   //output faield
                         {
                             if ([self.delegate respondsToSelector:@selector(didFailedOutput)])
                             {
                                 [self.delegate didFailedOutput];
                             }
                         }
                     });
                 }
                     break;
                     
                 case AVAssetExportSessionStatusCancelled:
                 {
                     NSLog(@"merge input videos - canceled");
                     
                     dispatch_async(dispatch_get_main_queue(), ^{
                         
                         unlink([prevMovieURL.path UTF8String]);

                         [[SHKActivityIndicator currentIndicator] performSelectorOnMainThread:@selector(hide) withObject:nil waitUntilDone:NO];
                         
                         if (isPreview)     //preview
                         {
                             if ([self.delegate respondsToSelector:@selector(didFailedPreview)])
                             {
                                 [self.delegate didFailedPreview];
                             }
                         }
                         else   //output faield
                         {
                             if ([self.delegate respondsToSelector:@selector(didFailedOutput)])
                             {
                                 [self.delegate didFailedOutput];
                             }
                         }
                     });
                 }
                     break;
                     
                 default:
                 {
                     dispatch_async(dispatch_get_main_queue(), ^{
                         
                         self.exporter = nil;
                         
                         unlink([prevMovieURL.path UTF8String]);

                         if (isPreview)
                         {
                             [[SHKActivityIndicator currentIndicator] performSelectorOnMainThread:@selector(hide) withObject:nil waitUntilDone:NO];
                             
                             //make output video from temp videos
                             if ([self.delegate respondsToSelector:@selector(didCompletedPreview)])
                             {
                                 [self.delegate didCompletedPreview];
                             }
                         }
                         else
                         {
                             NSLog(@"Video Save to Photo Album...");
                             
                             [self saveMovieToPhotoAlbum];
                             
                             if ([self.delegate respondsToSelector:@selector(saveToAlbumProgress)])
                                 [self.delegate saveToAlbumProgress];
                         }
                         
                     });
                 }
                     break;
             }
         }];
    }
    else // objects (0, index-1) are videos+photos.
    {
        self.currentProcessingIdx = index;
        NSMutableArray *allAudioParams = [[NSMutableArray alloc] init];
        NSURL* prevMovieURL = [NSURL fileURLWithPath:self.pathToMovie];
        AVURLAsset* prevAsset = [AVURLAsset assetWithURL:prevMovieURL];
        
        for (int i=self.currentProcessingIdx-1; i>=prevIdx; i--)
        {
            @autoreleasepool
            {
                MediaObjectView* object = [self.objectArray objectAtIndex:i];
                
                if ((object.mediaType == MEDIA_VIDEO)||(object.mediaType == MEDIA_GIF))
                {
                    AVURLAsset* inputAsset = [AVURLAsset assetWithURL:object.mediaUrl];
                    
                    if(inputAsset != nil)
                    {
                        //duration
                        CMTime duration = inputAsset.duration;
                        
                        //VIDEO TRACK
                        AVMutableCompositionTrack *videoTrack = [self.mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
                        
                        videoTrack = [self setVideoTrackTimeRange:inputAsset object:object track:videoTrack];
                        
                        if (object.isExistAudioTrack)
                        {
                            //AUDIO TRACK
                            NSArray *audioDataSourceArray = [NSArray arrayWithArray: [inputAsset tracksWithMediaType:AVMediaTypeAudio]];
                            if ([audioDataSourceArray count] > 0)
                            {
                                AVMutableCompositionTrack *audioTrack = [self.mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
                                
                                audioTrack = [self setAudioTrackTimeRange:inputAsset object:object track:audioTrack];
                                
                                //volume
                                CGFloat volume = [object getVolume];
                                
                                AVMutableAudioMixInputParameters *params;
                                params = [AVMutableAudioMixInputParameters audioMixInputParameters];
                                [params setVolume:volume atTime:kCMTimeZero];
                                [params setTrackID:[audioTrack trackID]];
                                [allAudioParams addObject:params];
                            }
                        }
                        
                        //fix orientation, transform//
                        AVMutableVideoCompositionLayerInstruction *layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
                        
                        AVAssetTrack *assetTrack = [[inputAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
                        
                        CGRect cropRect = object.normalFilterVideoCropRect;
                        [layerInstruction setCropRectangle:cropRect atTime:kCMTimeZero];
                        
                        CGAffineTransform transform = object.nationalVideoTransformOutputValue;
                        transform = CGAffineTransformScale(transform, outputScaleFactor, outputScaleFactor);
                        transform = CGAffineTransformMake(transform.a, transform.b, transform.c, transform.d, transform.tx*outputScaleFactor, transform.ty*outputScaleFactor);
                        [layerInstruction setTransform:CGAffineTransformConcat(assetTrack.preferredTransform, transform) atTime:kCMTimeZero];
                        
                        CGFloat totalDuration = [object getVideoTotalDuration];
                        
                        if ((object.mfStartPosition + totalDuration) > grNormalFilterOutputTotalTime)
                        {
                            [layerInstruction setOpacity:0.0 atTime:CMTimeMake(grNormalFilterOutputTotalTime*inputAsset.duration.timescale, inputAsset.duration.timescale)];
                        }
                        else
                        {
                            [layerInstruction setOpacity:0.0 atTime:CMTimeMake((object.mfStartPosition + totalDuration)*duration.timescale, duration.timescale)];
                        }
                        
                        // video animations - 2014/02/03 by Yinjing Li
                        layerInstruction = [self setVideoAnimation:layerInstruction mediaObject:object asset:inputAsset];
                        
                        [self.layerInstructionArray addObject:layerInstruction];
                    }
                    
                    inputAsset = nil;
                }
                else if (object.mediaType == MEDIA_MUSIC)
                {
                    AVURLAsset* inputAsset = [AVURLAsset assetWithURL:object.mediaUrl];
                    
                    if(inputAsset != nil)
                    {
                        //AUDIO TRACK
                        NSArray *audioDataSourceArray = [NSArray arrayWithArray: [inputAsset tracksWithMediaType:AVMediaTypeAudio]];
                        if ([audioDataSourceArray count] > 0)
                        {
                            AVMutableCompositionTrack *audioTrack = [self.mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
                            
                            CMTime startTimeOnComposition = CMTimeMake(object.mfStartPosition * inputAsset.duration.timescale, inputAsset.duration.timescale);
                            
                            for (int i=0; i<object.motionArray.count; i++)
                            {
                                NSError *error = nil;
                                
                                NSNumber* motionNum = [object.motionArray objectAtIndex:i];
                                NSNumber* startPosNum = [object.startPositionArray objectAtIndex:i];
                                NSNumber* endPosNum = [object.endPositionArray objectAtIndex:i];
                                
                                CGFloat motionValue = [motionNum floatValue];
                                CGFloat startPosition = [startPosNum floatValue];
                                CGFloat endPosition = [endPosNum floatValue];
                                
                                CMTime duration = CMTimeMakeWithSeconds((endPosition - startPosition), inputAsset.duration.timescale);
                                
                                [audioTrack insertTimeRange:CMTimeRangeMake(CMTimeMake(startPosition*inputAsset.duration.timescale, inputAsset.duration.timescale), duration)
                                                    ofTrack:[audioDataSourceArray objectAtIndex:0]
                                                     atTime:startTimeOnComposition
                                                      error:&error];
                                if(error)
                                    NSLog(@"Insertion error: %@", error);
                                
                                /************************** slow/fast motion *******************************/
                                if (motionValue != 1.0f)
                                    [audioTrack scaleTimeRange:CMTimeRangeMake(startTimeOnComposition, duration)
                                                    toDuration:CMTimeMake(duration.value/motionValue, inputAsset.duration.timescale)];
                                
                                startTimeOnComposition = CMTimeAdd(startTimeOnComposition, CMTimeMakeWithSeconds((endPosition - startPosition)/motionValue, inputAsset.duration.timescale));
                            }
                            
                            //volume
                            CGFloat volume = [object getVolume];
                            
                            AVMutableAudioMixInputParameters *params;
                            params =[AVMutableAudioMixInputParameters audioMixInputParameters];
                            
                            if ((object.startActionType == ACTION_NONE)&&(object.endActionType == ACTION_NONE)) //[none, none]
                            {
                                [params setVolume:volume atTime:kCMTimeZero];
                            }
                            else if ((object.startActionType != ACTION_NONE)&&(object.endActionType != ACTION_NONE))    //[fade, fade]
                            {
                                [params setVolumeRampFromStartVolume:0.0
                                                         toEndVolume:volume
                                                           timeRange:CMTimeRangeMake(CMTimeMake(object.mfStartPosition*inputAsset.duration.timescale, inputAsset.duration.timescale), CMTimeMake(object.mfStartAnimationDuration*inputAsset.duration.timescale, inputAsset.duration.timescale))];
                                [params setVolumeRampFromStartVolume:volume
                                                         toEndVolume:0.0
                                                           timeRange:CMTimeRangeMake(CMTimeMake((object.mfEndPosition - object.mfEndAnimationDuration)*inputAsset.duration.timescale, inputAsset.duration.timescale), CMTimeMake(object.mfEndAnimationDuration*inputAsset.duration.timescale, inputAsset.duration.timescale))];
                            }
                            else if ((object.startActionType == ACTION_NONE)&&(object.endActionType != ACTION_NONE))    //[none, fade]
                            {
                                [params setVolumeRampFromStartVolume:volume
                                                         toEndVolume:volume
                                                           timeRange:CMTimeRangeMake(CMTimeMake(object.mfStartPosition*inputAsset.duration.timescale, inputAsset.duration.timescale), CMTimeMake(object.mfStartAnimationDuration*inputAsset.duration.timescale, inputAsset.duration.timescale))];
                                [params setVolumeRampFromStartVolume:volume
                                                         toEndVolume:0.0
                                                           timeRange:CMTimeRangeMake(CMTimeMake((object.mfEndPosition - object.mfEndAnimationDuration)*inputAsset.duration.timescale, inputAsset.duration.timescale), CMTimeMake(object.mfEndAnimationDuration*inputAsset.duration.timescale, inputAsset.duration.timescale))];
                                
                            }
                            else if ((object.startActionType != ACTION_NONE)&&(object.endActionType == ACTION_NONE))    //[fade, none]
                            {
                                [params setVolumeRampFromStartVolume:0.0
                                                         toEndVolume:volume
                                                           timeRange:CMTimeRangeMake(CMTimeMake(object.mfStartPosition*inputAsset.duration.timescale, inputAsset.duration.timescale), CMTimeMake(object.mfStartAnimationDuration*inputAsset.duration.timescale, inputAsset.duration.timescale))];
                                [params setVolumeRampFromStartVolume:volume
                                                         toEndVolume:volume
                                                           timeRange:CMTimeRangeMake(CMTimeMake((object.mfEndPosition - object.mfEndAnimationDuration)*inputAsset.duration.timescale, inputAsset.duration.timescale), CMTimeMake(object.mfEndAnimationDuration*inputAsset.duration.timescale, inputAsset.duration.timescale))];
                            }
                            
                            [params setTrackID:[audioTrack trackID]];
                            [allAudioParams addObject:params];
                        }
                    }
                    
                    inputAsset = nil;
                }
            }
        }
        
        if(prevAsset != nil)
        {
            //duration
            CMTime duration = prevAsset.duration;
            
            //VIDEO TRACK
            AVMutableCompositionTrack *videoTrack = [self.mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
            NSArray *videoDataSourceArray = [NSArray arrayWithArray: [prevAsset tracksWithMediaType:AVMediaTypeVideo]];
            NSError *error = nil;
            [videoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, duration)
                                ofTrack:([videoDataSourceArray count]>0)?[videoDataSourceArray objectAtIndex:0]:nil
                                 atTime:kCMTimeZero
                                  error:&error];
            if(error)
                NSLog(@"Insertion error: %@", error);
            
            
            //AUDIO TRACK
            NSArray *audioDataSourceArray = [NSArray arrayWithArray: [prevAsset tracksWithMediaType:AVMediaTypeAudio]];
            if ([audioDataSourceArray count] > 0)
            {
                AVMutableCompositionTrack *audioTrack = [self.mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
                error = nil;
                [audioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, duration)
                                    ofTrack:[audioDataSourceArray objectAtIndex:0]
                                     atTime:kCMTimeZero
                                      error:&error];
                if(error)
                    NSLog(@"Insertion error: %@", error);
                
                //volume
                CGFloat volume = 1.0f;
                
                AVMutableAudioMixInputParameters *params;
                params =[AVMutableAudioMixInputParameters audioMixInputParameters];
                [params setVolumeRampFromStartVolume:volume
                                         toEndVolume:volume
                                           timeRange:CMTimeRangeMake(kCMTimeZero, duration)];
                
                [params setTrackID:[audioTrack trackID]];
                [allAudioParams addObject:params];
            }
            
            //fix orientation, transform//
            AVMutableVideoCompositionLayerInstruction *layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
            
            AVAssetTrack *assetTrack = [[prevAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
            CGAffineTransform transfrom = CGAffineTransformIdentity;
            [layerInstruction setTransform:CGAffineTransformConcat(assetTrack.preferredTransform, transfrom) atTime:kCMTimeZero];
            
            if (duration.value / duration.timescale > grNormalFilterOutputTotalTime)
            {
                duration = CMTimeMake(grNormalFilterOutputTotalTime*duration.timescale, duration.timescale);
            }

            [layerInstruction setOpacity:0.0 atTime:duration];
            
            [self.layerInstructionArray addObject:layerInstruction];
        }
        
        AVMutableAudioMix * audioMix = [AVMutableAudioMix audioMix];
        [audioMix setInputParameters:allAudioParams];
        
        AVMutableVideoCompositionInstruction * MainInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
        CGFloat scale = [self getTimeScale];
        MainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMake(grNormalFilterOutputTotalTime*scale, scale));
        MainInstruction.backgroundColor = [UIColor clearColor].CGColor;
        MainInstruction.layerInstructions = self.layerInstructionArray;
        
        AVMutableVideoComposition *MainCompositionInst = [AVMutableVideoComposition videoComposition];
        MainCompositionInst.instructions = [NSArray arrayWithObject:MainInstruction];
        MainCompositionInst.frameDuration = CMTimeMake(1, grFrameRate);
        MainCompositionInst.renderSize = videoSize;
        
        // photo animations - 2014/02/03 by Yinjing Li
        MainCompositionInst.animationTool = [self setPhotoAnimation:prevIdx index:self.currentProcessingIdx];
        
        if (isPreview)
            self.pathToMovie = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"VideoDreamer-Preview%d.m4v", self.currentProcessingIdx]];
        else
            self.pathToMovie = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"VideoDreamer%d.m4v", self.currentProcessingIdx]];
        
        unlink([self.pathToMovie UTF8String]); // If a file already exists, AVAssetWriter won't let you record new frames, so delete the old movie
        NSURL *url = [NSURL fileURLWithPath:self.pathToMovie];
        
        if (self.exporter != nil)
            self.exporter = nil;
        
        self.exporter = [[AVAssetExportSession alloc] initWithAsset:self.mixComposition presetName:AVAssetExportPresetHighestQuality];
        self.exporter.outputURL = url;
        self.exporter.outputFileType = AVFileTypeQuickTimeMovie;
        self.exporter.videoComposition = MainCompositionInst;
        [self.exporter setAudioMix:audioMix];//for volume
        
        if (isPreview && (grNormalFilterOutputTotalTime > grPreviewDuration))
            self.exporter.timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMake(grPreviewDuration*scale, scale));
        else
            self.exporter.timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMake(grNormalFilterOutputTotalTime*scale, scale));
        
        self.exporter.shouldOptimizeForNetworkUse = YES;
        
        //normal processing progress bar
        mnProcessingIndex++;

        dispatch_async(dispatch_get_main_queue(), ^{
            
            if ([self.delegate respondsToSelector:@selector(startAllNormalProgress:current:total:)])
                [self.delegate startAllNormalProgress:self.exporter current:mnProcessingIndex total:mnProcessingCount];
            
        });
        
        [self.exporter exportAsynchronouslyWithCompletionHandler:^
         {
             switch ([self.exporter status])
             {
                 case AVAssetExportSessionStatusFailed:
                 {
                     NSLog(@"merge input videos - failed: %@", [[self.exporter error] localizedDescription]);
                     
                     dispatch_async(dispatch_get_main_queue(), ^{
                         
                         unlink([prevMovieURL.path UTF8String]);

                         [[SHKActivityIndicator currentIndicator] performSelectorOnMainThread:@selector(hide) withObject:nil waitUntilDone:NO];

                         [self removeAllObjects];

                         if (isPreview)     //preview
                         {
                             if ([self.delegate respondsToSelector:@selector(didFailedPreview)])
                             {
                                 [self.delegate didFailedPreview];
                             }
                         }
                         else   //output faield
                         {
                             if ([self.delegate respondsToSelector:@selector(didFailedOutput)])
                             {
                                 [self.delegate didFailedOutput];
                             }
                         }
                     });
                 }
                     break;
                     
                 case AVAssetExportSessionStatusCancelled:
                 {
                     NSLog(@"merge input videos - canceled");
                     
                     dispatch_async(dispatch_get_main_queue(), ^{
                         
                         unlink([prevMovieURL.path UTF8String]);

                         [[SHKActivityIndicator currentIndicator] performSelectorOnMainThread:@selector(hide) withObject:nil waitUntilDone:NO];
                         
                         [self removeAllObjects];

                         if (isPreview)     //preview
                         {
                             if ([self.delegate respondsToSelector:@selector(didFailedPreview)])
                             {
                                 [self.delegate didFailedPreview];
                             }
                         }
                         else   //output faield
                         {
                             if ([self.delegate respondsToSelector:@selector(didFailedOutput)])
                             {
                                 [self.delegate didFailedOutput];
                             }
                         }
                     });
                 }
                     break;
                     
                 default:
                 {
                     dispatch_async(dispatch_get_main_queue(), ^{
                         
                         unlink([prevMovieURL.path UTF8String]);
                         
                         [self performSelectorOnMainThread:@selector(nextNormalFilter) withObject:nil waitUntilDone:NO];
                     });
                 }
                     break;
             }
         }];
    }
}

- (void) firstPhotoToVideo:(MediaObjectView*) firstObject
{
    UIImage* frameImage = nil;

    if (firstObject.mediaType == MEDIA_PHOTO)
        frameImage = firstObject.renderedImage;
    else if (firstObject.mediaType == MEDIA_TEXT)
        frameImage = [firstObject renderingTextView];

    
    NSUInteger fps = 1;
    NSError *error = nil;
    
    if (isPreview)
    {
        self.pathToMovie = [NSTemporaryDirectory() stringByAppendingPathComponent:@"VideoDreamer-Preview-FirstPhoto.m4v"];
    }
    else
    {
        self.pathToMovie = [NSTemporaryDirectory() stringByAppendingPathComponent:@"VideoDreamer-FirstPhoto.m4v"];
    }
    
    unlink([self.pathToMovie UTF8String]); // If a file already exists, AVAssetWriter won't let you record new frames, so delete the old movie
    
    
    self.videoWriter = [[AVAssetWriter alloc] initWithURL:
                         [NSURL fileURLWithPath:self.pathToMovie] fileType:AVFileTypeQuickTimeMovie
                                                     error:&error];
    NSParameterAssert(self.videoWriter);
    
    NSDictionary *videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                   AVVideoCodecH264, AVVideoCodecKey,
                                   [NSNumber numberWithInt:videoSize.width], AVVideoWidthKey,
                                   [NSNumber numberWithInt:videoSize.height], AVVideoHeightKey,
                                   nil];
    
    AVAssetWriterInput* videoWriterInput = [AVAssetWriterInput
                                            assetWriterInputWithMediaType:AVMediaTypeVideo
                                            outputSettings:videoSettings];
    
    AVAssetWriterInputPixelBufferAdaptor *adaptor = [AVAssetWriterInputPixelBufferAdaptor
                                                     assetWriterInputPixelBufferAdaptorWithAssetWriterInput:videoWriterInput
                                                     sourcePixelBufferAttributes:nil];
    
    NSParameterAssert(videoWriterInput);
    NSParameterAssert([self.videoWriter canAddInput:videoWriterInput]);
    videoWriterInput.expectsMediaDataInRealTime = YES;
    [self.videoWriter addInput:videoWriterInput];
    [self.videoWriter startWriting];
    [self.videoWriter startSessionAtSourceTime:kCMTimeZero];
    
    CVPixelBufferRef buffer = [self pixelBufferFromCGImage:[frameImage CGImage] size:videoSize];
    
    int frameCount = 0;
    float duration = firstObject.mfEndPosition - firstObject.mfStartPosition;
    
    for (int i=0; i< (int)duration+1; i++)
    {
        BOOL append_ok = NO;
        int j = 0;
        
        while (!append_ok && j < 1)
        {
            if (adaptor.assetWriterInput.readyForMoreMediaData)
            {
                CMTime frameTime = CMTimeMake(frameCount*fps,(int32_t) fps);
                append_ok = [adaptor appendPixelBuffer:buffer withPresentationTime:frameTime];
                
                if(!append_ok)
                {
                    NSError *error = self.videoWriter.error;
                    
                    if(error!=nil)
                    {
                        NSLog(@"Unresolved error %@,%@.", error, [error userInfo]);
                    }
                }
            }
            else
            {
                [NSThread sleepForTimeInterval:0.1];
            }
            
            j++;
        }
        
        frameCount++;
    }
    
    CVPixelBufferRelease(buffer);
    frameImage = nil;
    
    [videoWriterInput markAsFinished];
    
    [self.videoWriter finishWritingWithCompletionHandler:^{
        
        if (self.videoWriter.status != AVAssetWriterStatusFailed && self.videoWriter.status == AVAssetWriterStatusCompleted)
        {
            self.videoWriter = nil;
            
            [self performSelectorOnMainThread:@selector(procNormalFilterFromFirstPhoto) withObject:nil waitUntilDone:NO];
        }
        else
        {
            NSLog(@"photos to video is failed!");
            self.videoWriter = nil;
        }
    }];
}

- (void) procNormalFilterFromFirstPhoto
{
    NSURL* prevMovieURL = [NSURL fileURLWithPath:self.pathToMovie];
    AVURLAsset* prevAsset = [AVURLAsset assetWithURL:prevMovieURL];
    CMTime duration = prevAsset.duration;
    NSMutableArray *allAudioParams = [[NSMutableArray alloc] init];
    
    for (int i=self.currentProcessingIdx-1; i>0; i--)
    {
        @autoreleasepool
        {
            MediaObjectView* object = [self.objectArray objectAtIndex:i];
            
            if ((object.mediaType == MEDIA_VIDEO)||(object.mediaType == MEDIA_GIF))
            {
                AVURLAsset* inputAsset = [AVURLAsset assetWithURL:object.mediaUrl];
                
                if(inputAsset != nil)
                {
                    //duration
                    CMTime duration = inputAsset.duration;
                    
                    //VIDEO TRACK
                    AVMutableCompositionTrack *videoTrack = [self.mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
                    
                    videoTrack = [self setVideoTrackTimeRange:inputAsset object:object track:videoTrack];
                    
                    if (object.isExistAudioTrack)
                    {
                        //AUDIO TRACK
                        NSArray *audioDataSourceArray = [NSArray arrayWithArray: [inputAsset tracksWithMediaType:AVMediaTypeAudio]];
                        if ([audioDataSourceArray count] > 0)
                        {
                            AVMutableCompositionTrack *audioTrack = [self.mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
                            
                            audioTrack = [self setAudioTrackTimeRange:inputAsset object:object track:audioTrack];
                            
                            //volume
                            CGFloat volume = [object getVolume];
                            
                            AVMutableAudioMixInputParameters *params;
                            params =[AVMutableAudioMixInputParameters audioMixInputParameters];
                            [params setVolume:volume atTime:kCMTimeZero];
                            [params setTrackID:[audioTrack trackID]];
                            [allAudioParams addObject:params];
                        }
                    }
                    
                    //fix orientation, transform//
                    AVMutableVideoCompositionLayerInstruction *layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
                    
                    AVAssetTrack *assetTrack = [[inputAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
                    
                    CGRect cropRect = object.normalFilterVideoCropRect;
                    [layerInstruction setCropRectangle:cropRect atTime:kCMTimeZero];
                    
                    CGAffineTransform transform = object.nationalVideoTransformOutputValue;
                    transform = CGAffineTransformScale(transform, outputScaleFactor, outputScaleFactor);
                    transform = CGAffineTransformMake(transform.a, transform.b, transform.c, transform.d, transform.tx*outputScaleFactor, transform.ty*outputScaleFactor);
                    [layerInstruction setTransform:CGAffineTransformConcat(assetTrack.preferredTransform, transform) atTime:kCMTimeZero];
                    
                    if ((object.mfStartPosition*duration.timescale + duration.value) / duration.timescale > grNormalFilterOutputTotalTime)
                    {
                        [layerInstruction setOpacity:0.0 atTime:CMTimeMake(grNormalFilterOutputTotalTime*duration.timescale, duration.timescale)];
                    }
                    else
                    {
                        [layerInstruction setOpacity:0.0 atTime:CMTimeMake((object.mfStartPosition*duration.timescale + duration.value), duration.timescale)];
                    }
                    
                    // video animations - 2014/02/03 by Yinjing Li
                    layerInstruction = [self setVideoAnimation:layerInstruction mediaObject:object asset:inputAsset];
                    
                    [self.layerInstructionArray addObject:layerInstruction];
                }
                
                inputAsset = nil;
            }
            else if (object.mediaType == MEDIA_MUSIC)
            {
                AVURLAsset* inputAsset = [AVURLAsset assetWithURL:object.mediaUrl];
                
                if(inputAsset != nil)
                {
                    //AUDIO TRACK
                    NSArray *audioDataSourceArray = [NSArray arrayWithArray: [inputAsset tracksWithMediaType:AVMediaTypeAudio]];
                    
                    if ([audioDataSourceArray count] > 0)
                    {
                        AVMutableCompositionTrack *audioTrack = [self.mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
                        
                        CMTime startTimeOnComposition = CMTimeMake(object.mfStartPosition * inputAsset.duration.timescale, inputAsset.duration.timescale);
                        
                        for (int i=0; i<object.motionArray.count; i++)
                        {
                            NSError *error = nil;
                            
                            NSNumber* motionNum = [object.motionArray objectAtIndex:i];
                            NSNumber* startPosNum = [object.startPositionArray objectAtIndex:i];
                            NSNumber* endPosNum = [object.endPositionArray objectAtIndex:i];
                            
                            CGFloat motionValue = [motionNum floatValue];
                            CGFloat startPosition = [startPosNum floatValue];
                            CGFloat endPosition = [endPosNum floatValue];
                            
                            CMTime duration = CMTimeMakeWithSeconds((endPosition - startPosition), inputAsset.duration.timescale);
                            
                            [audioTrack insertTimeRange:CMTimeRangeMake(CMTimeMake(startPosition*inputAsset.duration.timescale, inputAsset.duration.timescale), duration)
                                                ofTrack:[audioDataSourceArray objectAtIndex:0]
                                                 atTime:startTimeOnComposition
                                                  error:&error];
                            if(error)
                                NSLog(@"Insertion error: %@", error);
                            
                            /************************** slow/fast motion *******************************/
                            if (motionValue != 1.0f)
                                [audioTrack scaleTimeRange:CMTimeRangeMake(startTimeOnComposition, duration)
                                                toDuration:CMTimeMake(duration.value/motionValue, inputAsset.duration.timescale)];
                            
                            startTimeOnComposition = CMTimeAdd(startTimeOnComposition, CMTimeMakeWithSeconds((endPosition - startPosition)/motionValue, inputAsset.duration.timescale));
                        }
                        
                        //volume
                        CGFloat volume = [object getVolume];
                        
                        AVMutableAudioMixInputParameters *params;
                        params =[AVMutableAudioMixInputParameters audioMixInputParameters];
                        
                        if ((object.startActionType == ACTION_NONE)&&(object.endActionType == ACTION_NONE)) //[none, none]
                        {
                            [params setVolume:volume atTime:kCMTimeZero];
                        }
                        else if ((object.startActionType != ACTION_NONE)&&(object.endActionType != ACTION_NONE))    //[fade, fade]
                        {
                            [params setVolumeRampFromStartVolume:0.0
                                                     toEndVolume:volume
                                                       timeRange:CMTimeRangeMake(CMTimeMake(object.mfStartPosition*inputAsset.duration.timescale, inputAsset.duration.timescale), CMTimeMake(object.mfStartAnimationDuration*inputAsset.duration.timescale, inputAsset.duration.timescale))];
                            [params setVolumeRampFromStartVolume:volume
                                                     toEndVolume:0.0
                                                       timeRange:CMTimeRangeMake(CMTimeMake((object.mfEndPosition - object.mfEndAnimationDuration)*inputAsset.duration.timescale, inputAsset.duration.timescale), CMTimeMake(object.mfEndAnimationDuration*inputAsset.duration.timescale, inputAsset.duration.timescale))];
                        }
                        else if ((object.startActionType == ACTION_NONE)&&(object.endActionType != ACTION_NONE))    //[none, fade]
                        {
                            [params setVolumeRampFromStartVolume:volume
                                                     toEndVolume:volume
                                                       timeRange:CMTimeRangeMake(CMTimeMake(object.mfStartPosition*inputAsset.duration.timescale, inputAsset.duration.timescale), CMTimeMake(object.mfStartAnimationDuration*inputAsset.duration.timescale, inputAsset.duration.timescale))];
                            [params setVolumeRampFromStartVolume:volume
                                                     toEndVolume:0.0
                                                       timeRange:CMTimeRangeMake(CMTimeMake((object.mfEndPosition - object.mfEndAnimationDuration)*inputAsset.duration.timescale, inputAsset.duration.timescale), CMTimeMake(object.mfEndAnimationDuration*inputAsset.duration.timescale, inputAsset.duration.timescale))];
                        }
                        else if ((object.startActionType != ACTION_NONE)&&(object.endActionType == ACTION_NONE))    //[fade, none]
                        {
                            [params setVolumeRampFromStartVolume:0.0
                                                     toEndVolume:volume
                                                       timeRange:CMTimeRangeMake(CMTimeMake(object.mfStartPosition*inputAsset.duration.timescale, inputAsset.duration.timescale), CMTimeMake(object.mfStartAnimationDuration*inputAsset.duration.timescale, inputAsset.duration.timescale))];
                            [params setVolumeRampFromStartVolume:volume
                                                     toEndVolume:volume
                                                       timeRange:CMTimeRangeMake(CMTimeMake((object.mfEndPosition - object.mfEndAnimationDuration)*inputAsset.duration.timescale, inputAsset.duration.timescale), CMTimeMake(object.mfEndAnimationDuration*inputAsset.duration.timescale, inputAsset.duration.timescale))];
                        }
                        
                        [params setTrackID:[audioTrack trackID]];
                        [allAudioParams addObject:params];
                    }
                }
                
                inputAsset = nil;
            }
        }
    }
    
    MediaObjectView* prevObject = [self.objectArray objectAtIndex:0];
    
    if(prevAsset != nil)
    {
        //VIDEO TRACK
        AVMutableCompositionTrack *videoTrack = [self.mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        NSArray *videoDataSourceArray = [NSArray arrayWithArray: [prevAsset tracksWithMediaType:AVMediaTypeVideo]];
        NSError *error = nil;
        [videoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, prevAsset.duration)
                            ofTrack:([videoDataSourceArray count]>0)?[videoDataSourceArray objectAtIndex:0]:nil
                             atTime:CMTimeMake(prevObject.mfStartPosition*prevAsset.duration.timescale, prevAsset.duration.timescale)
                              error:&error];

        if(error)
            NSLog(@"Insertion error: %@", error);
        
        //AUDIO TRACK
        NSArray *audioDataSourceArray = [NSArray arrayWithArray: [prevAsset tracksWithMediaType:AVMediaTypeAudio]];
        if ([audioDataSourceArray count] > 0)
        {
            AVMutableCompositionTrack *audioTrack = [self.mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
            error = nil;
            [audioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, prevAsset.duration)
                                ofTrack:[audioDataSourceArray objectAtIndex:0]
                                 atTime:CMTimeMake(prevObject.mfStartPosition*prevAsset.duration.timescale, prevAsset.duration.timescale)
                                  error:&error];

            if(error)
                NSLog(@"Insertion error: %@", error);
            
            //volume
            CGFloat volume = 1.0;
            
            AVMutableAudioMixInputParameters *params;
            params =[AVMutableAudioMixInputParameters audioMixInputParameters];
            [params setVolumeRampFromStartVolume:volume
                                     toEndVolume:volume
                                       timeRange:CMTimeRangeMake(kCMTimeZero, duration)];
            
            [params setTrackID:[audioTrack trackID]];
            [allAudioParams addObject:params];
            
        }
        
        //fix orientation, transform//
        AVMutableVideoCompositionLayerInstruction *layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
        
        AVAssetTrack *assetTrack = [[prevAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
        
        CGAffineTransform transfrom = CGAffineTransformIdentity;
        [layerInstruction setTransform:CGAffineTransformConcat(assetTrack.preferredTransform, transfrom) atTime:kCMTimeZero];
        [layerInstruction setOpacity:0.0 atTime:kCMTimeZero];
        
        [self.layerInstructionArray addObject:layerInstruction];
    }
    
    AVMutableVideoCompositionInstruction * MainInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    MainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMake(grNormalFilterOutputTotalTime*prevAsset.duration.timescale, prevAsset.duration.timescale));
    MainInstruction.backgroundColor = [UIColor clearColor].CGColor;
    MainInstruction.layerInstructions = self.layerInstructionArray;
    
    AVMutableVideoComposition *MainCompositionInst = [AVMutableVideoComposition videoComposition];
    MainCompositionInst.instructions = [NSArray arrayWithObject:MainInstruction];
    MainCompositionInst.frameDuration = CMTimeMake(1, grFrameRate);
    MainCompositionInst.renderSize = videoSize;
    
    // photo animations - 2014/02/03 by Yinjing Li
    MainCompositionInst.animationTool = [self setPhotoAnimation:0 index:self.currentProcessingIdx];
    
    if (self.currentProcessingIdx == self.objectArray.count)
    {
        if (isPreview)
            self.pathToMovie = [NSTemporaryDirectory() stringByAppendingPathComponent:@"VideoDreamer-Preview.m4v"];
        else
            self.pathToMovie = [NSTemporaryDirectory() stringByAppendingPathComponent:@"VideoDreamer.m4v"];
    }
    else
    {
        if (isPreview)
            self.pathToMovie = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"VideoDreamer-Preview%d.m4v", self.currentProcessingIdx]];
        else
            self.pathToMovie = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"VideoDreamer%d.m4v", self.currentProcessingIdx]];
    }
    
    unlink([self.pathToMovie UTF8String]); // If a file already exists, AVAssetWriter won't let you record new frames, so delete the old movie
    NSURL *url = [NSURL fileURLWithPath:self.pathToMovie];
    
    if (self.exporter != nil)
        self.exporter = nil;
    
    self.exporter = [[AVAssetExportSession alloc] initWithAsset:self.mixComposition presetName:AVAssetExportPresetHighestQuality];
    self.exporter.outputURL = url;
    self.exporter.outputFileType = AVFileTypeQuickTimeMovie;
    self.exporter.videoComposition = MainCompositionInst;
    
    if (allAudioParams.count > 0)
    {
        AVMutableAudioMix * audioMix = [AVMutableAudioMix audioMix];
        [audioMix setInputParameters:allAudioParams];
        
        [self.exporter setAudioMix:audioMix];//for volume
    }

    if (isPreview && (grNormalFilterOutputTotalTime > grPreviewDuration))
        self.exporter.timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMake(grPreviewDuration*prevAsset.duration.timescale, prevAsset.duration.timescale));
    else
        self.exporter.timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMake(grNormalFilterOutputTotalTime*prevAsset.duration.timescale, prevAsset.duration.timescale));
    
    self.exporter.shouldOptimizeForNetworkUse = YES;
    
    //normal processing progress bar
    mnProcessingIndex++;

    dispatch_async(dispatch_get_main_queue(), ^{
        
        if ([self.delegate respondsToSelector:@selector(startAllNormalProgress:current:total:)])
            [self.delegate startAllNormalProgress:self.exporter current:mnProcessingIndex total:mnProcessingCount];
        
    });
    
    prevAsset = nil;
    
    [self.exporter exportAsynchronouslyWithCompletionHandler:^
     {
         switch ([self.exporter status])
         {
             case AVAssetExportSessionStatusFailed:
             {
                 NSLog(@"merge input videos - failed: %@", [[self.exporter error] localizedDescription]);
                 
                 dispatch_async(dispatch_get_main_queue(), ^{

                     unlink([prevMovieURL.path UTF8String]);
                     
                     [[SHKActivityIndicator currentIndicator] hide];
                     
                     [self removeAllObjects];

                     if (isPreview) //preview
                     {
                         if ([self.delegate respondsToSelector:@selector(didFailedPreview)])
                         {
                             [self.delegate didFailedPreview];
                         }
                     }
                     else   //output faield
                     {
                         if ([self.delegate respondsToSelector:@selector(didFailedOutput)])
                         {
                             [self.delegate didFailedOutput];
                         }
                     }
                     
                 });
             }
                 break;
             case AVAssetExportSessionStatusCancelled:
             {
                 NSLog(@"merge input videos - canceled");
                 
                 dispatch_async(dispatch_get_main_queue(), ^{
                     
                     unlink([prevMovieURL.path UTF8String]);

                     [[SHKActivityIndicator currentIndicator] hide];
                     
                     [self removeAllObjects];

                     if (isPreview) //preview
                     {
                         if ([self.delegate respondsToSelector:@selector(didFailedPreview)])
                         {
                             [self.delegate didFailedPreview];
                         }
                     }
                     else   //output faield
                     {
                         if ([self.delegate respondsToSelector:@selector(didFailedOutput)])
                         {
                             [self.delegate didFailedOutput];
                         }
                     }
                     
                 });
             }
                 break;
             default:
             {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     
                     unlink([prevMovieURL.path UTF8String]);
                     
                     if (self.currentProcessingIdx == self.objectArray.count)
                     {
                         self.exporter = nil;
                         
                         [self removeAllObjects];
                         
                         if (isPreview)
                         {
                             [[SHKActivityIndicator currentIndicator] hide];
                             
                             unlink([prevMovieURL.path UTF8String]);
                             
                             //make output video from temp videos
                             if ([self.delegate respondsToSelector:@selector(didCompletedPreview)])
                             {
                                 [self.delegate didCompletedPreview];
                             }
                         }
                         else
                         {
                             NSLog(@"Video Save to Photo Album...");
                             
                             unlink([prevMovieURL.path UTF8String]);
                         
                             [self saveMovieToPhotoAlbum];
                             
                             if ([self.delegate respondsToSelector:@selector(saveToAlbumProgress)])
                                 [self.delegate saveToAlbumProgress];
                         }
                     }
                     else
                     {
                         [self performSelectorOnMainThread:@selector(nextNormalFilter) withObject:nil waitUntilDone:NO];
                     }
                     
                 });
             }
                 break;
         }
     }];
}


-(int) getProgressTotalCountInFirstVideo
{
    int totalCount = 0;
    BOOL isVideo = NO;
    BOOL isPrevVideo = NO;
    int limitCount = 0;
    
    for (MediaObjectView* object in self.objectArray)
    {
        if (((object.mediaType == MEDIA_VIDEO)||(object.mediaType == MEDIA_GIF)) && !isVideo)
        {
            if (limitCount != 0)
            {
                limitCount = 0;
                
                if(isPrevVideo)
                    totalCount++;
            }
            
            totalCount++;
            isVideo = YES;
            
        }
        else if ((object.mediaType == MEDIA_PHOTO)||(object.mediaType == MEDIA_TEXT))
        {
            if (isVideo)
            {
                isVideo = NO;
                isPrevVideo = YES;
            }
            
            if ((object.startActionType == ACTION_EXPLODE)||
                ((object.startActionType >= ACTION_GENIE_BL)&&(object.startActionType <= ACTION_GENIE_TR))||
                (object.startActionType == ACTION_SWAP_ALL)||
                (object.startActionType == ACTION_ZOOM_ALL)||
                (object.endActionType == ACTION_EXPLODE)||
                ((object.endActionType >= ACTION_GENIE_BL)&&(object.endActionType <= ACTION_GENIE_TR))||
                (object.endActionType == ACTION_SWAP_ALL)||
                (object.endActionType == ACTION_ZOOM_ALL))
            {
                limitCount++;
            }
            
            if (limitCount >= PHOTO_COMPOSITING_MAX_COUNT)
            {
                isPrevVideo = NO;
                limitCount = 0;
                totalCount++;
            }
        }
        else if(isVideo)
        {
            isVideo = NO;
            isPrevVideo = YES;
        }
    }
    
    return totalCount;
}

- (int) getFirstProcessingIndexWhenFirstObjectIsVideo
{
    int index = 0;
    int photoTextCount = 0;
    BOOL isProcessingStart = NO;
    
    while (!isProcessingStart)
    {
        MediaObjectView* object = [self.objectArray objectAtIndex:index];
        
        if ((object.mediaType == MEDIA_VIDEO)||(object.mediaType == MEDIA_GIF)||(object.mediaType == MEDIA_MUSIC))
        {
            index++;
            
            if (index == self.objectArray.count)
            {
                isProcessingStart = YES;
            }
            else if (index >= VIDEO_COMPOSITING_MAX_COUNT)
            {
                isProcessingStart = YES;
            }
        }
        else if ((object.mediaType == MEDIA_PHOTO)||(object.mediaType == MEDIA_TEXT))
        {
            BOOL isVideo = NO;
            
            while (!isVideo)
            {
                MediaObjectView* object_ = [self.objectArray objectAtIndex:index];
                
                if ((object_.mediaType == MEDIA_VIDEO)||(object_.mediaType == MEDIA_GIF))
                {
                    isVideo = YES;
                    isProcessingStart = YES;
                }
                else if ((object_.mediaType == MEDIA_PHOTO)||(object_.mediaType == MEDIA_TEXT)||(object_.mediaType == MEDIA_MUSIC))
                {
                    index++;
                    
                    if ((object_.mediaType == MEDIA_PHOTO)||(object_.mediaType == MEDIA_TEXT))
                    {
                        if ((object_.startActionType == ACTION_EXPLODE)||
                            ((object_.startActionType >= ACTION_GENIE_BL)&&(object_.startActionType <= ACTION_GENIE_TR))||
                            (object_.startActionType == ACTION_SWAP_ALL)||
                            (object_.startActionType == ACTION_ZOOM_ALL)||
                            (object_.endActionType == ACTION_EXPLODE)||
                            ((object_.endActionType >= ACTION_GENIE_BL)&&(object_.endActionType <= ACTION_GENIE_TR))||
                            (object_.endActionType == ACTION_SWAP_ALL)||
                            (object_.endActionType == ACTION_ZOOM_ALL))
                        {
                            photoTextCount++;
                        }
                    }
                    
                    if (index == self.objectArray.count)
                    {
                        isVideo = YES;
                        isProcessingStart = YES;
                    }
                    else if (photoTextCount >= PHOTO_COMPOSITING_MAX_COUNT)
                    {
                        isVideo = YES;
                        isProcessingStart = YES;
                    }
                }
            }
        }
    }
    
    return index;
}

- (int) getFirstProcessingIndexWhenFirstObjectIsPhoto
{
    int index = 0;
    int photoTextCount = 0;
    BOOL isProcessingStart = NO;
    
    while (!isProcessingStart)
    {
        MediaObjectView* object = [self.objectArray objectAtIndex:index];
        
        if ((object.mediaType == MEDIA_PHOTO)||(object.mediaType == MEDIA_TEXT)||(object.mediaType == MEDIA_MUSIC))
        {
            index++;
            
            if ((object.mediaType == MEDIA_PHOTO)||(object.mediaType == MEDIA_TEXT))
            {
                if ((object.startActionType == ACTION_EXPLODE)||
                    ((object.startActionType >= ACTION_GENIE_BL)&&(object.startActionType <= ACTION_GENIE_TR))||
                    (object.startActionType == ACTION_SWAP_ALL)||
                    (object.startActionType == ACTION_ZOOM_ALL)||
                    (object.endActionType == ACTION_EXPLODE)||
                    ((object.endActionType >= ACTION_GENIE_BL)&&(object.endActionType <= ACTION_GENIE_TR))||
                    (object.endActionType == ACTION_SWAP_ALL)||
                    (object.endActionType == ACTION_ZOOM_ALL))
                {
                    photoTextCount++;
                }
            }
            
            if (photoTextCount >= PHOTO_COMPOSITING_MAX_COUNT)
            {
                isProcessingStart = YES;
            }
            
            if (index == self.objectArray.count)
            {
                isProcessingStart = YES;
            }
        }
        else if ((object.mediaType == MEDIA_VIDEO)||(object.mediaType == MEDIA_GIF))
        {
            isProcessingStart = YES;
        }
    }
    
    return index;
}

- (MediaObjectView*) getFirstObjectFromObjectArray
{
    MediaObjectView* firstObject = [self.objectArray objectAtIndex:0];
    
    /* if first object is a music, move that to last object */
    if (firstObject.mediaType == MEDIA_MUSIC)
    {
        BOOL isProcessingStart = NO;
        
        while (!isProcessingStart)
        {
            MediaObjectView* object = [self.objectArray objectAtIndex:0];
            
            if (object.mediaType != MEDIA_MUSIC)
            {
                isProcessingStart = YES;
                firstObject = [self.objectArray objectAtIndex:0];
            }
            else
            {
                [self.objectArray removeObjectAtIndex:0];
                [self.objectArray addObject:object];
            }
        }
    }
    
    return firstObject;
}



#pragma mark -
#pragma mark - getTotalVideoTime
/*
 * this function is get a total video time for output using a normal filter
 * created by Yinjing Li at 2014/01/12.
 */

- (CGFloat) getTimeScale
{
    CMTime maxDuration= kCMTimeZero;
    
    for (int i=0; i<self.objectArray.count; i++)
    {
        MediaObjectView* object = [self.objectArray objectAtIndex:i];
        
        if ((object.mediaType == MEDIA_VIDEO)||(object.mediaType == MEDIA_GIF))
        {
            AVURLAsset* inputAsset = [AVURLAsset assetWithURL:object.mediaUrl];
            
            if(inputAsset != nil)
            {
                //duration
                CMTime duration = inputAsset.duration;
                float current_duration = (float)duration.value / (float)duration.timescale;
                float max_duration = (float)maxDuration.value / (float)maxDuration.timescale;
                if (current_duration > max_duration) {
                    maxDuration = duration;
                }
            }
        }
    }
    
    return maxDuration.timescale;
}


#pragma mark -
#pragma mark - save video to custom album

- (void) saveMovieToPhotoAlbum
{
    NSURL* videoUrl = [NSURL fileURLWithPath:self.pathToMovie isDirectory:NO];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0f)
    {
        ALAssetsLibrary* library = [[ALAssetsLibrary alloc] init];
        
        [library saveVideo:videoUrl toAlbum:@"Video Dreamer" withCompletionBlock:^(NSError *error)
         {
             dispatch_async(dispatch_get_main_queue(), ^{
                 
                 if ([self.delegate respondsToSelector:@selector(didCompleteProgressbar)]) {
                     [self.delegate didCompleteProgressbar];
                 }
                 
                 if (error!=nil)
                 {
                     NSLog(@"Video Failed!");
                     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Video Saving Failed:%@", [error description]]  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil, nil];
                     [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
                 }
                 else
                 {
                     NSLog(@"Video Saved!");
                     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Video Saved" message:@"Saved To Photo Album"  delegate:self cancelButtonTitle:@"Continue" otherButtonTitles:@"Play", nil];
                     [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
                     
                 }
                 
             });
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
                 PHAssetChangeRequest *videoRequest = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:videoUrl];
                 
                 //Create Album
                 PHAssetCollectionChangeRequest *albumRequest = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:@"Video Dreamer"];
                 
                 //get a placeholder for the new asset and add it to the album editing request
                 PHObjectPlaceholder* assetPlaceholder = [videoRequest placeholderForCreatedAsset];
                 
                 [albumRequest addAssets:@[assetPlaceholder]];
             }
             else //add video to album
             {
                 //create asset
                 PHAssetChangeRequest *videoRequest = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:videoUrl];
                 
                 //change Album
                 PHAssetCollection *assetCollection = (PHAssetCollection *)fetchResult[0];
                 PHAssetCollectionChangeRequest *albumRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:assetCollection];
                 
                 //get a placeholder for the new asset and add it to the album editing request
                 PHObjectPlaceholder* assetPlaceholder = [videoRequest placeholderForCreatedAsset];
                 
                 [albumRequest addAssets:@[assetPlaceholder]];
             }
             
         } completionHandler:^(BOOL success, NSError *error) {
             
             dispatch_async(dispatch_get_main_queue(), ^{

                 if ([self.delegate respondsToSelector:@selector(didCompleteProgressbar)]) {
                     [self.delegate didCompleteProgressbar];
                 }
                 
                 if (error!=nil)
                 {
                     NSLog(@"Video Failed!");
                     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Video Saving Failed:%@", [error description]]  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil, nil];
                     [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
                 }
                 else
                 {
                     NSLog(@"Video Saved!");
                     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Video Saved" message:@"Saved To Photo Album"  delegate:self cancelButtonTitle:@"Continue" otherButtonTitles:@"Play", nil];
                     [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
                     
                 }

             });
         }];
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [[SHKActivityIndicator currentIndicator] performSelectorOnMainThread:@selector(hide) withObject:nil waitUntilDone:NO];

    if (!isFailed) {//completed
        
        if(!isPreview){//output video
            
            if ([self.delegate respondsToSelector:@selector(didCompleteOutput:)]) {
                [self.delegate didCompleteOutput:(int)buttonIndex];
            }
        }
    }
    else{//failed
        if (isPreview) {//preview
            
            if ([self.delegate respondsToSelector:@selector(didFailedPreview)]) {
                [self.delegate didFailedPreview];
            }
        }else{//output faield
            
            if ([self.delegate respondsToSelector:@selector(didFailedOutput)]) {
                [self.delegate didFailedOutput];
            }
        }
    }
}


#pragma mark - 
#pragma mark - Video Animation!!!

- (AVMutableVideoCompositionLayerInstruction*) setVideoAnimation: (AVMutableVideoCompositionLayerInstruction*)layerInstruction mediaObject:(MediaObjectView*) object asset:(AVURLAsset*) inputAsset
{
    CGRect frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
    const CGFloat viewWidth = frame.size.width;
    const CGFloat viewHeight = frame.size.height;

    AVAssetTrack *assetTrack = [[inputAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    CGAffineTransform videoTransfrom = CGAffineTransformIdentity;
    
    if ((object.mediaType == MEDIA_VIDEO)||(object.mediaType == MEDIA_GIF))
    {
        videoTransfrom = object.nationalVideoTransformOutputValue;
        videoTransfrom = CGAffineTransformScale(videoTransfrom, outputScaleFactor, outputScaleFactor);
        videoTransfrom = CGAffineTransformMake(videoTransfrom.a, videoTransfrom.b, videoTransfrom.c, videoTransfrom.d, videoTransfrom.tx*outputScaleFactor, videoTransfrom.ty*outputScaleFactor);
        videoTransfrom = CGAffineTransformConcat(assetTrack.preferredTransform, videoTransfrom);
    }
    else if (object.mediaType == MEDIA_PHOTO)
    {
        videoTransfrom = CGAffineTransformConcat(assetTrack.preferredTransform, videoTransfrom);
    }
   
    //start action
    if (object.startActionType == ACTION_NONE)
    {
        [layerInstruction setOpacity:object.imageView.alpha atTime:CMTimeMake(object.mfStartPosition*inputAsset.duration.timescale, inputAsset.duration.timescale)];
    }
    else if (object.startActionType == ACTION_FADE)
    {
        [layerInstruction setOpacityRampFromStartOpacity:0.0f toEndOpacity:object.imageView.alpha timeRange:CMTimeRangeMake(CMTimeMake(object.mfStartPosition*inputAsset.duration.timescale, inputAsset.duration.timescale), CMTimeMake(object.mfStartAnimationDuration*inputAsset.duration.timescale, inputAsset.duration.timescale))];
    }
    else if (object.startActionType == ACTION_BLACK)
    {
        [layerInstruction setOpacity:0.0f atTime:kCMTimeZero];
        [layerInstruction setOpacityRampFromStartOpacity:0.0f toEndOpacity:object.imageView.alpha timeRange:CMTimeRangeMake(CMTimeMake((object.mfStartPosition+object.mfStartAnimationDuration)*inputAsset.duration.timescale, inputAsset.duration.timescale), CMTimeMake(MIN_DURATION*inputAsset.duration.timescale, inputAsset.duration.timescale))];
    }
    else if ((object.startActionType >= ACTION_ZOOM_BL)&&(object.startActionType <= ACTION_ZOOM_TR))
    {
        CGAffineTransform inTranslationTransform;
        inTranslationTransform = CGAffineTransformConcat(videoTransfrom, CGAffineTransformMakeScale(0.001f, 0.001f));
        
        switch (object.startActionType)
        {
            case ACTION_ZOOM_CC:
                inTranslationTransform = CGAffineTransformMake(inTranslationTransform.a, inTranslationTransform.b, inTranslationTransform.c, inTranslationTransform.d, viewWidth/2, viewHeight/2);
                break;
            case ACTION_ZOOM_RL:
                inTranslationTransform = CGAffineTransformMake(inTranslationTransform.a, inTranslationTransform.b, inTranslationTransform.c, inTranslationTransform.d, viewWidth*1.1f, viewHeight/2);
                break;
            case ACTION_ZOOM_LR:
                inTranslationTransform = CGAffineTransformMake(inTranslationTransform.a, inTranslationTransform.b, inTranslationTransform.c, inTranslationTransform.d, -viewWidth*0.1f, viewHeight/2);
                break;
            case ACTION_ZOOM_TB:
                inTranslationTransform = CGAffineTransformMake(inTranslationTransform.a, inTranslationTransform.b, inTranslationTransform.c, inTranslationTransform.d, viewWidth/2, -viewHeight*0.1f);
                break;
            case ACTION_ZOOM_BT:
                inTranslationTransform = CGAffineTransformMake(inTranslationTransform.a, inTranslationTransform.b, inTranslationTransform.c, inTranslationTransform.d, viewWidth/2, viewHeight*1.1f);
                break;
            case ACTION_ZOOM_BL:
                inTranslationTransform = CGAffineTransformMake(inTranslationTransform.a, inTranslationTransform.b, inTranslationTransform.c, inTranslationTransform.d, -viewWidth*0.1f, viewHeight*1.1f);
                break;
            case ACTION_ZOOM_BR:
                inTranslationTransform = CGAffineTransformMake(inTranslationTransform.a, inTranslationTransform.b, inTranslationTransform.c, inTranslationTransform.d, viewWidth*1.1f, viewHeight*1.1f);
                break;
            case ACTION_ZOOM_TL:
                inTranslationTransform = CGAffineTransformMake(inTranslationTransform.a, inTranslationTransform.b, inTranslationTransform.c, inTranslationTransform.d, -viewWidth*0.1f, -viewHeight*0.1f);
                break;
            case ACTION_ZOOM_TR:
                inTranslationTransform = CGAffineTransformMake(inTranslationTransform.a, inTranslationTransform.b, inTranslationTransform.c, inTranslationTransform.d, viewWidth*1.1f, -viewHeight*0.1f);
                break;

            default:
                break;
        }
        
        [layerInstruction setTransformRampFromStartTransform:inTranslationTransform toEndTransform:videoTransfrom timeRange:CMTimeRangeMake(CMTimeMake(object.mfStartPosition*inputAsset.duration.timescale, inputAsset.duration.timescale), CMTimeMake(object.mfStartAnimationDuration*inputAsset.duration.timescale, inputAsset.duration.timescale))];
    }
    else if ((object.startActionType >= ACTION_SLIDE_BL)&&(object.startActionType <= ACTION_SLIDE_TR))
    {
        ADTransitionOrientation orientation = ADTransitionLeftToRight;
        
        switch (object.startActionType)
        {
            case ACTION_SLIDE_RL:
                orientation = ADTransitionRightToLeft;
                break;
            case ACTION_SLIDE_LR:
                orientation = ADTransitionLeftToRight;
                break;
            case ACTION_SLIDE_TB:
                orientation = ADTransitionTopToBottom;
                break;
            case ACTION_SLIDE_BT:
                orientation = ADTransitionBottomToTop;
                break;
            case ACTION_SLIDE_BL:
                orientation = ADTransitionBottomLeft;
                break;
            case ACTION_SLIDE_BR:
                orientation = ADTransitionBottomRight;
                break;
            case ACTION_SLIDE_TL:
                orientation = ADTransitionTopLeft;
                break;
            case ACTION_SLIDE_TR:
                orientation = ADTransitionTopRight;
                break;
                
            default:
                orientation = ADTransitionRightToLeft;
                break;
        }
        
        CGAffineTransform inTranslationTransform = CGAffineTransformIdentity;
        
        switch (orientation)
        {
            case ADTransitionRightToLeft:
                inTranslationTransform = CGAffineTransformMake(videoTransfrom.a, videoTransfrom.b, videoTransfrom.c, videoTransfrom.d, videoTransfrom.tx+viewWidth, videoTransfrom.ty);
                break;
                
            case ADTransitionLeftToRight:
                inTranslationTransform = CGAffineTransformMake(videoTransfrom.a, videoTransfrom.b, videoTransfrom.c, videoTransfrom.d, videoTransfrom.tx-viewWidth, videoTransfrom.ty);
                break;
                
            case ADTransitionTopToBottom:
                inTranslationTransform = CGAffineTransformMake(videoTransfrom.a, videoTransfrom.b, videoTransfrom.c, videoTransfrom.d, videoTransfrom.tx, videoTransfrom.ty-viewHeight);
                break;
                
            case ADTransitionBottomToTop:
                inTranslationTransform = CGAffineTransformMake(videoTransfrom.a, videoTransfrom.b, videoTransfrom.c, videoTransfrom.d, videoTransfrom.tx, videoTransfrom.ty+viewHeight);
                break;

            case ADTransitionBottomLeft:
                inTranslationTransform = CGAffineTransformMake(videoTransfrom.a, videoTransfrom.b, videoTransfrom.c, videoTransfrom.d, videoTransfrom.tx-viewWidth, videoTransfrom.ty+viewHeight);
                break;

            case ADTransitionBottomRight:
                inTranslationTransform = CGAffineTransformMake(videoTransfrom.a, videoTransfrom.b, videoTransfrom.c, videoTransfrom.d, videoTransfrom.tx+viewWidth, videoTransfrom.ty+viewHeight);
                break;
                
            case ADTransitionTopLeft:
                inTranslationTransform = CGAffineTransformMake(videoTransfrom.a, videoTransfrom.b, videoTransfrom.c, videoTransfrom.d, videoTransfrom.tx-viewWidth, videoTransfrom.ty-viewHeight);
                break;

            case ADTransitionTopRight:
                inTranslationTransform = CGAffineTransformMake(videoTransfrom.a, videoTransfrom.b, videoTransfrom.c, videoTransfrom.d, videoTransfrom.tx+viewWidth, videoTransfrom.ty-viewHeight);
                break;


            default:
                NSAssert(FALSE, @"Unhandled ADTransitionOrientation");
                break;
        }

        [layerInstruction setTransformRampFromStartTransform:inTranslationTransform toEndTransform:videoTransfrom timeRange:CMTimeRangeMake(CMTimeMake(object.mfStartPosition*inputAsset.duration.timescale, inputAsset.duration.timescale), CMTimeMake(object.mfStartAnimationDuration*inputAsset.duration.timescale, inputAsset.duration.timescale))];
    }
    else if ((object.startActionType >= ACTION_SWAP_BL)&&(object.startActionType <= ACTION_SWAP_TR))
    {
        ADTransitionOrientation orientation = ADTransitionLeftToRight;
        
        switch (object.startActionType)
        {
            case ACTION_SWAP_RL:
                orientation = ADTransitionRightToLeft;
                break;
            case ACTION_SWAP_LR:
                orientation = ADTransitionLeftToRight;
                break;
            case ACTION_SWAP_TB:
                orientation = ADTransitionTopToBottom;
                break;
            case ACTION_SWAP_BT:
                orientation = ADTransitionBottomToTop;
                break;
            case ACTION_SWAP_BL:
                orientation = ADTransitionBottomLeft;
                break;
            case ACTION_SWAP_BR:
                orientation = ADTransitionBottomRight;
                break;
            case ACTION_SWAP_TL:
                orientation = ADTransitionTopLeft;
                break;
            case ACTION_SWAP_TR:
                orientation = ADTransitionTopRight;
                break;

            default:
                orientation = ADTransitionRightToLeft;
                break;
        }
        
        CGAffineTransform startTranslationTransform = CGAffineTransformConcat(videoTransfrom, CGAffineTransformMakeScale(0.001f, 0.001f));
        startTranslationTransform = CGAffineTransformMake(startTranslationTransform.a, startTranslationTransform.b, startTranslationTransform.c, startTranslationTransform.d, viewWidth/2.0f, viewHeight/2.0f);
        
        CGAffineTransform inTranslationTransform = CGAffineTransformIdentity;
        
        switch (orientation)
        {
            case ADTransitionRightToLeft:
                inTranslationTransform = CGAffineTransformMake(videoTransfrom.a, videoTransfrom.b, videoTransfrom.c, videoTransfrom.d, viewWidth+videoTransfrom.tx, videoTransfrom.ty);
                break;
                
            case ADTransitionLeftToRight:
                inTranslationTransform = CGAffineTransformMake(videoTransfrom.a, videoTransfrom.b, videoTransfrom.c, videoTransfrom.d, -viewWidth+videoTransfrom.tx, videoTransfrom.ty);
                break;
                
            case ADTransitionBottomToTop:
                inTranslationTransform = CGAffineTransformMake(videoTransfrom.a, videoTransfrom.b, videoTransfrom.c, videoTransfrom.d, videoTransfrom.tx, viewHeight+videoTransfrom.ty);
                break;
                
            case ADTransitionTopToBottom:
                inTranslationTransform = CGAffineTransformMake(videoTransfrom.a, videoTransfrom.b, videoTransfrom.c, videoTransfrom.d, videoTransfrom.tx, -viewHeight+videoTransfrom.ty);
                break;

            case ADTransitionBottomLeft:
                inTranslationTransform = CGAffineTransformMake(videoTransfrom.a, videoTransfrom.b, videoTransfrom.c, videoTransfrom.d, -viewWidth+videoTransfrom.tx, viewHeight+videoTransfrom.ty);
                break;

            case ADTransitionBottomRight:
                inTranslationTransform = CGAffineTransformMake(videoTransfrom.a, videoTransfrom.b, videoTransfrom.c, videoTransfrom.d, viewWidth+videoTransfrom.tx, viewHeight+videoTransfrom.ty);
                break;

            case ADTransitionTopLeft:
                inTranslationTransform = CGAffineTransformMake(videoTransfrom.a, videoTransfrom.b, videoTransfrom.c, videoTransfrom.d, -viewWidth+videoTransfrom.tx, -viewHeight+videoTransfrom.ty);
                break;
                
            case ADTransitionTopRight:
                inTranslationTransform = CGAffineTransformMake(videoTransfrom.a, videoTransfrom.b, videoTransfrom.c, videoTransfrom.d, viewWidth+videoTransfrom.tx, -viewHeight+videoTransfrom.ty);
                break;


            default:
                NSAssert(FALSE, @"Unhandlded ADSwapTransitionOrientation!");
                break;
        }

        [layerInstruction setTransformRampFromStartTransform:startTranslationTransform toEndTransform:inTranslationTransform timeRange:CMTimeRangeMake(CMTimeMake(object.mfStartPosition*inputAsset.duration.timescale, inputAsset.duration.timescale), CMTimeMake(object.mfStartAnimationDuration/2.0f*inputAsset.duration.timescale, inputAsset.duration.timescale))];
        
        [layerInstruction setTransformRampFromStartTransform:inTranslationTransform toEndTransform:videoTransfrom timeRange:CMTimeRangeMake(CMTimeMake((object.mfStartPosition + object.mfStartAnimationDuration/2.0f)*inputAsset.duration.timescale, inputAsset.duration.timescale), CMTimeMake(object.mfStartAnimationDuration/2.0f*inputAsset.duration.timescale, inputAsset.duration.timescale))];
    }
    else if (object.startActionType == ACTION_ROTATE)
    {
        [layerInstruction setOpacity:0.0f atTime:kCMTimeZero];
        [layerInstruction setOpacityRampFromStartOpacity:0.0f toEndOpacity:object.imageView.alpha timeRange:CMTimeRangeMake(CMTimeMake((object.mfStartPosition+object.mfStartAnimationDuration)*inputAsset.duration.timescale, inputAsset.duration.timescale), CMTimeMake(MIN_DURATION*inputAsset.duration.timescale, inputAsset.duration.timescale))];
    }
    else if ((object.startActionType >= ACTION_GENIE_BL)&&(object.startActionType <= ACTION_GENIE_TR))
    {
        [layerInstruction setOpacity:0.0f atTime:kCMTimeZero];
        [layerInstruction setOpacityRampFromStartOpacity:0.0f toEndOpacity:object.imageView.alpha timeRange:CMTimeRangeMake(CMTimeMake((object.mfStartPosition+object.mfStartAnimationDuration)*inputAsset.duration.timescale, inputAsset.duration.timescale), CMTimeMake(MIN_DURATION*inputAsset.duration.timescale, inputAsset.duration.timescale))];
    }
    else if (object.startActionType == ACTION_EXPLODE)
    {
        [layerInstruction setOpacity:0.0f atTime:kCMTimeZero];
        [layerInstruction setOpacityRampFromStartOpacity:0.0f toEndOpacity:object.imageView.alpha timeRange:CMTimeRangeMake(CMTimeMake((object.mfStartPosition+object.mfStartAnimationDuration)*inputAsset.duration.timescale, inputAsset.duration.timescale), CMTimeMake(MIN_DURATION*inputAsset.duration.timescale, inputAsset.duration.timescale))];
    }
    else if ((object.startActionType >= ACTION_REVEAL_BT)&&(object.startActionType <= ACTION_REVEAL_TB))
    {
        ADTransitionOrientation orientation = ADTransitionLeftToRight;
        
        switch (object.startActionType)
        {
            case ACTION_REVEAL_RL:
                orientation = ADTransitionRightToLeft;
                break;
            case ACTION_REVEAL_LR:
                orientation = ADTransitionLeftToRight;
                break;
            case ACTION_REVEAL_TB:
                orientation = ADTransitionTopToBottom;
                break;
            case ACTION_REVEAL_BT:
                orientation = ADTransitionBottomToTop;
                break;
                
            default:
                orientation = ADTransitionRightToLeft;
                break;
        }
        
        CGAffineTransform inTranslationTransform = CGAffineTransformIdentity;
        
        switch (orientation)
        {
            case ADTransitionRightToLeft:
            {
                inTranslationTransform = CGAffineTransformMake(videoTransfrom.a, videoTransfrom.b, videoTransfrom.c, videoTransfrom.d, videoTransfrom.tx+viewWidth, videoTransfrom.ty);
            }
                break;
            case ADTransitionLeftToRight:
            {
                inTranslationTransform = CGAffineTransformMake(videoTransfrom.a, videoTransfrom.b, videoTransfrom.c, videoTransfrom.d, videoTransfrom.tx-viewWidth, videoTransfrom.ty);
            }
                break;
            case ADTransitionTopToBottom:
            {
                inTranslationTransform = CGAffineTransformMake(videoTransfrom.a, videoTransfrom.b, videoTransfrom.c, videoTransfrom.d, videoTransfrom.tx, videoTransfrom.ty-viewHeight);
            }
                break;
            case ADTransitionBottomToTop:
            {
                inTranslationTransform = CGAffineTransformMake(videoTransfrom.a, videoTransfrom.b, videoTransfrom.c, videoTransfrom.d, videoTransfrom.tx, videoTransfrom.ty+viewHeight);
            }
                break;
            default:
                NSAssert(FALSE, @"Unhandled ADTransitionOrientation");
                break;
        }
        
        [layerInstruction setTransformRampFromStartTransform:inTranslationTransform toEndTransform:videoTransfrom timeRange:CMTimeRangeMake(CMTimeMake(object.mfStartPosition*inputAsset.duration.timescale, inputAsset.duration.timescale), CMTimeMake(object.mfStartAnimationDuration*inputAsset.duration.timescale, inputAsset.duration.timescale))];
        
        [layerInstruction setOpacityRampFromStartOpacity:0.0f toEndOpacity:object.imageView.alpha timeRange:CMTimeRangeMake(CMTimeMake(object.mfStartPosition*inputAsset.duration.timescale, inputAsset.duration.timescale), CMTimeMake(object.mfStartAnimationDuration/2.0f*inputAsset.duration.timescale, inputAsset.duration.timescale))];
    }
    else    //new addition by Yinjing Li at 2015/05/03
    {
        [layerInstruction setOpacity:0.0 atTime:kCMTimeZero];
        
        [layerInstruction setOpacity:object.imageView.alpha atTime:CMTimeMake((object.mfStartPosition+MIN_DURATION)*inputAsset.duration.timescale, inputAsset.duration.timescale)];
    }


    // end action
    if (object.endActionType == ACTION_NONE)
    {
        if (object.mfEndPosition > grNormalFilterOutputTotalTime)
        {
            [layerInstruction setOpacity:0.0 atTime:CMTimeMake(grNormalFilterOutputTotalTime*inputAsset.duration.timescale, inputAsset.duration.timescale)];
        }
        else
        {
            [layerInstruction setOpacity:0.0f atTime:CMTimeMake(object.mfEndPosition*inputAsset.duration.timescale, inputAsset.duration.timescale)];
        }
    }
    else if (object.endActionType == ACTION_FADE)
    {
        [layerInstruction setOpacityRampFromStartOpacity:object.imageView.alpha toEndOpacity:0.0f timeRange:CMTimeRangeMake(CMTimeMake((object.mfEndPosition - object.mfEndAnimationDuration - MIN_DURATION)*inputAsset.duration.timescale, inputAsset.duration.timescale), CMTimeMake(object.mfEndAnimationDuration*inputAsset.duration.timescale, inputAsset.duration.timescale))];
    }
    else if (object.endActionType == ACTION_BLACK)
    {
        [layerInstruction setOpacityRampFromStartOpacity:object.imageView.alpha toEndOpacity:0.0f timeRange:CMTimeRangeMake(CMTimeMake((object.mfEndPosition - object.mfEndAnimationDuration)*inputAsset.duration.timescale, inputAsset.duration.timescale), CMTimeMake(MIN_DURATION*inputAsset.duration.timescale, inputAsset.duration.timescale))];
    }
    else if ((object.endActionType >= ACTION_ZOOM_BL)&&(object.endActionType <= ACTION_ZOOM_TR))
    {
        CGAffineTransform outTranslationTransform = CGAffineTransformConcat(videoTransfrom, CGAffineTransformMakeScale(0.001f, 0.001f));
        
        switch (object.endActionType)
        {
            case ACTION_ZOOM_CC:
                outTranslationTransform = CGAffineTransformMake(outTranslationTransform.a, outTranslationTransform.b, outTranslationTransform.c, outTranslationTransform.d, viewWidth/2, viewHeight/2);
                break;
            case ACTION_ZOOM_RL:
                outTranslationTransform = CGAffineTransformMake(outTranslationTransform.a, outTranslationTransform.b, outTranslationTransform.c, outTranslationTransform.d, -viewWidth*0.1f, viewHeight/2);
                break;
            case ACTION_ZOOM_LR:
                outTranslationTransform = CGAffineTransformMake(outTranslationTransform.a, outTranslationTransform.b, outTranslationTransform.c, outTranslationTransform.d, viewWidth*1.1f, viewHeight/2);
                break;
            case ACTION_ZOOM_TB:
                outTranslationTransform = CGAffineTransformMake(outTranslationTransform.a, outTranslationTransform.b, outTranslationTransform.c, outTranslationTransform.d, viewWidth/2, viewHeight*1.1f);
                break;
            case ACTION_ZOOM_BT:
                outTranslationTransform = CGAffineTransformMake(outTranslationTransform.a, outTranslationTransform.b, outTranslationTransform.c, outTranslationTransform.d, viewWidth/2, -viewHeight*0.1f);
                break;
            case ACTION_ZOOM_BL:
                outTranslationTransform = CGAffineTransformMake(outTranslationTransform.a, outTranslationTransform.b, outTranslationTransform.c, outTranslationTransform.d, -viewWidth*0.1f, viewHeight*1.1f);
                break;
            case ACTION_ZOOM_BR:
                outTranslationTransform = CGAffineTransformMake(outTranslationTransform.a, outTranslationTransform.b, outTranslationTransform.c, outTranslationTransform.d, viewWidth*1.1f, viewHeight*1.1f);
                break;
            case ACTION_ZOOM_TL:
                outTranslationTransform = CGAffineTransformMake(outTranslationTransform.a, outTranslationTransform.b, outTranslationTransform.c, outTranslationTransform.d, -viewWidth*0.1f, -viewHeight*0.1f);
                break;
            case ACTION_ZOOM_TR:
                outTranslationTransform = CGAffineTransformMake(outTranslationTransform.a, outTranslationTransform.b, outTranslationTransform.c, outTranslationTransform.d, viewWidth*1.1f, -viewHeight*0.1f);
                break;
                
            default:
                break;
        }
        
        [layerInstruction setTransformRampFromStartTransform:videoTransfrom toEndTransform:outTranslationTransform timeRange:CMTimeRangeMake(CMTimeMake((object.mfEndPosition - object.mfEndAnimationDuration - MIN_DURATION)*inputAsset.duration.timescale, inputAsset.duration.timescale), CMTimeMake(object.mfEndAnimationDuration*inputAsset.duration.timescale, inputAsset.duration.timescale))];

        if (object.mfEndPosition > grNormalFilterOutputTotalTime)
        {
            [layerInstruction setOpacity:0.0 atTime:CMTimeMake(grNormalFilterOutputTotalTime*inputAsset.duration.timescale, inputAsset.duration.timescale)];
        }
        else
        {
            [layerInstruction setOpacity:0.0f atTime:CMTimeMake(object.mfEndPosition*inputAsset.duration.timescale, inputAsset.duration.timescale)];
        }
    }
    else if ((object.endActionType >= ACTION_SLIDE_BL)&&(object.endActionType <= ACTION_SLIDE_TR))
    {
        ADTransitionOrientation orientation = ADTransitionRightToLeft;
        
        switch (object.endActionType)
        {
            case ACTION_SLIDE_RL:
                orientation = ADTransitionRightToLeft;
                break;
            case ACTION_SLIDE_LR:
                orientation = ADTransitionLeftToRight;
                break;
            case ACTION_SLIDE_TB:
                orientation = ADTransitionTopToBottom;
                break;
            case ACTION_SLIDE_BT:
                orientation = ADTransitionBottomToTop;
                break;
            case ACTION_SLIDE_BL:
                orientation = ADTransitionBottomLeft;
                break;
            case ACTION_SLIDE_BR:
                orientation = ADTransitionBottomRight;
                break;
            case ACTION_SLIDE_TL:
                orientation = ADTransitionTopLeft;
                break;
            case ACTION_SLIDE_TR:
                orientation = ADTransitionTopRight;
                break;

            default:
                orientation = ADTransitionRightToLeft;
                break;
        }
        
        CGAffineTransform outTranslationTransform = CGAffineTransformIdentity;
        
        switch (orientation)
        {
            case ADTransitionRightToLeft:
                outTranslationTransform = CGAffineTransformMake(videoTransfrom.a, videoTransfrom.b, videoTransfrom.c, videoTransfrom.d, videoTransfrom.tx-viewWidth, videoTransfrom.ty);
                break;
                
            case ADTransitionLeftToRight:
                outTranslationTransform = CGAffineTransformMake(videoTransfrom.a, videoTransfrom.b, videoTransfrom.c, videoTransfrom.d, videoTransfrom.tx+viewWidth, videoTransfrom.ty);
                break;
                
            case ADTransitionTopToBottom:
                outTranslationTransform = CGAffineTransformMake(videoTransfrom.a, videoTransfrom.b, videoTransfrom.c, videoTransfrom.d, videoTransfrom.tx, videoTransfrom.ty+viewHeight);
                break;
                
            case ADTransitionBottomToTop:
                outTranslationTransform = CGAffineTransformMake(videoTransfrom.a, videoTransfrom.b, videoTransfrom.c, videoTransfrom.d, videoTransfrom.tx, videoTransfrom.ty-viewHeight);
                break;

            case ADTransitionBottomLeft:
                outTranslationTransform = CGAffineTransformMake(videoTransfrom.a, videoTransfrom.b, videoTransfrom.c, videoTransfrom.d, videoTransfrom.tx-viewWidth, videoTransfrom.ty+viewHeight);
                break;

            case ADTransitionBottomRight:
                outTranslationTransform = CGAffineTransformMake(videoTransfrom.a, videoTransfrom.b, videoTransfrom.c, videoTransfrom.d, videoTransfrom.tx+viewWidth, videoTransfrom.ty+viewHeight);
                break;

            case ADTransitionTopLeft:
                outTranslationTransform = CGAffineTransformMake(videoTransfrom.a, videoTransfrom.b, videoTransfrom.c, videoTransfrom.d, videoTransfrom.tx-viewWidth, videoTransfrom.ty-viewHeight);
                break;

            case ADTransitionTopRight:
                outTranslationTransform = CGAffineTransformMake(videoTransfrom.a, videoTransfrom.b, videoTransfrom.c, videoTransfrom.d, videoTransfrom.tx+viewWidth, videoTransfrom.ty-viewHeight);
                break;

            default:
                NSAssert(FALSE, @"Unhandled ADTransitionOrientation");
                break;
        }
        
        [layerInstruction setTransformRampFromStartTransform:videoTransfrom toEndTransform:outTranslationTransform timeRange:CMTimeRangeMake(CMTimeMake((object.mfEndPosition - object.mfEndAnimationDuration - MIN_DURATION)*inputAsset.duration.timescale, inputAsset.duration.timescale), CMTimeMake(object.mfEndAnimationDuration*inputAsset.duration.timescale, inputAsset.duration.timescale))];
    }
    else if ((object.endActionType >= ACTION_SWAP_BL)&&(object.endActionType <= ACTION_SWAP_TR))
    {
        ADTransitionOrientation orientation = ADTransitionLeftToRight;
        
        switch (object.endActionType)
        {
            case ACTION_SWAP_RL:
                orientation = ADTransitionRightToLeft;
                break;
            case ACTION_SWAP_LR:
                orientation = ADTransitionLeftToRight;
                break;
            case ACTION_SWAP_TB:
                orientation = ADTransitionTopToBottom;
                break;
            case ACTION_SWAP_BT:
                orientation = ADTransitionBottomToTop;
                break;
            case ACTION_SWAP_BL:
                orientation = ADTransitionBottomLeft;
                break;
            case ACTION_SWAP_BR:
                orientation = ADTransitionBottomRight;
                break;
            case ACTION_SWAP_TL:
                orientation = ADTransitionTopLeft;
                break;
            case ACTION_SWAP_TR:
                orientation = ADTransitionTopRight;
                break;

            default:
                orientation = ADTransitionRightToLeft;
                break;
        }
        
        CGAffineTransform endTranslationTransform = CGAffineTransformConcat(videoTransfrom, CGAffineTransformMakeScale(0.001f, 0.001f));
        endTranslationTransform = CGAffineTransformMake(endTranslationTransform.a, endTranslationTransform.b, endTranslationTransform.c, endTranslationTransform.d, viewWidth/2, viewHeight/2);
        
        CGAffineTransform outTranslationTransform = CGAffineTransformIdentity;

        switch (orientation)
        {
            case ADTransitionRightToLeft:
                outTranslationTransform = CGAffineTransformMake(videoTransfrom.a, videoTransfrom.b, videoTransfrom.c, videoTransfrom.d, -viewWidth+videoTransfrom.tx, videoTransfrom.ty);
                break;
                
            case ADTransitionLeftToRight:
                outTranslationTransform = CGAffineTransformMake(videoTransfrom.a, videoTransfrom.b, videoTransfrom.c, videoTransfrom.d, viewWidth+videoTransfrom.tx, videoTransfrom.ty);
                break;
                
            case ADTransitionTopToBottom:
                outTranslationTransform = CGAffineTransformMake(videoTransfrom.a, videoTransfrom.b, videoTransfrom.c, videoTransfrom.d, videoTransfrom.tx, viewHeight+videoTransfrom.ty);
                break;
                
            case ADTransitionBottomToTop:
                outTranslationTransform = CGAffineTransformMake(videoTransfrom.a, videoTransfrom.b, videoTransfrom.c, videoTransfrom.d, videoTransfrom.tx, -viewHeight+videoTransfrom.ty);
                break;

            case ADTransitionBottomLeft:
                outTranslationTransform = CGAffineTransformMake(videoTransfrom.a, videoTransfrom.b, videoTransfrom.c, videoTransfrom.d, -viewWidth+videoTransfrom.tx, viewHeight+videoTransfrom.ty);
                break;

            case ADTransitionBottomRight:
                outTranslationTransform = CGAffineTransformMake(videoTransfrom.a, videoTransfrom.b, videoTransfrom.c, videoTransfrom.d, viewWidth+videoTransfrom.tx, viewHeight+videoTransfrom.ty);
                break;
                
            case ADTransitionTopLeft:
                outTranslationTransform = CGAffineTransformMake(videoTransfrom.a, videoTransfrom.b, videoTransfrom.c, videoTransfrom.d, -viewWidth+videoTransfrom.tx, -viewHeight+videoTransfrom.ty);
                break;

            case ADTransitionTopRight:
                outTranslationTransform = CGAffineTransformMake(videoTransfrom.a, videoTransfrom.b, videoTransfrom.c, videoTransfrom.d, viewWidth+videoTransfrom.tx, -viewHeight+videoTransfrom.ty);
                break;


            default:
                NSAssert(FALSE, @"Unhandled ADTransitionOrientation");
                break;
        }
        
        [layerInstruction setTransformRampFromStartTransform:videoTransfrom toEndTransform:outTranslationTransform timeRange:CMTimeRangeMake(CMTimeMake((object.mfEndPosition - object.mfEndAnimationDuration)*inputAsset.duration.timescale, inputAsset.duration.timescale), CMTimeMake(object.mfEndAnimationDuration/2.0f*inputAsset.duration.timescale, inputAsset.duration.timescale))];

        [layerInstruction setTransformRampFromStartTransform:outTranslationTransform toEndTransform:endTranslationTransform timeRange:CMTimeRangeMake(CMTimeMake((object.mfEndPosition - object.mfEndAnimationDuration/2.0f)*inputAsset.duration.timescale, inputAsset.duration.timescale), CMTimeMake((object.mfEndAnimationDuration/2.0f - MIN_DURATION)*inputAsset.duration.timescale, inputAsset.duration.timescale))];
        
        if (object.mfEndPosition > grNormalFilterOutputTotalTime)
        {
            [layerInstruction setOpacity:0.0 atTime:CMTimeMake(grNormalFilterOutputTotalTime*inputAsset.duration.timescale, inputAsset.duration.timescale)];
        }
        else
        {
            [layerInstruction setOpacity:0.0f atTime:CMTimeMake(object.mfEndPosition*inputAsset.duration.timescale, inputAsset.duration.timescale)];
        }
    }
    else if (object.endActionType == ACTION_ROTATE)
    {
        [layerInstruction setOpacityRampFromStartOpacity:object.imageView.alpha toEndOpacity:0.0f timeRange:CMTimeRangeMake(CMTimeMake((object.mfEndPosition - object.mfEndAnimationDuration)*inputAsset.duration.timescale, inputAsset.duration.timescale), CMTimeMake(MIN_DURATION*inputAsset.duration.timescale, inputAsset.duration.timescale))];
    }
    else if ((object.endActionType >= ACTION_GENIE_BL)&&(object.endActionType <= ACTION_GENIE_TR))
    {
        [layerInstruction setOpacityRampFromStartOpacity:object.imageView.alpha toEndOpacity:0.0f timeRange:CMTimeRangeMake(CMTimeMake((object.mfEndPosition - object.mfEndAnimationDuration - MIN_DURATION)*inputAsset.duration.timescale, inputAsset.duration.timescale), CMTimeMake(MIN_DURATION*inputAsset.duration.timescale, inputAsset.duration.timescale))];
    }
    else if (object.endActionType == ACTION_EXPLODE)
    {
        [layerInstruction setOpacityRampFromStartOpacity:object.imageView.alpha toEndOpacity:0.0f timeRange:CMTimeRangeMake(CMTimeMake((object.mfEndPosition - object.mfEndAnimationDuration)*inputAsset.duration.timescale, inputAsset.duration.timescale), CMTimeMake(MIN_DURATION*inputAsset.duration.timescale, inputAsset.duration.timescale))];
    }
    else if ((object.endActionType >= ACTION_REVEAL_BT)&&(object.endActionType <= ACTION_REVEAL_TB))
    {
        ADTransitionOrientation orientation = ADTransitionRightToLeft;
        
        switch (object.endActionType)
        {
            case ACTION_REVEAL_RL:
                orientation = ADTransitionRightToLeft;
                break;
            case ACTION_REVEAL_LR:
                orientation = ADTransitionLeftToRight;
                break;
            case ACTION_REVEAL_TB:
                orientation = ADTransitionTopToBottom;
                break;
            case ACTION_REVEAL_BT:
                orientation = ADTransitionBottomToTop;
                break;
                
            default:
                orientation = ADTransitionRightToLeft;
                break;
        }
        
        CGAffineTransform outTranslationTransform = CGAffineTransformIdentity;
        
        switch (orientation)
        {
            case ADTransitionRightToLeft:
            {
                outTranslationTransform = CGAffineTransformMake(videoTransfrom.a, videoTransfrom.b, videoTransfrom.c, videoTransfrom.d, videoTransfrom.tx-viewWidth, videoTransfrom.ty);
            }
                break;
            case ADTransitionLeftToRight:
            {
                outTranslationTransform = CGAffineTransformMake(videoTransfrom.a, videoTransfrom.b, videoTransfrom.c, videoTransfrom.d, videoTransfrom.tx+viewWidth, videoTransfrom.ty);
            }
                break;
            case ADTransitionTopToBottom:
            {
                outTranslationTransform = CGAffineTransformMake(videoTransfrom.a, videoTransfrom.b, videoTransfrom.c, videoTransfrom.d, videoTransfrom.tx, videoTransfrom.ty+viewHeight);
            }
                break;
            case ADTransitionBottomToTop:
            {
                outTranslationTransform = CGAffineTransformMake(videoTransfrom.a, videoTransfrom.b, videoTransfrom.c, videoTransfrom.d, videoTransfrom.tx, videoTransfrom.ty-viewHeight);
            }
                break;
            default:
                NSAssert(FALSE, @"Unhandled ADTransitionOrientation");
                break;
        }
        
        [layerInstruction setTransformRampFromStartTransform:videoTransfrom toEndTransform:outTranslationTransform timeRange:CMTimeRangeMake(CMTimeMake((object.mfEndPosition - object.mfEndAnimationDuration - MIN_DURATION)*inputAsset.duration.timescale, inputAsset.duration.timescale), CMTimeMake(object.mfEndAnimationDuration*inputAsset.duration.timescale, inputAsset.duration.timescale))];
        
        [layerInstruction setOpacityRampFromStartOpacity:object.imageView.alpha toEndOpacity:0.0f timeRange:CMTimeRangeMake(CMTimeMake((object.mfEndPosition - object.mfEndAnimationDuration*0.5f - MIN_DURATION)*inputAsset.duration.timescale, inputAsset.duration.timescale), CMTimeMake(object.mfEndAnimationDuration*0.5f*inputAsset.duration.timescale, inputAsset.duration.timescale))];
    }

    return layerInstruction;
}


CGPathRef CGPathCreateCornerRect( const CGRect r, const CGFloat cornerRadius )
{
    CGMutablePathRef p = CGPathCreateMutable() ;
    
    CGPathMoveToPoint( p, NULL, r.origin.x + cornerRadius, r.origin.y ) ;
    
    CGFloat maxX = CGRectGetMaxX( r ) ;
    CGFloat maxY = CGRectGetMaxY( r ) ;
    
    CGPathAddArcToPoint( p, NULL, maxX, r.origin.y, maxX, r.origin.y + cornerRadius, cornerRadius ) ;
    CGPathAddArcToPoint( p, NULL, maxX, maxY, maxX - cornerRadius, maxY, cornerRadius ) ;
    CGPathAddArcToPoint( p, NULL, r.origin.x, maxY, r.origin.x, maxY - cornerRadius, cornerRadius ) ;
    CGPathAddArcToPoint( p, NULL, r.origin.x, r.origin.y, r.origin.x + cornerRadius, r.origin.y, cornerRadius ) ;
    
    return p ;
}


#pragma mark -
#pragma mark - Photo Animation!!!

-(void) setOverlayLayerContents:(MediaObjectView*) object layer:(CALayer*) overlayLayer
{
    if (object.isKbEnabled)
    {
        UIImage *overlayImage = nil;
        
        if (object.mediaType == MEDIA_PHOTO)
        {
            overlayImage = [object renderingOutlineAndShadow];
            [overlayLayer setContents:(id)[overlayImage CGImage]];
        }
        else if (object.mediaType == MEDIA_TEXT)
        {
            overlayImage = [object renderingTextViewOutlineAndShadow];
        }
        
        
        CALayer* kbLayer = [CALayer layer];
        kbLayer.backgroundColor = [UIColor clearColor].CGColor;
        kbLayer.masksToBounds = YES;
        
        CGAffineTransform objectTransform = object.transform;
        object.transform = CGAffineTransformIdentity;
        CGRect photoFrame = object.frame;
        
        object.transform = objectTransform;
        
        photoFrame = CGRectMake(photoFrame.origin.x*outputScaleFactor, videoSize.height - (photoFrame.origin.y + photoFrame.size.height)*outputScaleFactor, photoFrame.size.width*outputScaleFactor, photoFrame.size.height*outputScaleFactor);
        
        objectTransform = CGAffineTransformMake(objectTransform.a, -objectTransform.b, -objectTransform.c, objectTransform.d, objectTransform.tx, objectTransform.ty);
        
        kbLayer.frame = photoFrame;
        kbLayer.transform = CATransform3DMakeAffineTransform(objectTransform);
        [overlayLayer addSublayer:kbLayer];
        
        CGSize boundsSize = kbLayer.bounds.size;
        CGFloat radius = 0.0f;
        UIBezierPath* path;
        
        if (object.objectCornerRadius == 0.0f)
        {
            path = [UIBezierPath bezierPathWithRect:kbLayer.bounds];
        }
        else
        {
            radius = object.objectCornerRadius*outputScaleFactor;
            
            if ((boundsSize.height >= boundsSize.width) && (radius > boundsSize.width/2))
                radius = boundsSize.width/2;
            else if ((boundsSize.height < boundsSize.width) && (radius > boundsSize.height/2))
                radius = boundsSize.height/2;
            
            CGPathRef pathRef = CGPathCreateCornerRect(kbLayer.bounds, radius);
            path = [UIBezierPath bezierPathWithCGPath:pathRef];
            CGPathRelease(pathRef);
        }
        
        CAShapeLayer* maskLayer = [CAShapeLayer layer];
        maskLayer.frame = kbLayer.bounds;
        maskLayer.path = path.CGPath;
        kbLayer.mask = maskLayer;
        
        CALayer *photoLayer = [CALayer layer];
        photoLayer.backgroundColor = [UIColor clearColor].CGColor;
        
        UIImage *photoImage = nil;
        
        if (object.mediaType == MEDIA_PHOTO)
            photoImage = [object renderingPhoto];
        else if (object.mediaType == MEDIA_TEXT)
            photoImage = [object renderingText];
        
        [photoLayer setContents:(id)[photoImage CGImage]];
        photoLayer.frame = CGRectMake(0.0f, 0.0f, photoFrame.size.width, photoFrame.size.height);
        [kbLayer addSublayer:photoLayer];
        
        
        CFTimeInterval kbPosition = AVCoreAnimationBeginTimeAtZero + object.mfStartPosition;
        CFTimeInterval kbDuration = object.mfEndPosition - object.mfStartPosition - MIN_DURATION;

        CAKeyframeAnimation * inKeyFrameTransformAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
        
        CGFloat viewWidth = (photoLayer.bounds.size.width * object.fKbScale - photoLayer.bounds.size.width)/2.0f;
        CGFloat viewHeight = (photoLayer.bounds.size.height * object.fKbScale - photoLayer.bounds.size.height)/2.0f;
        
        CATransform3D translationTransform  = CATransform3DTranslate(CATransform3DIdentity, viewWidth*(1.0f - object.kbFocusPoint.x*2.0f), viewHeight*(object.kbFocusPoint.y*2.0f - 1.0f), 0);

        if (object.nKbIn == KB_IN)
            inKeyFrameTransformAnimation.values = @[[NSValue valueWithCATransform3D:CATransform3DIdentity],
                                                    [NSValue valueWithCATransform3D:translationTransform]];
        else if (object.nKbIn == KB_OUT)
            inKeyFrameTransformAnimation.values = @[[NSValue valueWithCATransform3D:translationTransform],
                                                    [NSValue valueWithCATransform3D:CATransform3DIdentity]];
        
        CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        
        if (object.nKbIn == KB_IN)
        {
            scaleAnimation.fromValue = [NSNumber numberWithFloat:1.0f];
            scaleAnimation.toValue = [NSNumber numberWithFloat:object.fKbScale];
        }
        else if (object.nKbIn == KB_OUT)
        {
            scaleAnimation.fromValue = [NSNumber numberWithFloat:object.fKbScale];
            scaleAnimation.toValue = [NSNumber numberWithFloat:1.0f];
        }
        
        CAAnimationGroup * kbAnimation = [CAAnimationGroup animation];
        kbAnimation.animations = @[inKeyFrameTransformAnimation, scaleAnimation];
        kbAnimation.duration = kbDuration;
        kbAnimation.beginTime = kbPosition;
        kbAnimation.removedOnCompletion = NO;
        kbAnimation.repeatCount = 1;
        kbAnimation.fillMode = kCAFillModeBackwards;
        kbAnimation.delegate = (id)self;
        
        [photoLayer addAnimation:kbAnimation forKey:@"KenBurns"];
        
        if (object.mediaType == MEDIA_TEXT)
        {
            CALayer *textLayer = [CALayer layer];
            textLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
            textLayer.backgroundColor = [UIColor clearColor].CGColor;
            [textLayer setContents:(id)[overlayImage CGImage]];
            [overlayLayer addSublayer:textLayer];
        }
    }
    else
    {
        UIImage *overlayImage = nil;
        
        if (gnOutputVideoFilterIndex == 0)
        {
            if (object.mediaType == MEDIA_PHOTO)
                overlayImage = object.renderedImage;
            else if (object.mediaType == MEDIA_TEXT)
                overlayImage = [object renderingTextView];
        }
        else if (gnOutputVideoFilterIndex == 1)
        {
            if (object.isImitationPhoto)
            {
                if (object.mediaType == MEDIA_PHOTO)
                    overlayImage = [object renderingOutlineAndShadow];
                else if (object.mediaType == MEDIA_TEXT)
                    overlayImage = [object renderingTextViewOutlineAndShadow];
            }
            else
            {
                if (object.mediaType == MEDIA_PHOTO)
                    overlayImage = object.renderedImage;
                else if (object.mediaType == MEDIA_TEXT)
                    overlayImage = [object renderingTextView];
            }
        }
        
        [overlayLayer setContents:(id)[overlayImage CGImage]];
    }
}

-(void) setOverlayLayerContents:(MediaObjectView*) object layers:(NSMutableArray*) overlayLayers
{
    if (object.isKbEnabled)
    {
        UIImage *overlayImage = nil;
        
        if (object.mediaType == MEDIA_PHOTO)
        {
            overlayImage = [object renderingOutlineAndShadow];
            
            for (CALayer* overlayLayer in overlayLayers)
                [overlayLayer setContents:(id)[overlayImage CGImage]];
        }
        else if (object.mediaType == MEDIA_TEXT)
        {
            overlayImage = [object renderingTextViewOutlineAndShadow];
        }
        

        CGAffineTransform objectTransform = object.transform;
        object.transform = CGAffineTransformIdentity;
        CGRect photoFrame = object.frame;
        
        object.transform = objectTransform;
        
        photoFrame = CGRectMake(photoFrame.origin.x*outputScaleFactor, videoSize.height - (photoFrame.origin.y + photoFrame.size.height)*outputScaleFactor, photoFrame.size.width*outputScaleFactor, photoFrame.size.height*outputScaleFactor);
        
        objectTransform = CGAffineTransformMake(objectTransform.a, -objectTransform.b, -objectTransform.c, objectTransform.d, objectTransform.tx, objectTransform.ty);

        UIImage *photoImage = nil;
        
        if (object.mediaType == MEDIA_PHOTO)
            photoImage = [object renderingPhoto];
        else if (object.mediaType == MEDIA_TEXT)
            photoImage = [object renderingText];

        for (CALayer* overlayLayer in overlayLayers)
        {
            CALayer* kbLayer = [CALayer layer];
            kbLayer.backgroundColor = [UIColor clearColor].CGColor;
            kbLayer.masksToBounds = YES;
            kbLayer.frame = photoFrame;
            kbLayer.transform = CATransform3DMakeAffineTransform(objectTransform);
            [overlayLayer addSublayer:kbLayer];
            
            CGSize boundsSize = kbLayer.bounds.size;
            CGFloat radius = 0.0f;
            UIBezierPath* path;
            
            if (object.objectCornerRadius == 0.0f)
            {
                path = [UIBezierPath bezierPathWithRect:kbLayer.bounds];
            }
            else
            {
                radius = object.objectCornerRadius*outputScaleFactor;
                
                if ((boundsSize.height >= boundsSize.width) && (radius > boundsSize.width/2))
                    radius = boundsSize.width/2;
                else if ((boundsSize.height < boundsSize.width) && (radius > boundsSize.height/2))
                    radius = boundsSize.height/2;
                
                CGPathRef pathRef = CGPathCreateCornerRect(kbLayer.bounds, radius);
                path = [UIBezierPath bezierPathWithCGPath:pathRef];
                CGPathRelease(pathRef);
            }
            
            CAShapeLayer* maskLayer = [CAShapeLayer layer];
            maskLayer.frame = kbLayer.bounds;
            maskLayer.path = path.CGPath;
            kbLayer.mask = maskLayer;
            
            CALayer *photoLayer = [CALayer layer];
            photoLayer.backgroundColor = [UIColor clearColor].CGColor;
            [photoLayer setContents:(id)[photoImage CGImage]];
            photoLayer.frame = CGRectMake(0.0f, 0.0f, photoFrame.size.width, photoFrame.size.height);
            [kbLayer addSublayer:photoLayer];
            
            CFTimeInterval kbPosition = AVCoreAnimationBeginTimeAtZero + object.mfStartPosition;
            CFTimeInterval kbDuration = object.mfEndPosition - object.mfStartPosition - MIN_DURATION;
            
            CAKeyframeAnimation * inKeyFrameTransformAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
            
            CGFloat viewWidth = (photoLayer.bounds.size.width * object.fKbScale - photoLayer.bounds.size.width)/2.0f;
            CGFloat viewHeight = (photoLayer.bounds.size.height * object.fKbScale - photoLayer.bounds.size.height)/2.0f;
            
            CATransform3D translationTransform  = CATransform3DTranslate(CATransform3DIdentity, viewWidth*(1.0f - object.kbFocusPoint.x*2.0f), viewHeight*(object.kbFocusPoint.y*2.0f - 1.0f), 0);
            
            if (object.nKbIn == KB_IN)
                inKeyFrameTransformAnimation.values = @[[NSValue valueWithCATransform3D:CATransform3DIdentity],
                                                        [NSValue valueWithCATransform3D:translationTransform]];
            else if (object.nKbIn == KB_OUT)
                inKeyFrameTransformAnimation.values = @[[NSValue valueWithCATransform3D:translationTransform],
                                                        [NSValue valueWithCATransform3D:CATransform3DIdentity]];
            
            CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
            
            if (object.nKbIn == KB_IN)
            {
                scaleAnimation.fromValue = [NSNumber numberWithFloat:1.0f];
                scaleAnimation.toValue = [NSNumber numberWithFloat:object.fKbScale];
            }
            else if (object.nKbIn == KB_OUT)
            {
                scaleAnimation.fromValue = [NSNumber numberWithFloat:object.fKbScale];
                scaleAnimation.toValue = [NSNumber numberWithFloat:1.0f];
            }
            
            CAAnimationGroup * kbAnimation = [CAAnimationGroup animation];
            kbAnimation.animations = @[inKeyFrameTransformAnimation, scaleAnimation];
            kbAnimation.duration = kbDuration;
            kbAnimation.beginTime = kbPosition;
            kbAnimation.removedOnCompletion = NO;
            kbAnimation.repeatCount = 1;
            kbAnimation.fillMode = kCAFillModeBackwards;
            kbAnimation.delegate = (id)self;
            
            [photoLayer addAnimation:kbAnimation forKey:@"KenBurns"];
            
            if (object.mediaType == MEDIA_TEXT)
            {
                CALayer *textLayer = [CALayer layer];
                textLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
                textLayer.backgroundColor = [UIColor clearColor].CGColor;
                [textLayer setContents:(id)[overlayImage CGImage]];
                [overlayLayer addSublayer:textLayer];
            }
        }
    }
    else
    {
        UIImage *overlayImage = nil;
        
        if (gnOutputVideoFilterIndex == 0)
        {
            if (object.mediaType == MEDIA_PHOTO)
                overlayImage = object.renderedImage;
            else if (object.mediaType == MEDIA_TEXT)
                overlayImage = [object renderingTextView];
        }
        else if (gnOutputVideoFilterIndex == 1)
        {
            if (object.isImitationPhoto)
            {
                if (object.mediaType == MEDIA_PHOTO)
                    overlayImage = [object renderingOutlineAndShadow];
                else if (object.mediaType == MEDIA_TEXT)
                    overlayImage = [object renderingTextViewOutlineAndShadow];
            }
            else
            {
                if (object.mediaType == MEDIA_PHOTO)
                    overlayImage = object.renderedImage;
                else if (object.mediaType == MEDIA_TEXT)
                    overlayImage = [object renderingTextView];
            }
        }
        
        for (CALayer* overlayLayer in overlayLayers)
        {
            [overlayLayer setContents:(id)[overlayImage CGImage]];
        }
    }
}

- (AVVideoCompositionCoreAnimationTool*) setPhotoAnimation :(int) startIndex index:(int) endIndex
{
    CALayer *parentLayer = [CALayer layer];
    parentLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
    parentLayer.backgroundColor = [UIColor clearColor].CGColor;
    
    CALayer *videoLayer = [CALayer layer];
    videoLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
    videoLayer.backgroundColor = [UIColor clearColor].CGColor;
    [parentLayer addSublayer:videoLayer];
    
    for (int i=startIndex; i<endIndex; i++)
    {
        @autoreleasepool
        {
            MediaObjectView* object = [self.objectArray objectAtIndex:i];
            
            CGFloat toZoomValue = 1.0f;
            CATransform3D inTranslationTransform = CATransform3DIdentity;

            if (object.mediaType == MEDIA_PHOTO)
            {
                CALayer *overlayLayer = [CALayer layer];
                overlayLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
                overlayLayer.backgroundColor = [UIColor clearColor].CGColor;

                if ((object.startActionType == ACTION_NONE)||(object.startActionType == ACTION_FADE)||(object.startActionType == ACTION_BLACK))
                {
                    [self setOverlayLayerContents:object layer:overlayLayer];

                    CABasicAnimation *startAnimation = [self getStartAction:object];
                    [overlayLayer addAnimation:startAnimation forKey:nil];
                }
                else
                {
                    if (object.startActionType == ACTION_SWAP_ALL)      //SwapAll
                    {
                        CALayer *overlayLayerRL = [CALayer layer];
                        overlayLayerRL.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
                        overlayLayerRL.backgroundColor = [UIColor clearColor].CGColor;

                        CALayer *overlayLayerLR = [CALayer layer];
                        overlayLayerLR.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
                        overlayLayerLR.backgroundColor = [UIColor clearColor].CGColor;

                        CALayer *overlayLayerTB = [CALayer layer];
                        overlayLayerTB.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
                        overlayLayerTB.backgroundColor = [UIColor clearColor].CGColor;
                        
                        NSMutableArray* layersArray = [[NSMutableArray alloc] initWithObjects:overlayLayer, overlayLayerRL, overlayLayerLR, overlayLayerTB, nil];
                        [self setOverlayLayerContents:object layers:layersArray];

                        
                        CFTimeInterval startPosition = AVCoreAnimationBeginTimeAtZero + object.mfStartPosition;
                        CFTimeInterval startDuration = object.mfStartAnimationDuration;
                        CGRect frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
                        
                        SwapAction* swapAction = [[SwapAction alloc] init];
                        CAAnimationGroup* rlAnimation = [swapAction startSwapAction:startPosition duration:startDuration orientation:ADTransitionRightToLeft sourceRect:frame];
                        CAAnimationGroup* lrAnimation = [swapAction startSwapAction:startPosition duration:startDuration orientation:ADTransitionLeftToRight sourceRect:frame];
                        CAAnimationGroup* tbAnimation = [swapAction startSwapAction:startPosition duration:startDuration orientation:ADTransitionTopToBottom sourceRect:frame];
                        CAAnimationGroup* btAnimation = [swapAction startSwapAction:startPosition duration:startDuration orientation:ADTransitionBottomToTop sourceRect:frame];
                        
                        [overlayLayerRL addAnimation:rlAnimation forKey:nil];
                        [overlayLayerLR addAnimation:lrAnimation forKey:nil];
                        [overlayLayerTB addAnimation:tbAnimation forKey:nil];
                        [overlayLayer addAnimation:btAnimation forKey:nil];
                        
                        
                        if (object.endActionType == ACTION_SWAP_ALL)
                        {
                            CFTimeInterval endPosition = AVCoreAnimationBeginTimeAtZero +  object.mfEndPosition - object.mfEndAnimationDuration;
                            CFTimeInterval endDuration = object.mfEndAnimationDuration;
                            
                            SwapAction* swapAction = [[SwapAction alloc] init];
                            CAAnimationGroup* rlAnimation = [swapAction endSwapAction:endPosition duration:endDuration orientation:ADTransitionRightToLeft sourceRect:frame fromTransform:inTranslationTransform fromZoomValue:toZoomValue];
                            CAAnimationGroup* lrAnimation = [swapAction endSwapAction:endPosition duration:endDuration orientation:ADTransitionLeftToRight sourceRect:frame fromTransform:inTranslationTransform fromZoomValue:toZoomValue];
                            CAAnimationGroup* tbAnimation = [swapAction endSwapAction:endPosition duration:endDuration orientation:ADTransitionTopToBottom sourceRect:frame fromTransform:inTranslationTransform fromZoomValue:toZoomValue];
                            CAAnimationGroup* btAnimation = [swapAction endSwapAction:endPosition duration:endDuration orientation:ADTransitionBottomToTop sourceRect:frame fromTransform:inTranslationTransform fromZoomValue:toZoomValue];
                            
                            [overlayLayerRL addAnimation:rlAnimation forKey:nil];
                            [overlayLayerLR addAnimation:lrAnimation forKey:nil];
                            [overlayLayerTB addAnimation:tbAnimation forKey:nil];
                            [overlayLayer addAnimation:btAnimation forKey:nil];
                            
                            [parentLayer addSublayer:overlayLayerRL];
                            [parentLayer addSublayer:overlayLayerLR];
                            [parentLayer addSublayer:overlayLayerTB];
                            [parentLayer addSublayer:overlayLayer];
                            
                            continue;
                        }
                        else
                        {
                            CAAnimationGroup* fadeAnimation = [self endFadeAction:(startPosition+startDuration) duration:MIN_DURATION fromTransform:inTranslationTransform fromZoomValue:toZoomValue];
                            [overlayLayerRL addAnimation:fadeAnimation forKey:nil];
                            [overlayLayerLR addAnimation:fadeAnimation forKey:nil];
                            [overlayLayerTB addAnimation:fadeAnimation forKey:nil];
                            
                            [parentLayer addSublayer:overlayLayerRL];
                            [parentLayer addSublayer:overlayLayerLR];
                            [parentLayer addSublayer:overlayLayerTB];
                        }
                    }
                    else if (object.startActionType == ACTION_ZOOM_ALL)   //ZoomAll
                    {
                        CALayer *overlayLayerRL = [CALayer layer];
                        overlayLayerRL.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
                        overlayLayerRL.backgroundColor = [UIColor clearColor].CGColor;
                        
                        CALayer *overlayLayerLR = [CALayer layer];
                        overlayLayerLR.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
                        overlayLayerLR.backgroundColor = [UIColor clearColor].CGColor;
                        
                        CALayer *overlayLayerTB = [CALayer layer];
                        overlayLayerTB.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
                        overlayLayerTB.backgroundColor = [UIColor clearColor].CGColor;

                        CALayer *overlayLayerBT = [CALayer layer];
                        overlayLayerBT.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
                        overlayLayerBT.backgroundColor = [UIColor clearColor].CGColor;
                        
                        NSMutableArray* layersArray = [[NSMutableArray alloc] initWithObjects:overlayLayer, overlayLayerRL, overlayLayerLR, overlayLayerTB, overlayLayerBT, nil];
                        [self setOverlayLayerContents:object layers:layersArray];

                        
                        CFTimeInterval startPosition = AVCoreAnimationBeginTimeAtZero + object.mfStartPosition;
                        CFTimeInterval startDuration = object.mfStartAnimationDuration;
                        CGRect frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
                        
                        CAAnimationGroup* rlAnimation = [self startZoomAction:startPosition duration:startDuration type:ACTION_ZOOM_RL sourceRect:frame];
                        CAAnimationGroup* lrAnimation = [self startZoomAction:startPosition duration:startDuration type:ACTION_ZOOM_LR sourceRect:frame];
                        CAAnimationGroup* tbAnimation = [self startZoomAction:startPosition duration:startDuration type:ACTION_ZOOM_TB sourceRect:frame];
                        CAAnimationGroup* btAnimation = [self startZoomAction:startPosition duration:startDuration type:ACTION_ZOOM_BT sourceRect:frame];
                        CAAnimationGroup* ccAnimation = [self startZoomAction:startPosition duration:startDuration type:ACTION_ZOOM_CC sourceRect:frame];
                        
                        [overlayLayerRL addAnimation:rlAnimation forKey:nil];
                        [overlayLayerLR addAnimation:lrAnimation forKey:nil];
                        [overlayLayerTB addAnimation:tbAnimation forKey:nil];
                        [overlayLayerBT addAnimation:btAnimation forKey:nil];
                        [overlayLayer addAnimation:ccAnimation forKey:nil];
                        
                        if (object.endActionType == ACTION_ZOOM_ALL)
                        {
                            CFTimeInterval endPosition = AVCoreAnimationBeginTimeAtZero +  object.mfEndPosition - object.mfEndAnimationDuration;
                            CFTimeInterval endDuration = object.mfEndAnimationDuration;
                            
                            CAAnimationGroup* rlAnimation = [self endZoomAction:endPosition duration:endDuration type:ACTION_ZOOM_RL sourceRect:frame fromTransform:inTranslationTransform fromZoomValue:toZoomValue];
                            CAAnimationGroup* lrAnimation = [self endZoomAction:endPosition duration:endDuration type:ACTION_ZOOM_LR sourceRect:frame fromTransform:inTranslationTransform fromZoomValue:toZoomValue];
                            CAAnimationGroup* tbAnimation = [self endZoomAction:endPosition duration:endDuration type:ACTION_ZOOM_TB sourceRect:frame fromTransform:inTranslationTransform fromZoomValue:toZoomValue];
                            CAAnimationGroup* btAnimation = [self endZoomAction:endPosition duration:endDuration type:ACTION_ZOOM_BT sourceRect:frame fromTransform:inTranslationTransform fromZoomValue:toZoomValue];
                            CAAnimationGroup* ccAnimation = [self endZoomAction:endPosition duration:endDuration type:ACTION_ZOOM_CC sourceRect:frame fromTransform:inTranslationTransform fromZoomValue:toZoomValue];
                            
                            [overlayLayerRL addAnimation:rlAnimation forKey:nil];
                            [overlayLayerLR addAnimation:lrAnimation forKey:nil];
                            [overlayLayerTB addAnimation:tbAnimation forKey:nil];
                            [overlayLayerBT addAnimation:btAnimation forKey:nil];
                            [overlayLayer addAnimation:ccAnimation forKey:nil];
                            
                            [parentLayer addSublayer:overlayLayerRL];
                            [parentLayer addSublayer:overlayLayerLR];
                            [parentLayer addSublayer:overlayLayerTB];
                            [parentLayer addSublayer:overlayLayerBT];
                            [parentLayer addSublayer:overlayLayer];
                            
                            continue;
                        }
                        else
                        {
                            CAAnimationGroup* fadeAnimation = [self endFadeAction:(startPosition+startDuration) duration:MIN_DURATION fromTransform:inTranslationTransform fromZoomValue:toZoomValue];
                            [overlayLayerRL addAnimation:fadeAnimation forKey:nil];
                            [overlayLayerLR addAnimation:fadeAnimation forKey:nil];
                            [overlayLayerTB addAnimation:fadeAnimation forKey:nil];
                            [overlayLayerBT addAnimation:fadeAnimation forKey:nil];
                            
                            [parentLayer addSublayer:overlayLayerRL];
                            [parentLayer addSublayer:overlayLayerLR];
                            [parentLayer addSublayer:overlayLayerTB];
                            [parentLayer addSublayer:overlayLayerBT];
                        }
                    }
                    else if ((object.startActionType == ACTION_GENIE_BT)||(object.startActionType == ACTION_GENIE_TB)||(object.startActionType == ACTION_GENIE_LR)||(object.startActionType == ACTION_GENIE_RL))
                    {
                        [self setOverlayLayerContents:object layer:overlayLayer];

                        ADTransitionOrientation orientation = ADTransitionLeftToRight;
                        
                        switch (object.startActionType)
                        {
                            case ACTION_GENIE_RL:
                                orientation = ADTransitionRightToLeft;
                                break;
                            case ACTION_GENIE_LR:
                                orientation = ADTransitionLeftToRight;
                                break;
                            case ACTION_GENIE_TB:
                                orientation = ADTransitionBottomToTop;
                                break;
                            case ACTION_GENIE_BT:
                                orientation = ADTransitionTopToBottom;
                                break;
                                
                            default:
                                orientation = ADTransitionRightToLeft;
                                break;
                        }

                        GenieAction* genieAction = [[GenieAction alloc] init];
                        
                        CFTimeInterval startPosition = AVCoreAnimationBeginTimeAtZero + object.mfStartPosition;
                        CFTimeInterval startDuration = object.mfStartAnimationDuration;
                        CGRect frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
                        
                        UIImage *overlayImage = nil;
                        
                        if (object.isKbEnabled)
                        {
                            overlayImage = [object renderingKenBurnsImage:YES];
                        }
                        else
                        {
                            if (gnOutputVideoFilterIndex == 0)
                            {
                                overlayImage = object.renderedImage;
                            }
                            else if (gnOutputVideoFilterIndex == 1)
                            {
                                if (object.isImitationPhoto)
                                    overlayImage = [object renderingOutlineAndShadow];
                                else
                                    overlayImage = object.renderedImage;
                            }
                        }
                        
                        overlayImage = [overlayImage rescaleImageToSize:videoSize];
                        
                        NSMutableArray* overlayLayers = [genieAction startGenieAction:overlayImage startPosition:startPosition duration:startDuration orientation:orientation sourceRect:frame];
                        
                        for (CALayer* layer in overlayLayers)
                        {
                            CABasicAnimation* startAnimation = [self startNoneAction:startPosition duration:MIN_DURATION];
                            [layer addAnimation:startAnimation forKey:nil];
                            
                            [parentLayer addSublayer:layer];
                        }
                        
                        
                        CABasicAnimation *animation = [self startNoneAction:(startPosition + object.mfStartAnimationDuration - MIN_DURATION) duration:MIN_DURATION];
                        [overlayLayer addAnimation:animation forKey:nil];
                    }
                    else if ((object.startActionType == ACTION_GENIE_TL)||(object.startActionType == ACTION_GENIE_TR)||(object.startActionType == ACTION_GENIE_BL)||(object.startActionType == ACTION_GENIE_BR))
                    {
                        [self setOverlayLayerContents:object layer:overlayLayer];

                        ADTransitionOrientation orientation = ADTransitionLeftToRight;
                        
                        switch (object.startActionType) {
                            case ACTION_GENIE_TR:
                                orientation = ADTransitionRightToLeft;
                                break;
                            case ACTION_GENIE_TL:
                                orientation = ADTransitionLeftToRight;
                                break;
                            case ACTION_GENIE_BL:
                                orientation = ADTransitionTopToBottom;
                                break;
                            case ACTION_GENIE_BR:
                                orientation = ADTransitionBottomToTop;
                                break;
                                
                            default:
                                orientation = ADTransitionRightToLeft;
                                break;
                        }
                        
                        SuckAction* suckAction = [[SuckAction alloc] init];
                        
                        CFTimeInterval startPosition = AVCoreAnimationBeginTimeAtZero + object.mfStartPosition;
                        CFTimeInterval startDuration = object.mfStartAnimationDuration;
                        CGRect frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
                        
                        UIImage *overlayImage = nil;
                        
                        if (object.isKbEnabled)
                        {
                            overlayImage = [object renderingKenBurnsImage:YES];
                        }
                        else
                        {
                            if (gnOutputVideoFilterIndex == 0)
                            {
                                overlayImage = object.renderedImage;
                            }
                            else if (gnOutputVideoFilterIndex == 1)
                            {
                                if (object.isImitationPhoto)
                                    overlayImage = [object renderingOutlineAndShadow];
                                else
                                    overlayImage = object.renderedImage;
                            }
                        }

                        overlayImage = [overlayImage rescaleImageToSize:videoSize];

                        NSMutableArray* overlayLayers = [suckAction startSuckAction:overlayImage startPosition:startPosition duration:startDuration orientation:orientation sourceRect:frame];
                        
                        for (CALayer* layer in overlayLayers)
                        {
                            CABasicAnimation* startAnimation = [self startNoneAction:startPosition duration:MIN_DURATION];
                            [layer addAnimation:startAnimation forKey:nil];
                            
                            [parentLayer addSublayer:layer];
                        }
                        
                        
                        CABasicAnimation *animation = [self startNoneAction:(startPosition + object.mfStartAnimationDuration - MIN_DURATION) duration:MIN_DURATION];
                        [overlayLayer addAnimation:animation forKey:nil];
                    }
                    else if ((object.startActionType >= ACTION_REVEAL_BT)&&(object.startActionType <= ACTION_REVEAL_TB))
                    {
                        [self setOverlayLayerContents:object layer:overlayLayer];

                        ADTransitionOrientation orientation = ADTransitionLeftToRight;
                        
                        switch (object.startActionType)
                        {
                            case ACTION_REVEAL_RL:
                                orientation = ADTransitionRightToLeft;
                                break;
                            case ACTION_REVEAL_LR:
                                orientation = ADTransitionLeftToRight;
                                break;
                            case ACTION_REVEAL_TB:
                                orientation = ADTransitionTopToBottom;
                                break;
                            case ACTION_REVEAL_BT:
                                orientation = ADTransitionBottomToTop;
                                break;
                                
                            default:
                                orientation = ADTransitionRightToLeft;
                                break;
                        }
                        
                        RevealAction* revealAction = [[RevealAction alloc] init];
                        
                        CFTimeInterval startPosition = AVCoreAnimationBeginTimeAtZero + object.mfStartPosition;
                        CFTimeInterval startDuration = object.mfStartAnimationDuration;
                        CGRect frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
                        
                        CAAnimationGroup* animation = [revealAction startRevealAction:startPosition duration:startDuration orientation:orientation sourceRect:frame];
                        [overlayLayer addAnimation:animation forKey:nil];
                    }
                    else if (object.startActionType == ACTION_EXPLODE)
                    {
                        [self setOverlayLayerContents:object layer:overlayLayer];

                        ExplodeAction* explodeAction = [[ExplodeAction alloc] init];
                        
                        CFTimeInterval startPosition = AVCoreAnimationBeginTimeAtZero + object.mfStartPosition;
                        CFTimeInterval startDuration = object.mfStartAnimationDuration;
                        CGRect frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
                        
                        UIImage *overlayImage = nil;
                        
                        if (object.isKbEnabled)
                        {
                            overlayImage = [object renderingKenBurnsImage:YES];
                        }
                        else
                        {
                            if (gnOutputVideoFilterIndex == 0)
                            {
                                overlayImage = object.renderedImage;
                            }
                            else if (gnOutputVideoFilterIndex == 1)
                            {
                                if (object.isImitationPhoto)
                                    overlayImage = [object renderingOutlineAndShadow];
                                else
                                    overlayImage = object.renderedImage;
                            }
                        }
                        
                        overlayImage = [overlayImage rescaleImageToSize:videoSize];
                        
                        if (!object.isImitationPhoto)
                        {
                            NSMutableArray* overlayLayers = [explodeAction startExplodeAction:overlayImage startPosition:startPosition duration:startDuration sourceRect:frame];
                            
                            for (CALayer* layer in overlayLayers)
                            {
                                CABasicAnimation* startAnimation = [self startNoneAction:startPosition duration:MIN_DURATION];
                                [layer addAnimation:startAnimation forKey:nil];
                                
                                CAAnimationGroup* endAnimation = [self endNoneAction:(startPosition + startDuration - MIN_DURATION) duration:MIN_DURATION fromTransform:inTranslationTransform fromZoomValue:toZoomValue];
                                [layer addAnimation:endAnimation forKey:nil];
                                
                                [parentLayer addSublayer:layer];
                            }
                        }
                        
                        CABasicAnimation *animation = [self startNoneAction:(startPosition + startDuration - MIN_DURATION) duration:MIN_DURATION];
                        [overlayLayer addAnimation:animation forKey:nil];
                    }
                    else
                    {
                        [self setOverlayLayerContents:object layer:overlayLayer];

                        CFTimeInterval startPosition = AVCoreAnimationBeginTimeAtZero + object.mfStartPosition;
                        CABasicAnimation* startAnimation = [self startNoneAction:startPosition duration:MIN_DURATION];
                        [overlayLayer addAnimation:startAnimation forKey:nil];

                        CAAnimationGroup *startAnimationGroup = [self getStartGroupAction:object];
                        [overlayLayer addAnimation:startAnimationGroup forKey:nil];
                    }
                }
                
                /****************************
                 end animation
                 ****************************/
                if ((object.endActionType == ACTION_NONE)||(object.endActionType == ACTION_FADE)||(object.endActionType == ACTION_BLACK))
                {
                    CAAnimationGroup *endAnimation = [self getEndAction:object fromTransform:inTranslationTransform fromZoomValue:toZoomValue];
                    [overlayLayer addAnimation:endAnimation forKey:nil];
                }
                else
                {
                    if (object.endActionType == ACTION_SWAP_ALL)
                    {
                        CALayer *overlayLayerRL = [CALayer layer];
                        overlayLayerRL.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
                        overlayLayerRL.backgroundColor = [UIColor clearColor].CGColor;
                        
                        CALayer *overlayLayerLR = [CALayer layer];
                        overlayLayerLR.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
                        overlayLayerLR.backgroundColor = [UIColor clearColor].CGColor;
                        
                        CALayer *overlayLayerTB = [CALayer layer];
                        overlayLayerTB.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
                        overlayLayerTB.backgroundColor = [UIColor clearColor].CGColor;
                        
                        NSMutableArray* layersArray = [[NSMutableArray alloc] initWithObjects:overlayLayerRL, overlayLayerLR, overlayLayerTB, nil];
                        [self setOverlayLayerContents:object layers:layersArray];

                        CFTimeInterval endPosition = AVCoreAnimationBeginTimeAtZero + object.mfEndPosition - object.mfEndAnimationDuration;
                        CFTimeInterval endDuration = object.mfEndAnimationDuration;
                        CGRect frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
                        
                        SwapAction* swapAction = [[SwapAction alloc] init];
                        CAAnimationGroup* rlAnimation = [swapAction endSwapAction:endPosition duration:endDuration orientation:ADTransitionRightToLeft sourceRect:frame fromTransform:inTranslationTransform fromZoomValue:toZoomValue];
                        CAAnimationGroup* lrAnimation = [swapAction endSwapAction:endPosition duration:endDuration orientation:ADTransitionLeftToRight sourceRect:frame fromTransform:inTranslationTransform fromZoomValue:toZoomValue];
                        CAAnimationGroup* tbAnimation = [swapAction endSwapAction:endPosition duration:endDuration orientation:ADTransitionTopToBottom sourceRect:frame fromTransform:inTranslationTransform fromZoomValue:toZoomValue];
                        CAAnimationGroup* btAnimation = [swapAction endSwapAction:endPosition duration:endDuration orientation:ADTransitionBottomToTop sourceRect:frame fromTransform:inTranslationTransform fromZoomValue:toZoomValue];
                        
                        [overlayLayerRL addAnimation:rlAnimation forKey:nil];
                        [overlayLayerLR addAnimation:lrAnimation forKey:nil];
                        [overlayLayerTB addAnimation:tbAnimation forKey:nil];
                        [overlayLayer addAnimation:btAnimation forKey:nil];
                        
                        CABasicAnimation* fadeAnimation = [self startFadeAction:(endPosition - MIN_DURATION) duration:MIN_DURATION];
                        [overlayLayerRL addAnimation:fadeAnimation forKey:nil];
                        [overlayLayerLR addAnimation:fadeAnimation forKey:nil];
                        [overlayLayerTB addAnimation:fadeAnimation forKey:nil];
                        
                        [parentLayer addSublayer:overlayLayerRL];
                        [parentLayer addSublayer:overlayLayerLR];
                        [parentLayer addSublayer:overlayLayerTB];
                        [parentLayer addSublayer:overlayLayer];
                        
                        continue;
                    }
                    else if (object.endActionType == ACTION_ZOOM_ALL)
                    {
                        CALayer *overlayLayerRL = [CALayer layer];
                        overlayLayerRL.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
                        overlayLayerRL.backgroundColor = [UIColor clearColor].CGColor;
                        
                        CALayer *overlayLayerLR = [CALayer layer];
                        overlayLayerLR.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
                        overlayLayerLR.backgroundColor = [UIColor clearColor].CGColor;
                        
                        CALayer *overlayLayerTB = [CALayer layer];
                        overlayLayerTB.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
                        overlayLayerTB.backgroundColor = [UIColor clearColor].CGColor;
                        
                        CALayer *overlayLayerBT = [CALayer layer];
                        overlayLayerBT.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
                        overlayLayerBT.backgroundColor = [UIColor clearColor].CGColor;
                        
                        NSMutableArray* layersArray = [[NSMutableArray alloc] initWithObjects:overlayLayerRL, overlayLayerLR, overlayLayerTB, overlayLayerBT, nil];
                        [self setOverlayLayerContents:object layers:layersArray];
                        
                        CFTimeInterval endPosition = AVCoreAnimationBeginTimeAtZero + object.mfEndPosition - object.mfEndAnimationDuration;
                        CFTimeInterval endDuration = object.mfEndAnimationDuration;
                        CGRect frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
                        
                        CAAnimationGroup* rlAnimation = [self endZoomAction:endPosition duration:endDuration type:ACTION_ZOOM_RL sourceRect:frame fromTransform:inTranslationTransform fromZoomValue:toZoomValue];
                        CAAnimationGroup* lrAnimation = [self endZoomAction:endPosition duration:endDuration type:ACTION_ZOOM_LR sourceRect:frame fromTransform:inTranslationTransform fromZoomValue:toZoomValue];
                        CAAnimationGroup* tbAnimation = [self endZoomAction:endPosition duration:endDuration type:ACTION_ZOOM_TB sourceRect:frame fromTransform:inTranslationTransform fromZoomValue:toZoomValue];
                        CAAnimationGroup* btAnimation = [self endZoomAction:endPosition duration:endDuration type:ACTION_ZOOM_BT sourceRect:frame fromTransform:inTranslationTransform fromZoomValue:toZoomValue];
                        CAAnimationGroup* ccAnimation = [self endZoomAction:endPosition duration:endDuration type:ACTION_ZOOM_CC sourceRect:frame fromTransform:inTranslationTransform fromZoomValue:toZoomValue];
                        
                        [overlayLayerRL addAnimation:rlAnimation forKey:nil];
                        [overlayLayerLR addAnimation:lrAnimation forKey:nil];
                        [overlayLayerTB addAnimation:tbAnimation forKey:nil];
                        [overlayLayerBT addAnimation:btAnimation forKey:nil];
                        [overlayLayer addAnimation:ccAnimation forKey:nil];
                        
                        CABasicAnimation* fadeAnimation = [self startFadeAction:(endPosition - MIN_DURATION) duration:MIN_DURATION];
                        [overlayLayerRL addAnimation:fadeAnimation forKey:nil];
                        [overlayLayerLR addAnimation:fadeAnimation forKey:nil];
                        [overlayLayerTB addAnimation:fadeAnimation forKey:nil];
                        [overlayLayerBT addAnimation:fadeAnimation forKey:nil];
                        
                        [parentLayer addSublayer:overlayLayerRL];
                        [parentLayer addSublayer:overlayLayerLR];
                        [parentLayer addSublayer:overlayLayerTB];
                        [parentLayer addSublayer:overlayLayerBT];
                        [parentLayer addSublayer:overlayLayer];
                        
                        continue;
                    }
                    else if ((object.endActionType == ACTION_GENIE_BT)||(object.endActionType == ACTION_GENIE_TB)||(object.endActionType == ACTION_GENIE_LR)||(object.endActionType == ACTION_GENIE_RL))
                    {
                        ADTransitionOrientation orientation = ADTransitionLeftToRight;
                        
                        switch (object.endActionType)
                        {
                            case ACTION_GENIE_RL:
                                orientation = ADTransitionRightToLeft;
                                break;
                            case ACTION_GENIE_LR:
                                orientation = ADTransitionLeftToRight;
                                break;
                            case ACTION_GENIE_TB:
                                orientation = ADTransitionBottomToTop;
                                break;
                            case ACTION_GENIE_BT:
                                orientation = ADTransitionTopToBottom;
                                break;
                                
                            default:
                                orientation = ADTransitionRightToLeft;
                                break;
                        }
                        
                        GenieAction* genieAction = [[GenieAction alloc] init];
                        
                        CFTimeInterval endPosition = AVCoreAnimationBeginTimeAtZero +  object.mfEndPosition - object.mfEndAnimationDuration;
                        CFTimeInterval endDuration = object.mfEndAnimationDuration;
                        CGRect frame = CGRectMake(0, 0, videoSize.width, videoSize.height);

                        UIImage *overlayImage = nil;
                        
                        if (object.isKbEnabled)
                        {
                            overlayImage = [object renderingKenBurnsImage:NO];
                        }
                        else
                        {
                            if (gnOutputVideoFilterIndex == 0)
                            {
                                overlayImage = object.renderedImage;
                            }
                            else if (gnOutputVideoFilterIndex == 1)
                            {
                                if (object.isImitationPhoto)
                                    overlayImage = [object renderingOutlineAndShadow];
                                else
                                    overlayImage = object.renderedImage;
                            }
                        }
                        
                        overlayImage = [overlayImage rescaleImageToSize:videoSize];

                        NSMutableArray* overlayLayers = [genieAction endGenieAction:overlayImage endPosition:endPosition duration:endDuration orientation:orientation sourceRect:frame];
                        
                        for (CALayer* layer in overlayLayers)
                        {
                            CABasicAnimation* startAnimation = [self startNoneAction:endPosition duration:MIN_DURATION];
                            [layer addAnimation:startAnimation forKey:nil];

                            [parentLayer addSublayer:layer];
                        }
                        
                        CAAnimationGroup* endAnimation = [self endNoneAction:endPosition duration:MIN_DURATION fromTransform:inTranslationTransform fromZoomValue:toZoomValue];
                        [overlayLayer addAnimation:endAnimation forKey:nil];
                    }
                    else if ((object.endActionType == ACTION_GENIE_BL)||(object.endActionType == ACTION_GENIE_BR)||(object.endActionType == ACTION_GENIE_TL)||(object.endActionType == ACTION_GENIE_TR))
                    {
                        ADTransitionOrientation orientation = ADTransitionLeftToRight;
                        
                        switch (object.endActionType)
                        {
                            case ACTION_GENIE_TR:
                                orientation = ADTransitionRightToLeft;
                                break;
                            case ACTION_GENIE_TL:
                                orientation = ADTransitionLeftToRight;
                                break;
                            case ACTION_GENIE_BL:
                                orientation = ADTransitionTopToBottom;
                                break;
                            case ACTION_GENIE_BR:
                                orientation = ADTransitionBottomToTop;
                                break;
                                
                            default:
                                orientation = ADTransitionRightToLeft;
                                break;
                        }
                        
                        SuckAction* suckAction = [[SuckAction alloc] init];
                        
                        CFTimeInterval endPosition = AVCoreAnimationBeginTimeAtZero +  object.mfEndPosition - object.mfEndAnimationDuration;
                        CFTimeInterval endDuration = object.mfEndAnimationDuration;
                        CGRect frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
                        
                        UIImage *overlayImage = nil;
                        
                        if (object.isKbEnabled)
                        {
                            overlayImage = [object renderingKenBurnsImage:NO];
                        }
                        else
                        {
                            if (gnOutputVideoFilterIndex == 0)
                            {
                                overlayImage = object.renderedImage;
                            }
                            else if (gnOutputVideoFilterIndex == 1)
                            {
                                if (object.isImitationPhoto)
                                    overlayImage = [object renderingOutlineAndShadow];
                                else
                                    overlayImage = object.renderedImage;
                            }
                        }
                        
                        overlayImage = [overlayImage rescaleImageToSize:videoSize];

                        NSMutableArray* overlayLayers = [suckAction endSuckAction:overlayImage endPosition:endPosition duration:endDuration orientation:orientation sourceRect:frame];
                        
                        for (CALayer* layer in overlayLayers)
                        {
                            CABasicAnimation* startAnimation = [self startNoneAction:endPosition duration:MIN_DURATION];
                            [layer addAnimation:startAnimation forKey:nil];
                            
                            [parentLayer addSublayer:layer];
                        }
                        
                        CAAnimationGroup* endAnimation = [self endNoneAction:endPosition duration:MIN_DURATION fromTransform:inTranslationTransform fromZoomValue:toZoomValue];
                        [overlayLayer addAnimation:endAnimation forKey:nil];
                    }
                    else if ((object.endActionType >= ACTION_REVEAL_BT)&&(object.endActionType <= ACTION_REVEAL_TB))
                    {
                        ADTransitionOrientation orientation = ADTransitionLeftToRight;
                        
                        switch (object.endActionType)
                        {
                            case ACTION_REVEAL_RL:
                                orientation = ADTransitionRightToLeft;
                                break;
                            case ACTION_REVEAL_LR:
                                orientation = ADTransitionLeftToRight;
                                break;
                            case ACTION_REVEAL_TB:
                                orientation = ADTransitionTopToBottom;
                                break;
                            case ACTION_REVEAL_BT:
                                orientation = ADTransitionBottomToTop;
                                break;
                                
                            default:
                                orientation = ADTransitionRightToLeft;
                                break;
                        }
                        
                        RevealAction* revealAction = [[RevealAction alloc] init];
                        
                        CFTimeInterval endPosition = AVCoreAnimationBeginTimeAtZero +  object.mfEndPosition - object.mfEndAnimationDuration - MIN_DURATION;
                        CFTimeInterval endDuration = object.mfEndAnimationDuration;
                        CGRect frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
                        
                        CAAnimationGroup* animation = [revealAction endRevealAction:endPosition duration:endDuration orientation:orientation sourceRect:frame fromTransform:inTranslationTransform fromZoomValue:toZoomValue];
                        [overlayLayer addAnimation:animation forKey:nil];
                    }
                    else if (object.endActionType == ACTION_EXPLODE)
                    {
                        ExplodeAction* explodeAction = [[ExplodeAction alloc] init];
                        
                        CFTimeInterval endPosition = AVCoreAnimationBeginTimeAtZero +  object.mfEndPosition - object.mfEndAnimationDuration - MIN_DURATION;
                        CFTimeInterval endDuration = object.mfEndAnimationDuration;
                        CGRect frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
                        
                        UIImage *overlayImage = nil;
                        
                        if (object.isKbEnabled)
                        {
                            overlayImage = [object renderingKenBurnsImage:NO];
                        }
                        else
                        {
                            if (gnOutputVideoFilterIndex == 0)
                            {
                                overlayImage = object.renderedImage;
                            }
                            else if (gnOutputVideoFilterIndex == 1)
                            {
                                if (object.isImitationPhoto)
                                    overlayImage = [object renderingOutlineAndShadow];
                                else
                                    overlayImage = object.renderedImage;
                            }
                        }
                        
                        overlayImage = [overlayImage rescaleImageToSize:videoSize];

                        if (!object.isImitationPhoto)
                        {
                            NSMutableArray* overlayLayers = [explodeAction endExplodeAction:overlayImage endPosition:endPosition duration:endDuration sourceRect:frame];
                            
                            for (CALayer* layer in overlayLayers)
                            {
                                CABasicAnimation* startAnimation = [self startNoneAction:endPosition duration:MIN_DURATION];
                                [layer addAnimation:startAnimation forKey:nil];
                                
                                [parentLayer addSublayer:layer];
                            }
                        }
                        
                        CAAnimationGroup* endAnimation = [self endNoneAction:endPosition duration:MIN_DURATION fromTransform:inTranslationTransform fromZoomValue:toZoomValue];
                        [overlayLayer addAnimation:endAnimation forKey:nil];
                    }
                    else
                    {
                        CAAnimationGroup *endAnimationGroup = [self getEndGroupAction:object fromTransform:inTranslationTransform fromZoomValue:toZoomValue];
                        [overlayLayer addAnimation:endAnimationGroup forKey:nil];
                    }
                }
                
                if (!object.isPhotoFromVideo)
                {
                    [parentLayer addSublayer:overlayLayer];
                }
            }
            else if (object.mediaType == MEDIA_TEXT)
            {
                CALayer *overlayLayer = [CALayer layer];
                overlayLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
                overlayLayer.backgroundColor = [UIColor clearColor].CGColor;

                if ((object.startActionType == ACTION_NONE)||(object.startActionType == ACTION_FADE)||(object.startActionType == ACTION_BLACK))
                {
                    [self setOverlayLayerContents:object layer:overlayLayer];

                    CABasicAnimation *startAnimation = [self getStartAction:object];
                    [overlayLayer addAnimation:startAnimation forKey:nil];
                }
                else
                {
                    if (object.startActionType == ACTION_SWAP_ALL)    //SwapAll
                    {
                        CALayer *overlayLayerRL = [CALayer layer];
                        overlayLayerRL.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
                        overlayLayerRL.backgroundColor = [UIColor clearColor].CGColor;
                        
                        CALayer *overlayLayerLR = [CALayer layer];
                        overlayLayerLR.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
                        overlayLayerLR.backgroundColor = [UIColor clearColor].CGColor;
                        
                        CALayer *overlayLayerTB = [CALayer layer];
                        overlayLayerTB.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
                        overlayLayerTB.backgroundColor = [UIColor clearColor].CGColor;

                        NSMutableArray* layersArray = [[NSMutableArray alloc] initWithObjects:overlayLayer, overlayLayerRL, overlayLayerLR, overlayLayerTB, nil];
                        [self setOverlayLayerContents:object layers:layersArray];

                        CFTimeInterval startPosition = AVCoreAnimationBeginTimeAtZero + object.mfStartPosition;
                        CFTimeInterval startDuration = object.mfStartAnimationDuration;
                        CGRect frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
                        
                        SwapAction* swapAction = [[SwapAction alloc] init];
                        CAAnimationGroup* rlAnimation = [swapAction startSwapAction:startPosition duration:startDuration orientation:ADTransitionRightToLeft sourceRect:frame];
                        CAAnimationGroup* lrAnimation = [swapAction startSwapAction:startPosition duration:startDuration orientation:ADTransitionLeftToRight sourceRect:frame];
                        CAAnimationGroup* tbAnimation = [swapAction startSwapAction:startPosition duration:startDuration orientation:ADTransitionTopToBottom sourceRect:frame];
                        CAAnimationGroup* btAnimation = [swapAction startSwapAction:startPosition duration:startDuration orientation:ADTransitionBottomToTop sourceRect:frame];
                        
                        [overlayLayerRL addAnimation:rlAnimation forKey:nil];
                        [overlayLayerLR addAnimation:lrAnimation forKey:nil];
                        [overlayLayerTB addAnimation:tbAnimation forKey:nil];
                        [overlayLayer addAnimation:btAnimation forKey:nil];
                        
                        if (object.endActionType == ACTION_SWAP_ALL) {
                            
                            CFTimeInterval endPosition = AVCoreAnimationBeginTimeAtZero +  object.mfEndPosition - object.mfEndAnimationDuration;
                            CFTimeInterval endDuration = object.mfEndAnimationDuration;
                            
                            SwapAction* swapAction = [[SwapAction alloc] init];
                            CAAnimationGroup* rlAnimation = [swapAction endSwapAction:endPosition duration:endDuration orientation:ADTransitionRightToLeft sourceRect:frame fromTransform:inTranslationTransform fromZoomValue:toZoomValue];
                            CAAnimationGroup* lrAnimation = [swapAction endSwapAction:endPosition duration:endDuration orientation:ADTransitionLeftToRight sourceRect:frame fromTransform:inTranslationTransform fromZoomValue:toZoomValue];
                            CAAnimationGroup* tbAnimation = [swapAction endSwapAction:endPosition duration:endDuration orientation:ADTransitionTopToBottom sourceRect:frame fromTransform:inTranslationTransform fromZoomValue:toZoomValue];
                            CAAnimationGroup* btAnimation = [swapAction endSwapAction:endPosition duration:endDuration orientation:ADTransitionBottomToTop sourceRect:frame fromTransform:inTranslationTransform fromZoomValue:toZoomValue];
                            
                            [overlayLayerRL addAnimation:rlAnimation forKey:nil];
                            [overlayLayerLR addAnimation:lrAnimation forKey:nil];
                            [overlayLayerTB addAnimation:tbAnimation forKey:nil];
                            [overlayLayer addAnimation:btAnimation forKey:nil];
                            
                            [parentLayer addSublayer:overlayLayerRL];
                            [parentLayer addSublayer:overlayLayerLR];
                            [parentLayer addSublayer:overlayLayerTB];
                            [parentLayer addSublayer:overlayLayer];
                            
                            continue;
                        }
                        else
                        {
                            CAAnimationGroup* fadeAnimation = [self endFadeAction:(startPosition+startDuration) duration:MIN_DURATION  fromTransform:inTranslationTransform fromZoomValue:toZoomValue];
                            [overlayLayerRL addAnimation:fadeAnimation forKey:nil];
                            [overlayLayerLR addAnimation:fadeAnimation forKey:nil];
                            [overlayLayerTB addAnimation:fadeAnimation forKey:nil];
                            
                            [parentLayer addSublayer:overlayLayerRL];
                            [parentLayer addSublayer:overlayLayerLR];
                            [parentLayer addSublayer:overlayLayerTB];
                        }
                    }
                    else if (object.startActionType == ACTION_ZOOM_ALL)   //ZoomAll
                    {
                        CALayer *overlayLayerRL = [CALayer layer];
                        overlayLayerRL.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
                        overlayLayerRL.backgroundColor = [UIColor clearColor].CGColor;
                        
                        CALayer *overlayLayerLR = [CALayer layer];
                        overlayLayerLR.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
                        overlayLayerLR.backgroundColor = [UIColor clearColor].CGColor;
                        
                        CALayer *overlayLayerTB = [CALayer layer];
                        overlayLayerTB.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
                        overlayLayerTB.backgroundColor = [UIColor clearColor].CGColor;
                        
                        CALayer *overlayLayerBT = [CALayer layer];
                        overlayLayerBT.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
                        overlayLayerBT.backgroundColor = [UIColor clearColor].CGColor;

                        NSMutableArray* layersArray = [[NSMutableArray alloc] initWithObjects:overlayLayer, overlayLayerRL, overlayLayerLR, overlayLayerTB, overlayLayerBT, nil];
                        [self setOverlayLayerContents:object layers:layersArray];
                        
                        CFTimeInterval startPosition = AVCoreAnimationBeginTimeAtZero + object.mfStartPosition;
                        CFTimeInterval startDuration = object.mfStartAnimationDuration;
                        CGRect frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
                        
                        CAAnimationGroup* rlAnimation = [self startZoomAction:startPosition duration:startDuration type:ACTION_ZOOM_RL sourceRect:frame];
                        CAAnimationGroup* lrAnimation = [self startZoomAction:startPosition duration:startDuration type:ACTION_ZOOM_LR sourceRect:frame];
                        CAAnimationGroup* tbAnimation = [self startZoomAction:startPosition duration:startDuration type:ACTION_ZOOM_TB sourceRect:frame];
                        CAAnimationGroup* btAnimation = [self startZoomAction:startPosition duration:startDuration type:ACTION_ZOOM_BT sourceRect:frame];
                        CAAnimationGroup* ccAnimation = [self startZoomAction:startPosition duration:startDuration type:ACTION_ZOOM_CC sourceRect:frame];
                        
                        [overlayLayerRL addAnimation:rlAnimation forKey:nil];
                        [overlayLayerLR addAnimation:lrAnimation forKey:nil];
                        [overlayLayerTB addAnimation:tbAnimation forKey:nil];
                        [overlayLayerBT addAnimation:btAnimation forKey:nil];
                        [overlayLayer addAnimation:ccAnimation forKey:nil];
                        
                        if (object.endActionType == ACTION_ZOOM_ALL)
                        {
                            CFTimeInterval endPosition = AVCoreAnimationBeginTimeAtZero +  object.mfEndPosition - object.mfEndAnimationDuration;
                            CFTimeInterval endDuration = object.mfEndAnimationDuration;
                            
                            CAAnimationGroup* rlAnimation = [self endZoomAction:endPosition duration:endDuration type:ACTION_ZOOM_RL sourceRect:frame fromTransform:inTranslationTransform fromZoomValue:toZoomValue];
                            CAAnimationGroup* lrAnimation = [self endZoomAction:endPosition duration:endDuration type:ACTION_ZOOM_LR sourceRect:frame fromTransform:inTranslationTransform fromZoomValue:toZoomValue];
                            CAAnimationGroup* tbAnimation = [self endZoomAction:endPosition duration:endDuration type:ACTION_ZOOM_TB sourceRect:frame fromTransform:inTranslationTransform fromZoomValue:toZoomValue];
                            CAAnimationGroup* btAnimation = [self endZoomAction:endPosition duration:endDuration type:ACTION_ZOOM_BT sourceRect:frame fromTransform:inTranslationTransform fromZoomValue:toZoomValue];
                            CAAnimationGroup* ccAnimation = [self endZoomAction:endPosition duration:endDuration type:ACTION_ZOOM_CC sourceRect:frame fromTransform:inTranslationTransform fromZoomValue:toZoomValue];
                            
                            [overlayLayerRL addAnimation:rlAnimation forKey:nil];
                            [overlayLayerLR addAnimation:lrAnimation forKey:nil];
                            [overlayLayerTB addAnimation:tbAnimation forKey:nil];
                            [overlayLayerBT addAnimation:btAnimation forKey:nil];
                            [overlayLayer addAnimation:ccAnimation forKey:nil];
                            
                            [parentLayer addSublayer:overlayLayerRL];
                            [parentLayer addSublayer:overlayLayerLR];
                            [parentLayer addSublayer:overlayLayerTB];
                            [parentLayer addSublayer:overlayLayerBT];
                            [parentLayer addSublayer:overlayLayer];
                            
                            continue;
                        }
                        else
                        {
                            CAAnimationGroup* fadeAnimation = [self endFadeAction:(startPosition+startDuration) duration:MIN_DURATION fromTransform:inTranslationTransform fromZoomValue:toZoomValue];
                            [overlayLayerRL addAnimation:fadeAnimation forKey:nil];
                            [overlayLayerLR addAnimation:fadeAnimation forKey:nil];
                            [overlayLayerTB addAnimation:fadeAnimation forKey:nil];
                            [overlayLayerBT addAnimation:fadeAnimation forKey:nil];
                            
                            [parentLayer addSublayer:overlayLayerRL];
                            [parentLayer addSublayer:overlayLayerLR];
                            [parentLayer addSublayer:overlayLayerTB];
                            [parentLayer addSublayer:overlayLayerBT];
                        }
                    }
                    else if ((object.startActionType == ACTION_GENIE_BT)||(object.startActionType == ACTION_GENIE_TB)||(object.startActionType == ACTION_GENIE_LR)||(object.startActionType == ACTION_GENIE_RL))
                    {
                        [self setOverlayLayerContents:object layer:overlayLayer];

                        ADTransitionOrientation orientation = ADTransitionLeftToRight;
                        
                        switch (object.startActionType)
                        {
                            case ACTION_GENIE_RL:
                                orientation = ADTransitionRightToLeft;
                                break;
                            case ACTION_GENIE_LR:
                                orientation = ADTransitionLeftToRight;
                                break;
                            case ACTION_GENIE_TB:
                                orientation = ADTransitionBottomToTop;
                                break;
                            case ACTION_GENIE_BT:
                                orientation = ADTransitionTopToBottom;
                                break;
                                
                            default:
                                orientation = ADTransitionRightToLeft;
                                break;
                        }
                        
                        GenieAction* genieAction = [[GenieAction alloc] init];
                        
                        CFTimeInterval startPosition = AVCoreAnimationBeginTimeAtZero + object.mfStartPosition;
                        CFTimeInterval startDuration = object.mfStartAnimationDuration;
                        CGRect frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
                        
                        UIImage *overlayImage = nil;
                        
                        if (object.isKbEnabled)
                            overlayImage = [object renderingKenBurnsImage:YES];
                        else
                            overlayImage = [object renderingTextView];
                        
                        overlayImage = [overlayImage rescaleImageToSize:videoSize];

                        NSMutableArray* overlayLayers = [genieAction startGenieAction:overlayImage startPosition:startPosition duration:startDuration orientation:orientation sourceRect:frame];
                        
                        for (CALayer* layer in overlayLayers)
                        {
                            CABasicAnimation* startAnimation = [self startNoneAction:startPosition duration:MIN_DURATION];
                            [layer addAnimation:startAnimation forKey:nil];
                            
                            [parentLayer addSublayer:layer];
                        }
                        
                        CABasicAnimation *animation = [self startNoneAction:(startPosition + object.mfStartAnimationDuration - MIN_DURATION) duration:MIN_DURATION];
                        [overlayLayer addAnimation:animation forKey:nil];
                    }
                    else if ((object.startActionType == ACTION_GENIE_BL)||(object.startActionType == ACTION_GENIE_BR)||(object.startActionType == ACTION_GENIE_TL)||(object.startActionType == ACTION_GENIE_TR))
                    {
                        [self setOverlayLayerContents:object layer:overlayLayer];

                        ADTransitionOrientation orientation = ADTransitionLeftToRight;
                        
                        switch (object.startActionType)
                        {
                            case ACTION_GENIE_TR:
                                orientation = ADTransitionRightToLeft;
                                break;
                            case ACTION_GENIE_TL:
                                orientation = ADTransitionLeftToRight;
                                break;
                            case ACTION_GENIE_BL:
                                orientation = ADTransitionTopToBottom;
                                break;
                            case ACTION_GENIE_BR:
                                orientation = ADTransitionBottomToTop;
                                break;
                                
                            default:
                                orientation = ADTransitionRightToLeft;
                                break;
                        }
                        
                        SuckAction* suckAction = [[SuckAction alloc] init];
                        
                        CFTimeInterval startPosition = AVCoreAnimationBeginTimeAtZero + object.mfStartPosition;
                        CFTimeInterval startDuration = object.mfStartAnimationDuration;
                        CGRect frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
                        
                        UIImage *overlayImage = nil;
                        
                        if (object.isKbEnabled)
                            overlayImage = [object renderingKenBurnsImage:YES];
                        else
                            overlayImage = [object renderingTextView];

                        overlayImage = [overlayImage rescaleImageToSize:videoSize];

                        NSMutableArray* overlayLayers = [suckAction startSuckAction:overlayImage startPosition:startPosition duration:startDuration orientation:orientation sourceRect:frame];
                        
                        for (CALayer* layer in overlayLayers)
                        {
                            CABasicAnimation* startAnimation = [self startNoneAction:startPosition duration:MIN_DURATION];
                            [layer addAnimation:startAnimation forKey:nil];
                            
                            [parentLayer addSublayer:layer];
                        }
                        
                        CABasicAnimation *animation = [self startNoneAction:(startPosition + object.mfStartAnimationDuration - MIN_DURATION) duration:MIN_DURATION];
                        [overlayLayer addAnimation:animation forKey:nil];
                    }
                    else if ((object.startActionType >= ACTION_REVEAL_BT)&&(object.startActionType <= ACTION_REVEAL_TB))
                    {
                        [self setOverlayLayerContents:object layer:overlayLayer];

                        ADTransitionOrientation orientation = ADTransitionLeftToRight;
                        
                        switch (object.startActionType)
                        {
                            case ACTION_REVEAL_RL:
                                orientation = ADTransitionRightToLeft;
                                break;
                            case ACTION_REVEAL_LR:
                                orientation = ADTransitionLeftToRight;
                                break;
                            case ACTION_REVEAL_TB:
                                orientation = ADTransitionTopToBottom;
                                break;
                            case ACTION_REVEAL_BT:
                                orientation = ADTransitionBottomToTop;
                                break;
                                
                            default:
                                orientation = ADTransitionRightToLeft;
                                break;
                        }
                        
                        RevealAction* revealAction = [[RevealAction alloc] init];
                        
                        CFTimeInterval startPosition = AVCoreAnimationBeginTimeAtZero + object.mfStartPosition;
                        CFTimeInterval startDuration = object.mfStartAnimationDuration;
                        CGRect frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
                        
                        CAAnimationGroup* animation = [revealAction startRevealAction:startPosition duration:startDuration orientation:orientation sourceRect:frame];
                        [overlayLayer addAnimation:animation forKey:nil];
                    }
                    else if (object.startActionType == ACTION_EXPLODE)
                    {
                        [self setOverlayLayerContents:object layer:overlayLayer];

                        ExplodeAction* explodeAction = [[ExplodeAction alloc] init];
                        
                        CFTimeInterval startPosition = AVCoreAnimationBeginTimeAtZero + object.mfStartPosition;
                        CFTimeInterval startDuration = object.mfStartAnimationDuration;
                        CGRect frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
                        
                        UIImage *overlayImage = nil;
                        
                        if (object.isKbEnabled)
                            overlayImage = [object renderingKenBurnsImage:YES];
                        else
                            overlayImage = [object renderingTextView];
                        
                        overlayImage = [overlayImage rescaleImageToSize:videoSize];

                        NSMutableArray* overlayLayers = [explodeAction startExplodeAction:overlayImage startPosition:startPosition duration:startDuration sourceRect:frame];
                        
                        for (CALayer* layer in overlayLayers)
                        {
                            CABasicAnimation* startAnimation = [self startNoneAction:startPosition duration:MIN_DURATION];
                            [layer addAnimation:startAnimation forKey:nil];
                            
                            CAAnimationGroup* endAnimation = [self endNoneAction:(startPosition + startDuration - MIN_DURATION) duration:MIN_DURATION fromTransform:inTranslationTransform fromZoomValue:toZoomValue];
                            [layer addAnimation:endAnimation forKey:nil];
                            
                            [parentLayer addSublayer:layer];
                        }
                        
                        CABasicAnimation *animation = [self startNoneAction:(startPosition + startDuration - MIN_DURATION) duration:MIN_DURATION];
                        [overlayLayer addAnimation:animation forKey:nil];
                    }
                    else
                    {
                        [self setOverlayLayerContents:object layer:overlayLayer];

                        CFTimeInterval startPosition = AVCoreAnimationBeginTimeAtZero + object.mfStartPosition;
                        CABasicAnimation* startAnimation = [self startNoneAction:startPosition duration:MIN_DURATION];
                        [overlayLayer addAnimation:startAnimation forKey:nil];
                        
                        CAAnimationGroup *startAnimationGroup = [self getStartGroupAction:object];
                        [overlayLayer addAnimation:startAnimationGroup forKey:nil];
                    }
                }
                
                /****************************
                 end animation
                 ****************************/
                if ((object.endActionType == ACTION_NONE)||(object.endActionType == ACTION_FADE)||(object.endActionType == ACTION_BLACK))
                {
                    CAAnimationGroup *endAnimation = [self getEndAction:object fromTransform:inTranslationTransform fromZoomValue:toZoomValue];
                    [overlayLayer addAnimation:endAnimation forKey:nil];
                }
                else
                {
                    if (object.endActionType == ACTION_SWAP_ALL)
                    {
                        CALayer *overlayLayerRL = [CALayer layer];
                        overlayLayerRL.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
                        overlayLayerRL.backgroundColor = [UIColor clearColor].CGColor;
                        
                        CALayer *overlayLayerLR = [CALayer layer];
                        overlayLayerLR.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
                        overlayLayerLR.backgroundColor = [UIColor clearColor].CGColor;
                        
                        CALayer *overlayLayerTB = [CALayer layer];
                        overlayLayerTB.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
                        overlayLayerTB.backgroundColor = [UIColor clearColor].CGColor;

                        NSMutableArray* layersArray = [[NSMutableArray alloc] initWithObjects:overlayLayerRL, overlayLayerLR, overlayLayerTB, nil];
                        [self setOverlayLayerContents:object layers:layersArray];
                        
                        CFTimeInterval endPosition = AVCoreAnimationBeginTimeAtZero +  object.mfEndPosition - object.mfEndAnimationDuration;
                        CFTimeInterval endDuration = object.mfEndAnimationDuration;
                        CGRect frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
                        
                        SwapAction* swapAction = [[SwapAction alloc] init];
                        CAAnimationGroup* rlAnimation = [swapAction endSwapAction:endPosition duration:endDuration orientation:ADTransitionRightToLeft sourceRect:frame fromTransform:inTranslationTransform fromZoomValue:toZoomValue];
                        CAAnimationGroup* lrAnimation = [swapAction endSwapAction:endPosition duration:endDuration orientation:ADTransitionLeftToRight sourceRect:frame fromTransform:inTranslationTransform fromZoomValue:toZoomValue];
                        CAAnimationGroup* tbAnimation = [swapAction endSwapAction:endPosition duration:endDuration orientation:ADTransitionTopToBottom sourceRect:frame fromTransform:inTranslationTransform fromZoomValue:toZoomValue];
                        CAAnimationGroup* btAnimation = [swapAction endSwapAction:endPosition duration:endDuration orientation:ADTransitionBottomToTop sourceRect:frame fromTransform:inTranslationTransform fromZoomValue:toZoomValue];
                        
                        [overlayLayerRL addAnimation:rlAnimation forKey:nil];
                        [overlayLayerLR addAnimation:lrAnimation forKey:nil];
                        [overlayLayerTB addAnimation:tbAnimation forKey:nil];
                        [overlayLayer addAnimation:btAnimation forKey:nil];
                        
                        CABasicAnimation* fadeAnimation = [self startFadeAction:(endPosition - MIN_DURATION) duration:MIN_DURATION];
                        [overlayLayerRL addAnimation:fadeAnimation forKey:nil];
                        [overlayLayerLR addAnimation:fadeAnimation forKey:nil];
                        [overlayLayerTB addAnimation:fadeAnimation forKey:nil];
                        
                        [parentLayer addSublayer:overlayLayerRL];
                        [parentLayer addSublayer:overlayLayerLR];
                        [parentLayer addSublayer:overlayLayerTB];
                        [parentLayer addSublayer:overlayLayer];
                        
                        continue;
                    }
                    else if (object.endActionType == ACTION_ZOOM_ALL)
                    {
                        CALayer *overlayLayerRL = [CALayer layer];
                        overlayLayerRL.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
                        overlayLayerRL.backgroundColor = [UIColor clearColor].CGColor;
                        
                        CALayer *overlayLayerLR = [CALayer layer];
                        overlayLayerLR.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
                        overlayLayerLR.backgroundColor = [UIColor clearColor].CGColor;
                        
                        CALayer *overlayLayerTB = [CALayer layer];
                        overlayLayerTB.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
                        overlayLayerTB.backgroundColor = [UIColor clearColor].CGColor;
                        
                        CALayer *overlayLayerBT = [CALayer layer];
                        overlayLayerBT.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
                        overlayLayerBT.backgroundColor = [UIColor clearColor].CGColor;

                        NSMutableArray* layersArray = [[NSMutableArray alloc] initWithObjects:overlayLayerRL, overlayLayerLR, overlayLayerTB, overlayLayerBT, nil];
                        [self setOverlayLayerContents:object layers:layersArray];
                        
                        CFTimeInterval endPosition = AVCoreAnimationBeginTimeAtZero +  object.mfEndPosition - object.mfEndAnimationDuration;
                        CFTimeInterval endDuration = object.mfEndAnimationDuration;
                        CGRect frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
                        
                        CAAnimationGroup* rlAnimation = [self endZoomAction:endPosition duration:endDuration type:ACTION_ZOOM_RL sourceRect:frame fromTransform:inTranslationTransform fromZoomValue:toZoomValue];
                        CAAnimationGroup* lrAnimation = [self endZoomAction:endPosition duration:endDuration type:ACTION_ZOOM_LR sourceRect:frame fromTransform:inTranslationTransform fromZoomValue:toZoomValue];
                        CAAnimationGroup* tbAnimation = [self endZoomAction:endPosition duration:endDuration type:ACTION_ZOOM_TB sourceRect:frame fromTransform:inTranslationTransform fromZoomValue:toZoomValue];
                        CAAnimationGroup* btAnimation = [self endZoomAction:endPosition duration:endDuration type:ACTION_ZOOM_BT sourceRect:frame fromTransform:inTranslationTransform fromZoomValue:toZoomValue];
                        CAAnimationGroup* ccAnimation = [self endZoomAction:endPosition duration:endDuration type:ACTION_ZOOM_CC sourceRect:frame fromTransform:inTranslationTransform fromZoomValue:toZoomValue];
                        
                        [overlayLayerRL addAnimation:rlAnimation forKey:nil];
                        [overlayLayerLR addAnimation:lrAnimation forKey:nil];
                        [overlayLayerTB addAnimation:tbAnimation forKey:nil];
                        [overlayLayerBT addAnimation:btAnimation forKey:nil];
                        [overlayLayer addAnimation:ccAnimation forKey:nil];
                        
                        CABasicAnimation* fadeAnimation = [self startFadeAction:(endPosition - MIN_DURATION) duration:MIN_DURATION];
                        [overlayLayerRL addAnimation:fadeAnimation forKey:nil];
                        [overlayLayerLR addAnimation:fadeAnimation forKey:nil];
                        [overlayLayerTB addAnimation:fadeAnimation forKey:nil];
                        [overlayLayerBT addAnimation:fadeAnimation forKey:nil];
                        
                        [parentLayer addSublayer:overlayLayerRL];
                        [parentLayer addSublayer:overlayLayerLR];
                        [parentLayer addSublayer:overlayLayerTB];
                        [parentLayer addSublayer:overlayLayerBT];
                        [parentLayer addSublayer:overlayLayer];
                        
                        continue;
                    }
                    else if ((object.endActionType == ACTION_GENIE_BT)||(object.endActionType == ACTION_GENIE_TB)||(object.endActionType == ACTION_GENIE_LR)||(object.endActionType == ACTION_GENIE_RL))
                    {
                        ADTransitionOrientation orientation = ADTransitionLeftToRight;
                        
                        switch (object.endActionType) {
                            case ACTION_GENIE_RL:
                                orientation = ADTransitionRightToLeft;
                                break;
                            case ACTION_GENIE_LR:
                                orientation = ADTransitionLeftToRight;
                                break;
                            case ACTION_GENIE_TB:
                                orientation = ADTransitionBottomToTop;
                                break;
                            case ACTION_GENIE_BT:
                                orientation = ADTransitionTopToBottom;
                                break;
                                
                            default:
                                orientation = ADTransitionRightToLeft;
                                break;
                        }
                        
                        GenieAction* genieAction = [[GenieAction alloc] init];
                        
                        CFTimeInterval endPosition = AVCoreAnimationBeginTimeAtZero +  object.mfEndPosition - object.mfEndAnimationDuration;
                        CFTimeInterval endDuration = object.mfEndAnimationDuration;
                        CGRect frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
                        
                        UIImage *overlayImage = nil;
                        
                        if (object.isKbEnabled)
                            overlayImage = [object renderingKenBurnsImage:NO];
                        else
                            overlayImage = [object renderingTextView];
                        
                        overlayImage = [overlayImage rescaleImageToSize:videoSize];

                        NSMutableArray* overlayLayers = [genieAction endGenieAction:overlayImage endPosition:endPosition duration:endDuration orientation:orientation sourceRect:frame];
                        
                        for (CALayer* layer in overlayLayers)
                        {
                            CABasicAnimation* startAnimation = [self startNoneAction:endPosition duration:MIN_DURATION];
                            [layer addAnimation:startAnimation forKey:nil];
                            
                            [parentLayer addSublayer:layer];
                        }
                        
                        CAAnimationGroup* endAnimation = [self endNoneAction:endPosition duration:MIN_DURATION fromTransform:inTranslationTransform fromZoomValue:toZoomValue];
                        [overlayLayer addAnimation:endAnimation forKey:nil];
                    }
                    else if ((object.endActionType == ACTION_GENIE_BL)||(object.endActionType == ACTION_GENIE_BR)||(object.endActionType == ACTION_GENIE_TL)||(object.endActionType == ACTION_GENIE_TR))
                    {
                        ADTransitionOrientation orientation = ADTransitionLeftToRight;
                        
                        switch (object.endActionType) {
                            case ACTION_GENIE_TR:
                                orientation = ADTransitionRightToLeft;
                                break;
                            case ACTION_GENIE_TL:
                                orientation = ADTransitionLeftToRight;
                                break;
                            case ACTION_GENIE_BL:
                                orientation = ADTransitionTopToBottom;
                                break;
                            case ACTION_GENIE_BR:
                                orientation = ADTransitionBottomToTop;
                                break;
                                
                            default:
                                orientation = ADTransitionRightToLeft;
                                break;
                        }
                        
                        SuckAction* suckAction = [[SuckAction alloc] init];
                        
                        CFTimeInterval endPosition = AVCoreAnimationBeginTimeAtZero +  object.mfEndPosition - object.mfEndAnimationDuration;
                        CFTimeInterval endDuration = object.mfEndAnimationDuration;
                        CGRect frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
                        
                        UIImage *overlayImage = nil;
                        
                        if (object.isKbEnabled)
                            overlayImage = [object renderingKenBurnsImage:NO];
                        else
                            overlayImage = [object renderingTextView];
                        
                        overlayImage = [overlayImage rescaleImageToSize:videoSize];

                        NSMutableArray* overlayLayers = [suckAction endSuckAction:overlayImage endPosition:endPosition duration:endDuration orientation:orientation sourceRect:frame];
                        
                        for (CALayer* layer in overlayLayers)
                        {
                            CABasicAnimation* startAnimation = [self startNoneAction:endPosition duration:MIN_DURATION];
                            [layer addAnimation:startAnimation forKey:nil];
                            
                            [parentLayer addSublayer:layer];
                        }
                        
                        CAAnimationGroup* endAnimation = [self endNoneAction:endPosition duration:MIN_DURATION fromTransform:inTranslationTransform fromZoomValue:toZoomValue];
                        [overlayLayer addAnimation:endAnimation forKey:nil];
                    }
                    else if ((object.endActionType >= ACTION_REVEAL_BT)&&(object.endActionType <= ACTION_REVEAL_TB))
                    {
                        ADTransitionOrientation orientation = ADTransitionLeftToRight;
                        
                        switch (object.endActionType)
                        {
                            case ACTION_REVEAL_RL:
                                orientation = ADTransitionRightToLeft;
                                break;
                            case ACTION_REVEAL_LR:
                                orientation = ADTransitionLeftToRight;
                                break;
                            case ACTION_REVEAL_TB:
                                orientation = ADTransitionTopToBottom;
                                break;
                            case ACTION_REVEAL_BT:
                                orientation = ADTransitionBottomToTop;
                                break;
                                
                            default:
                                orientation = ADTransitionRightToLeft;
                                break;
                        }
                        
                        RevealAction* revealAction = [[RevealAction alloc] init];
                        
                        CFTimeInterval endPosition = AVCoreAnimationBeginTimeAtZero +  object.mfEndPosition - object.mfEndAnimationDuration;
                        CFTimeInterval endDuration = object.mfEndAnimationDuration;
                        CGRect frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
                        
                        CAAnimationGroup* animation = [revealAction endRevealAction:endPosition duration:endDuration orientation:orientation sourceRect:frame fromTransform:inTranslationTransform fromZoomValue:toZoomValue];
                        [overlayLayer addAnimation:animation forKey:nil];
                    }
                    else if (object.endActionType == ACTION_EXPLODE)
                    {
                        ExplodeAction* explodeAction = [[ExplodeAction alloc] init];
                        
                        CFTimeInterval endPosition = AVCoreAnimationBeginTimeAtZero +  object.mfEndPosition - object.mfEndAnimationDuration - MIN_DURATION;
                        CFTimeInterval endDuration = object.mfEndAnimationDuration;
                        CGRect frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
                        
                        UIImage *overlayImage = nil;
                        
                        if (object.isKbEnabled)
                            overlayImage = [object renderingKenBurnsImage:NO];
                        else
                            overlayImage = [object renderingTextView];
                        
                        overlayImage = [overlayImage rescaleImageToSize:videoSize];

                        NSMutableArray* overlayLayers = [explodeAction endExplodeAction:overlayImage endPosition:endPosition duration:endDuration sourceRect:frame];
                        
                        for (CALayer* layer in overlayLayers)
                        {
                            CABasicAnimation* startAnimation = [self startNoneAction:endPosition duration:MIN_DURATION];
                            [layer addAnimation:startAnimation forKey:nil];

                            [parentLayer addSublayer:layer];
                        }
                        
                        CAAnimationGroup* endAnimation = [self endNoneAction:endPosition duration:MIN_DURATION fromTransform:inTranslationTransform fromZoomValue:toZoomValue];
                        [overlayLayer addAnimation:endAnimation forKey:nil];
                    }
                    else
                    {
                        CAAnimationGroup *endAnimationGroup = [self getEndGroupAction:object fromTransform:inTranslationTransform fromZoomValue:toZoomValue];
                        [overlayLayer addAnimation:endAnimationGroup forKey:nil];
                    }
                }
                
                [parentLayer addSublayer:overlayLayer];
            }
            else if ((object.mediaType == MEDIA_VIDEO)||(object.mediaType == MEDIA_GIF))
            {
                if((object.startActionType == ACTION_EXPLODE) || ((object.startActionType >= ACTION_FLIP_BT)&&(object.startActionType <= ACTION_GENIE_TR)) || ((object.startActionType >= ACTION_REVEAL_BT)&&(object.startActionType <= ACTION_REVEAL_TB)) || (object.startActionType == ACTION_SPIN_CC) || (object.startActionType == ACTION_SWAP_ALL) || ((object.startActionType >= ACTION_SWING_BT)&&(object.startActionType <= ACTION_ZOOM_ALL)))
                {
                    CAAnimationGroup *startAnimationGroup = [self getStartGroupAction:object];
                    [videoLayer addAnimation:startAnimationGroup forKey:nil];
                }

                if((object.endActionType == ACTION_EXPLODE) || ((object.endActionType >= ACTION_FLIP_BT)&&(object.endActionType <= ACTION_GENIE_TR)) || ((object.endActionType >= ACTION_REVEAL_BT)&&(object.endActionType <= ACTION_REVEAL_TB)) || (object.endActionType == ACTION_SPIN_CC) || (object.endActionType == ACTION_SWAP_ALL) || ((object.endActionType >= ACTION_SWING_BT)&&(object.endActionType <= ACTION_ZOOM_ALL)))
                {
                    CAAnimationGroup *endAnimationGroup = [self getEndGroupAction:object fromTransform:inTranslationTransform fromZoomValue:toZoomValue];
                    [videoLayer addAnimation:endAnimationGroup forKey:nil];
                }
            }
        }
    }
    
   
    AVVideoCompositionCoreAnimationTool* animationTool = [AVVideoCompositionCoreAnimationTool
                                         videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];

    return animationTool;
}

- (AVVideoCompositionCoreAnimationTool*) setVideoAnimationForChromakey:(int) objectIndex
{
    //parent layer
    CALayer *parentLayer = [CALayer layer];
    parentLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
    parentLayer.backgroundColor = [UIColor clearColor].CGColor;
    
    //video layer
    CALayer *videoLayer = [CALayer layer];
    videoLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
    videoLayer.backgroundColor = [UIColor clearColor].CGColor;
    [parentLayer addSublayer:videoLayer];
    
    @autoreleasepool
    {
        MediaObjectView* object = [self.objectArray objectAtIndex:objectIndex];
        
        CGFloat toZoomValue = 1.0f;
        CATransform3D inTranslationTransform = CATransform3DIdentity;
        
        if((object.startActionType == ACTION_EXPLODE) || ((object.startActionType >= ACTION_FLIP_BT)&&(object.startActionType <= ACTION_GENIE_TR)) || ((object.startActionType >= ACTION_REVEAL_BT)&&(object.startActionType <= ACTION_REVEAL_TB)) || (object.startActionType == ACTION_SPIN_CC) || (object.startActionType == ACTION_SWAP_ALL) || ((object.startActionType >= ACTION_SWING_BT)&&(object.startActionType <= ACTION_ZOOM_ALL)))
        {
            CAAnimationGroup *startAnimationGroup = [self getStartGroupAction:object];
            [videoLayer addAnimation:startAnimationGroup forKey:nil];
        }
        
        if((object.endActionType == ACTION_EXPLODE) || ((object.endActionType >= ACTION_FLIP_BT)&&(object.endActionType <= ACTION_GENIE_TR)) || ((object.endActionType >= ACTION_REVEAL_BT)&&(object.endActionType <= ACTION_REVEAL_TB)) || (object.endActionType == ACTION_SPIN_CC) || (object.endActionType == ACTION_SWAP_ALL) || ((object.endActionType >= ACTION_SWING_BT)&&(object.endActionType <= ACTION_ZOOM_ALL)))
        {
            CAAnimationGroup *endAnimationGroup = [self getEndGroupAction:object fromTransform:inTranslationTransform fromZoomValue:toZoomValue];
            [videoLayer addAnimation:endAnimationGroup forKey:nil];
        }

        if (object.objectCornerRadius != 0.0f)
        {
            BOOL isBlack = NO;
            
            if (objectIndex == 0)
                isBlack = YES;
            
            UIImage *overlayImage = [object renderingImageViewForChromakey:isBlack];

            CALayer *overlayLayer = [CALayer layer];
            overlayLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
            overlayLayer.backgroundColor = [UIColor clearColor].CGColor;
            [overlayLayer setContents:(id)[overlayImage CGImage]];

            if ((object.startActionType == ACTION_NONE)||(object.startActionType == ACTION_FADE)||(object.startActionType == ACTION_BLACK))
            {
                object.startActionType = ACTION_NONE;
                CABasicAnimation *startAnimation = [self getStartAction:object];
                [overlayLayer addAnimation:startAnimation forKey:nil];
            }
            else
            {
                if (object.startActionType == ACTION_SWAP_ALL)      //SwapAll
                {
                    CALayer *overlayLayerRL = [CALayer layer];
                    overlayLayerRL.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
                    overlayLayerRL.backgroundColor = [UIColor clearColor].CGColor;
                    
                    CALayer *overlayLayerLR = [CALayer layer];
                    overlayLayerLR.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
                    overlayLayerLR.backgroundColor = [UIColor clearColor].CGColor;
                    
                    CALayer *overlayLayerTB = [CALayer layer];
                    overlayLayerTB.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
                    overlayLayerTB.backgroundColor = [UIColor clearColor].CGColor;
                    
                    NSMutableArray* layersArray = [[NSMutableArray alloc] initWithObjects:overlayLayerRL, overlayLayerLR, overlayLayerTB, nil];
                    [self setOverlayLayerContents:object layers:layersArray];

                    CFTimeInterval startPosition = AVCoreAnimationBeginTimeAtZero + object.mfStartPosition;
                    CFTimeInterval startDuration = object.mfStartAnimationDuration;
                    CGRect frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
                    
                    SwapAction* swapAction = [[SwapAction alloc] init];
                    CAAnimationGroup* rlAnimation = [swapAction startSwapAction:startPosition duration:startDuration orientation:ADTransitionRightToLeft sourceRect:frame];
                    CAAnimationGroup* lrAnimation = [swapAction startSwapAction:startPosition duration:startDuration orientation:ADTransitionLeftToRight sourceRect:frame];
                    CAAnimationGroup* tbAnimation = [swapAction startSwapAction:startPosition duration:startDuration orientation:ADTransitionTopToBottom sourceRect:frame];
                    CAAnimationGroup* btAnimation = [swapAction startSwapAction:startPosition duration:startDuration orientation:ADTransitionBottomToTop sourceRect:frame];
                    
                    [overlayLayerRL addAnimation:rlAnimation forKey:nil];
                    [overlayLayerLR addAnimation:lrAnimation forKey:nil];
                    [overlayLayerTB addAnimation:tbAnimation forKey:nil];
                    [overlayLayer addAnimation:btAnimation forKey:nil];
                    
                    if (object.endActionType == ACTION_SWAP_ALL)
                    {
                        CFTimeInterval endPosition = AVCoreAnimationBeginTimeAtZero +  object.mfEndPosition - object.mfEndAnimationDuration;
                        CFTimeInterval endDuration = object.mfEndAnimationDuration;
                        
                        SwapAction* swapAction = [[SwapAction alloc] init];
                        CAAnimationGroup* rlAnimation = [swapAction endSwapAction:endPosition duration:endDuration orientation:ADTransitionRightToLeft sourceRect:frame fromTransform:inTranslationTransform fromZoomValue:toZoomValue];
                        CAAnimationGroup* lrAnimation = [swapAction endSwapAction:endPosition duration:endDuration orientation:ADTransitionLeftToRight sourceRect:frame fromTransform:inTranslationTransform fromZoomValue:toZoomValue];
                        CAAnimationGroup* tbAnimation = [swapAction endSwapAction:endPosition duration:endDuration orientation:ADTransitionTopToBottom sourceRect:frame fromTransform:inTranslationTransform fromZoomValue:toZoomValue];
                        CAAnimationGroup* btAnimation = [swapAction endSwapAction:endPosition duration:endDuration orientation:ADTransitionBottomToTop sourceRect:frame fromTransform:inTranslationTransform fromZoomValue:toZoomValue];
                        
                        [overlayLayerRL addAnimation:rlAnimation forKey:nil];
                        [overlayLayerLR addAnimation:lrAnimation forKey:nil];
                        [overlayLayerTB addAnimation:tbAnimation forKey:nil];
                        [overlayLayer addAnimation:btAnimation forKey:nil];
                        
                        [parentLayer addSublayer:overlayLayerRL];
                        [parentLayer addSublayer:overlayLayerLR];
                        [parentLayer addSublayer:overlayLayerTB];
                        [parentLayer addSublayer:overlayLayer];
                    }
                    else
                    {
                        CAAnimationGroup* fadeAnimation = [self endFadeAction:(startPosition+startDuration) duration:MIN_DURATION fromTransform:inTranslationTransform fromZoomValue:toZoomValue];
                        [overlayLayerRL addAnimation:fadeAnimation forKey:nil];
                        [overlayLayerLR addAnimation:fadeAnimation forKey:nil];
                        [overlayLayerTB addAnimation:fadeAnimation forKey:nil];
                        
                        [parentLayer addSublayer:overlayLayerRL];
                        [parentLayer addSublayer:overlayLayerLR];
                        [parentLayer addSublayer:overlayLayerTB];
                    }
                }
                else if (object.startActionType == ACTION_ZOOM_ALL)   //ZoomAll
                {
                    CALayer *overlayLayerRL = [CALayer layer];
                    overlayLayerRL.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
                    overlayLayerRL.backgroundColor = [UIColor clearColor].CGColor;
                    
                    CALayer *overlayLayerLR = [CALayer layer];
                    overlayLayerLR.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
                    overlayLayerLR.backgroundColor = [UIColor clearColor].CGColor;
                    
                    CALayer *overlayLayerTB = [CALayer layer];
                    overlayLayerTB.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
                    overlayLayerTB.backgroundColor = [UIColor clearColor].CGColor;
                    
                    CALayer *overlayLayerBT = [CALayer layer];
                    overlayLayerBT.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
                    overlayLayerBT.backgroundColor = [UIColor clearColor].CGColor;

                    NSMutableArray* layersArray = [[NSMutableArray alloc] initWithObjects:overlayLayerRL, overlayLayerLR, overlayLayerTB, overlayLayerBT, nil];
                    [self setOverlayLayerContents:object layers:layersArray];

                    CFTimeInterval startPosition = AVCoreAnimationBeginTimeAtZero + object.mfStartPosition;
                    CFTimeInterval startDuration = object.mfStartAnimationDuration;
                    CGRect frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
                    
                    CAAnimationGroup* rlAnimation = [self startZoomAction:startPosition duration:startDuration type:ACTION_ZOOM_RL sourceRect:frame];
                    CAAnimationGroup* lrAnimation = [self startZoomAction:startPosition duration:startDuration type:ACTION_ZOOM_LR sourceRect:frame];
                    CAAnimationGroup* tbAnimation = [self startZoomAction:startPosition duration:startDuration type:ACTION_ZOOM_TB sourceRect:frame];
                    CAAnimationGroup* btAnimation = [self startZoomAction:startPosition duration:startDuration type:ACTION_ZOOM_BT sourceRect:frame];
                    CAAnimationGroup* ccAnimation = [self startZoomAction:startPosition duration:startDuration type:ACTION_ZOOM_CC sourceRect:frame];
                    
                    [overlayLayerRL addAnimation:rlAnimation forKey:nil];
                    [overlayLayerLR addAnimation:lrAnimation forKey:nil];
                    [overlayLayerTB addAnimation:tbAnimation forKey:nil];
                    [overlayLayerBT addAnimation:btAnimation forKey:nil];
                    [overlayLayer addAnimation:ccAnimation forKey:nil];
                    
                    if (object.endActionType == ACTION_ZOOM_ALL)
                    {
                        CFTimeInterval endPosition = AVCoreAnimationBeginTimeAtZero +  object.mfEndPosition - object.mfEndAnimationDuration;
                        CFTimeInterval endDuration = object.mfEndAnimationDuration;
                        
                        CAAnimationGroup* rlAnimation = [self endZoomAction:endPosition duration:endDuration type:ACTION_ZOOM_RL sourceRect:frame fromTransform:inTranslationTransform fromZoomValue:toZoomValue];
                        CAAnimationGroup* lrAnimation = [self endZoomAction:endPosition duration:endDuration type:ACTION_ZOOM_LR sourceRect:frame fromTransform:inTranslationTransform fromZoomValue:toZoomValue];
                        CAAnimationGroup* tbAnimation = [self endZoomAction:endPosition duration:endDuration type:ACTION_ZOOM_TB sourceRect:frame fromTransform:inTranslationTransform fromZoomValue:toZoomValue];
                        CAAnimationGroup* btAnimation = [self endZoomAction:endPosition duration:endDuration type:ACTION_ZOOM_BT sourceRect:frame fromTransform:inTranslationTransform fromZoomValue:toZoomValue];
                        CAAnimationGroup* ccAnimation = [self endZoomAction:endPosition duration:endDuration type:ACTION_ZOOM_CC sourceRect:frame fromTransform:inTranslationTransform fromZoomValue:toZoomValue];
                        
                        [overlayLayerRL addAnimation:rlAnimation forKey:nil];
                        [overlayLayerLR addAnimation:lrAnimation forKey:nil];
                        [overlayLayerTB addAnimation:tbAnimation forKey:nil];
                        [overlayLayerBT addAnimation:btAnimation forKey:nil];
                        [overlayLayer addAnimation:ccAnimation forKey:nil];
                        
                        [parentLayer addSublayer:overlayLayerRL];
                        [parentLayer addSublayer:overlayLayerLR];
                        [parentLayer addSublayer:overlayLayerTB];
                        [parentLayer addSublayer:overlayLayerBT];
                        [parentLayer addSublayer:overlayLayer];
                    }
                    else
                    {
                        CAAnimationGroup* fadeAnimation = [self endFadeAction:(startPosition+startDuration) duration:MIN_DURATION fromTransform:inTranslationTransform fromZoomValue:toZoomValue];
                        [overlayLayerRL addAnimation:fadeAnimation forKey:nil];
                        [overlayLayerLR addAnimation:fadeAnimation forKey:nil];
                        [overlayLayerTB addAnimation:fadeAnimation forKey:nil];
                        [overlayLayerBT addAnimation:fadeAnimation forKey:nil];
                        
                        [parentLayer addSublayer:overlayLayerRL];
                        [parentLayer addSublayer:overlayLayerLR];
                        [parentLayer addSublayer:overlayLayerTB];
                        [parentLayer addSublayer:overlayLayerBT];
                    }
                }
                else if ((object.startActionType == ACTION_GENIE_BT)||(object.startActionType == ACTION_GENIE_TB)||(object.startActionType == ACTION_GENIE_LR)||(object.startActionType == ACTION_GENIE_RL))
                {
                    ADTransitionOrientation orientation = ADTransitionLeftToRight;
                    
                    switch (object.startActionType)
                    {
                        case ACTION_GENIE_RL:
                            orientation = ADTransitionRightToLeft;
                            break;
                        case ACTION_GENIE_LR:
                            orientation = ADTransitionLeftToRight;
                            break;
                        case ACTION_GENIE_TB:
                            orientation = ADTransitionBottomToTop;
                            break;
                        case ACTION_GENIE_BT:
                            orientation = ADTransitionTopToBottom;
                            break;
                            
                        default:
                            orientation = ADTransitionRightToLeft;
                            break;
                    }
                    
                    GenieAction* genieAction = [[GenieAction alloc] init];
                    
                    CFTimeInterval startPosition = AVCoreAnimationBeginTimeAtZero + object.mfStartPosition;
                    CFTimeInterval startDuration = object.mfStartAnimationDuration + MIN_DURATION;
                    CGRect frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
                    
                    UIImage *image = nil;
                    
                    if (object.isKbEnabled)
                        image = [object renderingKenBurnsImage:YES];
                    else
                        image = object.renderedImage;
                    
                    image = [image rescaleImageToSize:videoSize];
                    
                    NSMutableArray* overlayLayers = [genieAction startGenieAction:image startPosition:startPosition duration:startDuration orientation:orientation sourceRect:frame];
                    
                    for (CALayer* layer in overlayLayers)
                    {
                        CABasicAnimation* startAnimation = [self startNoneAction:startPosition duration:MIN_DURATION];
                        [layer addAnimation:startAnimation forKey:nil];
                        [parentLayer addSublayer:layer];
                    }
                    
                    CABasicAnimation *animation = [self startNoneAction:(startPosition + startDuration) duration:MIN_DURATION];
                    [overlayLayer addAnimation:animation forKey:nil];
                }
                else if ((object.startActionType == ACTION_GENIE_TL)||(object.startActionType == ACTION_GENIE_TR)||(object.startActionType == ACTION_GENIE_BL)||(object.startActionType == ACTION_GENIE_BR))
                {
                    ADTransitionOrientation orientation = ADTransitionLeftToRight;
                    
                    switch (object.startActionType)
                    {
                        case ACTION_GENIE_TR:
                            orientation = ADTransitionRightToLeft;
                            break;
                        case ACTION_GENIE_TL:
                            orientation = ADTransitionLeftToRight;
                            break;
                        case ACTION_GENIE_BL:
                            orientation = ADTransitionTopToBottom;
                            break;
                        case ACTION_GENIE_BR:
                            orientation = ADTransitionBottomToTop;
                            break;
                            
                        default:
                            orientation = ADTransitionRightToLeft;
                            break;
                    }
                    
                    SuckAction* suckAction = [[SuckAction alloc] init];
                    
                    CFTimeInterval startPosition = AVCoreAnimationBeginTimeAtZero + object.mfStartPosition;
                    CFTimeInterval startDuration = object.mfStartAnimationDuration + MIN_DURATION;
                    CGRect frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
                    
                    UIImage *image = nil;
                    
                    if (object.isKbEnabled)
                        image = [object renderingKenBurnsImage:YES];
                    else
                        image = object.renderedImage;
                    
                    image = [image rescaleImageToSize:videoSize];
                    
                    NSMutableArray* overlayLayers = [suckAction startSuckAction:image startPosition:startPosition duration:startDuration orientation:orientation sourceRect:frame];
                    
                    for (CALayer* layer in overlayLayers)
                    {
                        CABasicAnimation* startAnimation = [self startNoneAction:startPosition duration:MIN_DURATION];
                        [layer addAnimation:startAnimation forKey:nil];
                        [parentLayer addSublayer:layer];
                    }
                    
                    CABasicAnimation *animation = [self startNoneAction:(startPosition + object.mfStartAnimationDuration - MIN_DURATION) duration:MIN_DURATION];
                    [overlayLayer addAnimation:animation forKey:nil];
                }
                else if ((object.startActionType >= ACTION_REVEAL_BT)&&(object.startActionType <= ACTION_REVEAL_TB))
                {
                    ADTransitionOrientation orientation = ADTransitionLeftToRight;
                    
                    switch (object.startActionType)
                    {
                        case ACTION_REVEAL_RL:
                            orientation = ADTransitionRightToLeft;
                            break;
                        case ACTION_REVEAL_LR:
                            orientation = ADTransitionLeftToRight;
                            break;
                        case ACTION_REVEAL_TB:
                            orientation = ADTransitionTopToBottom;
                            break;
                        case ACTION_REVEAL_BT:
                            orientation = ADTransitionBottomToTop;
                            break;
                            
                        default:
                            orientation = ADTransitionRightToLeft;
                            break;
                    }
                    
                    RevealAction* revealAction = [[RevealAction alloc] init];
                    
                    CFTimeInterval startPosition = AVCoreAnimationBeginTimeAtZero + object.mfStartPosition;
                    CFTimeInterval startDuration = object.mfStartAnimationDuration;
                    CGRect frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
                    
                    CAAnimationGroup* animation = [revealAction startRevealAction:startPosition duration:startDuration orientation:orientation sourceRect:frame];
                    [overlayLayer addAnimation:animation forKey:nil];
                }
                else if (object.startActionType == ACTION_EXPLODE)
                {
                    ExplodeAction* explodeAction = [[ExplodeAction alloc] init];
                    
                    CFTimeInterval startPosition = AVCoreAnimationBeginTimeAtZero + object.mfStartPosition;
                    CFTimeInterval startDuration = object.mfStartAnimationDuration + MIN_DURATION;
                    CGRect frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
                    
                    UIImage *image = nil;
                    
                    if (object.isKbEnabled)
                        image = [object renderingKenBurnsImage:YES];
                    else
                        image = object.renderedImage;
                    
                    image = [image rescaleImageToSize:videoSize];
                    
                    NSMutableArray* overlayLayers = [explodeAction startExplodeAction:image startPosition:startPosition duration:startDuration sourceRect:frame];
                    
                    for (CALayer* layer in overlayLayers)
                    {
                        CABasicAnimation* startAnimation = [self startNoneAction:startPosition duration:MIN_DURATION];
                        [layer addAnimation:startAnimation forKey:nil];
                        
                        CAAnimationGroup* endAnimation = [self endNoneAction:(startPosition + startDuration - MIN_DURATION) duration:MIN_DURATION fromTransform:inTranslationTransform fromZoomValue:toZoomValue];
                        [layer addAnimation:endAnimation forKey:nil];
                        [parentLayer addSublayer:layer];
                    }
                    
                    CABasicAnimation *animation = [self startNoneAction:(startPosition + startDuration - MIN_DURATION) duration:MIN_DURATION];
                    [overlayLayer addAnimation:animation forKey:nil];
                }
                else if (object.startActionType == ACTION_ROTATE)
                {
                    CALayer *rotateLayer = [CALayer layer];
                    rotateLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
                    rotateLayer.backgroundColor = [UIColor clearColor].CGColor;
                    
                    UIImage* renderedImage = [object renderingImageView];
                    [rotateLayer setContents:(id)[renderedImage CGImage]];
                    
                    CFTimeInterval startPosition = AVCoreAnimationBeginTimeAtZero + object.mfStartPosition;
                    CFTimeInterval startDuration = object.mfStartAnimationDuration + MIN_DURATION;
                    CGRect frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
                    
                    RotateAction* rotateAction = [[RotateAction alloc] init];
                    CAAnimationGroup* startAnimation = [rotateAction startRotateAction:startPosition duration:startDuration sourceRect:frame];
                    [rotateLayer addAnimation:startAnimation forKey:nil];
                    
                    CAAnimationGroup* endAnimation = [self endNoneAction:(startPosition + startDuration - MIN_DURATION) duration:MIN_DURATION fromTransform:inTranslationTransform fromZoomValue:toZoomValue];
                    [rotateLayer addAnimation:endAnimation forKey:nil];
                    
                    [parentLayer addSublayer:rotateLayer];
                    
                    CABasicAnimation *animation = [self startNoneAction:(startPosition + startDuration - MIN_DURATION) duration:MIN_DURATION];
                    [overlayLayer addAnimation:animation forKey:nil];
                }
                else
                {
                    CFTimeInterval startPosition = AVCoreAnimationBeginTimeAtZero + object.mfStartPosition;
                    CABasicAnimation* startAnimation = [self startNoneAction:startPosition duration:MIN_DURATION];
                    [overlayLayer addAnimation:startAnimation forKey:nil];
                    
                    CAAnimationGroup *startAnimationGroup = [self getStartGroupAction:object];
                    [overlayLayer addAnimation:startAnimationGroup forKey:nil];
                }
            }
            
            if ((object.endActionType == ACTION_NONE)||(object.endActionType == ACTION_FADE)||(object.endActionType == ACTION_BLACK))
            {
                object.endActionType = ACTION_NONE;
                
                CAAnimationGroup *endAnimation = [self getEndAction:object fromTransform:inTranslationTransform fromZoomValue:toZoomValue];
                [overlayLayer addAnimation:endAnimation forKey:nil];
            }
            else
            {
                if (object.endActionType == ACTION_SWAP_ALL)
                {
                    CALayer *overlayLayerRL = [CALayer layer];
                    overlayLayerRL.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
                    overlayLayerRL.backgroundColor = [UIColor clearColor].CGColor;
                    
                    CALayer *overlayLayerLR = [CALayer layer];
                    overlayLayerLR.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
                    overlayLayerLR.backgroundColor = [UIColor clearColor].CGColor;
                    
                    CALayer *overlayLayerTB = [CALayer layer];
                    overlayLayerTB.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
                    overlayLayerTB.backgroundColor = [UIColor clearColor].CGColor;

                    NSMutableArray* layersArray = [[NSMutableArray alloc] initWithObjects:overlayLayerRL, overlayLayerLR, overlayLayerTB, nil];
                    [self setOverlayLayerContents:object layers:layersArray];

                    CFTimeInterval endPosition = AVCoreAnimationBeginTimeAtZero + object.mfEndPosition - object.mfEndAnimationDuration;
                    CFTimeInterval endDuration = object.mfEndAnimationDuration;
                    CGRect frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
                    
                    SwapAction* swapAction = [[SwapAction alloc] init];
                    CAAnimationGroup* rlAnimation = [swapAction endSwapAction:endPosition duration:endDuration orientation:ADTransitionRightToLeft sourceRect:frame fromTransform:inTranslationTransform fromZoomValue:toZoomValue];
                    CAAnimationGroup* lrAnimation = [swapAction endSwapAction:endPosition duration:endDuration orientation:ADTransitionLeftToRight sourceRect:frame fromTransform:inTranslationTransform fromZoomValue:toZoomValue];
                    CAAnimationGroup* tbAnimation = [swapAction endSwapAction:endPosition duration:endDuration orientation:ADTransitionTopToBottom sourceRect:frame fromTransform:inTranslationTransform fromZoomValue:toZoomValue];
                    CAAnimationGroup* btAnimation = [swapAction endSwapAction:endPosition duration:endDuration orientation:ADTransitionBottomToTop sourceRect:frame fromTransform:inTranslationTransform fromZoomValue:toZoomValue];
                    
                    [overlayLayerRL addAnimation:rlAnimation forKey:nil];
                    [overlayLayerLR addAnimation:lrAnimation forKey:nil];
                    [overlayLayerTB addAnimation:tbAnimation forKey:nil];
                    [overlayLayer addAnimation:btAnimation forKey:nil];
                    
                    CABasicAnimation* fadeAnimation = [self startFadeAction:(endPosition - MIN_DURATION) duration:MIN_DURATION];
                    [overlayLayerRL addAnimation:fadeAnimation forKey:nil];
                    [overlayLayerLR addAnimation:fadeAnimation forKey:nil];
                    [overlayLayerTB addAnimation:fadeAnimation forKey:nil];
                    
                    [parentLayer addSublayer:overlayLayerRL];
                    [parentLayer addSublayer:overlayLayerLR];
                    [parentLayer addSublayer:overlayLayerTB];
                    [parentLayer addSublayer:overlayLayer];
                }
                else if (object.endActionType == ACTION_ZOOM_ALL)
                {
                    CALayer *overlayLayerRL = [CALayer layer];
                    overlayLayerRL.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
                    overlayLayerRL.backgroundColor = [UIColor clearColor].CGColor;
                    
                    CALayer *overlayLayerLR = [CALayer layer];
                    overlayLayerLR.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
                    overlayLayerLR.backgroundColor = [UIColor clearColor].CGColor;
                    
                    CALayer *overlayLayerTB = [CALayer layer];
                    overlayLayerTB.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
                    overlayLayerTB.backgroundColor = [UIColor clearColor].CGColor;
                    
                    CALayer *overlayLayerBT = [CALayer layer];
                    overlayLayerBT.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
                    overlayLayerBT.backgroundColor = [UIColor clearColor].CGColor;

                    NSMutableArray* layersArray = [[NSMutableArray alloc] initWithObjects:overlayLayerRL, overlayLayerLR, overlayLayerTB, overlayLayerBT, nil];
                    [self setOverlayLayerContents:object layers:layersArray];

                    CFTimeInterval endPosition = AVCoreAnimationBeginTimeAtZero + object.mfEndPosition - object.mfEndAnimationDuration;
                    CFTimeInterval endDuration = object.mfEndAnimationDuration;
                    CGRect frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
                    
                    CAAnimationGroup* rlAnimation = [self endZoomAction:endPosition duration:endDuration type:ACTION_ZOOM_RL sourceRect:frame fromTransform:inTranslationTransform fromZoomValue:toZoomValue];
                    CAAnimationGroup* lrAnimation = [self endZoomAction:endPosition duration:endDuration type:ACTION_ZOOM_LR sourceRect:frame fromTransform:inTranslationTransform fromZoomValue:toZoomValue];
                    CAAnimationGroup* tbAnimation = [self endZoomAction:endPosition duration:endDuration type:ACTION_ZOOM_TB sourceRect:frame fromTransform:inTranslationTransform fromZoomValue:toZoomValue];
                    CAAnimationGroup* btAnimation = [self endZoomAction:endPosition duration:endDuration type:ACTION_ZOOM_BT sourceRect:frame fromTransform:inTranslationTransform fromZoomValue:toZoomValue];
                    CAAnimationGroup* ccAnimation = [self endZoomAction:endPosition duration:endDuration type:ACTION_ZOOM_CC sourceRect:frame fromTransform:inTranslationTransform fromZoomValue:toZoomValue];
                    
                    [overlayLayerRL addAnimation:rlAnimation forKey:nil];
                    [overlayLayerLR addAnimation:lrAnimation forKey:nil];
                    [overlayLayerTB addAnimation:tbAnimation forKey:nil];
                    [overlayLayerBT addAnimation:btAnimation forKey:nil];
                    [overlayLayer addAnimation:ccAnimation forKey:nil];
                    
                    CABasicAnimation* fadeAnimation = [self startFadeAction:(endPosition - MIN_DURATION) duration:MIN_DURATION];
                    [overlayLayerRL addAnimation:fadeAnimation forKey:nil];
                    [overlayLayerLR addAnimation:fadeAnimation forKey:nil];
                    [overlayLayerTB addAnimation:fadeAnimation forKey:nil];
                    [overlayLayerBT addAnimation:fadeAnimation forKey:nil];
                    
                    [parentLayer addSublayer:overlayLayerRL];
                    [parentLayer addSublayer:overlayLayerLR];
                    [parentLayer addSublayer:overlayLayerTB];
                    [parentLayer addSublayer:overlayLayerBT];
                    [parentLayer addSublayer:overlayLayer];
                }
                else if ((object.endActionType == ACTION_GENIE_BT)||(object.endActionType == ACTION_GENIE_TB)||(object.endActionType == ACTION_GENIE_LR)||(object.endActionType == ACTION_GENIE_RL))
                {
                    ADTransitionOrientation orientation = ADTransitionLeftToRight;
                    
                    switch (object.endActionType)
                    {
                        case ACTION_GENIE_RL:
                            orientation = ADTransitionRightToLeft;
                            break;
                        case ACTION_GENIE_LR:
                            orientation = ADTransitionLeftToRight;
                            break;
                        case ACTION_GENIE_TB:
                            orientation = ADTransitionBottomToTop;
                            break;
                        case ACTION_GENIE_BT:
                            orientation = ADTransitionTopToBottom;
                            break;
                            
                        default:
                            orientation = ADTransitionRightToLeft;
                            break;
                    }
                    
                    GenieAction* genieAction = [[GenieAction alloc] init];
                    
                    CFTimeInterval endPosition = AVCoreAnimationBeginTimeAtZero +  object.mfEndPosition - object.mfEndAnimationDuration - MIN_DURATION;
                    CFTimeInterval endDuration = object.mfEndAnimationDuration;
                    CGRect frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
                    
                    UIImage *image = nil;
                    
                    if (object.isKbEnabled)
                        image = [object renderingKenBurnsImage:NO];
                    else
                        image = object.renderedImage;
                    
                    image = [image rescaleImageToSize:videoSize];
                    
                    NSMutableArray* overlayLayers = [genieAction endGenieAction:image endPosition:endPosition duration:endDuration orientation:orientation sourceRect:frame];
                    
                    for (CALayer* layer in overlayLayers)
                    {
                        CABasicAnimation* startAnimation = [self startNoneAction:endPosition duration:MIN_DURATION];
                        [layer addAnimation:startAnimation forKey:nil];
                        [parentLayer addSublayer:layer];
                    }
                    
                    CAAnimationGroup* endAnimation = [self endNoneAction:(endPosition-MIN_DURATION) duration:MIN_DURATION fromTransform:inTranslationTransform fromZoomValue:toZoomValue];
                    [overlayLayer addAnimation:endAnimation forKey:nil];
                }
                else if ((object.endActionType == ACTION_GENIE_BL)||(object.endActionType == ACTION_GENIE_BR)||(object.endActionType == ACTION_GENIE_TL)||(object.endActionType == ACTION_GENIE_TR))
                {
                    ADTransitionOrientation orientation = ADTransitionLeftToRight;
                    
                    switch (object.endActionType)
                    {
                        case ACTION_GENIE_TR:
                            orientation = ADTransitionRightToLeft;
                            break;
                        case ACTION_GENIE_TL:
                            orientation = ADTransitionLeftToRight;
                            break;
                        case ACTION_GENIE_BL:
                            orientation = ADTransitionTopToBottom;
                            break;
                        case ACTION_GENIE_BR:
                            orientation = ADTransitionBottomToTop;
                            break;
                            
                        default:
                            orientation = ADTransitionRightToLeft;
                            break;
                    }
                    
                    SuckAction* suckAction = [[SuckAction alloc] init];
                    
                    CFTimeInterval endPosition = AVCoreAnimationBeginTimeAtZero +  object.mfEndPosition - object.mfEndAnimationDuration - MIN_DURATION;
                    CFTimeInterval endDuration = object.mfEndAnimationDuration;
                    CGRect frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
                    
                    UIImage *image = nil;
                    
                    if (object.isKbEnabled)
                        image = [object renderingKenBurnsImage:NO];
                    else
                        image = object.renderedImage;

                    image = [image rescaleImageToSize:videoSize];

                    NSMutableArray* overlayLayers = [suckAction endSuckAction:image endPosition:endPosition duration:endDuration orientation:orientation sourceRect:frame];
                    
                    for (CALayer* layer in overlayLayers)
                    {
                        CABasicAnimation* startAnimation = [self startNoneAction:endPosition duration:MIN_DURATION];
                        [layer addAnimation:startAnimation forKey:nil];
                        [parentLayer addSublayer:layer];
                    }
                    
                    CAAnimationGroup* endAnimation = [self endNoneAction:endPosition duration:MIN_DURATION fromTransform:inTranslationTransform fromZoomValue:toZoomValue];
                    [overlayLayer addAnimation:endAnimation forKey:nil];
                }
                else if ((object.endActionType >= ACTION_REVEAL_BT)&&(object.endActionType <= ACTION_REVEAL_TB))
                {
                    ADTransitionOrientation orientation = ADTransitionLeftToRight;
                    
                    switch (object.endActionType)
                    {
                        case ACTION_REVEAL_RL:
                            orientation = ADTransitionRightToLeft;
                            break;
                        case ACTION_REVEAL_LR:
                            orientation = ADTransitionLeftToRight;
                            break;
                        case ACTION_REVEAL_TB:
                            orientation = ADTransitionTopToBottom;
                            break;
                        case ACTION_REVEAL_BT:
                            orientation = ADTransitionBottomToTop;
                            break;
                            
                        default:
                            orientation = ADTransitionRightToLeft;
                            break;
                    }
                    
                    RevealAction* revealAction = [[RevealAction alloc] init];
                    
                    CFTimeInterval endPosition = AVCoreAnimationBeginTimeAtZero +  object.mfEndPosition - object.mfEndAnimationDuration - MIN_DURATION;
                    CFTimeInterval endDuration = object.mfEndAnimationDuration;
                    CGRect frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
                    
                    CAAnimationGroup* animation = [revealAction endRevealAction:endPosition duration:endDuration orientation:orientation sourceRect:frame fromTransform:inTranslationTransform fromZoomValue:toZoomValue];
                    [overlayLayer addAnimation:animation forKey:nil];
                }
                else if (object.endActionType == ACTION_EXPLODE)
                {
                    ExplodeAction* explodeAction = [[ExplodeAction alloc] init];
                    
                    CFTimeInterval endPosition = AVCoreAnimationBeginTimeAtZero +  object.mfEndPosition - object.mfEndAnimationDuration - MIN_DURATION;
                    CFTimeInterval endDuration = object.mfEndAnimationDuration;
                    CGRect frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
                    
                    UIImage *image = nil;
                    
                    if (object.isKbEnabled)
                        image = [object renderingKenBurnsImage:NO];
                    else
                        image = object.renderedImage;

                    image = [image rescaleImageToSize:videoSize];

                    NSMutableArray* overlayLayers = [explodeAction endExplodeAction:image endPosition:endPosition duration:endDuration sourceRect:frame];
                    
                    for (CALayer* layer in overlayLayers)
                    {
                        CABasicAnimation* startAnimation = [self startNoneAction:endPosition duration:MIN_DURATION];
                        [layer addAnimation:startAnimation forKey:nil];
                        [parentLayer addSublayer:layer];
                    }
                    
                    CAAnimationGroup* endAnimation = [self endNoneAction:endPosition duration:MIN_DURATION fromTransform:inTranslationTransform fromZoomValue:toZoomValue];
                    [overlayLayer addAnimation:endAnimation forKey:nil];
                }
                else if (object.endActionType == ACTION_ROTATE)
                {
                    CFTimeInterval endPosition = AVCoreAnimationBeginTimeAtZero +  object.mfEndPosition - object.mfEndAnimationDuration - MIN_DURATION;
                    CFTimeInterval endDuration = object.mfEndAnimationDuration;
                    CGRect frame = CGRectMake(0, 0, videoSize.width, videoSize.height);

                    UIImage* renderedImage = [object renderingImageView];

                    CALayer *rotateLayer = [CALayer layer];
                    rotateLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
                    rotateLayer.backgroundColor = [UIColor clearColor].CGColor;
                    [rotateLayer setContents:(id)[renderedImage CGImage]];

                    CABasicAnimation* startAnimation = [self startNoneAction:endPosition duration:MIN_DURATION];
                    [rotateLayer addAnimation:startAnimation forKey:nil];

                    RotateAction* rotateAction = [[RotateAction alloc] init];
                    CAAnimationGroup* endAnimation = [rotateAction endRotateAction:endPosition duration:endDuration sourceRect:frame fromTransform:inTranslationTransform fromZoomValue:toZoomValue];
                    [rotateLayer addAnimation:endAnimation forKey:nil];
                    [parentLayer addSublayer:rotateLayer];

                    CAAnimationGroup* animation = [self endNoneAction:(endPosition + MIN_DURATION)  duration:MIN_DURATION fromTransform:inTranslationTransform fromZoomValue:toZoomValue];
                    [overlayLayer addAnimation:animation forKey:nil];
                }
                else
                {
                    CAAnimationGroup *endAnimationGroup = [self getEndGroupAction:object fromTransform:inTranslationTransform fromZoomValue:toZoomValue];
                    [overlayLayer addAnimation:endAnimationGroup forKey:nil];
                }
            }
            
            [parentLayer addSublayer:overlayLayer];
        }
        //added by YinjingLi 2015/06/04
        else  if ((object.startActionType == ACTION_EXPLODE)||(object.endActionType == ACTION_EXPLODE)||
                  (object.startActionType == ACTION_ROTATE)||(object.endActionType == ACTION_ROTATE)||
                  ((object.startActionType >= ACTION_GENIE_BL)&&(object.startActionType <= ACTION_GENIE_TR))||
                  ((object.endActionType >= ACTION_GENIE_BL)&&(object.endActionType <= ACTION_GENIE_TR)))
        {
            CALayer *overlayLayer = [CALayer layer];
            overlayLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
            overlayLayer.backgroundColor = [UIColor clearColor].CGColor;
            
            if ((object.startActionType == ACTION_GENIE_BT)||(object.startActionType == ACTION_GENIE_TB)||(object.startActionType == ACTION_GENIE_LR)||(object.startActionType == ACTION_GENIE_RL))
            {
                ADTransitionOrientation orientation = ADTransitionLeftToRight;
                
                switch (object.startActionType)
                {
                    case ACTION_GENIE_RL:
                        orientation = ADTransitionRightToLeft;
                        break;
                    case ACTION_GENIE_LR:
                        orientation = ADTransitionLeftToRight;
                        break;
                    case ACTION_GENIE_TB:
                        orientation = ADTransitionBottomToTop;
                        break;
                    case ACTION_GENIE_BT:
                        orientation = ADTransitionTopToBottom;
                        break;
                        
                    default:
                        orientation = ADTransitionRightToLeft;
                        break;
                }
                
                GenieAction* genieAction = [[GenieAction alloc] init];
                
                CFTimeInterval startPosition = AVCoreAnimationBeginTimeAtZero + object.mfStartPosition;
                CFTimeInterval startDuration = object.mfStartAnimationDuration + MIN_DURATION;
                CGRect frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
                
                UIImage *overlayImage = nil;
                
                if (object.isKbEnabled)
                    overlayImage = [object renderingKenBurnsImage:YES];
                else
                    overlayImage = object.renderedImage;
                
                overlayImage = [overlayImage rescaleImageToSize:videoSize];
                
                NSMutableArray* overlayLayers = [genieAction startGenieAction:overlayImage startPosition:startPosition duration:startDuration orientation:orientation sourceRect:frame];
                
                for (CALayer* layer in overlayLayers)
                {
                    CABasicAnimation* startAnimation = [self startNoneAction:startPosition duration:MIN_DURATION];
                    [layer addAnimation:startAnimation forKey:nil];
                    [parentLayer addSublayer:layer];
                }
                
                CABasicAnimation *animation = [self startNoneAction:(startPosition + object.mfStartAnimationDuration - MIN_DURATION) duration:MIN_DURATION];
                [overlayLayer addAnimation:animation forKey:nil];
            }
            else if ((object.startActionType == ACTION_GENIE_TL)||(object.startActionType == ACTION_GENIE_TR)||(object.startActionType == ACTION_GENIE_BL)||(object.startActionType == ACTION_GENIE_BR))
            {
                ADTransitionOrientation orientation = ADTransitionLeftToRight;
                
                switch (object.startActionType)
                {
                    case ACTION_GENIE_TR:
                        orientation = ADTransitionRightToLeft;
                        break;
                    case ACTION_GENIE_TL:
                        orientation = ADTransitionLeftToRight;
                        break;
                    case ACTION_GENIE_BL:
                        orientation = ADTransitionTopToBottom;
                        break;
                    case ACTION_GENIE_BR:
                        orientation = ADTransitionBottomToTop;
                        break;
                        
                    default:
                        orientation = ADTransitionRightToLeft;
                        break;
                }
                
                SuckAction* suckAction = [[SuckAction alloc] init];
                
                CFTimeInterval startPosition = AVCoreAnimationBeginTimeAtZero + object.mfStartPosition;
                CFTimeInterval startDuration = object.mfStartAnimationDuration + MIN_DURATION;
                CGRect frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
                
                UIImage *overlayImage = nil;
                
                if (object.isKbEnabled)
                    overlayImage = [object renderingKenBurnsImage:YES];
                else
                    overlayImage = object.renderedImage;
                
                overlayImage = [overlayImage rescaleImageToSize:videoSize];
                
                NSMutableArray* overlayLayers = [suckAction startSuckAction:overlayImage startPosition:startPosition duration:startDuration orientation:orientation sourceRect:frame];
                
                for (CALayer* layer in overlayLayers)
                {
                    CABasicAnimation* startAnimation = [self startNoneAction:startPosition duration:MIN_DURATION];
                    [layer addAnimation:startAnimation forKey:nil];
                    [parentLayer addSublayer:layer];
                }
                
                CABasicAnimation *animation = [self startNoneAction:(startPosition + object.mfStartAnimationDuration - MIN_DURATION) duration:MIN_DURATION];
                [overlayLayer addAnimation:animation forKey:nil];
            }
            else if (object.startActionType == ACTION_EXPLODE)
            {
                ExplodeAction* explodeAction = [[ExplodeAction alloc] init];
                
                CFTimeInterval startPosition = AVCoreAnimationBeginTimeAtZero + object.mfStartPosition;
                CFTimeInterval startDuration = object.mfStartAnimationDuration + MIN_DURATION;
                CGRect frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
                
                UIImage *overlayImage = nil;
                
                if (object.isKbEnabled)
                    overlayImage = [object renderingKenBurnsImage:YES];
                else
                    overlayImage = object.renderedImage;
                
                overlayImage = [overlayImage rescaleImageToSize:videoSize];
                
                NSMutableArray* overlayLayers = [explodeAction startExplodeAction:overlayImage startPosition:startPosition duration:startDuration sourceRect:frame];
                
                for (CALayer* layer in overlayLayers)
                {
                    CABasicAnimation* startAnimation = [self startNoneAction:startPosition duration:MIN_DURATION];
                    [layer addAnimation:startAnimation forKey:nil];
                    
                    CAAnimationGroup* endAnimation = [self endNoneAction:(startPosition + startDuration - MIN_DURATION) duration:MIN_DURATION fromTransform:inTranslationTransform fromZoomValue:toZoomValue];
                    [layer addAnimation:endAnimation forKey:nil];
                    
                    [parentLayer addSublayer:layer];
                }
                
                CABasicAnimation *animation = [self startNoneAction:(startPosition + startDuration - MIN_DURATION) duration:MIN_DURATION];
                [overlayLayer addAnimation:animation forKey:nil];
            }
            else if (object.startActionType == ACTION_ROTATE)
            {
                CALayer *rotateLayer = [CALayer layer];
                rotateLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
                rotateLayer.backgroundColor = [UIColor clearColor].CGColor;
                
                UIImage* renderedImage = [object renderingImageView];
                [rotateLayer setContents:(id)[renderedImage CGImage]];
                
                CFTimeInterval startPosition = AVCoreAnimationBeginTimeAtZero + object.mfStartPosition;
                CFTimeInterval startDuration = object.mfStartAnimationDuration + MIN_DURATION;
                CGRect frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
                
                RotateAction* rotateAction = [[RotateAction alloc] init];
                CAAnimationGroup* startAnimation = [rotateAction startRotateAction:startPosition duration:startDuration sourceRect:frame];
                [rotateLayer addAnimation:startAnimation forKey:nil];
                
                CAAnimationGroup* endAnimation = [self endNoneAction:(startPosition + startDuration - MIN_DURATION) duration:MIN_DURATION fromTransform:inTranslationTransform fromZoomValue:toZoomValue];
                [rotateLayer addAnimation:endAnimation forKey:nil];
                
                [parentLayer addSublayer:rotateLayer];
                
                CABasicAnimation *animation = [self startNoneAction:(startPosition + startDuration - MIN_DURATION) duration:MIN_DURATION];
                [overlayLayer addAnimation:animation forKey:nil];
            }
            
            if ((object.endActionType == ACTION_GENIE_BT)||(object.endActionType == ACTION_GENIE_TB)||(object.endActionType == ACTION_GENIE_LR)||(object.endActionType == ACTION_GENIE_RL))
            {
                ADTransitionOrientation orientation = ADTransitionLeftToRight;
                
                switch (object.endActionType)
                {
                    case ACTION_GENIE_RL:
                        orientation = ADTransitionRightToLeft;
                        break;
                    case ACTION_GENIE_LR:
                        orientation = ADTransitionLeftToRight;
                        break;
                    case ACTION_GENIE_TB:
                        orientation = ADTransitionBottomToTop;
                        break;
                    case ACTION_GENIE_BT:
                        orientation = ADTransitionTopToBottom;
                        break;
                        
                    default:
                        orientation = ADTransitionRightToLeft;
                        break;
                }
                
                GenieAction* genieAction = [[GenieAction alloc] init];
                
                CFTimeInterval endPosition = AVCoreAnimationBeginTimeAtZero +  object.mfEndPosition - object.mfEndAnimationDuration - MIN_DURATION;
                CFTimeInterval endDuration = object.mfEndAnimationDuration;
                CGRect frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
                
                UIImage *overlayImage = nil;
                
                if (object.isKbEnabled)
                    overlayImage = [object renderingKenBurnsImage:NO];
                else
                    overlayImage = object.renderedImage;
                
                overlayImage = [overlayImage rescaleImageToSize:videoSize];
                
                NSMutableArray* overlayLayers = [genieAction endGenieAction:overlayImage endPosition:endPosition duration:endDuration orientation:orientation sourceRect:frame];
                
                for (CALayer* layer in overlayLayers)
                {
                    CABasicAnimation* startAnimation = [self startNoneAction:endPosition duration:MIN_DURATION];
                    [layer addAnimation:startAnimation forKey:nil];
                    [parentLayer addSublayer:layer];
                }
                
                CAAnimationGroup* endAnimation = [self endNoneAction:endPosition duration:MIN_DURATION fromTransform:inTranslationTransform fromZoomValue:toZoomValue];
                [overlayLayer addAnimation:endAnimation forKey:nil];
            }
            else if ((object.endActionType == ACTION_GENIE_BL)||(object.endActionType == ACTION_GENIE_BR)||(object.endActionType == ACTION_GENIE_TL)||(object.endActionType == ACTION_GENIE_TR))
            {
                ADTransitionOrientation orientation = ADTransitionLeftToRight;
                
                switch (object.endActionType)
                {
                    case ACTION_GENIE_TR:
                        orientation = ADTransitionRightToLeft;
                        break;
                    case ACTION_GENIE_TL:
                        orientation = ADTransitionLeftToRight;
                        break;
                    case ACTION_GENIE_BL:
                        orientation = ADTransitionTopToBottom;
                        break;
                    case ACTION_GENIE_BR:
                        orientation = ADTransitionBottomToTop;
                        break;
                        
                    default:
                        orientation = ADTransitionRightToLeft;
                        break;
                }
                
                SuckAction* suckAction = [[SuckAction alloc] init];
                
                CFTimeInterval endPosition = AVCoreAnimationBeginTimeAtZero +  object.mfEndPosition - object.mfEndAnimationDuration - MIN_DURATION;
                CFTimeInterval endDuration = object.mfEndAnimationDuration;
                CGRect frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
                
                UIImage *overlayImage = nil;
                
                if (object.isKbEnabled)
                    overlayImage = [object renderingKenBurnsImage:NO];
                else
                    overlayImage = object.renderedImage;
                
                overlayImage = [overlayImage rescaleImageToSize:videoSize];
                
                NSMutableArray* overlayLayers = [suckAction endSuckAction:overlayImage endPosition:endPosition duration:endDuration orientation:orientation sourceRect:frame];
                
                for (CALayer* layer in overlayLayers)
                {
                    CABasicAnimation* startAnimation = [self startNoneAction:endPosition duration:MIN_DURATION];
                    [layer addAnimation:startAnimation forKey:nil];
                    [parentLayer addSublayer:layer];
                }
                
                CAAnimationGroup* endAnimation = [self endNoneAction:endPosition duration:MIN_DURATION fromTransform:inTranslationTransform fromZoomValue:toZoomValue];
                [overlayLayer addAnimation:endAnimation forKey:nil];
            }
            else if (object.endActionType == ACTION_EXPLODE)
            {
                ExplodeAction* explodeAction = [[ExplodeAction alloc] init];
                
                CFTimeInterval endPosition = AVCoreAnimationBeginTimeAtZero +  object.mfEndPosition - object.mfEndAnimationDuration - MIN_DURATION;
                CFTimeInterval endDuration = object.mfEndAnimationDuration;
                CGRect frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
                
                UIImage *overlayImage = nil;
                
                if (object.isKbEnabled)
                    overlayImage = [object renderingKenBurnsImage:NO];
                else
                    overlayImage = object.renderedImage;
                
                overlayImage = [overlayImage rescaleImageToSize:videoSize];
                
                NSMutableArray* overlayLayers = [explodeAction endExplodeAction:overlayImage endPosition:endPosition duration:endDuration sourceRect:frame];
                
                for (CALayer* layer in overlayLayers)
                {
                    CABasicAnimation* startAnimation = [self startNoneAction:endPosition duration:MIN_DURATION];
                    [layer addAnimation:startAnimation forKey:nil];
                    [parentLayer addSublayer:layer];
                }
                
                CAAnimationGroup* endAnimation = [self endNoneAction:endPosition duration:MIN_DURATION fromTransform:inTranslationTransform fromZoomValue:toZoomValue];
                [overlayLayer addAnimation:endAnimation forKey:nil];
            }
            else if (object.endActionType == ACTION_ROTATE)
            {
                CFTimeInterval endPosition = AVCoreAnimationBeginTimeAtZero +  object.mfEndPosition - object.mfEndAnimationDuration - MIN_DURATION;
                CFTimeInterval endDuration = object.mfEndAnimationDuration;
                CGRect frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
                
                UIImage* renderedImage = [object renderingImageView];
                
                CALayer *rotateLayer = [CALayer layer];
                rotateLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
                rotateLayer.backgroundColor = [UIColor clearColor].CGColor;
                [rotateLayer setContents:(id)[renderedImage CGImage]];
                
                CABasicAnimation* startAnimation = [self startNoneAction:endPosition duration:MIN_DURATION];
                [rotateLayer addAnimation:startAnimation forKey:nil];
                
                RotateAction* rotateAction = [[RotateAction alloc] init];
                CAAnimationGroup* endAnimation = [rotateAction endRotateAction:endPosition duration:endDuration sourceRect:frame fromTransform:inTranslationTransform fromZoomValue:toZoomValue];
                [rotateLayer addAnimation:endAnimation forKey:nil];
                [parentLayer addSublayer:rotateLayer];
                
                CAAnimationGroup* animation = [self endNoneAction:endPosition+MIN_DURATION duration:MIN_DURATION fromTransform:inTranslationTransform fromZoomValue:toZoomValue];
                [overlayLayer addAnimation:animation forKey:nil];
            }
            
            [parentLayer addSublayer:overlayLayer];
        }
    }
    
    AVVideoCompositionCoreAnimationTool* animationTool = [AVVideoCompositionCoreAnimationTool
                                                          videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
    
    return animationTool;
}


#pragma mark -

- (CABasicAnimation*) getStartAction:(MediaObjectView*) object
{
    CABasicAnimation *startAnimation = nil;
    CFTimeInterval startPosition = AVCoreAnimationBeginTimeAtZero + object.mfStartPosition;
    CFTimeInterval startDuration = object.mfStartAnimationDuration;
    
    if (object.startActionType == ACTION_NONE)
    {
        if (object.mfStartPosition == 0.0f) {
            startAnimation = nil;
        }
        else{
            startAnimation = [self startNoneAction:startPosition duration:startDuration];
        }
    }
    else if (object.startActionType == ACTION_FADE){
        startAnimation = [self startFadeAction:startPosition duration:startDuration];
    }
    else if (object.startActionType == ACTION_BLACK){
        startAnimation = [self startFadeAction:(startPosition + startDuration - MIN_DURATION) duration:MIN_DURATION];
    }
    
    return startAnimation;
}

- (CAAnimationGroup*) getEndAction:(MediaObjectView*) object fromTransform:(CATransform3D)inTranslationTransform fromZoomValue:(CGFloat)toZoomValue
{
    CAAnimationGroup *endAnimation = nil;
    CFTimeInterval endPosition = AVCoreAnimationBeginTimeAtZero + object.mfEndPosition - object.mfEndAnimationDuration;
    CFTimeInterval endDuration = object.mfEndAnimationDuration;
    
    if (object.endActionType == ACTION_NONE)
    {
        endPosition = AVCoreAnimationBeginTimeAtZero + object.mfEndPosition;
        endDuration = MIN_DURATION;
        endAnimation = [self endNoneAction:endPosition duration:endDuration fromTransform:inTranslationTransform fromZoomValue:toZoomValue];
    }
    else if (object.endActionType == ACTION_FADE)
    {
        endAnimation = [self endFadeAction:endPosition duration:endDuration fromTransform:inTranslationTransform fromZoomValue:toZoomValue];
    }
    else if (object.endActionType == ACTION_BLACK)
    {
        endAnimation = [self endFadeAction:endPosition duration:MIN_DURATION fromTransform:inTranslationTransform fromZoomValue:toZoomValue];
    }
    
    return endAnimation;
}


#pragma mark -

- (CAAnimationGroup*) getStartGroupAction:(MediaObjectView*) object
{
    CAAnimationGroup *startAnimation = nil;
    CFTimeInterval startPosition = AVCoreAnimationBeginTimeAtZero + object.mfStartPosition;
    CFTimeInterval startDuration = object.mfStartAnimationDuration;
    
    CGRect frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
    
    if ((object.startActionType >= ACTION_ZOOM_BL)&&(object.startActionType <= ACTION_ZOOM_TR)){
        
        startAnimation = [self startZoomAction:startPosition duration:startDuration type:object.startActionType sourceRect:frame];
    }
    else if ((object.startActionType >= ACTION_SLIDE_BL)&&(object.startActionType <= ACTION_SLIDE_TR))
    {
        ADTransitionOrientation orientation = ADTransitionLeftToRight;
        
        switch (object.startActionType)
        {
            case ACTION_SLIDE_RL:
                orientation = ADTransitionRightToLeft;
                break;
            case ACTION_SLIDE_LR:
                orientation = ADTransitionLeftToRight;
                break;
            case ACTION_SLIDE_TB:
                orientation = ADTransitionTopToBottom;
                break;
            case ACTION_SLIDE_BT:
                orientation = ADTransitionBottomToTop;
                break;
            case ACTION_SLIDE_BL:
                orientation = ADTransitionBottomLeft;
                break;
            case ACTION_SLIDE_BR:
                orientation = ADTransitionBottomRight;
                break;
            case ACTION_SLIDE_TL:
                orientation = ADTransitionTopLeft;
                break;
            case ACTION_SLIDE_TR:
                orientation = ADTransitionTopRight;
                break;

            default:
                orientation = ADTransitionRightToLeft;
                break;
        }
        
        startAnimation = [self startSlideAction:startPosition duration:startDuration orientation:orientation sourceRect:frame];
    }
    else if ((object.startActionType >= ACTION_FOLD_BT)&&(object.startActionType <= ACTION_FOLD_TB))
    {
        ADTransitionOrientation orientation = ADTransitionLeftToRight;
        
        switch (object.startActionType)
        {
            case ACTION_FOLD_RL:
                orientation = ADTransitionRightToLeft;
                break;
            case ACTION_FOLD_LR:
                orientation = ADTransitionLeftToRight;
                break;
            case ACTION_FOLD_TB:
                orientation = ADTransitionTopToBottom;
                break;
            case ACTION_FOLD_BT:
                orientation = ADTransitionBottomToTop;
                break;
                
            default:
                orientation = ADTransitionRightToLeft;
                break;
        }
        
        FlipAction* flipAction = [[FlipAction alloc] init];
        startAnimation = [flipAction startFlipAction:startPosition duration:startDuration orientation:orientation sourceRect:frame];
    }
    else if ((object.startActionType >= ACTION_SWAP_BL)&&(object.startActionType <= ACTION_SWAP_TR))
    {
        ADTransitionOrientation orientation = ADTransitionLeftToRight;
        
        switch (object.startActionType)
        {
            case ACTION_SWAP_RL:
                orientation = ADTransitionRightToLeft;
                break;
            case ACTION_SWAP_LR:
                orientation = ADTransitionLeftToRight;
                break;
            case ACTION_SWAP_TB:
                orientation = ADTransitionTopToBottom;
                break;
            case ACTION_SWAP_BT:
                orientation = ADTransitionBottomToTop;
                break;
            case ACTION_SWAP_BL:
                orientation = ADTransitionBottomLeft;
                break;
            case ACTION_SWAP_BR:
                orientation = ADTransitionBottomRight;
                break;
            case ACTION_SWAP_TL:
                orientation = ADTransitionTopLeft;
                break;
            case ACTION_SWAP_TR:
                orientation = ADTransitionTopRight;
                break;

            default:
                orientation = ADTransitionRightToLeft;
                break;
        }
        
        SwapAction* swapAction = [[SwapAction alloc] init];
        startAnimation = [swapAction startSwapAction:startPosition duration:startDuration orientation:orientation sourceRect:frame];
    }
    else if (object.startActionType == ACTION_ROTATE)
    {
        RotateAction* rotateAction = [[RotateAction alloc] init];
        startAnimation = [rotateAction startRotateAction:startPosition duration:startDuration sourceRect:frame];
    }
    else if ((object.startActionType >= ACTION_FLIP_BT)&&(object.startActionType <= ACTION_FLIP_TB))
    {
        ADTransitionOrientation orientation = ADTransitionLeftToRight;
        
        switch (object.startActionType)
        {
            case ACTION_FLIP_RL:
                orientation = ADTransitionRightToLeft;
                break;
            case ACTION_FLIP_LR:
                orientation = ADTransitionLeftToRight;
                break;
            case ACTION_FLIP_TB:
                orientation = ADTransitionTopToBottom;
                break;
            case ACTION_FLIP_BT:
                orientation = ADTransitionBottomToTop;
                break;
                
            default:
                orientation = ADTransitionRightToLeft;
                break;
        }
        
        FoldAction* foldAction = [[FoldAction alloc] init];
        startAnimation = [foldAction startFoldAction:startPosition duration:startDuration orientation:orientation sourceRect:frame];
    }
    else if ((object.startActionType >= ACTION_SWING_BT)&&(object.startActionType <= ACTION_SWING_TB))
    {
        ADTransitionOrientation orientation = ADTransitionLeftToRight;
        
        switch (object.startActionType)
        {
            case ACTION_SWING_RL:
                orientation = ADTransitionRightToLeft;
                break;
            case ACTION_SWING_LR:
                orientation = ADTransitionLeftToRight;
                break;
            case ACTION_SWING_TB:
                orientation = ADTransitionTopToBottom;
                break;
            case ACTION_SWING_BT:
                orientation = ADTransitionBottomToTop;
                break;
                
            default:
                orientation = ADTransitionRightToLeft;
                break;
        }
        
        SwingAction* swingAction = [[SwingAction alloc] init];
        startAnimation = [swingAction startSwingAction:startPosition duration:startDuration orientation:orientation sourceRect:frame];
    }
    else if (object.startActionType == ACTION_SPIN_CC)
    {
        SpinAction* spinAction = [[SpinAction alloc] init];
        startAnimation = [spinAction startSpinAction:startPosition duration:startDuration];
    }

    return startAnimation;
}

- (CAAnimationGroup*) getEndGroupAction:(MediaObjectView*) object fromTransform:(CATransform3D) fromTransform fromZoomValue:(CGFloat) fromZoomValue
{
    CAAnimationGroup *endAnimation = nil;
    CFTimeInterval endPosition = AVCoreAnimationBeginTimeAtZero +  object.mfEndPosition - object.mfEndAnimationDuration;
    CFTimeInterval endDuration = object.mfEndAnimationDuration;
    CGRect frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
    
    if ((object.endActionType >= ACTION_ZOOM_BL)&&(object.endActionType <= ACTION_ZOOM_TR))
    {
        endAnimation = [self endZoomAction:endPosition duration:endDuration type:object.endActionType sourceRect:frame fromTransform:fromTransform fromZoomValue:fromZoomValue];
    }
    else if ((object.endActionType >= ACTION_SLIDE_BL)&&(object.endActionType <= ACTION_SLIDE_TR))
    {
        ADTransitionOrientation orientation = ADTransitionRightToLeft;////////////////////////
        
        switch (object.endActionType)
        {
            case ACTION_SLIDE_RL:
                orientation = ADTransitionRightToLeft;
                break;
            case ACTION_SLIDE_LR:
                orientation = ADTransitionLeftToRight;
                break;
            case ACTION_SLIDE_TB:
                orientation = ADTransitionTopToBottom;
                break;
            case ACTION_SLIDE_BT:
                orientation = ADTransitionBottomToTop;
                break;
            case ACTION_SLIDE_BL:
                orientation = ADTransitionBottomLeft;
                break;
            case ACTION_SLIDE_BR:
                orientation = ADTransitionBottomRight;
                break;
            case ACTION_SLIDE_TL:
                orientation = ADTransitionTopLeft;
                break;
            case ACTION_SLIDE_TR:
                orientation = ADTransitionTopRight;
                break;

            default:
                orientation = ADTransitionRightToLeft;
                break;
        }
        
        endAnimation = [self endSlideAction:endPosition duration:endDuration orientation:orientation sourceRect:frame];
    }
    else if ((object.endActionType >= ACTION_FOLD_BT)&&(object.endActionType <= ACTION_FOLD_TB))
    {
        ADTransitionOrientation orientation = ADTransitionLeftToRight;
        
        switch (object.endActionType)
        {
            case ACTION_FOLD_RL:
                orientation = ADTransitionRightToLeft;
                break;
            case ACTION_FOLD_LR:
                orientation = ADTransitionLeftToRight;
                break;
            case ACTION_FOLD_TB:
                orientation = ADTransitionTopToBottom;
                break;
            case ACTION_FOLD_BT:
                orientation = ADTransitionBottomToTop;
                break;
                
            default:
                orientation = ADTransitionRightToLeft;
                break;
        }
        
        FlipAction* flipAction = [[FlipAction alloc] init];
        endAnimation = [flipAction endFlipAction:endPosition duration:endDuration orientation:orientation sourceRect:frame fromTransform:fromTransform fromZoomValue:fromZoomValue];
    }
    else if ((object.endActionType >= ACTION_SWAP_BL)&&(object.endActionType <= ACTION_SWAP_TR))
    {
        ADTransitionOrientation orientation = ADTransitionLeftToRight;
        
        switch (object.endActionType)
        {
            case ACTION_SWAP_RL:
                orientation = ADTransitionRightToLeft;
                break;
            case ACTION_SWAP_LR:
                orientation = ADTransitionLeftToRight;
                break;
            case ACTION_SWAP_TB:
                orientation = ADTransitionTopToBottom;
                break;
            case ACTION_SWAP_BT:
                orientation = ADTransitionBottomToTop;
                break;
            case ACTION_SWAP_BL:
                orientation = ADTransitionBottomLeft;
                break;
            case ACTION_SWAP_BR:
                orientation = ADTransitionBottomRight;
                break;
            case ACTION_SWAP_TL:
                orientation = ADTransitionTopLeft;
                break;
            case ACTION_SWAP_TR:
                orientation = ADTransitionTopRight;
                break;

            default:
                orientation = ADTransitionRightToLeft;
                break;
        }
        
        SwapAction* swapAction = [[SwapAction alloc] init];
        endAnimation = [swapAction endSwapAction:endPosition duration:endDuration orientation:orientation sourceRect:frame fromTransform:fromTransform fromZoomValue:fromZoomValue];
    }
    else if (object.endActionType == ACTION_ROTATE)
    {
        RotateAction* rotateAction = [[RotateAction alloc] init];
        endAnimation = [rotateAction endRotateAction:endPosition duration:endDuration sourceRect:frame fromTransform:fromTransform fromZoomValue:fromZoomValue];
    }
    else if ((object.endActionType >= ACTION_FLIP_BT)&&(object.endActionType <= ACTION_FLIP_TB))
    {
        ADTransitionOrientation orientation = ADTransitionLeftToRight;
        
        switch (object.endActionType)
        {
            case ACTION_FLIP_RL:
                orientation = ADTransitionRightToLeft;
                break;
            case ACTION_FLIP_LR:
                orientation = ADTransitionLeftToRight;
                break;
            case ACTION_FLIP_TB:
                orientation = ADTransitionTopToBottom;
                break;
            case ACTION_FLIP_BT:
                orientation = ADTransitionBottomToTop;
                break;
                
            default:
                orientation = ADTransitionRightToLeft;
                break;
        }
        
        FoldAction* foldAction = [[FoldAction alloc] init];
        endAnimation = [foldAction endFoldAction:endPosition duration:endDuration orientation:orientation sourceRect:frame fromTransform:fromTransform fromZoomValue:fromZoomValue];
    }
    else if ((object.endActionType >= ACTION_SWING_BT)&&(object.endActionType <= ACTION_SWING_TB))
    {
        ADTransitionOrientation orientation = ADTransitionLeftToRight;
        
        switch (object.endActionType)
        {
            case ACTION_SWING_RL:
                orientation = ADTransitionRightToLeft;
                break;
            case ACTION_SWING_LR:
                orientation = ADTransitionLeftToRight;
                break;
            case ACTION_SWING_TB:
                orientation = ADTransitionTopToBottom;
                break;
            case ACTION_SWING_BT:
                orientation = ADTransitionBottomToTop;
                break;
                
            default:
                orientation = ADTransitionRightToLeft;
                break;
        }
        
        SwingAction* swingAction = [[SwingAction alloc] init];
        endAnimation = [swingAction endSwingAction:endPosition duration:endDuration orientation:orientation sourceRect:frame fromTransform:fromTransform fromZoomValue:fromZoomValue];
    }
    else if (object.endActionType == ACTION_SPIN_CC)
    {
        SpinAction* spinAction = [[SpinAction alloc] init];
        endAnimation = [spinAction endSpinAction:endPosition duration:endDuration fromTransform:fromTransform fromZoomValue:fromZoomValue];
    }

    return endAnimation;
}


#pragma mark - "None" Action
- (CABasicAnimation*) startNoneAction:(CFTimeInterval) startPosition duration:(CFTimeInterval) duration
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.fromValue = [NSNumber numberWithFloat:0.0];
    animation.toValue = [NSNumber numberWithFloat:1.0];
    animation.additive = NO;
    animation.fillMode = kCAFillModeBackwards;
    animation.beginTime = startPosition;
    animation.duration = MIN_DURATION;
    
    return animation;
}

- (CAAnimationGroup*) endNoneAction:(CFTimeInterval) endPosition duration:(CFTimeInterval) duration fromTransform:(CATransform3D) fromTransform fromZoomValue:(CGFloat) fromZoomValue
{
    CAKeyframeAnimation * outPosition = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    outPosition.values = @[[NSValue valueWithCATransform3D:fromTransform]];
    
    CAKeyframeAnimation *scaleAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.values = @[[NSNumber numberWithFloat:fromZoomValue]];

    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.fromValue = [NSNumber numberWithFloat:1.0];
    animation.toValue = [NSNumber numberWithFloat:0.0];
    
    CAAnimationGroup * outAnimation = [CAAnimationGroup animation];
    [outAnimation setAnimations:@[outPosition, scaleAnimation, animation]];
    outAnimation.beginTime = endPosition;
    outAnimation.duration = MIN_DURATION;
    outAnimation.removedOnCompletion = NO;
    outAnimation.fillMode = kCAFillModeForwards;

    return outAnimation;
}


#pragma mark - "Fade" Action
- (CABasicAnimation*) startFadeAction:(CFTimeInterval) startPosition duration:(CFTimeInterval) duration
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.fromValue = [NSNumber numberWithFloat:0.0];
    animation.toValue = [NSNumber numberWithFloat:1.0];
    animation.additive = NO;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeBackwards;
    animation.beginTime = startPosition;
    animation.duration = duration;
    
    return animation;
}

- (CAAnimationGroup*) endFadeAction:(CFTimeInterval) endPosition duration:(CFTimeInterval) duration fromTransform:(CATransform3D) fromTransform fromZoomValue:(CGFloat) fromZoomValue
{
    CAKeyframeAnimation * outPosition = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    outPosition.values = @[[NSValue valueWithCATransform3D:fromTransform]];
    
    CAKeyframeAnimation *scaleAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.values = @[[NSNumber numberWithFloat:fromZoomValue]];

    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.fromValue = [NSNumber numberWithFloat:1.0];
    animation.toValue = [NSNumber numberWithFloat:0.0];
    
    CAAnimationGroup * outAnimation = [CAAnimationGroup animation];
    [outAnimation setAnimations:@[outPosition, scaleAnimation, animation]];
    outAnimation.beginTime = endPosition;
    outAnimation.duration = duration;
    outAnimation.removedOnCompletion = NO;
    outAnimation.fillMode = kCAFillModeForwards;
    
    return outAnimation;
}



#pragma mark - "Zoom" Action
- (CAAnimationGroup*) startZoomAction:(CFTimeInterval) startPosition duration:(CFTimeInterval) duration type:(int)actionType sourceRect:(CGRect)sourceRect
{
    const CGFloat viewWidth = sourceRect.size.width;
    const CGFloat viewHeight = sourceRect.size.height;
    CATransform3D inTranslationTransform = CATransform3DIdentity;

    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
    scaleAnimation.toValue = [NSNumber numberWithDouble:1.0f];
    scaleAnimation.additive = NO;
    scaleAnimation.removedOnCompletion = NO;
    scaleAnimation.fillMode = kCAFillModeBackwards;
    
    switch (actionType)
    {
        case ACTION_ZOOM_CC:
            inTranslationTransform = CATransform3DMakeTranslation(0, 0, 0);
            break;
            
        case ACTION_ZOOM_RL:
            inTranslationTransform = CATransform3DMakeTranslation(viewWidth*0.6f, 0, 0);
            break;
            
        case ACTION_ZOOM_LR:
            inTranslationTransform = CATransform3DMakeTranslation(-viewWidth*0.6f, 0, 0);
            break;
            
        case ACTION_ZOOM_TB:
            inTranslationTransform = CATransform3DMakeTranslation(0, viewHeight*0.6f, 0);
            break;
            
        case ACTION_ZOOM_BT:
            inTranslationTransform = CATransform3DMakeTranslation(0, -viewHeight*0.6f, 0);
            break;

        case ACTION_ZOOM_BL:
            inTranslationTransform = CATransform3DMakeTranslation(-viewWidth*0.6f, -viewHeight*0.6f, 0);
            break;

        case ACTION_ZOOM_BR:
            inTranslationTransform = CATransform3DMakeTranslation(viewWidth*0.6f, -viewHeight*0.6f, 0);
            break;
            
        case ACTION_ZOOM_TL:
            inTranslationTransform = CATransform3DMakeTranslation(-viewWidth*0.6f, viewHeight*0.6f, 0);
            break;

        case ACTION_ZOOM_TR:
            inTranslationTransform = CATransform3DMakeTranslation(viewWidth*0.6f, viewHeight*0.6f, 0);
            break;

        default:
            NSAssert(FALSE, @"Unhandled ADTransitionOrientation");
            break;
    }
    
    CAKeyframeAnimation * inKeyFrameTransformAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    inKeyFrameTransformAnimation.values = @[[NSValue valueWithCATransform3D:inTranslationTransform],
                                            [NSValue valueWithCATransform3D:CATransform3DIdentity]];
    inKeyFrameTransformAnimation.additive = NO;
    inKeyFrameTransformAnimation.fillMode = kCAFillModeBackwards;
    
    CAAnimationGroup * inAnimation = [CAAnimationGroup animation];
    inAnimation.animations = @[inKeyFrameTransformAnimation, scaleAnimation];
    inAnimation.beginTime = startPosition;
    inAnimation.duration = duration;
    inAnimation.removedOnCompletion = YES;
    inAnimation.fillMode = kCAFillModeBackwards;
    inAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];

    return inAnimation;
}

- (CAAnimationGroup*) endZoomAction:(CFTimeInterval) endPosition duration:(CFTimeInterval) duration type:(int)actionType sourceRect:(CGRect)sourceRect fromTransform:(CATransform3D) fromTransform fromZoomValue:(CGFloat) fromZoomValue
{
    const CGFloat viewWidth = sourceRect.size.width;
    const CGFloat viewHeight = sourceRect.size.height;
    CATransform3D outTranslationTransform = CATransform3DIdentity;

    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    animation.fromValue = [NSNumber numberWithFloat:fromZoomValue];
    animation.toValue = [NSNumber numberWithDouble:0.0f];
    animation.additive = NO;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    
    switch (actionType)
    {
        case ACTION_ZOOM_CC:
            outTranslationTransform = CATransform3DMakeTranslation(0, 0, 0);
            break;
            
        case ACTION_ZOOM_RL:
            outTranslationTransform = CATransform3DMakeTranslation(-viewWidth*0.6f, 0, 0);
            break;
            
        case ACTION_ZOOM_LR:
            outTranslationTransform = CATransform3DMakeTranslation(viewWidth*0.6f, 0, 0);
            break;
            
        case ACTION_ZOOM_TB:
            outTranslationTransform = CATransform3DMakeTranslation(0, -viewHeight*0.6f, 0);
            break;
            
        case ACTION_ZOOM_BT:
            outTranslationTransform = CATransform3DMakeTranslation(0, viewHeight*0.6f, 0);
            break;

        case ACTION_ZOOM_BL:
            outTranslationTransform = CATransform3DMakeTranslation(-viewWidth*0.6f, -viewHeight*0.6f, 0);
            break;

        case ACTION_ZOOM_BR:
            outTranslationTransform = CATransform3DMakeTranslation(viewWidth*0.6f, -viewHeight*0.6f, 0);
            break;

        case ACTION_ZOOM_TL:
            outTranslationTransform = CATransform3DMakeTranslation(-viewWidth*0.6f, viewHeight*0.6f, 0);
            break;

        case ACTION_ZOOM_TR:
            outTranslationTransform = CATransform3DMakeTranslation(viewWidth*0.6f, viewHeight*0.6f, 0);
            break;

        default:
            NSAssert(FALSE, @"Unhandled ADTransitionOrientation");
            break;
    }
    
    CAKeyframeAnimation * outKeyFrameTransformAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    outKeyFrameTransformAnimation.values = @[[NSValue valueWithCATransform3D:fromTransform],
                                            [NSValue valueWithCATransform3D:outTranslationTransform]];
    outKeyFrameTransformAnimation.additive = NO;
    outKeyFrameTransformAnimation.fillMode = kCAFillModeForwards;

    CAAnimationGroup * outAnimation = [CAAnimationGroup animation];
    outAnimation.animations = @[outKeyFrameTransformAnimation, animation];
    outAnimation.beginTime = endPosition;
    outAnimation.duration = duration;
    outAnimation.removedOnCompletion = NO;
    outAnimation.fillMode = kCAFillModeForwards;
    outAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];

    return outAnimation;
}



#pragma mark - "Slide" Action
- (CAAnimationGroup*) startSlideAction:(CFTimeInterval)startPosition duration:(CFTimeInterval)duration orientation:(ADTransitionOrientation)orientation sourceRect:(CGRect)sourceRect
{
    const CGFloat viewWidth = sourceRect.size.width;
    const CGFloat viewHeight = sourceRect.size.height;
    
    CATransform3D inTranslationTransform = CATransform3DIdentity;
    
    switch (orientation) {
        case ADTransitionRightToLeft:
            inTranslationTransform = CATransform3DTranslate(CATransform3DIdentity, viewWidth, 0, 0);
            break;
            
        case ADTransitionLeftToRight:
            inTranslationTransform = CATransform3DTranslate(CATransform3DIdentity, -viewWidth, 0, 0);
            break;
            
        case ADTransitionTopToBottom:
            inTranslationTransform = CATransform3DTranslate(CATransform3DIdentity, 0, viewHeight, 0);
            break;
            
        case ADTransitionBottomToTop:
            inTranslationTransform = CATransform3DTranslate(CATransform3DIdentity, 0, -viewHeight, 0);
            break;

        case ADTransitionBottomLeft:
            inTranslationTransform = CATransform3DTranslate(CATransform3DIdentity, -viewWidth, -viewHeight, 0);
            break;

        case ADTransitionBottomRight:
            inTranslationTransform = CATransform3DTranslate(CATransform3DIdentity, viewWidth, -viewHeight, 0);
            break;

        case ADTransitionTopLeft:
            inTranslationTransform = CATransform3DTranslate(CATransform3DIdentity, -viewWidth, viewHeight, 0);
            break;

        case ADTransitionTopRight:
            inTranslationTransform = CATransform3DTranslate(CATransform3DIdentity, viewWidth, viewHeight, 0);
            break;

        default:
            NSAssert(FALSE, @"Unhandled ADTransitionOrientation");
            break;
    }
    
    CAKeyframeAnimation * inKeyFrameTransformAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    inKeyFrameTransformAnimation.values = @[[NSValue valueWithCATransform3D:inTranslationTransform],
                                            [NSValue valueWithCATransform3D:CATransform3DIdentity]];
    inKeyFrameTransformAnimation.additive = NO;
    inKeyFrameTransformAnimation.fillMode = kCAFillModeBackwards;
    inKeyFrameTransformAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];

    CAAnimationGroup * inAnimation = [CAAnimationGroup animation];
    inAnimation.animations = @[inKeyFrameTransformAnimation];
    inAnimation.beginTime = startPosition;
    inAnimation.duration = duration;
    inAnimation.removedOnCompletion = NO;
    inAnimation.fillMode = kCAFillModeBackwards;

    return inAnimation;
}

- (CAAnimationGroup*) endSlideAction:(CFTimeInterval)endPosition duration:(CFTimeInterval)duration orientation:(ADTransitionOrientation)orientation sourceRect:(CGRect)sourceRect
{
    const CGFloat viewWidth = sourceRect.size.width;
    const CGFloat viewHeight = sourceRect.size.height;
    CATransform3D outTranslationTransform = CATransform3DIdentity;
    
    switch (orientation)
    {
        case ADTransitionRightToLeft:
            outTranslationTransform = CATransform3DTranslate(CATransform3DIdentity, -viewWidth, 0, 0);
            break;
            
        case ADTransitionLeftToRight:
            outTranslationTransform = CATransform3DTranslate(CATransform3DIdentity, viewWidth, 0, 0);
            break;
            
        case ADTransitionTopToBottom:
            outTranslationTransform = CATransform3DTranslate(CATransform3DIdentity, 0, -viewHeight, 0);
            break;
            
        case ADTransitionBottomToTop:
            outTranslationTransform = CATransform3DTranslate(CATransform3DIdentity, 0, viewHeight, 0);
            break;

        case ADTransitionBottomLeft:
            outTranslationTransform = CATransform3DTranslate(CATransform3DIdentity, -viewWidth, -viewHeight, 0);
            break;

        case ADTransitionBottomRight:
            outTranslationTransform = CATransform3DTranslate(CATransform3DIdentity, viewWidth, -viewHeight, 0);
            break;

        case ADTransitionTopLeft:
            outTranslationTransform = CATransform3DTranslate(CATransform3DIdentity, -viewWidth, viewHeight, 0);
            break;
            
        case ADTransitionTopRight:
            outTranslationTransform = CATransform3DTranslate(CATransform3DIdentity, viewWidth, viewHeight, 0);
            break;

        default:
            NSAssert(FALSE, @"Unhandled ADTransitionOrientation");
            break;
    }
    
    CAKeyframeAnimation * outKeyFrameTransformAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    outKeyFrameTransformAnimation.values = @[[NSValue valueWithCATransform3D:CATransform3DIdentity],
                                             [NSValue valueWithCATransform3D:outTranslationTransform]];
    outKeyFrameTransformAnimation.additive = NO;
    outKeyFrameTransformAnimation.fillMode = kCAFillModeForwards;
    outKeyFrameTransformAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];


    CAAnimationGroup * outAnimation = [CAAnimationGroup animation];
    outAnimation.animations = @[outKeyFrameTransformAnimation];
    outAnimation.beginTime = endPosition;
    outAnimation.duration = duration;
    outAnimation.removedOnCompletion = NO;
    outAnimation.fillMode = kCAFillModeForwards;

    return outAnimation;
}


#pragma mark - 
#pragma mark - setVideoTrackTimeRange

-(AVMutableCompositionTrack*) setVideoTrackTimeRange:(AVURLAsset*) inputAsset object:(MediaObjectView*) object track:(AVMutableCompositionTrack*) videoTrack
{
    NSArray *videoDataSourceArray = [NSArray arrayWithArray:[inputAsset tracksWithMediaType:AVMediaTypeVideo]];

    CMTime startTimeOnComposition = CMTimeMake(object.mfStartPosition * inputAsset.duration.timescale, inputAsset.duration.timescale);
    
    for (int i=0; i<object.motionArray.count; i++)
    {
        NSError *error = nil;
        
        NSNumber* motionNum = [object.motionArray objectAtIndex:i];
        NSNumber* startPosNum = [object.startPositionArray objectAtIndex:i];
        NSNumber* endPosNum = [object.endPositionArray objectAtIndex:i];
        
        CGFloat motionValue = [motionNum floatValue];
        CGFloat startPosition = [startPosNum floatValue];
        CGFloat endPosition = [endPosNum floatValue];
        
        CMTime duration = CMTimeMakeWithSeconds((endPosition - startPosition), inputAsset.duration.timescale);
        
        [videoTrack insertTimeRange:CMTimeRangeMake(CMTimeMake(startPosition*inputAsset.duration.timescale, inputAsset.duration.timescale), duration)
                            ofTrack:[videoDataSourceArray objectAtIndex:0]
                             atTime:startTimeOnComposition
                              error:&error];
        if(error)
            NSLog(@"Insertion error: %@", error);
        
        /************************** slow/fast motion *******************************/
        if (motionValue != 1.0f)
            [videoTrack scaleTimeRange:CMTimeRangeMake(startTimeOnComposition, duration)
                            toDuration:CMTimeMake(duration.value/motionValue, inputAsset.duration.timescale)];
        
        startTimeOnComposition = CMTimeAdd(startTimeOnComposition, CMTimeMakeWithSeconds((endPosition - startPosition)/motionValue, inputAsset.duration.timescale));
    }

    return videoTrack;
}

-(AVMutableCompositionTrack*) setAudioTrackTimeRange:(AVURLAsset*) inputAsset object:(MediaObjectView*) object track:(AVMutableCompositionTrack*) audioTrack
{
    NSArray *audioDataSourceArray = [NSArray arrayWithArray:[inputAsset tracksWithMediaType:AVMediaTypeAudio]];
    
    CMTime startTimeOnComposition = CMTimeMake(object.mfStartPosition * inputAsset.duration.timescale, inputAsset.duration.timescale);
    
    for (int i=0; i<object.motionArray.count; i++)
    {
        NSError *error = nil;
        
        NSNumber* motionNum = [object.motionArray objectAtIndex:i];
        NSNumber* startPosNum = [object.startPositionArray objectAtIndex:i];
        NSNumber* endPosNum = [object.endPositionArray objectAtIndex:i];
        
        CGFloat motionValue = [motionNum floatValue];
        CGFloat startPosition = [startPosNum floatValue];
        CGFloat endPosition = [endPosNum floatValue];
        
        CMTime duration = CMTimeMakeWithSeconds((endPosition - startPosition), inputAsset.duration.timescale);
        
        [audioTrack insertTimeRange:CMTimeRangeMake(CMTimeMake(startPosition*inputAsset.duration.timescale, inputAsset.duration.timescale), duration)
                            ofTrack:[audioDataSourceArray objectAtIndex:0]
                             atTime:startTimeOnComposition
                              error:&error];
        if(error)
            NSLog(@"Insertion error: %@", error);
        
        /************************** slow/fast motion *******************************/
        if (motionValue != 1.0f)
            [audioTrack scaleTimeRange:CMTimeRangeMake(startTimeOnComposition, duration)
                            toDuration:CMTimeMake(duration.value/motionValue, inputAsset.duration.timescale)];
        
        startTimeOnComposition = CMTimeAdd(startTimeOnComposition, CMTimeMakeWithSeconds((endPosition - startPosition)/motionValue, inputAsset.duration.timescale));
    }

    return audioTrack;
}


- (CAAnimationGroup*) startVideoAudioAction:(CFTimeInterval)startPosition duration:(CFTimeInterval)duration
{
    CABasicAnimation *animationHide = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animationHide.fromValue = [NSNumber numberWithFloat:0.0];
    animationHide.toValue = [NSNumber numberWithFloat:0.0];
    animationHide.beginTime = startPosition;
    animationHide.duration = duration;
    
    CABasicAnimation *animationShow = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animationShow.fromValue = [NSNumber numberWithFloat:0.0];
    animationShow.toValue = [NSNumber numberWithFloat:0.0];
    animationShow.beginTime = startPosition + duration;
    animationShow.duration = MIN_DURATION;
    
    CAAnimationGroup * inAnimation = [CAAnimationGroup animation];
    [inAnimation setAnimations:@[animationHide, animationShow]];
    inAnimation.beginTime = startPosition;
    inAnimation.duration = duration + MIN_DURATION;
    
    return inAnimation;
}


#pragma mark -
#pragma mark -
#pragma mark - Chromakey Filter Output

-(void) createChromaKeyFilterOutput
{
    mnProcessingIndex = 0;
    mnProcessingCount = 0;
    self.currentProcessingIdx = 0;
    
    [self.musicObjectArray removeAllObjects];
    self.musicObjectArray = nil;
    self.musicObjectArray = [[NSMutableArray alloc] init];
    
    /************************************
     move a musics to music array
     ************************************/
    
    NSInteger index = 0;
    while (index < [self.objectArray count])
    {
        MediaObjectView *object = self.objectArray[index];
        
        if (object.mediaType == MEDIA_MUSIC)
        {
            [self.musicObjectArray addObject:object];
            [self.objectArray removeObjectAtIndex:index];
            continue;
        }
        
        index ++;
    }
    
    /****************************************
     detect a processing total count
     ***************************************/
    
    BOOL isPrevVideo = YES;

    for (int i=0; i<self.objectArray.count; i++)
    {
        MediaObjectView* object = [self.objectArray objectAtIndex:i];
        
        if ((i==0) && ((object.mediaType == MEDIA_PHOTO)||(object.mediaType == MEDIA_TEXT)))
        {
            mnProcessingCount++; //make video from a first photo or text
            isPrevVideo = NO;
        }
        else if ((object.mediaType == MEDIA_VIDEO)||(object.mediaType == MEDIA_GIF))
        {
            mnProcessingCount++; //make a green video
        }
    }
    
    if (mnProcessingCount == 1)  //make a green video + apply GPUImageFilter
        mnProcessingCount = 2;
    else
        mnProcessingCount = mnProcessingCount * 2 - 1;    //make green videos "mnProgressTotalCount" + apply chromakey filter "mnProgressTotalCount - 1".
    
    for (int i=0; i<self.objectArray.count; i++)
    {
        MediaObjectView* object = [self.objectArray objectAtIndex:i];
        
        if ((object.mediaType == MEDIA_VIDEO)||(object.mediaType == MEDIA_GIF))
        {
            isPrevVideo = YES;
        }
        else if (((object.mediaType == MEDIA_PHOTO)||(object.mediaType == MEDIA_TEXT)) && isPrevVideo)
        {
            isPrevVideo = NO;
            mnProcessingCount++;
        }
    }
    
    [self createGreenVideos];
}


/*
 create a green videos from all photos, texts, videos.
 */

-(void) createGreenVideos
{
    if (self.currentProcessingIdx >= self.objectArray.count)
    {
        [self applyChromakeyToGreenVideos];
    }
    else
    {
        if (self.mixComposition != nil)
            self.mixComposition = nil;
        self.mixComposition = [[AVMutableComposition alloc] init];
        
        if(self.layerInstructionArray != nil)
        {
            [self.layerInstructionArray removeAllObjects];
            self.layerInstructionArray = nil;
        }
        
        self.layerInstructionArray = [[NSMutableArray alloc] init];
        
        MediaObjectView* mediaObj = [self.objectArray objectAtIndex:self.currentProcessingIdx];
        
        if ((mediaObj.mediaType == MEDIA_VIDEO)||(mediaObj.mediaType == MEDIA_GIF))
            [self videoToGreenVideo];
        else if (((mediaObj.mediaType == MEDIA_PHOTO)||(mediaObj.mediaType == MEDIA_TEXT)) && (self.currentProcessingIdx == 0))
            [self makeBackgroundVideoForFirstPhoto];
    }
}

-(void) videoToGreenVideo
{
    NSMutableArray *allAudioParams = [[NSMutableArray alloc] init];
    
    MediaObjectView* object = [self.objectArray objectAtIndex:self.currentProcessingIdx];
    
    AVURLAsset* inputAsset = [AVURLAsset assetWithURL:object.mediaUrl];
    
    if(inputAsset != nil)
    {
        //duration
        CMTime duration = inputAsset.duration;
        
        //VIDEO TRACK
        AVMutableCompositionTrack *videoTrack = [self.mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        videoTrack = [self setVideoTrackTimeRange:inputAsset object:object track:videoTrack];
        
        if (object.isExistAudioTrack)
        {
            //AUDIO TRACK
            NSArray *audioDataSourceArray = [NSArray arrayWithArray: [inputAsset tracksWithMediaType:AVMediaTypeAudio]];
            if ([audioDataSourceArray count] > 0)
            {
                AVMutableCompositionTrack *audioTrack = [self.mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
                
                audioTrack = [self setAudioTrackTimeRange:inputAsset object:object track:audioTrack];
                
                //volume
                CGFloat volume = [object getVolume];
                
                AVMutableAudioMixInputParameters *params;
                params =[AVMutableAudioMixInputParameters audioMixInputParameters];
                [params setVolume:volume atTime:kCMTimeZero];
                [params setTrackID:[audioTrack trackID]];
                [allAudioParams addObject:params];
            }
        }
        
        if (self.currentProcessingIdx == 0)
        {
            for (int i=0; i<self.musicObjectArray.count; i++)
            {
                MediaObjectView* audioObject = [self.musicObjectArray objectAtIndex:i];
                
                AVURLAsset* inputAudioAsset = [AVURLAsset assetWithURL:audioObject.mediaUrl];
                
                if(inputAudioAsset != nil)
                {
                    //AUDIO TRACK
                    NSArray *audioDataSourceArray = [NSArray arrayWithArray: [inputAudioAsset tracksWithMediaType:AVMediaTypeAudio]];
                    if ([audioDataSourceArray count] > 0)
                    {
                        AVMutableCompositionTrack *audioTrack = [self.mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
                        
                        CMTime startTimeOnComposition = CMTimeMake(object.mfStartPosition * inputAsset.duration.timescale, inputAsset.duration.timescale);
                        
                        for (int i=0; i<object.motionArray.count; i++)
                        {
                            NSError *error = nil;
                            
                            NSNumber* motionNum = [object.motionArray objectAtIndex:i];
                            NSNumber* startPosNum = [object.startPositionArray objectAtIndex:i];
                            NSNumber* endPosNum = [object.endPositionArray objectAtIndex:i];
                            
                            CGFloat motionValue = [motionNum floatValue];
                            CGFloat startPosition = [startPosNum floatValue];
                            CGFloat endPosition = [endPosNum floatValue];
                            
                            CMTime duration = CMTimeMakeWithSeconds((endPosition - startPosition), inputAsset.duration.timescale);
                            
                            [audioTrack insertTimeRange:CMTimeRangeMake(CMTimeMake(startPosition*inputAsset.duration.timescale, inputAsset.duration.timescale), duration)
                                                ofTrack:[audioDataSourceArray objectAtIndex:0]
                                                 atTime:startTimeOnComposition
                                                  error:&error];
                            if(error)
                                NSLog(@"Insertion error: %@", error);
                            
                            /************************** slow/fast motion *******************************/
                            if (motionValue != 1.0f)
                                [audioTrack scaleTimeRange:CMTimeRangeMake(startTimeOnComposition, duration)
                                                toDuration:CMTimeMake(duration.value/motionValue, inputAsset.duration.timescale)];
                            
                            startTimeOnComposition = CMTimeAdd(startTimeOnComposition, CMTimeMakeWithSeconds((endPosition - startPosition)/motionValue, inputAsset.duration.timescale));
                        }
                        
                        //volume
                        CGFloat volume = [audioObject getVolume];
                        
                        AVMutableAudioMixInputParameters *params;
                        params =[AVMutableAudioMixInputParameters audioMixInputParameters];
                        
                        if ((audioObject.startActionType == ACTION_NONE)&&(audioObject.endActionType == ACTION_NONE)) //[none, none]
                        {
                            [params setVolume:volume atTime:kCMTimeZero];
                        }
                        else if ((audioObject.startActionType != ACTION_NONE)&&(audioObject.endActionType != ACTION_NONE))    //[fade, fade]
                        {
                            [params setVolumeRampFromStartVolume:0.0
                                                     toEndVolume:volume
                                                       timeRange:CMTimeRangeMake(CMTimeMake(audioObject.mfStartPosition*inputAudioAsset.duration.timescale, inputAudioAsset.duration.timescale), CMTimeMake(audioObject.mfStartAnimationDuration*inputAudioAsset.duration.timescale, inputAudioAsset.duration.timescale))];
                            [params setVolumeRampFromStartVolume:volume
                                                     toEndVolume:0.0
                                                       timeRange:CMTimeRangeMake(CMTimeMake((audioObject.mfEndPosition - audioObject.mfEndAnimationDuration)*inputAudioAsset.duration.timescale, inputAudioAsset.duration.timescale), CMTimeMake(audioObject.mfEndAnimationDuration*inputAudioAsset.duration.timescale, inputAudioAsset.duration.timescale))];
                        }
                        else if ((audioObject.startActionType == ACTION_NONE)&&(audioObject.endActionType != ACTION_NONE))    //[none, fade]
                        {
                            [params setVolumeRampFromStartVolume:volume
                                                     toEndVolume:volume
                                                       timeRange:CMTimeRangeMake(CMTimeMake(audioObject.mfStartPosition*inputAudioAsset.duration.timescale, inputAudioAsset.duration.timescale), CMTimeMake(audioObject.mfStartAnimationDuration*inputAudioAsset.duration.timescale, inputAudioAsset.duration.timescale))];
                            [params setVolumeRampFromStartVolume:volume
                                                     toEndVolume:0.0
                                                       timeRange:CMTimeRangeMake(CMTimeMake((audioObject.mfEndPosition - audioObject.mfEndAnimationDuration)*inputAudioAsset.duration.timescale, inputAudioAsset.duration.timescale), CMTimeMake(audioObject.mfEndAnimationDuration*inputAudioAsset.duration.timescale, inputAudioAsset.duration.timescale))];
                            
                        }
                        else if ((audioObject.startActionType != ACTION_NONE)&&(audioObject.endActionType == ACTION_NONE))    //[fade, none]
                        {
                            [params setVolumeRampFromStartVolume:0.0
                                                     toEndVolume:volume
                                                       timeRange:CMTimeRangeMake(CMTimeMake(audioObject.mfStartPosition*inputAudioAsset.duration.timescale, inputAudioAsset.duration.timescale), CMTimeMake(audioObject.mfStartAnimationDuration*inputAudioAsset.duration.timescale, inputAudioAsset.duration.timescale))];
                            [params setVolumeRampFromStartVolume:volume
                                                     toEndVolume:volume
                                                       timeRange:CMTimeRangeMake(CMTimeMake((audioObject.mfEndPosition - audioObject.mfEndAnimationDuration)*inputAudioAsset.duration.timescale, inputAudioAsset.duration.timescale), CMTimeMake(audioObject.mfEndAnimationDuration*inputAudioAsset.duration.timescale, inputAudioAsset.duration.timescale))];
                        }
                        
                        [params setTrackID:[audioTrack trackID]];
                        [allAudioParams addObject:params];
                    }
                }
                
                inputAudioAsset = nil;
            }
        }
        
        //fix orientation, transform//
        AVMutableVideoCompositionLayerInstruction *layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
        
        AVAssetTrack *assetTrack = [[inputAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
        
        CGRect cropRect = object.normalFilterVideoCropRect;
        [layerInstruction setCropRectangle:cropRect atTime:kCMTimeZero];
        
        CGAffineTransform transform = object.nationalVideoTransformOutputValue;
        transform = CGAffineTransformScale(transform, outputScaleFactor, outputScaleFactor);
        transform = CGAffineTransformMake(transform.a, transform.b, transform.c, transform.d, transform.tx*outputScaleFactor, transform.ty*outputScaleFactor);
        [layerInstruction setTransform:CGAffineTransformConcat(assetTrack.preferredTransform, transform) atTime:kCMTimeZero];
        
        CGFloat totalDuration = [object getVideoTotalDuration];
        
        if ((object.mfStartPosition + totalDuration) > grNormalFilterOutputTotalTime)
        {
            [layerInstruction setOpacity:0.0 atTime:CMTimeMake(grNormalFilterOutputTotalTime*inputAsset.duration.timescale, inputAsset.duration.timescale)];
        }
        else
        {
            [layerInstruction setOpacity:0.0 atTime:CMTimeMake((object.mfStartPosition + totalDuration)*duration.timescale, duration.timescale)];
        }
        
        // video animations - 2014/02/03 by Yinjing Li
        layerInstruction = [self setVideoAnimation:layerInstruction mediaObject:object asset:inputAsset];
        
        [self.layerInstructionArray addObject:layerInstruction];
        
        AVMutableAudioMix * audioMix = [AVMutableAudioMix audioMix];
        [audioMix setInputParameters:allAudioParams];
        
        AVMutableVideoCompositionInstruction * MainInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
        CGFloat scale = [self getTimeScale];
        MainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMake(grNormalFilterOutputTotalTime*scale, scale));
        
        if (self.currentProcessingIdx == 0)
            MainInstruction.backgroundColor = [UIColor blackColor].CGColor;
        else
            MainInstruction.backgroundColor = object.objectChromaColor.CGColor;
        
        MainInstruction.layerInstructions = self.layerInstructionArray;
        
        AVMutableVideoComposition *MainCompositionInst = [AVMutableVideoComposition videoComposition];
        MainCompositionInst.instructions = [NSArray arrayWithObject:MainInstruction];
        MainCompositionInst.frameDuration = CMTimeMake(1, grFrameRate);
        MainCompositionInst.renderSize = videoSize;
        
        
        // video animation - 2015/05/05 by Yinjing Li
        MainCompositionInst.animationTool = [self setVideoAnimationForChromakey:self.currentProcessingIdx];
        
        
        self.pathToMovie = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"greenVideo%d.m4v", self.currentProcessingIdx]];
        
        unlink([self.pathToMovie UTF8String]); // If a file already exists, AVAssetWriter won't let you record new frames, so delete the old movie
        NSURL *url = [NSURL fileURLWithPath:self.pathToMovie];
        
        if (self.exporter != nil)
            self.exporter = nil;
        
        self.exporter = [[AVAssetExportSession alloc] initWithAsset:self.mixComposition presetName:AVAssetExportPresetHighestQuality];
        self.exporter.outputURL = url;
        self.exporter.outputFileType = AVFileTypeQuickTimeMovie;
        self.exporter.videoComposition = MainCompositionInst;
        
        if (allAudioParams.count > 0)
            [self.exporter setAudioMix:audioMix];//for volume
        
        if (isPreview && (grNormalFilterOutputTotalTime > grPreviewDuration))
            self.exporter.timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMake(grPreviewDuration*scale, scale));
        else
            self.exporter.timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMake(grNormalFilterOutputTotalTime*scale, scale));
        
        self.exporter.shouldOptimizeForNetworkUse = YES;
        
        mnProcessingIndex++;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self.delegate respondsToSelector:@selector(startAllNormalProgress:current:total:)])
                [self.delegate startAllNormalProgress:self.exporter current:mnProcessingIndex total:mnProcessingCount];
        });
        
        
        int nextVideoIndex = (int)self.objectArray.count;
        
        for (int i=self.currentProcessingIdx+1; i<self.objectArray.count; i++)
        {
            MediaObjectView* nextObject = [self.objectArray objectAtIndex:i];
            
            if ((nextObject.mediaType == MEDIA_VIDEO)||(nextObject.mediaType == MEDIA_GIF))
            {
                nextVideoIndex = i;
                break;
            }
        }

        [self.exporter exportAsynchronouslyWithCompletionHandler:^
         {
             switch ([self.exporter status])
             {
                 case AVAssetExportSessionStatusCompleted:
                 {
                     dispatch_async(dispatch_get_main_queue(), ^{
                         
                         self.currentProcessingIdx = nextVideoIndex;
                         
                         [self createGreenVideos];
                     });
                     
                     break;
                 }

                 default:
                 {
                     NSLog(@"video to greenVideo - failed: %@", [[self.exporter error] localizedDescription]);
                     
                     dispatch_async(dispatch_get_main_queue(), ^{
                         
                         [[SHKActivityIndicator currentIndicator] performSelectorOnMainThread:@selector(hide) withObject:nil waitUntilDone:NO];
                         
                         [self failedMakeGreenVideos];
                     });
                     
                     break;
                 }
             }
         }];
    }
}

- (void) makeBackgroundVideoForFirstPhoto
{
    self.pathToMovie = [NSTemporaryDirectory() stringByAppendingPathComponent:@"background.m4v"];
    
    UIImage *frameImage = nil;
    
    CGRect rect = CGRectMake(0, 0, videoSize.width, videoSize.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextFillRect(context, rect);
    frameImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSUInteger fps = 1;
    CGSize imageSize = frameImage.size;
    NSError *error = nil;
    
    unlink([self.pathToMovie UTF8String]);
    
    self.videoWriter = [[AVAssetWriter alloc] initWithURL:
                        [NSURL fileURLWithPath:self.pathToMovie] fileType:AVFileTypeQuickTimeMovie
                                                    error:&error];
    NSParameterAssert(self.videoWriter);
    
    NSDictionary *videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                   AVVideoCodecH264, AVVideoCodecKey,
                                   [NSNumber numberWithInt:imageSize.width], AVVideoWidthKey,
                                   [NSNumber numberWithInt:imageSize.height], AVVideoHeightKey,
                                   nil];
    
    AVAssetWriterInput* videoWriterInput = [AVAssetWriterInput
                                            assetWriterInputWithMediaType:AVMediaTypeVideo
                                            outputSettings:videoSettings];
    
    AVAssetWriterInputPixelBufferAdaptor *adaptor = [AVAssetWriterInputPixelBufferAdaptor
                                                     assetWriterInputPixelBufferAdaptorWithAssetWriterInput:videoWriterInput
                                                     sourcePixelBufferAttributes:nil];
    
    NSParameterAssert(videoWriterInput);
    NSParameterAssert([self.videoWriter canAddInput:videoWriterInput]);
    videoWriterInput.expectsMediaDataInRealTime = YES;
    [self.videoWriter addInput:videoWriterInput];
    [self.videoWriter startWriting];
    [self.videoWriter startSessionAtSourceTime:kCMTimeZero];
    
    CVPixelBufferRef buffer = [self pixelBufferFromCGImage:[frameImage CGImage] size:videoSize];
    
    int frameCount = 0;
    float duration = 1.0f;
    
    for (int i=0; i< (int)duration+1; i++)
    {
        BOOL append_ok = NO;
        int j = 0;
        
        while (!append_ok && j < 1)
        {
            if (adaptor.assetWriterInput.readyForMoreMediaData)
            {
                CMTime frameTime = CMTimeMake(frameCount*fps,(int32_t) fps);
                append_ok = [adaptor appendPixelBuffer:buffer withPresentationTime:frameTime];
                
                if(!append_ok)
                {
                    NSError *error = self.videoWriter.error;
                    
                    if(error!=nil)
                        NSLog(@"Unresolved error %@,%@.", error, [error userInfo]);
                }
            }
            else
            {
                [NSThread sleepForTimeInterval:0.1];
            }
            
            j++;
        }
        
        frameCount++;
    }
    
    CVPixelBufferRelease(buffer);
    frameImage = nil;
    
    [videoWriterInput markAsFinished];
    
    [self.videoWriter finishWritingWithCompletionHandler:^{
        
        if (self.videoWriter.status != AVAssetWriterStatusFailed && self.videoWriter.status == AVAssetWriterStatusCompleted)
        {
            self.videoWriter = nil;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self photoToVideo];
                
            });
        }
        else
        {
            NSLog(@"photos to video is failed!");
            self.videoWriter = nil;
        }
    }];
}

- (void) photoToVideo
{
    self.pathToMovie = [NSTemporaryDirectory() stringByAppendingPathComponent:@"background.m4v"];

    NSURL* bgVideo = [NSURL fileURLWithPath:self.pathToMovie];
    AVURLAsset* bgAsset = [AVURLAsset assetWithURL:bgVideo];
    
    MediaObjectView* mediaObject = [self.objectArray objectAtIndex:0];

    NSMutableArray *allAudioParams = [[NSMutableArray alloc] init];

    if(bgAsset != nil)
    {
        //VIDEO TRACK
        AVMutableCompositionTrack *videoTrack = [self.mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        NSArray *videoDataSourceArray = [NSArray arrayWithArray: [bgAsset tracksWithMediaType:AVMediaTypeVideo]];
        NSError *error = nil;
        [videoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, bgAsset.duration)
                            ofTrack:([videoDataSourceArray count]>0)?[videoDataSourceArray objectAtIndex:0]:nil
                             atTime:CMTimeMake(mediaObject.mfStartPosition*bgAsset.duration.timescale, bgAsset.duration.timescale)
                              error:&error];
        
        if(error)
            NSLog(@"Insertion error: %@", error);
        
        
        for (int i=0; i<self.musicObjectArray.count; i++)
        {
            MediaObjectView* audioObject = [self.musicObjectArray objectAtIndex:i];
            
            AVURLAsset* inputAudioAsset = [AVURLAsset assetWithURL:audioObject.mediaUrl];
            
            if(inputAudioAsset != nil)
            {
                //AUDIO TRACK
                NSArray *audioDataSourceArray = [NSArray arrayWithArray: [inputAudioAsset tracksWithMediaType:AVMediaTypeAudio]];
                if ([audioDataSourceArray count] > 0)
                {
                    AVMutableCompositionTrack *audioTrack = [self.mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
                    
                    CMTime startTimeOnComposition = CMTimeMake(audioObject.mfStartPosition * inputAudioAsset.duration.timescale, inputAudioAsset.duration.timescale);
                    
                    for (int i=0; i<audioObject.motionArray.count; i++)
                    {
                        NSError *error = nil;
                        
                        NSNumber* motionNum = [audioObject.motionArray objectAtIndex:i];
                        NSNumber* startPosNum = [audioObject.startPositionArray objectAtIndex:i];
                        NSNumber* endPosNum = [audioObject.endPositionArray objectAtIndex:i];
                        
                        CGFloat motionValue = [motionNum floatValue];
                        CGFloat startPosition = [startPosNum floatValue];
                        CGFloat endPosition = [endPosNum floatValue];
                        
                        CMTime duration = CMTimeMakeWithSeconds((endPosition - startPosition), inputAudioAsset.duration.timescale);
                        
                        [audioTrack insertTimeRange:CMTimeRangeMake(CMTimeMake(startPosition*inputAudioAsset.duration.timescale, inputAudioAsset.duration.timescale), duration)
                                            ofTrack:[audioDataSourceArray objectAtIndex:0]
                                             atTime:startTimeOnComposition
                                              error:&error];
                        if(error)
                            NSLog(@"Insertion error: %@", error);
                        
                        /************************** slow/fast motion *******************************/
                        if (motionValue != 1.0f)
                            [audioTrack scaleTimeRange:CMTimeRangeMake(startTimeOnComposition, duration)
                                            toDuration:CMTimeMake(duration.value/motionValue, inputAudioAsset.duration.timescale)];
                        
                        startTimeOnComposition = CMTimeAdd(startTimeOnComposition, CMTimeMakeWithSeconds((endPosition - startPosition)/motionValue, inputAudioAsset.duration.timescale));
                    }
                    
                    //volume
                    CGFloat volume = [audioObject getVolume];
                    
                    AVMutableAudioMixInputParameters *params;
                    params =[AVMutableAudioMixInputParameters audioMixInputParameters];
                    
                    if ((audioObject.startActionType == ACTION_NONE)&&(audioObject.endActionType == ACTION_NONE)) //[none, none]
                    {
                        [params setVolume:volume atTime:kCMTimeZero];
                    }
                    else if ((audioObject.startActionType != ACTION_NONE)&&(audioObject.endActionType != ACTION_NONE))    //[fade, fade]
                    {
                        [params setVolumeRampFromStartVolume:0.0
                                                 toEndVolume:volume
                                                   timeRange:CMTimeRangeMake(CMTimeMake(audioObject.mfStartPosition*inputAudioAsset.duration.timescale, inputAudioAsset.duration.timescale), CMTimeMake(audioObject.mfStartAnimationDuration*inputAudioAsset.duration.timescale, inputAudioAsset.duration.timescale))];
                        [params setVolumeRampFromStartVolume:volume
                                                 toEndVolume:0.0
                                                   timeRange:CMTimeRangeMake(CMTimeMake((audioObject.mfEndPosition - audioObject.mfEndAnimationDuration)*inputAudioAsset.duration.timescale, inputAudioAsset.duration.timescale), CMTimeMake(audioObject.mfEndAnimationDuration*inputAudioAsset.duration.timescale, inputAudioAsset.duration.timescale))];
                    }
                    else if ((audioObject.startActionType == ACTION_NONE)&&(audioObject.endActionType != ACTION_NONE))    //[none, fade]
                    {
                        [params setVolumeRampFromStartVolume:volume
                                                 toEndVolume:volume
                                                   timeRange:CMTimeRangeMake(CMTimeMake(audioObject.mfStartPosition*inputAudioAsset.duration.timescale, inputAudioAsset.duration.timescale), CMTimeMake(audioObject.mfStartAnimationDuration*inputAudioAsset.duration.timescale, inputAudioAsset.duration.timescale))];
                        [params setVolumeRampFromStartVolume:volume
                                                 toEndVolume:0.0
                                                   timeRange:CMTimeRangeMake(CMTimeMake((audioObject.mfEndPosition - audioObject.mfEndAnimationDuration)*inputAudioAsset.duration.timescale, inputAudioAsset.duration.timescale), CMTimeMake(audioObject.mfEndAnimationDuration*inputAudioAsset.duration.timescale, inputAudioAsset.duration.timescale))];
                        
                    }
                    else if ((audioObject.startActionType != ACTION_NONE)&&(audioObject.endActionType == ACTION_NONE))    //[fade, none]
                    {
                        [params setVolumeRampFromStartVolume:0.0
                                                 toEndVolume:volume
                                                   timeRange:CMTimeRangeMake(CMTimeMake(audioObject.mfStartPosition*inputAudioAsset.duration.timescale, inputAudioAsset.duration.timescale), CMTimeMake(audioObject.mfStartAnimationDuration*inputAudioAsset.duration.timescale, inputAudioAsset.duration.timescale))];
                        [params setVolumeRampFromStartVolume:volume
                                                 toEndVolume:volume
                                                   timeRange:CMTimeRangeMake(CMTimeMake((audioObject.mfEndPosition - audioObject.mfEndAnimationDuration)*inputAudioAsset.duration.timescale, inputAudioAsset.duration.timescale), CMTimeMake(audioObject.mfEndAnimationDuration*inputAudioAsset.duration.timescale, inputAudioAsset.duration.timescale))];
                    }
                    
                    [params setTrackID:[audioTrack trackID]];
                    [allAudioParams addObject:params];
                }
            }
            
            inputAudioAsset = nil;
        }

        
        //fix orientation, transform//
        AVMutableVideoCompositionLayerInstruction *layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
        
        AVAssetTrack *assetTrack = [[bgAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
        
        CGAffineTransform transfrom = CGAffineTransformIdentity;
        [layerInstruction setTransform:CGAffineTransformConcat(assetTrack.preferredTransform, transfrom) atTime:kCMTimeZero];
        [layerInstruction setOpacity:0.0 atTime:kCMTimeZero];
        
        [self.layerInstructionArray addObject:layerInstruction];
    }
    
    AVMutableAudioMix * audioMix = [AVMutableAudioMix audioMix];
    [audioMix setInputParameters:allAudioParams];
    
    AVMutableVideoCompositionInstruction * MainInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    MainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMake(grNormalFilterOutputTotalTime*bgAsset.duration.timescale, bgAsset.duration.timescale));
    MainInstruction.backgroundColor = [UIColor blackColor].CGColor;
    MainInstruction.layerInstructions = self.layerInstructionArray;
    
    AVMutableVideoComposition *MainCompositionInst = [AVMutableVideoComposition videoComposition];
    MainCompositionInst.instructions = [NSArray arrayWithObject:MainInstruction];
    MainCompositionInst.frameDuration = CMTimeMake(1, grFrameRate);
    MainCompositionInst.renderSize = videoSize;
    
    //detect first video index
    int nextVideoIndex = (int)self.objectArray.count;
    
    for (int i=1; i<self.objectArray.count; i++)
    {
        MediaObjectView* object = [self.objectArray objectAtIndex:i];
        
        if ((object.mediaType == MEDIA_VIDEO)||(object.mediaType == MEDIA_GIF))
        {
            nextVideoIndex = i;
            break;
        }
    }
    
    // photo animations - 2014/02/03 by Yinjing Li
    MainCompositionInst.animationTool = [self setPhotoAnimation:self.currentProcessingIdx index:nextVideoIndex];
    
    
    self.pathToMovie = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"greenVideo%d.m4v", self.currentProcessingIdx]];
    unlink([self.pathToMovie UTF8String]); // If a file already exists, AVAssetWriter won't let you record new frames, so delete the old movie
    NSURL *url = [NSURL fileURLWithPath:self.pathToMovie];
    
    if (self.exporter != nil)
        self.exporter = nil;
    
    self.exporter = [[AVAssetExportSession alloc] initWithAsset:self.mixComposition presetName:AVAssetExportPresetHighestQuality];
    self.exporter.outputURL = url;
    self.exporter.outputFileType = AVFileTypeQuickTimeMovie;
    self.exporter.videoComposition = MainCompositionInst;

    if (allAudioParams.count > 0)
        [self.exporter setAudioMix:audioMix];//for volume

    if (isPreview && (grNormalFilterOutputTotalTime > grPreviewDuration))
        self.exporter.timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMake(grPreviewDuration*bgAsset.duration.timescale, bgAsset.duration.timescale));
    else
        self.exporter.timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMake(grNormalFilterOutputTotalTime*bgAsset.duration.timescale, bgAsset.duration.timescale));
    
    self.exporter.shouldOptimizeForNetworkUse = YES;
    
    //normal processing progress bar
    mnProcessingIndex++;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if ([self.delegate respondsToSelector:@selector(startAllNormalProgress:current:total:)])
            [self.delegate startAllNormalProgress:self.exporter current:mnProcessingIndex total:mnProcessingCount];
        
    });

    [self.exporter exportAsynchronouslyWithCompletionHandler:^
     {
         switch ([self.exporter status])
         {
             case AVAssetExportSessionStatusCompleted:
             {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     
                     NSString* prevPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"background.m4v"];
                     unlink([prevPath UTF8String]);

                     self.currentProcessingIdx = nextVideoIndex;
                     
                     [self createGreenVideos];
                 });
                 
                 break;
             }
                 
             default:
             {
                 NSLog(@"video to greenVideo - failed: %@", [[self.exporter error] localizedDescription]);
                 
                 dispatch_async(dispatch_get_main_queue(), ^{
                     
                     NSString* prevPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"background.m4v"];
                     unlink([prevPath UTF8String]);

                     [[SHKActivityIndicator currentIndicator] performSelectorOnMainThread:@selector(hide) withObject:nil waitUntilDone:NO];
                     
                     [self failedMakeGreenVideos];
                 });
                 
                 break;
             }
         }
     }];
}

-(void)failedMakeGreenVideos
{
    NSLog(@"Failed make green videos");
}

- (void)retrievingProgressing
{
    if (self.thMovieWriter)
    {
        CGFloat duration = CMTimeGetSeconds(self.thMovieWriter.duration);
        CGFloat progress = 0.0f;
        
        if (isPreview && (grNormalFilterOutputTotalTime > grPreviewDuration))
            progress = duration / grPreviewDuration;
        else
            progress = duration / grNormalFilterOutputTotalTime;
        
        if ([self.delegate respondsToSelector:@selector(updateChromakeyVideoExporting:)])
            [self.delegate updateChromakeyVideoExporting:progress];
    }
}


#pragma mark -
#pragma mark -
#pragma mark - GPUImageFilter Processing


-(void)overlayPhotosToGreenVideo:(NSInteger) greenVideoIndex url:(NSURL*) baseVideoUrl
{
    if (self.mixComposition != nil)
        self.mixComposition = nil;
    self.mixComposition = [[AVMutableComposition alloc] init];
    
    if(self.layerInstructionArray != nil)
    {
        [self.layerInstructionArray removeAllObjects];
        self.layerInstructionArray = nil;
    }
    
    self.layerInstructionArray = [[NSMutableArray alloc] init];

    
    AVURLAsset* inputAsset = [AVURLAsset assetWithURL:baseVideoUrl];
    
    if(inputAsset != nil)
    {
        CMTime duration = inputAsset.duration;
        
        AVMutableCompositionTrack *videoTrack = [self.mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
       
        NSArray *videoDataSourceArray = [NSArray arrayWithArray:[inputAsset tracksWithMediaType:AVMediaTypeVideo]];
        NSError *error = nil;
        
        [videoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, duration)
                            ofTrack:([videoDataSourceArray count]>0)?[videoDataSourceArray objectAtIndex:0]:nil
                             atTime:kCMTimeZero
                              error:&error];
        if(error)
            NSLog(@"Insertion error: %@", error);
        
        
        //AUDIO TRACK
        NSArray *audioDataSourceArray = [NSArray arrayWithArray: [inputAsset tracksWithMediaType:AVMediaTypeAudio]];
        if ([audioDataSourceArray count] > 0)
        {
            AVMutableCompositionTrack *audioTrack = [self.mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
            
            NSArray *audioDataSourceArray = [NSArray arrayWithArray:[inputAsset tracksWithMediaType:AVMediaTypeAudio]];
            NSError *error = nil;
            
            [audioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, duration)
                                ofTrack:([audioDataSourceArray count]>0)?[audioDataSourceArray objectAtIndex:0]:nil
                                 atTime:kCMTimeZero
                                  error:&error];
            if(error)
                NSLog(@"Insertion error: %@", error);
        }
        
        //fix orientation, transform//
        AVMutableVideoCompositionLayerInstruction *layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
        
        AVAssetTrack *assetTrack = [[inputAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
        
        [layerInstruction setTransform:CGAffineTransformConcat(assetTrack.preferredTransform, CGAffineTransformIdentity) atTime:kCMTimeZero];
        [layerInstruction setOpacity:1.0f atTime:kCMTimeZero];
        
        [self.layerInstructionArray addObject:layerInstruction];
        
        AVMutableVideoCompositionInstruction * MainInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
        CGFloat scale = inputAsset.duration.timescale;
        MainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMake(grNormalFilterOutputTotalTime*scale, scale));
        MainInstruction.layerInstructions = self.layerInstructionArray;
        
        AVMutableVideoComposition *MainCompositionInst = [AVMutableVideoComposition videoComposition];
        MainCompositionInst.instructions = [NSArray arrayWithObject:MainInstruction];
        MainCompositionInst.frameDuration = CMTimeMake(1, grFrameRate);
        MainCompositionInst.renderSize = videoSize;
        
        
        int nextVideoObjectIndex = (int)self.objectArray.count;
        
        for (int i=(int)greenVideoIndex+1; i<self.objectArray.count; i++)
        {
            MediaObjectView* object = [self.objectArray objectAtIndex:i];
            
            if ((object.mediaType == MEDIA_VIDEO)||(object.mediaType == MEDIA_GIF))
            {
                nextVideoObjectIndex = i;
                break;
            }
        }
        
        MainCompositionInst.animationTool = [self setPhotoAnimation:(int)greenVideoIndex+1 index:nextVideoObjectIndex];

        
        if (nextVideoObjectIndex == self.objectArray.count)
            self.currentProcessingIdx = (int)self.objectArray.count-1;
        else
            self.currentProcessingIdx = nextVideoObjectIndex-1;
        
        
        NSURL *movieURL = nil;

        if (isPreview)   //preview
        {
            if (self.currentProcessingIdx == (self.objectArray.count-1))
            {
                self.pathToMovie = [NSTemporaryDirectory() stringByAppendingPathComponent:@"VideoDreamer-Preview.m4v"];
                unlink([self.pathToMovie UTF8String]);
                movieURL = [NSURL fileURLWithPath:self.pathToMovie];
            }
            else
            {
                self.pathToMovie = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"VideoDreamer-Preview-Temp%d.m4v", self.currentProcessingIdx]];
                unlink([self.pathToMovie UTF8String]);
                movieURL = [NSURL fileURLWithPath:self.pathToMovie];
            }
        }
        else  //apply output
        {
            if (self.currentProcessingIdx == (self.objectArray.count-1))
            {
                self.pathToMovie = [NSTemporaryDirectory() stringByAppendingPathComponent:@"VideoDreamer.m4v"];
                unlink([self.pathToMovie UTF8String]);
                movieURL = [NSURL fileURLWithPath:self.pathToMovie];
            }
            else
            {
                self.pathToMovie = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"VideoDreamer-Temp%d.m4v", self.currentProcessingIdx]];
                unlink([self.pathToMovie UTF8String]);
                movieURL = [NSURL fileURLWithPath:self.pathToMovie];
            }
        }
        
        if (self.exporter != nil)
            self.exporter = nil;
        
        self.exporter = [[AVAssetExportSession alloc] initWithAsset:self.mixComposition presetName:AVAssetExportPresetHighestQuality];
        self.exporter.outputURL = movieURL;
        self.exporter.outputFileType = AVFileTypeQuickTimeMovie;
        self.exporter.videoComposition = MainCompositionInst;
        
        if (isPreview && (grNormalFilterOutputTotalTime > grPreviewDuration))
            self.exporter.timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMake(grPreviewDuration*scale, scale));
        else
            self.exporter.timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMake(grNormalFilterOutputTotalTime*scale, scale));
        
        self.exporter.shouldOptimizeForNetworkUse = YES;
        
        mnProcessingIndex++;
        
        [timer invalidate];
        timer = nil;

        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self.delegate respondsToSelector:@selector(startAllNormalProgress:current:total:)])
                [self.delegate startAllNormalProgress:self.exporter current:mnProcessingIndex total:mnProcessingCount];
        });
        
        
        [self.exporter exportAsynchronouslyWithCompletionHandler:^
         {
             switch ([self.exporter status])
             {
                 case AVAssetExportSessionStatusCompleted:
                 {
                     dispatch_async(dispatch_get_main_queue(), ^{
                         
                         if (self.currentProcessingIdx == (self.objectArray.count-1))
                         {
                             [timer invalidate];
                             timer = nil;
                             
                             unlink([baseVideoUrl.path UTF8String]);
                             
                             [self removeAllObjects];

                             if (isPreview)
                             {
                                 [[SHKActivityIndicator currentIndicator] performSelectorOnMainThread:@selector(hide) withObject:nil waitUntilDone:NO];
                                 
                                 //make output video from temp videos
                                 if ([self.delegate respondsToSelector:@selector(didCompletedPreview)])
                                 {
                                     [self.delegate didCompletedPreview];
                                 }
                             }
                             else
                             {
                                 NSLog(@"Video Save to Photo Album...");
                                 
                                 [self saveMovieToPhotoAlbum];
                                 
                                 if ([self.delegate respondsToSelector:@selector(saveToAlbumProgress)])
                                 {
                                     [self.delegate saveToAlbumProgress];
                                 }
                             }
                         }
                         else
                         {
                             unlink([baseVideoUrl.path UTF8String]);

                             [self makeNextOutputVideo];
                         }

                     });
                     
                     break;
                 }
                     
                 default:
                 {
                     NSLog(@"video to greenVideo - failed: %@", [[self.exporter error] localizedDescription]);
                     
                     dispatch_async(dispatch_get_main_queue(), ^{
                         
                         unlink([baseVideoUrl.path UTF8String]);

                         [[SHKActivityIndicator currentIndicator] performSelectorOnMainThread:@selector(hide) withObject:nil waitUntilDone:NO];
                         
                         [self failedMakeGreenVideos];
                     });
                     
                     break;
                 }
             }
         }];
    }
}

-(void)applyChromakeyToGreenVideos
{
    isFailed = NO;
    self.currentProcessingIdx = 0;
    
    self.filter = nil;
    self.thMovieA = nil;
    self.thMovieFX = nil;
    
    NSString* firstGreenVideoPath = nil;
    NSString* secondGreenVideoPath = nil;
    
    NSArray *thMovies = nil;
    
    if (mnProcessingCount > 2)
    {
        int firstVideoIndex = 0;
        int secondVideoIndex = 1;

        MediaObjectView* firstObject = [self.objectArray objectAtIndex:firstVideoIndex];
        
        if ((firstObject.mediaType == MEDIA_VIDEO)||(firstObject.mediaType == MEDIA_GIF))
        {
            MediaObjectView* secondObject = [self.objectArray objectAtIndex:secondVideoIndex];

            if ((secondObject.mediaType == MEDIA_PHOTO) || (secondObject.mediaType == MEDIA_TEXT))
            {
                //new processing for overlay
                firstGreenVideoPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"greenVideo%d.m4v", firstVideoIndex]];
                NSURL* baseVideoUrl = [NSURL fileURLWithPath:firstGreenVideoPath];

                [self overlayPhotosToGreenVideo:firstVideoIndex url:baseVideoUrl];
                
                return;
            }
        }
        else if ((firstObject.mediaType == MEDIA_PHOTO)||(firstObject.mediaType == MEDIA_TEXT))
        {
            for (int i=1; i<self.objectArray.count; i++)
            {
                MediaObjectView* secondObject = [self.objectArray objectAtIndex:i];
                
                if ((secondObject.mediaType == MEDIA_VIDEO)||(secondObject.mediaType == MEDIA_GIF))
                {
                    secondVideoIndex = i;
                    
                    break;
                }
            }
        }
        
        firstGreenVideoPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"greenVideo%d.m4v", firstVideoIndex]];
        self.asset1 = [self prepareInputVideo:[NSURL fileURLWithPath:firstGreenVideoPath]];
        self.thMovieA = [[THImageMovie alloc] initWithAsset:self.asset1];
        
        secondGreenVideoPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"greenVideo%d.m4v", secondVideoIndex]];
        self.asset2 = [self prepareInputVideo:[NSURL fileURLWithPath:secondGreenVideoPath]];
        self.thMovieFX = [[THImageMovie alloc] initWithAsset:self.asset2];
        
        [self initFilter:secondVideoIndex];
        
        [self.thMovieFX addTarget:self.filter];
        [self.thMovieA addTarget:self.filter];
        
        self.currentProcessingIdx = secondVideoIndex;
        
        thMovies = @[self.thMovieA, self.thMovieFX];
    }
    else
    {
        int firstVideoIndex = 0;
        
        firstGreenVideoPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"greenVideo%d.m4v", firstVideoIndex]];
        self.asset1 = [self prepareInputVideo:[NSURL fileURLWithPath:firstGreenVideoPath]];
        self.thMovieA = [[THImageMovie alloc] initWithAsset:self.asset1];
        
        self.thMovieFX = nil;
        
        self.filter = [[GPUImageFilter alloc] init];
        [self.thMovieA addTarget:self.filter];
        
        self.currentProcessingIdx = firstVideoIndex;
        
        thMovies = @[self.thMovieA];
    }
    
    if (isPreview)   //preview
    {
        NSURL *movieURL = nil;
        
        if (self.currentProcessingIdx == (self.objectArray.count-1))
        {
            self.pathToMovie = [NSTemporaryDirectory() stringByAppendingPathComponent:@"VideoDreamer-Preview.m4v"];
            unlink([self.pathToMovie UTF8String]);
            movieURL = [NSURL fileURLWithPath:self.pathToMovie];
        }
        else
        {
            self.pathToMovie = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"VideoDreamer-Preview-Temp%d.m4v", self.currentProcessingIdx]];
            unlink([self.pathToMovie UTF8String]);
            movieURL = [NSURL fileURLWithPath:self.pathToMovie];
        }
        
        self.thMovieWriter =  [[THImageMovieWriter alloc] initWithMovieURL:movieURL size:videoSize movies:thMovies];
        [self.filter addTarget:self.thMovieWriter];
        
        [self.thMovieA startProcessing];
        if (self.thMovieFX != nil)
            [self.thMovieFX startProcessing];
        [self.thMovieWriter startRecording];

        [self movieRecordingStarted];

        
        __weak typeof(self) weakSelf = self;
        
        [self.thMovieWriter setCompletionBlock:^{
            
            [weakSelf didFinishedPreviewVideoWrite];
            
            //remove a temp videos
            unlink([firstGreenVideoPath UTF8String]);
            
            if(secondGreenVideoPath)
                unlink([secondGreenVideoPath UTF8String]);

        }];

        [self.thMovieWriter setFailureBlock:^ (NSError* error) {
            
            [weakSelf didFailedPreviewVideoWrite];
            
            //remove a temp videos
            unlink([firstGreenVideoPath UTF8String]);
            
            if(secondGreenVideoPath)
                unlink([secondGreenVideoPath UTF8String]);
            
        }];
    }
    else  //apply output
    {
        NSURL *movieURL = nil;
        
        if (self.currentProcessingIdx == (self.objectArray.count-1))
        {
            self.pathToMovie = [NSTemporaryDirectory() stringByAppendingPathComponent:@"VideoDreamer.m4v"];
            unlink([self.pathToMovie UTF8String]);
            movieURL = [NSURL fileURLWithPath:self.pathToMovie];
        }
        else
        {
            self.pathToMovie = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"VideoDreamer-Temp%d.m4v", self.currentProcessingIdx]];
            unlink([self.pathToMovie UTF8String]);
            movieURL = [NSURL fileURLWithPath:self.pathToMovie];
        }
        
        self.thMovieWriter =  [[THImageMovieWriter alloc] initWithMovieURL:movieURL size:videoSize movies:thMovies];
        [self.filter addTarget:self.thMovieWriter];
        
        [self.thMovieA startProcessing];
        if (self.thMovieFX != nil)
            [self.thMovieFX startProcessing];
        [self.thMovieWriter startRecording];

        
        [self movieRecordingStarted];

        
        __weak typeof(self) weakSelf = self;
        
        [self.thMovieWriter setCompletionBlock:^{
            
            [weakSelf didFinishedOutputVideoWrite];
            
            //remove a temp videos
            unlink([firstGreenVideoPath UTF8String]);
            
            if(secondGreenVideoPath)
                unlink([secondGreenVideoPath UTF8String]);
        }];
        
        [self.thMovieWriter setFailureBlock:^ (NSError* error) {
            
            [weakSelf didFailedOutputVideoWrite];

            //remove a temp videos
            unlink([firstGreenVideoPath UTF8String]);
            
            if(secondGreenVideoPath)
                unlink([secondGreenVideoPath UTF8String]);
        }];
    }
}


-(void) initFilter:(NSInteger) objectIndex
{
    MediaObjectView* object = [self.objectArray objectAtIndex:objectIndex];

    const CGFloat* components = CGColorGetComponents(object.objectChromaColor.CGColor);
    
    self.filter = [[GPUImageChromaKeyBlendFilter alloc] init];
    [self.filter forceProcessingAtSize:CGSizeMake(videoSize.width, videoSize.height)];  //by yinjing at 20150528
    [(GPUImageChromaKeyBlendFilter *)self.filter setColorToReplaceRed:components[0] green:components[1] blue:components[2]];
}


/*
 * if isPreview is YES, 5 sec.
 * if isPreview is NO, full time.
 */
- (AVAsset*) prepareInputVideo:(NSURL *)videoUrl
{
    AVURLAsset* inputPrepareVideoAsset = [AVURLAsset assetWithURL:videoUrl];
    AVMutableComposition* mixComposition = [AVMutableComposition composition];
    
    if(inputPrepareVideoAsset != nil)
    {
        CMTime duration = inputPrepareVideoAsset.duration;
        float input_duration = (float)inputPrepareVideoAsset.duration.value / (float)inputPrepareVideoAsset.duration.timescale;
        
        if (isPreview && (input_duration > grPreviewDuration))
            duration = CMTimeMake(inputPrepareVideoAsset.duration.timescale * grPreviewDuration, inputPrepareVideoAsset.duration.timescale);
        
        //VIDEO TRACK
        AVMutableCompositionTrack *firstTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        NSArray *videoDataSourceArray = [NSArray arrayWithArray: [inputPrepareVideoAsset tracksWithMediaType:AVMediaTypeVideo]];
        [firstTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, duration)
                            ofTrack:([videoDataSourceArray count]>0)?[videoDataSourceArray objectAtIndex:0]:nil
                             atTime:kCMTimeZero
                              error:nil];
        
        //AUDIO TRACK
        NSArray *dataSourceArray = [NSArray arrayWithArray: [inputPrepareVideoAsset tracksWithMediaType:AVMediaTypeAudio]];
        if ([dataSourceArray count] > 0)
        {
            AVMutableCompositionTrack *firstAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
            [firstAudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, duration)
                                     ofTrack:[dataSourceArray objectAtIndex:0]
                                      atTime:kCMTimeZero
                                       error:nil];
        }
    }
    
    return mixComposition;
}

- (void) makeNextOutputVideo
{
    isFailed = NO;
    self.filter = nil;
    
    NSArray *thMovies = nil;
    NSString* secondGreenVideoPath = nil;
    NSURL* prevMovieURL = nil;

    if (self.currentProcessingIdx < (self.objectArray.count-1))
    {
        int secondVideoIndex = self.currentProcessingIdx+1;
        
        MediaObjectView* secondObject = [self.objectArray objectAtIndex:secondVideoIndex];
        
        if ((secondObject.mediaType == MEDIA_PHOTO) || (secondObject.mediaType == MEDIA_TEXT))
        {
            //new processing for overlay
            NSURL* baseVideoUrl = [NSURL fileURLWithPath:self.pathToMovie];
            
            [self overlayPhotosToGreenVideo:self.currentProcessingIdx url:baseVideoUrl];
            
            return;
        }
        
        prevMovieURL = [NSURL fileURLWithPath:self.pathToMovie];
        self.asset1 = [self prepareInputVideo:prevMovieURL];
        self.thMovieA = [[THImageMovie alloc] initWithAsset:self.asset1];
        
        secondGreenVideoPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"greenVideo%d.m4v", secondVideoIndex]];
        self.asset2 = [self prepareInputVideo:[NSURL fileURLWithPath:secondGreenVideoPath]];
        self.thMovieFX = [[THImageMovie alloc] initWithAsset:self.asset2];
        
        [self initFilter:secondVideoIndex];

        [self.thMovieFX addTarget:self.filter];
        [self.thMovieA addTarget:self.filter];
        
        self.currentProcessingIdx = secondVideoIndex;
        
        thMovies = @[self.thMovieA, self.thMovieFX];
    }
    
    if (isPreview)   //preview
    {
        NSURL *movieURL = nil;
        
        if (self.currentProcessingIdx == (self.objectArray.count-1))
        {
            self.pathToMovie = [NSTemporaryDirectory() stringByAppendingPathComponent:@"VideoDreamer-Preview.m4v"];
            unlink([self.pathToMovie UTF8String]);
            movieURL = [NSURL fileURLWithPath:self.pathToMovie];
        }
        else
        {
            self.pathToMovie = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"VideoDreamer-Preview-Temp%d.m4v", self.currentProcessingIdx]];
            unlink([self.pathToMovie UTF8String]);
            movieURL = [NSURL fileURLWithPath:self.pathToMovie];
        }
        
        self.thMovieWriter =  [[THImageMovieWriter alloc] initWithMovieURL:movieURL size:videoSize movies:thMovies];
        [self.filter addTarget:self.thMovieWriter];
        
        [self.thMovieA startProcessing];
        if (self.thMovieFX != nil)
            [self.thMovieFX startProcessing];
        [self.thMovieWriter startRecording];


        [self movieRecordingStarted];

        
        __weak typeof(self) weakSelf = self;
        
        [self.thMovieWriter setCompletionBlock:^{
            
            [weakSelf didFinishedPreviewVideoWrite];
            
            unlink([secondGreenVideoPath UTF8String]);
            unlink([prevMovieURL.path UTF8String]);
        }];
        
        [self.thMovieWriter setFailureBlock:^ (NSError* error) {
            
            [weakSelf didFailedPreviewVideoWrite];
            
            unlink([secondGreenVideoPath UTF8String]);
            unlink([prevMovieURL.path UTF8String]);
        }];
    }
    else     //apply output
    {
        NSURL *movieURL = nil;
        
        if (self.currentProcessingIdx == (self.objectArray.count-1))
        {
            self.pathToMovie = [NSTemporaryDirectory() stringByAppendingPathComponent:@"VideoDreamer.m4v"];
            unlink([self.pathToMovie UTF8String]);
            movieURL = [NSURL fileURLWithPath:self.pathToMovie];
        }
        else
        {
            self.pathToMovie = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"VideoDreamer-Temp%d.m4v", self.currentProcessingIdx]];
            unlink([self.pathToMovie UTF8String]);
            movieURL = [NSURL fileURLWithPath:self.pathToMovie];
        }
        
        self.thMovieWriter =  [[THImageMovieWriter alloc] initWithMovieURL:movieURL size:videoSize movies:thMovies];
        [self.filter addTarget:self.thMovieWriter];
        
        [self.thMovieA startProcessing];
        if (self.thMovieFX != nil)
            [self.thMovieFX startProcessing];
        [self.thMovieWriter startRecording];
        
        
        [self movieRecordingStarted];

        
        __weak typeof(self) weakSelf = self;
        
        [self.thMovieWriter setCompletionBlock:^{
            
            [weakSelf didFinishedOutputVideoWrite];
            
            unlink([secondGreenVideoPath UTF8String]);
            unlink([prevMovieURL.path UTF8String]);
        }];
        
        [self.thMovieWriter setFailureBlock:^ (NSError* error) {
            
            [weakSelf didFailedOutputVideoWrite];
            
            unlink([secondGreenVideoPath UTF8String]);
            unlink([prevMovieURL.path UTF8String]);
        }];
    }
}

- (void) didFinishedOutputVideoWrite
{
    isFailed = NO;
    
    if (self.thMovieFX != nil)
        [self.thMovieFX endProcessing];
    
    if (self.thMovieA != nil)
        [self.thMovieA endProcessing];
    
    [timer invalidate];
    timer = nil;
    
    [self movieRecordingCompleted];
}

- (void) didFailedOutputVideoWrite
{
    isFailed = YES;
    
    if (self.thMovieFX != nil)
        [self.thMovieFX endProcessing];
    
    if (self.thMovieA != nil)
        [self.thMovieA endProcessing];
    
    [timer invalidate];
    timer = nil;
    
    [self movieRecordingCompleted];
}

- (void) didFinishedPreviewVideoWrite
{
    isFailed = NO;
    
    if (self.thMovieFX != nil)
        [self.thMovieFX endProcessing];
    
    if (self.thMovieA != nil)
        [self.thMovieA endProcessing];
    
    [timer invalidate];
    timer = nil;
    
    [self movieRecordingCompleted];
}

- (void) didFailedPreviewVideoWrite
{
    isFailed = YES;
    
    if (self.thMovieFX != nil)
        [self.thMovieFX endProcessing];
    
    if (self.thMovieA != nil)
        [self.thMovieA endProcessing];
    
    [timer invalidate];
    timer = nil;
    
    [self movieRecordingCompleted];
}


/*
 * description - GPUImageMovieWriter delegate function. save a new merged video on local disk after video merge completed.
 * date - 11/27/2013
 * author - Yinjing Li
 */
- (void)movieRecordingCompleted
{
    self.thMovieWriter = nil;
    self.thMovieFX = nil;
    self.thMovieA = nil;
    self.filter = nil;
    
    if (isPreview)
    {
        NSString* prevMovie = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"VideoDreamer-Preview-Temp%d.m4v", self.currentProcessingIdx-1]];
        unlink([prevMovie UTF8String]);
    }
    else
    {
        NSString* prevMovie = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"VideoDreamer-Temp%d.m4v", self.currentProcessingIdx-1]];
        unlink([prevMovie UTF8String]);
    }
    
    if (!isFailed)  //completed
    {
        if (self.currentProcessingIdx == (self.objectArray.count-1))
        {
            [timer invalidate];
            timer = nil;

            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self removeAllObjects];

                if (isPreview)
                {
                    [[SHKActivityIndicator currentIndicator] performSelectorOnMainThread:@selector(hide) withObject:nil waitUntilDone:NO];
                    
                    //make output video from temp videos
                    if ([self.delegate respondsToSelector:@selector(didCompletedPreview)])
                    {
                        [self.delegate didCompletedPreview];
                    }
                }
                else
                {
                    NSLog(@"Video Save to Photo Album...");
                    
                    [self saveMovieToPhotoAlbum];
                    
                    if ([self.delegate respondsToSelector:@selector(saveToAlbumProgress)])
                    {
                        [self.delegate saveToAlbumProgress];
                    }
                }
            });
        }
        else
        {
            [self makeNextOutputVideo];
        }
    }
    else    //failed
    {
        [timer invalidate];
        timer = nil;

        if (isPreview)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Preview video creating failed!"  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil, nil];
            [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Video creating failed!"  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil, nil];
            [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
        }
    }
}

- (void)movieRecordingStarted
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        mnProcessingIndex++;

        if ([self.delegate respondsToSelector:@selector(startAllChromakeyProgress:total:)])
            [self.delegate startAllChromakeyProgress:mnProcessingIndex total:mnProcessingCount];
        
        [timer invalidate];
        timer = nil;
        
        timer = [NSTimer scheduledTimerWithTimeInterval:0.02f
                                                 target:self
                                               selector:@selector(retrievingProgressing)
                                               userInfo:nil
                                                repeats:YES];
    });
}


#pragma mark -
#pragma mark - Create pixel buffer from CGImage

- (CVPixelBufferRef) pixelBufferFromCGImage: (CGImageRef) image size:(CGSize) renderSize
{
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey,
                             nil];
    CVPixelBufferRef pxbuffer = NULL;
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault,
                                          renderSize.width,
                                          renderSize.height,
                                          kCVPixelFormatType_32ARGB,
                                          (__bridge CFDictionaryRef) options,
                                          &pxbuffer);
    if (status != kCVReturnSuccess)
        NSLog(@"Failed to create pixel buffer");
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef context = CGBitmapContextCreate(pxdata, renderSize.width,
                                                 renderSize.height, 8, CVPixelBufferGetBytesPerRow(pxbuffer), rgbColorSpace,
                                                 (CGBitmapInfo)kCGImageAlphaPremultipliedFirst);
    CGContextConcatCTM(context, CGAffineTransformMakeRotation(0));
    
    CGContextDrawImage(context, CGRectMake(0, 0, renderSize.width, renderSize.height), image);
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    
    return pxbuffer;
}

@end
