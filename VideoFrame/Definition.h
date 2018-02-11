//
//  Definition.h
//  VideoFrame
//
//  Created by Yinjing Li on 11/13/13.
//  Copyright (c) 2013 Yinjing Li. All rights reserved.
//

#ifndef VideoFrame_Definition_h
#define VideoFrame_Definition_h



#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

//default font
#define MYRIADPRO @"MyriadPro-Semibold"
#define IPHONE_DEFAULT_FONT_SIZE 20
#define IPAD_DEFAULT_FONT_SIZE 40
#define FONT_SIZE 14.0f

//device orientation
#define ORIENTATION_LANDSCAPE 1
#define ORIENTATION_PORTRAIT 2
#define ORIENTATION_ALL 3

//template type
#define TEMPLATE_LANDSCAPE 1
#define TEMPLATE_PORTRAIT 2
#define TEMPLATE_SQUARE 3
#define TEMPLATE_1080P 4

//app starting type
#define START_WITH_TEMPLATE 1
#define START_WITH_PHOTOCAM 2
#define START_WITH_VIDEOCAM 3

//object type
#define MEDIA_PHOTO 1
#define MEDIA_VIDEO 2
#define MEDIA_MUSIC 3
#define MEDIA_TEXT 4
#define MEDIA_GIF 5

//timeline type
#define TIMELINE_TYPE_1 1
#define TIMELINE_TYPE_2 2
#define TIMELINE_TYPE_3 3

#define TIME_OVERLAPPED_VALUE 1.0f

//output video quality type
#define OUTPUT_HD 1
#define OUTPUT_UNIVERSAL 2
#define OUTPUT_SDTV 3

#define BOUND_SIZE 40.0f
#define VIDEO_COMPOSITING_MAX_COUNT 10
#define PHOTO_COMPOSITING_MAX_COUNT 2
#define MIN_DURATION 0.01f   // minimum action duration
#define IPHONE_TIMELINE_WIDTH_MIN 160.0f
#define IPAD_TIMELINE_WIDTH_MIN 230.0f

//timeline view zoom type
#define ZOOM_BOTH 1
#define ZOOM_HORIZONTAL 2
#define ZOOM_VERTICAL 3

//KenBurns action type
#define KB_IN 0
#define KB_OUT 1

//shapes max count
#define SHAPES_MAX_COUNT 62

#define SLIDER_BORDERS_SIZE 3.0f
#define BG_VIEW_BORDERS_SIZE 3.0f

#define LEFT 1
#define CENTER 2
#define RIGHT 3

#define VIDEO_SLIDER_MIN_WIDTH  10


//ACTIONS
#define ACTION_NONE 0
#define ACTION_BLACK 1
#define ACTION_EXPLODE 2
#define ACTION_FADE 3
#define ACTION_FLIP_BT 4
#define ACTION_FLIP_LR 5
#define ACTION_FLIP_RL 6
#define ACTION_FLIP_TB 7
#define ACTION_FOLD_BT 8
#define ACTION_FOLD_LR 9
#define ACTION_FOLD_RL 10
#define ACTION_FOLD_TB 11
#define ACTION_GENIE_BL 12
#define ACTION_GENIE_BR 13
#define ACTION_GENIE_BT 14
#define ACTION_GENIE_LR 15
#define ACTION_GENIE_RL 16
#define ACTION_GENIE_TB 17
#define ACTION_GENIE_TL 18
#define ACTION_GENIE_TR 19
#define ACTION_ROTATE 20
#define ACTION_REVEAL_BT 21
#define ACTION_REVEAL_LR 22
#define ACTION_REVEAL_RL 23
#define ACTION_REVEAL_TB 24
#define ACTION_SLIDE_BL 25
#define ACTION_SLIDE_BR 26
#define ACTION_SLIDE_BT 27
#define ACTION_SLIDE_LR 28
#define ACTION_SLIDE_RL 29
#define ACTION_SLIDE_TB 30
#define ACTION_SLIDE_TL 31
#define ACTION_SLIDE_TR 32
#define ACTION_SPIN_CC 33
#define ACTION_SWAP_ALL 34
#define ACTION_SWAP_BL 35
#define ACTION_SWAP_BR 36
#define ACTION_SWAP_BT 37
#define ACTION_SWAP_LR 38
#define ACTION_SWAP_RL 39
#define ACTION_SWAP_TB 40
#define ACTION_SWAP_TL 41
#define ACTION_SWAP_TR 42
#define ACTION_SWING_BT 43
#define ACTION_SWING_LR 44
#define ACTION_SWING_RL 45
#define ACTION_SWING_TB 46
#define ACTION_ZOOM_ALL 47
#define ACTION_ZOOM_BL 48
#define ACTION_ZOOM_BR 49
#define ACTION_ZOOM_BT 50
#define ACTION_ZOOM_CC 51
#define ACTION_ZOOM_LR 52
#define ACTION_ZOOM_RL 53
#define ACTION_ZOOM_TB 54
#define ACTION_ZOOM_TL 55
#define ACTION_ZOOM_TR 56

