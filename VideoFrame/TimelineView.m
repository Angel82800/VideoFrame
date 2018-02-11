//
//  TimelineView.m
//  VideoFrame
//
//  Created by Yinjing Li on 1/13/14.
//  Copyright (c) 2014 Yinjing Li. All rights reserved.
//

#import "TimelineView.h"

@implementation TimelineView

@synthesize timelineDelegate = _timelineDelegate;


#pragma mark
#pragma mark -

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        {
            labelFontSize = 11.0f;
            sliderWidthMin = IPHONE_TIMELINE_WIDTH_MIN;
        }
        else
        {
            labelFontSize = 14.0f;
            sliderWidthMin = IPAD_TIMELINE_WIDTH_MIN;
        }

        if (self.sliderArray != nil)
        {
            [self.sliderArray removeAllObjects];
            self.sliderArray = nil;
        }
        
        self.sliderArray = [[NSMutableArray alloc] init];
        
        self.previewPlayerItem = nil;
        self.previewPlayer = nil;
        self.previewPlayerLayer = nil;

        self.totalTime = 0.0f;
        self.oldY = 0.0f;
        bottomY = frame.origin.y + frame.size.height;
        
        self.layer.borderColor = [UIColor blackColor].CGColor;
        self.layer.borderWidth = 1.0f;
        [self setBackgroundColor:[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.5f]];
        [self setIndicatorStyle:UIScrollViewIndicatorStyleWhite];
        [self flashScrollIndicators];
        [self setScrollEnabled:NO];
        
        [self setFrame:CGRectMake(frame.origin.x, bottomY - grSliderHeightMax, frame.size.width, grSliderHeightMax)];
        
        [self setContentSize:self.bounds.size];
        
        grMaxContentHeight = self.bounds.size.height;
    }
    
    return self;
}


- (void) deleteAllSliders
{
    if (self.sliderArray.count>0)
    {
        for (int i=0; i<self.sliderArray.count; i++)
        {
            YJLVideoRangeSlider* slider = [self.sliderArray objectAtIndex:i];
            [slider removeFromSuperview];
        }
    }
    
    [self.sliderArray removeAllObjects];
    self.sliderArray = nil;
}


-(CGFloat) getObjectTotalDuration:(MediaObjectView*) mediaObj
{
    CGFloat totalDuration = 0.0f;
    
    for (int i=0; i<mediaObj.motionArray.count; i++)
    {
        NSNumber* motionValueNum = [mediaObj.motionArray objectAtIndex:i];
        NSNumber* startPosNum = [mediaObj.startPositionArray objectAtIndex:i];
        NSNumber* endPosNum = [mediaObj.endPositionArray objectAtIndex:i];
        
        CGFloat motionValue = [motionValueNum floatValue];
        CGFloat startPosition = [startPosNum floatValue];
        CGFloat endPosition = [endPosNum floatValue];
        
        totalDuration += (endPosition - startPosition)/motionValue;
    }
    
    return totalDuration;
}


#pragma mark -
#pragma mark - add new timeline from a new media object

