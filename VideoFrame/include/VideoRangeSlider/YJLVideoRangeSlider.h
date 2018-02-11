

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import "YJLSliderLeft.h"
#import "YJLSliderRight.h"
#import "YJLResizibleBubble.h"
#import "UIColor+YJL.h"
#import "UIImageExtras.h"
#import "Definition.h"
#import "ActionSettingsPickerView.h"
#import "FDWaveformView.h"
#import "YJLCenterView.h"
#import "CustomModalView.h"


@protocol YJLVideoRangeSliderDelegate;


@interface YJLVideoRangeSlider : UIView<UIGestureRecognizerDelegate, ActionSettingsPickerView, FDWaveformViewDelegate, CustomModalViewDelegate>
{
    BOOL isLR;
    BOOL isMoveStart;
}


@property (nonatomic, weak) id <YJLVideoRangeSliderDelegate> delegate;

@property (nonatomic, strong) UILabel* durationLabel;
@property (nonatomic, strong) UILabel* startAnimationLabel;
@property (nonatomic, strong) UILabel* endAnimationLabel;
@property (nonatomic, strong) UILabel* thumbnailLabel;

@property (nonatomic, strong) UIImageView* thumbnailImageView;
@property (nonatomic, strong) UIImageView* groupImageView;

@property (nonatomic, strong) FDWaveformView *waveform;

@property (nonatomic, assign) int media_type;
@property (nonatomic, assign) int objectIndex;
@property (nonatomic, assign) int startActionType;
@property (nonatomic, assign) int endActionType;

@property (nonatomic, assign) NSInteger maxGap;
@property (nonatomic, assign) NSInteger minGap;

@property (nonatomic, assign) CGFloat startActionTime;
@property (nonatomic, assign) CGFloat endActionTime;
@property (nonatomic, assign) CGFloat leftPosition;//left position of video for trim
@property (nonatomic, assign) CGFloat rightPosition;//right position of video for trim
@property (nonatomic, assign) CGFloat scaleFactor;
@property (nonatomic, assign) CGFloat frame_width;
@property (nonatomic, assign) CGFloat yPosition;
@property (nonatomic, assign) CGFloat durationSeconds;

@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, assign) BOOL isGrouped;

@property (nonatomic, strong) AVAsset *myAsset;

@property(nonatomic, strong) CustomModalView* customModalView;


-(id) initWithFrame:(CGRect)frame videoUrl:(NSURL *)videoUrl;
-(id) initWithFrame:(CGRect)frame musicUrl:(NSURL *)musicUrl;
-(id) initWithFrame:(CGRect)frame image:(UIImage *)image scale:(CGFloat)scale type:(int) mediaType;
-(id) initWithFrameText:(NSString*) text frame:(CGRect)frame scale:(CGFloat)scale;

-(void) changeSliderFrame:(CGFloat)scaleFactor;
-(void) isActived;
-(void) isNotActived;
-(void) drawRuler;
-(void) changedTextThumbnail:(NSString*) string;
-(void) changeSliderFrameByDuration:(CGFloat)duration;
-(void) changeMusicWaveByRange:(CGFloat) startPosition end:(CGFloat)endPosition;
-(void) updateWaveform:(NSURL*) musicUrl;
-(void) layoutSubviews;
-(void) changeSliderYPosition;
-(void) changeSliderByLeftPosition:(CGFloat) left;
-(void) changeSliderPosition:(CGFloat)left right:(CGFloat) right;
-(void) replaceSliderLeftPosition:(CGFloat) left right:(CGFloat) right;

-(void)setActions:(int) startActionType startTime:(CGFloat) startActionTime endType:(int) endActionType endTime:(CGFloat)endActionTime;

@end


@protocol YJLVideoRangeSliderDelegate <NSObject>

@optional

-(void) videoRange:(YJLVideoRangeSlider *)videoRange didChangeLeftPosition:(CGFloat)leftPosition rightPosition:(CGFloat)rightPosition;
-(void) changeGroupPosition:(CGFloat) deltaPosition;
-(void) didEndGesture;
-(void) timelineObjectSelected:(int) objectIndex;
-(void) previewShow:(int) objectIndex;
-(void) previewHide;
-(void) onShowTimelineMenu:(int) selectedIndex;
-(void) changeActionAll:(int) mediaType isStart:(BOOL) start actionTypeStr:(NSString*) typeStr actionType:(int) type actionTime:(CGFloat) time;

@end





