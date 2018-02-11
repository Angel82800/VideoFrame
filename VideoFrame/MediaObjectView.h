//
//  MediaObjectView.h
//  VideoFrame
//
//  Created by Yinjing Li on 12/4/13.
//  Copyright (c) 2013 Yinjing Li. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreText/CoreText.h>

#import "ReflectionView.h"
#import "UITextViewExtras.h"


/***************************************************
 Mask Bound Enum
 **************************************************/
typedef NS_ENUM(NSUInteger, BoundMode) {
    BoundModeNone     = 0,
    BoundModeLeft     = 1 << 0,
    BoundModeRight    = 1 << 1,
    BoundModeTop      = 1 << 2,
    BoundModeBottom   = 1 << 3,
};


/***************************************************
 MaskArrowView
 **************************************************/
@interface MaskArrowView : UIImageView

- (id)init:(int)arrowIndex;

@end


/***************************************************
 MediaObjectDelegate
 **************************************************/
@protocol MediaObjectDelegate <NSObject>

@optional
-(void) mediaObjectSelected:(int) index;
-(void) generateNewTextObject;
-(void) textChanged:(id) object;
-(void) objectSettingViewShow:(int) index;
-(void) changeBoldBtn:(BOOL) isBold;
-(void) changeItalicBtn:(BOOL) isItalic;

@end


@class UITextViewExtras;
@class BSKeyboardControls;

@interface MediaObjectView:ReflectionView
{
    CGSize textMaxSize;
}

@property(nonatomic, weak) id <MediaObjectDelegate> delegate;

@property(nonatomic, strong) UIView* mediaView;
@property(nonatomic, strong) UIView* videoView;

@property(nonatomic, strong) UIImageView* imageView;
@property(nonatomic, strong) UIImageView* kbFocusImageView;

@property(nonatomic, strong) UIImage* originalImage;
@property(nonatomic, strong) UIImage* renderedImage;

@property(nonatomic, strong) UITextViewExtras* textView;

@property(nonatomic, assign) int mediaType;
@property(nonatomic, assign) int objectIndex;
@property(nonatomic, assign) int startActionType;
@property(nonatomic, assign) int endActionType;
@property(nonatomic, assign) int objectBorderStyle;//1-none, 2-line
@property(nonatomic, assign) int objectShadowStyle;//1-none, 2-shadow
@property(nonatomic, assign) int shapeOverlayStyle;//1-none, 2-overlay

@property(nonatomic, assign) NSInteger nKbIn;

@property(nonatomic, assign) NSInteger photoFilterIndex;
@property(nonatomic, assign) float photoFilterValue;

@property(nonatomic, assign) BOOL isSelected;
@property(nonatomic, assign) BOOL isMask;//yes-mask, no-rotate, zoom, move
@property(nonatomic, assign) BOOL isArrowActived;
@property(nonatomic, assign) BOOL isPlaying;
@property(nonatomic, assign) BOOL isExistAudioTrack;
@property(nonatomic, assign) BOOL isImitationPhoto;
@property(nonatomic, assign) BOOL isPhotoFromVideo;
@property(nonatomic, assign) BOOL isBold;
@property(nonatomic, assign) BOOL isItalic;
@property(nonatomic, assign) BOOL isUnderline;
@property(nonatomic, assign) BOOL isStroke;
@property(nonatomic, assign) BOOL isKbEnabled;
@property(nonatomic, assign) BOOL isShape;
@property(nonatomic, assign) BOOL isGrouped;

@property(nonatomic, assign) CGFloat mediaDuration;
@property(nonatomic, assign) CGFloat mediaTimescale;
@property(nonatomic, assign) CGFloat mediaVolume;
@property(nonatomic, assign) CGFloat mfStartPosition;
@property(nonatomic, assign) CGFloat mfEndPosition;
@property(nonatomic, assign) CGFloat mfStartAnimationDuration;
@property(nonatomic, assign) CGFloat mfEndAnimationDuration;
@property(nonatomic, assign) CGFloat lastScaleFactor;
@property(nonatomic, assign) CGFloat firstX;
@property(nonatomic, assign) CGFloat firstY;
@property(nonatomic, assign) CGFloat rotateAngle;
@property(nonatomic, assign) CGFloat scaleValue;
@property(nonatomic, assign) CGFloat portraitSpecialScale;
@property(nonatomic, assign) CGFloat mySX;
@property(nonatomic, assign) CGFloat mySY;
@property(nonatomic, assign) CGFloat objectBorderWidth;
@property(nonatomic, assign) CGFloat objectCornerRadius;
@property(nonatomic, assign) CGFloat objectShadowBlur;
@property(nonatomic, assign) CGFloat objectShadowOffset;
@property(nonatomic, assign) CGFloat textObjectFontSize;
@property(nonatomic, assign) CGFloat fKbScale;

@property(nonatomic, assign) CGPoint reflectionDelta;
@property(nonatomic, assign) CGPoint originalVideoCenter;
@property(nonatomic, assign) CGPoint changedVideoCenter;
@property(nonatomic, assign) CGPoint lastPoint;
@property(nonatomic, assign) CGPoint firstTouchedPoint;
@property(nonatomic, assign) CGPoint kbFocusPoint;

