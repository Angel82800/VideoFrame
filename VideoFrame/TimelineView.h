//
//  TimelineView.h
//  VideoFrame
//
//  Created by Yinjing Li on 1/13/14.
//  Copyright (c) 2014 Yinjing Li. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Definition.h"
#import "YJLVideoRangeSlider.h"
#import "MediaObjectView.h"
#import "UIColor+YJL.h"
#import "UIBezierPath+dqd_arrowhead.h"
#import "YJLResizibleBubble.h"
#import "YJLActionMenu.h"
#import "AppDelegate.h"
#import "TimePickerView.h"
#import "CustomModalView.h"


@protocol TimelineViewDelegate <NSObject>

@optional

-(void) timelineSelected:(int) index;
-(void) timelineGrouped:(int) index isGrouped:(BOOL) flag;
-(void) timelineUnGroupAll;
-(void) onEditSpeed;
-(void) onEditJog;
-(void) onEditTrim;
-(void) updateTotalTime;
-(void) onEditVolume;
-(void) onRemoveMusic;
-(void) exchangedObjects:(int) fromIdx toIndex:(int) toIdx;
-(void) hideVerticalView:(BOOL) hide;

@end


@interface TimelineView : UIScrollView <YJLVideoRangeSliderDelegate, UIGestureRecognizerDelegate, TimePickerViewDelegate, UIScrollViewDelegate, CustomModalViewDelegate>
{
    CGFloat bottomY;
    CGFloat labelFontSize;
    CGFloat sliderWidthMin;
    
    int mnPreviewIndex;
}


@property(nonatomic, weak) id <TimelineViewDelegate> timelineDelegate;

@property(nonatomic, strong) YJLResizibleBubble *popoverBubble;
@property(nonatomic, strong) CustomModalView* customModalView;

@property(nonatomic, strong) UIImageView* previewImageView;
@property(nonatomic, strong) UILabel* previewTimeLabel;
@property(nonatomic, strong) AVPlayer *previewPlayer;
@property(nonatomic, strong) AVPlayerLayer* previewPlayerLayer;
@property(nonatomic, strong) AVPlayerItem *previewPlayerItem;

@property(nonatomic, assign) CGFloat totalTime;
@property(nonatomic, assign) CGFloat scaleFactor;//totalTime/TimelineView.frame.size.width
@property(nonatomic, assign) CGFloat oldY;

@property(nonatomic, strong) NSMutableArray* sliderArray;


-(void) addNewTimeLine:(MediaObjectView*) mediaObj;
-(void) changeSliderOrder:(int) index insertFlag:(BOOL)insertFlag;
-(void) removeSlider:(int) index;
-(void) deleteAllSliders;
-(void) selectTimelineObject:(int) index;
-(void) changedTextThumbnail:(MediaObjectView*) object;
-(void) changeTimeline:(int) index time:(CGFloat)duration;
-(void) replaceSlider:(int) selectedIndex;
-(void) resetTimeline:(int) index obj:(MediaObjectView*) object;
-(void) initTimelinePosition:(int) index startPosition:(CGFloat) startPosition endPosition:(CGFloat) endPosition;
-(void) timelineObjectDeselected;
-(void) updateWaveform:(int) index url:(NSURL*) musicUrl;

-(int) getStartActionType:(int) index;
-(int) getEndActionType:(int) index;

-(CGFloat) getStartPosition:(int) index;
-(CGFloat) getEndPosition:(int) index;
-(CGFloat) getStartActionTime:(int) index;
-(CGFloat) getEndActionTime:(int) index;

- (void)updateZoom;

@end





