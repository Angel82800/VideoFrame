//
//  TimelineVerticalView.h
//  VideoFrame
//
//  Created by Yinjing Li on 8/14/14.
//  Copyright (c) 2014 Yinjing Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Definition.h"
#import "MakeVideoVC.h"

@protocol TimelineVerticalViewDelegate <NSObject>

@optional

-(void) setTimelineViewContentOffsetY:(CGFloat) offsetY;
-(void) timelineViewVerticalScrollViewWillBeginDragging;
-(void) moveToTop;
-(void) moveToBottom;

@end


@interface TimelineVerticalView : UIView<UIScrollViewDelegate>

@property(nonatomic, weak) id <TimelineVerticalViewDelegate> delegate;

@property(nonatomic, strong) UIImageView* topArrowImageView;
@property(nonatomic, strong) UIImageView* bottomArrowImageView;
@property(nonatomic, strong) UIImageView* bgImageView;

@property(nonatomic, strong) UIScrollView* verticalScrollView;


-(void) setContentSize:(CGSize) size;

@end
