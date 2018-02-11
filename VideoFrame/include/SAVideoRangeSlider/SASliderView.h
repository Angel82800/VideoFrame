//
//  SASliderView.h
//  VideoFrame
//
//  Created by YinjingLi on 10/2/15.
//  Copyright © 2015 Yinjing Li. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>

#import "SASliderLeft.h"
#import "SASliderRight.h"
#import "SAResizibleBubble.h"
#import "YJLCustomDeleteButton.h"


@protocol SASliderViewDelegate;



@interface SASliderView : UIView <UIGestureRecognizerDelegate>
{
    CGFloat red, green, blue;
    int mediaType;
    
    float lastPtForMusic;
}

@property (nonatomic, weak) id <SASliderViewDelegate> delegate;

@property (nonatomic, strong) SASliderLeft *leftThumb;
@property (nonatomic, strong) SASliderRight *rightThumb;
@property (nonatomic, strong) SAResizibleBubble *popoverBubble;

@property(nonatomic, strong) YJLCustomDeleteButton* deleteBtn;

@property (nonatomic, strong) UIView *topBorder;
@property (nonatomic, strong) UIView *bottomBorder;

@property (nonatomic, strong) UILabel *bubleText;

@property (nonatomic, assign) NSInteger nSliderIndex;
@property (nonatomic, assign) CGFloat motionValue;  // motion value of this sub slider
@property (nonatomic, assign) Float64 myAssetDuration;  // duration of video(AVAsset) - same on all sub sliders, not change on any sub slider
@property (nonatomic, assign) CGFloat leftPos;
@property (nonatomic, assign) CGFloat rightPos;
@property (nonatomic, assign) BOOL isGestureProcessing;

@property (nonatomic, assign) CGFloat BasePos;
@property (nonatomic, assign) CGFloat BaseSize;

- (id)initWithFrame:(CGRect)frame width:(CGFloat) thumbWidth sec:(Float64) duration value:(CGFloat) motionValue type:(int)type;
- (void) setVideoSliderRangeForEditMotion:(CGFloat) fStart end:(CGFloat)fEnd;
- (void) changedVideoMotion:(CGFloat) value;
- (void) updateSlider:(BOOL) isSelected;
- (void) selectedSASliderView;
- (void) updateBubble:(CGFloat) fStart stop:(CGFloat) fStop;

@end


@protocol SASliderViewDelegate <NSObject>

@optional

- (void) didChangeSliderPosition:(CGFloat)fLeftPos right:(CGFloat)fRightPos LCR:(int)type value:(CGFloat) motionValue;
- (BOOL) checkSelectedGestureProcessing:(NSInteger) index;
- (void) didSelectedSASliderView:(NSInteger) index;
- (void) didLongPressedSASliderView;
- (void) didDeleteSASliderView:(NSInteger) index;
- (void) requestDetectEdge:(int) LCR;
- (void) stopMusic:(int)LCR;
- (void) didScaled:(float)scale;
- (void) sendMoveDelta:(float)delta;
- (void) setClipViewPos;
@end