typedef enum {
    ADTransitionRightToLeft,
    ADTransitionLeftToRight,
    ADTransitionTopToBottom,
    ADTransitionBottomToTop,
    ADTransitionBottomLeft,
    ADTransitionBottomRight,
    ADTransitionTopLeft,
    ADTransitionTopRight
} ADTransitionOrientation;

typedef NS_ENUM(NSUInteger, BCRectEdge)
{
    BCRectEdgeTop    = 0,
    BCRectEdgeLeft   = 1,
    BCRectEdgeBottom = 2,
    BCRectEdgeRight  = 3
};

BOOL isRememberedBold;
BOOL isRememberedItalic;
BOOL isRememberedUnderline;
BOOL isRememberedStroke;
BOOL isIPhoneFive;
BOOL isActionChangeAll;
BOOL isKenBurnsChangeAll;
BOOL isWorkspace;
BOOL isKenBurnsEnabled;

int gnOrientation; // 1- landscape, 2-portrait, 3 - UIInterfaceOrientationMaskAll
int gnInstagramOrientation;
int gnTemplateIndex;    // 1 - landscape, 2-portrait, 3-instagram
int gnVisibleMaxCount;
int gnStartActionTypeDef;
int gnEndActionTypeDef;
int gnSelectedObjectIndex;
int gnTimelineType;
int gnOutputQuality;
int gnDefaultOutlineType;
int gnStartWithType;
int gnZoomType;
int gnKBZoomInOutType;
int gnOutputVideoFilterIndex;

CGFloat grNormalFilterOutputTotalTime;
CGFloat grSliderHeight;
CGFloat grSliderHeightMax;
CGFloat grZoomScale;
CGFloat grStartActionTimeDef;
CGFloat grEndActionTimeDef;
CGFloat grPhotoDefaultDuration;
CGFloat grTextDefaultDuration;
CGFloat grPreviewDuration;
CGFloat grMaxContentHeight;
CGFloat grDefaultOutlineWidth;
CGFloat grDefaultOutlineCorner;
CGFloat grFrameRate;
CGFloat grKBScale;


NSArray* gaActionNameArray;
NSArray* gaFontNameArray;

NSMutableArray* gaRecentColorArray;

UIFont* rememberedFont;

UIColor* defaultOutlineColor;

NSTextAlignment rememberedTextAlignment;

NSString* gstrCurrentProjectName;

typedef enum {
    
    /* filter value slider enabled */
    GPUIMAGE_NONE,
    GPUIMAGE_SEPIA,
    GPUIMAGE_SATURATION,
    GPUIMAGE_CONTRAST,
    GPUIMAGE_BRIGHTNESS,
    GPUIMAGE_LEVELS,
    GPUIMAGE_EXPOSURE,
    GPUIMAGE_RGB,
    GPUIMAGE_HUE,
    GPUIMAGE_WHITEBALANCE,
    GPUIMAGE_MONOCHROME,
    GPUIMAGE_SHARPEN,
    GPUIMAGE_UNSHARPMASK,
    GPUIMAGE_GAMMA,
    GPUIMAGE_HIGHLIGHTSHADOW,
    GPUIMAGE_HAZE,
    GPUIMAGE_TILTSHIFT,
    GPUIMAGE_POSTERIZE,
    GPUIMAGE_EMBOSS,
    GPUIMAGE_VIGNETTE,
    
    /* filter value slider disabled */
    GPUIMAGE_COLORINVERT,
    GPUIMAGE_TONECURVE,
    GPUIMAGE_GRAYSCALE,
    GPUIMAGE_SKETCH,
    GPUIMAGE_SMOOTHTOON,
    GPUIMAGE_GAUSSIAN,
    GPUIMAGE_GAUSSIAN_SELECTIVE,
    GPUIMAGE_GAUSSIAN_POSITION,
    GPUIMAGE_PINCH
} GPUImageFilterType;


static BOOL AnimatedGifDataIsValid(NSData *data)
{
    if (data.length > 4)
    {
        const unsigned char * bytes = [data bytes];
        
        return bytes[0] == 0x47 && bytes[1] == 0x49 && bytes[2] == 0x46;
    }
    
    return NO;
}

#endif