- (void) addNewTimeLine:(MediaObjectView*) mediaObj
{
    if (self.sliderArray == nil)
        self.sliderArray = [[NSMutableArray alloc] init];
    
    if (mediaObj.mediaType == MEDIA_VIDEO)
    {
        AVAsset *myAsset = [AVURLAsset URLAssetWithURL:mediaObj.mediaUrl options:nil];
        CGFloat duration = CMTimeGetSeconds([myAsset duration]);

        if (self.sliderArray.count == 0)// this is first slider.
        {
            YJLVideoRangeSlider* newSlider = [[YJLVideoRangeSlider alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.bounds.size.width, grSliderHeightMax) videoUrl:mediaObj.mediaUrl];
            newSlider.delegate = self;
            newSlider.objectIndex = 0;
            [self addSubview:newSlider];

            [self.sliderArray addObject:newSlider];
            
            self.totalTime = [self getObjectTotalDuration:mediaObj];
            self.scaleFactor = self.frame.size.width/20.0f;
            
            [newSlider changeSliderFrame:self.scaleFactor*grZoomScale];
            [newSlider drawRuler];
        }
        else//already a sliders exist on timelines.
        {
            CGFloat time = duration;
            CGRect frame = CGRectZero;
            BOOL isMusicOnly = YES;

            for (int i=0; i<self.sliderArray.count; i++)
            {
                YJLVideoRangeSlider* prevSlider = [self.sliderArray objectAtIndex:i];
                
                if (prevSlider.media_type != MEDIA_MUSIC)
                {
                    isMusicOnly = NO;
                    break;
                }
            }
            
            if (isMusicOnly)
            {
                if (time <= self.totalTime)
                {
                    if (self.scaleFactor*time < sliderWidthMin)
                    {
                        self.scaleFactor = sliderWidthMin/time;
                        
                        for (int i=0; i<self.sliderArray.count; i++)
                        {
                            YJLVideoRangeSlider* slider = [self.sliderArray objectAtIndex:i];
                            [slider changeSliderFrame:self.scaleFactor*grZoomScale];
                        }
                    }
                    
                    frame = CGRectMake(0.0f, 0.0f, self.scaleFactor*time, grSliderHeightMax);
                }
                else
                {
                    self.totalTime = time;
                    self.scaleFactor = self.frame.size.width / self.totalTime;
                    
                    CGFloat minDuration = self.totalTime;
                
                    for (int i=0; i<self.sliderArray.count; i++)
                    {
                        YJLVideoRangeSlider* slider = [self.sliderArray objectAtIndex:i];
                        
                        CGFloat duration = slider.durationSeconds;
                    
                        if (duration < minDuration)
                            minDuration = duration;
                    }
                    
                    if (self.scaleFactor*minDuration < sliderWidthMin)
                        self.scaleFactor = sliderWidthMin/minDuration;
                    
                    for (int i=0; i<self.sliderArray.count; i++)
                    {
                        YJLVideoRangeSlider* slider = [self.sliderArray objectAtIndex:i];
                        [slider changeSliderFrame:self.scaleFactor*grZoomScale];
                    }
                    
                    frame = CGRectMake(0.0f, 0.0f, self.scaleFactor*time, grSliderHeightMax);
                }
            }
            else
            {
                if (gnTimelineType == TIMELINE_TYPE_1)
                {
                    if (time <= self.totalTime)
                    {
                        if (self.scaleFactor*time < sliderWidthMin)
                        {
                            self.scaleFactor = sliderWidthMin/time;
                            
                            for (int i=0; i<self.sliderArray.count; i++)
                            {
                                YJLVideoRangeSlider* slider = [self.sliderArray objectAtIndex:i];
                                [slider changeSliderFrame:self.scaleFactor*grZoomScale];
                            }
                        }
                        
                        frame = CGRectMake(0.0f, 0.0f, self.scaleFactor*time, grSliderHeightMax);
                    }
                    else
                    {
                        self.totalTime = time;
                        self.scaleFactor = self.frame.size.width / self.totalTime;
                        
                        CGFloat minDuration = self.totalTime;
                    
                        for (int i=0; i<self.sliderArray.count; i++)
                        {
                            YJLVideoRangeSlider* slider = [self.sliderArray objectAtIndex:i];
                            
                            CGFloat duration = slider.durationSeconds;
                        
                            if (duration < minDuration)
                                minDuration = duration;
                        }
                        
                        if (self.scaleFactor*minDuration < sliderWidthMin)
                            self.scaleFactor = sliderWidthMin/minDuration;
                        
                        for (int i=0; i<self.sliderArray.count; i++)
                        {
                            YJLVideoRangeSlider* slider = [self.sliderArray objectAtIndex:i];
                            [slider changeSliderFrame:self.scaleFactor*grZoomScale];
                        }
                        
                        frame = CGRectMake(0.0f, 0.0f, self.scaleFactor*time, grSliderHeightMax);
                    }
                }
                else if (gnTimelineType == TIMELINE_TYPE_2)
                {
                    frame = CGRectMake(self.scaleFactor*self.totalTime, 0.0f, self.scaleFactor*time, grSliderHeightMax);
                    self.totalTime = self.totalTime + time;
                }
                else if (gnTimelineType == TIMELINE_TYPE_3)
                {
                    CGFloat overlappedTime = self.totalTime - TIME_OVERLAPPED_VALUE;
                    
                    if (overlappedTime < 0.0f)
                    {
                        overlappedTime = 0.0f;
                    }
                    
                    frame = CGRectMake(self.scaleFactor*overlappedTime, 0.0f, self.scaleFactor*time, grSliderHeightMax);
                    self.totalTime = overlappedTime + time;
                }
            }

            YJLVideoRangeSlider* newSlider = [[YJLVideoRangeSlider alloc] initWithFrame:frame videoUrl:mediaObj.mediaUrl];
            newSlider.delegate = self;
            newSlider.objectIndex = (int)self.sliderArray.count;
            [self addSubview:newSlider];

            [self.sliderArray addObject:newSlider];
        }
    }
    else if (mediaObj.mediaType == MEDIA_MUSIC)
    {
        AVAsset *myAsset = [AVURLAsset URLAssetWithURL:mediaObj.mediaUrl options:nil];
        
        CGFloat duration = CMTimeGetSeconds([myAsset duration]);
        
        if (self.sliderArray.count == 0)// this is first slider.
        {
            YJLVideoRangeSlider* newSlider = [[YJLVideoRangeSlider alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.bounds.size.width, grSliderHeightMax) musicUrl:mediaObj.mediaUrl];
            newSlider.delegate = self;
            newSlider.objectIndex = 0;
            [self addSubview:newSlider];
            
            [self.sliderArray addObject:newSlider];
            
            self.totalTime = duration;
            self.scaleFactor = self.frame.size.width/20.0f;
            
            [newSlider changeSliderFrame:self.scaleFactor*grZoomScale];
            [newSlider drawRuler];
        }
        else//already a sliders exist on timelines.
        {
            CGFloat time = duration;
            CGRect frame = CGRectZero;
            
            if (time <= self.totalTime)
            {
                if (self.scaleFactor*time < sliderWidthMin)
                {
                    self.scaleFactor = sliderWidthMin/time;
                    
                    for (int i=0; i<self.sliderArray.count; i++)
                    {
                        YJLVideoRangeSlider* slider = [self.sliderArray objectAtIndex:i];
                        [slider changeSliderFrame:self.scaleFactor*grZoomScale];
                    }
                }
                
                frame = CGRectMake(0.0f, 0.0f, self.scaleFactor*time, grSliderHeightMax);
            }
            else
            {
                self.totalTime = time;
                self.scaleFactor = self.frame.size.width / self.totalTime;
                
                CGFloat minDuration = self.totalTime;
            
                for (int i=0; i<self.sliderArray.count; i++)
                {
                    YJLVideoRangeSlider* slider = [self.sliderArray objectAtIndex:i];
                    CGFloat duration = slider.durationSeconds;
                
                    if (duration < minDuration)
                        minDuration = duration;
                }
                
                if (self.scaleFactor*minDuration < sliderWidthMin)
                    self.scaleFactor = sliderWidthMin/minDuration;
                
                for (int i=0; i<self.sliderArray.count; i++)
                {
                    YJLVideoRangeSlider* slider = [self.sliderArray objectAtIndex:i];
                    [slider changeSliderFrame:self.scaleFactor*grZoomScale];
                }
                
                frame = CGRectMake(0.0f, 0.0f, self.scaleFactor*time, grSliderHeightMax);
            }

            YJLVideoRangeSlider* newSlider = [[YJLVideoRangeSlider alloc] initWithFrame:frame musicUrl:mediaObj.mediaUrl];
            newSlider.delegate = self;
            newSlider.objectIndex = (int)self.sliderArray.count;
            [self addSubview:newSlider];
            
            [self.sliderArray addObject:newSlider];
        }
    }
    else if ((mediaObj.mediaType == MEDIA_PHOTO)||(mediaObj.mediaType == MEDIA_GIF))
    {
        if (self.sliderArray.count == 0)// it is first slider
        {
            self.totalTime = grPhotoDefaultDuration;
            self.scaleFactor = self.frame.size.width / self.totalTime;
            
            YJLVideoRangeSlider* newSlider = [[YJLVideoRangeSlider alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.bounds.size.width, grSliderHeightMax) image:mediaObj.imageView.image scale:self.scaleFactor type:mediaObj.mediaType];
            
            newSlider.delegate = self;
            newSlider.objectIndex = 0;
            [self addSubview:newSlider];

            [self.sliderArray addObject:newSlider];
            
            self.scaleFactor = self.frame.size.width/20.0f;
            
            [newSlider changeSliderFrame:self.scaleFactor*grZoomScale];
            [newSlider drawRuler];
        }
        else
        {
            BOOL isMusicOnly = YES;

            for (int i=0; i<self.sliderArray.count; i++)
            {
                YJLVideoRangeSlider* prevSlider = [self.sliderArray objectAtIndex:i];
            
                if (prevSlider.media_type != MEDIA_MUSIC)
                {
                    isMusicOnly = NO;
                    break;
                }
            }

            CGRect frame = CGRectMake(0.0f, 0.0f, self.scaleFactor*grPhotoDefaultDuration, grSliderHeightMax);

            if ((!isMusicOnly)&&(gnTimelineType == TIMELINE_TYPE_2))
            {
                frame = CGRectMake(self.scaleFactor*self.totalTime, 0.0f, self.scaleFactor*grPhotoDefaultDuration, grSliderHeightMax);
                self.totalTime = self.totalTime + grPhotoDefaultDuration;
            }
            else if ((!isMusicOnly)&&(gnTimelineType == TIMELINE_TYPE_3))
            {
                CGFloat overlappedTime = self.totalTime - TIME_OVERLAPPED_VALUE;
                
                if (overlappedTime < 0.0f)
                {
                    overlappedTime = 0.0f;
                }
                
                frame = CGRectMake(self.scaleFactor*overlappedTime, 0.0f, self.scaleFactor*grPhotoDefaultDuration, grSliderHeightMax);
                self.totalTime = overlappedTime + grPhotoDefaultDuration;
            }
            else if (self.totalTime < grPhotoDefaultDuration)
            {
                self.totalTime = grPhotoDefaultDuration;
            }
            
            YJLVideoRangeSlider* newSlider = [[YJLVideoRangeSlider alloc] initWithFrame:frame image:mediaObj.imageView.image scale:self.scaleFactor type:mediaObj.mediaType];
            newSlider.delegate = self;
            newSlider.objectIndex = (int)self.sliderArray.count;
            [self addSubview:newSlider];

            [self.sliderArray addObject:newSlider];
        }
    }
    else if (mediaObj.mediaType == MEDIA_TEXT)
    {
        if (self.sliderArray.count == 0)// it is first slider
        {
            self.totalTime = grTextDefaultDuration;
            self.scaleFactor = self.frame.size.width / self.totalTime;
            
            YJLVideoRangeSlider* newSlider = [[YJLVideoRangeSlider alloc] initWithFrameText:mediaObj.textView.text frame:CGRectMake(0.0f, 0.0f, self.bounds.size.width, grSliderHeightMax) scale:self.scaleFactor];
            
            newSlider.delegate = self;
            newSlider.objectIndex = 0;
            [self addSubview:newSlider];
            
            [self.sliderArray addObject:newSlider];
            
            self.scaleFactor = self.frame.size.width/20.0f;
            
            [newSlider changeSliderFrame:self.scaleFactor*grZoomScale];
            [newSlider drawRuler];
        }
        else
        {
            BOOL isMusicOnly = YES;
            
            for (int i=0; i<self.sliderArray.count; i++)
            {
                YJLVideoRangeSlider* prevSlider = [self.sliderArray objectAtIndex:i];
                
                if (prevSlider.media_type != MEDIA_MUSIC)
                {
                    isMusicOnly = NO;
                    break;
                }
            }
            
            CGRect frame = CGRectMake(0.0f, 0.0f, self.scaleFactor*grTextDefaultDuration, grSliderHeightMax);
            
            if ((!isMusicOnly)&&(gnTimelineType == TIMELINE_TYPE_2))
            {
                frame = CGRectMake(self.scaleFactor*self.totalTime, 0.0f, self.scaleFactor*grTextDefaultDuration, grSliderHeightMax);
                self.totalTime = self.totalTime + grTextDefaultDuration;
            }
            else if ((!isMusicOnly)&&(gnTimelineType == TIMELINE_TYPE_3))
            {
                CGFloat overlappedTime = self.totalTime - TIME_OVERLAPPED_VALUE;
                
                if (overlappedTime < 0.0f)
                {
                    overlappedTime = 0.0f;
                }
                
                frame = CGRectMake(self.scaleFactor*overlappedTime, 0.0f, self.scaleFactor*grTextDefaultDuration, grSliderHeightMax);
                self.totalTime = overlappedTime + grTextDefaultDuration;
            }
            else if (self.totalTime < grTextDefaultDuration)
            {
                self.totalTime = grTextDefaultDuration;
            }
            
            YJLVideoRangeSlider* newSlider = [[YJLVideoRangeSlider alloc] initWithFrameText:mediaObj.textView.text frame:frame scale:self.scaleFactor];
            newSlider.delegate = self;
            newSlider.objectIndex = (int)self.sliderArray.count;
            [self addSubview:newSlider];
            
            [self.sliderArray addObject:newSlider];
        }
    }
    
    
    /* change sliders height by scaleFactor from minimum slider width*/
    CGFloat minWidth = 0.0f;
    CGFloat minDuration = self.totalTime;
    
    for (int i=0; i<self.sliderArray.count; i++)
    {
        YJLVideoRangeSlider* slider = [self.sliderArray objectAtIndex:i];

        if (minDuration > (slider.rightPosition - slider.leftPosition))
        {
            minDuration = (slider.rightPosition - slider.leftPosition);
        }
    }
    
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        minWidth = IPHONE_TIMELINE_WIDTH_MIN;
    else
        minWidth = IPAD_TIMELINE_WIDTH_MIN;
    
    self.scaleFactor = minWidth / minDuration;
    
    for (int i=0; i<self.sliderArray.count; i++)
    {
        YJLVideoRangeSlider* slider = [self.sliderArray objectAtIndex:i];
        [slider changeSliderFrame:self.scaleFactor*grZoomScale];
        [slider drawRuler];
        [slider layoutSubviews];
    }
    
    
    /* change content size */
    if (self.sliderArray.count > 0)
        self.contentSize = CGSizeMake(self.scaleFactor*grZoomScale*self.totalTime, self.sliderArray.count*grSliderHeight);
    else
        self.contentSize = CGSizeMake(self.scaleFactor*grZoomScale*self.totalTime, grSliderHeight);
    
    grMaxContentHeight = self.contentSize.height;
    
    
    /* change slider frame */
    for (int i=0; i<self.sliderArray.count; i++)
    {
        YJLVideoRangeSlider* slider = [self.sliderArray objectAtIndex:i];
        slider.frame = CGRectMake(slider.frame.origin.x, grSliderHeight*(self.sliderArray.count-1-i), slider.frame.size.width, grSliderHeight);
        slider.yPosition = slider.center.y;
        [slider changeSliderYPosition];
    }
    

    /* change self frame */
    if (self.sliderArray.count > gnVisibleMaxCount)
    {
        if (self.sliderArray.count*grSliderHeight >= gnVisibleMaxCount*grSliderHeightMax)
            self.frame = CGRectMake(self.frame.origin.x, bottomY - gnVisibleMaxCount*grSliderHeightMax, self.frame.size.width, gnVisibleMaxCount*grSliderHeightMax);
        else
            self.frame = CGRectMake(self.frame.origin.x, bottomY - self.sliderArray.count*grSliderHeight, self.frame.size.width, self.sliderArray.count*grSliderHeight);
    }
    else
    {
        self.frame = CGRectMake(self.frame.origin.x, bottomY - self.sliderArray.count*grSliderHeight, self.frame.size.width, self.sliderArray.count*grSliderHeight);
    }

    [self setNeedsLayout];
    
    if ([self.timelineDelegate respondsToSelector:@selector(updateTotalTime)])
    {
        [self.timelineDelegate updateTotalTime];
    }
    
    /* init Preview */
    if (!self.popoverBubble)
    {
        //preview bubble
        self.popoverBubble = [[YJLResizibleBubble alloc] initWithFrame:CGRectMake(0.0f, 0.0f, grSliderHeight*4.0f, grSliderHeight*2.0f)];
        self.popoverBubble.alpha = 0;
        self.popoverBubble.backgroundColor = [UIColor clearColor];
        [self.superview addSubview:self.popoverBubble];
        
        self.previewImageView = [[UIImageView alloc] initWithFrame:CGRectMake(1.0f, 1.0f, grSliderHeight*4.0f - 2.0f, grSliderHeight*2.0f - 7.0f)];
        [self.previewImageView setBackgroundColor:[UIColor clearColor]];
        self.previewImageView.userInteractionEnabled = NO;
        self.previewImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.popoverBubble addSubview:self.previewImageView];
        
        self.previewTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(1.0f, grSliderHeight*1.5f, grSliderHeight*4.0f - 2.0f, grSliderHeight*0.5f - 5.0f)];
        self.previewTimeLabel.backgroundColor = [UIColor colorWithWhite:0.5f alpha:0.5f];
        self.previewTimeLabel.textAlignment = NSTextAlignmentCenter;
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
            self.previewTimeLabel.font = [UIFont fontWithName:MYRIADPRO size:10];
        else
            self.previewTimeLabel.font = [UIFont fontWithName:MYRIADPRO size:14];
        
        [self.previewTimeLabel setText:@"00:00.000"];
        self.previewTimeLabel.textColor = [UIColor whiteColor];
        self.previewTimeLabel.shadowColor = [UIColor blackColor];
        self.previewTimeLabel.shadowOffset = CGSizeMake(0, 1);
        self.previewTimeLabel.layer.borderColor = [UIColor blackColor].CGColor;
        self.previewTimeLabel.layer.borderWidth = 0.5f;
        [self.popoverBubble addSubview:self.previewTimeLabel];
    }

    int objectIndex = (int)self.sliderArray.count-1;
    
    YJLVideoRangeSlider* slider = [self.sliderArray objectAtIndex:objectIndex];
    CGFloat originX = slider.leftPosition * slider.frame_width / slider.durationSeconds;
    CGRect bubbleFrame = CGRectMake(originX, slider.frame.origin.y - self.popoverBubble.frame.size.height, self.popoverBubble.frame.size.width, self.popoverBubble.frame.size.height);
    bubbleFrame = [self.superview convertRect:bubbleFrame fromView:self];
    self.popoverBubble.frame = bubbleFrame;
    
    if(objectIndex <= 1)
        [self previewProc:objectIndex];
    
    [self setNeedsDisplay];
}

-(void) updateWaveform:(int) index url:(NSURL*) musicUrl
{
    YJLVideoRangeSlider* slider = [self.sliderArray objectAtIndex:index];
    
    [slider updateWaveform:musicUrl];
}

#pragma mark - 
#pragma mark - Reset Timeline

-(void)resetTimeline:(int) index obj:(MediaObjectView*) object
{
    YJLVideoRangeSlider* slider = [self.sliderArray objectAtIndex:index];
    [slider setActions:object.startActionType startTime:object.mfStartAnimationDuration endType:object.endActionType endTime:object.mfEndAnimationDuration];
    
    slider.isGrouped = object.isGrouped;
    
    if (slider.isGrouped)
    {
        slider.groupImageView.hidden = NO;
    }
    else
    {
        slider.groupImageView.hidden = YES;
    }

}


#pragma mark - Change Slider Order

