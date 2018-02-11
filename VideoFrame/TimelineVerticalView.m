//
//  TimelineVerticalView.m
//  VideoFrame
//
//  Created by Yinjing Li on 7/30/14.
//  Copyright (c) 2014 Yinjing Li. All rights reserved.
//

#import "TimelineVerticalView.h"

@implementation TimelineVerticalView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        [self setUserInteractionEnabled:YES];

        self.backgroundColor = [UIColor blackColor];

        /* background image view */
        self.bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, grSliderHeightMax, self.bounds.size.width, self.bounds.size.height - grSliderHeightMax*2.0f)];
        [self.bgImageView setBackgroundColor:[UIColor clearColor]];
        [self.bgImageView setImage:[UIImage imageNamed:@"verticalSliderBg"]];
        [self addSubview:self.bgImageView];

        /* vertical UIScrollView */
        self.verticalScrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        [self.verticalScrollView setBackgroundColor:[UIColor clearColor]];
        [self.verticalScrollView setIndicatorStyle:UIScrollViewIndicatorStyleWhite];
        [self.verticalScrollView setScrollEnabled:YES];
        [self.verticalScrollView setDelegate:self];
        [self addSubview:self.verticalScrollView];
        
        /* top arrow button */
        self.topArrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.bounds.size.width, grSliderHeightMax)];
        [self.topArrowImageView setBackgroundColor:[UIColor clearColor]];
        [self.topArrowImageView setImage:[UIImage imageNamed:@"top_arrow"]];
        [self.topArrowImageView setUserInteractionEnabled:YES];
        [self addSubview:self.topArrowImageView];
        
        /* bottom arrow button */
        self.bottomArrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, self.bounds.size.height - grSliderHeightMax, self.bounds.size.width, grSliderHeightMax)];
        [self.bottomArrowImageView setBackgroundColor:[UIColor clearColor]];
        [self.bottomArrowImageView setImage:[UIImage imageNamed:@"bottom_arrow"]];
        [self.bottomArrowImageView setUserInteractionEnabled:YES];
        [self addSubview:self.bottomArrowImageView];
    }
    
    return self;
}

-(void) setContentSize:(CGSize) size
{
    [self.verticalScrollView setContentSize:size];
}


#pragma mark -
#pragma mark - touch functions

- (void) touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    
    if (CGRectContainsPoint(self.topArrowImageView.frame, point))
    {
        if ([self.delegate respondsToSelector:@selector(moveToTop)])
        {
            [self.delegate moveToTop];
        }
    }
    else if (CGRectContainsPoint(self.bottomArrowImageView.frame, point))
    {
        if ([self.delegate respondsToSelector:@selector(moveToBottom)])
        {
            [self.delegate moveToBottom];
        }
    }
}


#pragma mark -
#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)_scrollView
{
    CGFloat contentOffset = _scrollView.contentOffset.y;
    
    if ([self.delegate respondsToSelector:@selector(setTimelineViewContentOffsetY:)])
    {
        [self.delegate setTimelineViewContentOffsetY:contentOffset];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if ([self.delegate respondsToSelector:@selector(timelineViewVerticalScrollViewWillBeginDragging)])
    {
        [self.delegate timelineViewVerticalScrollViewWillBeginDragging];
    }
}

@end
