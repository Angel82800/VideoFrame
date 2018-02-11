//
//  TimelineHorizontalView.m
//  VideoFrame
//
//  Created by Yinjing Li on 7/30/14.
//  Copyright (c) 2014 Yinjing Li. All rights reserved.
//

#import "TimelineHorizontalView.h"

@implementation TimelineHorizontalView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        [self setUserInteractionEnabled:YES];
        
        self.backgroundColor = [UIColor lightGrayColor];
        self.layer.borderColor = [UIColor blackColor].CGColor;
        self.layer.borderWidth = 1.0f;

        /* horizontal UIScrollView */
        self.horizontalScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.bounds.size.width, grSliderHeightMax*0.8f)];
        [self.horizontalScrollView setBackgroundColor:[UIColor blackColor]];
        [self.horizontalScrollView setIndicatorStyle:UIScrollViewIndicatorStyleWhite];
        [self.horizontalScrollView setScrollEnabled:YES];
        [self.horizontalScrollView setDelegate:self];
        [self addSubview:self.horizontalScrollView];
        
        /* background image view */
        self.bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(grSliderHeightMax*1.0f, 0.0f, self.bounds.size.width - grSliderHeightMax*2.0f, grSliderHeightMax*0.8f)];
        [self.bgImageView setBackgroundColor:[UIColor clearColor]];
        [self.bgImageView setImage:[UIImage imageNamed:@"horizontalSliderBg"]];
        [self addSubview:self.bgImageView];
        
        /* left arrow button */
        self.leftArrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(grSliderHeightMax*0.1f, 0.0f, grSliderHeightMax*0.8f, grSliderHeightMax*0.8f)];
        [self.leftArrowImageView setBackgroundColor:[UIColor clearColor]];
        [self.leftArrowImageView setImage:[UIImage imageNamed:@"left_arrow"]];
        [self.leftArrowImageView setUserInteractionEnabled:YES];
        [self addSubview:self.leftArrowImageView];
        
        /* right arrow button */
        self.rightArrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.bounds.size.width - grSliderHeightMax*0.9f, 0.0f, grSliderHeightMax*0.8f, grSliderHeightMax*0.8f)];
        [self.rightArrowImageView setBackgroundColor:[UIColor clearColor]];
        [self.rightArrowImageView setImage:[UIImage imageNamed:@"right_arrow"]];
        [self.rightArrowImageView setUserInteractionEnabled:YES];
        [self addSubview:self.rightArrowImageView];
        
        if (((gnTemplateIndex == TEMPLATE_SQUARE) || (gnTemplateIndex == TEMPLATE_PORTRAIT)) && ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone))
        {
            /* ZoomOut imageView */
            self.zoomOutImageView = [[UIImageView alloc] initWithFrame:CGRectMake(grSliderHeightMax*1.1f, grSliderHeightMax, grSliderHeightMax*0.3f, grSliderHeightMax*0.3f)];
            [self.zoomOutImageView setBackgroundColor:[UIColor clearColor]];
            [self.zoomOutImageView setImage:[UIImage imageNamed:@"ZoomOut"]];
            [self.zoomOutImageView setUserInteractionEnabled:YES];
            [self addSubview:self.zoomOutImageView];
            
            /* ZoomIn imageView */
            self.zoomInImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.bounds.size.width - grSliderHeightMax*0.65f, grSliderHeightMax, grSliderHeightMax*0.3f, grSliderHeightMax*0.3f)];
            [self.zoomInImageView setBackgroundColor:[UIColor clearColor]];
            [self.zoomInImageView setImage:[UIImage imageNamed:@"ZoomIn"]];
            [self.zoomInImageView setUserInteractionEnabled:YES];
            [self addSubview:self.zoomInImageView];
            
            self.zoomSlider = [[UISlider alloc] initWithFrame:CGRectMake(grSliderHeightMax*1.5f, grSliderHeightMax*0.8f, self.bounds.size.width - grSliderHeightMax*2.25f, grSliderHeightMax*0.7f)];
            [self.zoomSlider setBackgroundColor:[UIColor clearColor]];
            [self.zoomSlider setMinimumTrackImage:[UIImage imageNamed:@"slider_min"] forState:UIControlStateNormal];
            [self.zoomSlider setMaximumTrackImage:[UIImage imageNamed:@"slider_max"] forState:UIControlStateNormal];
            [self.zoomSlider setThumbImage:[UIImage imageNamed:@"slider_thumb_ipad"] forState:UIControlStateNormal];
            [self.zoomSlider setMinimumValue:0.1f];
            [self.zoomSlider setMaximumValue:2.0f];
            [self.zoomSlider setValue:1.0f];
            [self.zoomSlider addTarget:self action:@selector(changeZoomSliderValue) forControlEvents:UIControlEventValueChanged];
            [self addSubview:self.zoomSlider];
            
            self.zoomTypeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [self.zoomTypeBtn setBackgroundColor:[UIColor clearColor]];
            [self.zoomTypeBtn setFrame:CGRectMake(grSliderHeightMax*0.25f, grSliderHeightMax*0.9f, grSliderHeightMax*0.5f, grSliderHeightMax*0.5f)];
            [self.zoomTypeBtn setImage:[UIImage imageNamed:@"zoom_both"] forState:UIControlStateNormal];
            [self.zoomTypeBtn addTarget:self action:@selector(actionZoomType:) forControlEvents:UIControlEventTouchUpInside];
            self.zoomTypeBtn.tag = ZOOM_BOTH;
            [self addSubview:self.zoomTypeBtn];
        }
        else
        {
            /* ZoomOut imageView */
            self.zoomOutImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.bounds.size.width*0.5f + grSliderHeightMax*0.35f, grSliderHeightMax, grSliderHeightMax*0.3f, grSliderHeightMax*0.3f)];
            [self.zoomOutImageView setBackgroundColor:[UIColor clearColor]];
            [self.zoomOutImageView setImage:[UIImage imageNamed:@"ZoomOut"]];
            [self.zoomOutImageView setUserInteractionEnabled:YES];
            [self addSubview:self.zoomOutImageView];
            
            /* ZoomIn imageView */
            self.zoomInImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.bounds.size.width - grSliderHeightMax*0.65f, grSliderHeightMax, grSliderHeightMax*0.3f, grSliderHeightMax*0.3f)];
            [self.zoomInImageView setBackgroundColor:[UIColor clearColor]];
            [self.zoomInImageView setImage:[UIImage imageNamed:@"ZoomIn"]];
            [self.zoomInImageView setUserInteractionEnabled:YES];
            [self addSubview:self.zoomInImageView];
            
            self.zoomSlider = [[UISlider alloc] initWithFrame:CGRectMake(self.bounds.size.width*0.5f + grSliderHeightMax*0.9f, grSliderHeightMax*0.8f, self.bounds.size.width*0.5f - grSliderHeightMax*1.8f, grSliderHeightMax*0.7f)];
            [self.zoomSlider setBackgroundColor:[UIColor clearColor]];
            [self.zoomSlider setMinimumTrackImage:[UIImage imageNamed:@"slider_min"] forState:UIControlStateNormal];
            [self.zoomSlider setMaximumTrackImage:[UIImage imageNamed:@"slider_max"] forState:UIControlStateNormal];
            [self.zoomSlider setThumbImage:[UIImage imageNamed:@"slider_thumb_ipad"] forState:UIControlStateNormal];
            [self.zoomSlider setMinimumValue:0.1f];
            [self.zoomSlider setMaximumValue:2.0f];
            [self.zoomSlider setValue:1.0f];
            [self.zoomSlider addTarget:self action:@selector(changeZoomSliderValue) forControlEvents:UIControlEventValueChanged];
            [self addSubview:self.zoomSlider];
            
            self.zoomTypeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [self.zoomTypeBtn setBackgroundColor:[UIColor clearColor]];
            [self.zoomTypeBtn setFrame:CGRectMake(self.bounds.size.width*0.5f - grSliderHeightMax, grSliderHeightMax*0.9f, grSliderHeightMax*0.5f, grSliderHeightMax*0.5f)];
            [self.zoomTypeBtn setImage:[UIImage imageNamed:@"zoom_both"] forState:UIControlStateNormal];
            [self.zoomTypeBtn addTarget:self action:@selector(actionZoomType:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:self.zoomTypeBtn];
        }
        
        /* timeLineView`s total time label */
        self.timeLineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.bounds.size.width, grSliderHeightMax*0.8f)];
        [self.timeLineLabel setBackgroundColor:[UIColor clearColor]];
        [self.timeLineLabel setTextAlignment:NSTextAlignmentCenter];
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
            [self.timeLineLabel setFont:[UIFont fontWithName:MYRIADPRO size:11.0f]];
        else
            [self.timeLineLabel setFont:[UIFont fontWithName:MYRIADPRO size:14.0f]];
        
        [self.timeLineLabel setTextColor:[UIColor whiteColor]];
        [self.timeLineLabel setShadowColor:[UIColor blackColor]];
        [self.timeLineLabel setShadowOffset:CGSizeMake(0, 1)];
        [self.timeLineLabel.layer setBorderColor:[UIColor blackColor].CGColor];
        [self.timeLineLabel.layer setBorderWidth:0.5f];
        [self addSubview:self.timeLineLabel];
    }
    
    return self;
}

