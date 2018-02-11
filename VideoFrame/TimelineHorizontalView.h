//
//  TimelineHorizontalView.h
//  VideoFrame
//
//  Created by Yinjing Li on 7/30/14.
//  Copyright (c) 2014 Yinjing Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Definition.h"
#import "MakeVideoVC.h"
#import "YJLActionMenu.h"

@protocol TimelineHorizontalViewDelegate <NSObject>

@optional

-(void) setTimelineViewContentOffsetX:(CGFloat) offsetX;
-(void) timelineViewHorizontalScrollViewWillBeginDragging;
-(void) moveToBegin;
-(void) moveToEnd;
-(void) changeTimelineScale:(CGFloat) scale;

@end


@interface TimelineHorizontalView : UIView<UIScrollViewDelegate>
{

}

@property(nonatomic, weak) id <TimelineHorizontalViewDelegate> delegate;

@property(nonatomic, strong) UIImageView* leftArrowImageView;
@property(nonatomic, strong) UIImageView* rightArrowImageView;
@property(nonatomic, strong) UIImageView* bgImageView;
@property(nonatomic, strong) UIImageView* zoomInImageView;
@property(nonatomic, strong) UIImageView* zoomOutImageView;

@property(nonatomic, strong) UILabel* timeLineLabel;

@property(nonatomic, strong) UIScrollView* horizontalScrollView;

@property(nonatomic, strong) UISlider* zoomSlider;

@property(nonatomic, strong) UIButton* zoomTypeBtn;


-(void) setContentSize:(CGSize) size;
-(void) setTotalTime:(CGFloat) time;

@end