@property(nonatomic, assign) CGSize workspaceSize;
@property(nonatomic, assign) CGSize originalVideoSize;
@property(nonatomic, assign) CGSize superViewSize;

@property(nonatomic, assign) CGRect originalBounds;
@property(nonatomic, assign) CGRect normalFilterVideoCropRect;

@property(nonatomic, strong) NSURL* mediaUrl;   // video or music url
@property(nonatomic, strong) NSString* imageName;

@property(nonatomic, strong) NSMutableArray* motionArray;
@property(nonatomic, strong) NSMutableArray* startPositionArray;
@property(nonatomic, strong) NSMutableArray* endPositionArray;

@property(nonatomic, assign) CGAffineTransform inputTransform;// for GPUImage
@property(nonatomic, assign) CGAffineTransform nationalVideoTransform;
@property(nonatomic, assign) CGAffineTransform nationalVideoTransformOutputValue;
@property(nonatomic, assign) CGAffineTransform nationalReflectionVideoTransformOutputValue;
@property(nonatomic, assign) CGAffineTransform videoTransform;

@property(nonatomic, strong) CAShapeLayer* selectedLineLayer;
@property(nonatomic, strong) CAShapeLayer* borderLineLayer;
@property(nonatomic, strong) CAShapeLayer* maskLayer;

@property(nonatomic, strong) AVAssetImageGenerator* imageGenerator;
@property(nonatomic, strong) AVAsset *mediaAsset;
@property(nonatomic, strong) AVAssetTrack *videoAssetTrack;

@property(nonatomic, assign) CMTime currentPosition;

@property(nonatomic, strong) UIPanGestureRecognizer *moveGesture;

@property(nonatomic, strong) UIColor *objectBorderColor;
@property(nonatomic, strong) UIColor *objectShadowColor;
@property(nonatomic, strong) UIColor *shapeOverlayColor;
@property(nonatomic, strong) UIColor *objectChromaColor;

@property(nonatomic, strong) MaskArrowView* maskArrowLeft;
@property(nonatomic, strong) MaskArrowView* maskArrowRight;
@property(nonatomic, strong) MaskArrowView* maskArrowTop;
@property(nonatomic, strong) MaskArrowView* maskArrowBottom;

@property(nonatomic, assign) BoundMode boundMode;

@property(nonatomic, strong) BSKeyboardControls* iPhoneKeyboard;


-(id) initWithImage:(UIImage*) image frame:(CGRect) frame;
-(id) initWithGIF:(UIImage*) gifImage size:(CGSize) workspaceSize;
-(id) initWithVideoUrl:(NSURL*) url size:(CGSize) workspaceSize startPositions:(NSMutableArray*)startPositionArray endPositions:(NSMutableArray*)endPositionArray motionArray:(NSMutableArray*) motionValueArray;
-(id) initWithMusicUrl:(NSURL*) url size:(CGSize) workspaceSize;
-(id) initWithText:(NSString*) defaultText size:(CGSize) workspaceSize;

-(CGAffineTransform) getVideoTransform;
-(CGAffineTransform) getNationalVideoTransform;
-(CGAffineTransform) getReflectionNationalVideoTransform;

-(CGFloat) getVolume;
-(CGFloat) getVideoTotalDuration;

-(UIImage*) renderingPhoto;
-(UIImage*) renderingText;
-(UIImage*) renderingOutlineAndShadow;
-(UIImage*) renderingTextViewOutlineAndShadow;
-(UIImage*) renderingKenBurnsImage:(BOOL) isStart;
-(UIImage*) renderingImageView;
-(UIImage*) renderingImageViewForChromakey:(BOOL)isBlack;
-(UIImage*) renderingTextView;

-(CGRect) getVideoCropRect;
-(CGRect) getIntersectionRect;
-(CGRect) getNormalFilterVideoCropRect;

-(void) object_actived;
-(void) setIndex:(int)index;
-(void) setVolume:(CGFloat) volume;
-(void) objectCopy:(MediaObjectView*) oldObject;
-(void) setObjectValuesFromOldObject:(MediaObjectView*) oldObject;
-(void) changeTextObjectFrame;
-(void) flip:(int) index;
-(void) applyBorder;
-(void) applyShadow;
-(void) applyTextColor:(UIColor*) color;
-(void) applyTextAlignment:(NSTextAlignment) alignment;
-(void) applyTextUnderline:(BOOL) isUnderline;
-(void) applyTextStroke:(BOOL) isStroke;
-(void) applyTextFont:(NSString*)fontName size:(CGFloat)fontSize bold:(BOOL)isBold italic:(BOOL)isItalic;
-(void) maskArrowsShow;
-(void) maskArrowsHidden;
-(void) initTextAttributed;
-(void) updateVideoThumbnail:(CGFloat) startTime;
-(void) changeVideoMaskBound:(UIPanGestureRecognizer*) gestureRecognizer;
-(void) changeImageMaskBound:(UIPanGestureRecognizer*) gestureRecognizer;
-(void) showKenBurnsFocusImageView;
-(void) hideKenBurnsFocusImageView;
-(void) changeVideoThumbWithFilter;
- (UIImage*) renderingReflectionImage:(UIImage*) image size:(CGSize) size rect:(CGRect) drawRect;

@end