-(void) setContentSize:(CGSize) size
{
    [self.horizontalScrollView setContentSize:size];
}

-(void) setTotalTime:(CGFloat) time
{
    [self.timeLineLabel setText:[NSString stringWithFormat:@"TOTAL TIME %@", [self timeToStr:time]]];
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
#pragma mark - touch functions

- (void) touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
    UITouch *touch = [touches anyObject];

    CGPoint point = [touch locationInView:self];
    
    if (CGRectContainsPoint(self.leftArrowImageView.frame, point))
    {
        if ([self.delegate respondsToSelector:@selector(moveToBegin)])
        {
            [self.delegate moveToBegin];
        }
    }
    else if (CGRectContainsPoint(self.rightArrowImageView.frame, point))
    {
        if ([self.delegate respondsToSelector:@selector(moveToEnd)])
        {
            [self.delegate moveToEnd];
        }
    }
}


#pragma mark -
#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)_scrollView
{
    CGFloat contentOffset = _scrollView.contentOffset.x;
    
    if ([self.delegate respondsToSelector:@selector(setTimelineViewContentOffsetX:)])
    {
        [self.delegate setTimelineViewContentOffsetX:contentOffset];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if ([self.delegate respondsToSelector:@selector(timelineViewHorizontalScrollViewWillBeginDragging)])
    {
        [self.delegate timelineViewHorizontalScrollViewWillBeginDragging];
    }
}

-(void) changeZoomSliderValue
{
    float scale = self.zoomSlider.value;
    
    if ([self.delegate respondsToSelector:@selector(changeTimelineScale:)])
    {
        [self.delegate changeTimelineScale:scale];
    }
}

-(void) actionZoomType:(id) sender
{
    NSArray *menuItems =
    @[
      [YJLActionMenuItem menuItem:@"Zoom Both"
                            image:[UIImage imageNamed:@"zoom_both_icon"]
                           target:self
                           action:@selector(actionZoomBoth)],
      
      [YJLActionMenuItem menuItem:@"Zoom Horizontal"
                            image:[UIImage imageNamed:@"zoom_horizontal_icon"]
                           target:self
                           action:@selector(actionZoomHorizontal)],
      
      [YJLActionMenuItem menuItem:@"Zoom Vertical"
                            image:[UIImage imageNamed:@"zoom_vertical_icon"]
                           target:self
                           action:@selector(actionZoomVertical)],
      ];
    
    CGRect frame = [self.superview convertRect:self.zoomTypeBtn.frame fromView:self];
    [YJLActionMenu showMenuInView:self.superview
                         fromRect:frame
                        menuItems:menuItems isWhiteBG:NO];
}

-(void) actionZoomBoth
{
    gnZoomType = ZOOM_BOTH;
    
    [self.zoomTypeBtn setImage:[UIImage imageNamed:@"zoom_both"] forState:UIControlStateNormal];
}

-(void) actionZoomHorizontal
{
    gnZoomType = ZOOM_HORIZONTAL;
    
    [self.zoomTypeBtn setImage:[UIImage imageNamed:@"zoom_horizontal"] forState:UIControlStateNormal];
}

-(void) actionZoomVertical
{
    gnZoomType = ZOOM_VERTICAL;
    
    [self.zoomTypeBtn setImage:[UIImage imageNamed:@"zoom_vertical"] forState:UIControlStateNormal];
}


@end