-(void) changeSliderOrder:(int) index insertFlag:(BOOL)insertFlag
{
    if (self.sliderArray.count <= 0)
        return;

    YJLVideoRangeSlider* slider = [self.sliderArray objectAtIndex:index];
    [self.sliderArray removeObjectAtIndex:index];
    
    if (insertFlag)
        [self.sliderArray insertObject:slider atIndex:0];
    else
        [self.sliderArray addObject:slider];
    
    for (int i=0; i<self.sliderArray.count; i++)
    {
        YJLVideoRangeSlider* slider = [self.sliderArray objectAtIndex:i];
        slider.objectIndex = i;
        slider.frame = CGRectMake(slider.frame.origin.x, grSliderHeight*(self.sliderArray.count-1-i), slider.frame.size.width, grSliderHeight);
        slider.yPosition = slider.center.y;
        [slider changeSliderYPosition];
    }
}


#pragma mark - Remove Slider

-(void) removeSlider:(int) index
{
    YJLVideoRangeSlider* slider = [self.sliderArray objectAtIndex:index];
    
    BOOL isFirstRemoved = YES;
    CGFloat removedLeft = slider.leftPosition;
    CGFloat minLeft = self.totalTime;
    
    [slider removeFromSuperview];
    [self.sliderArray removeObjectAtIndex:index];

    for (int i=0; i<self.sliderArray.count; i++)
    {
        YJLVideoRangeSlider* slider = [self.sliderArray objectAtIndex:i];
        
        if (removedLeft > slider.leftPosition)
            isFirstRemoved = NO;
        
        if (minLeft >= slider.leftPosition)
            minLeft = slider.leftPosition;
    }
    
    if (isFirstRemoved)
    {
        for (int i=0; i<self.sliderArray.count; i++)
        {
            YJLVideoRangeSlider* slider = [self.sliderArray objectAtIndex:i];

            CGFloat right = minLeft * slider.frame_width / slider.durationSeconds;
            [slider changeSliderByLeftPosition:(right)];
        }
    }
    
    for (int i=0; i<self.sliderArray.count; i++)
    {
        YJLVideoRangeSlider* slider = [self.sliderArray objectAtIndex:i];
        slider.frame = CGRectMake(slider.frame.origin.x, grSliderHeight*(self.sliderArray.count-1-i), slider.frame.size.width, grSliderHeight);
        slider.objectIndex = i;
        slider.yPosition = slider.center.y;
        [slider changeSliderYPosition];
    }
    
    /* change self frame */
    if (self.sliderArray.count > gnVisibleMaxCount)
    {
        if (self.sliderArray.count*grSliderHeight >= gnVisibleMaxCount*grSliderHeightMax)
            self.frame = CGRectMake(self.frame.origin.x, bottomY - gnVisibleMaxCount*grSliderHeightMax, self.frame.size.width, gnVisibleMaxCount*grSliderHeightMax);
        else
            self.frame = CGRectMake(self.frame.origin.x, bottomY - self.sliderArray.count*grSliderHeight, self.frame.size.width, self.sliderArray.count*grSliderHeight);
    }
    else
    {
        self.frame = CGRectMake(self.frame.origin.x, bottomY - self.sliderArray.count*grSliderHeight, self.frame.size.width, self.sliderArray.count*grSliderHeight);
    }
    
    if (self.sliderArray.count > 0)
    {
        YJLVideoRangeSlider* slider = [self.sliderArray objectAtIndex:0];

        CGFloat maxTime = slider.rightPosition;
        
        for (int i=0; i<self.sliderArray.count; i++)
        {
            YJLVideoRangeSlider* slider = [self.sliderArray objectAtIndex:i];
        
            CGFloat time_ = slider.rightPosition;
            
            if (time_ >= maxTime)
                maxTime = time_;
        }
        
        self.totalTime = maxTime;
        
        if (self.sliderArray.count > 0)
            self.contentSize = CGSizeMake(self.scaleFactor*grZoomScale*self.totalTime, self.sliderArray.count*grSliderHeight);
        else
            self.contentSize = CGSizeMake(self.scaleFactor*grZoomScale*self.totalTime, grSliderHeight);
        
        grMaxContentHeight = self.contentSize.height;
    }
    else
    {
        self.totalTime = 0.0f;
    }
    
    [self setNeedsLayout];

    if ([self.timelineDelegate respondsToSelector:@selector(updateTotalTime)])
    {
        [self.timelineDelegate updateTotalTime];
    }
    
    [self setNeedsDisplay];
}

-(void) replaceSlider:(int) selectedIndex
{
    if (self.sliderArray.count <= 0)
        return;
    
    [self.sliderArray exchangeObjectAtIndex:(self.sliderArray.count-1) withObjectAtIndex:selectedIndex];
    
    YJLVideoRangeSlider* oldSlider = self.sliderArray.lastObject;
    
    CGFloat left = oldSlider.leftPosition * oldSlider.frame_width / oldSlider.durationSeconds;
    CGFloat right = oldSlider.rightPosition * oldSlider.frame_width / oldSlider.durationSeconds;
    
    [oldSlider removeFromSuperview];
    [self.sliderArray removeLastObject];
    
    YJLVideoRangeSlider* newSlider = [self.sliderArray objectAtIndex:selectedIndex];
    [newSlider replaceSliderLeftPosition:left right:right];

    for (int i=0; i<self.sliderArray.count; i++)
    {
        YJLVideoRangeSlider* slider = [self.sliderArray objectAtIndex:i];
        slider.objectIndex = i;
        slider.frame = CGRectMake(slider.frame.origin.x, grSliderHeight*(self.sliderArray.count-1-i), slider.frame.size.width, grSliderHeight);
        slider.yPosition = slider.center.y;
        [slider changeSliderYPosition];
    }
    
    /* change self frame */
    if (self.sliderArray.count > gnVisibleMaxCount)
    {
        if (self.sliderArray.count*grSliderHeight >= gnVisibleMaxCount*grSliderHeightMax)
            self.frame = CGRectMake(self.frame.origin.x, bottomY - gnVisibleMaxCount*grSliderHeightMax, self.frame.size.width, gnVisibleMaxCount*grSliderHeightMax);
        else
            self.frame = CGRectMake(self.frame.origin.x, bottomY - self.sliderArray.count*grSliderHeight, self.frame.size.width, self.sliderArray.count*grSliderHeight);
    }
    else
    {
        self.frame = CGRectMake(self.frame.origin.x, bottomY - self.sliderArray.count*grSliderHeight, self.frame.size.width, self.sliderArray.count*grSliderHeight);
    }
    
    if (self.sliderArray.count > 0)
    {
        YJLVideoRangeSlider* slider = [self.sliderArray objectAtIndex:0];
        
        CGFloat maxTime = slider.rightPosition;
        
        for (int i=0; i<self.sliderArray.count; i++)
        {
            YJLVideoRangeSlider* slider = [self.sliderArray objectAtIndex:i];
            
            CGFloat time_ = slider.rightPosition;
            
            if (time_ >= maxTime)
                maxTime = time_;
        }
        
        self.totalTime = maxTime;
        
        if (self.sliderArray.count > 0)
            self.contentSize = CGSizeMake(self.scaleFactor*grZoomScale*self.totalTime, self.sliderArray.count*grSliderHeight);
        else
            self.contentSize = CGSizeMake(self.scaleFactor*grZoomScale*self.totalTime, grSliderHeight);
        
        grMaxContentHeight = self.contentSize.height;
    }
    else
    {
        self.totalTime = 0.0f;
    }
    
    [self setNeedsLayout];
    
    if ([self.timelineDelegate respondsToSelector:@selector(updateTotalTime)])
    {
        [self.timelineDelegate updateTotalTime];
    }
}


#pragma mark -
#pragma mark - Timeline Preview Proc

-(void) previewProc:(int) selectedIndex
{
    if (selectedIndex > 0)
    {
        YJLVideoRangeSlider* selectedSlider = [self.sliderArray objectAtIndex:selectedIndex];
        
        CGFloat originX = selectedSlider.leftPosition * selectedSlider.frame_width / selectedSlider.durationSeconds;
        CGRect bubbleFrame = CGRectMake(originX, selectedSlider.frame.origin.y - self.popoverBubble.frame.size.height, self.popoverBubble.frame.size.width, self.popoverBubble.frame.size.height);
        bubbleFrame = [self.superview convertRect:bubbleFrame fromView:self];
        self.popoverBubble.frame = bubbleFrame;
        
        CGFloat selectedLeft = selectedSlider.leftPosition;
        
        int previewIndex = selectedIndex - 1;
        
        YJLVideoRangeSlider* previewSlider = [self.sliderArray objectAtIndex:previewIndex];
        
        if ((previewSlider.rightPosition >= selectedLeft) && (previewSlider.leftPosition <= selectedLeft))
        {
            [self changePreviewThumbnail:previewSlider position:selectedLeft];
        }
        else
        {
            if (previewIndex > 0)
            {
                BOOL isContained = NO;
                
                while (!isContained)
                {
                    previewIndex--;
                    
                    if (previewIndex < 0)
                    {
                        isContained = YES;
                        
                        self.previewImageView.image = nil;
                        self.previewImageView.backgroundColor = [UIColor blackColor];
                        
                        self.previewPlayerLayer.hidden = YES;
                        self.previewPlayerItem = nil;
                        
                        mnPreviewIndex = -1;
                        
                        NSString* timeStr = [self timeToStr:selectedLeft];
                        [self.previewTimeLabel setText:[NSString stringWithFormat:@"%@", timeStr]];
                    }
                    else
                    {
                        YJLVideoRangeSlider* previewSlider = [self.sliderArray objectAtIndex:previewIndex];
                        
                        if ((previewSlider.rightPosition >= selectedLeft) && (previewSlider.leftPosition <= selectedLeft))
                        {
                            isContained = YES;
                            
                            [self changePreviewThumbnail:previewSlider position:selectedLeft];
                        }
                    }
                }
            }
            else
            {
                self.previewImageView.image = nil;
                self.previewImageView.backgroundColor = [UIColor blackColor];
                
                self.previewPlayerLayer.hidden = YES;
                self.previewPlayerItem = nil;
                
                mnPreviewIndex = -1;
                
                NSString* timeStr = [self timeToStr:selectedLeft];
                [self.previewTimeLabel setText:[NSString stringWithFormat:@"%@", timeStr]];
            }
        }
    }
    else
    {
        self.previewImageView.image = nil;
        self.previewImageView.backgroundColor = [UIColor blackColor];
        
        self.previewPlayerLayer.hidden = YES;
        self.previewPlayerItem = nil;
        
        mnPreviewIndex = -1;
    }
}

-(void) changePreviewThumbnail:(YJLVideoRangeSlider*) previewSlider position:(CGFloat) position
{
    if (mnPreviewIndex != previewSlider.objectIndex)
    {
        if ((previewSlider.media_type == MEDIA_PHOTO)||(previewSlider.media_type == MEDIA_GIF))
        {
            self.previewPlayerLayer.hidden = YES;
            self.previewPlayerItem = nil;
            
            self.previewImageView.image = previewSlider.thumbnailImageView.image;
            self.previewImageView.backgroundColor = [UIColor clearColor];
        }
        else if (previewSlider.media_type == MEDIA_TEXT)
        {
            self.previewPlayerLayer.hidden = YES;
            self.previewPlayerItem = nil;
            
            self.previewImageView.image = previewSlider.thumbnailImageView.image;
            self.previewImageView.backgroundColor = [UIColor clearColor];
        }
        else if (previewSlider.media_type == MEDIA_MUSIC)
        {
            self.previewPlayerLayer.hidden = YES;
            self.previewPlayerItem = nil;
            
            self.previewImageView.image = [UIImage imageNamed:@"musicSymbol"];
            self.previewImageView.backgroundColor = [UIColor clearColor];
        }
        else if (previewSlider.media_type == MEDIA_VIDEO)
        {
            self.previewImageView.backgroundColor = [UIColor clearColor];
            self.previewImageView.image = nil;
            
            self.previewPlayerItem = [AVPlayerItem playerItemWithAsset:previewSlider.myAsset];
            
            if (!self.previewPlayer)
            {
                self.previewPlayer = [AVPlayer playerWithPlayerItem:self.previewPlayerItem];
                self.previewPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:self.previewPlayer];
                
                self.previewPlayerLayer.frame = self.previewImageView.frame;
                [self.popoverBubble.layer addSublayer:self.previewPlayerLayer];
                
                [self.popoverBubble bringSubviewToFront:self.previewTimeLabel];
            }
            else
            {
                [self.previewPlayer replaceCurrentItemWithPlayerItem:self.previewPlayerItem];
            }
            
            self.previewPlayerLayer.hidden = NO;
            
            [self.previewPlayer seekToTime:CMTimeMakeWithSeconds((position - previewSlider.leftPosition), previewSlider.myAsset.duration.timescale) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
        }
        
        mnPreviewIndex = previewSlider.objectIndex;
    }
    else
    {
        if (previewSlider.media_type == MEDIA_VIDEO)
        {
            self.previewImageView.backgroundColor = [UIColor clearColor];
            self.previewImageView.image = nil;
            self.previewPlayerLayer.hidden = NO;
            
            [self.previewPlayer seekToTime:CMTimeMakeWithSeconds((position - previewSlider.leftPosition), previewSlider.myAsset.duration.timescale) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
        }
    }
    
    NSString* timeStr = [self timeToStr:position];
    [self.previewTimeLabel setText:[NSString stringWithFormat:@"%@", timeStr]];
}


#pragma mark - YJLVideoRangeSliderDelegate

- (void)videoRange:(YJLVideoRangeSlider *)videoRange didChangeLeftPosition:(CGFloat)leftPosition rightPosition:(CGFloat)rightPosition
{
    CGFloat minLeftPosition = leftPosition;
    
    if (videoRange.isGrouped)
    {
        for (int i=0; i<self.sliderArray.count; i++)
        {
            YJLVideoRangeSlider* slider = [self.sliderArray objectAtIndex:i];
            
            if (slider.isGrouped)
            {
                if (minLeftPosition >= slider.leftPosition)
                {
                    minLeftPosition = slider.leftPosition;
                }
            }
        }
    }

    if (minLeftPosition <= 0.0f)
    {
        CGFloat left = minLeftPosition * videoRange.frame_width / videoRange.durationSeconds;
        
        for (int i=0; i<self.sliderArray.count; i++)
        {
            YJLVideoRangeSlider* slider = [self.sliderArray objectAtIndex:i];
            [slider changeSliderByLeftPosition:left];
        }
    }
    else
    {
        BOOL isMinLeft = YES;
        
        for (int i=0; i<self.sliderArray.count; i++)
        {
            YJLVideoRangeSlider* slider = [self.sliderArray objectAtIndex:i];
            
            if ((slider.objectIndex != videoRange.objectIndex)&&(slider.leftPosition < minLeftPosition))
            {
                isMinLeft = NO;
                break;
            }
        }
        
        if (isMinLeft)
        {
            CGFloat left = minLeftPosition * videoRange.frame_width / videoRange.durationSeconds;
            
            for (int i=0; i<self.sliderArray.count; i++)
            {
                YJLVideoRangeSlider* slider = [self.sliderArray objectAtIndex:i];
                [slider changeSliderByLeftPosition:left];
            }
        }
    }

    ////////////////// 2015/09/22 /////////////////////
    
    CGFloat minLeft = videoRange.leftPosition;
    
    for (int i=0; i<self.sliderArray.count; i++)
    {
        YJLVideoRangeSlider* slider = [self.sliderArray objectAtIndex:i];
        
        if (slider.leftPosition < minLeft)
        {
            minLeft = slider.leftPosition;
        }
    }
    
    if (minLeft > 0.0f)
    {
        for (int i=0; i<self.sliderArray.count; i++)
        {
            YJLVideoRangeSlider* slider = [self.sliderArray objectAtIndex:i];
            
            CGFloat deltaPosition = minLeft * videoRange.frame_width / videoRange.durationSeconds;
            
            [slider changeSliderByLeftPosition:deltaPosition];
        }
    }
    
    /////////////////////////////////////////////////////
    
    CGFloat time = rightPosition;
    
    if (time > self.totalTime)
    {
        self.totalTime = time;
        
        if (self.sliderArray.count > 0)
            self.contentSize = CGSizeMake(self.scaleFactor*grZoomScale*self.totalTime, self.sliderArray.count*grSliderHeight);
        else
            self.contentSize = CGSizeMake(self.scaleFactor*grZoomScale*self.totalTime, grSliderHeight);
        
        grMaxContentHeight = self.contentSize.height;
    }
    else
    {
        CGFloat maxTime = time;
        
        for (int i=0; i<self.sliderArray.count; i++)
        {
            YJLVideoRangeSlider* slider = [self.sliderArray objectAtIndex:i];
            CGFloat time_ = slider.rightPosition;
            
            if (time_ >= maxTime)
                maxTime = time_;
        }
        
        self.totalTime = maxTime;
        
        if (self.sliderArray.count > 0)
            self.contentSize = CGSizeMake(self.scaleFactor*grZoomScale*self.totalTime, self.sliderArray.count*grSliderHeight);
        else
            self.contentSize = CGSizeMake(self.scaleFactor*grZoomScale*self.totalTime, grSliderHeight);
        
        grMaxContentHeight = self.contentSize.height;
    }
    
    if ([self.timelineDelegate respondsToSelector:@selector(updateTotalTime)])
    {
        [self.timelineDelegate updateTotalTime];
    }
    
    [self detectSliderYPosition:videoRange.objectIndex];
    
    /* Preview Proc*/

    int selectedIndex = videoRange.objectIndex;

    [self previewProc:selectedIndex];
}

-(void) didEndGesture
{
    for (int i=0; i<self.sliderArray.count; i++)
    {
        YJLVideoRangeSlider* slider = [self.sliderArray objectAtIndex:i];
        slider.frame = CGRectMake(slider.frame.origin.x, grSliderHeight*(self.sliderArray.count-1-i), slider.frame.size.width, grSliderHeight);
        slider.objectIndex = i;
        slider.yPosition = slider.center.y;
        [slider changeSliderYPosition];
    }
}

- (void) detectSliderYPosition:(int) index
{
    YJLVideoRangeSlider* selectedSlider = [self.sliderArray objectAtIndex:index];
    CGFloat yPosition = selectedSlider.yPosition;
    
    int movedIndex = ((int)self.sliderArray.count-1) - (int)(yPosition / grSliderHeight);
    
    if (index != movedIndex)
    {
        gnSelectedObjectIndex = movedIndex;
        
        YJLVideoRangeSlider* slider = [self.sliderArray objectAtIndex:index];
        [self.sliderArray removeObjectAtIndex:index];
        [self.sliderArray insertObject:slider atIndex:movedIndex];
        
        if ([self.timelineDelegate respondsToSelector:@selector(exchangedObjects:toIndex:)])
        {
            [self.timelineDelegate exchangedObjects:index toIndex:movedIndex];
        }
        
        for (int i=0; i<self.sliderArray.count; i++)
        {
            YJLVideoRangeSlider* slider = [self.sliderArray objectAtIndex:i];
            slider.frame = CGRectMake(slider.frame.origin.x, grSliderHeight*(self.sliderArray.count-1-i), slider.frame.size.width, grSliderHeight);
            slider.objectIndex = i;
            slider.yPosition = slider.center.y;
            [slider changeSliderYPosition];
        }
    }
}

-(void) changeActionAll:(int) mediaType isStart:(BOOL) start actionTypeStr:(NSString*) typeStr actionType:(int) type actionTime:(CGFloat) time
{
    for (int i=0; i<self.sliderArray.count; i++)
    {
        YJLVideoRangeSlider* slider = [self.sliderArray objectAtIndex:i];
        
        if ((mediaType == MEDIA_MUSIC) && (slider.media_type == MEDIA_MUSIC))
        {
            if (start)
            {
                slider.startActionType = type;
                slider.startActionTime = time;
                
                if ((type == ACTION_NONE)&&(time == MIN_DURATION))
                    time = 0.00f;
                
                [slider.startAnimationLabel setText:[NSString stringWithFormat:@"%@\n%.2fs", typeStr, time]];
            }
            else
            {
                slider.endActionType = type;
                slider.endActionTime = time;
                
                if ((type == ACTION_NONE)&&(time == MIN_DURATION))
                    time = 0.00f;
                
                [slider.endAnimationLabel setText:[NSString stringWithFormat:@"%@\n%.2fs", typeStr, time]];
            }
        }
        else if((slider.media_type != MEDIA_MUSIC)&&(mediaType != MEDIA_MUSIC))
        {
            if (start)
            {
                slider.startActionType = type;
                slider.startActionTime = time;
                
                if ((type == ACTION_NONE)&&(time == MIN_DURATION))
                    time = 0.00f;
                
                [slider.startAnimationLabel setText:[NSString stringWithFormat:@"%@\n%.2fs", typeStr, time]];
            }
            else
            {
                slider.endActionType = type;
                slider.endActionTime = time;
                
                if ((type == ACTION_NONE)&&(time == MIN_DURATION))
                    time = 0.00f;
                
                [slider.endAnimationLabel setText:[NSString stringWithFormat:@"%@\n%.2fs", typeStr, time]];
            }
        }
        
        [slider layoutSubviews];
    }
}


#pragma mark -
#pragma mark - Change Timeline from duration

-(void) changeTimeline:(int) index time:(CGFloat)duration
{
    YJLVideoRangeSlider* slider = [self.sliderArray objectAtIndex:index];
    [slider changeSliderFrameByDuration:duration];
    
    if (self.sliderArray.count > 0)
    {
        YJLVideoRangeSlider* slider = [self.sliderArray objectAtIndex:0];
        
        CGFloat maxTime = slider.rightPosition;
        
        for (int i=0; i<self.sliderArray.count; i++)
        {
            YJLVideoRangeSlider* slider = [self.sliderArray objectAtIndex:i];
            
            CGFloat time_ = slider.rightPosition;
            if (time_ >= maxTime)
                maxTime = time_;
        }
        
        self.totalTime = maxTime;
        
        if (self.sliderArray.count > 0)
            self.contentSize = CGSizeMake(self.scaleFactor*grZoomScale*self.totalTime, self.sliderArray.count*grSliderHeight);
        else
            self.contentSize = CGSizeMake(self.scaleFactor*grZoomScale*self.totalTime, grSliderHeight);
        
        grMaxContentHeight = self.contentSize.height;
    }
    else
    {
        self.totalTime = 0;
    }
    
    [self setNeedsLayout];
    
    if ([self.timelineDelegate respondsToSelector:@selector(updateTotalTime)])
    {
        [self.timelineDelegate updateTotalTime];
    }
}

- (void)timelineObjectSelected:(int) objectIndex
{
    mnPreviewIndex = -1;
    
    for (int i=0; i<self.sliderArray.count; i++)
    {
        YJLVideoRangeSlider* slider = [self.sliderArray objectAtIndex:i];
        
        if (i == objectIndex)
        {
            [slider isActived];
            [self bringSubviewToFront:slider];
            
            CGFloat originX = slider.leftPosition * slider.frame_width / slider.durationSeconds;
            CGRect bubbleFrame = CGRectMake(originX, slider.frame.origin.y - self.popoverBubble.frame.size.height, self.popoverBubble.frame.size.width, self.popoverBubble.frame.size.height);
            bubbleFrame = [self.superview convertRect:bubbleFrame fromView:self];
            self.popoverBubble.frame = bubbleFrame;
            self.previewImageView.image = nil;
            self.previewImageView.backgroundColor = [UIColor clearColor];
        }
        else
        {
            [slider isNotActived];
        }
    }
    
    if ([self.timelineDelegate respondsToSelector:@selector(timelineSelected:)])
    {
        [self.timelineDelegate timelineSelected:objectIndex];
    }
}

- (void)timelineObjectDeselected
{
    mnPreviewIndex = -1;
    
    for (int i=0; i<self.sliderArray.count; i++)
    {
        YJLVideoRangeSlider* slider = [self.sliderArray objectAtIndex:i];
        [slider isNotActived];
    }
}


#pragma mark - get start position
-(void) initTimelinePosition:(int) index startPosition:(CGFloat) startPosition endPosition:(CGFloat) endPosition
{
    YJLVideoRangeSlider* slider = [self.sliderArray objectAtIndex:index];
    CGFloat left = startPosition * slider.frame_width / slider.durationSeconds;
    CGFloat right = endPosition * slider.frame_width / slider.durationSeconds;
    
    [slider changeSliderPosition:left right:right];
}


#pragma mark - get start position
- (CGFloat) getStartPosition:(int) index
{
    CGFloat startPosition = 0.0f;
    
    YJLVideoRangeSlider* slider = [self.sliderArray objectAtIndex:index];
    startPosition = slider.leftPosition;
    
    return startPosition;
}

#pragma mark - get end position
- (CGFloat) getEndPosition:(int) index
{
    CGFloat endPosition = 0.0f;
    
    YJLVideoRangeSlider* slider = [self.sliderArray objectAtIndex:index];
    endPosition = slider.rightPosition;
    
    return endPosition;
}

#pragma mark - get start action type
- (int) getStartActionType:(int) index
{
    YJLVideoRangeSlider* slider = [self.sliderArray objectAtIndex:index];
    
    return slider.startActionType;
}

#pragma mark - get end action type
- (int) getEndActionType:(int) index
{
    YJLVideoRangeSlider* slider = [self.sliderArray objectAtIndex:index];
    
    return slider.endActionType;
}

#pragma mark - get start action duration
- (CGFloat) getStartActionTime:(int) index
{
    YJLVideoRangeSlider* slider = [self.sliderArray objectAtIndex:index];
   
    return slider.startActionTime;
}

#pragma mark - get end action duration
- (CGFloat) getEndActionTime:(int) index
{
    YJLVideoRangeSlider* slider = [self.sliderArray objectAtIndex:index];
   
    return slider.endActionTime;
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
#pragma mark - Select Object

- (void) selectTimelineObject:(int) index
{
    for (int i=0; i<self.sliderArray.count; i++)
    {
        YJLVideoRangeSlider* slider = [self.sliderArray objectAtIndex:i];

        if (i==index)
            [slider isActived];
        else
            [slider isNotActived];
        
        [self.sliderArray replaceObjectAtIndex:i withObject:slider];
    }
}

-(void) changedTextThumbnail:(MediaObjectView*) object
{
    int index = object.objectIndex;
    
    if (index >= [self.sliderArray count])
        return;
    
    YJLVideoRangeSlider* slider = [self.sliderArray objectAtIndex:index];
    
    [slider changedTextThumbnail:object.textView.text];
}


#pragma mark -
#pragma mark - Preview

-(void) previewShow:(int) objectIndex
{
    YJLVideoRangeSlider* selectedSlider = [self.sliderArray objectAtIndex:objectIndex];
    
    CGFloat originX = selectedSlider.leftPosition * selectedSlider.frame_width / selectedSlider.durationSeconds;
    CGRect bubbleFrame = CGRectMake(originX, selectedSlider.frame.origin.y - self.popoverBubble.frame.size.height, self.popoverBubble.frame.size.width, self.popoverBubble.frame.size.height);
    bubbleFrame = [self.superview convertRect:bubbleFrame fromView:self];
    self.popoverBubble.frame = bubbleFrame;

    self.popoverBubble.alpha = 1.0f;
}

-(void) previewHide
{
    [self hideBubble];
    
    /*****************************/
    CGFloat minDuration = self.totalTime;
    for (int i=0; i<self.sliderArray.count; i++)
    {
        YJLVideoRangeSlider* slider = [self.sliderArray objectAtIndex:i];
        
        if (minDuration > (slider.rightPosition - slider.leftPosition))
            minDuration = (slider.rightPosition - slider.leftPosition);
    }
    
    CGFloat minWidth = 0.0f;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        minWidth = IPHONE_TIMELINE_WIDTH_MIN;
    else
        minWidth = IPAD_TIMELINE_WIDTH_MIN;
    
    self.scaleFactor = minWidth / minDuration;
    
    for (int i=0; i<self.sliderArray.count; i++)
    {
        YJLVideoRangeSlider* slider = [self.sliderArray objectAtIndex:i];
        [slider changeSliderFrame:self.scaleFactor*grZoomScale];
        [slider drawRuler];
    }
    
    if (self.sliderArray.count > 0)
        self.contentSize = CGSizeMake(self.scaleFactor*grZoomScale*self.totalTime, self.sliderArray.count*grSliderHeight);
    else
        self.contentSize = CGSizeMake(self.scaleFactor*grZoomScale*self.totalTime, grSliderHeight);
    /*****************************/
    
    if ([self.timelineDelegate respondsToSelector:@selector(updateTotalTime)])
    {
        [self.timelineDelegate updateTotalTime];
    }
}


#pragma mark - Bubble

- (void)hideBubble
{
    [UIView animateWithDuration:0.4
                          delay:0
                        options:UIViewAnimationCurveEaseIn | UIViewAnimationOptionAllowUserInteraction
                     animations:^(void) {
                         
                         self.popoverBubble.alpha = 0;
                     }
                     completion:nil];
}


#pragma mark -
#pragma mark - Show Timeline Menu

-(void) onShowTimelineMenu:(int) selectedIndex
{
    gnSelectedObjectIndex = selectedIndex;

    YJLVideoRangeSlider* slider = [self.sliderArray objectAtIndex:gnSelectedObjectIndex];
    
    NSArray *menuItems = nil;
    
    if (slider.isGrouped)
    {
        menuItems =
        @[
          [YJLActionMenuItem menuItem:@"UnGroup"
                                image:nil
                               target:self
                               action:@selector(onHandleGroup)],

          [YJLActionMenuItem menuItem:@"UnGroup All"
                                image:nil
                               target:self
                               action:@selector(onHandleUnGroupAll)],

          [YJLActionMenuItem menuItem:@"AlignLeft"
                                image:nil
                               target:self
                               action:@selector(onHandleAlignLeft)],
          
          [YJLActionMenuItem menuItem:@"AlignRight"
                                image:nil
                               target:self
                               action:@selector(onHandleAlignRight)],

          [YJLActionMenuItem menuItem:@"Stack"
                                image:nil
                               target:self
                               action:@selector(onHandleGroupStack)],

          [YJLActionMenuItem menuItem:@"Stagger"
                                image:nil
                               target:self
                               action:@selector(onHandleGroupStagger)],

          [YJLActionMenuItem menuItem:@"Flip Back"
                                image:nil
                               target:self
                               action:@selector(onHandleGroupFlipBack)],

          [YJLActionMenuItem menuItem:@"Skip to Start"
                                image:nil
                               target:self
                               action:@selector(skipToStart)],
          
          [YJLActionMenuItem menuItem:@"Skip to End"
                                image:nil
                               target:self
                               action:@selector(skipToEnd)],
          ];
    }
    else
    {
        if ((slider.media_type == MEDIA_PHOTO)||(slider.media_type == MEDIA_TEXT)||(slider.media_type == MEDIA_GIF))
        {
            menuItems =
            @[
              [YJLActionMenuItem menuItem:@"Skip to Start"
                                    image:nil
                                   target:self
                                   action:@selector(skipToStart)],
              
              [YJLActionMenuItem menuItem:@"Skip to End"
                                    image:nil
                                   target:self
                                   action:@selector(skipToEnd)],
              
              [YJLActionMenuItem menuItem:@"Edit Time"
                                    image:nil
                                   target:self
                                   action:@selector(editTime)],

              [YJLActionMenuItem menuItem:@"Group"
                                    image:nil
                                   target:self
                                   action:@selector(onHandleGroup)],
              ];
        }
        else if (slider.media_type == MEDIA_VIDEO)
        {
            menuItems =
            @[
              [YJLActionMenuItem menuItem:@"Skip to Start"
                                    image:nil
                                   target:self
                                   action:@selector(skipToStart)],
              
              [YJLActionMenuItem menuItem:@"Skip to End"
                                    image:nil
                                   target:self
                                   action:@selector(skipToEnd)],
              
              [YJLActionMenuItem menuItem:@"Segment Speed"
                                    image:nil
                                   target:self
                                   action:@selector(editSpeed)],

              [YJLActionMenuItem menuItem:@"Jog Video"
                                    image:nil
                                   target:self
                                   action:@selector(editJog)],

              [YJLActionMenuItem menuItem:@"Trim Video"
                                    image:nil
                                   target:self
                                   action:@selector(editTrim)],

              [YJLActionMenuItem menuItem:@"Group"
                                    image:nil
                                   target:self
                                   action:@selector(onHandleGroup)],
              ];
        }
        else if (slider.media_type == MEDIA_MUSIC)
        {
            menuItems =
            @[
              [YJLActionMenuItem menuItem:@"Remove"
                                    image:nil
                                   target:self
                                   action:@selector(removeMusic)],

              [YJLActionMenuItem menuItem:@"Skip to Start"
                                    image:nil
                                   target:self
                                   action:@selector(skipToStart)],
              
              [YJLActionMenuItem menuItem:@"Skip to End"
                                    image:nil
                                   target:self
                                   action:@selector(skipToEnd)],
              
              [YJLActionMenuItem menuItem:@"Edit Volume"
                                    image:nil
                                   target:self
                                   action:@selector(editVolume)],
              
              [YJLActionMenuItem menuItem:@"Segment Speed"
                                    image:nil
                                   target:self
                                   action:@selector(editSpeed)],
              
              [YJLActionMenuItem menuItem:@"Trim Music"
                                    image:nil
                                   target:self
                                   action:@selector(editTrim)],

              [YJLActionMenuItem menuItem:@"Group"
                                    image:nil
                                   target:self
                                   action:@selector(onHandleGroup)],
              ];
        }
    }
    
    CGFloat originX = slider.leftPosition * slider.frame_width / slider.durationSeconds;
    CGFloat width = (slider.rightPosition - slider.leftPosition) * slider.frame_width / slider.durationSeconds;
    CGRect menuFrame = CGRectMake(originX, slider.frame.origin.y, width, slider.frame.size.height);
    menuFrame = [self.superview convertRect:menuFrame fromView:self];
    
    [YJLActionMenu showMenuInView:self.superview
                         fromRect:menuFrame
                        menuItems:menuItems isWhiteBG:NO];
}


#pragma mark -
#pragma mark - Skip Start / End

-(void) skipToStart
{
    YJLVideoRangeSlider* selectedSlider = [self.sliderArray objectAtIndex:gnSelectedObjectIndex];
    
    if (selectedSlider.isGrouped)
    {
        BOOL isFirst = YES;
        CGFloat minLeft = 0.0f;

        for (int i=0; i<self.sliderArray.count; i++)
        {
            YJLVideoRangeSlider* slider = [self.sliderArray objectAtIndex:i];

            if (slider.isGrouped)
            {
                if (isFirst)
                {
                    minLeft = slider.leftPosition;
                    isFirst = NO;
                }
                else
                {
                    if (minLeft > slider.leftPosition)
                    {
                        minLeft = slider.leftPosition;
                    }
                }
            }
        }

        for (int i=0; i<self.sliderArray.count; i++)
        {
            YJLVideoRangeSlider* slider = [self.sliderArray objectAtIndex:i];
            
            if (slider.isGrouped)
            {
                [slider changeSliderByLeftPosition:(minLeft * selectedSlider.frame_width / selectedSlider.durationSeconds)];
            }
        }
        
        //////////////////////////// 2015/09/23 //////////////////////////
        
        if (minLeft > 0.0f)
        {
            CGFloat maxRight = 0.0f;
            
            for (int i=0; i<self.sliderArray.count; i++)
            {
                YJLVideoRangeSlider* slider = [self.sliderArray objectAtIndex:i];
                
                if (slider.isGrouped)
                {
                    if (slider.rightPosition > maxRight)
                    {
                        maxRight = slider.rightPosition;
                    }
                }
            }
            
            for (int i=0; i<self.sliderArray.count; i++)
            {
                YJLVideoRangeSlider* slider = [self.sliderArray objectAtIndex:i];
                
                if (!slider.isGrouped)
                {
                    [slider changeSliderByLeftPosition:(-maxRight * selectedSlider.frame_width / selectedSlider.durationSeconds)];
                }
            }
        }
        
        //////////////////////////////////////////////////////////////////

        CGFloat time = selectedSlider.rightPosition;
        
        if (time > self.totalTime)
        {
            self.totalTime = time;
            
            if (self.sliderArray.count > 0)
                self.contentSize = CGSizeMake(self.scaleFactor*grZoomScale*self.totalTime, self.sliderArray.count*grSliderHeight);
            else
                self.contentSize = CGSizeMake(self.scaleFactor*grZoomScale*self.totalTime, grSliderHeight);
            
            grMaxContentHeight = self.contentSize.height;
        }
        else
        {
            CGFloat maxTime = time;
            
            for (int i=0; i<self.sliderArray.count; i++)
            {
                YJLVideoRangeSlider* slider = [self.sliderArray objectAtIndex:i];
                CGFloat time_ = slider.rightPosition;
                
                if (time_ >= maxTime)
                    maxTime = time_;
            }
            
            self.totalTime = maxTime;
            
            if (self.sliderArray.count > 0)
                self.contentSize = CGSizeMake(self.scaleFactor*grZoomScale*self.totalTime, self.sliderArray.count*grSliderHeight);
            else
                self.contentSize = CGSizeMake(self.scaleFactor*grZoomScale*self.totalTime, grSliderHeight);
            
            grMaxContentHeight = self.contentSize.height;
        }
        
        if ([self.timelineDelegate respondsToSelector:@selector(updateTotalTime)])
        {
            [self.timelineDelegate updateTotalTime];
        }
    }
    else
    {
        if (selectedSlider.leftPosition > 0.0f)
        {
            CGFloat left = 0.0f;
            CGFloat right = (selectedSlider.rightPosition - selectedSlider.leftPosition) * selectedSlider.frame_width / selectedSlider.durationSeconds;
            [selectedSlider changeSliderPosition:left right:right];
            
            for (int i=0; i<self.sliderArray.count; i++)
            {
                if (i != gnSelectedObjectIndex)
                {
                    YJLVideoRangeSlider* slider = [self.sliderArray objectAtIndex:i];
                    [slider changeSliderByLeftPosition:(-right)];
                }
            }
            
            CGFloat time = selectedSlider.rightPosition;
            
            if (time > self.totalTime)
            {
                self.totalTime = time;
                
                if (self.sliderArray.count > 0)
                    self.contentSize = CGSizeMake(self.scaleFactor*grZoomScale*self.totalTime, self.sliderArray.count*grSliderHeight);
                else
                    self.contentSize = CGSizeMake(self.scaleFactor*grZoomScale*self.totalTime, grSliderHeight);
                
                grMaxContentHeight = self.contentSize.height;
            }
            else
            {
                CGFloat maxTime = time;
                
                for (int i=0; i<self.sliderArray.count; i++)
                {
                    YJLVideoRangeSlider* slider = [self.sliderArray objectAtIndex:i];
                    CGFloat time_ = slider.rightPosition;
                    
                    if (time_ >= maxTime)
                        maxTime = time_;
                }
                
                self.totalTime = maxTime;
                
                if (self.sliderArray.count > 0)
                    self.contentSize = CGSizeMake(self.scaleFactor*grZoomScale*self.totalTime, self.sliderArray.count*grSliderHeight);
                else
                    self.contentSize = CGSizeMake(self.scaleFactor*grZoomScale*self.totalTime, grSliderHeight);
                
                grMaxContentHeight = self.contentSize.height;
            }
            
            if ([self.timelineDelegate respondsToSelector:@selector(updateTotalTime)])
            {
                [self.timelineDelegate updateTotalTime];
            }
        }
    }
}

-(void) skipToEnd
{
    YJLVideoRangeSlider* selectedSlider = [self.sliderArray objectAtIndex:gnSelectedObjectIndex];
    
    if (selectedSlider.isGrouped)
    {
        BOOL isFirst = YES;
        CGFloat minLeft = 0.0f;
        
        for (int i=0; i<self.sliderArray.count; i++)
        {
            YJLVideoRangeSlider* slider = [self.sliderArray objectAtIndex:i];
            
            if (slider.isGrouped)
            {
                if (isFirst)
                {
                    minLeft = slider.leftPosition;
                    isFirst = NO;
                }
                else
                {
                    if (minLeft > slider.leftPosition)
                    {
                        minLeft = slider.leftPosition;
                    }
                }
            }
        }

        CGFloat left = minLeft;
        
        for (int i=0; i<self.sliderArray.count; i++)
        {
            YJLVideoRangeSlider* slider = [self.sliderArray objectAtIndex:i];

            if (!slider.isGrouped && (slider.rightPosition > left))
            {
                left = slider.rightPosition;
            }
        }
        
        if (left > minLeft)
        {
            for (int i=0; i<self.sliderArray.count; i++)
            {
                YJLVideoRangeSlider* slider = [self.sliderArray objectAtIndex:i];
                
                if (slider.isGrouped)
                {
                    [slider changeSliderByLeftPosition:((minLeft - left) * selectedSlider.frame_width / selectedSlider.durationSeconds)];
                }
            }
        }
        
        minLeft = selectedSlider.leftPosition;
        
        for (int i=0; i<self.sliderArray.count; i++)
        {
            YJLVideoRangeSlider* slider = [self.sliderArray objectAtIndex:i];
            
            if (slider.leftPosition < minLeft)
            {
                minLeft = slider.leftPosition;
            }
        }
        
        if (minLeft > 0.0f)
        {
            for (int i=0; i<self.sliderArray.count; i++)
            {
                YJLVideoRangeSlider* slider = [self.sliderArray objectAtIndex:i];
                
                CGFloat deltaPosition = minLeft * selectedSlider.frame_width / selectedSlider.durationSeconds;
                
                [slider changeSliderByLeftPosition:deltaPosition];
            }
        }
        
        CGFloat time = selectedSlider.rightPosition;
        
        if (time > self.totalTime)
        {
            self.totalTime = time;
            
            if (self.sliderArray.count > 0)
                self.contentSize = CGSizeMake(self.scaleFactor*grZoomScale*self.totalTime, self.sliderArray.count*grSliderHeight);
            else
                self.contentSize = CGSizeMake(self.scaleFactor*grZoomScale*self.totalTime, grSliderHeight);
            
            grMaxContentHeight = self.contentSize.height;
        }
        else
        {
            CGFloat maxTime = time;
            
            for (int i=0; i<self.sliderArray.count; i++)
            {
                YJLVideoRangeSlider* slider = [self.sliderArray objectAtIndex:i];
                
                CGFloat time_ = slider.rightPosition;
                
                if (time_ >= maxTime)
                    maxTime = time_;
            }
            
            self.totalTime = maxTime;
            
            if (self.sliderArray.count > 0)
                self.contentSize = CGSizeMake(self.scaleFactor*grZoomScale*self.totalTime, self.sliderArray.count*grSliderHeight);
            else
                self.contentSize = CGSizeMake(self.scaleFactor*grZoomScale*self.totalTime, grSliderHeight);
            
            grMaxContentHeight = self.contentSize.height;
        }
        
        if ([self.timelineDelegate respondsToSelector:@selector(updateTotalTime)])
        {
            [self.timelineDelegate updateTotalTime];
        }
    }
    else
    {
        CGFloat left = selectedSlider.leftPosition;
        
        for (int i=0; i<self.sliderArray.count; i++)
        {
            if (i != gnSelectedObjectIndex)
            {
                YJLVideoRangeSlider* slider = [self.sliderArray objectAtIndex:i];
                
                if (slider.rightPosition > left)
                    left = slider.rightPosition;
            }
        }
        
        CGFloat right = left + (selectedSlider.rightPosition - selectedSlider.leftPosition);
        
        left = left * selectedSlider.frame_width / selectedSlider.durationSeconds;
        right = right * selectedSlider.frame_width / selectedSlider.durationSeconds;
        [selectedSlider changeSliderPosition:left right:right];
        
        CGFloat minLeft = selectedSlider.rightPosition;
        
        for (int i=0; i<self.sliderArray.count; i++)
        {
            YJLVideoRangeSlider* slider = [self.sliderArray objectAtIndex:i];
            
            if (slider.leftPosition <= minLeft)
                minLeft = slider.leftPosition;
        }
        
        if (minLeft != 0.0f)
        {
            minLeft = minLeft * selectedSlider.frame_width / selectedSlider.durationSeconds;
            
            for (int i=0; i<self.sliderArray.count; i++)
            {
                YJLVideoRangeSlider* slider = [self.sliderArray objectAtIndex:i];
                [slider changeSliderByLeftPosition:minLeft];
            }
        }
        
        CGFloat time = selectedSlider.rightPosition;
        
        if (time > self.totalTime)
        {
            self.totalTime = time;
            
            if (self.sliderArray.count > 0)
                self.contentSize = CGSizeMake(self.scaleFactor*grZoomScale*self.totalTime, self.sliderArray.count*grSliderHeight);
            else
                self.contentSize = CGSizeMake(self.scaleFactor*grZoomScale*self.totalTime, grSliderHeight);
            
            grMaxContentHeight = self.contentSize.height;
        }
        else
        {
            CGFloat maxTime = time;
            
            for (int i=0; i<self.sliderArray.count; i++)
            {
                YJLVideoRangeSlider* slider = [self.sliderArray objectAtIndex:i];
                
                CGFloat time_ = slider.rightPosition;
                
                if (time_ >= maxTime)
                    maxTime = time_;
            }
            
            self.totalTime = maxTime;
            
            if (self.sliderArray.count > 0)
                self.contentSize = CGSizeMake(self.scaleFactor*grZoomScale*self.totalTime, self.sliderArray.count*grSliderHeight);
            else
                self.contentSize = CGSizeMake(self.scaleFactor*grZoomScale*self.totalTime, grSliderHeight);
            
            grMaxContentHeight = self.contentSize.height;
        }
        
        if ([self.timelineDelegate respondsToSelector:@selector(updateTotalTime)])
        {
            [self.timelineDelegate updateTotalTime];
        }
    }
}

-(void) editTime
{
    YJLVideoRangeSlider* slider = [self.sliderArray objectAtIndex:gnSelectedObjectIndex];

    TimePickerView *picker = [[TimePickerView alloc] initWithTitle:@"Default"];
    picker.delegate = self;
    [picker setComponents];
    [picker setMediaType:slider.media_type];
    CGFloat time = slider.rightPosition - slider.leftPosition;
    [picker setTime:time];
    
    [picker initializePicker];
    
    if (self.customModalView != nil)
    {
        [self.customModalView hideCustomModalView];
        self.customModalView = nil;
    }
    
    self.customModalView = [[CustomModalView alloc] initWithView:picker bgColor:[UIColor whiteColor]];
    self.customModalView.delegate = self;
    self.customModalView.dismissButtonRight = YES;
    [self.customModalView show];
}

-(void) editSpeed
{
    if ([self.timelineDelegate respondsToSelector:@selector(onEditSpeed)])
    {
        [self.timelineDelegate onEditSpeed];
    }
}

-(void) editJog
{
    if ([self.timelineDelegate respondsToSelector:@selector(onEditJog)])
    {
        [self.timelineDelegate onEditJog];
    }
}

-(void) editTrim
{
    if ([self.timelineDelegate respondsToSelector:@selector(onEditTrim)])
    {
        [self.timelineDelegate onEditTrim];
    }
}

-(void) removeMusic
{
    if ([self.timelineDelegate respondsToSelector:@selector(onRemoveMusic)])
    {
        [self.timelineDelegate onRemoveMusic];
    }
}

-(void) editVolume
{
    if ([self.timelineDelegate respondsToSelector:@selector(onEditVolume)])
    {
        [self.timelineDelegate onEditVolume];
    }
}


#pragma mark -
#pragma mark - TimePickerViewDelegate

-(void) didCancel
{
    if (self.customModalView != nil)
    {
        [self.customModalView hideCustomModalView];
        self.customModalView = nil;
    }
}
-(void) timePickerViewSeleted:(CGFloat) time
{
    YJLVideoRangeSlider* selectedSlider = [self.sliderArray objectAtIndex:gnSelectedObjectIndex];
    
    CGFloat left = selectedSlider.leftPosition * selectedSlider.frame_width / selectedSlider.durationSeconds;
    CGFloat right = (time + selectedSlider.leftPosition) * selectedSlider.frame_width / selectedSlider.durationSeconds;
    [selectedSlider changeSliderPosition:left right:right];
    
    time = selectedSlider.rightPosition;
    
    if (time > self.totalTime)
    {
        self.totalTime = time;
        
        if (self.sliderArray.count > 0)
            self.contentSize = CGSizeMake(self.scaleFactor*grZoomScale*self.totalTime, self.sliderArray.count*grSliderHeight);
        else
            self.contentSize = CGSizeMake(self.scaleFactor*grZoomScale*self.totalTime, grSliderHeight);
        
        grMaxContentHeight = self.contentSize.height;
    }
    else
    {
        CGFloat maxTime = time;
        
        for (int i=0; i<self.sliderArray.count; i++)
        {
            YJLVideoRangeSlider* slider = [self.sliderArray objectAtIndex:i];
            CGFloat time_ = slider.rightPosition;
            
            if (time_ >= maxTime)
                maxTime = time_;
        }
        
        self.totalTime = maxTime;
        
        if (self.sliderArray.count > 0)
            self.contentSize = CGSizeMake(self.scaleFactor*grZoomScale*self.totalTime, self.sliderArray.count*grSliderHeight);
        else
            self.contentSize = CGSizeMake(self.scaleFactor*grZoomScale*self.totalTime, grSliderHeight);
        
        grMaxContentHeight = self.contentSize.height;
    }
    
    CGFloat minDuration = self.totalTime;
    
    for (int i=0; i<self.sliderArray.count; i++)
    {
        YJLVideoRangeSlider* slider = [self.sliderArray objectAtIndex:i];
        
        if (minDuration > (slider.rightPosition - slider.leftPosition))
        {
            minDuration = (slider.rightPosition - slider.leftPosition);
        }
    }
    
    CGFloat minWidth = 0.0f;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        minWidth = IPHONE_TIMELINE_WIDTH_MIN;
    else
        minWidth = IPAD_TIMELINE_WIDTH_MIN;
    
    self.scaleFactor = minWidth / minDuration;
    
    for (int i=0; i<self.sliderArray.count; i++)
    {
        YJLVideoRangeSlider* slider = [self.sliderArray objectAtIndex:i];
        [slider changeSliderFrame:self.scaleFactor*grZoomScale];
        [slider drawRuler];
    }
    
    if (self.sliderArray.count > 0)
        self.contentSize = CGSizeMake(self.scaleFactor*grZoomScale*self.totalTime, self.sliderArray.count*grSliderHeight);
    else
        self.contentSize = CGSizeMake(self.scaleFactor*grZoomScale*self.totalTime, grSliderHeight);
    
    if ([self.timelineDelegate respondsToSelector:@selector(updateTotalTime)])
    {
        [self.timelineDelegate updateTotalTime];
    }
    
    if (self.customModalView != nil)
    {
        [self.customModalView hideCustomModalView];
        self.customModalView = nil;
    }
}


#pragma mark -
#pragma mark - Zoom In/Out

- (void)updateZoom
{
    for (int i=0; i<self.sliderArray.count; i++)
    {
        YJLVideoRangeSlider* slider = [self.sliderArray objectAtIndex:i];
        [slider changeSliderFrame:self.scaleFactor*grZoomScale];
        slider.frame = CGRectMake(slider.frame.origin.x, grSliderHeight*(self.sliderArray.count-1-i), slider.frame.size.width, grSliderHeight);
        slider.yPosition = slider.center.y;
        [slider changeSliderYPosition];
    }
    
    if (self.sliderArray.count > 0)
        self.contentSize = CGSizeMake(self.scaleFactor*grZoomScale*self.totalTime, self.sliderArray.count*grSliderHeight);
    else
        self.contentSize = CGSizeMake(self.scaleFactor*grZoomScale*self.totalTime, grSliderHeight);
    
    grMaxContentHeight = self.contentSize.height;
    
    
    /* change self frame */
    if (self.sliderArray.count > gnVisibleMaxCount)
    {
        if (self.sliderArray.count*grSliderHeight >= gnVisibleMaxCount*grSliderHeightMax)
        {
            if ([self.timelineDelegate respondsToSelector:@selector(hideVerticalView:)])
            {
                [self.timelineDelegate hideVerticalView:NO];
            }

            self.frame = CGRectMake(self.frame.origin.x, bottomY - gnVisibleMaxCount*grSliderHeightMax, self.frame.size.width, gnVisibleMaxCount*grSliderHeightMax);
        }
        else
        {
            if ([self.timelineDelegate respondsToSelector:@selector(hideVerticalView:)])
            {
                [self.timelineDelegate hideVerticalView:YES];
            }

            self.frame = CGRectMake(self.frame.origin.x, bottomY - self.sliderArray.count*grSliderHeight, self.frame.size.width, self.sliderArray.count*grSliderHeight);
        }
    }
    else
    {
        self.frame = CGRectMake(self.frame.origin.x, bottomY - self.sliderArray.count*grSliderHeight, self.frame.size.width, self.sliderArray.count*grSliderHeight);
    }
    
    if ([self.timelineDelegate respondsToSelector:@selector(updateTotalTime)])
    {
        [self.timelineDelegate updateTotalTime];
    }
}


- (void)drawRect:(CGRect)rect
{
    [[UIColor lightGrayColor] set];

    //Horizontal dash
    for(int i=0; i<=self.sliderArray.count; i++)
    {
        UIBezierPath *bezier = [[UIBezierPath alloc] init];
        [bezier moveToPoint:CGPointMake(self.contentOffset.x, i*grSliderHeight)];
        [bezier addLineToPoint:CGPointMake(self.contentOffset.x + self.bounds.size.width, i*grSliderHeight)];
        [bezier setLineWidth:0.5f];
        [bezier setLineCapStyle:kCGLineCapSquare];
        
        CGFloat dashPattern[2] = {6.0f, 3.0f};
        [bezier setLineDash:dashPattern count:2 phase:0];
        
        [bezier stroke];
    }
    
    [[UIColor yellowColor] set];
    
    UIBezierPath *startLine = [[UIBezierPath alloc] init];
    [startLine moveToPoint:CGPointMake(0.0f, 0.0f)];
    [startLine addLineToPoint:CGPointMake(0.0f, self.sliderArray.count*grSliderHeight)];
    [startLine setLineWidth:2.0f];
    [startLine setLineCapStyle:kCGLineCapSquare];
    [startLine stroke];

    UIBezierPath *endLine = [[UIBezierPath alloc] init];
    [endLine moveToPoint:CGPointMake(self.contentSize.width - 2.0f, 0.0f)];
    [endLine addLineToPoint:CGPointMake(self.contentSize.width - 2.0f, self.sliderArray.count*grSliderHeight)];
    [endLine setLineWidth:2.0f];
    [endLine setLineCapStyle:kCGLineCapSquare];
    [endLine stroke];
}


#pragma mark - 
#pragma mark - Timeline Group

-(void) onHandleGroup
{
    YJLVideoRangeSlider* slider = [self.sliderArray objectAtIndex:gnSelectedObjectIndex];

    slider.isGrouped = !slider.isGrouped;
    
    if (slider.isGrouped)
    {
        slider.groupImageView.hidden = NO;
    }
    else
    {
        slider.groupImageView.hidden = YES;
    }
    
    if ([self.timelineDelegate respondsToSelector:@selector(timelineGrouped:isGrouped:)])
    {
        [self.timelineDelegate timelineGrouped:gnSelectedObjectIndex isGrouped:slider.isGrouped];
    }
}

-(void) onHandleUnGroupAll
{
    for (int i=0; i<self.sliderArray.count; i++)
    {
        YJLVideoRangeSlider* slider = [self.sliderArray objectAtIndex:i];

        slider.isGrouped = NO;
        slider.groupImageView.hidden = YES;
    }
    
    if ([self.timelineDelegate respondsToSelector:@selector(timelineUnGroupAll:)])
    {
        [self.timelineDelegate timelineUnGroupAll];
    }
}

-(void) onHandleAlignLeft
{
    YJLVideoRangeSlider* selectedSlider = [self.sliderArray objectAtIndex:gnSelectedObjectIndex];
    
    for (int i=0; i<self.sliderArray.count; i++)
    {
        YJLVideoRangeSlider* slider = [self.sliderArray objectAtIndex:i];

        CGFloat deltaPosition = 0.0f;
        
        if (slider.isGrouped)
        {
            deltaPosition = (slider.leftPosition - selectedSlider.leftPosition) * selectedSlider.frame_width / selectedSlider.durationSeconds;
            
            [slider changeSliderByLeftPosition:deltaPosition];
        }
    }
    
    CGFloat minLeft = selectedSlider.leftPosition;
    
    for (int i=0; i<self.sliderArray.count; i++)
    {
        YJLVideoRangeSlider* slider = [self.sliderArray objectAtIndex:i];
        
        if (slider.leftPosition < minLeft)
        {
            minLeft = slider.leftPosition;
        }
    }
    
    if (minLeft > 0.0f)
    {
        for (int i=0; i<self.sliderArray.count; i++)
        {
            YJLVideoRangeSlider* slider = [self.sliderArray objectAtIndex:i];
            
            CGFloat deltaPosition = minLeft * selectedSlider.frame_width / selectedSlider.durationSeconds;
            
            [slider changeSliderByLeftPosition:deltaPosition];
        }
    }
    
    CGFloat time = selectedSlider.rightPosition;
    
    if (time > self.totalTime)
    {
        self.totalTime = time;
        
        if (self.sliderArray.count > 0)
            self.contentSize = CGSizeMake(self.scaleFactor*grZoomScale*self.totalTime, self.sliderArray.count*grSliderHeight);
        else
            self.contentSize = CGSizeMake(self.scaleFactor*grZoomScale*self.totalTime, grSliderHeight);
        
        grMaxContentHeight = self.contentSize.height;
    }
    else
    {
        CGFloat maxTime = time;
        
        for (int i=0; i<self.sliderArray.count; i++)
        {
            YJLVideoRangeSlider* slider = [self.sliderArray objectAtIndex:i];
            CGFloat time_ = slider.rightPosition;
            
            if (time_ >= maxTime)
                maxTime = time_;
        }
        
        self.totalTime = maxTime;
        
        if (self.sliderArray.count > 0)
            self.contentSize = CGSizeMake(self.scaleFactor*grZoomScale*self.totalTime, self.sliderArray.count*grSliderHeight);
        else
            self.contentSize = CGSizeMake(self.scaleFactor*grZoomScale*self.totalTime, grSliderHeight);
        
        grMaxContentHeight = self.contentSize.height;
    }
    
    if ([self.timelineDelegate respondsToSelector:@selector(updateTotalTime)])
    {
        [self.timelineDelegate updateTotalTime];
    }
}

-(void) onHandleAlignRight
{
    YJLVideoRangeSlider* selectedSlider = [self.sliderArray objectAtIndex:gnSelectedObjectIndex];
    
    for (int i=0; i<self.sliderArray.count; i++)
    {
        YJLVideoRangeSlider* slider = [self.sliderArray objectAtIndex:i];
        
        if (slider.isGrouped)
        {
            CGFloat deltaPosition = (slider.rightPosition - selectedSlider.rightPosition) * selectedSlider.frame_width / selectedSlider.durationSeconds;
            
            [slider changeSliderByLeftPosition:deltaPosition];
        }
    }
    
    CGFloat minLeft = selectedSlider.leftPosition;
    
    for (int i=0; i<self.sliderArray.count; i++)
    {
        YJLVideoRangeSlider* slider = [self.sliderArray objectAtIndex:i];
        
        if (slider.leftPosition < minLeft)
        {
            minLeft = slider.leftPosition;
        }
    }
    
    if (minLeft > 0.0f)
    {
        for (int i=0; i<self.sliderArray.count; i++)
        {
            YJLVideoRangeSlider* slider = [self.sliderArray objectAtIndex:i];
            
            CGFloat deltaPosition = minLeft * selectedSlider.frame_width / selectedSlider.durationSeconds;
            
            [slider changeSliderByLeftPosition:deltaPosition];
        }
    }

    CGFloat time = selectedSlider.rightPosition;
    
    if (time > self.totalTime)
    {
        self.totalTime = time;
        
        if (self.sliderArray.count > 0)
            self.contentSize = CGSizeMake(self.scaleFactor*grZoomScale*self.totalTime, self.sliderArray.count*grSliderHeight);
        else
            self.contentSize = CGSizeMake(self.scaleFactor*grZoomScale*self.totalTime, grSliderHeight);
        
        grMaxContentHeight = self.contentSize.height;
    }
    else
    {
        CGFloat maxTime = time;
        
        for (int i=0; i<self.sliderArray.count; i++)
        {
            YJLVideoRangeSlider* slider = [self.sliderArray objectAtIndex:i];
            CGFloat time_ = slider.rightPosition;
            
            if (time_ >= maxTime)
                maxTime = time_;
        }
        
        self.totalTime = maxTime;
        
        if (self.sliderArray.count > 0)
            self.contentSize = CGSizeMake(self.scaleFactor*grZoomScale*self.totalTime, self.sliderArray.count*grSliderHeight);
        else
            self.contentSize = CGSizeMake(self.scaleFactor*grZoomScale*self.totalTime, grSliderHeight);
        
        grMaxContentHeight = self.contentSize.height;
    }
    
    if ([self.timelineDelegate respondsToSelector:@selector(updateTotalTime)])
    {
        [self.timelineDelegate updateTotalTime];
    }
}

-(void) onHandleGroupStack
{
    YJLVideoRangeSlider* selectedSlider = [self.sliderArray objectAtIndex:gnSelectedObjectIndex];
    
    CGFloat leftPosition = 0.0f;
    BOOL isFirst = YES;
    
    for (int i=0; i<self.sliderArray.count; i++)
    {
        YJLVideoRangeSlider* slider = [self.sliderArray objectAtIndex:i];
        
        if (slider.isGrouped)
        {
            if (isFirst)
            {
                leftPosition = slider.leftPosition;
                isFirst = NO;
            }
            else
            {
                CGFloat leftPos = leftPosition  * slider.frame_width / slider.durationSeconds;
                CGFloat rightPos = (leftPosition + slider.rightPosition - slider.leftPosition)  * slider.frame_width / slider.durationSeconds;
                
                [slider changeSliderPosition:leftPos right:rightPos];
            }
        }
    }
    
    ////////////////// 2015/09/24 /////////////////////
    
    CGFloat minLeft = selectedSlider.leftPosition;
    
    for (int i=0; i<self.sliderArray.count; i++)
    {
        YJLVideoRangeSlider* slider = [self.sliderArray objectAtIndex:i];
        
        if (slider.leftPosition < minLeft)
        {
            minLeft = slider.leftPosition;
        }
    }
    
    if (minLeft > 0.0f)
    {
        for (int i=0; i<self.sliderArray.count; i++)
        {
            YJLVideoRangeSlider* slider = [self.sliderArray objectAtIndex:i];
            
            CGFloat deltaPosition = minLeft * selectedSlider.frame_width / selectedSlider.durationSeconds;
            
            [slider changeSliderByLeftPosition:deltaPosition];
        }
    }
    
    /////////////////////////////////////////////////////
    
    CGFloat time = selectedSlider.rightPosition;
    
    if (time > self.totalTime)
    {
        self.totalTime = time;
        
        if (self.sliderArray.count > 0)
            self.contentSize = CGSizeMake(self.scaleFactor*grZoomScale*self.totalTime, self.sliderArray.count*grSliderHeight);
        else
            self.contentSize = CGSizeMake(self.scaleFactor*grZoomScale*self.totalTime, grSliderHeight);
        
        grMaxContentHeight = self.contentSize.height;
    }
    else
    {
        CGFloat maxTime = time;
        
        for (int i=0; i<self.sliderArray.count; i++)
        {
            YJLVideoRangeSlider* slider = [self.sliderArray objectAtIndex:i];
            CGFloat time_ = slider.rightPosition;
            
            if (time_ >= maxTime)
                maxTime = time_;
        }
        
        self.totalTime = maxTime;
        
        if (self.sliderArray.count > 0)
            self.contentSize = CGSizeMake(self.scaleFactor*grZoomScale*self.totalTime, self.sliderArray.count*grSliderHeight);
        else
            self.contentSize = CGSizeMake(self.scaleFactor*grZoomScale*self.totalTime, grSliderHeight);
        
        grMaxContentHeight = self.contentSize.height;
    }
    
    if ([self.timelineDelegate respondsToSelector:@selector(updateTotalTime)])
    {
        [self.timelineDelegate updateTotalTime];
    }
}

-(void) onHandleGroupStagger
{
    CGFloat rightPosition = 0.0f;
    BOOL isFirst = YES;
    
    for (int i=0; i<self.sliderArray.count; i++)
    {
        YJLVideoRangeSlider* slider = [self.sliderArray objectAtIndex:i];
        
        if (slider.isGrouped)
        {
            if (isFirst)
            {
                rightPosition = slider.rightPosition;
                isFirst = NO;
            }
            else
            {
                CGFloat leftPosition = (rightPosition - slider.leftPosition)  * slider.frame_width / slider.durationSeconds;
                
                [slider changeSliderByLeftPosition:-leftPosition];
                
                rightPosition = slider.rightPosition;
            }
        }
    }
    
    ////////////////// 2015/09/24 /////////////////////
    
    YJLVideoRangeSlider* selectedSlider = [self.sliderArray objectAtIndex:gnSelectedObjectIndex];

    CGFloat minLeft = selectedSlider.leftPosition;
    
    for (int i=0; i<self.sliderArray.count; i++)
    {
        YJLVideoRangeSlider* slider = [self.sliderArray objectAtIndex:i];
        
        if (slider.leftPosition < minLeft)
        {
            minLeft = slider.leftPosition;
        }
    }
    
    if (minLeft > 0.0f)
    {
        for (int i=0; i<self.sliderArray.count; i++)
        {
            YJLVideoRangeSlider* slider = [self.sliderArray objectAtIndex:i];
            
            CGFloat deltaPosition = minLeft * selectedSlider.frame_width / selectedSlider.durationSeconds;
            
            [slider changeSliderByLeftPosition:deltaPosition];
        }
    }
    
    /////////////////////////////////////////////////////
    
    if (rightPosition > self.totalTime)
    {
        self.totalTime = rightPosition;
        
        if (self.sliderArray.count > 0)
            self.contentSize = CGSizeMake(self.scaleFactor*grZoomScale*self.totalTime, self.sliderArray.count*grSliderHeight);
        else
            self.contentSize = CGSizeMake(self.scaleFactor*grZoomScale*self.totalTime, grSliderHeight);
        
        grMaxContentHeight = self.contentSize.height;
    }
    else
    {
        CGFloat maxTime = rightPosition;
        
        for (int i=0; i<self.sliderArray.count; i++)
        {
            YJLVideoRangeSlider* slider = [self.sliderArray objectAtIndex:i];
            CGFloat time_ = slider.rightPosition;
            
            if (time_ >= maxTime)
                maxTime = time_;
        }
        
        self.totalTime = maxTime;
        
        if (self.sliderArray.count > 0)
            self.contentSize = CGSizeMake(self.scaleFactor*grZoomScale*self.totalTime, self.sliderArray.count*grSliderHeight);
        else
            self.contentSize = CGSizeMake(self.scaleFactor*grZoomScale*self.totalTime, grSliderHeight);
        
        grMaxContentHeight = self.contentSize.height;
    }
    
    if ([self.timelineDelegate respondsToSelector:@selector(updateTotalTime)])
    {
        [self.timelineDelegate updateTotalTime];
    }
}

-(void) onHandleGroupFlipBack
{
    NSMutableArray* groupIndexArray = [[NSMutableArray alloc] init];
    
    for (int i=0; i<self.sliderArray.count; i++)
    {
        YJLVideoRangeSlider* slider = [self.sliderArray objectAtIndex:i];

        if (slider.isGrouped)
            [groupIndexArray addObject:[NSNumber numberWithInt:i]];
    }
    
    if (groupIndexArray.count>1)
    {
        int nMiddleIndex = (int) groupIndexArray.count / 2;
        
        for (int i=0; i<nMiddleIndex; i++)
        {
            int nBackExchangeIndex = [[groupIndexArray objectAtIndex:i] intValue];
            int nFrontExchangeIndex = [[groupIndexArray objectAtIndex:(groupIndexArray.count-1-i)] intValue];
            
            //exchange back to front
            YJLVideoRangeSlider* backSlider = [self.sliderArray objectAtIndex:nBackExchangeIndex];
            [self.sliderArray removeObjectAtIndex:nBackExchangeIndex];
            [self.sliderArray insertObject:backSlider atIndex:nFrontExchangeIndex];
            
            if ([self.timelineDelegate respondsToSelector:@selector(exchangedObjects:toIndex:)])
                [self.timelineDelegate exchangedObjects:nBackExchangeIndex toIndex:nFrontExchangeIndex];
            
            //exchange (front - 1) to back
            YJLVideoRangeSlider* frontSlider = [self.sliderArray objectAtIndex:nFrontExchangeIndex-1];
            [self.sliderArray removeObjectAtIndex:nFrontExchangeIndex-1];
            [self.sliderArray insertObject:frontSlider atIndex:nBackExchangeIndex];
            
            if ([self.timelineDelegate respondsToSelector:@selector(exchangedObjects:toIndex:)])
                [self.timelineDelegate exchangedObjects:nFrontExchangeIndex-1 toIndex:nBackExchangeIndex];
            
            if ([self.timelineDelegate respondsToSelector:@selector(timelineSelected:)])
                [self.timelineDelegate timelineSelected:nBackExchangeIndex];
        }
        
        for (int i=0; i<self.sliderArray.count; i++)
        {
            YJLVideoRangeSlider* slider = [self.sliderArray objectAtIndex:i];
            slider.frame = CGRectMake(slider.frame.origin.x, grSliderHeight*(self.sliderArray.count-1-i), slider.frame.size.width, grSliderHeight);
            slider.objectIndex = i;
            slider.yPosition = slider.center.y;
            [slider changeSliderYPosition];
        }
    }
    
    [groupIndexArray removeAllObjects];
    groupIndexArray = nil;
}

-(void) changeGroupPosition:(CGFloat) deltaPosition
{
    for (int i=0; i<self.sliderArray.count; i++)
    {
        YJLVideoRangeSlider* slider = [self.sliderArray objectAtIndex:i];

        if (slider.isGrouped && (i != gnSelectedObjectIndex))
        {
            [slider changeSliderByLeftPosition:-deltaPosition];
        }
    }
}


@end
