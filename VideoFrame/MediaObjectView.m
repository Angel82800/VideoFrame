//
//  MediaObjectView.m
//  VideoFrame
//
//  Created by Yinjing Li on 12/4/13.
//  Copyright (c) 2013 Yinjing Li. All rights reserved.
//

#import "MediaObjectView.h"

#import "Definition.h"
#import "UIImageExtras.h"
#import "CustomModalView.h"
#import "AppDelegate.h"
#import "BSKeyboardControls.h"


#pragma mark -
#pragma mark - MaskArrowView

@implementation MaskArrowView

- (id)init:(int)arrowIndex
{
    if(!(self = [super initWithFrame:(CGRect){0, 0, BOUND_SIZE, BOUND_SIZE}]))
    {
        return nil;
    }
    
    static UIImage *image;
    
    switch (arrowIndex)
    {
        case 1:
            image = [UIImage imageNamed:@"left-right"];
            break;
        case 2:
            image = [UIImage imageNamed:@"left-right"];
            break;
        case 3:
            image = [UIImage imageNamed:@"top-bottom"];
            break;
        case 4:
            image = [UIImage imageNamed:@"top-bottom"];
            break;
            
        default:
            break;
    }
    
    [self setImage:image];
    
    return self;
}

@end



@interface MediaObjectView () <UIGestureRecognizerDelegate, UIAlertViewDelegate, UITextViewDelegate, BSKeyboardControlsDelegate, UITextViewExtrasDelegate>

@end

    
@implementation MediaObjectView:ReflectionView



-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        
    }
    
    return self;
}


#pragma mark - 
#pragma mark - init

-(id) initWithImage:(UIImage*) image frame:(CGRect) frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor clearColor];

        self.mediaType = MEDIA_PHOTO;
        
        self.startPositionArray = [[NSMutableArray alloc] init];
        self.endPositionArray = [[NSMutableArray alloc] init];
        self.motionArray = [[NSMutableArray alloc] init];

        [self.startPositionArray addObject:[NSNumber numberWithFloat:0.0f]];
        [self.endPositionArray addObject:[NSNumber numberWithFloat:grPhotoDefaultDuration]];
        [self.motionArray addObject:[NSNumber numberWithFloat:1.0f]];

        self.mediaUrl = nil;
        self.isSelected = YES;
        self.isMask = NO;
        self.isPlaying = NO;
        self.isArrowActived = NO;
        self.mfStartPosition = 0.0f;
        self.mfEndPosition = 0.0f;
        self.mfStartAnimationDuration = MIN_DURATION;
        self.mfEndAnimationDuration = MIN_DURATION;
        self.mySX = 1.0f;
        self.mySY = 1.0f;
        self.isExistAudioTrack = NO;
        self.originalBounds = self.bounds;
        self.isImitationPhoto = NO;
        self.isReflection = NO;
        self.reflectionScale = 0.5f;
        self.reflectionAlpha = 0.5f;
        self.reflectionGap = 0.0f;
        self.isKbEnabled = isKenBurnsEnabled;
        self.nKbIn = gnKBZoomInOutType;
        self.kbFocusPoint = CGPointMake(0.5f, 0.5f);
        self.fKbScale = grKBScale;
        self.isShape = NO;
        self.shapeOverlayColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f];
        self.shapeOverlayStyle = 1;
        self.objectChromaColor = [UIColor blackColor];
        self.photoFilterIndex = 0;
        self.photoFilterValue = 0.5f;
        self.isPhotoFromVideo = NO;
        self.isGrouped = NO;
        
        self.originalImage = [[UIImage alloc] initWithCGImage:image.CGImage];

        self.mediaView = [[UIView alloc] initWithFrame:self.bounds];
        self.mediaView.clipsToBounds = YES;
        self.mediaView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.mediaView];
        
        self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        [self.imageView setImage:image];
        [self.mediaView addSubview:self.imageView];
        
        /* zoom gesture init */
        UIPinchGestureRecognizer *zoomGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(zoom:)];
        zoomGesture.delegate = self;
        [self addGestureRecognizer:zoomGesture];
        
        /* move gesture init */
        self.moveGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(move:)];
        [self.moveGesture setMinimumNumberOfTouches:1];
        [self.moveGesture setMaximumNumberOfTouches:1];
        self.moveGesture.delegate = self;
        [self addGestureRecognizer:self.moveGesture];
        
        /* rotate gesture */
        UIRotationGestureRecognizer *rotationGesture = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotate:)];
        rotationGesture.delegate = self;
        [self addGestureRecognizer:rotationGesture];
        
        /* select tap gesture */
        UITapGestureRecognizer *selectGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selected:)];
        selectGesture.delegate = self;
        [self addGestureRecognizer:selectGesture];
        [selectGesture setNumberOfTapsRequired:1];

        /* Outline, Shadow Setting Values */
        self.objectBorderStyle = gnDefaultOutlineType;
        self.objectBorderWidth = grDefaultOutlineWidth;
        self.objectBorderColor = defaultOutlineColor;
        self.objectShadowStyle = 1;
        self.objectShadowBlur = 18.5f;
        self.objectShadowOffset = 0.0f;
        self.objectShadowColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f];
        self.objectCornerRadius = grDefaultOutlineCorner;
        
        self.borderLineLayer = [CAShapeLayer layer];
        self.borderLineLayer.strokeColor = [UIColor clearColor].CGColor;
        self.borderLineLayer.fillColor = nil;
        self.borderLineLayer.lineWidth = self.objectBorderWidth;
        self.borderLineLayer.frame = CGRectMake(-self.objectBorderWidth, -self.objectBorderWidth, self.mediaView.bounds.size.width+self.objectBorderWidth*2.0f, self.mediaView.bounds.size.height+self.objectBorderWidth*2.0f);
        [self.layer addSublayer:self.borderLineLayer];
        
        /* line dash */
        self.selectedLineLayer = [CAShapeLayer layer];
        self.selectedLineLayer.strokeColor = [UIColor greenColor].CGColor;
        self.selectedLineLayer.shadowColor = [UIColor redColor].CGColor;
        self.selectedLineLayer.shadowOpacity = 1.0f;
        self.selectedLineLayer.shadowOffset = CGSizeMake(2.0f, 2.0f);
        self.selectedLineLayer.fillColor = nil;
        self.selectedLineLayer.lineWidth = 4;
        self.selectedLineLayer.frame = self.bounds;
        [self.selectedLineLayer setLineJoin:kCALineJoinRound];
        [self.selectedLineLayer setLineDashPattern:
         [NSArray arrayWithObjects:[NSNumber numberWithInt:10],
          [NSNumber numberWithInt:5],
          nil]];
        [self.layer addSublayer:self.selectedLineLayer];

        self.maskLayer = [CAShapeLayer layer];
        self.mediaView.layer.mask = self.maskLayer;

        [self applySelectedLinePath];

        /* mask left arrow, left gesture */
        self.maskArrowLeft = [[MaskArrowView alloc] init:1];
        self.maskArrowLeft.center = CGPointMake(self.maskArrowLeft.frame.size.width/2, self.frame.size.height/2);
        [self addSubview:self.maskArrowLeft];
        self.maskArrowLeft.userInteractionEnabled = YES;
        
        UIPanGestureRecognizer *photoMaskLeftGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(mask_left:)];
        [photoMaskLeftGesture setMinimumNumberOfTouches:1];
        [photoMaskLeftGesture setMaximumNumberOfTouches:1];
        photoMaskLeftGesture.delegate = self;
        [self.maskArrowLeft addGestureRecognizer:photoMaskLeftGesture];
        
        /* mask right arrow, right gesture */
        self.maskArrowRight = [[MaskArrowView alloc] init:2];
        self.maskArrowRight.center = CGPointMake(self.frame.size.width - self.maskArrowRight.frame.size.width/2, self.frame.size.height/2);
        [self addSubview:self.maskArrowRight];
        self.maskArrowRight.userInteractionEnabled = YES;
        
        UIPanGestureRecognizer *photoMaskRightGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(mask_right:)];
        [photoMaskRightGesture setMinimumNumberOfTouches:1];
        [photoMaskRightGesture setMaximumNumberOfTouches:1];
        photoMaskRightGesture.delegate = self;
        [self.maskArrowRight addGestureRecognizer:photoMaskRightGesture];
        
        /* mask top arrow, top gesture */
        self.maskArrowTop = [[MaskArrowView alloc] init:3];
        self.maskArrowTop.center = CGPointMake(self.frame.size.width/2, self.maskArrowTop.frame.size.height/2);
        [self addSubview:self.maskArrowTop];
        self.maskArrowTop.userInteractionEnabled = YES;
        
        UIPanGestureRecognizer *photoMaskTopGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(mask_top:)];
        [photoMaskTopGesture setMinimumNumberOfTouches:1];
        [photoMaskTopGesture setMaximumNumberOfTouches:1];
        photoMaskTopGesture.delegate = self;
        [self.maskArrowTop addGestureRecognizer:photoMaskTopGesture];
        
        /* mask bottom arrow, bottom gesture */
        self.maskArrowBottom = [[MaskArrowView alloc] init:4];
        self.maskArrowBottom.center = CGPointMake(self.frame.size.width/2, self.frame.size.height - self.maskArrowBottom.frame.size.height/2);
        [self addSubview:self.maskArrowBottom];
        self.maskArrowBottom.userInteractionEnabled = YES;
        
        UIPanGestureRecognizer *photoMaskBottomGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(mask_bottom:)];
        [photoMaskBottomGesture setMinimumNumberOfTouches:1];
        [photoMaskBottomGesture setMaximumNumberOfTouches:1];
        photoMaskBottomGesture.delegate = self;
        [self.maskArrowBottom addGestureRecognizer:photoMaskBottomGesture];
        
        /* hidden mask arrows */
        self.maskArrowLeft.hidden = YES;
        self.maskArrowRight.hidden = YES;
        self.maskArrowTop.hidden = YES;
        self.maskArrowBottom.hidden = YES;
        
        [self applyBorder];
        
        self.kbFocusImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.bounds.size.width/2.0f - 25.0f, self.bounds.size.height/2.0f - 25.0f, 50.0f, 50.0f)];
        [self.kbFocusImageView setImage:[UIImage imageNamed:@"focus"]];
        self.kbFocusImageView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.kbFocusImageView];
        self.kbFocusImageView.hidden = YES;
    }
    
    return self;
}

-(id) initWithGIF:(UIImage*) gifImage size:(CGSize) workspaceSize
{
    self = [super init];
    
    if (self)
    {
        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor clearColor];
        
        self.startPositionArray = [[NSMutableArray alloc] init];
        self.endPositionArray = [[NSMutableArray alloc] init];
        self.motionArray = [[NSMutableArray alloc] init];

        [self.startPositionArray addObject:[NSNumber numberWithFloat:0.0f]];
        [self.endPositionArray addObject:[NSNumber numberWithFloat:grPhotoDefaultDuration]];
        [self.motionArray addObject:[NSNumber numberWithFloat:1.0f]];

        self.isMask = NO;
        self.isSelected = YES;
        self.mediaType = MEDIA_GIF;
        self.mediaUrl = nil;
        self.isPlaying = NO;
        self.isArrowActived = NO;
        self.mfStartPosition = 0.0f;
        self.mfEndPosition = 0.0f;
        self.mfStartAnimationDuration = MIN_DURATION;
        self.mfEndAnimationDuration = MIN_DURATION;
        self.mySX = 1.0f;
        self.mySY = 1.0f;
        self.isExistAudioTrack = NO;
        self.workspaceSize = workspaceSize;
        self.rotateAngle = 0.0f;
        self.scaleValue = 1.0f;
        self.isImitationPhoto = NO;
        self.isReflection = NO;
        self.reflectionScale = 0.5f;
        self.reflectionAlpha = 0.5f;
        self.reflectionGap = 0.0f;
        self.reflectionDelta = CGPointZero;
        self.isKbEnabled = NO;
        self.nKbIn = KB_IN;
        self.kbFocusPoint = CGPointMake(0.5f, 0.5f);
        self.fKbScale = 1.1f;
        self.isShape = NO;
        self.shapeOverlayColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f];
        self.shapeOverlayStyle = 1;
        self.objectChromaColor = [UIColor greenColor];
        self.photoFilterIndex = 0;
        self.photoFilterValue = 0.5f;
        self.isPhotoFromVideo = NO;
        _mediaVolume = 1.0f;
        self.isGrouped = NO;

        // video view frame
        self.originalVideoSize = gifImage.size;
        
        float rScaleX, rScaleY;
        float rWidth, rHeight;
        
        rScaleX = self.originalVideoSize.width / workspaceSize.width;
        rScaleY = self.originalVideoSize.height / workspaceSize.height;
        
        if (rScaleX >= rScaleY)
        {
            rWidth = workspaceSize.width;
            rHeight = self.originalVideoSize.height * workspaceSize.width / self.originalVideoSize.width;
        }
        else
        {
            rHeight = workspaceSize.height;
            rWidth = self.originalVideoSize.width * workspaceSize.height / self.originalVideoSize.height;
        }
        
        self.nationalVideoTransform = CGAffineTransformIdentity;
        self.nationalVideoTransform = CGAffineTransformMakeScale(rWidth/self.originalVideoSize.width, rHeight/self.originalVideoSize.height);
        
        rScaleX = rWidth / workspaceSize.width;
        rScaleY = rHeight / workspaceSize.height;
        
        self.videoTransform = CGAffineTransformIdentity;
        self.videoTransform = CGAffineTransformMakeScale(rScaleX, rScaleY);
        
        [self setFrame:CGRectMake((workspaceSize.width - rWidth)/2, (workspaceSize.height - rHeight)/2, rWidth, rHeight)];

        self.nationalVideoTransform = CGAffineTransformConcat(self.nationalVideoTransform, CGAffineTransformMakeTranslation((workspaceSize.width - rWidth)/2, (workspaceSize.height - rHeight)/2));

        self.originalImage = [[UIImage alloc] initWithCGImage:gifImage.CGImage];
        
        self.mediaView = [[UIView alloc] initWithFrame:self.bounds];
        self.mediaView.clipsToBounds = YES;
        self.mediaView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.mediaView];
        
        self.videoView = [[UIView alloc] initWithFrame:self.bounds];
        self.videoView.backgroundColor = [UIColor clearColor];
        [self.mediaView addSubview:self.videoView];

        self.originalVideoCenter = self.videoView.center;
        self.changedVideoCenter = self.videoView.center;

        self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        [self.imageView setImage:gifImage];
        [self.videoView addSubview:self.imageView];
        
        /* zoom gesture init */
        UIPinchGestureRecognizer *zoomGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(zoom:)];
        zoomGesture.delegate = self;
        [self addGestureRecognizer:zoomGesture];
        
        /* move gesture init */
        self.moveGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(move:)];
        [self.moveGesture setMinimumNumberOfTouches:1];
        [self.moveGesture setMaximumNumberOfTouches:1];
        self.moveGesture.delegate = self;
        [self addGestureRecognizer:self.moveGesture];
        
        /* rotate gesture */
        UIRotationGestureRecognizer *rotationGesture = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotate:)];
        rotationGesture.delegate = self;
        [self addGestureRecognizer:rotationGesture];
        
        /* select tap gesture */
        UITapGestureRecognizer *selectGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selected:)];
        selectGesture.delegate = self;
        [self addGestureRecognizer:selectGesture];
        [selectGesture setNumberOfTapsRequired:1];
        
        self.originalBounds = self.bounds;

        /* Outline, Shadow Setting Values */
        self.objectBorderStyle = gnDefaultOutlineType;
        self.objectBorderWidth = grDefaultOutlineWidth;
        self.objectBorderColor = defaultOutlineColor;
        self.objectShadowStyle = 1;
        self.objectShadowBlur = 18.5f;
        self.objectShadowOffset = 0.0f;
        self.objectShadowColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f];
        self.objectCornerRadius = grDefaultOutlineCorner;
        
        self.borderLineLayer = [CAShapeLayer layer];
        self.borderLineLayer.strokeColor = [UIColor clearColor].CGColor;
        self.borderLineLayer.fillColor = nil;
        self.borderLineLayer.lineWidth = self.objectBorderWidth;
        self.borderLineLayer.frame = CGRectMake(-self.objectBorderWidth, -self.objectBorderWidth, self.mediaView.bounds.size.width+self.objectBorderWidth*2.0f, self.mediaView.bounds.size.height+self.objectBorderWidth*2.0f);
        [self.layer addSublayer:self.borderLineLayer];
        
        /* line dash */
        self.selectedLineLayer = [CAShapeLayer layer];
        self.selectedLineLayer.strokeColor = [UIColor greenColor].CGColor;
        self.selectedLineLayer.shadowColor = [UIColor redColor].CGColor;
        self.selectedLineLayer.shadowOpacity = 1.0f;
        self.selectedLineLayer.shadowOffset = CGSizeMake(2.0f, 2.0f);
        self.selectedLineLayer.fillColor = nil;
        self.selectedLineLayer.lineWidth = 4;
        self.selectedLineLayer.frame = self.bounds;
        [self.selectedLineLayer setLineJoin:kCALineJoinRound];
        [self.selectedLineLayer setLineDashPattern:
         [NSArray arrayWithObjects:[NSNumber numberWithInt:10],
          [NSNumber numberWithInt:5],
          nil]];
        [self.layer addSublayer:self.selectedLineLayer];
        
        self.maskLayer = [CAShapeLayer layer];
        self.mediaView.layer.mask = self.maskLayer;
        
        [self applySelectedLinePath];
        
        /* mask left arrow, left gesture */
        self.maskArrowLeft = [[MaskArrowView alloc] init:1];
        self.maskArrowLeft.center = CGPointMake(self.maskArrowLeft.frame.size.width/2, self.frame.size.height/2);
        [self addSubview:self.maskArrowLeft];
        self.maskArrowLeft.userInteractionEnabled = YES;
        
        UIPanGestureRecognizer *photoMaskLeftGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(mask_left:)];
        [photoMaskLeftGesture setMinimumNumberOfTouches:1];
        [photoMaskLeftGesture setMaximumNumberOfTouches:1];
        photoMaskLeftGesture.delegate = self;
        [self.maskArrowLeft addGestureRecognizer:photoMaskLeftGesture];
        
        /* mask right arrow, right gesture */
        self.maskArrowRight = [[MaskArrowView alloc] init:2];
        self.maskArrowRight.center = CGPointMake(self.frame.size.width - self.maskArrowRight.frame.size.width/2, self.frame.size.height/2);
        [self addSubview:self.maskArrowRight];
        self.maskArrowRight.userInteractionEnabled = YES;
        
        UIPanGestureRecognizer *photoMaskRightGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(mask_right:)];
        [photoMaskRightGesture setMinimumNumberOfTouches:1];
        [photoMaskRightGesture setMaximumNumberOfTouches:1];
        photoMaskRightGesture.delegate = self;
        [self.maskArrowRight addGestureRecognizer:photoMaskRightGesture];
        
        /* mask top arrow, top gesture */
        self.maskArrowTop = [[MaskArrowView alloc] init:3];
        self.maskArrowTop.center = CGPointMake(self.frame.size.width/2, self.maskArrowTop.frame.size.height/2);
        [self addSubview:self.maskArrowTop];
        self.maskArrowTop.userInteractionEnabled = YES;
        
        UIPanGestureRecognizer *photoMaskTopGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(mask_top:)];
        [photoMaskTopGesture setMinimumNumberOfTouches:1];
        [photoMaskTopGesture setMaximumNumberOfTouches:1];
        photoMaskTopGesture.delegate = self;
        [self.maskArrowTop addGestureRecognizer:photoMaskTopGesture];
        
        /* mask bottom arrow, bottom gesture */
        self.maskArrowBottom = [[MaskArrowView alloc] init:4];
        self.maskArrowBottom.center = CGPointMake(self.frame.size.width/2, self.frame.size.height - self.maskArrowBottom.frame.size.height/2);
        [self addSubview:self.maskArrowBottom];
        self.maskArrowBottom.userInteractionEnabled = YES;
        
        UIPanGestureRecognizer *photoMaskBottomGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(mask_bottom:)];
        [photoMaskBottomGesture setMinimumNumberOfTouches:1];
        [photoMaskBottomGesture setMaximumNumberOfTouches:1];
        photoMaskBottomGesture.delegate = self;
        [self.maskArrowBottom addGestureRecognizer:photoMaskBottomGesture];
        
        /* hidden mask arrows */
        self.maskArrowLeft.hidden = YES;
        self.maskArrowRight.hidden = YES;
        self.maskArrowTop.hidden = YES;
        self.maskArrowBottom.hidden = YES;
        
        [self applyBorder];
        
        CGFloat newScale = 1.0f;
        
        if (gnDefaultOutlineType > 1)
        {
            if (rWidth >= rHeight)
            {
                CGFloat rScaled = rWidth - grDefaultOutlineWidth*2.0f;
                newScale = rScaled / rWidth;
            }
            else
            {
                CGFloat rScaled = rHeight - grDefaultOutlineWidth*2.0f;
                newScale = rScaled / rHeight;
            }
        }
        
        self.transform = CGAffineTransformScale(self.transform, self.mySX, self.mySY);
        self.videoTransform = CGAffineTransformScale(self.videoTransform, self.mySX, self.mySY);
        
        CGAffineTransform transform = CGAffineTransformScale([self transform], newScale, newScale);
        self.transform = transform;
        
        self.videoTransform = CGAffineTransformScale(self.videoTransform, newScale, newScale);
        self.nationalVideoTransform = CGAffineTransformScale(self.nationalVideoTransform, newScale, newScale);
        self.scaleValue *= newScale;
        float radius = self.scaleValue * sqrtf(self.bounds.size.width*self.bounds.size.width + self.bounds.size.height*self.bounds.size.height)/2.0f;
        float angle = atanf(self.bounds.size.height/self.bounds.size.width);
        float rotAngle = angle + self.rotateAngle;
        CGPoint translatePoint = CGPointMake(self.center.x - cosf(rotAngle)*radius, self.center.y - sinf(rotAngle)*radius);
        
        self.nationalVideoTransform = CGAffineTransformMake(self.nationalVideoTransform.a, self.nationalVideoTransform.b, self.nationalVideoTransform.c, self.nationalVideoTransform.d, translatePoint.x, translatePoint.y);
        
        self.transform = CGAffineTransformScale(self.transform, self.mySX, self.mySY);
        self.videoTransform = CGAffineTransformScale(self.videoTransform, self.mySX, self.mySY);
        
        CGFloat currentScaleX = sqrtf(powf(self.transform.a, 2) + powf(self.transform.c, 2));
        
        if (currentScaleX == 0.0)
        {
            currentScaleX = 1;
        }
        
        transform = CGAffineTransformMakeScale(1 / currentScaleX, 1 / currentScaleX);
        self.maskArrowTop.transform = transform;
        self.maskArrowLeft.transform = transform;
        self.maskArrowRight.transform = transform;
        self.maskArrowBottom.transform = transform;
        
        self.maskArrowLeft.center = CGPointMake(self.maskArrowLeft.frame.size.width/2, self.bounds.size.height/2);
        self.maskArrowRight.center = CGPointMake(self.bounds.size.width-self.maskArrowRight.frame.size.width/2, self.bounds.size.height/2);
        self.maskArrowTop.center = CGPointMake(self.bounds.size.width/2, self.maskArrowTop.frame.size.height/2);
        self.maskArrowBottom.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height-self.maskArrowBottom.frame.size.height/2);
        
        self.selectedLineLayer.lineWidth = 4 / currentScaleX;
    }
    
    return self;
}

- (id)initWithVideoUrl:(NSURL*) url size:(CGSize) workspaceSize startPositions:(NSMutableArray*)startPositionArray endPositions:(NSMutableArray*)endPositionArray motionArray:(NSMutableArray*) motionValueArray
{
    self = [super init];
    
    if (self)
    {
        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor clearColor];
        self.layer.backgroundColor = [UIColor blackColor].CGColor;

        self.startPositionArray = [[NSMutableArray alloc] init];
        self.endPositionArray = [[NSMutableArray alloc] init];
        self.motionArray = [[NSMutableArray alloc] init];

        self.isMask = NO;
        self.isSelected = YES;
        self.mediaType = MEDIA_VIDEO;
        self.mediaUrl = url;
        self.isPlaying = NO;
        self.isArrowActived = NO;
        self.mfStartPosition = 0.0f;
        self.mfEndPosition = 0.0f;
        self.mfStartAnimationDuration = MIN_DURATION;
        self.mfEndAnimationDuration = MIN_DURATION;
        self.mySX = 1.0f;
        self.mySY = 1.0f;
        self.isExistAudioTrack = YES;
        self.workspaceSize = workspaceSize;
        self.rotateAngle = 0.0f;
        self.scaleValue = 1.0f;
        self.isImitationPhoto = NO;
        self.isReflection = NO;
        self.reflectionScale = 0.5f;
        self.reflectionAlpha = 0.5f;
        self.reflectionGap = 0.0f;
        self.reflectionDelta = CGPointZero;
        self.isKbEnabled = NO;
        self.nKbIn = KB_IN;
        self.kbFocusPoint = CGPointMake(0.5f, 0.5f);
        self.fKbScale = 1.1f;
        self.isShape = NO;
        self.objectChromaColor = [UIColor greenColor];
        self.isPhotoFromVideo = NO;
        self.isGrouped = NO;

        /* video asset */
        self.mediaAsset = nil;
        self.mediaAsset = [AVURLAsset assetWithURL:self.mediaUrl];
        
        _mediaVolume = 1.0f;
        
        self.mediaDuration = CMTimeGetSeconds(self.mediaAsset.duration);
        
        CGFloat startPosition = 0.0f;
        CGFloat endPosition = self.mediaDuration;
        
        [self.startPositionArray addObject:[NSNumber numberWithFloat:startPosition]];
        [self.endPositionArray addObject:[NSNumber numberWithFloat:endPosition]];
        [self.motionArray addObject:[NSNumber numberWithFloat:1.0f]];
        
        self.currentPosition = kCMTimeZero;
        
        NSArray *tracks = [self.mediaAsset tracksWithMediaType:AVMediaTypeVideo];
        if (tracks.count > 0)
            self.videoAssetTrack = [tracks lastObject];
        else
            self.videoAssetTrack = nil;
        
        // video view frame
        CGAffineTransform firstTransform = self.videoAssetTrack.preferredTransform;

        self.originalVideoSize = self.videoAssetTrack.naturalSize;
        
        float rScaleX, rScaleY;
        float rWidth, rHeight;
        
        rScaleX = self.originalVideoSize.width / workspaceSize.width;
        rScaleY = self.originalVideoSize.height / workspaceSize.height;
        
        if (rScaleX >= rScaleY)
        {
            rWidth = workspaceSize.width;
            rHeight = self.originalVideoSize.height * workspaceSize.width / self.originalVideoSize.width;
        }
        else
        {
            rHeight = workspaceSize.height;
            rWidth = self.originalVideoSize.width * workspaceSize.height / self.originalVideoSize.height;
        }
        
        self.nationalVideoTransform = CGAffineTransformIdentity;
        self.nationalVideoTransform = CGAffineTransformMakeScale(rWidth/self.originalVideoSize.width, rHeight/self.originalVideoSize.height);

        rScaleX = rWidth / workspaceSize.width;
        rScaleY = rHeight / workspaceSize.height;
        
        self.videoTransform = CGAffineTransformIdentity;
        self.videoTransform = CGAffineTransformMakeScale(rScaleX, rScaleY);
        
        [self setFrame:CGRectMake((workspaceSize.width - rWidth)/2, (workspaceSize.height - rHeight)/2, rWidth, rHeight)];
        
        self.nationalVideoTransform = CGAffineTransformConcat(self.nationalVideoTransform, CGAffineTransformMakeTranslation((workspaceSize.width - rWidth)/2, (workspaceSize.height - rHeight)/2));

        self.mediaView = [[UIView alloc] initWithFrame:self.bounds];
        self.mediaView.clipsToBounds = YES;
        self.mediaView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.mediaView];
        
        self.videoView = [[UIView alloc] initWithFrame:self.bounds];
        self.videoView.backgroundColor = [UIColor clearColor];
        [self.mediaView addSubview:self.videoView];
        
        self.originalVideoCenter = self.videoView.center;
        self.changedVideoCenter = self.videoView.center;

        //video thumbnail image
        self.imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:self.mediaAsset];
        self.imageGenerator.appliesPreferredTrackTransform = YES;
        
        if ([self isRetina])
            self.imageGenerator.maximumSize = CGSizeMake(self.videoAssetTrack.naturalSize.width*2, self.videoAssetTrack.naturalSize.height*2);
        else
            self.imageGenerator.maximumSize = self.videoAssetTrack.naturalSize;
        
        
        NSError *error;
        
        CGImageRef halfWayImage = [self.imageGenerator copyCGImageAtTime:kCMTimeZero actualTime:NULL error:&error];
        
        if (halfWayImage != NULL)
        {
            if ([self isRetina])
                self.originalImage = [[UIImage alloc] initWithCGImage:halfWayImage scale:2.0 orientation:UIImageOrientationUp];
            else
                self.originalImage = [[UIImage alloc] initWithCGImage:halfWayImage];

            self.imageView = [[UIImageView alloc] initWithImage:self.originalImage];
            [self.videoView addSubview:self.imageView];
            [self.imageView setFrame:CGRectMake(0, 0, rWidth, rHeight)];
            CGImageRelease(halfWayImage);
        }

        //init gesture
        /* zoom gesture init */
        UIPinchGestureRecognizer *scaleGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(zoom:)];
        scaleGesture.delegate = self;
        [self addGestureRecognizer:scaleGesture];
        
        UIRotationGestureRecognizer *rotationGesture = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotate:)];
        rotationGesture.delegate = self;
        [self addGestureRecognizer:rotationGesture];
        
        UITapGestureRecognizer *selectGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selected:)];
        selectGesture.delegate = self;
        [selectGesture setNumberOfTapsRequired:1];
        [self addGestureRecognizer:selectGesture];
        
        /* move gesture init */
        self.moveGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(move:)];
//                [self.moveGesture setMinimumNumberOfTouches:1];
                [self.moveGesture setMaximumNumberOfTouches:1];
        self.moveGesture.delegate = self;
        [self addGestureRecognizer:self.moveGesture];
        
        if(firstTransform.a == -1.0 && firstTransform.b == 0 && firstTransform.c == 0 && firstTransform.d == -1.0)
        {
            self.transform = CGAffineTransformRotate(self.transform, (-1)*firstTransform.d*M_PI);
            self.videoTransform = CGAffineTransformRotate(self.videoTransform, (-1)*firstTransform.d*M_PI);
            
            CGAffineTransform transform = CGAffineTransformMakeRotation(firstTransform.d*M_PI);
            CATransform3D transform3D = CATransform3DMakeAffineTransform(transform);
            self.imageView.layer.transform = transform3D;
        }

        self.originalBounds = self.bounds;

        /* outline, shadow setting values */
        self.objectBorderStyle = gnDefaultOutlineType;
        self.objectBorderWidth = grDefaultOutlineWidth;
        self.objectBorderColor = defaultOutlineColor;
        self.objectCornerRadius = 0.0f;
        self.objectShadowStyle = 1;
        self.objectShadowBlur = 18.5f;
        self.objectShadowOffset = 0.0f;
        self.objectShadowColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f];

        self.borderLineLayer = [CAShapeLayer layer];
        self.borderLineLayer.strokeColor = [UIColor clearColor].CGColor;
        self.borderLineLayer.fillColor = nil;
        self.borderLineLayer.lineWidth = self.objectBorderWidth;
        self.borderLineLayer.frame = CGRectMake(-self.objectBorderWidth, -self.objectBorderWidth, self.mediaView.bounds.size.width+self.objectBorderWidth*2.0f, self.mediaView.bounds.size.height+self.objectBorderWidth*2.0f);
        [self.layer addSublayer:self.borderLineLayer];

        /* line dash */
        self.selectedLineLayer = [CAShapeLayer layer];
        self.selectedLineLayer.strokeColor = [UIColor greenColor].CGColor;
        self.selectedLineLayer.shadowColor = [UIColor redColor].CGColor;
        self.selectedLineLayer.shadowOpacity = 1.0f;
        self.selectedLineLayer.shadowOffset = CGSizeMake(2.0f, 2.0f);
        self.selectedLineLayer.fillColor = nil;
        self.selectedLineLayer.lineWidth = 4;
        self.selectedLineLayer.frame = self.bounds;
        [self.selectedLineLayer setLineJoin:kCALineJoinRound];
        [self.selectedLineLayer setLineDashPattern:
         [NSArray arrayWithObjects:[NSNumber numberWithInt:10],
          [NSNumber numberWithInt:5],
          nil]];
        [self.layer addSublayer:self.selectedLineLayer];

        self.maskLayer = [CAShapeLayer layer];
        self.mediaView.layer.mask = self.maskLayer;

        [self applySelectedLinePath];
        
        /* mask left arrow, left gesture */
        self.maskArrowLeft = [[MaskArrowView alloc] init:1];
        self.maskArrowLeft.center = CGPointMake(self.maskArrowLeft.frame.size.width/2, self.frame.size.height/2);
        [self addSubview:self.maskArrowLeft];
        self.maskArrowLeft.userInteractionEnabled = YES;
        
        UIPanGestureRecognizer *photoMaskLeftGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(mask_left:)];
        [photoMaskLeftGesture setMinimumNumberOfTouches:1];
        [photoMaskLeftGesture setMaximumNumberOfTouches:1];
        photoMaskLeftGesture.delegate = self;
        [self.maskArrowLeft addGestureRecognizer:photoMaskLeftGesture];
        
        /* mask right arrow, right gesture */
        self.maskArrowRight = [[MaskArrowView alloc] init:2];
        self.maskArrowRight.center = CGPointMake(self.frame.size.width - self.maskArrowRight.frame.size.width/2, self.frame.size.height/2);
        [self addSubview:self.maskArrowRight];
        self.maskArrowRight.userInteractionEnabled = YES;
        
        UIPanGestureRecognizer *photoMaskRightGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(mask_right:)];
        [photoMaskRightGesture setMinimumNumberOfTouches:1];
        [photoMaskRightGesture setMaximumNumberOfTouches:1];
        photoMaskRightGesture.delegate = self;
        [self.maskArrowRight addGestureRecognizer:photoMaskRightGesture];
        
        /* mask top arrow, top gesture */
        self.maskArrowTop = [[MaskArrowView alloc] init:3];
        self.maskArrowTop.center = CGPointMake(self.frame.size.width/2, self.maskArrowTop.frame.size.height/2);
        [self addSubview:self.maskArrowTop];
        self.maskArrowTop.userInteractionEnabled = YES;
        
        UIPanGestureRecognizer *photoMaskTopGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(mask_top:)];
        [photoMaskTopGesture setMinimumNumberOfTouches:1];
        [photoMaskTopGesture setMaximumNumberOfTouches:1];
        photoMaskTopGesture.delegate = self;
        [self.maskArrowTop addGestureRecognizer:photoMaskTopGesture];
        
        /* mask bottom arrow, bottom gesture */
        self.maskArrowBottom = [[MaskArrowView alloc] init:4];
        self.maskArrowBottom.center = CGPointMake(self.frame.size.width/2, self.frame.size.height - self.maskArrowBottom.frame.size.height/2);
        [self addSubview:self.maskArrowBottom];
        self.maskArrowBottom.userInteractionEnabled = YES;
        
        UIPanGestureRecognizer *photoMaskBottomGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(mask_bottom:)];
        [photoMaskBottomGesture setMinimumNumberOfTouches:1];
        [photoMaskBottomGesture setMaximumNumberOfTouches:1];
        photoMaskBottomGesture.delegate = self;
        [self.maskArrowBottom addGestureRecognizer:photoMaskBottomGesture];
        
        /* hidden mask arrows */
        self.maskArrowLeft.hidden = YES;
        self.maskArrowRight.hidden = YES;
        self.maskArrowTop.hidden = YES;
        self.maskArrowBottom.hidden = YES;
        
        [self applyBorder];

        CGFloat newScale = 1.0f;

        if (gnDefaultOutlineType > 1)
        {
            if (rWidth >= rHeight)
            {
                CGFloat rScaled = rWidth - grDefaultOutlineWidth*2.0f;
                newScale = rScaled / rWidth;
            }
            else
            {
                CGFloat rScaled = rHeight - grDefaultOutlineWidth*2.0f;
                newScale = rScaled / rHeight;
            }
        }
        
        self.transform = CGAffineTransformScale(self.transform, self.mySX, self.mySY);
        self.videoTransform = CGAffineTransformScale(self.videoTransform, self.mySX, self.mySY);
        
        CGAffineTransform transform = CGAffineTransformScale([self transform], newScale, newScale);
        self.transform = transform;
        
        self.videoTransform = CGAffineTransformScale(self.videoTransform, newScale, newScale);
        self.nationalVideoTransform = CGAffineTransformScale(self.nationalVideoTransform, newScale, newScale);
        self.scaleValue *= newScale;
        float radius = self.scaleValue * sqrtf(self.bounds.size.width*self.bounds.size.width + self.bounds.size.height*self.bounds.size.height)/2.0f;
        float angle = atanf(self.bounds.size.height/self.bounds.size.width);
        float rotAngle = angle + self.rotateAngle;
        CGPoint translatePoint = CGPointMake(self.center.x - cosf(rotAngle)*radius, self.center.y - sinf(rotAngle)*radius);
        
        self.nationalVideoTransform = CGAffineTransformMake(self.nationalVideoTransform.a, self.nationalVideoTransform.b, self.nationalVideoTransform.c, self.nationalVideoTransform.d, translatePoint.x, translatePoint.y);
        
        self.transform = CGAffineTransformScale(self.transform, self.mySX, self.mySY);
        self.videoTransform = CGAffineTransformScale(self.videoTransform, self.mySX, self.mySY);
        
        CGFloat currentScaleX = sqrtf(powf(self.transform.a, 2) + powf(self.transform.c, 2));
        
        if (currentScaleX == 0.0)
        {
            currentScaleX = 1;
        }
        
        transform = CGAffineTransformMakeScale(1 / currentScaleX, 1 / currentScaleX);
        self.maskArrowTop.transform = transform;
        self.maskArrowLeft.transform = transform;
        self.maskArrowRight.transform = transform;
        self.maskArrowBottom.transform = transform;
        
        self.maskArrowLeft.center = CGPointMake(self.maskArrowLeft.frame.size.width/2, self.bounds.size.height/2);
        self.maskArrowRight.center = CGPointMake(self.bounds.size.width-self.maskArrowRight.frame.size.width/2, self.bounds.size.height/2);
        self.maskArrowTop.center = CGPointMake(self.bounds.size.width/2, self.maskArrowTop.frame.size.height/2);
        self.maskArrowBottom.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height-self.maskArrowBottom.frame.size.height/2);
        
        self.selectedLineLayer.lineWidth = 4 / currentScaleX;
    }
    
    return self;
}

-(id) initWithText:(NSString*) defaultText size:(CGSize) workspaceSize
{
    textMaxSize = workspaceSize;
    
    self = [super initWithFrame:CGRectMake((workspaceSize.width - textMaxSize.width)/2, (workspaceSize.height - textMaxSize.height)/2, textMaxSize.width, textMaxSize.height)];
    
    if (self)
    {
        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor clearColor];

        self.startPositionArray = [[NSMutableArray alloc] init];
        self.endPositionArray = [[NSMutableArray alloc] init];
        self.motionArray = [[NSMutableArray alloc] init];

        [self.startPositionArray addObject:[NSNumber numberWithFloat:0.0f]];
        [self.endPositionArray addObject:[NSNumber numberWithFloat:grTextDefaultDuration]];
        [self.motionArray addObject:[NSNumber numberWithFloat:1.0f]];

        self.mediaUrl = nil;
        self.mediaType = MEDIA_TEXT;
        self.isSelected = YES;
        self.isMask = YES;
        self.isPlaying = NO;
        self.isArrowActived = NO;
        self.mfStartPosition = 0.0f;
        self.mfEndPosition = 0.0f;
        self.mfStartAnimationDuration = MIN_DURATION;
        self.mfEndAnimationDuration = MIN_DURATION;
        self.mySX = 1.0f;
        self.mySY = 1.0f;
        self.isExistAudioTrack = NO;
        self.isImitationPhoto = NO;
        self.isReflection = NO;
        self.reflectionScale = 0.5f;
        self.reflectionAlpha = 0.5f;
        self.reflectionGap = 0.0f;
        self.isKbEnabled = isKenBurnsEnabled;
        self.nKbIn = gnKBZoomInOutType;
        self.kbFocusPoint = CGPointMake(0.5f, 0.5f);
        self.fKbScale = grKBScale;
        self.isShape = NO;
        self.objectChromaColor = [UIColor blackColor];
        self.isPhotoFromVideo = NO;
        self.isGrouped = NO;

        self.mediaView = [[UIView alloc] initWithFrame:self.bounds];
        self.mediaView.clipsToBounds = YES;
        self.mediaView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.mediaView];
        
        /****************** UITextView *******************************/
        self.textView = [[UITextViewExtras alloc] initWithFrame:self.bounds];
        self.textView.backgroundColor = [UIColor clearColor];
        self.textView.textColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f];
        self.textView.textAlignment = NSTextAlignmentCenter;
        self.textView.scrollEnabled = NO;
        self.textView.contentInset = UIEdgeInsetsZero;
        [self.textView setAutocapitalizationType:UITextAutocapitalizationTypeNone];
        [self.textView setAutocorrectionType:UITextAutocorrectionTypeNo];
        [self.textView setSpellCheckingType:UITextSpellCheckingTypeNo];
        [self.textView setDataDetectorTypes:UIDataDetectorTypeNone];
        self.textView.selectable = NO;
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        {
            self.textView.font = rememberedFont;
            self.textObjectFontSize = IPHONE_DEFAULT_FONT_SIZE;
        }
        else
        {
            self.textView.font = rememberedFont;
            self.textObjectFontSize = IPAD_DEFAULT_FONT_SIZE;
        }
        
        self.textView.text = defaultText;
        self.textView.delegate = self;
        self.textView.customDelegate = self;
        [self.mediaView addSubview:self.textView];
        
        self.textView.editable = YES;
        [self.textView becomeFirstResponder];
        
        self.frame = CGRectMake((workspaceSize.width-self.textView.frame.size.width)/2, 0.0f, self.textView.frame.size.width, self.textView.frame.size.height);
        self.mediaView.frame = CGRectMake(0.0f, 0.0f, self.textView.frame.size.width, self.textView.frame.size.height);
        /**********************************************************************************/
        
        /* zoom gesture init */
        UIPinchGestureRecognizer *zoomGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(zoom:)];
        zoomGesture.delegate = self;
        [self addGestureRecognizer:zoomGesture];
        
        /* move gesture init */
        self.moveGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(move:)];
        [self.moveGesture setMinimumNumberOfTouches:1];
        [self.moveGesture setMaximumNumberOfTouches:1];
        self.moveGesture.delegate = self;
        [self addGestureRecognizer:self.moveGesture];
        
        /* rotate gesture */
        UIRotationGestureRecognizer *rotationGesture = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotate:)];
        rotationGesture.delegate = self;
        [self addGestureRecognizer:rotationGesture];
        
        /* select tap gesture */
        UITapGestureRecognizer *selectGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selected:)];
        selectGesture.delegate = self;
        [self addGestureRecognizer:selectGesture];
        [selectGesture setNumberOfTapsRequired:1];
        
        /* longpress gesture */
        UILongPressGestureRecognizer *pressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressText:)];
        pressGesture.delegate = self;
        [self addGestureRecognizer:pressGesture];
        
        self.originalBounds = self.bounds;
        
        /* Outline, Shadow Setting Valuse */
        self.objectBorderStyle = 1;
        self.objectBorderWidth = 15.0f;
        self.objectBorderColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f];
        self.objectCornerRadius = 5.0f;
        self.objectShadowStyle = 1;
        self.objectShadowBlur = 3.5f;
        self.objectShadowOffset = 5.0f;
        self.objectShadowColor = [UIColor yellowColor];
        
        self.borderLineLayer = [CAShapeLayer layer];
        self.borderLineLayer.strokeColor = [UIColor clearColor].CGColor;
        self.borderLineLayer.fillColor = nil;
        self.borderLineLayer.lineWidth = self.objectBorderWidth;
        self.borderLineLayer.frame = CGRectMake(-self.objectBorderWidth, -self.objectBorderWidth, self.mediaView.bounds.size.width+self.objectBorderWidth*2.0f, self.mediaView.bounds.size.height+self.objectBorderWidth*2.0f);
        [self.layer addSublayer:self.borderLineLayer];
        
        /* line dash */
        self.selectedLineLayer = [CAShapeLayer layer];
        self.selectedLineLayer.strokeColor = [UIColor greenColor].CGColor;
        self.selectedLineLayer.shadowColor = [UIColor redColor].CGColor;
        self.selectedLineLayer.shadowOpacity = 1.0f;
        self.selectedLineLayer.shadowOffset = CGSizeMake(2.0f, 2.0f);
        self.selectedLineLayer.fillColor = nil;
        self.selectedLineLayer.lineWidth = 4;
        self.selectedLineLayer.frame = self.bounds;
        [self.selectedLineLayer setLineJoin:kCALineJoinRound];
        [self.selectedLineLayer setLineDashPattern:
         [NSArray arrayWithObjects:[NSNumber numberWithInt:10],
          [NSNumber numberWithInt:5],
          nil]];
        [self.layer addSublayer:self.selectedLineLayer];
        
        self.maskLayer = [CAShapeLayer layer];
        self.mediaView.layer.mask = self.maskLayer;

        [self applySelectedLinePath];
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        {
            [self setIPhoneKeyboard:[[BSKeyboardControls alloc] initWithFields:@[self.textView,]]];
            [self.iPhoneKeyboard setDelegate:self];
        }
        
        self.textView.textAlignment = rememberedTextAlignment;
        self.isBold = isRememberedBold;
        self.isItalic = isRememberedItalic;
        self.isUnderline = isRememberedUnderline;
        self.isStroke = isRememberedStroke;
        
        [self initTextAttributed];
        
        /* mask left arrow, left gesture */
        self.maskArrowLeft = [[MaskArrowView alloc] init:1];
        self.maskArrowLeft.center = CGPointMake(self.maskArrowLeft.frame.size.width/2, self.frame.size.height/2);
        [self addSubview:self.maskArrowLeft];
        self.maskArrowLeft.userInteractionEnabled = YES;
        
        UIPanGestureRecognizer *photoMaskLeftGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(mask_left:)];
        [photoMaskLeftGesture setMinimumNumberOfTouches:1];
        [photoMaskLeftGesture setMaximumNumberOfTouches:1];
        photoMaskLeftGesture.delegate = self;
        [self.maskArrowLeft addGestureRecognizer:photoMaskLeftGesture];
        
        /* mask right arrow, right gesture */
        self.maskArrowRight = [[MaskArrowView alloc] init:2];
        self.maskArrowRight.center = CGPointMake(self.frame.size.width - self.maskArrowRight.frame.size.width/2, self.frame.size.height/2);
        [self addSubview:self.maskArrowRight];
        self.maskArrowRight.userInteractionEnabled = YES;
        
        UIPanGestureRecognizer *photoMaskRightGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(mask_right:)];
        [photoMaskRightGesture setMinimumNumberOfTouches:1];
        [photoMaskRightGesture setMaximumNumberOfTouches:1];
        photoMaskRightGesture.delegate = self;
        [self.maskArrowRight addGestureRecognizer:photoMaskRightGesture];
        
        /* mask top arrow, top gesture */
        self.maskArrowTop = [[MaskArrowView alloc] init:3];
        self.maskArrowTop.center = CGPointMake(self.frame.size.width/2, self.maskArrowTop.frame.size.height/2);
        [self addSubview:self.maskArrowTop];
        self.maskArrowTop.userInteractionEnabled = YES;
        
        UIPanGestureRecognizer *photoMaskTopGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(mask_top:)];
        [photoMaskTopGesture setMinimumNumberOfTouches:1];
        [photoMaskTopGesture setMaximumNumberOfTouches:1];
        photoMaskTopGesture.delegate = self;
        [self.maskArrowTop addGestureRecognizer:photoMaskTopGesture];
        
        /* mask bottom arrow, bottom gesture */
        self.maskArrowBottom = [[MaskArrowView alloc] init:4];
        self.maskArrowBottom.center = CGPointMake(self.frame.size.width/2, self.frame.size.height-self.maskArrowBottom.frame.size.height/2);
        [self addSubview:self.maskArrowBottom];
        self.maskArrowBottom.userInteractionEnabled = YES;
        
        UIPanGestureRecognizer *photoMaskBottomGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(mask_bottom:)];
        [photoMaskBottomGesture setMinimumNumberOfTouches:1];
        [photoMaskBottomGesture setMaximumNumberOfTouches:1];
        photoMaskBottomGesture.delegate = self;
        [self.maskArrowBottom addGestureRecognizer:photoMaskBottomGesture];

        self.textView.keyboardAppearance = UIKeyboardAppearanceDark;
        
        self.photoFilterIndex = 0;
        self.photoFilterValue = 0.5f;
        
        self.kbFocusImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.bounds.size.width/2.0f - 25.0f, self.bounds.size.height/2.0f - 25.0f, 50.0f, 50.0f)];
        [self.kbFocusImageView setImage:[UIImage imageNamed:@"focus"]];
        self.kbFocusImageView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.kbFocusImageView];
        self.kbFocusImageView.hidden = YES;
    }
    
    return self;
}

- (id)initWithMusicUrl:(NSURL*) url size:(CGSize) workspaceSize
{
    self = [super init];
    
    if (self)
    {
        self.imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"musicSymbol"]];
        self.imageView.backgroundColor = [UIColor clearColor];
        [self.imageView setFrame:CGRectMake(0, 0, self.imageView.frame.size.width, self.imageView.frame.size.height)];
        [self addSubview:self.imageView];
        self.imageView.userInteractionEnabled = NO;
        
        self.frame = CGRectMake((workspaceSize.width-self.imageView.frame.size.width)/2, (workspaceSize.height-self.imageView.frame.size.height)/2, self.imageView.frame.size.width, self.imageView.frame.size.height);
        
        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor clearColor];

        self.isMask = NO;
        self.isSelected = YES;
        self.mediaType = MEDIA_MUSIC;
        self.mediaUrl = url;
        self.isPlaying = NO;
        self.isArrowActived = NO;
        self.mfStartPosition = 0.0f;
        self.mfEndPosition = 0.0f;
        self.mfStartAnimationDuration = MIN_DURATION;
        self.mfEndAnimationDuration = MIN_DURATION;
        self.isExistAudioTrack = YES;
        self.isKbEnabled = NO;
        self.nKbIn = KB_IN;
        self.kbFocusPoint = CGPointMake(0.5f, 0.5f);
        self.fKbScale = 1.1f;
        self.isShape = NO;
        self.isPhotoFromVideo = NO;
        self.isGrouped = NO;

        /* video asset */
        self.mediaAsset = nil;
        self.mediaAsset = [AVURLAsset assetWithURL:self.mediaUrl];
        _mediaVolume = 1.0f;
        
        self.mediaDuration = CMTimeGetSeconds(self.mediaAsset.duration);
        
        CGFloat startPosition = 0.0f;
        CGFloat endPosition = self.mediaDuration;
        
        self.startPositionArray = [[NSMutableArray alloc] init];
        self.endPositionArray = [[NSMutableArray alloc] init];
        self.motionArray = [[NSMutableArray alloc] init];

        [self.startPositionArray addObject:[NSNumber numberWithFloat:startPosition]];
        [self.endPositionArray addObject:[NSNumber numberWithFloat:endPosition]];
        [self.motionArray addObject:[NSNumber numberWithFloat:1.0f]];
        
        self.currentPosition = kCMTimeZero;
        
        /* move gesture init */
        self.moveGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(move:)];
        [self.moveGesture setMinimumNumberOfTouches:1];
        [self.moveGesture setMaximumNumberOfTouches:1];
        self.moveGesture.delegate = self;
        [self addGestureRecognizer:self.moveGesture];
        
        UITapGestureRecognizer *selectGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selected:)];
        selectGesture.delegate = self;
        [selectGesture setNumberOfTapsRequired:1];
        [self addGestureRecognizer:selectGesture];

        /* line dash */
        self.selectedLineLayer = [CAShapeLayer layer];
        self.selectedLineLayer.strokeColor = [UIColor greenColor].CGColor;
        self.selectedLineLayer.shadowColor = [UIColor redColor].CGColor;
        self.selectedLineLayer.shadowOpacity = 1.0f;
        self.selectedLineLayer.shadowOffset = CGSizeMake(2.0f, 2.0f);
        self.selectedLineLayer.fillColor = nil;
        self.selectedLineLayer.lineWidth = 4;
        self.selectedLineLayer.frame = self.bounds;
        [self.selectedLineLayer setLineJoin:kCALineJoinRound];
        [self.selectedLineLayer setLineDashPattern:
         [NSArray arrayWithObjects:[NSNumber numberWithInt:10],
          [NSNumber numberWithInt:5],
          nil]];
        [self.layer addSublayer:self.selectedLineLayer];
        
        [self applySelectedLinePath];
    }
    
    return self;
}


#pragma mark - 

-(BOOL)isRetina
{
    return ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] && ([UIScreen mainScreen].scale == 2.0));
}

- (CGAffineTransform) getVideoTransform
{
    return self.videoTransform;
}

-(CGFloat) getVideoTotalDuration
{
    CGFloat totalDuration = 0.0f;
    
    for (int i=0; i<self.motionArray.count; i++)
    {
        NSNumber* motionValueNum = [self.motionArray objectAtIndex:i];
        NSNumber* startPosNum = [self.startPositionArray objectAtIndex:i];
        NSNumber* endPosNum = [self.endPositionArray objectAtIndex:i];
        
        CGFloat motionValue = [motionValueNum floatValue];
        CGFloat startPosition = [startPosNum floatValue];
        CGFloat endPosition = [endPosNum floatValue];
        
        totalDuration += (endPosition - startPosition)/motionValue;
    }
    
    return totalDuration;
}

- (void) setIndex:(int)index
{
    self.objectIndex = index;
}

- (void) setVolume:(CGFloat) volume
{
    self.mediaVolume = volume;
}

- (CGFloat) getVolume
{
    return self.mediaVolume;
}

- (void) updateVideoThumbnail:(CGFloat) startTime
{
    if (self.imageGenerator != nil)
        self.imageGenerator = nil;
    
    self.imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:self.mediaAsset];
    self.imageGenerator.appliesPreferredTrackTransform = YES;
    
    if ([self isRetina])
        self.imageGenerator.maximumSize = CGSizeMake(self.videoAssetTrack.naturalSize.width*2, self.videoAssetTrack.naturalSize.height*2);
    else
        self.imageGenerator.maximumSize = self.videoAssetTrack.naturalSize;
    
    NSError *error;
    
    CGImageRef halfWayImage = [self.imageGenerator copyCGImageAtTime:CMTimeMake(startTime*self.mediaAsset.duration.timescale, self.mediaAsset.duration.timescale) actualTime:NULL error:&error];
    
    if (halfWayImage != NULL)
    {
        UIImage *videoScreen = nil;
        
        if ([self isRetina])
            videoScreen = [[UIImage alloc] initWithCGImage:halfWayImage scale:2.0 orientation:UIImageOrientationUp];
        else
            videoScreen = [[UIImage alloc] initWithCGImage:halfWayImage];
        
        [self.imageView setImage:videoScreen];
        CGImageRelease(halfWayImage);
    }
}


#pragma mark -
/**********************************************************************
 update video object thumb image on workspace with a selected filter
************************************************************************/

-(void) changeVideoThumbWithFilter
{
    self.mediaAsset = [AVURLAsset assetWithURL:self.mediaUrl];
    
    //video thumbnail image
    if (self.imageGenerator != nil)
        self.imageGenerator = nil;

    self.imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:self.mediaAsset];
    self.imageGenerator.appliesPreferredTrackTransform = YES;
    
    if ([self isRetina])
        self.imageGenerator.maximumSize = CGSizeMake(self.videoAssetTrack.naturalSize.width*2, self.videoAssetTrack.naturalSize.height*2);
    else
        self.imageGenerator.maximumSize = self.videoAssetTrack.naturalSize;
    
    NSError *error;
    
    CGImageRef halfWayImage = [self.imageGenerator copyCGImageAtTime:kCMTimeZero actualTime:NULL error:&error];
    
    if (halfWayImage != NULL)
    {
        if ([self isRetina])
            self.originalImage = [[UIImage alloc] initWithCGImage:halfWayImage scale:2.0 orientation:UIImageOrientationUp];
        else
            self.originalImage = [[UIImage alloc] initWithCGImage:halfWayImage];
        
        self.imageView.image = self.originalImage;
        
        CGImageRelease(halfWayImage);
    }
}


#pragma mark -
#pragma mark - Object Selected Gesture Function

/*
 name - selected
 param - (UITapGestureRecognizer *)gestureRecognizer
 return - non
 description - object select gesture function.
 created - 11/15/2013
 author - Yinjing Li.
 */

- (void)selected:(UITapGestureRecognizer *)gestureRecognizer
{
    [self object_actived];
    
    [self objectSettingShow];
    
    if (((self.mediaType == MEDIA_PHOTO) || (self.mediaType == MEDIA_TEXT)) && (self.kbFocusImageView.hidden == NO))
    {
        CGPoint point = [gestureRecognizer locationInView:self];

        self.kbFocusImageView.center = point;
        self.kbFocusPoint = CGPointMake(point.x / self.bounds.size.width, point.y / self.bounds.size.height);
    }
}

- (void) object_actived
{
    self.isSelected = YES;
    self.selectedLineLayer.hidden = NO;
    
    if ([self.delegate respondsToSelector:@selector(mediaObjectSelected:)])
    {
        [self.delegate mediaObjectSelected:self.objectIndex];
    }
}

-(void) maskArrowsShow
{
    self.isMask = YES;
    self.maskArrowLeft.hidden = NO;
    self.maskArrowRight.hidden = NO;
    self.maskArrowTop.hidden = NO;
    self.maskArrowBottom.hidden = NO;
}

-(void) maskArrowsHidden
{
    self.isMask = NO;
    self.maskArrowLeft.hidden = YES;
    self.maskArrowRight.hidden = YES;
    self.maskArrowTop.hidden = YES;
    self.maskArrowBottom.hidden = YES;
}


#pragma mark -
#pragma mark - Object Zoom, Rotate and Move Gesture Functions

/*
 name - zoom
 param - (UIPinchGestureRecognizer *)gestureRecognizer
 return - non
 description - zoom gesture function.
 created - 10/27/2013
 author - Yinjing Li.
 */

- (void)zoom:(UIPinchGestureRecognizer *)gestureRecognizer
{
    if([gestureRecognizer state] == UIGestureRecognizerStateBegan)
    {
        _lastScaleFactor = [gestureRecognizer scale];
        
        [self object_actived];
    }

    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan || [gestureRecognizer state] == UIGestureRecognizerStateChanged)
    {
        self.transform = CGAffineTransformScale(self.transform, self.mySX, self.mySY);
        self.videoTransform = CGAffineTransformScale(self.videoTransform, self.mySX, self.mySY);

        CGFloat currentScale = [[[gestureRecognizer view].layer valueForKeyPath:@"transform.scale"] floatValue];
        
        const CGFloat kMaxScale = 3.0f;
        const CGFloat kMinScale = 0.3f;
        
        CGFloat newScale = 1 -  (_lastScaleFactor - [gestureRecognizer scale]);
        
        newScale = MIN(newScale, kMaxScale / currentScale);
        newScale = MAX(newScale, kMinScale / currentScale);
        
        CGAffineTransform transform = CGAffineTransformScale([[gestureRecognizer view] transform], newScale, newScale);
        [gestureRecognizer view].transform = transform;
        _lastScaleFactor = [gestureRecognizer scale];
        
        if ((self.mediaType == MEDIA_VIDEO)||(self.mediaType == MEDIA_GIF))
        {
            self.videoTransform = CGAffineTransformScale(self.videoTransform, newScale, newScale);
            self.nationalVideoTransform = CGAffineTransformScale(self.nationalVideoTransform, newScale, newScale);
            self.scaleValue *= newScale ;
            
            float radius = self.scaleValue * sqrtf(self.bounds.size.width*self.bounds.size.width + self.bounds.size.height*self.bounds.size.height)/2.0f;
            float angle = atanf(self.bounds.size.height/self.bounds.size.width);
            float rotAngle = angle + self.rotateAngle;
            CGPoint translatePoint = CGPointMake(self.center.x - cosf(rotAngle)*radius, self.center.y - sinf(rotAngle)*radius);
            
            self.nationalVideoTransform = CGAffineTransformMake(self.nationalVideoTransform.a, self.nationalVideoTransform.b, self.nationalVideoTransform.c, self.nationalVideoTransform.d, translatePoint.x, translatePoint.y);
        }
        
        self.transform = CGAffineTransformScale(self.transform, self.mySX, self.mySY);
        self.videoTransform = CGAffineTransformScale(self.videoTransform, self.mySX, self.mySY);
    }
    
    CGFloat currentScaleX = sqrtf(powf(self.transform.a, 2) + powf(self.transform.c, 2));
   
    if (currentScaleX == 0.0)
        currentScaleX = 1;
    
    CGAffineTransform transform = CGAffineTransformMakeScale(1 / currentScaleX, 1 / currentScaleX);
    self.maskArrowTop.transform = transform;
    self.maskArrowLeft.transform = transform;
    self.maskArrowRight.transform = transform;
    self.maskArrowBottom.transform = transform;

    self.maskArrowLeft.center = CGPointMake(self.maskArrowLeft.frame.size.width/2, self.bounds.size.height/2);
    self.maskArrowRight.center = CGPointMake(self.bounds.size.width-self.maskArrowRight.frame.size.width/2, self.bounds.size.height/2);
    self.maskArrowTop.center = CGPointMake(self.bounds.size.width/2, self.maskArrowTop.frame.size.height/2);
    self.maskArrowBottom.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height-self.maskArrowBottom.frame.size.height/2);
    
    self.selectedLineLayer.lineWidth = 4 / currentScaleX;
    
    if ((self.mediaType == MEDIA_PHOTO)||(self.mediaType == MEDIA_TEXT))
        self.kbFocusImageView.transform = transform;
}


/*
 name - rotate
 param - (UIPanGestureRecognizer *)gestureRecognizer
 return - non
 description - rotate gesture function.
 created - 11/14/2013
 author - Yinjing Li.
 */

- (void)rotate:(UIRotationGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan || [gestureRecognizer state] == UIGestureRecognizerStateChanged)
    {
        if ((self.mediaType == MEDIA_VIDEO)||(self.mediaType == MEDIA_GIF))
        {
            self.transform = CGAffineTransformScale(self.transform, self.mySX, self.mySY);
            self.videoTransform = CGAffineTransformScale(self.videoTransform, self.mySX, self.mySY);
            self.transform = CGAffineTransformRotate(self.transform, [gestureRecognizer rotation]);
            self.videoTransform = CGAffineTransformRotate(self.videoTransform, [gestureRecognizer rotation]);
            
            float radius = self.scaleValue * sqrtf(self.bounds.size.width*self.bounds.size.width + self.bounds.size.height*self.bounds.size.height)/2.0f;
            float angle = atanf(self.bounds.size.height/self.bounds.size.width);
            self.rotateAngle = self.rotateAngle + [gestureRecognizer rotation];
            float rotAngle = angle + self.rotateAngle;
            
            CGPoint translatePoint = CGPointMake(self.center.x - cosf(rotAngle)*radius, self.center.y - sinf(rotAngle)*radius);
            self.nationalVideoTransform = CGAffineTransformRotate(self.nationalVideoTransform, [gestureRecognizer rotation]);
            self.nationalVideoTransform = CGAffineTransformMake(self.nationalVideoTransform.a, self.nationalVideoTransform.b, self.nationalVideoTransform.c, self.nationalVideoTransform.d, translatePoint.x, translatePoint.y);
            self.transform = CGAffineTransformScale(self.transform, self.mySX, self.mySY);
            self.videoTransform = CGAffineTransformScale(self.videoTransform, self.mySX, self.mySY);
        }
        else if((self.mediaType == MEDIA_PHOTO)||(self.mediaType == MEDIA_TEXT))
        {
            self.transform = CGAffineTransformScale(self.transform, self.mySX, self.mySY);
            self.transform = CGAffineTransformRotate(self.transform, [gestureRecognizer rotation]);
            self.transform = CGAffineTransformScale(self.transform, self.mySX, self.mySY);
            self.rotateAngle = self.rotateAngle + [gestureRecognizer rotation];
        }
        
        [gestureRecognizer setRotation:0];
        
        if ([gestureRecognizer state] == UIGestureRecognizerStateBegan)
        {
            [self object_actived];
        }
    }
}


/*
 name - move
 param - (UIPanGestureRecognizer *)gestureRecognizer
 return - non
 description - move gesture function.
 created - 10/27/2013
 author - Yinjing Li.
 */

- (void)move:(UIPanGestureRecognizer *)gestureRecognizer
{
    if (!self.isMask)
    {
        CGPoint translatedPoint = [gestureRecognizer translationInView:self.superview];

        if([gestureRecognizer state] == UIGestureRecognizerStateBegan)
        {
            _firstX = self.center.x;
            _firstY = self.center.y;
            [self object_actived];
        }
        
        translatedPoint = CGPointMake(_firstX+translatedPoint.x, _firstY + translatedPoint.y);
        [self setCenter:translatedPoint];
        
        float radius = self.scaleValue * sqrtf(self.bounds.size.width*self.bounds.size.width + self.bounds.size.height*self.bounds.size.height)/2.0f;
        float angle = atanf(self.bounds.size.height/self.bounds.size.width);
        float rotAngle = angle + self.rotateAngle;
        CGPoint translatePoint = CGPointMake(self.center.x - cosf(rotAngle)*radius, self.center.y - sinf(rotAngle)*radius);
        self.nationalVideoTransform = CGAffineTransformMake(self.nationalVideoTransform.a, self.nationalVideoTransform.b, self.nationalVideoTransform.c, self.nationalVideoTransform.d, translatePoint.x, translatePoint.y);
    }
    else if(!self.isArrowActived)
    {
        if (self.mediaType == MEDIA_PHOTO)
        {
            CGPoint translatedPoint = [gestureRecognizer translationInView:self];
            
            if([gestureRecognizer state] == UIGestureRecognizerStateBegan)
            {
                _firstX = self.imageView.center.x;
                _firstY = self.imageView.center.y;
            }
            
            translatedPoint = CGPointMake(_firstX+translatedPoint.x, _firstY + translatedPoint.y);
            [self.imageView setCenter:translatedPoint];
        }
        else if ((self.mediaType == MEDIA_VIDEO)||(self.mediaType == MEDIA_GIF))
        {
            CGPoint translatedPoint = [gestureRecognizer translationInView:self];
           
            if([gestureRecognizer state] == UIGestureRecognizerStateBegan)
            {
                _firstX = self.videoView.center.x;
                _firstY = self.videoView.center.y;
            }
            
            // get original intersection rect from self.videoView.frame/self.bounds
            CGAffineTransform transform = self.transform;
            self.transform = CGAffineTransformIdentity;
            CGRect originalRect = CGRectIntersection(self.videoView.frame, self.bounds);
            self.transform = transform;
            
            //move self.videoView center
            translatedPoint = CGPointMake(_firstX+translatedPoint.x, _firstY + translatedPoint.y);
            [self.videoView setCenter:translatedPoint];
            
            // get changed intersection rect from self.videoView.frame/self.bounds
            self.transform = CGAffineTransformIdentity;
            CGRect changedRect = CGRectIntersection(self.videoView.frame, self.bounds);
            self.changedVideoCenter = self.videoView.center;
            self.transform = transform;
            
            // change videoTransform from original intersection rect and changed intersection rect
            self.videoTransform = CGAffineTransformConcat(self.videoTransform, CGAffineTransformMakeScale(changedRect.size.width/originalRect.size.width, changedRect.size.height/originalRect.size.height));
        }
        else if (self.mediaType == MEDIA_TEXT)
        {
            CGPoint translatedPoint = [gestureRecognizer translationInView:self.superview];
            
            if([gestureRecognizer state] == UIGestureRecognizerStateBegan)
            {
                _firstX = self.center.x;
                _firstY = self.center.y;
                [self object_actived];
            }
            
            translatedPoint = CGPointMake(_firstX+translatedPoint.x, _firstY + translatedPoint.y);
            [self setCenter:translatedPoint];
        }
    }
}


#pragma mark - 
#pragma mark - Touch Function


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    self.firstTouchedPoint = [[touches anyObject] locationInView:self];
    self.isArrowActived = NO;

    if (self.isMask)
    {
        if (CGRectContainsPoint(self.maskArrowLeft.frame, self.firstTouchedPoint))
            self.isArrowActived = YES;
        else if (CGRectContainsPoint(self.maskArrowRight.frame, self.firstTouchedPoint))
            self.isArrowActived = YES;
        else if (CGRectContainsPoint(self.maskArrowTop.frame, self.firstTouchedPoint))
            self.isArrowActived = YES;
        else if (CGRectContainsPoint(self.maskArrowBottom.frame, self.firstTouchedPoint))
            self.isArrowActived = YES;
    }
    
    if (self.isArrowActived)
    {
        [self removeGestureRecognizer:self.moveGesture];
    }
    else
    {
//        [self removeGestureRecognizer:self.moveGesture];
        [self addGestureRecognizer:self.moveGesture];
    }
}

- (void) touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    int num = (int)[[touches allObjects] count];
    if( num >= 3 ){
        self.userInteractionEnabled = NO;
    }
}

- (void) touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    self.userInteractionEnabled = YES;
}

- (void) touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    self.userInteractionEnabled = YES;
}


#pragma mark - 
#pragma mark - Mask Left, Right, Top, Bottom Gesture Functions

- (void)mask_left:(UIPanGestureRecognizer *)gestureRecognizer
{
    self.boundMode = BoundModeLeft;

    if (self.mediaType == MEDIA_PHOTO)
    {
        if (self.boundMode != BoundModeNone)//normal
        {
            [self changeImageMaskBound:gestureRecognizer];
            [gestureRecognizer setTranslation:CGPointZero inView:self];
        }
    }
    else if ((self.mediaType == MEDIA_VIDEO)||(self.mediaType == MEDIA_GIF))
    {
        if (self.boundMode != BoundModeNone)//normal
        {
            [self changeVideoMaskBound:gestureRecognizer];
            [gestureRecognizer setTranslation:CGPointZero inView:self];
        }
    }
    else if (self.mediaType == MEDIA_TEXT)
    {
        if (self.boundMode != BoundModeNone)//normal
        {
            [self changeTextMaskBound:gestureRecognizer];
            [gestureRecognizer setTranslation:CGPointZero inView:self];
        }
    }
}

- (void)mask_right:(UIPanGestureRecognizer *)gestureRecognizer
{
    self.boundMode = BoundModeRight;

    if (self.mediaType == MEDIA_PHOTO)
    {
        if (self.boundMode != BoundModeNone)//normal
        {
            [self changeImageMaskBound:gestureRecognizer];
            [gestureRecognizer setTranslation:CGPointZero inView:self];
        }
    }
    else if ((self.mediaType == MEDIA_VIDEO)||(self.mediaType == MEDIA_GIF))
    {
        if (self.boundMode != BoundModeNone)//normal
        {
            [self changeVideoMaskBound:gestureRecognizer];
            [gestureRecognizer setTranslation:CGPointZero inView:self];
        }
    }
    else if (self.mediaType == MEDIA_TEXT)
    {
        if (self.boundMode != BoundModeNone)//normal
        {
            [self changeTextMaskBound:gestureRecognizer];
            [gestureRecognizer setTranslation:CGPointZero inView:self];
        }
    }
}

- (void)mask_top:(UIPanGestureRecognizer *)gestureRecognizer
{
    self.boundMode = BoundModeTop;

    if (self.mediaType == MEDIA_PHOTO)
    {
        if (self.boundMode != BoundModeNone)//normal
        {
            [self changeImageMaskBound:gestureRecognizer];
            [gestureRecognizer setTranslation:CGPointZero inView:self];
        }
    }
    else if ((self.mediaType == MEDIA_VIDEO)||(self.mediaType == MEDIA_GIF))
    {
        if (self.boundMode != BoundModeNone)//normal
        {
            [self changeVideoMaskBound:gestureRecognizer];
            [gestureRecognizer setTranslation:CGPointZero inView:self];
        }
    }
    else if (self.mediaType == MEDIA_TEXT)
    {
        if (self.boundMode != BoundModeNone)//normal
        {
            [self changeTextMaskBound:gestureRecognizer];
            [gestureRecognizer setTranslation:CGPointZero inView:self];
        }
    }
}

- (void)mask_bottom:(UIPanGestureRecognizer *)gestureRecognizer
{
    self.boundMode = BoundModeBottom;

    if (self.mediaType == MEDIA_PHOTO)
    {
        if (self.boundMode != BoundModeNone)
        {
            [self changeImageMaskBound:gestureRecognizer];
            [gestureRecognizer setTranslation:CGPointZero inView:self];
        }
    }
    else if ((self.mediaType == MEDIA_VIDEO)||(self.mediaType == MEDIA_GIF))
    {
        if (self.boundMode != BoundModeNone)
        {
            [self changeVideoMaskBound:gestureRecognizer];
            [gestureRecognizer setTranslation:CGPointZero inView:self];
        }
    }
    else if (self.mediaType == MEDIA_TEXT)
    {
        if (self.boundMode != BoundModeNone)
        {
            [self changeTextMaskBound:gestureRecognizer];
            [gestureRecognizer setTranslation:CGPointZero inView:self];
        }
    }
}


#pragma mark - Change Object with Changed Mask

- (void) changeImageMaskBound:(UIPanGestureRecognizer*) gestureRecognizer
{
    if (self.isShape)
    {
        CGPoint point = [gestureRecognizer translationInView:self];
        CGPoint originalRightBottomPnt = CGPointMake(self.frame.origin.x + self.frame.size.width, self.frame.origin.y + self.frame.size.height);
        CGPoint originalLeftBottomPnt = CGPointMake(self.frame.origin.x, self.frame.origin.y + self.frame.size.height);
        CGPoint originalRightTopPnt = CGPointMake(self.frame.origin.x + self.frame.size.width, self.frame.origin.y);
        CGPoint originalLeftTopPnt = CGPointMake(self.frame.origin.x, self.frame.origin.y);
        
        CGAffineTransform transform = self.transform;
        self.transform = CGAffineTransformIdentity;
        
        if (self.boundMode == BoundModeLeft)
        {
            if ((self.frame.size.width - point.x) > BOUND_SIZE*2)
            {
                [self setFrame:CGRectMake(self.frame.origin.x + point.x, self.frame.origin.y, self.frame.size.width - point.x, self.frame.size.height)];
                [self.mediaView setFrame:CGRectMake(self.mediaView.frame.origin.x, self.mediaView.frame.origin.y, self.mediaView.frame.size.width - point.x, self.mediaView.frame.size.height)];
                [self.imageView setFrame:CGRectMake(self.imageView.frame.origin.x, self.imageView.frame.origin.y, self.imageView.frame.size.width - point.x, self.imageView.frame.size.height)];
            }
        }
        else if (self.boundMode == BoundModeRight)
        {
            if ((self.frame.size.width + point.x) > BOUND_SIZE*2)
            {
                [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width + point.x, self.frame.size.height)];
                [self.mediaView setFrame:CGRectMake(self.mediaView.frame.origin.x, self.mediaView.frame.origin.y, self.mediaView.frame.size.width + point.x, self.mediaView.frame.size.height)];
                [self.imageView setFrame:CGRectMake(self.imageView.frame.origin.x, self.imageView.frame.origin.y, self.imageView.frame.size.width + point.x, self.imageView.frame.size.height)];
            }
        }
        else if (self.boundMode == BoundModeTop)
        {
            if ((self.frame.size.height - point.y) > BOUND_SIZE*2)
            {
                [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y + point.y, self.frame.size.width, self.frame.size.height - point.y)];
                [self.mediaView setFrame:CGRectMake(self.mediaView.frame.origin.x, self.mediaView.frame.origin.y, self.mediaView.frame.size.width, self.mediaView.frame.size.height - point.y)];
                [self.imageView setFrame:CGRectMake(self.imageView.frame.origin.x, self.imageView.frame.origin.y, self.imageView.frame.size.width, self.imageView.frame.size.height - point.y)];
            }
        }
        else if (self.boundMode == BoundModeBottom)
        {
            if((self.frame.size.height + point.y) > BOUND_SIZE*2)
            {
                [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height + point.y)];
                [self.mediaView setFrame:CGRectMake(self.mediaView.frame.origin.x, self.mediaView.frame.origin.y, self.mediaView.frame.size.width, self.mediaView.frame.size.height + point.y)];
                [self.imageView setFrame:CGRectMake(self.imageView.frame.origin.x, self.imageView.frame.origin.y, self.imageView.frame.size.width, self.imageView.frame.size.height + point.y)];
            }
        }
        
        self.borderLineLayer.frame = CGRectMake(-self.objectBorderWidth, -self.objectBorderWidth, self.mediaView.bounds.size.width+self.objectBorderWidth*2.0f, self.mediaView.bounds.size.height+self.objectBorderWidth*2.0f);
        [self applyBorderLinePath];
        
        self.maskArrowLeft.center = CGPointMake(self.maskArrowLeft.frame.size.width/2, self.bounds.size.height/2);
        self.maskArrowRight.center = CGPointMake(self.bounds.size.width-self.maskArrowRight.frame.size.width/2, self.bounds.size.height/2);
        self.maskArrowTop.center = CGPointMake(self.bounds.size.width/2, self.maskArrowTop.frame.size.height/2);
        self.maskArrowBottom.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height-self.maskArrowBottom.frame.size.height/2);
        
        [self applySelectedLinePath];
        
        self.selectedLineLayer.frame = self.bounds;
        
        self.transform = transform;
        
        CGPoint changedRightBottomPnt = CGPointMake(self.frame.origin.x + self.frame.size.width, self.frame.origin.y + self.frame.size.height);
        CGPoint changedLeftBottomPnt = CGPointMake(self.frame.origin.x, self.frame.origin.y + self.frame.size.height);
        CGPoint changedRightTopPnt = CGPointMake(self.frame.origin.x + self.frame.size.width, self.frame.origin.y);
        CGPoint changedLeftTopPnt = CGPointMake(self.frame.origin.x, self.frame.origin.y);
        
        int val = self.rotateAngle / (2*M_PI);
        CGFloat angle = self.rotateAngle - val*(2*M_PI);
        
        if (((self.boundMode == BoundModeLeft)&&(self.mySX == 1)) || ((self.boundMode == BoundModeRight)&&(self.mySX == -1)))
        {
            if (((angle>=0.0f)&&(angle<=M_PI/2)) || ((angle >= -2*M_PI)&&(angle<= -3*M_PI/2)))
            {
                self.center = CGPointMake(self.center.x + (originalRightBottomPnt.x - changedRightBottomPnt.x), self.center.y + (originalRightBottomPnt.y - changedRightBottomPnt.y));
            }
            else if (((angle>M_PI/2)&&(angle<=M_PI)) || ((angle > -3*M_PI/2)&&(angle<= -M_PI)))
            {
                self.center = CGPointMake(self.center.x + (originalLeftBottomPnt.x - changedLeftBottomPnt.x), self.center.y + (originalLeftBottomPnt.y - changedLeftBottomPnt.y));
            }
            else if (((angle>M_PI)&&(angle<=3*M_PI/2)) || ((angle > -M_PI)&&(angle<= -M_PI/2)))
            {
                self.center = CGPointMake(self.center.x + (originalLeftTopPnt.x - changedLeftTopPnt.x), self.center.y + (originalLeftTopPnt.y - changedLeftTopPnt.y));
            }
            else
            {
                self.center = CGPointMake(self.center.x + (originalRightTopPnt.x - changedRightTopPnt.x), self.center.y + (originalRightTopPnt.y - changedRightTopPnt.y));
            }
        }
        else if (((self.boundMode == BoundModeRight)&&(self.mySX == 1)) || ((self.boundMode == BoundModeLeft)&&(self.mySX == -1)))
        {
            if (((angle>=0.0f)&&(angle<=M_PI/2)) || ((angle >= -2*M_PI)&&(angle<= -3*M_PI/2)))
            {
                self.center = CGPointMake(self.center.x + (originalLeftTopPnt.x - changedLeftTopPnt.x), self.center.y + (originalLeftTopPnt.y - changedLeftTopPnt.y));
            }
            else if (((angle>M_PI/2)&&(angle<=M_PI)) || ((angle > -3*M_PI/2)&&(angle<= -M_PI)))
            {
                self.center = CGPointMake(self.center.x + (originalRightTopPnt.x - changedRightTopPnt.x), self.center.y + (originalRightTopPnt.y - changedRightTopPnt.y));
            }
            else if (((angle>M_PI)&&(angle<=3*M_PI/2)) || ((angle > -M_PI)&&(angle<= -M_PI/2)))
            {
                self.center = CGPointMake(self.center.x + (originalRightBottomPnt.x - changedRightBottomPnt.x), self.center.y + (originalRightBottomPnt.y - changedRightBottomPnt.y));
            }
            else
            {
                self.center = CGPointMake(self.center.x + (originalLeftBottomPnt.x - changedLeftBottomPnt.x), self.center.y + (originalLeftBottomPnt.y - changedLeftBottomPnt.y));
            }
        }
        else if (((self.boundMode == BoundModeBottom)&&(self.mySY == 1)) || ((self.boundMode == BoundModeTop)&&(self.mySY == -1)))
        {
            if (((angle>=0.0f)&&(angle<=M_PI/2)) || ((angle >= -2*M_PI)&&(angle<= -3*M_PI/2)))
            {
                self.center = CGPointMake(self.center.x + (originalRightTopPnt.x - changedRightTopPnt.x), self.center.y + (originalRightTopPnt.y - changedRightTopPnt.y));
            }
            else if (((angle>M_PI/2)&&(angle<=M_PI)) || ((angle > -3*M_PI/2)&&(angle<= -M_PI)))
            {
                self.center = CGPointMake(self.center.x + (originalRightBottomPnt.x - changedRightBottomPnt.x), self.center.y + (originalRightBottomPnt.y - changedRightBottomPnt.y));
            }
            else if (((angle>M_PI)&&(angle<=3*M_PI/2)) || ((angle > -M_PI)&&(angle<= -M_PI/2)))
            {
                self.center = CGPointMake(self.center.x + (originalLeftBottomPnt.x - changedLeftBottomPnt.x), self.center.y + (originalLeftBottomPnt.y - changedLeftBottomPnt.y));
            }
            else
            {
                self.center = CGPointMake(self.center.x + (originalLeftTopPnt.x - changedLeftTopPnt.x), self.center.y + (originalLeftTopPnt.y - changedLeftTopPnt.y));
            }
            
            [self update];
        }
        else if (((self.boundMode == BoundModeTop)&&(self.mySY == 1)) || ((self.boundMode == BoundModeBottom)&&(self.mySY == -1)))
        {
            if (((angle>=0.0f)&&(angle<=M_PI/2)) || ((angle >= -2*M_PI)&&(angle<= -3*M_PI/2)))
            {
                self.center = CGPointMake(self.center.x + (originalLeftBottomPnt.x - changedLeftBottomPnt.x), self.center.y + (originalLeftBottomPnt.y - changedLeftBottomPnt.y));
            }
            else if (((angle>M_PI/2)&&(angle<=M_PI)) || ((angle > -3*M_PI/2)&&(angle<= -M_PI)))
            {
                self.center = CGPointMake(self.center.x + (originalLeftTopPnt.x - changedLeftTopPnt.x), self.center.y + (originalLeftTopPnt.y - changedLeftTopPnt.y));
            }
            else if (((angle>M_PI)&&(angle<=3*M_PI/2)) || ((angle > -M_PI)&&(angle<= -M_PI/2)))
            {
                self.center = CGPointMake(self.center.x + (originalRightTopPnt.x - changedRightTopPnt.x), self.center.y + (originalRightTopPnt.y - changedRightTopPnt.y));
            }
            else
            {
                self.center = CGPointMake(self.center.x + (originalRightBottomPnt.x - changedRightBottomPnt.x), self.center.y + (originalRightBottomPnt.y - changedRightBottomPnt.y));
            }
            
            [self update];
        }
        
        [self applyShadow];
        
        self.originalBounds = self.bounds;
    }
    else
    {
        CGPoint point = [gestureRecognizer translationInView:self];
        CGPoint originalRightBottomPnt = CGPointMake(self.frame.origin.x + self.frame.size.width, self.frame.origin.y + self.frame.size.height);
        CGPoint originalLeftBottomPnt = CGPointMake(self.frame.origin.x, self.frame.origin.y + self.frame.size.height);
        CGPoint originalRightTopPnt = CGPointMake(self.frame.origin.x + self.frame.size.width, self.frame.origin.y);
        CGPoint originalLeftTopPnt = CGPointMake(self.frame.origin.x, self.frame.origin.y);
        
        CGAffineTransform transform = self.transform;
        self.transform = CGAffineTransformIdentity;
        
        if (self.boundMode == BoundModeLeft)
        {
            if (((self.frame.size.width - point.x) > BOUND_SIZE*2)&&((self.frame.size.width - point.x) < self.imageView.bounds.size.width))
            {
                [self setFrame:CGRectMake(self.frame.origin.x + point.x, self.frame.origin.y, self.frame.size.width - point.x, self.frame.size.height)];
                [self.mediaView setFrame:CGRectMake(self.mediaView.frame.origin.x, self.mediaView.frame.origin.y, self.mediaView.frame.size.width - point.x, self.mediaView.frame.size.height)];
                [self.imageView setFrame:CGRectMake(self.imageView.frame.origin.x - point.x, self.imageView.frame.origin.y, self.imageView.frame.size.width, self.imageView.frame.size.height)];
            }
        }
        else if (self.boundMode == BoundModeRight)
        {
            if (((self.frame.size.width + point.x) > BOUND_SIZE*2)&&((self.frame.size.width + point.x) < self.imageView.bounds.size.width))
            {
                [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width + point.x, self.frame.size.height)];
                [self.mediaView setFrame:CGRectMake(self.mediaView.frame.origin.x, self.mediaView.frame.origin.y, self.mediaView.frame.size.width + point.x, self.mediaView.frame.size.height)];
                [self.imageView setFrame:CGRectMake(self.imageView.frame.origin.x, self.imageView.frame.origin.y, self.imageView.frame.size.width, self.imageView.frame.size.height)];
            }
        }
        else if (self.boundMode == BoundModeTop)
        {
            if (((self.frame.size.height - point.y) > BOUND_SIZE*2)&&((self.frame.size.height - point.y) < self.imageView.bounds.size.height))
            {
                [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y + point.y, self.frame.size.width, self.frame.size.height - point.y)];
                [self.mediaView setFrame:CGRectMake(self.mediaView.frame.origin.x, self.mediaView.frame.origin.y, self.mediaView.frame.size.width, self.mediaView.frame.size.height - point.y)];
                [self.imageView setFrame:CGRectMake(self.imageView.frame.origin.x, self.imageView.frame.origin.y - point.y, self.imageView.frame.size.width, self.imageView.frame.size.height)];
            }
        }
        else if (self.boundMode == BoundModeBottom)
        {
            if(((self.frame.size.height + point.y) > BOUND_SIZE*2)&&((self.frame.size.height + point.y) < self.imageView.bounds.size.height))
            {
                [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height + point.y)];
                [self.mediaView setFrame:CGRectMake(self.mediaView.frame.origin.x, self.mediaView.frame.origin.y, self.mediaView.frame.size.width, self.mediaView.frame.size.height + point.y)];
                [self.imageView setFrame:CGRectMake(self.imageView.frame.origin.x, self.imageView.frame.origin.y, self.imageView.frame.size.width, self.imageView.frame.size.height)];
            }
        }
        
        self.borderLineLayer.frame = CGRectMake(-self.objectBorderWidth, -self.objectBorderWidth, self.mediaView.bounds.size.width+self.objectBorderWidth*2.0f, self.mediaView.bounds.size.height+self.objectBorderWidth*2.0f);

        [self applyBorderLinePath];
        
        self.maskArrowLeft.center = CGPointMake(self.maskArrowLeft.frame.size.width/2, self.bounds.size.height/2);
        self.maskArrowRight.center = CGPointMake(self.bounds.size.width-self.maskArrowRight.frame.size.width/2, self.bounds.size.height/2);
        self.maskArrowTop.center = CGPointMake(self.bounds.size.width/2, self.maskArrowTop.frame.size.height/2);
        self.maskArrowBottom.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height-self.maskArrowBottom.frame.size.height/2);
        
        [self applySelectedLinePath];
        
        self.selectedLineLayer.frame = self.bounds;
        
        self.transform = transform;
        
        CGPoint changedRightBottomPnt = CGPointMake(self.frame.origin.x + self.frame.size.width, self.frame.origin.y + self.frame.size.height);
        CGPoint changedLeftBottomPnt = CGPointMake(self.frame.origin.x, self.frame.origin.y + self.frame.size.height);
        CGPoint changedRightTopPnt = CGPointMake(self.frame.origin.x + self.frame.size.width, self.frame.origin.y);
        CGPoint changedLeftTopPnt = CGPointMake(self.frame.origin.x, self.frame.origin.y);
        
        int val = self.rotateAngle / (2*M_PI);
        CGFloat angle = self.rotateAngle - val*(2*M_PI);
        
        if (((self.boundMode == BoundModeLeft)&&(self.mySX == 1)) || ((self.boundMode == BoundModeRight)&&(self.mySX == -1)))
        {
            if (((angle>=0.0f)&&(angle<=M_PI/2)) || ((angle >= -2*M_PI)&&(angle<= -3*M_PI/2)))
            {
                self.center = CGPointMake(self.center.x + (originalRightBottomPnt.x - changedRightBottomPnt.x), self.center.y + (originalRightBottomPnt.y - changedRightBottomPnt.y));
            }
            else if (((angle>M_PI/2)&&(angle<=M_PI)) || ((angle > -3*M_PI/2)&&(angle<= -M_PI)))
            {
                self.center = CGPointMake(self.center.x + (originalLeftBottomPnt.x - changedLeftBottomPnt.x), self.center.y + (originalLeftBottomPnt.y - changedLeftBottomPnt.y));
            }
            else if (((angle>M_PI)&&(angle<=3*M_PI/2)) || ((angle > -M_PI)&&(angle<= -M_PI/2)))
            {
                self.center = CGPointMake(self.center.x + (originalLeftTopPnt.x - changedLeftTopPnt.x), self.center.y + (originalLeftTopPnt.y - changedLeftTopPnt.y));
            }
            else
            {
                self.center = CGPointMake(self.center.x + (originalRightTopPnt.x - changedRightTopPnt.x), self.center.y + (originalRightTopPnt.y - changedRightTopPnt.y));
            }
        }
        else if (((self.boundMode == BoundModeRight)&&(self.mySX == 1)) || ((self.boundMode == BoundModeLeft)&&(self.mySX == -1)))
        {
            if (((angle>=0.0f)&&(angle<=M_PI/2)) || ((angle >= -2*M_PI)&&(angle<= -3*M_PI/2)))
            {
                self.center = CGPointMake(self.center.x + (originalLeftTopPnt.x - changedLeftTopPnt.x), self.center.y + (originalLeftTopPnt.y - changedLeftTopPnt.y));
            }
            else if (((angle>M_PI/2)&&(angle<=M_PI)) || ((angle > -3*M_PI/2)&&(angle<= -M_PI)))
            {
                self.center = CGPointMake(self.center.x + (originalRightTopPnt.x - changedRightTopPnt.x), self.center.y + (originalRightTopPnt.y - changedRightTopPnt.y));
            }
            else if (((angle>M_PI)&&(angle<=3*M_PI/2)) || ((angle > -M_PI)&&(angle<= -M_PI/2)))
            {
                self.center = CGPointMake(self.center.x + (originalRightBottomPnt.x - changedRightBottomPnt.x), self.center.y + (originalRightBottomPnt.y - changedRightBottomPnt.y));
            }
            else
            {
                self.center = CGPointMake(self.center.x + (originalLeftBottomPnt.x - changedLeftBottomPnt.x), self.center.y + (originalLeftBottomPnt.y - changedLeftBottomPnt.y));
            }
        }
        else if (((self.boundMode == BoundModeBottom)&&(self.mySY == 1)) || ((self.boundMode == BoundModeTop)&&(self.mySY == -1)))
        {
            if (((angle>=0.0f)&&(angle<=M_PI/2)) || ((angle >= -2*M_PI)&&(angle<= -3*M_PI/2)))
            {
                self.center = CGPointMake(self.center.x + (originalRightTopPnt.x - changedRightTopPnt.x), self.center.y + (originalRightTopPnt.y - changedRightTopPnt.y));
            }
            else if (((angle>M_PI/2)&&(angle<=M_PI)) || ((angle > -3*M_PI/2)&&(angle<= -M_PI)))
            {
                self.center = CGPointMake(self.center.x + (originalRightBottomPnt.x - changedRightBottomPnt.x), self.center.y + (originalRightBottomPnt.y - changedRightBottomPnt.y));
            }
            else if (((angle>M_PI)&&(angle<=3*M_PI/2)) || ((angle > -M_PI)&&(angle<= -M_PI/2)))
            {
                self.center = CGPointMake(self.center.x + (originalLeftBottomPnt.x - changedLeftBottomPnt.x), self.center.y + (originalLeftBottomPnt.y - changedLeftBottomPnt.y));
            }
            else
            {
                self.center = CGPointMake(self.center.x + (originalLeftTopPnt.x - changedLeftTopPnt.x), self.center.y + (originalLeftTopPnt.y - changedLeftTopPnt.y));
            }
            
            [self update];
        }
        else if (((self.boundMode == BoundModeTop)&&(self.mySY == 1)) || ((self.boundMode == BoundModeBottom)&&(self.mySY == -1)))
        {
            if (((angle>=0.0f)&&(angle<=M_PI/2)) || ((angle >= -2*M_PI)&&(angle<= -3*M_PI/2)))
            {
                self.center = CGPointMake(self.center.x + (originalLeftBottomPnt.x - changedLeftBottomPnt.x), self.center.y + (originalLeftBottomPnt.y - changedLeftBottomPnt.y));
            }
            else if (((angle>M_PI/2)&&(angle<=M_PI)) || ((angle > -3*M_PI/2)&&(angle<= -M_PI)))
            {
                self.center = CGPointMake(self.center.x + (originalLeftTopPnt.x - changedLeftTopPnt.x), self.center.y + (originalLeftTopPnt.y - changedLeftTopPnt.y));
            }
            else if (((angle>M_PI)&&(angle<=3*M_PI/2)) || ((angle > -M_PI)&&(angle<= -M_PI/2)))
            {
                self.center = CGPointMake(self.center.x + (originalRightTopPnt.x - changedRightTopPnt.x), self.center.y + (originalRightTopPnt.y - changedRightTopPnt.y));
            }
            else
            {
                self.center = CGPointMake(self.center.x + (originalRightBottomPnt.x - changedRightBottomPnt.x), self.center.y + (originalRightBottomPnt.y - changedRightBottomPnt.y));
            }
            
            [self update];
        }
        
        [self applyShadow];
    }
}

- (void) changeVideoMaskBound:(UIPanGestureRecognizer*) gestureRecognizer
{
    CGPoint point = [gestureRecognizer translationInView:self];
    CGPoint originalRightBottomPnt = CGPointMake(self.frame.origin.x + self.frame.size.width, self.frame.origin.y + self.frame.size.height);
    CGPoint originalLeftBottomPnt = CGPointMake(self.frame.origin.x, self.frame.origin.y + self.frame.size.height);
    CGPoint originalRightTopPnt = CGPointMake(self.frame.origin.x + self.frame.size.width, self.frame.origin.y);
    CGPoint originalLeftTopPnt = CGPointMake(self.frame.origin.x, self.frame.origin.y);

    CGAffineTransform transform = self.transform;
    self.transform = CGAffineTransformIdentity;
    
    CGRect originalRect = CGRectIntersection(self.videoView.frame, self.bounds);
    
    if (self.boundMode == BoundModeLeft)
    {
        if (((self.frame.size.width - point.x) > BOUND_SIZE*2)&&((self.frame.size.width - point.x) < self.videoView.bounds.size.width))
        {
            [self setFrame:CGRectMake(self.frame.origin.x + point.x, self.frame.origin.y, self.frame.size.width - point.x, self.frame.size.height)];
            [self.mediaView setFrame:CGRectMake(self.mediaView.frame.origin.x, self.mediaView.frame.origin.y, self.mediaView.frame.size.width - point.x, self.mediaView.frame.size.height)];
            [self.videoView setFrame:CGRectMake(self.videoView.frame.origin.x - point.x, self.videoView.frame.origin.y, self.videoView.frame.size.width, self.videoView.frame.size.height)];
        }
    }
    else if (self.boundMode == BoundModeRight)
    {
        if (((self.frame.size.width + point.x) > BOUND_SIZE*2)&&((self.frame.size.width + point.x) < self.videoView.bounds.size.width))
        {
            [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width + point.x, self.frame.size.height)];
            [self.mediaView setFrame:CGRectMake(self.mediaView.frame.origin.x, self.mediaView.frame.origin.y, self.mediaView.frame.size.width + point.x, self.mediaView.frame.size.height)];
            [self.videoView setFrame:CGRectMake(self.videoView.frame.origin.x, self.videoView.frame.origin.y, self.videoView.frame.size.width, self.videoView.frame.size.height)];
        }
    }
    else if (self.boundMode == BoundModeTop)
    {
        if (((self.frame.size.height - point.y) > BOUND_SIZE*2)&&((self.frame.size.height - point.y) < self.videoView.bounds.size.height))
        {
            [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y + point.y, self.frame.size.width, self.frame.size.height - point.y)];
            [self.mediaView setFrame:CGRectMake(self.mediaView.frame.origin.x, self.mediaView.frame.origin.y, self.mediaView.frame.size.width, self.mediaView.frame.size.height - point.y)];
            [self.videoView setFrame:CGRectMake(self.videoView.frame.origin.x, self.videoView.frame.origin.y - point.y, self.videoView.frame.size.width, self.videoView.frame.size.height)];
        }
    }
    else if (self.boundMode == BoundModeBottom)
    {
        if(((self.frame.size.height + point.y) > BOUND_SIZE*2)&&((self.frame.size.height + point.y) < self.videoView.bounds.size.height))
        {
            [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height + point.y)];
            [self.mediaView setFrame:CGRectMake(self.mediaView.frame.origin.x, self.mediaView.frame.origin.y, self.mediaView.frame.size.width, self.mediaView.frame.size.height + point.y)];
            [self.videoView setFrame:CGRectMake(self.videoView.frame.origin.x, self.videoView.frame.origin.y, self.videoView.frame.size.width, self.videoView.frame.size.height)];
            self.reflectionDelta = CGPointMake(self.reflectionDelta.x, self.reflectionDelta.y+point.y);
        }
    }
    
    self.borderLineLayer.frame = CGRectMake(-self.objectBorderWidth, -self.objectBorderWidth, self.mediaView.bounds.size.width+self.objectBorderWidth*2.0f, self.mediaView.bounds.size.height+self.objectBorderWidth*2.0f);
    [self applyBorderLinePath];
    
    self.maskArrowLeft.center = CGPointMake(self.maskArrowLeft.frame.size.width/2, self.bounds.size.height/2);
    self.maskArrowRight.center = CGPointMake(self.bounds.size.width-self.maskArrowRight.frame.size.width/2, self.bounds.size.height/2);
    self.maskArrowTop.center = CGPointMake(self.bounds.size.width/2, self.maskArrowTop.frame.size.height/2);
    self.maskArrowBottom.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height-self.maskArrowBottom.frame.size.height/2);
    
    [self applySelectedLinePath];
    
    self.selectedLineLayer.frame = self.bounds;

    // get changed intersection rect from self.videoView.frame/self.bounds
    CGRect changedRect = CGRectIntersection(self.videoView.frame, self.bounds);
    self.transform = transform;
    
    // change videoTransform from original intersection rect and changed intersection rect
    self.videoTransform = CGAffineTransformConcat(self.videoTransform, CGAffineTransformMakeScale(changedRect.size.width/originalRect.size.width, changedRect.size.height/originalRect.size.height));
    
    CGPoint changedRightBottomPnt = CGPointMake(self.frame.origin.x + self.frame.size.width, self.frame.origin.y + self.frame.size.height);
    CGPoint changedLeftBottomPnt = CGPointMake(self.frame.origin.x, self.frame.origin.y + self.frame.size.height);
    CGPoint changedRightTopPnt = CGPointMake(self.frame.origin.x + self.frame.size.width, self.frame.origin.y);
    CGPoint changedLeftTopPnt = CGPointMake(self.frame.origin.x, self.frame.origin.y);
    
    int val = self.rotateAngle / (2*M_PI);
    CGFloat angle = self.rotateAngle - val*(2*M_PI);
    
    if (((self.boundMode == BoundModeLeft)&&(self.mySX == 1)) || ((self.boundMode == BoundModeRight)&&(self.mySX == -1)))
    {
        if (((angle>=0.0f)&&(angle<=M_PI/2)) || ((angle >= -2*M_PI)&&(angle<= -3*M_PI/2)))
        {
            self.center = CGPointMake(self.center.x + (originalRightBottomPnt.x - changedRightBottomPnt.x), self.center.y + (originalRightBottomPnt.y - changedRightBottomPnt.y));
        }
        else if (((angle>M_PI/2)&&(angle<=M_PI)) || ((angle > -3*M_PI/2)&&(angle<= -M_PI)))
        {
            self.center = CGPointMake(self.center.x + (originalLeftBottomPnt.x - changedLeftBottomPnt.x), self.center.y + (originalLeftBottomPnt.y - changedLeftBottomPnt.y));
        }
        else if (((angle>M_PI)&&(angle<=3*M_PI/2)) || ((angle > -M_PI)&&(angle<= -M_PI/2)))
        {
            self.center = CGPointMake(self.center.x + (originalLeftTopPnt.x - changedLeftTopPnt.x), self.center.y + (originalLeftTopPnt.y - changedLeftTopPnt.y));
        }
        else
        {
            self.center = CGPointMake(self.center.x + (originalRightTopPnt.x - changedRightTopPnt.x), self.center.y + (originalRightTopPnt.y - changedRightTopPnt.y));
        }
    }
    else if (((self.boundMode == BoundModeRight)&&(self.mySX == 1)) || ((self.boundMode == BoundModeLeft)&&(self.mySX == -1)))
    {
        if (((angle>=0.0f)&&(angle<=M_PI/2)) || ((angle >= -2*M_PI)&&(angle<= -3*M_PI/2)))
        {
            self.center = CGPointMake(self.center.x + (originalLeftTopPnt.x - changedLeftTopPnt.x), self.center.y + (originalLeftTopPnt.y - changedLeftTopPnt.y));
        }
        else if (((angle>M_PI/2)&&(angle<=M_PI)) || ((angle > -3*M_PI/2)&&(angle<= -M_PI)))
        {
            self.center = CGPointMake(self.center.x + (originalRightTopPnt.x - changedRightTopPnt.x), self.center.y + (originalRightTopPnt.y - changedRightTopPnt.y));
        }
        else if (((angle>M_PI)&&(angle<=3*M_PI/2)) || ((angle > -M_PI)&&(angle<= -M_PI/2)))
        {
            self.center = CGPointMake(self.center.x + (originalRightBottomPnt.x - changedRightBottomPnt.x), self.center.y + (originalRightBottomPnt.y - changedRightBottomPnt.y));
        }
        else
        {
            self.center = CGPointMake(self.center.x + (originalLeftBottomPnt.x - changedLeftBottomPnt.x), self.center.y + (originalLeftBottomPnt.y - changedLeftBottomPnt.y));
        }
    }
    else if (((self.boundMode == BoundModeBottom)&&(self.mySY == 1)) || ((self.boundMode == BoundModeTop)&&(self.mySY == -1)))
    {
        if (((angle>=0.0f)&&(angle<=M_PI/2)) || ((angle >= -2*M_PI)&&(angle<= -3*M_PI/2)))
        {
            self.center = CGPointMake(self.center.x + (originalRightTopPnt.x - changedRightTopPnt.x), self.center.y + (originalRightTopPnt.y - changedRightTopPnt.y));
        }
        else if (((angle>M_PI/2)&&(angle<=M_PI)) || ((angle > -3*M_PI/2)&&(angle<= -M_PI)))
        {
            self.center = CGPointMake(self.center.x + (originalRightBottomPnt.x - changedRightBottomPnt.x), self.center.y + (originalRightBottomPnt.y - changedRightBottomPnt.y));
        }
        else if (((angle>M_PI)&&(angle<=3*M_PI/2)) || ((angle > -M_PI)&&(angle<= -M_PI/2)))
        {
            self.center = CGPointMake(self.center.x + (originalLeftBottomPnt.x - changedLeftBottomPnt.x), self.center.y + (originalLeftBottomPnt.y - changedLeftBottomPnt.y));
        }
        else
        {
            self.center = CGPointMake(self.center.x + (originalLeftTopPnt.x - changedLeftTopPnt.x), self.center.y + (originalLeftTopPnt.y - changedLeftTopPnt.y));
        }

        [self update];
    }
    else if (((self.boundMode == BoundModeTop)&&(self.mySY == 1)) || ((self.boundMode == BoundModeBottom)&&(self.mySY == -1)))
    {
        if (((angle>=0.0f)&&(angle<=M_PI/2)) || ((angle >= -2*M_PI)&&(angle<= -3*M_PI/2)))
        {
            self.center = CGPointMake(self.center.x + (originalLeftBottomPnt.x - changedLeftBottomPnt.x), self.center.y + (originalLeftBottomPnt.y - changedLeftBottomPnt.y));
        }
        else if (((angle>M_PI/2)&&(angle<=M_PI)) || ((angle > -3*M_PI/2)&&(angle<= -M_PI)))
        {
            self.center = CGPointMake(self.center.x + (originalLeftTopPnt.x - changedLeftTopPnt.x), self.center.y + (originalLeftTopPnt.y - changedLeftTopPnt.y));
        }
        else if (((angle>M_PI)&&(angle<=3*M_PI/2)) || ((angle > -M_PI)&&(angle<= -M_PI/2)))
        {
            self.center = CGPointMake(self.center.x + (originalRightTopPnt.x - changedRightTopPnt.x), self.center.y + (originalRightTopPnt.y - changedRightTopPnt.y));
        }
        else
        {
            self.center = CGPointMake(self.center.x + (originalRightBottomPnt.x - changedRightBottomPnt.x), self.center.y + (originalRightBottomPnt.y - changedRightBottomPnt.y));
        }
        
        [self update];
    }

    [self applyShadow];
}

- (void) changeTextMaskBound:(UIPanGestureRecognizer*) gestureRecognizer
{
    CGPoint point = [gestureRecognizer translationInView:self];
    CGPoint originalRightBottomPnt = CGPointMake(self.frame.origin.x + self.frame.size.width, self.frame.origin.y + self.frame.size.height);
    CGPoint originalLeftBottomPnt = CGPointMake(self.frame.origin.x, self.frame.origin.y + self.frame.size.height);
    CGPoint originalRightTopPnt = CGPointMake(self.frame.origin.x + self.frame.size.width, self.frame.origin.y);
    CGPoint originalLeftTopPnt = CGPointMake(self.frame.origin.x, self.frame.origin.y);
    
    CGAffineTransform transform = self.transform;
    self.transform = CGAffineTransformIdentity;
    
    if (self.boundMode == BoundModeLeft)
    {
        if (((self.frame.size.width - point.x) > BOUND_SIZE*2)&&((self.frame.size.width - point.x) < textMaxSize.width))
        {
            [self setFrame:CGRectMake(self.frame.origin.x + point.x, self.frame.origin.y, self.frame.size.width - point.x, self.frame.size.height)];
            [self.mediaView setFrame:CGRectMake(self.mediaView.frame.origin.x, self.mediaView.frame.origin.y, self.mediaView.frame.size.width - point.x, self.mediaView.frame.size.height)];
            [self.textView setFrame:CGRectMake(self.textView.frame.origin.x, self.textView.frame.origin.y, self.textView.frame.size.width - point.x, self.textView.frame.size.height)];
        }
    }
    else if (self.boundMode == BoundModeRight)
    {
        if (((self.frame.size.width + point.x) > BOUND_SIZE*2)&&((self.frame.size.width + point.x) < textMaxSize.width))
        {
            [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width + point.x, self.frame.size.height)];
            [self.mediaView setFrame:CGRectMake(self.mediaView.frame.origin.x, self.mediaView.frame.origin.y, self.mediaView.frame.size.width + point.x, self.mediaView.frame.size.height)];
            [self.textView setFrame:CGRectMake(self.textView.frame.origin.x, self.textView.frame.origin.y, self.textView.frame.size.width + point.x, self.textView.frame.size.height)];
        }
    }
    else if (self.boundMode == BoundModeTop)
    {
        if (((self.frame.size.height - point.y) > BOUND_SIZE*2)&&((self.frame.size.height - point.y) < textMaxSize.height))
        {
            [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y + point.y, self.frame.size.width, self.frame.size.height - point.y)];
            [self.mediaView setFrame:CGRectMake(self.mediaView.frame.origin.x, self.mediaView.frame.origin.y, self.mediaView.frame.size.width, self.mediaView.frame.size.height - point.y)];
            [self.textView setFrame:CGRectMake(self.textView.frame.origin.x, self.textView.frame.origin.y, self.textView.frame.size.width, self.textView.frame.size.height - point.y)];
        }
    }
    else if (self.boundMode == BoundModeBottom)
    {
        if(((self.frame.size.height + point.y) > BOUND_SIZE*2)&&((self.frame.size.height + point.y) < textMaxSize.height))
        {
            [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height + point.y)];
            [self.mediaView setFrame:CGRectMake(self.mediaView.frame.origin.x, self.mediaView.frame.origin.y, self.mediaView.frame.size.width, self.mediaView.frame.size.height + point.y)];
            [self.textView setFrame:CGRectMake(self.textView.frame.origin.x, self.textView.frame.origin.y, self.textView.frame.size.width, self.textView.frame.size.height + point.y)];
        }
    }
    
    self.borderLineLayer.frame = CGRectMake(-self.objectBorderWidth, -self.objectBorderWidth, self.mediaView.bounds.size.width+self.objectBorderWidth*2.0f, self.mediaView.bounds.size.height+self.objectBorderWidth*2.0f);
    [self applyBorderLinePath];
    
    self.maskArrowLeft.center = CGPointMake(self.maskArrowLeft.frame.size.width/2, self.bounds.size.height/2);
    self.maskArrowRight.center = CGPointMake(self.bounds.size.width-self.maskArrowRight.frame.size.width/2, self.bounds.size.height/2);
    self.maskArrowTop.center = CGPointMake(self.bounds.size.width/2, self.maskArrowTop.frame.size.height/2);
    self.maskArrowBottom.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height-self.maskArrowBottom.frame.size.height/2);
    
    [self applySelectedLinePath];
    
    self.selectedLineLayer.frame = self.bounds;
    
    self.transform = transform;
    
    CGPoint changedRightBottomPnt = CGPointMake(self.frame.origin.x + self.frame.size.width, self.frame.origin.y + self.frame.size.height);
    CGPoint changedLeftBottomPnt = CGPointMake(self.frame.origin.x, self.frame.origin.y + self.frame.size.height);
    CGPoint changedRightTopPnt = CGPointMake(self.frame.origin.x + self.frame.size.width, self.frame.origin.y);
    CGPoint changedLeftTopPnt = CGPointMake(self.frame.origin.x, self.frame.origin.y);
    
    int val = self.rotateAngle / (2*M_PI);
    CGFloat angle = self.rotateAngle - val*(2*M_PI);
    
    if (((self.boundMode == BoundModeLeft)&&(self.mySX == 1)) || ((self.boundMode == BoundModeRight)&&(self.mySX == -1)))
    {
        if (((angle>=0.0f)&&(angle<=M_PI/2)) || ((angle >= -2*M_PI)&&(angle<= -3*M_PI/2)))
        {
            self.center = CGPointMake(self.center.x + (originalRightBottomPnt.x - changedRightBottomPnt.x), self.center.y + (originalRightBottomPnt.y - changedRightBottomPnt.y));
        }
        else if (((angle>M_PI/2)&&(angle<=M_PI)) || ((angle > -3*M_PI/2)&&(angle<= -M_PI)))
        {
            self.center = CGPointMake(self.center.x + (originalLeftBottomPnt.x - changedLeftBottomPnt.x), self.center.y + (originalLeftBottomPnt.y - changedLeftBottomPnt.y));
        }
        else if (((angle>M_PI)&&(angle<=3*M_PI/2)) || ((angle > -M_PI)&&(angle<= -M_PI/2)))
        {
            self.center = CGPointMake(self.center.x + (originalLeftTopPnt.x - changedLeftTopPnt.x), self.center.y + (originalLeftTopPnt.y - changedLeftTopPnt.y));
        }
        else
        {
            self.center = CGPointMake(self.center.x + (originalRightTopPnt.x - changedRightTopPnt.x), self.center.y + (originalRightTopPnt.y - changedRightTopPnt.y));
        }
    }
    else if (((self.boundMode == BoundModeRight)&&(self.mySX == 1)) || ((self.boundMode == BoundModeLeft)&&(self.mySX == -1)))
    {
        if (((angle>=0.0f)&&(angle<=M_PI/2)) || ((angle >= -2*M_PI)&&(angle<= -3*M_PI/2)))
        {
            self.center = CGPointMake(self.center.x + (originalLeftTopPnt.x - changedLeftTopPnt.x), self.center.y + (originalLeftTopPnt.y - changedLeftTopPnt.y));
        }
        else if (((angle>M_PI/2)&&(angle<=M_PI)) || ((angle > -3*M_PI/2)&&(angle<= -M_PI)))
        {
            self.center = CGPointMake(self.center.x + (originalRightTopPnt.x - changedRightTopPnt.x), self.center.y + (originalRightTopPnt.y - changedRightTopPnt.y));
        }
        else if (((angle>M_PI)&&(angle<=3*M_PI/2)) || ((angle > -M_PI)&&(angle<= -M_PI/2)))
        {
            self.center = CGPointMake(self.center.x + (originalRightBottomPnt.x - changedRightBottomPnt.x), self.center.y + (originalRightBottomPnt.y - changedRightBottomPnt.y));
        }
        else
        {
            self.center = CGPointMake(self.center.x + (originalLeftBottomPnt.x - changedLeftBottomPnt.x), self.center.y + (originalLeftBottomPnt.y - changedLeftBottomPnt.y));
        }
    }
    else if (((self.boundMode == BoundModeBottom)&&(self.mySY == 1)) || ((self.boundMode == BoundModeTop)&&(self.mySY == -1)))
    {
        if (((angle>=0.0f)&&(angle<=M_PI/2)) || ((angle >= -2*M_PI)&&(angle<= -3*M_PI/2)))
        {
            self.center = CGPointMake(self.center.x + (originalRightTopPnt.x - changedRightTopPnt.x), self.center.y + (originalRightTopPnt.y - changedRightTopPnt.y));
        }
        else if (((angle>M_PI/2)&&(angle<=M_PI)) || ((angle > -3*M_PI/2)&&(angle<= -M_PI)))
        {
            self.center = CGPointMake(self.center.x + (originalRightBottomPnt.x - changedRightBottomPnt.x), self.center.y + (originalRightBottomPnt.y - changedRightBottomPnt.y));
        }
        else if (((angle>M_PI)&&(angle<=3*M_PI/2)) || ((angle > -M_PI)&&(angle<= -M_PI/2)))
        {
            self.center = CGPointMake(self.center.x + (originalLeftBottomPnt.x - changedLeftBottomPnt.x), self.center.y + (originalLeftBottomPnt.y - changedLeftBottomPnt.y));
        }
        else
        {
            self.center = CGPointMake(self.center.x + (originalLeftTopPnt.x - changedLeftTopPnt.x), self.center.y + (originalLeftTopPnt.y - changedLeftTopPnt.y));
        }
        
        [self update];
    }
    else if (((self.boundMode == BoundModeTop)&&(self.mySY == 1)) || ((self.boundMode == BoundModeBottom)&&(self.mySY == -1)))
    {
        if (((angle>=0.0f)&&(angle<=M_PI/2)) || ((angle >= -2*M_PI)&&(angle<= -3*M_PI/2)))
        {
            self.center = CGPointMake(self.center.x + (originalLeftBottomPnt.x - changedLeftBottomPnt.x), self.center.y + (originalLeftBottomPnt.y - changedLeftBottomPnt.y));
        }
        else if (((angle>M_PI/2)&&(angle<=M_PI)) || ((angle > -3*M_PI/2)&&(angle<= -M_PI)))
        {
            self.center = CGPointMake(self.center.x + (originalLeftTopPnt.x - changedLeftTopPnt.x), self.center.y + (originalLeftTopPnt.y - changedLeftTopPnt.y));
        }
        else if (((angle>M_PI)&&(angle<=3*M_PI/2)) || ((angle > -M_PI)&&(angle<= -M_PI/2)))
        {
            self.center = CGPointMake(self.center.x + (originalRightTopPnt.x - changedRightTopPnt.x), self.center.y + (originalRightTopPnt.y - changedRightTopPnt.y));
        }
        else
        {
            self.center = CGPointMake(self.center.x + (originalRightBottomPnt.x - changedRightBottomPnt.x), self.center.y + (originalRightBottomPnt.y - changedRightBottomPnt.y));
        }
        
        [self update];
    }
    
    [self applyShadow];
}


#pragma mark - 
#pragma mark - getNormalFilterVideoCropRect

- (CGRect) getNormalFilterVideoCropRect
{
    CGRect cropRect = CGRectInfinite;
    
    CGAffineTransform transform = self.transform;
    self.transform = CGAffineTransformIdentity;
    
    cropRect = CGRectIntersection(self.videoView.frame, self.bounds);
    cropRect = CGRectMake((-1)*self.videoView.frame.origin.x, (-1)*self.videoView.frame.origin.y, cropRect.size.width, cropRect.size.height);
    
    if (cropRect.origin.x < 0.0f)
        cropRect = CGRectMake(0.0f, cropRect.origin.y, cropRect.size.width, cropRect.size.height);

    if (cropRect.origin.y < 0.0f)
        cropRect = CGRectMake(cropRect.origin.x, 0.0f, cropRect.size.width, cropRect.size.height);

    CGFloat scaleX = self.originalVideoSize.width / self.videoView.frame.size.width;
    CGFloat scaleY = self.originalVideoSize.height / self.videoView.frame.size.height;
    
    cropRect = CGRectMake(cropRect.origin.x*scaleX, cropRect.origin.y*scaleY, cropRect.size.width*scaleX, cropRect.size.height*scaleY);

    self.transform = transform;
    
    return cropRect;
}


#pragma mark -
#pragma mark - getNationalVideoTransform

- (CGAffineTransform) getNationalVideoTransform
{
    CGAffineTransform transform = CGAffineTransformIdentity;
    transform = CGAffineTransformScale(self.nationalVideoTransform, self.mySX, self.mySY);
    
    if ((self.mySX == -1.0f)&&(self.mySY == -1.0f))  //FlipBoth
    {
        float radius = self.scaleValue * sqrtf(self.originalBounds.size.width*self.originalBounds.size.width + self.originalBounds.size.height*self.originalBounds.size.height)/2.0f;
        float angle = atanf(self.originalBounds.size.height/self.originalBounds.size.width);
        float rotAngle = (angle + self.rotateAngle) + M_PI;
        CGPoint centerPoint = [self convertPoint:self.videoView.center toView:self.superview];
        CGPoint translatePoint = CGPointMake(centerPoint.x - cosf(rotAngle)*radius, centerPoint.y - sinf(rotAngle)*radius);
        transform = CGAffineTransformMake(transform.a, transform.b, transform.c, transform.d, translatePoint.x, translatePoint.y);
    }
    else if ((self.mySX == -1.0f)&&(self.mySY == 1.0f))  //FlipH
    {
        float radius = self.scaleValue * sqrtf(self.originalBounds.size.width*self.originalBounds.size.width + self.originalBounds.size.height*self.originalBounds.size.height)/2.0f;
        float angle = atanf(self.originalBounds.size.height/self.originalBounds.size.width);
        float rotAngle = (angle + self.rotateAngle) + (M_PI - 2 * atanf(self.originalBounds.size.height/self.originalBounds.size.width));
        CGPoint centerPoint = [self convertPoint:self.videoView.center toView:self.superview];
        CGPoint translatePoint = CGPointMake(centerPoint.x - cosf(rotAngle)*radius, centerPoint.y - sinf(rotAngle)*radius);
        transform = CGAffineTransformMake(transform.a, transform.b, transform.c, transform.d, translatePoint.x, translatePoint.y);
    }
    else if ((self.mySX == 1.0f)&&(self.mySY == -1.0f))  //FlipV
    {
        float radius = self.scaleValue * sqrtf(self.originalBounds.size.width*self.originalBounds.size.width + self.originalBounds.size.height*self.originalBounds.size.height)/2.0f;
        float angle = atanf(self.originalBounds.size.height/self.originalBounds.size.width);
        float rotAngle = (angle + self.rotateAngle) + 2 * (M_PI - 2 * atanf(self.originalBounds.size.height/self.originalBounds.size.width)) + 2 * atanf(self.originalBounds.size.height/self.originalBounds.size.width);
        CGPoint centerPoint = [self convertPoint:self.videoView.center toView:self.superview];
        CGPoint translatePoint = CGPointMake(centerPoint.x - cosf(rotAngle)*radius, centerPoint.y - sinf(rotAngle)*radius);
        transform = CGAffineTransformMake(transform.a, transform.b, transform.c, transform.d, translatePoint.x, translatePoint.y);
    }
    else     //Normal
    {
        float radius = self.scaleValue * sqrtf(self.originalBounds.size.width*self.originalBounds.size.width + self.originalBounds.size.height*self.originalBounds.size.height)/2.0f;
        float angle = atanf(self.originalBounds.size.height/self.originalBounds.size.width);
        float rotAngle = angle + self.rotateAngle;
        CGPoint centerPoint = [self convertPoint:self.videoView.center toView:self.superview];
        CGPoint translatePoint = CGPointMake(centerPoint.x - cosf(rotAngle)*radius, centerPoint.y - sinf(rotAngle)*radius);
        
        transform = CGAffineTransformMake(transform.a, transform.b, transform.c, transform.d, translatePoint.x, translatePoint.y);
    }
    
    return transform;
}

- (CGAffineTransform) getReflectionNationalVideoTransform
{
    CGAffineTransform transform = CGAffineTransformIdentity;
    transform = CGAffineTransformScale(self.nationalVideoTransform, self.mySX, self.mySY);
    
    if ((self.mySX == -1.0f)&&(self.mySY == -1.0f))  //FlipBoth
    {
        float radius = self.scaleValue * sqrtf(self.originalBounds.size.width*self.originalBounds.size.width + self.originalBounds.size.height*self.originalBounds.size.height)/2.0f;
        float angle = atanf(self.originalBounds.size.height/self.originalBounds.size.width);
        float rotAngle = (angle + self.rotateAngle) + M_PI;
        CGPoint centerPoint = [self convertPoint:self.videoView.center toView:self.superview];
        CGPoint translatePoint = CGPointMake(centerPoint.x - cosf(rotAngle)*radius, centerPoint.y - sinf(rotAngle)*radius);
        
        rotAngle = M_PI - angle + self.rotateAngle;
        CGPoint translatePoint_ = CGPointMake(centerPoint.x - cosf(rotAngle)*radius, centerPoint.y - sinf(rotAngle)*radius);
        CGPoint reflectionPoint = CGPointMake(2*translatePoint_.x - translatePoint.x, 2*translatePoint_.y - translatePoint.y);
        
        CGFloat gapX = (reflectionPoint.x - translatePoint_.x)*self.reflectionGap / sqrtf((reflectionPoint.x - translatePoint_.x)*(reflectionPoint.x - translatePoint_.x) + (reflectionPoint.y - translatePoint_.y)*(reflectionPoint.y - translatePoint_.y));
        CGFloat gapY = (reflectionPoint.y - translatePoint_.y)*self.reflectionGap / sqrtf((reflectionPoint.x - translatePoint_.x)*(reflectionPoint.x - translatePoint_.x) + (reflectionPoint.y - translatePoint_.y)*(reflectionPoint.y - translatePoint_.y));
        
        CGPoint reflectionDeltaPnt = CGPointMake(self.reflectionDelta.x , self.reflectionDelta.y);
        CGPoint videoCenterDeltaPnt = CGPointMake(self.changedVideoCenter.x - self.originalVideoCenter.x, self.changedVideoCenter.y - self.originalVideoCenter.y);
        CGPoint deltaPnt = CGPointApplyAffineTransform(CGPointMake(reflectionDeltaPnt.x/* - videoCenterDeltaPnt.x*/, reflectionDeltaPnt.y - videoCenterDeltaPnt.y),  self.transform);
        transform = CGAffineTransformMake(transform.a, transform.b, transform.c, transform.d, reflectionPoint.x + self.scaleValue * gapX + deltaPnt.x*2.0f, reflectionPoint.y + self.scaleValue * gapY + deltaPnt.y*2.0f);
    }
    else if ((self.mySX == -1.0f)&&(self.mySY == 1.0f))  //FlipH
    {
        float radius = self.scaleValue * sqrtf(self.originalBounds.size.width*self.originalBounds.size.width + self.originalBounds.size.height*self.originalBounds.size.height)/2.0f;
        float angle = atanf(self.originalBounds.size.height/self.originalBounds.size.width);
        float rotAngle = (angle + self.rotateAngle) + (M_PI - 2 * atanf(self.originalBounds.size.height/self.originalBounds.size.width));
        CGPoint centerPoint = [self convertPoint:self.videoView.center toView:self.superview];
        CGPoint translatePoint = CGPointMake(centerPoint.x - cosf(rotAngle)*radius, centerPoint.y - sinf(rotAngle)*radius);
        
        rotAngle = M_PI + angle + self.rotateAngle;
        CGPoint translatePoint_ = CGPointMake(centerPoint.x - cosf(rotAngle)*radius, centerPoint.y - sinf(rotAngle)*radius);
        CGPoint reflectionPoint = CGPointMake(2*translatePoint_.x - translatePoint.x, 2*translatePoint_.y - translatePoint.y);
        
        CGFloat gapX = (reflectionPoint.x - translatePoint_.x)*self.reflectionGap / sqrtf((reflectionPoint.x - translatePoint_.x)*(reflectionPoint.x - translatePoint_.x) + (reflectionPoint.y - translatePoint_.y)*(reflectionPoint.y - translatePoint_.y));
        CGFloat gapY = (reflectionPoint.y - translatePoint_.y)*self.reflectionGap / sqrtf((reflectionPoint.x - translatePoint_.x)*(reflectionPoint.x - translatePoint_.x) + (reflectionPoint.y - translatePoint_.y)*(reflectionPoint.y - translatePoint_.y));
        
        CGPoint reflectionDeltaPnt = CGPointMake(self.reflectionDelta.x , self.reflectionDelta.y);
        CGPoint videoCenterDeltaPnt = CGPointMake(self.changedVideoCenter.x - self.originalVideoCenter.x, self.changedVideoCenter.y - self.originalVideoCenter.y);
        CGPoint deltaPnt = CGPointApplyAffineTransform(CGPointMake(reflectionDeltaPnt.x/* - videoCenterDeltaPnt.x*/, reflectionDeltaPnt.y - videoCenterDeltaPnt.y),  self.transform);
        transform = CGAffineTransformMake(transform.a, transform.b, transform.c, transform.d, reflectionPoint.x + self.scaleValue * gapX + deltaPnt.x*2.0f, reflectionPoint.y + self.scaleValue * gapY + deltaPnt.y*2.0f);
    }
    else if ((self.mySX == 1.0f)&&(self.mySY == -1.0f))  //FlipV
    {
        float radius = self.scaleValue * sqrtf(self.originalBounds.size.width*self.originalBounds.size.width + self.originalBounds.size.height*self.originalBounds.size.height)/2.0f;
        float angle = atanf(self.originalBounds.size.height/self.originalBounds.size.width);
        float rotAngle = (angle + self.rotateAngle) + 2 * (M_PI - 2 * atanf(self.originalBounds.size.height/self.originalBounds.size.width)) + 2 * atanf(self.originalBounds.size.height/self.originalBounds.size.width);
        CGPoint centerPoint = [self convertPoint:self.videoView.center toView:self.superview];
        CGPoint translatePoint = CGPointMake(centerPoint.x - cosf(rotAngle)*radius, centerPoint.y - sinf(rotAngle)*radius);
        
        rotAngle = angle + self.rotateAngle;
        CGPoint translatePoint_ = CGPointMake(centerPoint.x - cosf(rotAngle)*radius, centerPoint.y - sinf(rotAngle)*radius);
        CGPoint reflectionPoint = CGPointMake(2*translatePoint_.x - translatePoint.x, 2*translatePoint_.y - translatePoint.y);
        
        CGFloat gapX = (reflectionPoint.x - translatePoint_.x)*self.reflectionGap / sqrtf((reflectionPoint.x - translatePoint_.x)*(reflectionPoint.x - translatePoint_.x) + (reflectionPoint.y - translatePoint_.y)*(reflectionPoint.y - translatePoint_.y));
        CGFloat gapY = (reflectionPoint.y - translatePoint_.y)*self.reflectionGap / sqrtf((reflectionPoint.x - translatePoint_.x)*(reflectionPoint.x - translatePoint_.x) + (reflectionPoint.y - translatePoint_.y)*(reflectionPoint.y - translatePoint_.y));
        
        CGPoint reflectionDeltaPnt = CGPointMake(self.reflectionDelta.x , self.reflectionDelta.y);
        CGPoint videoCenterDeltaPnt = CGPointMake(self.changedVideoCenter.x - self.originalVideoCenter.x, self.changedVideoCenter.y - self.originalVideoCenter.y);
        CGPoint deltaPnt = CGPointApplyAffineTransform(CGPointMake(reflectionDeltaPnt.x/* - videoCenterDeltaPnt.x*/, reflectionDeltaPnt.y - videoCenterDeltaPnt.y),  self.transform);
        transform = CGAffineTransformMake(transform.a, transform.b, transform.c, transform.d, reflectionPoint.x + self.scaleValue * gapX + deltaPnt.x*2.0f, reflectionPoint.y + self.scaleValue * gapY + deltaPnt.y*2.0f);
    }
    else     //Normal
    {
        float radius = self.scaleValue * sqrtf(self.originalBounds.size.width*self.originalBounds.size.width + self.originalBounds.size.height*self.originalBounds.size.height)/2.0f;
        float angle = atanf(self.originalBounds.size.height/self.originalBounds.size.width);
        float rotAngle = angle + self.rotateAngle;
        CGPoint centerPoint = [self convertPoint:CGPointMake(self.videoView.center.x, self.videoView.center.y) toView:self.superview];
        CGPoint translatePoint = CGPointMake(centerPoint.x - cosf(rotAngle)*radius, centerPoint.y - sinf(rotAngle)*radius);
        
        rotAngle = 2*M_PI - angle + self.rotateAngle;
        CGPoint translatePoint_ = CGPointMake(centerPoint.x - cosf(rotAngle)*radius, centerPoint.y - sinf(rotAngle)*radius);
        CGPoint reflectionPoint = CGPointMake(2*translatePoint_.x - translatePoint.x, 2*translatePoint_.y - translatePoint.y);
        
        CGFloat gapX = (reflectionPoint.x - translatePoint_.x)*self.reflectionGap / sqrtf((reflectionPoint.x - translatePoint_.x)*(reflectionPoint.x - translatePoint_.x) + (reflectionPoint.y - translatePoint_.y)*(reflectionPoint.y - translatePoint_.y));
        CGFloat gapY = (reflectionPoint.y - translatePoint_.y)*self.reflectionGap / sqrtf((reflectionPoint.x - translatePoint_.x)*(reflectionPoint.x - translatePoint_.x) + (reflectionPoint.y - translatePoint_.y)*(reflectionPoint.y - translatePoint_.y));
        
        CGPoint reflectionDeltaPnt = CGPointMake(self.reflectionDelta.x , self.reflectionDelta.y);
        CGPoint videoCenterDeltaPnt = CGPointMake(self.changedVideoCenter.x - self.originalVideoCenter.x, self.changedVideoCenter.y - self.originalVideoCenter.y);
        CGPoint deltaPnt = CGPointApplyAffineTransform(CGPointMake(reflectionDeltaPnt.x/* - videoCenterDeltaPnt.x*/, reflectionDeltaPnt.y - videoCenterDeltaPnt.y),  self.transform);
        transform = CGAffineTransformMake(transform.a, transform.b, transform.c, transform.d, reflectionPoint.x + self.scaleValue * gapX + deltaPnt.x*2.0f, reflectionPoint.y + self.scaleValue * gapY + deltaPnt.y*2.0f);
    }
    
    return transform;
}


#pragma mark -
#pragma mark - get video crop rect

- (CGRect) getVideoCropRect
{
    CGAffineTransform transform = self.transform;
    self.transform = CGAffineTransformIdentity;

    CGRect cropRect = CGRectIntersection(self.videoView.frame, self.bounds);
    cropRect = CGRectMake((-1)*self.videoView.frame.origin.x, (-1)*self.videoView.frame.origin.y, cropRect.size.width, cropRect.size.height);
    cropRect = CGRectMake(cropRect.origin.x*self.originalVideoSize.width/self.videoView.frame.size.width, cropRect.origin.y*self.originalVideoSize.height/self.videoView.frame.size.height, cropRect.size.width*self.originalVideoSize.width/self.videoView.frame.size.width, cropRect.size.height*self.self.originalVideoSize.height/self.videoView.frame.size.height);
    
    if (cropRect.origin.x < 0.0f)
        cropRect = CGRectMake(0.0f, cropRect.origin.y, cropRect.size.width, cropRect.size.height);

    if (cropRect.origin.y < 0.0f)
        cropRect = CGRectMake(cropRect.origin.x, 0.0f, cropRect.size.width, cropRect.size.height);
    
    cropRect = CGRectMake(cropRect.origin.x / self.originalVideoSize.width, cropRect.origin.y / self.originalVideoSize.height, cropRect.size.width / self.originalVideoSize.width, cropRect.size.height / self.originalVideoSize.height);
    
    self.transform = transform;
    
    return cropRect;
}

- (CGRect) getIntersectionRect
{
    CGRect intersectRect = CGRectZero;
    
    CGAffineTransform transform = self.transform;
    self.transform = CGAffineTransformIdentity;
    intersectRect = CGRectIntersection(self.videoView.frame, self.bounds);
    self.transform = transform;

    return intersectRect;
}


#pragma mark -
#pragma mark - object copy: oldObject params to NewObject params

- (void) objectCopy:(MediaObjectView*) oldObject
{
    self.mediaType = oldObject.mediaType;
    self.objectIndex = oldObject.objectIndex;
    self.workspaceSize = oldObject.workspaceSize;
    self.isSelected = oldObject.isSelected;
    self.isMask = oldObject.isMask;
    self.isArrowActived = oldObject.isArrowActived;
    self.isPlaying = oldObject.isPlaying;
    self.mediaDuration = oldObject.mediaDuration;
    self.mediaVolume = oldObject.mediaVolume;
    self.mediaUrl = oldObject.mediaUrl;
    self.imageName = oldObject.imageName;
    self.inputTransform = oldObject.inputTransform;
    self.selectedLineLayer = oldObject.selectedLineLayer;
    self.maskLayer = oldObject.maskLayer;
    self.imageView = oldObject.imageView;
    self.imageView.image = oldObject.imageView.image;
    self.videoView = oldObject.videoView;
    self.mediaView = oldObject.mediaView;
    self.originalImage = oldObject.originalImage;
    
    if (self.mediaType == MEDIA_TEXT)
    {
        self.textView = oldObject.textView;
        self.textView.textColor = oldObject.textView.textColor;
        self.textView.font = oldObject.textView.font;
        self.textView.textAlignment = oldObject.textView.textAlignment;
        self.isBold = oldObject.isBold;
        self.isItalic = oldObject.isItalic;
        self.isUnderline = oldObject.isUnderline;
        self.isStroke = oldObject.isStroke;
    }

    self.mediaAsset = oldObject.mediaAsset;
    self.videoAssetTrack = oldObject.videoAssetTrack;
    self.nationalVideoTransform = oldObject.nationalVideoTransform;
    self.nationalVideoTransformOutputValue = oldObject.nationalVideoTransformOutputValue;
    self.nationalReflectionVideoTransformOutputValue = oldObject.nationalReflectionVideoTransformOutputValue;
    self.mfStartPosition = oldObject.mfStartPosition;
    self.mfEndPosition = oldObject.mfEndPosition;
    self.mfStartAnimationDuration = oldObject.mfStartAnimationDuration;
    self.mfEndAnimationDuration = oldObject.mfEndAnimationDuration;
    self.startActionType = oldObject.startActionType;
    self.endActionType = oldObject.endActionType;
    self.frame = oldObject.frame;
    self.bounds = oldObject.bounds;
    self.transform = oldObject.transform;
    self.lastScaleFactor = oldObject.lastScaleFactor;
    self.firstX = oldObject.firstX;
    self.firstY = oldObject.firstY;
    self.lastPoint = oldObject.lastPoint;
    self.videoTransform = oldObject.videoTransform;
    self.originalVideoSize = oldObject.originalVideoSize;
    self.firstTouchedPoint = oldObject.firstTouchedPoint;
    self.boundMode = oldObject.boundMode;
    self.rotateAngle = oldObject.rotateAngle;
    self.scaleValue = oldObject.scaleValue;
    self.portraitSpecialScale = oldObject.portraitSpecialScale;
    self.originalBounds = oldObject.originalBounds;
    self.normalFilterVideoCropRect = oldObject.normalFilterVideoCropRect;
    self.mySX = oldObject.mySX;
    self.mySY = oldObject.mySY;
    self.isExistAudioTrack = NO;
    self.objectBorderStyle = oldObject.objectBorderStyle;
    self.objectBorderWidth = oldObject.objectBorderWidth;
    self.objectBorderColor = oldObject.objectBorderColor;
    self.objectChromaColor = oldObject.objectChromaColor;
    self.objectShadowStyle = oldObject.objectShadowStyle;
    self.objectShadowBlur = oldObject.objectShadowBlur;
    self.objectShadowOffset = oldObject.objectShadowOffset;
    self.objectShadowColor = oldObject.objectShadowColor;
    self.objectCornerRadius = oldObject.objectCornerRadius;
    self.superViewSize = oldObject.superViewSize;
    self.isReflection = oldObject.isReflection;
    self.reflectionScale = oldObject.reflectionScale;
    self.reflectionAlpha = oldObject.reflectionAlpha;
    self.reflectionGap = oldObject.reflectionGap;
    self.reflectionDelta = oldObject.reflectionDelta;
    self.originalVideoCenter = oldObject.originalVideoCenter;
    self.changedVideoCenter = oldObject.changedVideoCenter;
    self.motionArray = [oldObject.motionArray copy];
    self.startPositionArray = [oldObject.startPositionArray copy];
    self.endPositionArray = [oldObject.endPositionArray copy];
    self.isKbEnabled = oldObject.isKbEnabled;
    self.nKbIn = oldObject.nKbIn;
    self.kbFocusPoint = oldObject.kbFocusPoint;
    self.fKbScale = oldObject.fKbScale;
    self.isShape = oldObject.isShape;
    self.isGrouped = oldObject.isGrouped;

    [self update];
}


#pragma mark - OldObjectView to NewObjectView

- (void) setObjectValuesFromOldObject:(MediaObjectView*) oldObject
{
    self.mediaType = oldObject.mediaType;
    self.workspaceSize = oldObject.workspaceSize;
    self.isPlaying = oldObject.isPlaying;
    self.mediaDuration = oldObject.mediaDuration;
    self.mediaVolume = oldObject.mediaVolume;
    self.inputTransform = oldObject.inputTransform;
    self.mediaView.frame = oldObject.mediaView.frame;
    self.imageView.frame = oldObject.imageView.frame;
    self.videoView.frame = oldObject.videoView.frame;
    self.nationalVideoTransform = oldObject.nationalVideoTransform;
    self.nationalVideoTransformOutputValue = oldObject.nationalVideoTransformOutputValue;
    self.nationalReflectionVideoTransformOutputValue = oldObject.nationalReflectionVideoTransformOutputValue;
    self.mfStartPosition = oldObject.mfStartPosition;
    self.mfEndPosition = oldObject.mfEndPosition;
    self.mfStartAnimationDuration = oldObject.mfStartAnimationDuration;
    self.mfEndAnimationDuration = oldObject.mfEndAnimationDuration;
    self.startActionType = oldObject.startActionType;
    self.endActionType = oldObject.endActionType;
    self.frame = oldObject.frame;
    self.bounds = oldObject.bounds;
    self.transform = oldObject.transform;
    self.lastScaleFactor = oldObject.lastScaleFactor;
    self.firstX = oldObject.firstX;
    self.firstY = oldObject.firstY;
    self.lastPoint = oldObject.lastPoint;
    self.videoTransform = oldObject.videoTransform;
    self.originalVideoSize = oldObject.originalVideoSize;
    self.firstTouchedPoint = oldObject.firstTouchedPoint;
    self.boundMode = oldObject.boundMode;
    self.rotateAngle = oldObject.rotateAngle;
    self.scaleValue = oldObject.scaleValue;
    self.portraitSpecialScale = oldObject.portraitSpecialScale;
    self.originalBounds = oldObject.originalBounds;
    self.normalFilterVideoCropRect = oldObject.normalFilterVideoCropRect;
    self.mySX = oldObject.mySX;
    self.mySY = oldObject.mySY;
    self.originalImage = oldObject.originalImage;

    CGFloat currentScaleX = sqrtf(powf(self.transform.a, 2) + powf(self.transform.c, 2));

    if (currentScaleX == 0.0f)
    {
        currentScaleX = 1.0f;
    }
    
    CGAffineTransform transform = CGAffineTransformMakeScale(1 / currentScaleX, 1 / currentScaleX);
    self.maskArrowTop.transform = transform;
    self.maskArrowLeft.transform = transform;
    self.maskArrowRight.transform = transform;
    self.maskArrowBottom.transform = transform;
    
    self.maskArrowLeft.center = CGPointMake(self.maskArrowLeft.frame.size.width/2, self.bounds.size.height/2);
    self.maskArrowRight.center = CGPointMake(self.bounds.size.width-self.maskArrowRight.frame.size.width/2, self.bounds.size.height/2);
    self.maskArrowTop.center = CGPointMake(self.bounds.size.width/2, self.maskArrowTop.frame.size.height/2);
    self.maskArrowBottom.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height-self.maskArrowBottom.frame.size.height/2);

    self.selectedLineLayer.lineWidth = 4 / currentScaleX;

    if (self.mediaType == MEDIA_PHOTO)
        [self changeImageMaskBound:nil];
    else if ((self.mediaType == MEDIA_VIDEO)||(self.mediaType == MEDIA_GIF))
        [self changeVideoMaskBound:nil];
    
    self.borderLineLayer.frame = oldObject.borderLineLayer.frame;
    self.superViewSize = oldObject.superViewSize;
    self.objectBorderStyle = oldObject.objectBorderStyle;
    self.objectBorderWidth = oldObject.objectBorderWidth;
    self.objectBorderColor = oldObject.objectBorderColor;
    self.objectChromaColor = oldObject.objectChromaColor;
    self.objectShadowStyle = oldObject.objectShadowStyle;
    self.objectShadowBlur = oldObject.objectShadowBlur;
    self.objectShadowOffset = oldObject.objectShadowOffset;
    self.objectShadowColor = oldObject.objectShadowColor;
    self.objectCornerRadius = oldObject.objectCornerRadius;

    [self applyBorder];
    [self applyShadow];

    if (self.mediaType == MEDIA_TEXT)
    {
        self.textView.frame = oldObject.textView.frame;
        self.textView.textColor = oldObject.textView.textColor;
        self.textView.font = oldObject.textView.font;
        self.textView.textAlignment = oldObject.textView.textAlignment;
        self.isBold = oldObject.isBold;
        self.isItalic = oldObject.isItalic;
        self.isUnderline = oldObject.isUnderline;
        self.isStroke = oldObject.isStroke;
        self.textObjectFontSize = oldObject.textObjectFontSize;
        self.textView.alpha = oldObject.textView.alpha;
        
        [self initTextAttributed];
    }
    else
    {
        self.imageView.alpha = oldObject.imageView.alpha;
    }
    
    self.isReflection = oldObject.isReflection;
    self.reflectionScale = oldObject.reflectionScale;
    self.reflectionAlpha = oldObject.reflectionAlpha;
    self.reflectionGap = oldObject.reflectionGap;
    self.reflectionDelta = oldObject.reflectionDelta;
    self.originalVideoCenter = oldObject.originalVideoCenter;
    self.changedVideoCenter = oldObject.changedVideoCenter;
    self.motionArray = [oldObject.motionArray copy];
    self.startPositionArray = [oldObject.startPositionArray copy];
    self.endPositionArray = [oldObject.endPositionArray copy];
    self.isKbEnabled = oldObject.isKbEnabled;
    self.nKbIn = oldObject.nKbIn;
    self.kbFocusPoint = oldObject.kbFocusPoint;
    self.fKbScale = oldObject.fKbScale;
    self.isShape = oldObject.isShape;
    self.isGrouped = oldObject.isGrouped;

    [self update];
}


/*******************************************************************************************************/
#pragma mark -
#pragma mark - Object Setting
/*********************************************************************************************************/

-(void) objectSettingShow
{
    [self maskArrowsHidden];
    
    if ([self.delegate respondsToSelector:@selector(objectSettingViewShow:)])
    {
        [self.delegate objectSettingViewShow:self.objectIndex];
    }
}

-(void) flip:(int) index
{
    CGFloat rX = 1.0f;
    CGFloat rY = 1.0f;
    
    if (index == 0) //flip H
    {
        rX = -1.0f;
        rY = 1.0f;
    }
    else if (index == 1)    //filp V
    {
        rX = 1.0f;
        rY = -1.0f;
    }
    else    //flip duplicate
    {
        rX = -1.0f;
        rY = -1.0f;
    }
    
    self.transform = CGAffineTransformScale(self.transform, rX, rY);
    self.videoTransform = CGAffineTransformScale(self.videoTransform, rX, rY);

    self.mySX *= rX;
    self.mySY *= rY;
}


CGPathRef CGPathCreateRoundRect( const CGRect r, const CGFloat cornerRadius )
{
    CGMutablePathRef p = CGPathCreateMutable() ;
    
    CGPathMoveToPoint( p, NULL, r.origin.x + cornerRadius, r.origin.y ) ;
    
    CGFloat maxX = CGRectGetMaxX( r ) ;
    CGFloat maxY = CGRectGetMaxY( r ) ;
    
    CGPathAddArcToPoint( p, NULL, maxX, r.origin.y, maxX, r.origin.y + cornerRadius, cornerRadius ) ;
    CGPathAddArcToPoint( p, NULL, maxX, maxY, maxX - cornerRadius, maxY, cornerRadius ) ;
    CGPathAddArcToPoint( p, NULL, r.origin.x, maxY, r.origin.x, maxY - cornerRadius, cornerRadius ) ;
    CGPathAddArcToPoint( p, NULL, r.origin.x, r.origin.y, r.origin.x + cornerRadius, r.origin.y, cornerRadius ) ;
    
    return p ;
}

- (void) applySelectedLinePath
{
    CGFloat radius = self.objectCornerRadius;
    
    if (self.mediaType == MEDIA_MUSIC)
    {
        CGPathRef path = CGPathCreateRoundRect(CGRectMake(0.0f, 0.0f, self.bounds.size.width, self.bounds.size.height), radius);
        self.selectedLineLayer.path = path;
        CGPathRelease(path);
    }
    else
    {
        if ((self.bounds.size.height >= self.bounds.size.width) && (radius > self.bounds.size.width/2))
        {
            radius = self.bounds.size.width/2;
        }
        else if ((self.bounds.size.height < self.bounds.size.width) && (radius > self.bounds.size.height/2))
        {
            radius = self.bounds.size.height/2;
        }
        
        CGPathRef path = CGPathCreateRoundRect(CGRectMake(0.0f, 0.0f, self.mediaView.bounds.size.width, self.mediaView.bounds.size.height), radius);
        self.selectedLineLayer.path = path;
        self.maskLayer.path = path;
        CGPathRelease(path);
    }
}

- (void) applyBorderLinePath
{
    if (self.objectCornerRadius == 0.0f)
    {
        UIBezierPath* path = [UIBezierPath bezierPathWithRect:CGRectMake(self.objectBorderWidth/2.0f, self.objectBorderWidth/2.0f, self.mediaView.bounds.size.width+self.objectBorderWidth, self.mediaView.bounds.size.height+self.objectBorderWidth)];
        self.borderLineLayer.path = path.CGPath;
    }
    else
    {
        CGFloat radius = self.objectCornerRadius + self.objectBorderWidth/2;
        
        if ((self.bounds.size.height >= self.bounds.size.width) && (radius > self.bounds.size.width/2 + self.objectBorderWidth/2))
        {
            radius = self.bounds.size.width/2 + self.objectBorderWidth/2;
        }
        else if ((self.bounds.size.height < self.bounds.size.width) && (radius > self.bounds.size.height/2 + self.objectBorderWidth/2))
        {
            radius = self.bounds.size.height/2 + self.objectBorderWidth/2;
        }
        
        CGPathRef path = CGPathCreateRoundRect(CGRectMake(self.objectBorderWidth/2.0f, self.objectBorderWidth/2.0f, self.mediaView.bounds.size.width+self.objectBorderWidth, self.mediaView.bounds.size.height+self.objectBorderWidth), radius);
        self.borderLineLayer.path = path;
        CGPathRelease(path);
    }
}


#pragma mark - Apply Border

- (void)applyBorder
{
    UIImage* borderImage = nil;
    
    self.borderLineLayer.fillColor = nil;
    self.borderLineLayer.lineWidth = self.objectBorderWidth;
    self.borderLineLayer.frame = CGRectMake(-self.objectBorderWidth, -self.objectBorderWidth, self.mediaView.bounds.size.width+self.objectBorderWidth*2.0f, self.mediaView.bounds.size.height+self.objectBorderWidth*2.0f);
    
    [self applyBorderLinePath];
    [self applyShadow];
    [self applySelectedLinePath];

    switch (self.objectBorderStyle)
    {
        case 1: //NO OUTLINE
            self.borderLineLayer.strokeColor = [UIColor clearColor].CGColor;
            break;
        case 2: //line
            self.borderLineLayer.strokeColor = self.objectBorderColor.CGColor;
            [self.borderLineLayer setLineCap:kCALineCapButt];
            [self.borderLineLayer setLineJoin:kCALineJoinMiter];
            [self.borderLineLayer setLineDashPattern:nil];
            break;
        case 3: //shot dot line
            self.borderLineLayer.strokeColor = self.objectBorderColor.CGColor;
            [self.borderLineLayer setLineCap:kCALineCapButt];
            [self.borderLineLayer setLineJoin:kCALineJoinMiter];
            [self.borderLineLayer setLineDashPattern:
             [NSArray arrayWithObjects:[NSNumber numberWithFloat:self.objectBorderWidth],
              [NSNumber numberWithFloat:self.objectBorderWidth],
              nil]];
            break;
        case 4: //middle dot line
            self.borderLineLayer.strokeColor = self.objectBorderColor.CGColor;
            [self.borderLineLayer setLineCap:kCALineCapButt];
            [self.borderLineLayer setLineJoin:kCALineJoinMiter];
            [self.borderLineLayer setLineDashPattern:
             [NSArray arrayWithObjects:[NSNumber numberWithFloat:self.objectBorderWidth*1.5f],
              [NSNumber numberWithFloat:self.objectBorderWidth*1.5f],
              nil]];
            break;
        case 5: //long dot line
            self.borderLineLayer.strokeColor = self.objectBorderColor.CGColor;
            [self.borderLineLayer setLineCap:kCALineCapButt];
            [self.borderLineLayer setLineJoin:kCALineJoinMiter];
            [self.borderLineLayer setLineDashPattern:
             [NSArray arrayWithObjects:[NSNumber numberWithFloat:self.objectBorderWidth*3.0f],
              [NSNumber numberWithFloat:self.objectBorderWidth*3.0f],
              nil]];
            break;
        case 6: //circle line
            self.borderLineLayer.strokeColor = self.objectBorderColor.CGColor;
            [self.borderLineLayer setLineCap:kCALineCapRound];
            [self.borderLineLayer setLineJoin:kCALineJoinMiter];
            [self.borderLineLayer setLineDashPattern:
             [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.1f],
              [NSNumber numberWithFloat:self.objectBorderWidth*2.0f],
              nil]];
            break;
        case 7: //two dots line
            borderImage = [UIImage imageNamed:@"dotline_pattern"];
            borderImage = [borderImage rescaleImageToSize:CGSizeMake(self.objectBorderWidth, self.objectBorderWidth)];
            borderImage = [borderImage imageWithOverlayColor:self.objectBorderColor];
            self.borderLineLayer.strokeColor = [UIColor colorWithPatternImage:borderImage].CGColor;
            [self.borderLineLayer setLineCap:kCALineCapButt];
            [self.borderLineLayer setLineJoin:kCALineJoinMiter];
            [self.borderLineLayer setLineDashPattern:nil];
            break;
        case 8: //jigsaw line
            borderImage = [UIImage imageNamed:@"dotline_pattern"];
            borderImage = [borderImage imageWithOverlayColor:self.objectBorderColor];
            self.borderLineLayer.strokeColor = [UIColor colorWithPatternImage:borderImage].CGColor;
            [self.borderLineLayer setLineCap:kCALineCapButt];
            [self.borderLineLayer setLineJoin:kCALineJoinMiter];
            [self.borderLineLayer setLineDashPattern:nil];
            break;
        case 9: //flower line
            borderImage = [UIImage imageNamed:@"flower"];
            borderImage = [borderImage rescaleImageToSize:CGSizeMake(self.objectBorderWidth, self.objectBorderWidth)];
            borderImage = [borderImage imageWithOverlayColor:self.objectBorderColor];
            self.borderLineLayer.strokeColor = [UIColor colorWithPatternImage:borderImage].CGColor;
            [self.borderLineLayer setLineCap:kCALineCapButt];
            [self.borderLineLayer setLineJoin:kCALineJoinMiter];
            [self.borderLineLayer setLineDashPattern:nil];
            break;
        case 10: //black circle line
            borderImage = [UIImage imageNamed:@"circle"];
            borderImage = [borderImage rescaleImageToSize:CGSizeMake(self.objectBorderWidth, self.objectBorderWidth)];
            borderImage = [borderImage imageWithOverlayColor:self.objectBorderColor];
            self.borderLineLayer.strokeColor = [UIColor colorWithPatternImage:borderImage].CGColor;
            [self.borderLineLayer setLineCap:kCALineCapButt];
            [self.borderLineLayer setLineJoin:kCALineJoinMiter];
            [self.borderLineLayer setLineDashPattern:nil];
            break;
        default:
            break;
    }
}


#pragma mark - Apply Shadow

- (void)applyShadow
{
    if (self.objectShadowStyle == 1)    //no shadow
    {
        if (self.mediaType == MEDIA_TEXT)
        {
            self.textView.layer.shadowOffset = CGSizeMake(self.objectShadowOffset, self.objectShadowOffset);
            self.textView.layer.shadowColor = [UIColor clearColor].CGColor;
            self.textView.layer.shadowOpacity = self.textView.alpha;
            self.textView.layer.shadowRadius = self.objectShadowBlur;

            self.borderLineLayer.shadowColor = [UIColor clearColor].CGColor;
            self.borderLineLayer.shadowOpacity = self.textView.alpha;
            self.borderLineLayer.shadowOffset = CGSizeMake(self.objectShadowOffset, self.objectShadowOffset);
            self.borderLineLayer.shadowRadius = self.objectShadowBlur;
        }
        else
        {
            self.layer.shadowOffset = CGSizeMake(self.objectShadowOffset, self.objectShadowOffset);
            self.layer.shadowColor = [UIColor clearColor].CGColor;
            self.layer.shadowOpacity = self.imageView.alpha;
            self.layer.shadowRadius = self.objectShadowBlur;
        }
    }
    else if (self.objectShadowStyle == 2)   //shadow
    {
        if (self.mediaType == MEDIA_TEXT)
        {
            self.textView.layer.shadowOffset = CGSizeMake(self.objectShadowOffset, self.objectShadowOffset);
            self.textView.layer.shadowColor = self.objectShadowColor.CGColor;
            self.textView.layer.shadowOpacity = self.textView.alpha;
            self.textView.layer.shadowRadius = self.objectShadowBlur;
            
            self.borderLineLayer.shadowColor = self.objectShadowColor.CGColor;
            self.borderLineLayer.shadowOpacity = self.textView.alpha;
            self.borderLineLayer.shadowOffset = CGSizeMake(self.objectShadowOffset, self.objectShadowOffset);
            self.borderLineLayer.shadowRadius = self.objectShadowBlur;
        }
        else
        {
            self.layer.shadowOffset = CGSizeMake(self.objectShadowOffset, self.objectShadowOffset);
            self.layer.shadowColor = self.objectShadowColor.CGColor;
            self.layer.shadowOpacity = self.imageView.alpha;
            self.layer.shadowRadius = self.objectShadowBlur;
        }
    }
}


-(UIBezierPath*) getBorderPath:(CGPoint) pnt
{
    CGFloat radius = 0.0f;
    UIBezierPath* path;
    
    if (self.objectCornerRadius == 0.0f)
    {
        path = [UIBezierPath bezierPathWithRect:CGRectMake(pnt.x - self.bounds.size.width*0.5f - self.objectBorderWidth*0.5f, pnt.y - self.bounds.size.height*0.5f - self.objectBorderWidth*0.5f, self.bounds.size.width + self.objectBorderWidth, self.bounds.size.height + self.objectBorderWidth)];
    }
    else
    {
        radius = self.objectCornerRadius + self.objectBorderWidth/2;
        
        if ((self.bounds.size.height >= self.bounds.size.width) && (radius > self.bounds.size.width/2 + self.objectBorderWidth/2))
        {
            radius = self.bounds.size.width/2 + self.objectBorderWidth/2;
        }
        else if ((self.bounds.size.height < self.bounds.size.width) && (radius > self.bounds.size.height/2 + self.objectBorderWidth/2))
        {
            radius = self.bounds.size.height/2 + self.objectBorderWidth/2;
        }
        
        CGPathRef pathRef = CGPathCreateRoundRect(CGRectMake(pnt.x - self.bounds.size.width*0.5f - self.objectBorderWidth*0.5f, pnt.y - self.bounds.size.height*0.5f - self.objectBorderWidth*0.5f, self.bounds.size.width + self.objectBorderWidth, self.bounds.size.height + self.objectBorderWidth), radius);
        path = [UIBezierPath bezierPathWithCGPath:pathRef];
        CGPathRelease(pathRef);
    }

    return path;
}

-(UIBezierPath*) getErasePath:(CGPoint) pnt
{
    CGSize boundsSize = self.bounds.size;
    CGFloat radius = 0.0f;
    UIBezierPath* path;
    
    if (self.objectCornerRadius == 0.0f)
    {
        path = [UIBezierPath bezierPathWithRect:CGRectMake(pnt.x - boundsSize.width*0.5f, pnt.y - boundsSize.height*0.5f, boundsSize.width, boundsSize.height)];
    }
    else
    {
        radius = self.objectCornerRadius;
        
        if ((boundsSize.height >= boundsSize.width) && (radius > boundsSize.width/2))
        {
            radius = boundsSize.width/2;
        }
        else if ((boundsSize.height < boundsSize.width) && (radius > boundsSize.height/2))
        {
            radius = boundsSize.height/2;
        }
        
        CGPathRef pathRef = CGPathCreateRoundRect(CGRectMake(pnt.x - boundsSize.width*0.5f, pnt.y - boundsSize.height*0.5f, boundsSize.width, boundsSize.height), radius);
        path = [UIBezierPath bezierPathWithCGPath:pathRef];
        CGPathRelease(pathRef);
    }
    
    return path;
}


-(UIBezierPath*) getPatternBorderPath:(CGSize) imageSize
{
    CGSize originalBoundSize = self.originalBounds.size;
    CGSize boundsSize = self.bounds.size;
    CGSize _size = self.imageView.image.size;
    
    if (self.isShape)
    {
        _size = imageSize;
    }

    CGFloat radius = 0.0f;
    UIBezierPath* path;
    
    if (self.objectCornerRadius == 0.0f)
    {
        path = [UIBezierPath bezierPathWithRect:CGRectMake(self.objectBorderWidth*_size.width/originalBoundSize.width*0.5f, self.objectBorderWidth*_size.width/originalBoundSize.width*0.5f, imageSize.width+self.objectBorderWidth*_size.width/originalBoundSize.width, imageSize.height+self.objectBorderWidth*_size.width/originalBoundSize.width)];
    }
    else
    {
        radius = self.objectCornerRadius + self.objectBorderWidth/2;
        
        if ((boundsSize.height >= boundsSize.width) && (radius > boundsSize.width/2 + self.objectBorderWidth/2))
        {
            radius = boundsSize.width/2 + self.objectBorderWidth/2;
        }
        else if ((boundsSize.height < boundsSize.width) && (radius > boundsSize.height/2 + self.objectBorderWidth/2))
        {
            radius = boundsSize.height/2 + self.objectBorderWidth/2;
        }
        
        CGPathRef pathRef = CGPathCreateRoundRect(CGRectMake(self.objectBorderWidth*_size.width/originalBoundSize.width*0.5f, self.objectBorderWidth*_size.width/originalBoundSize.width*0.5f, imageSize.width+self.objectBorderWidth*_size.width/originalBoundSize.width, imageSize.height+self.objectBorderWidth*_size.width/originalBoundSize.width), radius*_size.width/originalBoundSize.width);
        path = [UIBezierPath bezierPathWithCGPath:pathRef];
        CGPathRelease(pathRef);
    }

    return path;
}

-(UIBezierPath*) getTextPatternBorderPath
{
    CGFloat radius = 0.0f;
    UIBezierPath* path;

    if (self.objectCornerRadius == 0.0f)
    {
        path = [UIBezierPath bezierPathWithRect:CGRectMake(self.objectBorderWidth*0.5f, self.objectBorderWidth*0.5f, self.textView.frame.size.width+self.objectBorderWidth, self.textView.frame.size.height+self.objectBorderWidth)];
    }
    else
    {
        radius = self.objectCornerRadius + self.objectBorderWidth/2;
        
        if ((self.bounds.size.height >= self.bounds.size.width) && (radius > self.bounds.size.width/2 + self.objectBorderWidth/2))
        {
            radius = self.bounds.size.width/2 + self.objectBorderWidth/2;
        }
        else if ((self.bounds.size.height < self.bounds.size.width) && (radius > self.bounds.size.height/2 + self.objectBorderWidth/2))
        {
            radius = self.bounds.size.height/2 + self.objectBorderWidth/2;
        }
        
        CGPathRef pathRef = CGPathCreateRoundRect(CGRectMake(self.objectBorderWidth*0.5f, self.objectBorderWidth*0.5f, self.textView.frame.size.width+self.objectBorderWidth, self.textView.frame.size.height+self.objectBorderWidth), radius);
        path = [UIBezierPath bezierPathWithCGPath:pathRef];
        CGPathRelease(pathRef);
    }
    
    return path;
}

#pragma mark - render image with corner

- (UIImage*) renderImageWithCorner:(UIImage*)image
{
    CGSize originalBoundSize = self.originalBounds.size;
    CGSize boundsSize = self.bounds.size;
    CGSize mediaViewBoundSize = self.mediaView.bounds.size;
    CGSize imageSize = self.imageView.image.size;
    
    if (self.isShape)
        imageSize = image.size;
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(image.size.width, image.size.height), NO, 2.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if ((boundsSize.height >= boundsSize.width) && (self.objectCornerRadius > boundsSize.width/2))
        self.objectCornerRadius = boundsSize.width/2;
    else if ((boundsSize.height < boundsSize.width) && (self.objectCornerRadius > boundsSize.height/2))
        self.objectCornerRadius = boundsSize.height/2;
    
    CGPathRef path = CGPathCreateRoundRect(CGRectMake(0.0f, 0.0f, mediaViewBoundSize.width*imageSize.width/originalBoundSize.width, mediaViewBoundSize.height*imageSize.width/originalBoundSize.width), self.objectCornerRadius*imageSize.width/originalBoundSize.width);
    CGContextAddPath(context, path);
    CGContextClip(context);
    CGPathRelease(path);
    
    [image drawInRect:CGRectMake(0.0f, 0.0f, image.size.width, image.size.height) blendMode:kCGBlendModeNormal alpha:1.0f];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (UIImage*) renderTextWithCorner:(UIImage*)image
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(image.size.width, image.size.height), NO, 2.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if ((self.bounds.size.height >= self.bounds.size.width) && (self.objectCornerRadius > self.bounds.size.width/2))
        self.objectCornerRadius = self.bounds.size.width/2;
    else if ((self.bounds.size.height < self.bounds.size.width) && (self.objectCornerRadius > self.bounds.size.height/2))
        self.objectCornerRadius = self.bounds.size.height/2;
    
    CGPathRef path = CGPathCreateRoundRect(CGRectMake(0.0f, 0.0f, image.size.width, image.size.height), self.objectCornerRadius);
    
    CGContextAddPath(context, path);
    CGContextClip(context);
    CGPathRelease(path);
    
    [image drawInRect:CGRectMake(0.0f, 0.0f, image.size.width, image.size.height) blendMode:kCGBlendModeNormal alpha:1.0f];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (UIImage*) renderingReflectionImage:(UIImage*) image size:(CGSize) size rect:(CGRect) drawRect
{
    UIImage* reflectionImage = nil;

    if (size.height > 0.0f && size.width > 0.0f)
    {
        //create gradient mask
        UIGraphicsBeginImageContextWithOptions(size, YES, 0.0f);
        CGContextRef gradientContext = UIGraphicsGetCurrentContext();
        CGFloat colors[] = {1.0f, 1.0f, 0.0f, 1.0f};
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
        CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, colors, NULL, 2);
        CGPoint gradientStartPoint = CGPointMake(0.0f, 0.0f);
        CGPoint gradientEndPoint = CGPointMake(0.0f, size.height);
        CGContextDrawLinearGradient(gradientContext, gradient, gradientStartPoint,
                                    gradientEndPoint, kCGGradientDrawsAfterEndLocation);
        CGImageRef gradientMask = CGBitmapContextCreateImage(gradientContext);
        CGGradientRelease(gradient);
        CGColorSpaceRelease(colorSpace);
        UIGraphicsEndImageContext();
        
        //create drawing context
        UIGraphicsBeginImageContextWithOptions(size, NO, 0.0f);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextScaleCTM(context, 1.0f, -1.0f);
        CGContextTranslateCTM(context, 0.0f, -drawRect.size.height);
        
        //clip to gradient
        CGContextClipToMask(context, CGRectMake(0.0f, drawRect.size.height - size.height,
                                                size.width, size.height), gradientMask);
        CGImageRelease(gradientMask);

        [image drawInRect:drawRect blendMode:kCGBlendModeNormal alpha:1.0f];
        
        //capture resultant image
        reflectionImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    return reflectionImage;
}


-(UIImage*) renderingPhoto
{
    UIGraphicsBeginImageContextWithOptions(self.mediaView.bounds.size, NO, 0.0f);
    [self.mediaView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
}

-(UIImage*) renderingText
{
    UIGraphicsBeginImageContextWithOptions(self.textView.bounds.size, NO, 2.0f);
    self.textView.layer.shadowColor = [UIColor clearColor].CGColor;
    [self.textView.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    if (self.objectShadowStyle == 2)
        self.textView.layer.shadowColor = self.objectShadowColor.CGColor;
    
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if (self.objectCornerRadius != 0.0f)
        image = [self renderTextWithCorner:image];
    
    if (self.objectShadowStyle == 2)
    {
        UIGraphicsBeginImageContextWithOptions(self.textView.bounds.size, NO, 2.0f);
        CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), CGSizeMake(self.objectShadowOffset, self.objectShadowOffset), self.objectShadowBlur, self.objectShadowColor.CGColor);
        [image drawInRect:CGRectMake(0.0f, 0.0f, self.textView.bounds.size.width, self.textView.bounds.size.height) blendMode:kCGBlendModeNormal alpha:1.0f];
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }

    return image;
}


#pragma mark -
#pragma mark - Render image with KenBurns actions.

-(UIImage*) renderingKenBurnsImage:(BOOL) isStart
{
    UIImage* image = nil;
    
    if (self.mediaType == MEDIA_PHOTO)
    {
        CGSize originalBoundSize = self.originalBounds.size;
        CGSize boundsSize = self.bounds.size;
        CGAffineTransform videoTransform = self.transform;
        CGFloat cropOriginX = (-1.0f)*self.imageView.frame.origin.x * self.imageView.image.size.width / self.imageView.frame.size.width;
        CGFloat cropOriginY = (-1.0f)*self.imageView.frame.origin.y * self.imageView.image.size.height / self.imageView.frame.size.height;
        CGFloat cropWidth = self.bounds.size.width * self.imageView.image.size.width / self.imageView.frame.size.width;
        CGFloat cropHeight = self.bounds.size.height * self.imageView.image.size.height / self.imageView.frame.size.height;
        CGRect cropRect = CGRectMake(cropOriginX, cropOriginY, cropWidth, cropHeight);
        
        image = [self.imageView.image cropImageToRect:cropRect];
        
        CGSize imageSize = image.size;
        
        CGRect kbCropRect = CGRectZero;
        
        CGFloat  fKbScale = 1.0f;
        
        if (self.nKbIn == KB_IN)
        {
            if (isStart)
                fKbScale = 1.0f + (self.fKbScale - 1.0f) * self.mfStartAnimationDuration / (self.mfEndPosition - self.mfStartPosition - MIN_DURATION);
            else
                fKbScale = 1.0f + (self.fKbScale - 1.0f) * (self.mfEndPosition - self.mfStartPosition - self.mfEndAnimationDuration - MIN_DURATION) / (self.mfEndPosition - self.mfStartPosition - MIN_DURATION);
        }
        else
        {
            if (isStart)
                fKbScale = 1.0f + (self.fKbScale - 1.0f) * (self.mfEndPosition - self.mfStartPosition - self.mfStartAnimationDuration - MIN_DURATION) / (self.mfEndPosition - self.mfStartPosition - MIN_DURATION);
            else
                fKbScale = 1.0f + (self.fKbScale - 1.0f) * self.mfEndAnimationDuration / (self.mfEndPosition - self.mfStartPosition - MIN_DURATION);
        }
        
        kbCropRect = CGRectMake((imageSize.width - imageSize.width/fKbScale)*self.kbFocusPoint.x, (imageSize.height - imageSize.height/fKbScale)*self.kbFocusPoint.y, imageSize.width/fKbScale, imageSize.height/fKbScale);

        image = [image cropImageToRect:kbCropRect];
        image = [image rescaleImageToSize:imageSize];
       
        if (self.isShape)
        {
            if (self.bounds.size.width >= self.bounds.size.height)
                imageSize = CGSizeMake(image.size.width, image.size.width*(self.bounds.size.height/self.bounds.size.width));
            else
                imageSize = CGSizeMake(image.size.height*(self.bounds.size.width/self.bounds.size.height), image.size.height);
            
            image = [image rescaleImageToSize:imageSize];
        }

        
        if (self.objectCornerRadius != 0.0f)
            image = [self renderImageWithCorner:image];
        
        CGColorRef colorRef = nil;
        CGPoint pnt = CGPointZero;
        UIBezierPath* path;
        UIImage* reflectionImage = nil;
        UIImage* gradientImage = nil;
        
        switch (self.objectBorderStyle)
        {
            case 1: //no outline
                if (self.isImitationPhoto)
                {
                    if (self.isReflection)
                    {
                        //reflection image
                        CGSize reflectionSize = CGSizeMake(boundsSize.width, boundsSize.height * self.reflectionScale);
                        CGRect reflectionRect = CGRectMake(0.0f, 0.0f, boundsSize.width, boundsSize.height);
                        reflectionImage = [self renderingReflectionImage:image size:reflectionSize rect:reflectionRect];
                        
                        //gradient mask
                        UIGraphicsBeginImageContextWithOptions(CGSizeMake(boundsSize.width, boundsSize.height * self.reflectionScale), YES, 0.0f);
                        CGContextRef gradientContext = UIGraphicsGetCurrentContext();
                        CGFloat colors[] = {1.0f, 1.0f, 0.0f, 0.5f};
                        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
                        CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, colors, NULL, 2);
                        CGPoint gradientStartPoint = CGPointMake(0.0f, 0.0f);
                        CGPoint gradientEndPoint = CGPointMake(0.0f, boundsSize.height * self.reflectionScale);
                        CGContextDrawLinearGradient(gradientContext, gradient, gradientStartPoint,
                                                    gradientEndPoint, kCGGradientDrawsAfterEndLocation);
                        CGImageRef gradientMask = CGBitmapContextCreateImage(gradientContext);
                        CGGradientRelease(gradient);
                        CGColorSpaceRelease(colorSpace);
                        UIGraphicsEndImageContext();
                        
                        //gradient image
                        UIGraphicsBeginImageContextWithOptions(CGSizeMake(boundsSize.width, boundsSize.height * self.reflectionScale), NO, 0.0f);
                        CGContextRef context = UIGraphicsGetCurrentContext();
                        CGContextClipToMask(context, CGRectMake(0.0f, 0.0f,
                                                                boundsSize.width, boundsSize.height * self.reflectionScale), gradientMask);
                        CGImageRelease(gradientMask);
                        CGContextSetFillColorWithColor(context, [[UIColor blackColor] colorWithAlphaComponent:self.imageView.alpha].CGColor);
                        CGContextFillRect(context, CGRectMake(0.0f, 0.0f,
                                                              boundsSize.width, boundsSize.height * self.reflectionScale));
                        gradientImage = UIGraphicsGetImageFromCurrentImageContext();
                        UIGraphicsEndImageContext();
                    }
                    
                    UIGraphicsBeginImageContextWithOptions(self.superViewSize, NO, 2.0f);
                    CGContextRef context = UIGraphicsGetCurrentContext();
                    
                    CGContextConcatCTM(UIGraphicsGetCurrentContext(), videoTransform);
                    pnt = CGPointApplyAffineTransform(CGPointMake(self.center.x, self.center.y), CGAffineTransformInvert(videoTransform));
                    
                    //draw black background
                    CGContextSetFillColorWithColor(context, [self.objectChromaColor colorWithAlphaComponent:self.imageView.alpha].CGColor);
                    if (self.isReflection)
                        CGContextFillRect(context, CGRectMake(pnt.x - boundsSize.width*0.5f - 2.0f, pnt.y - boundsSize.height*0.5f - 2.0f, boundsSize.width + 4.0f, boundsSize.height * (1.0f + self.reflectionScale) + 4.0f + self.reflectionGap));
                    else
                        CGContextFillRect(context, CGRectMake(pnt.x - boundsSize.width*0.5f - 2.0f, pnt.y - boundsSize.height*0.5f - 2.0f, boundsSize.width + 4.0f, boundsSize.height + 4.0f));
                    
                    CGContextSaveGState(context);
                    
                    //shadow
                    if (self.objectShadowStyle == 2)
                        CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), CGSizeMake(self.objectShadowOffset, self.objectShadowOffset), self.objectShadowBlur, self.objectShadowColor.CGColor);
                    
                    //draw image
                    [image drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f, pnt.y - boundsSize.height*0.5f, boundsSize.width, boundsSize.height) blendMode:kCGBlendModeNormal alpha:self.imageView.alpha];
                    
                    if (self.isReflection)
                        [reflectionImage drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f, pnt.y + boundsSize.height*0.5f + self.reflectionGap, boundsSize.width, boundsSize.height * self.reflectionScale) blendMode:kCGBlendModeNormal alpha:1.0f];
                    
                    //erase inner of path
                    path = [self getErasePath:pnt];
                    CGContextAddPath(context, path.CGPath);
                    CGContextSetBlendMode(context, kCGBlendModeClear);
                    CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
                    CGContextFillPath(context);
                    CGContextRestoreGState(context);
                    
                    if (self.isReflection)
                    {
                        path = [self getErasePath:CGPointMake(pnt.x, pnt.y + boundsSize.height + self.reflectionGap)];
                        CGContextAddPath(context, path.CGPath);
                        CGContextSetBlendMode(context, kCGBlendModeClear);
                        CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
                        CGContextFillPath(context);
                        
                        //black gradient
                        [gradientImage drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f, pnt.y + boundsSize.height*0.5f + self.reflectionGap, boundsSize.width, boundsSize.height * self.reflectionScale) blendMode:kCGBlendModeNormal alpha:1.0f];
                    }
                    
                    CGContextConcatCTM(UIGraphicsGetCurrentContext(), CGAffineTransformInvert(videoTransform));
                    image = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                }
                else
                {
                    CGSize reflectionSize = CGSizeMake(boundsSize.width, boundsSize.height * self.reflectionScale);
                    CGRect reflectionRect = CGRectMake(0.0f, 0.0f, boundsSize.width, boundsSize.height);
                    
                    if (self.isReflection)
                        reflectionImage = [self renderingReflectionImage:image size:reflectionSize rect:reflectionRect];
                    
                    UIGraphicsBeginImageContextWithOptions(self.superViewSize, NO, 2.0f);
                    CGContextConcatCTM(UIGraphicsGetCurrentContext(), videoTransform);
                    pnt = CGPointApplyAffineTransform(CGPointMake(self.center.x, self.center.y), CGAffineTransformInvert(videoTransform));
                    
                    if (self.objectShadowStyle == 2)
                        CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), CGSizeMake(self.objectShadowOffset, self.objectShadowOffset), self.objectShadowBlur, self.objectShadowColor.CGColor);
                    
                    [image drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f, pnt.y - boundsSize.height*0.5f, boundsSize.width, boundsSize.height) blendMode:kCGBlendModeNormal alpha:self.imageView.alpha];
                    
                    if (self.isReflection)
                        [reflectionImage drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f, pnt.y + boundsSize.height*0.5f + self.reflectionGap, reflectionSize.width, reflectionSize.height) blendMode:kCGBlendModeNormal alpha:self.reflectionAlpha];
                    
                    CGContextConcatCTM(UIGraphicsGetCurrentContext(), CGAffineTransformInvert(videoTransform));
                    image = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                }
                break;
            case 2: //line
                if (self.isImitationPhoto)
                {
                    UIGraphicsBeginImageContextWithOptions(CGSizeMake(image.size.width + self.objectBorderWidth*imageSize.width/originalBoundSize.width*2, image.size.height + self.objectBorderWidth*imageSize.width/originalBoundSize.width*2), NO, 2.0f);
                    [image drawInRect:CGRectMake(self.objectBorderWidth*imageSize.width/originalBoundSize.width, self.objectBorderWidth*imageSize.width/originalBoundSize.width, image.size.width, image.size.height) blendMode:kCGBlendModeNormal alpha:1.0f];
                    
                    CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(),  [self.objectBorderColor colorWithAlphaComponent:self.imageView.alpha].CGColor);
                    
                    path = [self getPatternBorderPath:image.size];
                    path.lineWidth = self.objectBorderWidth*imageSize.width/originalBoundSize.width;
                    [path stroke];
                    
                    image = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                    
                    if (self.isReflection)
                    {
                        CGSize reflectionSize = CGSizeMake(boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale);
                        CGRect reflectionRect = CGRectMake(0.0f, 0.0f, boundsSize.width + self.objectBorderWidth*2, boundsSize.height + self.objectBorderWidth*2);
                        reflectionImage = [self renderingReflectionImage:image size:reflectionSize rect:reflectionRect];
                        
                        //gradient mask
                        UIGraphicsBeginImageContextWithOptions(CGSizeMake(boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale), YES, 0.0f);
                        CGContextRef gradientContext = UIGraphicsGetCurrentContext();
                        CGFloat colors[] = {1.0f, 1.0f, 0.0f, 1.0f};
                        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
                        CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, colors, NULL, 2);
                        CGPoint gradientStartPoint = CGPointMake(0.0f, 0.0f);
                        CGPoint gradientEndPoint = CGPointMake(0.0f, (boundsSize.height*self.reflectionScale) + self.objectBorderWidth*2);
                        CGContextDrawLinearGradient(gradientContext, gradient, gradientStartPoint,
                                                    gradientEndPoint, kCGGradientDrawsAfterEndLocation);
                        CGImageRef gradientMask = CGBitmapContextCreateImage(gradientContext);
                        CGGradientRelease(gradient);
                        CGColorSpaceRelease(colorSpace);
                        UIGraphicsEndImageContext();
                        
                        //gradient image
                        UIGraphicsBeginImageContextWithOptions(CGSizeMake(boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale), NO, 0.0f);
                        CGContextRef context = UIGraphicsGetCurrentContext();
                        CGContextClipToMask(context, CGRectMake(0.0f, 0.0f,
                                                                boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale), gradientMask);
                        CGImageRelease(gradientMask);
                        CGContextSetFillColorWithColor(context, [[UIColor blackColor] colorWithAlphaComponent:self.imageView.alpha].CGColor);
                        CGContextFillRect(context, CGRectMake(0.0f, 0.0f,
                                                              boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale));
                        gradientImage = UIGraphicsGetImageFromCurrentImageContext();
                        UIGraphicsEndImageContext();
                    }
                    
                    UIGraphicsBeginImageContextWithOptions(self.superViewSize, NO, 2.0f);
                    CGContextRef context = UIGraphicsGetCurrentContext();
                    
                    CGContextConcatCTM(UIGraphicsGetCurrentContext(), videoTransform);
                    pnt = CGPointApplyAffineTransform(CGPointMake(self.center.x, self.center.y), CGAffineTransformInvert(videoTransform));
                    
                    //draw black background
                    CGContextSetFillColorWithColor(context, [self.objectChromaColor colorWithAlphaComponent:self.imageView.alpha].CGColor);
                    
                    if (self.isReflection)
                    {
                        CGContextFillRect(context, CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y - boundsSize.height*0.5f - self.objectBorderWidth, boundsSize.width + self.objectBorderWidth*2, boundsSize.height * (1.0f + self.reflectionScale) + self.objectBorderWidth*2 + self.reflectionGap));
                    }
                    else
                    {
                        CGContextFillRect(context, CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y - boundsSize.height*0.5f - self.objectBorderWidth, boundsSize.width + self.objectBorderWidth*2, boundsSize.height + self.objectBorderWidth*2));
                    }
                    
                    CGContextSaveGState(context);
                    
                    //shadow
                    if (self.objectShadowStyle == 2)
                        CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), CGSizeMake(self.objectShadowOffset, self.objectShadowOffset), self.objectShadowBlur, self.objectShadowColor.CGColor);
                    
                    //draw image
                    [image drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y - boundsSize.height*0.5f - self.objectBorderWidth, boundsSize.width + self.objectBorderWidth*2, boundsSize.height + self.objectBorderWidth*2) blendMode:kCGBlendModeNormal alpha:1.0f];
                    
                    if (self.isReflection)
                        [reflectionImage drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y + boundsSize.height*0.5f - self.objectBorderWidth + self.reflectionGap, boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale) blendMode:kCGBlendModeNormal alpha:1.0f];
                    
                    //erase inner of path
                    path = [self getErasePath:pnt];
                    CGContextAddPath(context, path.CGPath);
                    CGContextSetBlendMode(context, kCGBlendModeClear);
                    CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
                    CGContextFillPath(context);
                    CGContextRestoreGState(context);
                    
                    if (self.isReflection)
                    {
                        path = [self getErasePath:CGPointMake(pnt.x, pnt.y + boundsSize.height + self.reflectionGap)];
                        CGContextAddPath(context, path.CGPath);
                        CGContextSetBlendMode(context, kCGBlendModeClear);
                        CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
                        CGContextFillPath(context);
                        
                        //black gradient
                        [gradientImage drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y + boundsSize.height*0.5f + self.reflectionGap, boundsSize.width + self.objectBorderWidth*2, boundsSize.height*self.reflectionScale + self.objectBorderWidth*2) blendMode:kCGBlendModeNormal alpha:1.0f];
                    }
                    
                    CGContextConcatCTM(UIGraphicsGetCurrentContext(), CGAffineTransformInvert(videoTransform));
                    image = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                }
                else
                {
                    UIGraphicsBeginImageContextWithOptions(CGSizeMake(image.size.width+self.objectBorderWidth*imageSize.width/originalBoundSize.width*2, image.size.height+self.objectBorderWidth*imageSize.width/originalBoundSize.width*2), NO, 2.0f);
                    [image drawInRect:CGRectMake(self.objectBorderWidth*imageSize.width/originalBoundSize.width, self.objectBorderWidth*imageSize.width/originalBoundSize.width, image.size.width, image.size.height) blendMode:kCGBlendModeNormal alpha:self.imageView.alpha];
                    
                    CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(),  [self.objectBorderColor colorWithAlphaComponent:self.imageView.alpha].CGColor);
                    
                    path = [self getPatternBorderPath:image.size];
                    path.lineWidth = self.objectBorderWidth*imageSize.width/originalBoundSize.width;
                    [path stroke];
                    
                    image = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                    
                    CGSize reflectionSize = CGSizeMake(boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2) * self.reflectionScale);
                    CGRect reflectionRect = CGRectMake(0.0f, 0.0f, boundsSize.width + self.objectBorderWidth*2, boundsSize.height+self.objectBorderWidth*2);
                    
                    if (self.isReflection)
                        reflectionImage = [self renderingReflectionImage:image size:reflectionSize rect:reflectionRect];
                    
                    UIGraphicsBeginImageContextWithOptions(self.superViewSize, NO, 2.0f);
                    CGContextConcatCTM(UIGraphicsGetCurrentContext(), videoTransform);
                    pnt = CGPointApplyAffineTransform(CGPointMake(self.center.x, self.center.y), CGAffineTransformInvert(videoTransform));
                    
                    if (self.objectShadowStyle == 2)
                        CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), CGSizeMake(self.objectShadowOffset, self.objectShadowOffset), self.objectShadowBlur, self.objectShadowColor.CGColor);
                    
                    [image drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y - boundsSize.height*0.5f - self.objectBorderWidth, boundsSize.width + self.objectBorderWidth*2, boundsSize.height+self.objectBorderWidth*2) blendMode:kCGBlendModeNormal alpha:1.0f];
                    
                    if (self.isReflection)
                        [reflectionImage drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y + boundsSize.height*0.5f + self.reflectionGap, reflectionSize.width, reflectionSize.height) blendMode:kCGBlendModeNormal alpha:self.reflectionAlpha];
                    
                    CGContextConcatCTM(UIGraphicsGetCurrentContext(), CGAffineTransformInvert(videoTransform));
                    image = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                }
                break;
            case 3: //shot dot line
                if (self.isImitationPhoto)
                {
                    UIGraphicsBeginImageContextWithOptions(CGSizeMake(image.size.width + self.objectBorderWidth*imageSize.width/originalBoundSize.width*2, image.size.height + self.objectBorderWidth*imageSize.width/originalBoundSize.width*2), NO, 2.0f);
                    [image drawInRect:CGRectMake(self.objectBorderWidth*imageSize.width/originalBoundSize.width, self.objectBorderWidth*imageSize.width/originalBoundSize.width, image.size.width, image.size.height) blendMode:kCGBlendModeNormal alpha:1.0f];
                    
                    CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(),  [self.objectBorderColor colorWithAlphaComponent:self.imageView.alpha].CGColor);
                    
                    CGFloat pattern[] = {self.objectBorderWidth, self.objectBorderWidth};
                    CGContextSetLineDash(UIGraphicsGetCurrentContext(), 0.0f, pattern, 2);
                    
                    path = [self getPatternBorderPath:image.size];
                    path.lineWidth = self.objectBorderWidth;
                    path.lineCapStyle = kCGLineCapButt;
                    path.lineJoinStyle = kCGLineJoinMiter;
                    [path stroke];
                    
                    image = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                    
                    if (self.isReflection)
                    {
                        CGSize reflectionSize = CGSizeMake(boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale);
                        CGRect reflectionRect = CGRectMake(0.0f, 0.0f, boundsSize.width + self.objectBorderWidth*2, boundsSize.height + self.objectBorderWidth*2);
                        reflectionImage = [self renderingReflectionImage:image size:reflectionSize rect:reflectionRect];
                        
                        //gradient mask
                        UIGraphicsBeginImageContextWithOptions(CGSizeMake(boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale), YES, 0.0f);
                        CGContextRef gradientContext = UIGraphicsGetCurrentContext();
                        CGFloat colors[] = {1.0f, 1.0f, 0.0f, 1.0f};
                        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
                        CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, colors, NULL, 2);
                        CGPoint gradientStartPoint = CGPointMake(0.0f, 0.0f);
                        CGPoint gradientEndPoint = CGPointMake(0.0f, (boundsSize.height*self.reflectionScale) + self.objectBorderWidth*2);
                        CGContextDrawLinearGradient(gradientContext, gradient, gradientStartPoint,
                                                    gradientEndPoint, kCGGradientDrawsAfterEndLocation);
                        CGImageRef gradientMask = CGBitmapContextCreateImage(gradientContext);
                        CGGradientRelease(gradient);
                        CGColorSpaceRelease(colorSpace);
                        UIGraphicsEndImageContext();
                        
                        //gradient image
                        UIGraphicsBeginImageContextWithOptions(CGSizeMake(boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale), NO, 0.0f);
                        CGContextRef context = UIGraphicsGetCurrentContext();
                        CGContextClipToMask(context, CGRectMake(0.0f, 0.0f,
                                                                boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale), gradientMask);
                        CGImageRelease(gradientMask);
                        CGContextSetFillColorWithColor(context, [[UIColor blackColor] colorWithAlphaComponent:self.imageView.alpha].CGColor);
                        CGContextFillRect(context, CGRectMake(0.0f, 0.0f,
                                                              boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale));
                        gradientImage = UIGraphicsGetImageFromCurrentImageContext();
                        UIGraphicsEndImageContext();
                    }
                    
                    UIGraphicsBeginImageContextWithOptions(self.superViewSize, NO, 2.0f);
                    CGContextRef context = UIGraphicsGetCurrentContext();
                    CGContextConcatCTM(UIGraphicsGetCurrentContext(), videoTransform);
                    pnt = CGPointApplyAffineTransform(CGPointMake(self.center.x, self.center.y), CGAffineTransformInvert(videoTransform));
                    CGContextSetFillColorWithColor(context, [self.objectChromaColor colorWithAlphaComponent:self.imageView.alpha].CGColor);
                    
                    if (self.isReflection)
                    {
                        CGContextFillRect(context, CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y - boundsSize.height*0.5f - self.objectBorderWidth, boundsSize.width + self.objectBorderWidth*2, boundsSize.height * (1.0f + self.reflectionScale) + self.objectBorderWidth*2 + self.reflectionGap));
                    }
                    else
                    {
                        CGContextFillRect(context, CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y - boundsSize.height*0.5f - self.objectBorderWidth, boundsSize.width + self.objectBorderWidth*2, boundsSize.height + self.objectBorderWidth*2));
                    }
                    
                    CGContextSaveGState(context);
                    
                    //shadow
                    if (self.objectShadowStyle == 2)
                    {
                        CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), CGSizeMake(self.objectShadowOffset, self.objectShadowOffset), self.objectShadowBlur, self.objectShadowColor.CGColor);
                    }
                    
                    //draw image
                    [image drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y - boundsSize.height*0.5f - self.objectBorderWidth, boundsSize.width + self.objectBorderWidth*2, boundsSize.height + self.objectBorderWidth*2) blendMode:kCGBlendModeNormal alpha:1.0f];
                    
                    if (self.isReflection)
                    {
                        [reflectionImage drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y + boundsSize.height*0.5f - self.objectBorderWidth + self.reflectionGap, boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale) blendMode:kCGBlendModeNormal alpha:1.0f];
                    }
                    
                    //erase inner of path
                    path = [self getErasePath:pnt];
                    CGContextAddPath(context, path.CGPath);
                    CGContextSetBlendMode(context, kCGBlendModeClear);
                    CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
                    CGContextFillPath(context);
                    CGContextRestoreGState(context);
                    
                    if (self.isReflection)
                    {
                        path = [self getErasePath:CGPointMake(pnt.x, pnt.y + boundsSize.height + self.reflectionGap)];
                        CGContextAddPath(context, path.CGPath);
                        CGContextSetBlendMode(context, kCGBlendModeClear);
                        CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
                        CGContextFillPath(context);
                        
                        //black gradient
                        [gradientImage drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y + boundsSize.height*0.5f + self.reflectionGap, boundsSize.width + self.objectBorderWidth*2, boundsSize.height*self.reflectionScale + self.objectBorderWidth*2) blendMode:kCGBlendModeNormal alpha:1.0f];
                    }
                    
                    CGContextConcatCTM(UIGraphicsGetCurrentContext(), CGAffineTransformInvert(videoTransform));
                    image = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                }
                else
                {
                    UIGraphicsBeginImageContextWithOptions(CGSizeMake(image.size.width+self.objectBorderWidth*imageSize.width/originalBoundSize.width*2, image.size.height+self.objectBorderWidth*imageSize.width/originalBoundSize.width*2), NO, 2.0f);
                    [image drawInRect:CGRectMake(self.objectBorderWidth*imageSize.width/originalBoundSize.width, self.objectBorderWidth*imageSize.width/originalBoundSize.width, image.size.width, image.size.height) blendMode:kCGBlendModeNormal alpha:self.imageView.alpha];
                    
                    CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(),  [self.objectBorderColor colorWithAlphaComponent:self.imageView.alpha].CGColor);
                    
                    CGFloat pattern[] = {self.objectBorderWidth, self.objectBorderWidth};
                    CGContextSetLineDash(UIGraphicsGetCurrentContext(), 0.0f, pattern, 2);
                    
                    path = [self getPatternBorderPath:image.size];
                    path.lineWidth = self.objectBorderWidth*imageSize.width/originalBoundSize.width;
                    path.lineCapStyle = kCGLineCapButt;
                    path.lineJoinStyle = kCGLineJoinMiter;
                    [path stroke];
                    
                    image = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                    
                    CGSize reflectionSize = CGSizeMake(boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2) * self.reflectionScale);
                    CGRect reflectionRect = CGRectMake(0.0f, 0.0f, boundsSize.width + self.objectBorderWidth*2, boundsSize.height+self.objectBorderWidth*2);
                    
                    if (self.isReflection)
                    {
                        reflectionImage = [self renderingReflectionImage:image size:reflectionSize rect:reflectionRect];
                    }
                    
                    UIGraphicsBeginImageContextWithOptions(self.superViewSize, NO, 2.0f);
                    CGContextConcatCTM(UIGraphicsGetCurrentContext(), videoTransform);
                    pnt = CGPointApplyAffineTransform(CGPointMake(self.center.x, self.center.y), CGAffineTransformInvert(videoTransform));
                    
                    if (self.objectShadowStyle == 2)
                    {
                        CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), CGSizeMake(self.objectShadowOffset, self.objectShadowOffset), self.objectShadowBlur, self.objectShadowColor.CGColor);
                    }
                    
                    [image drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y - boundsSize.height*0.5f - self.objectBorderWidth, boundsSize.width + self.objectBorderWidth*2, boundsSize.height+self.objectBorderWidth*2) blendMode:kCGBlendModeNormal alpha:1.0f];
                    
                    if (self.isReflection)
                    {
                        [reflectionImage drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y + boundsSize.height*0.5f + self.reflectionGap, reflectionSize.width, reflectionSize.height) blendMode:kCGBlendModeNormal alpha:self.reflectionAlpha];
                    }
                    
                    CGContextConcatCTM(UIGraphicsGetCurrentContext(), CGAffineTransformInvert(videoTransform));
                    image = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                }
                break;
            case 4: //middle dot line
                if (self.isImitationPhoto)
                {
                    UIGraphicsBeginImageContextWithOptions(CGSizeMake(image.size.width + self.objectBorderWidth*imageSize.width/originalBoundSize.width*2, image.size.height + self.objectBorderWidth*imageSize.width/originalBoundSize.width*2), NO, 2.0f);
                    [image drawInRect:CGRectMake(self.objectBorderWidth*imageSize.width/originalBoundSize.width, self.objectBorderWidth*imageSize.width/originalBoundSize.width, image.size.width, image.size.height) blendMode:kCGBlendModeNormal alpha:1.0f];
                    
                    CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(),  [self.objectBorderColor colorWithAlphaComponent:self.imageView.alpha].CGColor);
                    
                    CGFloat middleDotLinePattern[] = {1.5f*self.objectBorderWidth, 1.5f*self.objectBorderWidth};
                    CGContextSetLineDash(UIGraphicsGetCurrentContext(), 0.0f, middleDotLinePattern, 2);
                    
                    path = [self getPatternBorderPath:image.size];
                    path.lineWidth = self.objectBorderWidth;
                    path.lineCapStyle = kCGLineCapButt;
                    path.lineJoinStyle = kCGLineJoinMiter;
                    [path stroke];
                    
                    image = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                    
                    if (self.isReflection)
                    {
                        //reflection image
                        CGSize reflectionSize = CGSizeMake(boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale);
                        CGRect reflectionRect = CGRectMake(0.0f, 0.0f, boundsSize.width + self.objectBorderWidth*2, boundsSize.height + self.objectBorderWidth*2);
                        reflectionImage = [self renderingReflectionImage:image size:reflectionSize rect:reflectionRect];
                        
                        //gradient mask
                        UIGraphicsBeginImageContextWithOptions(CGSizeMake(boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale), YES, 0.0f);
                        CGContextRef gradientContext = UIGraphicsGetCurrentContext();
                        CGFloat colors[] = {1.0f, 1.0f, 0.0f, 1.0f};
                        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
                        CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, colors, NULL, 2);
                        CGPoint gradientStartPoint = CGPointMake(0.0f, 0.0f);
                        CGPoint gradientEndPoint = CGPointMake(0.0f, (boundsSize.height*self.reflectionScale) + self.objectBorderWidth*2);
                        CGContextDrawLinearGradient(gradientContext, gradient, gradientStartPoint,
                                                    gradientEndPoint, kCGGradientDrawsAfterEndLocation);
                        CGImageRef gradientMask = CGBitmapContextCreateImage(gradientContext);
                        CGGradientRelease(gradient);
                        CGColorSpaceRelease(colorSpace);
                        UIGraphicsEndImageContext();
                        
                        //gradient image
                        UIGraphicsBeginImageContextWithOptions(CGSizeMake(boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale), NO, 0.0f);
                        CGContextRef context = UIGraphicsGetCurrentContext();
                        CGContextClipToMask(context, CGRectMake(0.0f, 0.0f,
                                                                boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale), gradientMask);
                        CGImageRelease(gradientMask);
                        CGContextSetFillColorWithColor(context, [[UIColor blackColor] colorWithAlphaComponent:self.imageView.alpha].CGColor);
                        CGContextFillRect(context, CGRectMake(0.0f, 0.0f,
                                                              boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale));
                        gradientImage = UIGraphicsGetImageFromCurrentImageContext();
                        UIGraphicsEndImageContext();
                    }
                    
                    UIGraphicsBeginImageContextWithOptions(self.superViewSize, NO, 2.0f);
                    CGContextRef context = UIGraphicsGetCurrentContext();
                    
                    CGContextConcatCTM(UIGraphicsGetCurrentContext(), videoTransform);
                    pnt = CGPointApplyAffineTransform(CGPointMake(self.center.x, self.center.y), CGAffineTransformInvert(videoTransform));
                    
                    //draw black background
                    CGContextSetFillColorWithColor(context, [self.objectChromaColor colorWithAlphaComponent:self.imageView.alpha].CGColor);
                    
                    if (self.isReflection)
                    {
                        CGContextFillRect(context, CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y - boundsSize.height*0.5f - self.objectBorderWidth, boundsSize.width + self.objectBorderWidth*2, boundsSize.height * (1.0f + self.reflectionScale) + self.objectBorderWidth*2 + self.reflectionGap));
                    }
                    else
                    {
                        CGContextFillRect(context, CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y - boundsSize.height*0.5f - self.objectBorderWidth, boundsSize.width + self.objectBorderWidth*2, boundsSize.height + self.objectBorderWidth*2));
                    }
                    
                    CGContextSaveGState(context);
                    
                    //shadow
                    if (self.objectShadowStyle == 2)
                    {
                        CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), CGSizeMake(self.objectShadowOffset, self.objectShadowOffset), self.objectShadowBlur, self.objectShadowColor.CGColor);
                    }
                    
                    //draw image
                    [image drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y - boundsSize.height*0.5f - self.objectBorderWidth, boundsSize.width + self.objectBorderWidth*2, boundsSize.height + self.objectBorderWidth*2) blendMode:kCGBlendModeNormal alpha:1.0f];
                    
                    if (self.isReflection)
                    {
                        [reflectionImage drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y + boundsSize.height*0.5f - self.objectBorderWidth + self.reflectionGap, boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale) blendMode:kCGBlendModeNormal alpha:1.0f];
                    }
                    
                    //erase inner of path
                    path = [self getErasePath:pnt];
                    CGContextAddPath(context, path.CGPath);
                    CGContextSetBlendMode(context, kCGBlendModeClear);
                    CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
                    CGContextFillPath(context);
                    CGContextRestoreGState(context);
                    
                    if (self.isReflection)
                    {
                        path = [self getErasePath:CGPointMake(pnt.x, pnt.y + boundsSize.height + self.reflectionGap)];
                        CGContextAddPath(context, path.CGPath);
                        CGContextSetBlendMode(context, kCGBlendModeClear);
                        CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
                        CGContextFillPath(context);
                        
                        //black gradient
                        [gradientImage drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y + boundsSize.height*0.5f + self.reflectionGap, boundsSize.width + self.objectBorderWidth*2, boundsSize.height*self.reflectionScale + self.objectBorderWidth*2) blendMode:kCGBlendModeNormal alpha:1.0f];
                    }
                    
                    CGContextConcatCTM(UIGraphicsGetCurrentContext(), CGAffineTransformInvert(videoTransform));
                    
                    image = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                }
                else
                {
                    UIGraphicsBeginImageContextWithOptions(CGSizeMake(image.size.width+self.objectBorderWidth*imageSize.width/originalBoundSize.width*2, image.size.height+self.objectBorderWidth*imageSize.width/originalBoundSize.width*2), NO, 2.0f);
                    [image drawInRect:CGRectMake(self.objectBorderWidth*imageSize.width/originalBoundSize.width, self.objectBorderWidth*imageSize.width/originalBoundSize.width, image.size.width, image.size.height) blendMode:kCGBlendModeNormal alpha:self.imageView.alpha];
                    
                    CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(),  [self.objectBorderColor colorWithAlphaComponent:self.imageView.alpha].CGColor);
                    
                    CGFloat middleDotLinePattern[] = {1.5f*self.objectBorderWidth, 1.5f*self.objectBorderWidth};
                    CGContextSetLineDash(UIGraphicsGetCurrentContext(), 0.0f, middleDotLinePattern, 2);
                    
                    path = [self getPatternBorderPath:image.size];
                    path.lineWidth = self.objectBorderWidth*imageSize.width/originalBoundSize.width;
                    path.lineCapStyle = kCGLineCapButt;
                    path.lineJoinStyle = kCGLineJoinMiter;
                    [path stroke];
                    
                    image = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                    
                    CGSize reflectionSize = CGSizeMake(boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2) * self.reflectionScale);
                    CGRect reflectionRect = CGRectMake(0.0f, 0.0f, boundsSize.width + self.objectBorderWidth*2, boundsSize.height+self.objectBorderWidth*2);
                    
                    if (self.isReflection)
                    {
                        reflectionImage = [self renderingReflectionImage:image size:reflectionSize rect:reflectionRect];
                    }
                    
                    UIGraphicsBeginImageContextWithOptions(self.superViewSize, NO, 2.0f);
                    CGContextConcatCTM(UIGraphicsGetCurrentContext(), videoTransform);
                    pnt = CGPointApplyAffineTransform(CGPointMake(self.center.x, self.center.y), CGAffineTransformInvert(videoTransform));
                    
                    if (self.objectShadowStyle == 2)
                    {
                        CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), CGSizeMake(self.objectShadowOffset, self.objectShadowOffset), self.objectShadowBlur, self.objectShadowColor.CGColor);
                    }
                    
                    [image drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y - boundsSize.height*0.5f - self.objectBorderWidth, boundsSize.width + self.objectBorderWidth*2, boundsSize.height+self.objectBorderWidth*2) blendMode:kCGBlendModeNormal alpha:1.0f];
                    
                    if (self.isReflection)
                    {
                        [reflectionImage drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y + boundsSize.height*0.5f + self.reflectionGap, reflectionSize.width, reflectionSize.height) blendMode:kCGBlendModeNormal alpha:self.reflectionAlpha];
                    }
                    
                    CGContextConcatCTM(UIGraphicsGetCurrentContext(), CGAffineTransformInvert(videoTransform));
                    image = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                }
                break;
            case 5: //long dot line
                if (self.isImitationPhoto)
                {
                    UIGraphicsBeginImageContextWithOptions(CGSizeMake(image.size.width + self.objectBorderWidth*imageSize.width/originalBoundSize.width*2, image.size.height + self.objectBorderWidth*imageSize.width/originalBoundSize.width*2), NO, 2.0f);
                    [image drawInRect:CGRectMake(self.objectBorderWidth*imageSize.width/originalBoundSize.width, self.objectBorderWidth*imageSize.width/originalBoundSize.width, image.size.width, image.size.height) blendMode:kCGBlendModeNormal alpha:1.0f];
                    
                    CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(),  [self.objectBorderColor colorWithAlphaComponent:self.imageView.alpha].CGColor);
                    
                    CGFloat longDotLinePattern[] = {3.0f*self.objectBorderWidth, 3.0f*self.objectBorderWidth};
                    CGContextSetLineDash(UIGraphicsGetCurrentContext(), 0.0f, longDotLinePattern, 2);
                    
                    path = [self getPatternBorderPath:image.size];
                    path.lineWidth = self.objectBorderWidth;
                    path.lineCapStyle = kCGLineCapButt;
                    path.lineJoinStyle = kCGLineJoinMiter;
                    [path stroke];
                    
                    image = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                    
                    if (self.isReflection)
                    {
                        //reflection image
                        CGSize reflectionSize = CGSizeMake(boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale);
                        CGRect reflectionRect = CGRectMake(0.0f, 0.0f, boundsSize.width + self.objectBorderWidth*2, boundsSize.height + self.objectBorderWidth*2);
                        reflectionImage = [self renderingReflectionImage:image size:reflectionSize rect:reflectionRect];
                        
                        //gradient mask
                        UIGraphicsBeginImageContextWithOptions(CGSizeMake(boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale), YES, 0.0f);
                        CGContextRef gradientContext = UIGraphicsGetCurrentContext();
                        CGFloat colors[] = {1.0f, 1.0f, 0.0f, 1.0f};
                        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
                        CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, colors, NULL, 2);
                        CGPoint gradientStartPoint = CGPointMake(0.0f, 0.0f);
                        CGPoint gradientEndPoint = CGPointMake(0.0f, (boundsSize.height*self.reflectionScale) + self.objectBorderWidth*2);
                        CGContextDrawLinearGradient(gradientContext, gradient, gradientStartPoint,
                                                    gradientEndPoint, kCGGradientDrawsAfterEndLocation);
                        CGImageRef gradientMask = CGBitmapContextCreateImage(gradientContext);
                        CGGradientRelease(gradient);
                        CGColorSpaceRelease(colorSpace);
                        UIGraphicsEndImageContext();
                        
                        //gradient image
                        UIGraphicsBeginImageContextWithOptions(CGSizeMake(boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale), NO, 0.0f);
                        CGContextRef context = UIGraphicsGetCurrentContext();
                        CGContextClipToMask(context, CGRectMake(0.0f, 0.0f,
                                                                boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale), gradientMask);
                        CGImageRelease(gradientMask);
                        CGContextSetFillColorWithColor(context, [[UIColor blackColor] colorWithAlphaComponent:self.imageView.alpha].CGColor);
                        CGContextFillRect(context, CGRectMake(0.0f, 0.0f,
                                                              boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale));
                        gradientImage = UIGraphicsGetImageFromCurrentImageContext();
                        UIGraphicsEndImageContext();
                    }
                    
                    UIGraphicsBeginImageContextWithOptions(self.superViewSize, NO, 2.0f);
                    CGContextRef context = UIGraphicsGetCurrentContext();
                    
                    CGContextConcatCTM(UIGraphicsGetCurrentContext(), videoTransform);
                    pnt = CGPointApplyAffineTransform(CGPointMake(self.center.x, self.center.y), CGAffineTransformInvert(videoTransform));
                    
                    //draw black background
                    CGContextSetFillColorWithColor(context, [self.objectChromaColor colorWithAlphaComponent:self.imageView.alpha].CGColor);
                    
                    if (self.isReflection)
                    {
                        CGContextFillRect(context, CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y - boundsSize.height*0.5f - self.objectBorderWidth, boundsSize.width + self.objectBorderWidth*2, boundsSize.height * (1.0f + self.reflectionScale) + self.objectBorderWidth*2 + self.reflectionGap));
                    }
                    else
                    {
                        CGContextFillRect(context, CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y - boundsSize.height*0.5f - self.objectBorderWidth, boundsSize.width + self.objectBorderWidth*2, boundsSize.height + self.objectBorderWidth*2));
                    }
                    
                    CGContextSaveGState(context);
                    
                    //shadow
                    if (self.objectShadowStyle == 2)
                    {
                        CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), CGSizeMake(self.objectShadowOffset, self.objectShadowOffset), self.objectShadowBlur, self.objectShadowColor.CGColor);
                    }
                    
                    //draw image
                    [image drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y - boundsSize.height*0.5f - self.objectBorderWidth, boundsSize.width + self.objectBorderWidth*2, boundsSize.height + self.objectBorderWidth*2) blendMode:kCGBlendModeNormal alpha:1.0f];
                    
                    if (self.isReflection)
                    {
                        [reflectionImage drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y + boundsSize.height*0.5f - self.objectBorderWidth + self.reflectionGap, boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale) blendMode:kCGBlendModeNormal alpha:1.0f];
                    }
                    
                    //erase inner of path
                    path = [self getErasePath:pnt];
                    CGContextAddPath(context, path.CGPath);
                    CGContextSetBlendMode(context, kCGBlendModeClear);
                    CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
                    CGContextFillPath(context);
                    CGContextRestoreGState(context);
                    
                    if (self.isReflection)
                    {
                        path = [self getErasePath:CGPointMake(pnt.x, pnt.y + boundsSize.height + self.reflectionGap)];
                        CGContextAddPath(context, path.CGPath);
                        CGContextSetBlendMode(context, kCGBlendModeClear);
                        CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
                        CGContextFillPath(context);
                        
                        //black gradient
                        [gradientImage drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y + boundsSize.height*0.5f + self.reflectionGap, boundsSize.width + self.objectBorderWidth*2, boundsSize.height*self.reflectionScale + self.objectBorderWidth*2) blendMode:kCGBlendModeNormal alpha:1.0f];
                    }
                    
                    CGContextConcatCTM(UIGraphicsGetCurrentContext(), CGAffineTransformInvert(videoTransform));
                    
                    image = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                }
                else
                {
                    UIGraphicsBeginImageContextWithOptions(CGSizeMake(image.size.width+self.objectBorderWidth*imageSize.width/originalBoundSize.width*2, image.size.height+self.objectBorderWidth*imageSize.width/originalBoundSize.width*2), NO, 2.0f);
                    [image drawInRect:CGRectMake(self.objectBorderWidth*imageSize.width/originalBoundSize.width, self.objectBorderWidth*imageSize.width/originalBoundSize.width, image.size.width, image.size.height) blendMode:kCGBlendModeNormal alpha:self.imageView.alpha];
                    
                    CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(),  [self.objectBorderColor colorWithAlphaComponent:self.imageView.alpha].CGColor);
                    
                    CGFloat longDotLinePattern[] = {3.0f*self.objectBorderWidth, 3.0f*self.objectBorderWidth};
                    CGContextSetLineDash(UIGraphicsGetCurrentContext(), 0.0f, longDotLinePattern, 2);
                    
                    path = [self getPatternBorderPath:image.size];
                    path.lineWidth = self.objectBorderWidth*imageSize.width/originalBoundSize.width;
                    path.lineCapStyle = kCGLineCapButt;
                    path.lineJoinStyle = kCGLineJoinMiter;
                    [path stroke];
                    
                    image = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                    
                    CGSize reflectionSize = CGSizeMake(boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2) * self.reflectionScale);
                    CGRect reflectionRect = CGRectMake(0.0f, 0.0f, boundsSize.width + self.objectBorderWidth*2, boundsSize.height+self.objectBorderWidth*2);
                    
                    if (self.isReflection)
                        reflectionImage = [self renderingReflectionImage:image size:reflectionSize rect:reflectionRect];
                    
                    UIGraphicsBeginImageContextWithOptions(self.superViewSize, NO, 2.0f);
                    CGContextConcatCTM(UIGraphicsGetCurrentContext(), videoTransform);
                    pnt = CGPointApplyAffineTransform(CGPointMake(self.center.x, self.center.y), CGAffineTransformInvert(videoTransform));
                    
                    if (self.objectShadowStyle == 2)
                        CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), CGSizeMake(self.objectShadowOffset, self.objectShadowOffset), self.objectShadowBlur, self.objectShadowColor.CGColor);
                    
                    [image drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y - boundsSize.height*0.5f - self.objectBorderWidth, boundsSize.width + self.objectBorderWidth*2, boundsSize.height+self.objectBorderWidth*2) blendMode:kCGBlendModeNormal alpha:1.0f];
                    
                    if (self.isReflection)
                        [reflectionImage drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y + boundsSize.height*0.5f + self.reflectionGap, reflectionSize.width, reflectionSize.height) blendMode:kCGBlendModeNormal alpha:self.reflectionAlpha];
                    
                    CGContextConcatCTM(UIGraphicsGetCurrentContext(), CGAffineTransformInvert(videoTransform));
                    image = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                }
                break;
            case 6: //circle dot line
                if (self.isImitationPhoto)
                {
                    UIGraphicsBeginImageContextWithOptions(CGSizeMake(image.size.width + self.objectBorderWidth*imageSize.width/originalBoundSize.width*2, image.size.height + self.objectBorderWidth*imageSize.width/originalBoundSize.width*2), NO, 2.0f);
                    [image drawInRect:CGRectMake(self.objectBorderWidth*imageSize.width/originalBoundSize.width, self.objectBorderWidth*imageSize.width/originalBoundSize.width, image.size.width, image.size.height) blendMode:kCGBlendModeNormal alpha:1.0f];
                    
                    CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(),  [self.objectBorderColor colorWithAlphaComponent:self.imageView.alpha].CGColor);
                    
                    CGFloat circleDotLinePattern[] = {0.1f, 2.0f*self.objectBorderWidth};
                    CGContextSetLineDash(UIGraphicsGetCurrentContext(), 0.0f, circleDotLinePattern, 2);
                    
                    path = [self getPatternBorderPath:image.size];
                    path.lineWidth = self.objectBorderWidth;
                    path.lineCapStyle = kCGLineCapRound;
                    path.lineJoinStyle = kCGLineJoinMiter;
                    [path stroke];
                    
                    image = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                    
                    if (self.isReflection)
                    {
                        //reflection image
                        CGSize reflectionSize = CGSizeMake(boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale);
                        CGRect reflectionRect = CGRectMake(0.0f, 0.0f, boundsSize.width + self.objectBorderWidth*2, boundsSize.height + self.objectBorderWidth*2);
                        reflectionImage = [self renderingReflectionImage:image size:reflectionSize rect:reflectionRect];
                        
                        //gradient mask
                        UIGraphicsBeginImageContextWithOptions(CGSizeMake(boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale), YES, 0.0f);
                        CGContextRef gradientContext = UIGraphicsGetCurrentContext();
                        CGFloat colors[] = {1.0f, 1.0f, 0.0f, 1.0f};
                        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
                        CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, colors, NULL, 2);
                        CGPoint gradientStartPoint = CGPointMake(0.0f, 0.0f);
                        CGPoint gradientEndPoint = CGPointMake(0.0f, (boundsSize.height*self.reflectionScale) + self.objectBorderWidth*2);
                        CGContextDrawLinearGradient(gradientContext, gradient, gradientStartPoint,
                                                    gradientEndPoint, kCGGradientDrawsAfterEndLocation);
                        CGImageRef gradientMask = CGBitmapContextCreateImage(gradientContext);
                        CGGradientRelease(gradient);
                        CGColorSpaceRelease(colorSpace);
                        UIGraphicsEndImageContext();
                        
                        //gradient image
                        UIGraphicsBeginImageContextWithOptions(CGSizeMake(boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale), NO, 0.0f);
                        CGContextRef context = UIGraphicsGetCurrentContext();
                        CGContextClipToMask(context, CGRectMake(0.0f, 0.0f,
                                                                boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale), gradientMask);
                        CGImageRelease(gradientMask);
                        CGContextSetFillColorWithColor(context, [[UIColor blackColor] colorWithAlphaComponent:self.imageView.alpha].CGColor);
                        CGContextFillRect(context, CGRectMake(0.0f, 0.0f,
                                                              boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale));
                        gradientImage = UIGraphicsGetImageFromCurrentImageContext();
                        UIGraphicsEndImageContext();
                    }
                    
                    UIGraphicsBeginImageContextWithOptions(self.superViewSize, NO, 2.0f);
                    CGContextRef context = UIGraphicsGetCurrentContext();
                    
                    CGContextConcatCTM(UIGraphicsGetCurrentContext(), videoTransform);
                    pnt = CGPointApplyAffineTransform(CGPointMake(self.center.x, self.center.y), CGAffineTransformInvert(videoTransform));
                    
                    //draw black background
                    CGContextSetFillColorWithColor(context, [self.objectChromaColor colorWithAlphaComponent:self.imageView.alpha].CGColor);
                    
                    if (self.isReflection)
                    {
                        CGContextFillRect(context, CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y - boundsSize.height*0.5f - self.objectBorderWidth, boundsSize.width + self.objectBorderWidth*2, boundsSize.height * (1.0f + self.reflectionScale) + self.objectBorderWidth*2 + self.reflectionGap));
                    }
                    else
                    {
                        CGContextFillRect(context, CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y - boundsSize.height*0.5f - self.objectBorderWidth, boundsSize.width + self.objectBorderWidth*2, boundsSize.height + self.objectBorderWidth*2));
                    }
                    
                    CGContextSaveGState(context);
                    
                    //shadow
                    if (self.objectShadowStyle == 2)
                    {
                        CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), CGSizeMake(self.objectShadowOffset, self.objectShadowOffset), self.objectShadowBlur, self.objectShadowColor.CGColor);
                    }
                    
                    //draw image
                    [image drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y - boundsSize.height*0.5f - self.objectBorderWidth, boundsSize.width + self.objectBorderWidth*2, boundsSize.height + self.objectBorderWidth*2) blendMode:kCGBlendModeNormal alpha:1.0f];
                    
                    if (self.isReflection)
                    {
                        [reflectionImage drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y + boundsSize.height*0.5f - self.objectBorderWidth + self.reflectionGap, boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale) blendMode:kCGBlendModeNormal alpha:1.0f];
                    }
                    
                    //erase inner of path
                    path = [self getErasePath:pnt];
                    CGContextAddPath(context, path.CGPath);
                    CGContextSetBlendMode(context, kCGBlendModeClear);
                    CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
                    CGContextFillPath(context);
                    CGContextRestoreGState(context);
                    
                    if (self.isReflection)
                    {
                        path = [self getErasePath:CGPointMake(pnt.x, pnt.y + boundsSize.height + self.reflectionGap)];
                        CGContextAddPath(context, path.CGPath);
                        CGContextSetBlendMode(context, kCGBlendModeClear);
                        CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
                        CGContextFillPath(context);
                        
                        //black gradient
                        [gradientImage drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y + boundsSize.height*0.5f + self.reflectionGap, boundsSize.width + self.objectBorderWidth*2, boundsSize.height*self.reflectionScale + self.objectBorderWidth*2) blendMode:kCGBlendModeNormal alpha:1.0f];
                    }
                    
                    CGContextConcatCTM(UIGraphicsGetCurrentContext(), CGAffineTransformInvert(videoTransform));
                    
                    image = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                }
                else
                {
                    UIGraphicsBeginImageContextWithOptions(CGSizeMake(image.size.width+self.objectBorderWidth*imageSize.width/originalBoundSize.width*2, image.size.height+self.objectBorderWidth*imageSize.width/originalBoundSize.width*2), NO, 2.0f);
                    [image drawInRect:CGRectMake(self.objectBorderWidth*imageSize.width/originalBoundSize.width, self.objectBorderWidth*imageSize.width/originalBoundSize.width, image.size.width, image.size.height) blendMode:kCGBlendModeNormal alpha:self.imageView.alpha];
                    
                    CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(),  [self.objectBorderColor colorWithAlphaComponent:self.imageView.alpha].CGColor);
                    
                    CGFloat circleDotLinePattern[] = {0.1f, 2.0f*self.objectBorderWidth};
                    CGContextSetLineDash(UIGraphicsGetCurrentContext(), 0.0f, circleDotLinePattern, 2);
                    
                    path = [self getPatternBorderPath:image.size];
                    path.lineWidth = self.objectBorderWidth*imageSize.width/originalBoundSize.width;
                    path.lineCapStyle = kCGLineCapRound;
                    path.lineJoinStyle = kCGLineJoinMiter;
                    [path stroke];
                    
                    image = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                    
                    CGSize reflectionSize = CGSizeMake(boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2) * self.reflectionScale);
                    CGRect reflectionRect = CGRectMake(0.0f, 0.0f, boundsSize.width + self.objectBorderWidth*2, boundsSize.height+self.objectBorderWidth*2);
                    
                    if (self.isReflection)
                        reflectionImage = [self renderingReflectionImage:image size:reflectionSize rect:reflectionRect];
                    
                    UIGraphicsBeginImageContextWithOptions(self.superViewSize, NO, 2.0f);
                    CGContextConcatCTM(UIGraphicsGetCurrentContext(), videoTransform);
                    pnt = CGPointApplyAffineTransform(CGPointMake(self.center.x, self.center.y), CGAffineTransformInvert(videoTransform));
                    
                    if (self.objectShadowStyle == 2)
                        CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), CGSizeMake(self.objectShadowOffset, self.objectShadowOffset), self.objectShadowBlur, self.objectShadowColor.CGColor);
                    
                    [image drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y - boundsSize.height*0.5f - self.objectBorderWidth, boundsSize.width + self.objectBorderWidth*2, boundsSize.height+self.objectBorderWidth*2) blendMode:kCGBlendModeNormal alpha:1.0f];
                    
                    if (self.isReflection)
                        [reflectionImage drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y + boundsSize.height*0.5f + self.reflectionGap, reflectionSize.width, reflectionSize.height) blendMode:kCGBlendModeNormal alpha:self.reflectionAlpha];
                    
                    CGContextConcatCTM(UIGraphicsGetCurrentContext(), CGAffineTransformInvert(videoTransform));
                    image = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                }
                break;
            case 7: //two dots line
            {
                UIGraphicsBeginImageContextWithOptions(CGSizeMake(image.size.width+self.objectBorderWidth*imageSize.width/originalBoundSize.width*2, image.size.height+self.objectBorderWidth*imageSize.width/originalBoundSize.width*2), NO, 2.0f);
                
                [image drawInRect:CGRectMake(self.objectBorderWidth*imageSize.width/originalBoundSize.width, self.objectBorderWidth*imageSize.width/originalBoundSize.width, image.size.width, image.size.height) blendMode:kCGBlendModeNormal alpha:self.imageView.alpha];
                
                UIImage* borderImage = [UIImage imageNamed:@"dotline_pattern"];
                borderImage = [borderImage rescaleImageToSize:CGSizeMake(self.objectBorderWidth*imageSize.width/originalBoundSize.width, self.objectBorderWidth*imageSize.width/originalBoundSize.width)];
                
                borderImage = [borderImage imageWithOverlayColor:[self.objectBorderColor colorWithAlphaComponent:self.imageView.alpha]];
                
                colorRef = [UIColor colorWithPatternImage:borderImage].CGColor;
                CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(),  colorRef);
                
                path = [self getPatternBorderPath:image.size];
                path.lineWidth = self.objectBorderWidth*imageSize.width/originalBoundSize.width;
                [path stroke];
                
                image = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                
                CGSize reflectionSize = CGSizeMake(boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2) * self.reflectionScale);
                CGRect reflectionRect = CGRectMake(0.0f, 0.0f, boundsSize.width + self.objectBorderWidth*2, boundsSize.height+self.objectBorderWidth*2);
                
                if (self.isReflection)
                    reflectionImage = [self renderingReflectionImage:image size:reflectionSize rect:reflectionRect];
                
                if (self.isImitationPhoto && self.isReflection)
                {
                    //gradient mask
                    UIGraphicsBeginImageContextWithOptions(CGSizeMake(boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale), YES, 0.0f);
                    CGContextRef gradientContext = UIGraphicsGetCurrentContext();
                    CGFloat colors[] = {1.0f, 1.0f, 0.0f, 1.0f};
                    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
                    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, colors, NULL, 2);
                    CGPoint gradientStartPoint = CGPointMake(0.0f, 0.0f);
                    CGPoint gradientEndPoint = CGPointMake(0.0f, (boundsSize.height*self.reflectionScale) + self.objectBorderWidth*2);
                    CGContextDrawLinearGradient(gradientContext, gradient, gradientStartPoint,
                                                gradientEndPoint, kCGGradientDrawsAfterEndLocation);
                    CGImageRef gradientMask = CGBitmapContextCreateImage(gradientContext);
                    CGGradientRelease(gradient);
                    CGColorSpaceRelease(colorSpace);
                    UIGraphicsEndImageContext();
                    
                    //gradient image
                    UIGraphicsBeginImageContextWithOptions(CGSizeMake(boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale), NO, 0.0f);
                    CGContextRef context = UIGraphicsGetCurrentContext();
                    CGContextClipToMask(context, CGRectMake(0.0f, 0.0f,
                                                            boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale), gradientMask);
                    CGImageRelease(gradientMask);
                    CGContextSetFillColorWithColor(context, [self.objectChromaColor colorWithAlphaComponent:self.imageView.alpha].CGColor);
                    CGContextFillRect(context, CGRectMake(0.0f, 0.0f,
                                                          boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale));
                    gradientImage = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                }
                
                UIGraphicsBeginImageContextWithOptions(self.superViewSize, NO, 2.0f);
                CGContextRef context = UIGraphicsGetCurrentContext();
                CGContextConcatCTM(UIGraphicsGetCurrentContext(), videoTransform);
                
                pnt = CGPointApplyAffineTransform(CGPointMake(self.center.x, self.center.y), CGAffineTransformInvert(videoTransform));
                
                if (self.isImitationPhoto)
                {
                    //draw black background
                    CGContextSetFillColorWithColor(context, [self.objectChromaColor colorWithAlphaComponent:self.imageView.alpha].CGColor);
                    
                    if (self.isReflection)
                    {
                        CGContextFillRect(context, CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y - boundsSize.height*0.5f - self.objectBorderWidth, boundsSize.width + self.objectBorderWidth*2, boundsSize.height * (1.0f + self.reflectionScale) + self.objectBorderWidth*2 + self.reflectionGap));
                    }
                    else
                    {
                        CGContextFillRect(context, CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y - boundsSize.height*0.5f - self.objectBorderWidth, boundsSize.width + self.objectBorderWidth*2, boundsSize.height + self.objectBorderWidth*2));
                    }
                    
                    CGContextSaveGState(context);
                    
                    if (self.objectShadowStyle == 2)
                    {
                        CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), CGSizeMake(self.objectShadowOffset, self.objectShadowOffset), self.objectShadowBlur, self.objectShadowColor.CGColor);
                    }
                    
                    [image drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y - boundsSize.height*0.5f - self.objectBorderWidth, boundsSize.width + self.objectBorderWidth*2, boundsSize.height+self.objectBorderWidth*2) blendMode:kCGBlendModeNormal alpha:1.0f];
                    
                    if (self.isReflection)
                    {
                        [reflectionImage drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y + boundsSize.height*0.5f - self.objectBorderWidth + self.reflectionGap, boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale) blendMode:kCGBlendModeNormal alpha:1.0f];
                    }
                    
                    //erase inner of path
                    path = [self getErasePath:pnt];
                    CGContextAddPath(context, path.CGPath);
                    CGContextSetBlendMode(context, kCGBlendModeClear);
                    CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
                    CGContextFillPath(context);
                    CGContextRestoreGState(context);
                    
                    if (self.isReflection)
                    {
                        path = [self getErasePath:CGPointMake(pnt.x, pnt.y + boundsSize.height + self.reflectionGap)];
                        CGContextAddPath(context, path.CGPath);
                        CGContextSetBlendMode(context, kCGBlendModeClear);
                        CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
                        CGContextFillPath(context);
                        
                        //black gradient
                        [gradientImage drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y + boundsSize.height*0.5f + self.reflectionGap, boundsSize.width + self.objectBorderWidth*2, boundsSize.height*self.reflectionScale + self.objectBorderWidth*2) blendMode:kCGBlendModeNormal alpha:1.0f];
                    }
                }
                else
                {
                    if (self.objectShadowStyle == 2)
                    {
                        CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), CGSizeMake(self.objectShadowOffset, self.objectShadowOffset), self.objectShadowBlur, self.objectShadowColor.CGColor);
                    }
                    
                    [image drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y - boundsSize.height*0.5f - self.objectBorderWidth, boundsSize.width + self.objectBorderWidth*2, boundsSize.height+self.objectBorderWidth*2) blendMode:kCGBlendModeNormal alpha:1.0f];
                    
                    if (self.isReflection)
                    {
                        [reflectionImage drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y + boundsSize.height*0.5f + self.reflectionGap, reflectionSize.width, reflectionSize.height) blendMode:kCGBlendModeNormal alpha:self.reflectionAlpha];
                    }
                }
                
                CGContextConcatCTM(UIGraphicsGetCurrentContext(), CGAffineTransformInvert(videoTransform));
                image = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
            }
                break;
            case 8: //jigsaw line
            {
                UIGraphicsBeginImageContextWithOptions(CGSizeMake(image.size.width+self.objectBorderWidth*imageSize.width/originalBoundSize.width*2, image.size.height+self.objectBorderWidth*imageSize.width/originalBoundSize.width*2), NO, 2.0f);
                [image drawInRect:CGRectMake(self.objectBorderWidth*imageSize.width/originalBoundSize.width, self.objectBorderWidth*imageSize.width/originalBoundSize.width, image.size.width, image.size.height) blendMode:kCGBlendModeNormal alpha:self.imageView.alpha];
                UIImage* borderImage = [UIImage imageNamed:@"dotline_pattern"];
                
                borderImage = [borderImage imageWithOverlayColor:[self.objectBorderColor colorWithAlphaComponent:self.imageView.alpha]];
                
                colorRef = [UIColor colorWithPatternImage:borderImage].CGColor;
                CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(),  colorRef);
                
                path = [self getPatternBorderPath:image.size];
                path.lineWidth = self.objectBorderWidth*imageSize.width/originalBoundSize.width;
                [path stroke];
                
                image = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                
                CGSize reflectionSize = CGSizeMake(boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2) * self.reflectionScale);
                CGRect reflectionRect = CGRectMake(0.0f, 0.0f, boundsSize.width + self.objectBorderWidth*2, boundsSize.height+self.objectBorderWidth*2);
                
                if (self.isReflection)
                    reflectionImage = [self renderingReflectionImage:image size:reflectionSize rect:reflectionRect];
                
                if (self.isImitationPhoto && self.isReflection)
                {
                    //gradient mask
                    UIGraphicsBeginImageContextWithOptions(CGSizeMake(boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale), YES, 0.0f);
                    CGContextRef gradientContext = UIGraphicsGetCurrentContext();
                    CGFloat colors[] = {1.0f, 1.0f, 0.0f, 1.0f};
                    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
                    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, colors, NULL, 2);
                    CGPoint gradientStartPoint = CGPointMake(0.0f, 0.0f);
                    CGPoint gradientEndPoint = CGPointMake(0.0f, (boundsSize.height*self.reflectionScale) + self.objectBorderWidth*2);
                    CGContextDrawLinearGradient(gradientContext, gradient, gradientStartPoint,
                                                gradientEndPoint, kCGGradientDrawsAfterEndLocation);
                    CGImageRef gradientMask = CGBitmapContextCreateImage(gradientContext);
                    CGGradientRelease(gradient);
                    CGColorSpaceRelease(colorSpace);
                    UIGraphicsEndImageContext();
                    
                    //gradient image
                    UIGraphicsBeginImageContextWithOptions(CGSizeMake(boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale), NO, 0.0f);
                    CGContextRef context = UIGraphicsGetCurrentContext();
                    CGContextClipToMask(context, CGRectMake(0.0f, 0.0f,
                                                            boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale), gradientMask);
                    CGImageRelease(gradientMask);
                    CGContextSetFillColorWithColor(context, [self.objectChromaColor colorWithAlphaComponent:self.imageView.alpha].CGColor);
                    CGContextFillRect(context, CGRectMake(0.0f, 0.0f,
                                                          boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale));
                    gradientImage = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                }
                
                UIGraphicsBeginImageContextWithOptions(self.superViewSize, NO, 2.0f);
                CGContextRef context = UIGraphicsGetCurrentContext();
                CGContextConcatCTM(UIGraphicsGetCurrentContext(), videoTransform);
                
                pnt = CGPointApplyAffineTransform(CGPointMake(self.center.x, self.center.y), CGAffineTransformInvert(videoTransform));
                
                if (self.isImitationPhoto)
                {
                    //draw black background
                    CGContextSetFillColorWithColor(context, [self.objectChromaColor colorWithAlphaComponent:self.imageView.alpha].CGColor);
                    
                    if (self.isReflection)
                    {
                        CGContextFillRect(context, CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y - boundsSize.height*0.5f - self.objectBorderWidth, boundsSize.width + self.objectBorderWidth*2, boundsSize.height * (1.0f + self.reflectionScale) + self.objectBorderWidth*2 + self.reflectionGap));
                    }
                    else
                    {
                        CGContextFillRect(context, CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y - boundsSize.height*0.5f - self.objectBorderWidth, boundsSize.width + self.objectBorderWidth*2, boundsSize.height + self.objectBorderWidth*2));
                    }
                    
                    CGContextSaveGState(context);
                    
                    if (self.objectShadowStyle == 2)
                    {
                        CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), CGSizeMake(self.objectShadowOffset, self.objectShadowOffset), self.objectShadowBlur, self.objectShadowColor.CGColor);
                    }
                    
                    [image drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y - boundsSize.height*0.5f - self.objectBorderWidth, boundsSize.width + self.objectBorderWidth*2, boundsSize.height+self.objectBorderWidth*2) blendMode:kCGBlendModeNormal alpha:1.0f];
                    
                    if (self.isReflection)
                    {
                        [reflectionImage drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y + boundsSize.height*0.5f - self.objectBorderWidth + self.reflectionGap, boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale) blendMode:kCGBlendModeNormal alpha:1.0f];
                    }
                    
                    //erase inner of path
                    path = [self getErasePath:pnt];
                    CGContextAddPath(context, path.CGPath);
                    CGContextSetBlendMode(context, kCGBlendModeClear);
                    CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
                    CGContextFillPath(context);
                    CGContextRestoreGState(context);
                    
                    if (self.isReflection)
                    {
                        path = [self getErasePath:CGPointMake(pnt.x, pnt.y + boundsSize.height + self.reflectionGap)];
                        CGContextAddPath(context, path.CGPath);
                        CGContextSetBlendMode(context, kCGBlendModeClear);
                        CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
                        CGContextFillPath(context);
                        
                        //black gradient
                        [gradientImage drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y + boundsSize.height*0.5f + self.reflectionGap, boundsSize.width + self.objectBorderWidth*2, boundsSize.height*self.reflectionScale + self.objectBorderWidth*2) blendMode:kCGBlendModeNormal alpha:1.0f];
                    }
                }
                else
                {
                    if (self.objectShadowStyle == 2)
                    {
                        CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), CGSizeMake(self.objectShadowOffset, self.objectShadowOffset), self.objectShadowBlur, self.objectShadowColor.CGColor);
                    }
                    
                    [image drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y - boundsSize.height*0.5f - self.objectBorderWidth, boundsSize.width + self.objectBorderWidth*2, boundsSize.height+self.objectBorderWidth*2) blendMode:kCGBlendModeNormal alpha:1.0f];
                    
                    if (self.isReflection)
                    {
                        [reflectionImage drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y + boundsSize.height*0.5f + self.reflectionGap, reflectionSize.width, reflectionSize.height) blendMode:kCGBlendModeNormal alpha:self.reflectionAlpha];
                    }
                }
                
                CGContextConcatCTM(UIGraphicsGetCurrentContext(), CGAffineTransformInvert(videoTransform));
                image = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
            }
                break;
            case 9: //flower line
            {
                UIGraphicsBeginImageContextWithOptions(CGSizeMake(image.size.width+self.objectBorderWidth*imageSize.width/originalBoundSize.width*2, image.size.height+self.objectBorderWidth*imageSize.width/originalBoundSize.width*2), NO, 2.0f);
                [image drawInRect:CGRectMake(self.objectBorderWidth*imageSize.width/originalBoundSize.width, self.objectBorderWidth*imageSize.width/originalBoundSize.width, image.size.width, image.size.height) blendMode:kCGBlendModeNormal alpha:self.imageView.alpha];
                UIImage* borderImage = [UIImage imageNamed:@"flower"];
                borderImage = [borderImage rescaleImageToSize:CGSizeMake(self.objectBorderWidth*imageSize.width/originalBoundSize.width, self.objectBorderWidth*imageSize.width/originalBoundSize.width)];
                
                borderImage = [borderImage imageWithOverlayColor:[self.objectBorderColor colorWithAlphaComponent:self.imageView.alpha]];
                
                colorRef = [UIColor colorWithPatternImage:borderImage].CGColor;
                CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(),  colorRef);
                
                path = [self getPatternBorderPath:image.size];
                path.lineWidth = self.objectBorderWidth*imageSize.width/originalBoundSize.width;
                [path stroke];
                
                image = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                
                CGSize reflectionSize = CGSizeMake(boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2) * self.reflectionScale);
                CGRect reflectionRect = CGRectMake(0.0f, 0.0f, boundsSize.width + self.objectBorderWidth*2, boundsSize.height+self.objectBorderWidth*2);
                
                if (self.isReflection)
                {
                    reflectionImage = [self renderingReflectionImage:image size:reflectionSize rect:reflectionRect];
                }
                
                if (self.isImitationPhoto && self.isReflection)
                {
                    //gradient mask
                    UIGraphicsBeginImageContextWithOptions(CGSizeMake(boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale), YES, 0.0f);
                    CGContextRef gradientContext = UIGraphicsGetCurrentContext();
                    CGFloat colors[] = {1.0f, 1.0f, 0.0f, 1.0f};
                    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
                    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, colors, NULL, 2);
                    CGPoint gradientStartPoint = CGPointMake(0.0f, 0.0f);
                    CGPoint gradientEndPoint = CGPointMake(0.0f, (boundsSize.height*self.reflectionScale) + self.objectBorderWidth*2);
                    CGContextDrawLinearGradient(gradientContext, gradient, gradientStartPoint,
                                                gradientEndPoint, kCGGradientDrawsAfterEndLocation);
                    CGImageRef gradientMask = CGBitmapContextCreateImage(gradientContext);
                    CGGradientRelease(gradient);
                    CGColorSpaceRelease(colorSpace);
                    UIGraphicsEndImageContext();
                    
                    //gradient image
                    UIGraphicsBeginImageContextWithOptions(CGSizeMake(boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale), NO, 0.0f);
                    CGContextRef context = UIGraphicsGetCurrentContext();
                    CGContextClipToMask(context, CGRectMake(0.0f, 0.0f,
                                                            boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale), gradientMask);
                    CGImageRelease(gradientMask);
                    CGContextSetFillColorWithColor(context, [self.objectChromaColor colorWithAlphaComponent:self.imageView.alpha].CGColor);
                    CGContextFillRect(context, CGRectMake(0.0f, 0.0f,
                                                          boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale));
                    gradientImage = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                }
                
                UIGraphicsBeginImageContextWithOptions(self.superViewSize, NO, 2.0f);
                CGContextRef context = UIGraphicsGetCurrentContext();
                CGContextConcatCTM(UIGraphicsGetCurrentContext(), videoTransform);
                
                pnt = CGPointApplyAffineTransform(CGPointMake(self.center.x, self.center.y), CGAffineTransformInvert(videoTransform));
                
                if (self.isImitationPhoto)
                {
                    //draw black background
                    CGContextSetFillColorWithColor(context, [self.objectChromaColor colorWithAlphaComponent:self.imageView.alpha].CGColor);
                    
                    if (self.isReflection)
                    {
                        CGContextFillRect(context, CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y - boundsSize.height*0.5f - self.objectBorderWidth, boundsSize.width + self.objectBorderWidth*2, boundsSize.height * (1.0f + self.reflectionScale) + self.objectBorderWidth*2 + self.reflectionGap));
                    }
                    else
                    {
                        CGContextFillRect(context, CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y - boundsSize.height*0.5f - self.objectBorderWidth, boundsSize.width + self.objectBorderWidth*2, boundsSize.height + self.objectBorderWidth*2));
                    }
                    
                    CGContextSaveGState(context);
                    
                    if (self.objectShadowStyle == 2)
                    {
                        CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), CGSizeMake(self.objectShadowOffset, self.objectShadowOffset), self.objectShadowBlur, self.objectShadowColor.CGColor);
                    }
                    
                    [image drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y - boundsSize.height*0.5f - self.objectBorderWidth, boundsSize.width + self.objectBorderWidth*2, boundsSize.height+self.objectBorderWidth*2) blendMode:kCGBlendModeNormal alpha:1.0f];
                    
                    if (self.isReflection)
                    {
                        [reflectionImage drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y + boundsSize.height*0.5f - self.objectBorderWidth + self.reflectionGap, boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale) blendMode:kCGBlendModeNormal alpha:1.0f];
                    }
                    
                    //erase inner of path
                    path = [self getErasePath:pnt];
                    CGContextAddPath(context, path.CGPath);
                    CGContextSetBlendMode(context, kCGBlendModeClear);
                    CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
                    CGContextFillPath(context);
                    CGContextRestoreGState(context);
                    
                    if (self.isReflection)
                    {
                        path = [self getErasePath:CGPointMake(pnt.x, pnt.y + boundsSize.height + self.reflectionGap)];
                        CGContextAddPath(context, path.CGPath);
                        CGContextSetBlendMode(context, kCGBlendModeClear);
                        CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
                        CGContextFillPath(context);
                        
                        //black gradient
                        [gradientImage drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y + boundsSize.height*0.5f + self.reflectionGap, boundsSize.width + self.objectBorderWidth*2, boundsSize.height*self.reflectionScale + self.objectBorderWidth*2) blendMode:kCGBlendModeNormal alpha:1.0f];
                    }
                }
                else
                {
                    if (self.objectShadowStyle == 2)
                    {
                        CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), CGSizeMake(self.objectShadowOffset, self.objectShadowOffset), self.objectShadowBlur, self.objectShadowColor.CGColor);
                    }
                    
                    [image drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y - boundsSize.height*0.5f - self.objectBorderWidth, boundsSize.width + self.objectBorderWidth*2, boundsSize.height+self.objectBorderWidth*2) blendMode:kCGBlendModeNormal alpha:1.0f];
                    
                    if (self.isReflection)
                    {
                        [reflectionImage drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y + boundsSize.height*0.5f + self.reflectionGap, reflectionSize.width, reflectionSize.height) blendMode:kCGBlendModeNormal alpha:self.reflectionAlpha];
                    }
                }
                
                CGContextConcatCTM(UIGraphicsGetCurrentContext(), CGAffineTransformInvert(videoTransform));
                image = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
            }
                break;
            case 10: //black circle line
            {
                UIGraphicsBeginImageContextWithOptions(CGSizeMake(image.size.width+self.objectBorderWidth*imageSize.width/originalBoundSize.width*2, image.size.height+self.objectBorderWidth*imageSize.width/originalBoundSize.width*2), NO, 2.0f);
                [image drawInRect:CGRectMake(self.objectBorderWidth*imageSize.width/originalBoundSize.width, self.objectBorderWidth*imageSize.width/originalBoundSize.width, image.size.width, image.size.height) blendMode:kCGBlendModeNormal alpha:self.imageView.alpha];
                UIImage* borderImage = [UIImage imageNamed:@"circle"];
                borderImage = [borderImage rescaleImageToSize:CGSizeMake(self.objectBorderWidth*imageSize.width/originalBoundSize.width, self.objectBorderWidth*imageSize.width/originalBoundSize.width)];
                
                borderImage = [borderImage imageWithOverlayColor:[self.objectBorderColor colorWithAlphaComponent:self.imageView.alpha]];
                
                colorRef = [UIColor colorWithPatternImage:borderImage].CGColor;
                CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(),  colorRef);
                
                path = [self getPatternBorderPath:image.size];
                path.lineWidth = self.objectBorderWidth*imageSize.width/originalBoundSize.width;
                [path stroke];
                
                image = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                
                CGSize reflectionSize = CGSizeMake(boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2) * self.reflectionScale);
                CGRect reflectionRect = CGRectMake(0.0f, 0.0f, boundsSize.width + self.objectBorderWidth*2, boundsSize.height+self.objectBorderWidth*2);
                
                if (self.isReflection)
                    reflectionImage = [self renderingReflectionImage:image size:reflectionSize rect:reflectionRect];
                
                if (self.isImitationPhoto && self.isReflection)
                {
                    //gradient mask
                    UIGraphicsBeginImageContextWithOptions(CGSizeMake(boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale), YES, 0.0f);
                    CGContextRef gradientContext = UIGraphicsGetCurrentContext();
                    CGFloat colors[] = {1.0f, 1.0f, 0.0f, 1.0f};
                    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
                    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, colors, NULL, 2);
                    CGPoint gradientStartPoint = CGPointMake(0.0f, 0.0f);
                    CGPoint gradientEndPoint = CGPointMake(0.0f, (boundsSize.height*self.reflectionScale) + self.objectBorderWidth*2);
                    CGContextDrawLinearGradient(gradientContext, gradient, gradientStartPoint,
                                                gradientEndPoint, kCGGradientDrawsAfterEndLocation);
                    CGImageRef gradientMask = CGBitmapContextCreateImage(gradientContext);
                    CGGradientRelease(gradient);
                    CGColorSpaceRelease(colorSpace);
                    UIGraphicsEndImageContext();
                    
                    //gradient image
                    UIGraphicsBeginImageContextWithOptions(CGSizeMake(boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale), NO, 0.0f);
                    CGContextRef context = UIGraphicsGetCurrentContext();
                    CGContextClipToMask(context, CGRectMake(0.0f, 0.0f,
                                                            boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale), gradientMask);
                    CGImageRelease(gradientMask);
                    CGContextSetFillColorWithColor(context, [self.objectChromaColor colorWithAlphaComponent:self.imageView.alpha].CGColor);
                    CGContextFillRect(context, CGRectMake(0.0f, 0.0f,
                                                          boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale));
                    gradientImage = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                }
                
                UIGraphicsBeginImageContextWithOptions(self.superViewSize, NO, 2.0f);
                CGContextRef context = UIGraphicsGetCurrentContext();
                CGContextConcatCTM(UIGraphicsGetCurrentContext(), videoTransform);
                
                pnt = CGPointApplyAffineTransform(CGPointMake(self.center.x, self.center.y), CGAffineTransformInvert(videoTransform));
                
                if (self.isImitationPhoto)
                {
                    //draw black background
                    CGContextSetFillColorWithColor(context, [self.objectChromaColor colorWithAlphaComponent:self.imageView.alpha].CGColor);
                    
                    if (self.isReflection)
                    {
                        CGContextFillRect(context, CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y - boundsSize.height*0.5f - self.objectBorderWidth, boundsSize.width + self.objectBorderWidth*2, boundsSize.height * (1.0f + self.reflectionScale) + self.objectBorderWidth*2 + self.reflectionGap));
                    }
                    else
                    {
                        CGContextFillRect(context, CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y - boundsSize.height*0.5f - self.objectBorderWidth, boundsSize.width + self.objectBorderWidth*2, boundsSize.height + self.objectBorderWidth*2));
                    }
                    
                    CGContextSaveGState(context);
                    
                    if (self.objectShadowStyle == 2)
                    {
                        CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), CGSizeMake(self.objectShadowOffset, self.objectShadowOffset), self.objectShadowBlur, self.objectShadowColor.CGColor);
                    }
                    
                    [image drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y - boundsSize.height*0.5f - self.objectBorderWidth, boundsSize.width + self.objectBorderWidth*2, boundsSize.height+self.objectBorderWidth*2) blendMode:kCGBlendModeNormal alpha:1.0f];
                    
                    if (self.isReflection)
                    {
                        [reflectionImage drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y + boundsSize.height*0.5f - self.objectBorderWidth + self.reflectionGap, boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale) blendMode:kCGBlendModeNormal alpha:1.0f];
                    }
                    
                    //erase inner of path
                    path = [self getErasePath:pnt];
                    CGContextAddPath(context, path.CGPath);
                    CGContextSetBlendMode(context, kCGBlendModeClear);
                    CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
                    CGContextFillPath(context);
                    CGContextRestoreGState(context);
                    
                    if (self.isReflection)
                    {
                        path = [self getErasePath:CGPointMake(pnt.x, pnt.y + boundsSize.height + self.reflectionGap)];
                        CGContextAddPath(context, path.CGPath);
                        CGContextSetBlendMode(context, kCGBlendModeClear);
                        CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
                        CGContextFillPath(context);
                        
                        //black gradient
                        [gradientImage drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y + boundsSize.height*0.5f + self.reflectionGap, boundsSize.width + self.objectBorderWidth*2, boundsSize.height*self.reflectionScale + self.objectBorderWidth*2) blendMode:kCGBlendModeNormal alpha:1.0f];
                    }
                }
                else
                {
                    if (self.objectShadowStyle == 2)
                    {
                        CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), CGSizeMake(self.objectShadowOffset, self.objectShadowOffset), self.objectShadowBlur, self.objectShadowColor.CGColor);
                    }
                    
                    [image drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y - boundsSize.height*0.5f - self.objectBorderWidth, boundsSize.width + self.objectBorderWidth*2, boundsSize.height+self.objectBorderWidth*2) blendMode:kCGBlendModeNormal alpha:1.0f];
                    
                    if (self.isReflection)
                    {
                        [reflectionImage drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y + boundsSize.height*0.5f + self.reflectionGap, reflectionSize.width, reflectionSize.height) blendMode:kCGBlendModeNormal alpha:self.reflectionAlpha];
                    }
                }
                
                CGContextConcatCTM(UIGraphicsGetCurrentContext(), CGAffineTransformInvert(videoTransform));
                image = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
            }
                break;
            default:
                break;
        }
    }
    else if (self.mediaType == MEDIA_TEXT)
    {
        UIImage* reflectionImage = nil;
        
        CGColorRef colorRef = nil;
        CGPoint pnt = CGPointZero;
        UIBezierPath* path;
        CGSize reflectionSize = CGSizeZero;
        CGRect reflectionRect = CGRectZero;
        
        UIGraphicsBeginImageContextWithOptions(self.textView.bounds.size, NO, 2.0f);
        self.textView.layer.shadowColor = [UIColor clearColor].CGColor;
        [self.textView.layer renderInContext:UIGraphicsGetCurrentContext()];
        
        if (self.objectShadowStyle == 2)
            self.textView.layer.shadowColor = self.objectShadowColor.CGColor;
        
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        
        CGSize imageSize = image.size;
        
        CGRect kbCropRect = CGRectZero;
        
        CGFloat  fKbScale = 1.0f;
        
        if (self.nKbIn == KB_IN)
        {
            if (isStart)
            {
                fKbScale = 1.0f + (self.fKbScale - 1.0f) * self.mfStartAnimationDuration / (self.mfEndPosition - self.mfStartPosition - MIN_DURATION);
            }
            else
            {
                fKbScale = 1.0f + (self.fKbScale - 1.0f) * (self.mfEndPosition - self.mfStartPosition - self.mfEndAnimationDuration - MIN_DURATION) / (self.mfEndPosition - self.mfStartPosition - MIN_DURATION);
            }
        }
        else
        {
            if (isStart)
            {
                fKbScale = 1.0f + (self.fKbScale - 1.0f) * (self.mfEndPosition - self.mfStartPosition - self.mfStartAnimationDuration - MIN_DURATION) / (self.mfEndPosition - self.mfStartPosition - MIN_DURATION);
            }
            else
            {
                fKbScale = 1.0f + (self.fKbScale - 1.0f) * self.mfEndAnimationDuration / (self.mfEndPosition - self.mfStartPosition - MIN_DURATION);
            }
        }
        
        kbCropRect = CGRectMake((imageSize.width - imageSize.width/fKbScale)*self.kbFocusPoint.x, (imageSize.height - imageSize.height/fKbScale)*self.kbFocusPoint.y, imageSize.width/fKbScale, imageSize.height/fKbScale);

        image = [image cropImageToRect:kbCropRect];
        image = [image rescaleImageToSize:imageSize];
        
        
        if (self.objectCornerRadius != 0.0f)
            image = [self renderTextWithCorner:image];
        
        switch (self.objectBorderStyle)
        {
            case 1: //no outline
                reflectionSize = CGSizeMake(self.bounds.size.width, self.bounds.size.height * self.reflectionScale);
                reflectionRect = CGRectMake(0.0f, 0.0f, self.bounds.size.width, self.bounds.size.height);
                
                if (self.isReflection)
                    reflectionImage = [self renderingReflectionImage:image size:reflectionSize rect:reflectionRect];
                
                UIGraphicsBeginImageContextWithOptions(self.superViewSize, NO, 2.0f);
                CGContextConcatCTM(UIGraphicsGetCurrentContext(), self.transform);
                pnt = CGPointApplyAffineTransform(CGPointMake(self.center.x, self.center.y), CGAffineTransformInvert(self.transform));
                
                if (self.objectShadowStyle == 2)
                {
                    CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), CGSizeMake(self.objectShadowOffset, self.objectShadowOffset), self.objectShadowBlur, self.objectShadowColor.CGColor);
                }
                
                [image drawInRect:CGRectMake(pnt.x - self.bounds.size.width*0.5f, pnt.y - self.bounds.size.height*0.5f, self.bounds.size.width, self.bounds.size.height)  blendMode:kCGBlendModeNormal alpha:1.0f];
                
                if (self.isReflection)
                {
                    [reflectionImage drawInRect:CGRectMake(pnt.x - self.bounds.size.width*0.5f, pnt.y + self.bounds.size.height*0.5f + self.reflectionGap, reflectionSize.width, reflectionSize.height) blendMode:kCGBlendModeNormal alpha:self.reflectionAlpha];
                }
                
                CGContextConcatCTM(UIGraphicsGetCurrentContext(), CGAffineTransformInvert(self.transform));
                image = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                break;
            case 2: //line
                if (self.isImitationPhoto)
                {
                    UIGraphicsBeginImageContextWithOptions(self.superViewSize, NO, 2.0f);
                    CGContextConcatCTM(UIGraphicsGetCurrentContext(), self.transform);
                    pnt = CGPointApplyAffineTransform(CGPointMake(self.center.x, self.center.y), CGAffineTransformInvert(self.transform));
                    
                    if (self.objectShadowStyle == 2)
                    {
                        CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), CGSizeMake(self.objectShadowOffset, self.objectShadowOffset), self.objectShadowBlur, self.objectShadowColor.CGColor);
                    }
                    
                    CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(),  [self.objectBorderColor colorWithAlphaComponent:self.textView.alpha].CGColor);
                    
                    path = [self getBorderPath:pnt];
                    path.lineWidth = self.objectBorderWidth;
                    [path stroke];
                    
                    CGContextConcatCTM(UIGraphicsGetCurrentContext(), CGAffineTransformInvert(self.transform));
                    image = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                }
                else
                {
                    UIGraphicsBeginImageContextWithOptions(CGSizeMake(self.textView.frame.size.width+self.objectBorderWidth*2, self.textView.frame.size.height+self.objectBorderWidth*2), NO, 2.0f);
                    [image drawInRect:CGRectMake(self.objectBorderWidth, self.objectBorderWidth, self.textView.frame.size.width, self.textView.frame.size.height)  blendMode:kCGBlendModeNormal alpha:1.0f];
                    
                    CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(),  [self.objectBorderColor colorWithAlphaComponent:self.textView.alpha].CGColor);
                    
                    path = [self getTextPatternBorderPath];
                    path.lineWidth = self.objectBorderWidth;
                    [path stroke];
                    
                    image = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                    
                    reflectionSize = CGSizeMake(self.bounds.size.width + self.objectBorderWidth*2, (self.bounds.size.height + self.objectBorderWidth*2) * self.reflectionScale);
                    reflectionRect = CGRectMake(0.0f, 0.0f, self.bounds.size.width + self.objectBorderWidth*2, self.bounds.size.height+self.objectBorderWidth*2);
                    
                    if (self.isReflection)
                    {
                        reflectionImage = [self renderingReflectionImage:image size:reflectionSize rect:reflectionRect];
                    }
                    
                    UIGraphicsBeginImageContextWithOptions(self.superViewSize, NO, 2.0f);
                    CGContextConcatCTM(UIGraphicsGetCurrentContext(), self.transform);
                    pnt = CGPointApplyAffineTransform(CGPointMake(self.center.x, self.center.y), CGAffineTransformInvert(self.transform));
                    
                    if (self.objectShadowStyle == 2)
                    {
                        CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), CGSizeMake(self.objectShadowOffset, self.objectShadowOffset), self.objectShadowBlur, self.objectShadowColor.CGColor);
                    }
                    
                    [image drawInRect:CGRectMake(pnt.x - self.bounds.size.width*0.5f - self.objectBorderWidth, pnt.y - self.bounds.size.height*0.5f - self.objectBorderWidth, self.bounds.size.width + self.objectBorderWidth*2, self.bounds.size.height+self.objectBorderWidth*2) blendMode:kCGBlendModeNormal alpha:1.0f];
                    
                    if (self.isReflection)
                    {
                        [reflectionImage drawInRect:CGRectMake(pnt.x - self.bounds.size.width*0.5f - self.objectBorderWidth, pnt.y + self.bounds.size.height*0.5f + self.reflectionGap, reflectionSize.width, reflectionSize.height) blendMode:kCGBlendModeNormal alpha:self.reflectionAlpha];
                    }
                    
                    CGContextConcatCTM(UIGraphicsGetCurrentContext(), CGAffineTransformInvert(self.transform));
                    image = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                }
                break;
            case 3: //shot dot line
                if (self.isImitationPhoto)
                {
                    UIGraphicsBeginImageContextWithOptions(self.superViewSize, NO, 2.0f);
                    CGContextConcatCTM(UIGraphicsGetCurrentContext(), self.transform);
                    pnt = CGPointApplyAffineTransform(CGPointMake(self.center.x, self.center.y), CGAffineTransformInvert(self.transform));
                    
                    if (self.objectShadowStyle == 2)
                    {
                        CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), CGSizeMake(self.objectShadowOffset, self.objectShadowOffset), self.objectShadowBlur, self.objectShadowColor.CGColor);
                    }
                    
                    CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(),  [self.objectBorderColor colorWithAlphaComponent:self.textView.alpha].CGColor);
                    
                    CGFloat pattern[] = {self.objectBorderWidth, self.objectBorderWidth};
                    CGContextSetLineDash(UIGraphicsGetCurrentContext(), 0.0f, pattern, 2);
                    
                    path = [self getBorderPath:pnt];
                    path.lineWidth = self.objectBorderWidth;
                    path.lineCapStyle = kCGLineCapButt;
                    path.lineJoinStyle = kCGLineJoinMiter;
                    [path stroke];
                    
                    CGContextConcatCTM(UIGraphicsGetCurrentContext(), CGAffineTransformInvert(self.transform));
                    image = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                }
                else
                {
                    UIGraphicsBeginImageContextWithOptions(CGSizeMake(self.textView.frame.size.width+self.objectBorderWidth*2, self.textView.frame.size.height+self.objectBorderWidth*2), NO, 2.0f);
                    [image drawInRect:CGRectMake(self.objectBorderWidth, self.objectBorderWidth, self.textView.frame.size.width, self.textView.frame.size.height)  blendMode:kCGBlendModeNormal alpha:1.0f];
                    
                    CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(),  [self.objectBorderColor colorWithAlphaComponent:self.textView.alpha].CGColor);
                    
                    CGFloat pattern[] = {self.objectBorderWidth, self.objectBorderWidth};
                    CGContextSetLineDash(UIGraphicsGetCurrentContext(), 0.0f, pattern, 2);
                    
                    path = [self getTextPatternBorderPath];
                    path.lineWidth = self.objectBorderWidth;
                    path.lineCapStyle = kCGLineCapButt;
                    path.lineJoinStyle = kCGLineJoinMiter;
                    [path stroke];
                    
                    image = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                    
                    reflectionSize = CGSizeMake(self.bounds.size.width + self.objectBorderWidth*2, (self.bounds.size.height + self.objectBorderWidth*2) * self.reflectionScale);
                    reflectionRect = CGRectMake(0.0f, 0.0f, self.bounds.size.width + self.objectBorderWidth*2, self.bounds.size.height+self.objectBorderWidth*2);
                    
                    if (self.isReflection)
                    {
                        reflectionImage = [self renderingReflectionImage:image size:reflectionSize rect:reflectionRect];
                    }
                    
                    UIGraphicsBeginImageContextWithOptions(self.superViewSize, NO, 2.0f);
                    CGContextConcatCTM(UIGraphicsGetCurrentContext(), self.transform);
                    pnt = CGPointApplyAffineTransform(CGPointMake(self.center.x, self.center.y), CGAffineTransformInvert(self.transform));
                    
                    if (self.objectShadowStyle == 2)
                    {
                        CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), CGSizeMake(self.objectShadowOffset, self.objectShadowOffset), self.objectShadowBlur, self.objectShadowColor.CGColor);
                    }
                    
                    [image drawInRect:CGRectMake(pnt.x - self.bounds.size.width*0.5f - self.objectBorderWidth, pnt.y - self.bounds.size.height*0.5f - self.objectBorderWidth, self.bounds.size.width + self.objectBorderWidth*2, self.bounds.size.height+self.objectBorderWidth*2) blendMode:kCGBlendModeNormal alpha:1.0f];
                    
                    if (self.isReflection)
                    {
                        [reflectionImage drawInRect:CGRectMake(pnt.x - self.bounds.size.width*0.5f - self.objectBorderWidth, pnt.y + self.bounds.size.height*0.5f + self.reflectionGap, reflectionSize.width, reflectionSize.height) blendMode:kCGBlendModeNormal alpha:self.reflectionAlpha];
                    }
                    
                    CGContextConcatCTM(UIGraphicsGetCurrentContext(), CGAffineTransformInvert(self.transform));
                    image = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                }
                break;
            case 4: //middle dot line
                if (self.isImitationPhoto)
                {
                    UIGraphicsBeginImageContextWithOptions(self.superViewSize, NO, 2.0f);
                    CGContextConcatCTM(UIGraphicsGetCurrentContext(), self.transform);
                    pnt = CGPointApplyAffineTransform(CGPointMake(self.center.x, self.center.y), CGAffineTransformInvert(self.transform));
                    
                    if (self.objectShadowStyle == 2)
                    {
                        CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), CGSizeMake(self.objectShadowOffset, self.objectShadowOffset), self.objectShadowBlur, self.objectShadowColor.CGColor);
                    }
                    
                    CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(),  [self.objectBorderColor colorWithAlphaComponent:self.textView.alpha].CGColor);
                    
                    CGFloat middleDotLinePattern[] = {1.5f*self.objectBorderWidth, 1.5f*self.objectBorderWidth};
                    CGContextSetLineDash(UIGraphicsGetCurrentContext(), 0.0f, middleDotLinePattern, 2);
                    
                    path = [self getBorderPath:pnt];
                    path.lineWidth = self.objectBorderWidth;
                    path.lineCapStyle = kCGLineCapButt;
                    path.lineJoinStyle = kCGLineJoinMiter;
                    [path stroke];
                    
                    CGContextConcatCTM(UIGraphicsGetCurrentContext(), CGAffineTransformInvert(self.transform));
                    image = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                }
                else
                {
                    UIGraphicsBeginImageContextWithOptions(CGSizeMake(self.textView.frame.size.width+self.objectBorderWidth*2, self.textView.frame.size.height+self.objectBorderWidth*2), NO, 2.0f);
                    [image drawInRect:CGRectMake(self.objectBorderWidth, self.objectBorderWidth, self.textView.frame.size.width, self.textView.frame.size.height)  blendMode:kCGBlendModeNormal alpha:1.0f];
                    
                    CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(),  [self.objectBorderColor colorWithAlphaComponent:self.textView.alpha].CGColor);
                    
                    CGFloat middleDotLinePattern[] = {1.5f*self.objectBorderWidth, 1.5f*self.objectBorderWidth};
                    CGContextSetLineDash(UIGraphicsGetCurrentContext(), 0.0f, middleDotLinePattern, 2);
                    
                    path = [self getTextPatternBorderPath];
                    path.lineWidth = self.objectBorderWidth;
                    path.lineCapStyle = kCGLineCapButt;
                    path.lineJoinStyle = kCGLineJoinMiter;
                    [path stroke];
                    
                    image = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                    
                    reflectionSize = CGSizeMake(self.bounds.size.width + self.objectBorderWidth*2, (self.bounds.size.height + self.objectBorderWidth*2) * self.reflectionScale);
                    reflectionRect = CGRectMake(0.0f, 0.0f, self.bounds.size.width + self.objectBorderWidth*2, self.bounds.size.height+self.objectBorderWidth*2);
                    
                    if (self.isReflection)
                    {
                        reflectionImage = [self renderingReflectionImage:image size:reflectionSize rect:reflectionRect];
                    }
                    
                    UIGraphicsBeginImageContextWithOptions(self.superViewSize, NO, 2.0f);
                    CGContextConcatCTM(UIGraphicsGetCurrentContext(), self.transform);
                    pnt = CGPointApplyAffineTransform(CGPointMake(self.center.x, self.center.y), CGAffineTransformInvert(self.transform));
                    
                    if (self.objectShadowStyle == 2)
                    {
                        CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), CGSizeMake(self.objectShadowOffset, self.objectShadowOffset), self.objectShadowBlur, self.objectShadowColor.CGColor);
                    }
                    
                    [image drawInRect:CGRectMake(pnt.x - self.bounds.size.width*0.5f - self.objectBorderWidth, pnt.y - self.bounds.size.height*0.5f - self.objectBorderWidth, self.bounds.size.width + self.objectBorderWidth*2, self.bounds.size.height+self.objectBorderWidth*2) blendMode:kCGBlendModeNormal alpha:1.0f];
                    
                    if (self.isReflection)
                    {
                        [reflectionImage drawInRect:CGRectMake(pnt.x - self.bounds.size.width*0.5f - self.objectBorderWidth, pnt.y + self.bounds.size.height*0.5f + self.reflectionGap, reflectionSize.width, reflectionSize.height) blendMode:kCGBlendModeNormal alpha:self.reflectionAlpha];
                    }
                    
                    CGContextConcatCTM(UIGraphicsGetCurrentContext(), CGAffineTransformInvert(self.transform));
                    image = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                }
                break;
            case 5: //long dot line
                if (self.isImitationPhoto)
                {
                    UIGraphicsBeginImageContextWithOptions(self.superViewSize, NO, 2.0f);
                    CGContextConcatCTM(UIGraphicsGetCurrentContext(), self.transform);
                    pnt = CGPointApplyAffineTransform(CGPointMake(self.center.x, self.center.y), CGAffineTransformInvert(self.transform));
                    
                    if (self.objectShadowStyle == 2)
                    {
                        CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), CGSizeMake(self.objectShadowOffset, self.objectShadowOffset), self.objectShadowBlur, self.objectShadowColor.CGColor);
                    }
                    
                    CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(),  [self.objectBorderColor colorWithAlphaComponent:self.textView.alpha].CGColor);
                    
                    CGFloat longDotLinePattern[] = {3.0f*self.objectBorderWidth, 3.0f*self.objectBorderWidth};
                    CGContextSetLineDash(UIGraphicsGetCurrentContext(), 0.0f, longDotLinePattern, 2);
                    
                    path = [self getBorderPath:pnt];
                    path.lineWidth = self.objectBorderWidth;
                    path.lineCapStyle = kCGLineCapButt;
                    path.lineJoinStyle = kCGLineJoinMiter;
                    [path stroke];
                    
                    CGContextConcatCTM(UIGraphicsGetCurrentContext(), CGAffineTransformInvert(self.transform));
                    image = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                }
                else
                {
                    UIGraphicsBeginImageContextWithOptions(CGSizeMake(self.textView.frame.size.width+self.objectBorderWidth*2, self.textView.frame.size.height+self.objectBorderWidth*2), NO, 2.0f);
                    [image drawInRect:CGRectMake(self.objectBorderWidth, self.objectBorderWidth, self.textView.frame.size.width, self.textView.frame.size.height)  blendMode:kCGBlendModeNormal alpha:1.0f];
                    
                    CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(),  [self.objectBorderColor colorWithAlphaComponent:self.textView.alpha].CGColor);
                    
                    CGFloat longDotLinePattern[] = {3.0f*self.objectBorderWidth, 3.0f*self.objectBorderWidth};
                    CGContextSetLineDash(UIGraphicsGetCurrentContext(), 0.0f, longDotLinePattern, 2);
                    
                    path = [self getTextPatternBorderPath];
                    path.lineWidth = self.objectBorderWidth;
                    path.lineCapStyle = kCGLineCapButt;
                    path.lineJoinStyle = kCGLineJoinMiter;
                    [path stroke];
                    
                    image = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                    
                    reflectionSize = CGSizeMake(self.bounds.size.width + self.objectBorderWidth*2, (self.bounds.size.height + self.objectBorderWidth*2) * self.reflectionScale);
                    reflectionRect = CGRectMake(0.0f, 0.0f, self.bounds.size.width + self.objectBorderWidth*2, self.bounds.size.height+self.objectBorderWidth*2);
                    
                    if (self.isReflection)
                    {
                        reflectionImage = [self renderingReflectionImage:image size:reflectionSize rect:reflectionRect];
                    }
                    
                    UIGraphicsBeginImageContextWithOptions(self.superViewSize, NO, 2.0f);
                    CGContextConcatCTM(UIGraphicsGetCurrentContext(), self.transform);
                    pnt = CGPointApplyAffineTransform(CGPointMake(self.center.x, self.center.y), CGAffineTransformInvert(self.transform));
                    
                    if (self.objectShadowStyle == 2)
                    {
                        CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), CGSizeMake(self.objectShadowOffset, self.objectShadowOffset), self.objectShadowBlur, self.objectShadowColor.CGColor);
                    }
                    
                    [image drawInRect:CGRectMake(pnt.x - self.bounds.size.width*0.5f - self.objectBorderWidth, pnt.y - self.bounds.size.height*0.5f - self.objectBorderWidth, self.bounds.size.width + self.objectBorderWidth*2, self.bounds.size.height+self.objectBorderWidth*2) blendMode:kCGBlendModeNormal alpha:1.0f];
                    
                    if (self.isReflection)
                    {
                        [reflectionImage drawInRect:CGRectMake(pnt.x - self.bounds.size.width*0.5f - self.objectBorderWidth, pnt.y + self.bounds.size.height*0.5f + self.reflectionGap, reflectionSize.width, reflectionSize.height) blendMode:kCGBlendModeNormal alpha:self.reflectionAlpha];
                    }
                    
                    CGContextConcatCTM(UIGraphicsGetCurrentContext(), CGAffineTransformInvert(self.transform));
                    image = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                }
                break;
            case 6: //circle dot line
                if (self.isImitationPhoto)
                {
                    UIGraphicsBeginImageContextWithOptions(self.superViewSize, NO, 2.0f);
                    CGContextConcatCTM(UIGraphicsGetCurrentContext(), self.transform);
                    pnt = CGPointApplyAffineTransform(CGPointMake(self.center.x, self.center.y), CGAffineTransformInvert(self.transform));
                    
                    if (self.objectShadowStyle == 2)
                    {
                        CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), CGSizeMake(self.objectShadowOffset, self.objectShadowOffset), self.objectShadowBlur, self.objectShadowColor.CGColor);
                    }
                    
                    CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(),  [self.objectBorderColor colorWithAlphaComponent:self.textView.alpha].CGColor);
                    
                    CGFloat circleDotLinePattern[] = {0.1f, 2.0f*self.objectBorderWidth};
                    CGContextSetLineDash(UIGraphicsGetCurrentContext(), 0.0f, circleDotLinePattern, 2);
                    
                    path = [self getBorderPath:pnt];
                    path.lineWidth = self.objectBorderWidth;
                    path.lineCapStyle = kCGLineCapRound;
                    path.lineJoinStyle = kCGLineJoinMiter;
                    [path stroke];
                    
                    CGContextConcatCTM(UIGraphicsGetCurrentContext(), CGAffineTransformInvert(self.transform));
                    image = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                }
                else
                {
                    UIGraphicsBeginImageContextWithOptions(CGSizeMake(self.textView.frame.size.width+self.objectBorderWidth*2, self.textView.frame.size.height+self.objectBorderWidth*2), NO, 2.0f);
                    [image drawInRect:CGRectMake(self.objectBorderWidth, self.objectBorderWidth, self.textView.frame.size.width, self.textView.frame.size.height)  blendMode:kCGBlendModeNormal alpha:1.0f];
                    
                    CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(),  [self.objectBorderColor colorWithAlphaComponent:self.textView.alpha].CGColor);
                    
                    CGFloat circleDotLinePattern[] = {0.1f, 2.0f*self.objectBorderWidth};
                    CGContextSetLineDash(UIGraphicsGetCurrentContext(), 0.0f, circleDotLinePattern, 2);
                    
                    path = [self getTextPatternBorderPath];
                    path.lineWidth = self.objectBorderWidth;
                    path.lineCapStyle = kCGLineCapRound;
                    path.lineJoinStyle = kCGLineJoinMiter;
                    [path stroke];
                    
                    image = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                    
                    reflectionSize = CGSizeMake(self.bounds.size.width + self.objectBorderWidth*2, (self.bounds.size.height + self.objectBorderWidth*2) * self.reflectionScale);
                    reflectionRect = CGRectMake(0.0f, 0.0f, self.bounds.size.width + self.objectBorderWidth*2, self.bounds.size.height+self.objectBorderWidth*2);
                    
                    if (self.isReflection)
                    {
                        reflectionImage = [self renderingReflectionImage:image size:reflectionSize rect:reflectionRect];
                    }
                    
                    UIGraphicsBeginImageContextWithOptions(self.superViewSize, NO, 2.0f);
                    CGContextConcatCTM(UIGraphicsGetCurrentContext(), self.transform);
                    pnt = CGPointApplyAffineTransform(CGPointMake(self.center.x, self.center.y), CGAffineTransformInvert(self.transform));
                    
                    if (self.objectShadowStyle == 2)
                    {
                        CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), CGSizeMake(self.objectShadowOffset, self.objectShadowOffset), self.objectShadowBlur, self.objectShadowColor.CGColor);
                    }
                    
                    [image drawInRect:CGRectMake(pnt.x - self.bounds.size.width*0.5f - self.objectBorderWidth, pnt.y - self.bounds.size.height*0.5f - self.objectBorderWidth, self.bounds.size.width + self.objectBorderWidth*2, self.bounds.size.height+self.objectBorderWidth*2) blendMode:kCGBlendModeNormal alpha:1.0f];
                    
                    if (self.isReflection)
                    {
                        [reflectionImage drawInRect:CGRectMake(pnt.x - self.bounds.size.width*0.5f - self.objectBorderWidth, pnt.y + self.bounds.size.height*0.5f + self.reflectionGap, reflectionSize.width, reflectionSize.height) blendMode:kCGBlendModeNormal alpha:self.reflectionAlpha];
                    }
                    
                    CGContextConcatCTM(UIGraphicsGetCurrentContext(), CGAffineTransformInvert(self.transform));
                    image = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                }
                break;
            case 7: //two dots line
            {
                UIGraphicsBeginImageContextWithOptions(CGSizeMake(self.textView.frame.size.width+self.objectBorderWidth*2, self.textView.frame.size.height+self.objectBorderWidth*2), NO, 2.0f);
                
                if (!self.isImitationPhoto)
                {
                    [image drawInRect:CGRectMake(self.objectBorderWidth, self.objectBorderWidth, self.textView.frame.size.width, self.textView.frame.size.height)  blendMode:kCGBlendModeNormal alpha:1.0f];
                }
                
                UIImage* borderImage = [UIImage imageNamed:@"dotline_pattern"];
                borderImage = [borderImage rescaleImageToSize:CGSizeMake(self.objectBorderWidth, self.objectBorderWidth)];
                borderImage = [borderImage imageWithOverlayColor:[self.objectBorderColor colorWithAlphaComponent:self.textView.alpha]];
                colorRef = [UIColor colorWithPatternImage:borderImage].CGColor;
                CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(),  colorRef);
                
                path = [self getTextPatternBorderPath];
                path.lineWidth = self.objectBorderWidth;
                [path stroke];
                
                image = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                
                reflectionSize = CGSizeMake(self.bounds.size.width + self.objectBorderWidth*2, (self.bounds.size.height + self.objectBorderWidth*2) * self.reflectionScale);
                reflectionRect = CGRectMake(0.0f, 0.0f, self.bounds.size.width + self.objectBorderWidth*2, self.bounds.size.height+self.objectBorderWidth*2);
                
                if (self.isReflection)
                {
                    reflectionImage = [self renderingReflectionImage:image size:reflectionSize rect:reflectionRect];
                }
                
                UIGraphicsBeginImageContextWithOptions(self.superViewSize, NO, 2.0f);
                CGContextConcatCTM(UIGraphicsGetCurrentContext(), self.transform);
                pnt = CGPointApplyAffineTransform(CGPointMake(self.center.x, self.center.y), CGAffineTransformInvert(self.transform));
                
                if (self.objectShadowStyle == 2)
                {
                    CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), CGSizeMake(self.objectShadowOffset, self.objectShadowOffset), self.objectShadowBlur, self.objectShadowColor.CGColor);
                }
                
                [image drawInRect:CGRectMake(pnt.x - self.bounds.size.width*0.5f - self.objectBorderWidth, pnt.y - self.bounds.size.height*0.5f - self.objectBorderWidth, self.bounds.size.width + self.objectBorderWidth*2, self.bounds.size.height+self.objectBorderWidth*2) blendMode:kCGBlendModeNormal alpha:1.0f];
                
                if (self.isReflection)
                {
                    [reflectionImage drawInRect:CGRectMake(pnt.x - self.bounds.size.width*0.5f - self.objectBorderWidth, pnt.y + self.bounds.size.height*0.5f + self.reflectionGap, reflectionSize.width, reflectionSize.height) blendMode:kCGBlendModeNormal alpha:self.reflectionAlpha];
                }
                
                CGContextConcatCTM(UIGraphicsGetCurrentContext(), CGAffineTransformInvert(self.transform));
                image = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
            }
                break;
            case 8: //jigsaw line
            {
                UIGraphicsBeginImageContextWithOptions(CGSizeMake(self.textView.frame.size.width+self.objectBorderWidth*2, self.textView.frame.size.height+self.objectBorderWidth*2), NO, 2.0f);
                
                if (!self.isImitationPhoto)
                {
                    [image drawInRect:CGRectMake(self.objectBorderWidth, self.objectBorderWidth, self.textView.frame.size.width, self.textView.frame.size.height)  blendMode:kCGBlendModeNormal alpha:1.0f];
                }
                
                UIImage* borderImage = [UIImage imageNamed:@"dotline_pattern"];
                borderImage = [borderImage imageWithOverlayColor:[self.objectBorderColor colorWithAlphaComponent:self.textView.alpha]];
                colorRef = [UIColor colorWithPatternImage:borderImage].CGColor;
                CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(),  colorRef);
                
                path = [self getTextPatternBorderPath];
                path.lineWidth = self.objectBorderWidth;
                [path stroke];
                
                image = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                
                reflectionSize = CGSizeMake(self.bounds.size.width + self.objectBorderWidth*2, (self.bounds.size.height + self.objectBorderWidth*2) * self.reflectionScale);
                reflectionRect = CGRectMake(0.0f, 0.0f, self.bounds.size.width + self.objectBorderWidth*2, self.bounds.size.height+self.objectBorderWidth*2);
                
                if (self.isReflection)
                {
                    reflectionImage = [self renderingReflectionImage:image size:reflectionSize rect:reflectionRect];
                }
                
                UIGraphicsBeginImageContextWithOptions(self.superViewSize, NO, 2.0f);
                CGContextConcatCTM(UIGraphicsGetCurrentContext(), self.transform);
                pnt = CGPointApplyAffineTransform(CGPointMake(self.center.x, self.center.y), CGAffineTransformInvert(self.transform));
                
                if (self.objectShadowStyle == 2)
                {
                    CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), CGSizeMake(self.objectShadowOffset, self.objectShadowOffset), self.objectShadowBlur, self.objectShadowColor.CGColor);
                }
                
                [image drawInRect:CGRectMake(pnt.x - self.bounds.size.width*0.5f - self.objectBorderWidth, pnt.y - self.bounds.size.height*0.5f - self.objectBorderWidth, self.bounds.size.width + self.objectBorderWidth*2, self.bounds.size.height+self.objectBorderWidth*2) blendMode:kCGBlendModeNormal alpha:1.0f];
                
                if (self.isReflection)
                {
                    [reflectionImage drawInRect:CGRectMake(pnt.x - self.bounds.size.width*0.5f - self.objectBorderWidth, pnt.y + self.bounds.size.height*0.5f + self.reflectionGap, reflectionSize.width, reflectionSize.height) blendMode:kCGBlendModeNormal alpha:self.reflectionAlpha];
                }
                
                CGContextConcatCTM(UIGraphicsGetCurrentContext(), CGAffineTransformInvert(self.transform));
                image = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
            }
                break;
            case 9: //flower line
            {
                UIGraphicsBeginImageContextWithOptions(CGSizeMake(self.textView.frame.size.width+self.objectBorderWidth*2, self.textView.frame.size.height+self.objectBorderWidth*2), NO, 2.0f);
                
                if (!self.isImitationPhoto)
                {
                    [image drawInRect:CGRectMake(self.objectBorderWidth, self.objectBorderWidth, self.textView.frame.size.width, self.textView.frame.size.height)  blendMode:kCGBlendModeNormal alpha:1.0f];
                }
                
                UIImage* borderImage = [UIImage imageNamed:@"flower"];
                borderImage = [borderImage rescaleImageToSize:CGSizeMake(self.objectBorderWidth, self.objectBorderWidth)];
                borderImage = [borderImage imageWithOverlayColor:[self.objectBorderColor colorWithAlphaComponent:self.textView.alpha]];
                colorRef = [UIColor colorWithPatternImage:borderImage].CGColor;
                CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(),  colorRef);
                
                path = [self getTextPatternBorderPath];
                path.lineWidth = self.objectBorderWidth;
                [path stroke];
                
                image = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                
                reflectionSize = CGSizeMake(self.bounds.size.width + self.objectBorderWidth*2, (self.bounds.size.height + self.objectBorderWidth*2) * self.reflectionScale);
                reflectionRect = CGRectMake(0.0f, 0.0f, self.bounds.size.width + self.objectBorderWidth*2, self.bounds.size.height+self.objectBorderWidth*2);
                
                if (self.isReflection)
                {
                    reflectionImage = [self renderingReflectionImage:image size:reflectionSize rect:reflectionRect];
                }
                
                UIGraphicsBeginImageContextWithOptions(self.superViewSize, NO, 2.0f);
                CGContextConcatCTM(UIGraphicsGetCurrentContext(), self.transform);
                pnt = CGPointApplyAffineTransform(CGPointMake(self.center.x, self.center.y), CGAffineTransformInvert(self.transform));
                
                if (self.objectShadowStyle == 2)
                {
                    CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), CGSizeMake(self.objectShadowOffset, self.objectShadowOffset), self.objectShadowBlur, self.objectShadowColor.CGColor);
                }
                
                [image drawInRect:CGRectMake(pnt.x - self.bounds.size.width*0.5f - self.objectBorderWidth, pnt.y - self.bounds.size.height*0.5f - self.objectBorderWidth, self.bounds.size.width + self.objectBorderWidth*2, self.bounds.size.height+self.objectBorderWidth*2) blendMode:kCGBlendModeNormal alpha:1.0f];
                
                if (self.isReflection)
                {
                    [reflectionImage drawInRect:CGRectMake(pnt.x - self.bounds.size.width*0.5f - self.objectBorderWidth, pnt.y + self.bounds.size.height*0.5f + self.reflectionGap, reflectionSize.width, reflectionSize.height) blendMode:kCGBlendModeNormal alpha:self.reflectionAlpha];
                }
                
                CGContextConcatCTM(UIGraphicsGetCurrentContext(), CGAffineTransformInvert(self.transform));
                image = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
            }
                break;
            case 10: //black circle line
            {
                UIGraphicsBeginImageContextWithOptions(CGSizeMake(self.textView.frame.size.width+self.objectBorderWidth*2, self.textView.frame.size.height+self.objectBorderWidth*2), NO, 2.0f);
                
                if (!self.isImitationPhoto)
                {
                    [image drawInRect:CGRectMake(self.objectBorderWidth, self.objectBorderWidth, self.textView.frame.size.width, self.textView.frame.size.height)  blendMode:kCGBlendModeNormal alpha:1.0f];
                }
                
                UIImage* borderImage = [UIImage imageNamed:@"circle"];
                borderImage = [borderImage rescaleImageToSize:CGSizeMake(self.objectBorderWidth, self.objectBorderWidth)];
                borderImage = [borderImage imageWithOverlayColor:[self.objectBorderColor colorWithAlphaComponent:self.textView.alpha]];
                colorRef = [UIColor colorWithPatternImage:borderImage].CGColor;
                CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(),  colorRef);
                
                path = [self getTextPatternBorderPath];
                path.lineWidth = self.objectBorderWidth;
                [path stroke];
                
                image = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                
                reflectionSize = CGSizeMake(self.bounds.size.width + self.objectBorderWidth*2, (self.bounds.size.height + self.objectBorderWidth*2) * self.reflectionScale);
                reflectionRect = CGRectMake(0.0f, 0.0f, self.bounds.size.width + self.objectBorderWidth*2, self.bounds.size.height+self.objectBorderWidth*2);
                
                if (self.isReflection)
                {
                    reflectionImage = [self renderingReflectionImage:image size:reflectionSize rect:reflectionRect];
                }
                
                UIGraphicsBeginImageContextWithOptions(self.superViewSize, NO, 2.0f);
                CGContextConcatCTM(UIGraphicsGetCurrentContext(), self.transform);
                pnt = CGPointApplyAffineTransform(CGPointMake(self.center.x, self.center.y), CGAffineTransformInvert(self.transform));
                
                if (self.objectShadowStyle == 2)
                {
                    CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), CGSizeMake(self.objectShadowOffset, self.objectShadowOffset), self.objectShadowBlur, self.objectShadowColor.CGColor);
                }
                
                [image drawInRect:CGRectMake(pnt.x - self.bounds.size.width*0.5f - self.objectBorderWidth, pnt.y - self.bounds.size.height*0.5f - self.objectBorderWidth, self.bounds.size.width + self.objectBorderWidth*2, self.bounds.size.height+self.objectBorderWidth*2) blendMode:kCGBlendModeNormal alpha:1.0f];
                
                if (self.isReflection)
                {
                    [reflectionImage drawInRect:CGRectMake(pnt.x - self.bounds.size.width*0.5f - self.objectBorderWidth, pnt.y + self.bounds.size.height*0.5f + self.reflectionGap, reflectionSize.width, reflectionSize.height) blendMode:kCGBlendModeNormal alpha:self.reflectionAlpha];
                }
                
                CGContextConcatCTM(UIGraphicsGetCurrentContext(), CGAffineTransformInvert(self.transform));
                image = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
            }
                break;
        }
    }
    
    return image;
}

#pragma mark -
#pragma mark - rendering imageView for inputing to a new video.

-(UIImage*) renderingImageView
{
    CGSize imageSize = self.imageView.image.size;
    CGSize originalBoundSize = self.originalBounds.size;
    CGSize boundsSize = CGSizeZero;
    CGAffineTransform videoTransform = self.transform;

    UIImage* image = nil;

    if (self.mediaUrl)
    {
        boundsSize = self.bounds.size;
        CGFloat cropOriginX = (-1.0f)*self.videoView.frame.origin.x * imageSize.width / self.videoView.frame.size.width;
        CGFloat cropOriginY = (-1.0f)*self.videoView.frame.origin.y * imageSize.height / self.videoView.frame.size.height;
        CGFloat cropWidth = self.bounds.size.width * imageSize.width / self.videoView.frame.size.width;
        CGFloat cropHeight = self.bounds.size.height * imageSize.height / self.videoView.frame.size.height;
        CGRect cropRect = CGRectMake(cropOriginX, cropOriginY, cropWidth, cropHeight);

        image = [self.imageView.image cropImageToRect:cropRect];
    }
    else
    {
        boundsSize = self.bounds.size;
        CGFloat cropOriginX = (-1.0f)*self.imageView.frame.origin.x * imageSize.width / self.imageView.frame.size.width;
        CGFloat cropOriginY = (-1.0f)*self.imageView.frame.origin.y * imageSize.height / self.imageView.frame.size.height;
        CGFloat cropWidth = self.bounds.size.width * imageSize.width / self.imageView.frame.size.width;
        CGFloat cropHeight = self.bounds.size.height * imageSize.height / self.imageView.frame.size.height;
        CGRect cropRect = CGRectMake(cropOriginX, cropOriginY, cropWidth, cropHeight);

        image = [self.imageView.image cropImageToRect:cropRect];
    }

    if (self.isShape)
    {
        if (self.bounds.size.width >= self.bounds.size.height)
            imageSize = CGSizeMake(image.size.width, image.size.width*(self.bounds.size.height/self.bounds.size.width));
        else
            imageSize = CGSizeMake(image.size.height*(self.bounds.size.width/self.bounds.size.height), image.size.height);

        image = [image rescaleImageToSize:imageSize];
    }

    if (self.objectCornerRadius != 0.0f)
        image = [self renderImageWithCorner:image];

    CGColorRef colorRef = nil;
    CGPoint pnt = CGPointZero;
    UIBezierPath* path;
    UIImage* reflectionImage = nil;
    UIImage* gradientImage = nil;

    switch (self.objectBorderStyle)
    {
        case 1: //no outline
            if (self.isImitationPhoto)
            {
                if (self.isReflection)
                {
                    //reflection image
                    CGSize reflectionSize = CGSizeMake(boundsSize.width, boundsSize.height * self.reflectionScale);
                    CGRect reflectionRect = CGRectMake(0.0f, 0.0f, boundsSize.width, boundsSize.height);
                    reflectionImage = [self renderingReflectionImage:image size:reflectionSize rect:reflectionRect];

                    //gradient mask
                    UIGraphicsBeginImageContextWithOptions(CGSizeMake(boundsSize.width, boundsSize.height * self.reflectionScale), YES, 0.0f);
                    CGContextRef gradientContext = UIGraphicsGetCurrentContext();
                    CGFloat colors[] = {1.0f, 1.0f, 0.0f, 0.5f};
                    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
                    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, colors, NULL, 2);
                    CGPoint gradientStartPoint = CGPointMake(0.0f, 0.0f);
                    CGPoint gradientEndPoint = CGPointMake(0.0f, boundsSize.height * self.reflectionScale);
                    CGContextDrawLinearGradient(gradientContext, gradient, gradientStartPoint,
                                                gradientEndPoint, kCGGradientDrawsAfterEndLocation);
                    CGImageRef gradientMask = CGBitmapContextCreateImage(gradientContext);
                    CGGradientRelease(gradient);
                    CGColorSpaceRelease(colorSpace);
                    UIGraphicsEndImageContext();

                    //gradient image
                    UIGraphicsBeginImageContextWithOptions(CGSizeMake(boundsSize.width, boundsSize.height * self.reflectionScale), NO, 0.0f);
                    CGContextRef context = UIGraphicsGetCurrentContext();
                    CGContextClipToMask(context, CGRectMake(0.0f, 0.0f,
                                                            boundsSize.width, boundsSize.height * self.reflectionScale), gradientMask);
                    CGImageRelease(gradientMask);
                    CGContextSetFillColorWithColor(context, [[UIColor blackColor] colorWithAlphaComponent:self.imageView.alpha].CGColor);
                    CGContextFillRect(context, CGRectMake(0.0f, 0.0f,
                                                          boundsSize.width, boundsSize.height * self.reflectionScale));
                    gradientImage = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                }

                UIGraphicsBeginImageContextWithOptions(self.superViewSize, NO, 2.0f);
                CGContextRef context = UIGraphicsGetCurrentContext();

                CGContextConcatCTM(UIGraphicsGetCurrentContext(), videoTransform);
                pnt = CGPointApplyAffineTransform(CGPointMake(self.center.x, self.center.y), CGAffineTransformInvert(videoTransform));

                //draw black background
                CGContextSetFillColorWithColor(context, [self.objectChromaColor colorWithAlphaComponent:self.imageView.alpha].CGColor);
                if (self.isReflection)
                    CGContextFillRect(context, CGRectMake(pnt.x - boundsSize.width*0.5f - 2.0f, pnt.y - boundsSize.height*0.5f - 2.0f, boundsSize.width + 4.0f, boundsSize.height * (1.0f + self.reflectionScale) + 4.0f + self.reflectionGap));
                else
                    CGContextFillRect(context, CGRectMake(pnt.x - boundsSize.width*0.5f - 2.0f, pnt.y - boundsSize.height*0.5f - 2.0f, boundsSize.width + 4.0f, boundsSize.height + 4.0f));

                CGContextSaveGState(context);

                //shadow
                if (self.objectShadowStyle == 2)
                    CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), CGSizeMake(self.objectShadowOffset, self.objectShadowOffset), self.objectShadowBlur, self.objectShadowColor.CGColor);

                //draw image
                [image drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f, pnt.y - boundsSize.height*0.5f, boundsSize.width, boundsSize.height) blendMode:kCGBlendModeNormal alpha:self.imageView.alpha];

                if (self.isReflection)
                    [reflectionImage drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f, pnt.y + boundsSize.height*0.5f + self.reflectionGap, boundsSize.width, boundsSize.height * self.reflectionScale) blendMode:kCGBlendModeNormal alpha:1.0f];

                //erase inner of path
                path = [self getErasePath:pnt];
                CGContextAddPath(context, path.CGPath);
                CGContextSetBlendMode(context, kCGBlendModeClear);
                CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
                CGContextFillPath(context);
                CGContextRestoreGState(context);

                if (self.isReflection)
                {
                    path = [self getErasePath:CGPointMake(pnt.x, pnt.y + boundsSize.height + self.reflectionGap)];
                    CGContextAddPath(context, path.CGPath);
                    CGContextSetBlendMode(context, kCGBlendModeClear);
                    CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
                    CGContextFillPath(context);

                    //black gradient
                    [gradientImage drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f, pnt.y + boundsSize.height*0.5f + self.reflectionGap, boundsSize.width, boundsSize.height * self.reflectionScale) blendMode:kCGBlendModeNormal alpha:1.0f];
                }

                CGContextConcatCTM(UIGraphicsGetCurrentContext(), CGAffineTransformInvert(videoTransform));
                image = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
            }
            else
            {
                CGSize reflectionSize = CGSizeMake(boundsSize.width, boundsSize.height * self.reflectionScale);
                CGRect reflectionRect = CGRectMake(0.0f, 0.0f, boundsSize.width, boundsSize.height);

                if (self.isReflection)
                    reflectionImage = [self renderingReflectionImage:image size:reflectionSize rect:reflectionRect];

                UIGraphicsBeginImageContextWithOptions(self.superViewSize, NO, 2.0f);
                CGContextConcatCTM(UIGraphicsGetCurrentContext(), videoTransform);
                pnt = CGPointApplyAffineTransform(CGPointMake(self.center.x, self.center.y), CGAffineTransformInvert(videoTransform));

                if (self.objectShadowStyle == 2)
                    CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), CGSizeMake(self.objectShadowOffset, self.objectShadowOffset), self.objectShadowBlur, self.objectShadowColor.CGColor);

                [image drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f, pnt.y - boundsSize.height*0.5f, boundsSize.width, boundsSize.height) blendMode:kCGBlendModeNormal alpha:self.imageView.alpha];

                if (self.isReflection)
                    [reflectionImage drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f, pnt.y + boundsSize.height*0.5f + self.reflectionGap, reflectionSize.width, reflectionSize.height) blendMode:kCGBlendModeNormal alpha:self.reflectionAlpha];

                CGContextConcatCTM(UIGraphicsGetCurrentContext(), CGAffineTransformInvert(videoTransform));
                image = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
            }
            break;
        case 2: //line
            if (self.isImitationPhoto)
            {
                UIGraphicsBeginImageContextWithOptions(CGSizeMake(image.size.width + self.objectBorderWidth*imageSize.width/originalBoundSize.width*2, image.size.height + self.objectBorderWidth*imageSize.width/originalBoundSize.width*2), NO, 2.0f);
                [image drawInRect:CGRectMake(self.objectBorderWidth*imageSize.width/originalBoundSize.width, self.objectBorderWidth*imageSize.width/originalBoundSize.width, image.size.width, image.size.height) blendMode:kCGBlendModeNormal alpha:1.0f];

                CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(),  [self.objectBorderColor colorWithAlphaComponent:self.imageView.alpha].CGColor);

                path = [self getPatternBorderPath:image.size];
                path.lineWidth = self.objectBorderWidth*imageSize.width/originalBoundSize.width;
                [path stroke];

                image = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();

                if (self.isReflection)
                {
                    CGSize reflectionSize = CGSizeMake(boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale);
                    CGRect reflectionRect = CGRectMake(0.0f, 0.0f, boundsSize.width + self.objectBorderWidth*2, boundsSize.height + self.objectBorderWidth*2);
                    reflectionImage = [self renderingReflectionImage:image size:reflectionSize rect:reflectionRect];

                    //gradient mask
                    UIGraphicsBeginImageContextWithOptions(CGSizeMake(boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale), YES, 0.0f);
                    CGContextRef gradientContext = UIGraphicsGetCurrentContext();
                    CGFloat colors[] = {1.0f, 1.0f, 0.0f, 1.0f};
                    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
                    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, colors, NULL, 2);
                    CGPoint gradientStartPoint = CGPointMake(0.0f, 0.0f);
                    CGPoint gradientEndPoint = CGPointMake(0.0f, (boundsSize.height*self.reflectionScale) + self.objectBorderWidth*2);
                    CGContextDrawLinearGradient(gradientContext, gradient, gradientStartPoint,
                                                gradientEndPoint, kCGGradientDrawsAfterEndLocation);
                    CGImageRef gradientMask = CGBitmapContextCreateImage(gradientContext);
                    CGGradientRelease(gradient);
                    CGColorSpaceRelease(colorSpace);
                    UIGraphicsEndImageContext();

                    //gradient image
                    UIGraphicsBeginImageContextWithOptions(CGSizeMake(boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale), NO, 0.0f);
                    CGContextRef context = UIGraphicsGetCurrentContext();
                    CGContextClipToMask(context, CGRectMake(0.0f, 0.0f,
                                                            boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale), gradientMask);
                    CGImageRelease(gradientMask);
                    CGContextSetFillColorWithColor(context, [[UIColor blackColor] colorWithAlphaComponent:self.imageView.alpha].CGColor);
                    CGContextFillRect(context, CGRectMake(0.0f, 0.0f,
                                                          boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale));
                    gradientImage = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                }

                UIGraphicsBeginImageContextWithOptions(self.superViewSize, NO, 2.0f);
                CGContextRef context = UIGraphicsGetCurrentContext();

                CGContextConcatCTM(UIGraphicsGetCurrentContext(), videoTransform);
                pnt = CGPointApplyAffineTransform(CGPointMake(self.center.x, self.center.y), CGAffineTransformInvert(videoTransform));

                //draw black background
                CGContextSetFillColorWithColor(context, [self.objectChromaColor colorWithAlphaComponent:self.imageView.alpha].CGColor);

                if (self.isReflection)
                {
                    CGContextFillRect(context, CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y - boundsSize.height*0.5f - self.objectBorderWidth, boundsSize.width + self.objectBorderWidth*2, boundsSize.height * (1.0f + self.reflectionScale) + self.objectBorderWidth*2 + self.reflectionGap));
                }
                else
                {
                    CGContextFillRect(context, CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y - boundsSize.height*0.5f - self.objectBorderWidth, boundsSize.width + self.objectBorderWidth*2, boundsSize.height + self.objectBorderWidth*2));
                }

                CGContextSaveGState(context);

                //shadow
                if (self.objectShadowStyle == 2)
                    CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), CGSizeMake(self.objectShadowOffset, self.objectShadowOffset), self.objectShadowBlur, self.objectShadowColor.CGColor);

                //draw image
                [image drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y - boundsSize.height*0.5f - self.objectBorderWidth, boundsSize.width + self.objectBorderWidth*2, boundsSize.height + self.objectBorderWidth*2) blendMode:kCGBlendModeNormal alpha:1.0f];

                if (self.isReflection)
                    [reflectionImage drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y + boundsSize.height*0.5f - self.objectBorderWidth + self.reflectionGap, boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale) blendMode:kCGBlendModeNormal alpha:1.0f];

                //erase inner of path
                path = [self getErasePath:pnt];
                CGContextAddPath(context, path.CGPath);
                CGContextSetBlendMode(context, kCGBlendModeClear);
                CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
                CGContextFillPath(context);
                CGContextRestoreGState(context);

                if (self.isReflection)
                {
                    path = [self getErasePath:CGPointMake(pnt.x, pnt.y + boundsSize.height + self.reflectionGap)];
                    CGContextAddPath(context, path.CGPath);
                    CGContextSetBlendMode(context, kCGBlendModeClear);
                    CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
                    CGContextFillPath(context);

                    //black gradient
                    [gradientImage drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y + boundsSize.height*0.5f + self.reflectionGap, boundsSize.width + self.objectBorderWidth*2, boundsSize.height*self.reflectionScale + self.objectBorderWidth*2) blendMode:kCGBlendModeNormal alpha:1.0f];
                }

                CGContextConcatCTM(UIGraphicsGetCurrentContext(), CGAffineTransformInvert(videoTransform));
                image = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
            }
            else
            {
                UIGraphicsBeginImageContextWithOptions(CGSizeMake(image.size.width+self.objectBorderWidth*imageSize.width/originalBoundSize.width*2, image.size.height+self.objectBorderWidth*imageSize.width/originalBoundSize.width*2), NO, 2.0f);
                [image drawInRect:CGRectMake(self.objectBorderWidth*imageSize.width/originalBoundSize.width, self.objectBorderWidth*imageSize.width/originalBoundSize.width, image.size.width, image.size.height) blendMode:kCGBlendModeNormal alpha:self.imageView.alpha];

                CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(),  [self.objectBorderColor colorWithAlphaComponent:self.imageView.alpha].CGColor);

                path = [self getPatternBorderPath:image.size];
                path.lineWidth = self.objectBorderWidth*imageSize.width/originalBoundSize.width;
                [path stroke];

                image = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();

                CGSize reflectionSize = CGSizeMake(boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2) * self.reflectionScale);
                CGRect reflectionRect = CGRectMake(0.0f, 0.0f, boundsSize.width + self.objectBorderWidth*2, boundsSize.height+self.objectBorderWidth*2);

                if (self.isReflection)
                    reflectionImage = [self renderingReflectionImage:image size:reflectionSize rect:reflectionRect];

                UIGraphicsBeginImageContextWithOptions(self.superViewSize, NO, 2.0f);
                CGContextConcatCTM(UIGraphicsGetCurrentContext(), videoTransform);
                pnt = CGPointApplyAffineTransform(CGPointMake(self.center.x, self.center.y), CGAffineTransformInvert(videoTransform));

                if (self.objectShadowStyle == 2)
                    CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), CGSizeMake(self.objectShadowOffset, self.objectShadowOffset), self.objectShadowBlur, self.objectShadowColor.CGColor);

                [image drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y - boundsSize.height*0.5f - self.objectBorderWidth, boundsSize.width + self.objectBorderWidth*2, boundsSize.height+self.objectBorderWidth*2) blendMode:kCGBlendModeNormal alpha:1.0f];

                if (self.isReflection)
                    [reflectionImage drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y + boundsSize.height*0.5f + self.reflectionGap, reflectionSize.width, reflectionSize.height) blendMode:kCGBlendModeNormal alpha:self.reflectionAlpha];

                CGContextConcatCTM(UIGraphicsGetCurrentContext(), CGAffineTransformInvert(videoTransform));
                image = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
            }
            break;
        case 3: //shot dot line
            if (self.isImitationPhoto)
            {
                UIGraphicsBeginImageContextWithOptions(CGSizeMake(image.size.width + self.objectBorderWidth*imageSize.width/originalBoundSize.width*2, image.size.height + self.objectBorderWidth*imageSize.width/originalBoundSize.width*2), NO, 2.0f);
                [image drawInRect:CGRectMake(self.objectBorderWidth*imageSize.width/originalBoundSize.width, self.objectBorderWidth*imageSize.width/originalBoundSize.width, image.size.width, image.size.height) blendMode:kCGBlendModeNormal alpha:1.0f];

                CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(),  [self.objectBorderColor colorWithAlphaComponent:self.imageView.alpha].CGColor);

                CGFloat pattern[] = {self.objectBorderWidth, self.objectBorderWidth};
                CGContextSetLineDash(UIGraphicsGetCurrentContext(), 0.0f, pattern, 2);

                path = [self getPatternBorderPath:image.size];
                path.lineWidth = self.objectBorderWidth;
                path.lineCapStyle = kCGLineCapButt;
                path.lineJoinStyle = kCGLineJoinMiter;
                [path stroke];

                image = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();

                if (self.isReflection)
                {
                    CGSize reflectionSize = CGSizeMake(boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale);
                    CGRect reflectionRect = CGRectMake(0.0f, 0.0f, boundsSize.width + self.objectBorderWidth*2, boundsSize.height + self.objectBorderWidth*2);
                    reflectionImage = [self renderingReflectionImage:image size:reflectionSize rect:reflectionRect];

                    //gradient mask
                    UIGraphicsBeginImageContextWithOptions(CGSizeMake(boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale), YES, 0.0f);
                    CGContextRef gradientContext = UIGraphicsGetCurrentContext();
                    CGFloat colors[] = {1.0f, 1.0f, 0.0f, 1.0f};
                    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
                    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, colors, NULL, 2);
                    CGPoint gradientStartPoint = CGPointMake(0.0f, 0.0f);
                    CGPoint gradientEndPoint = CGPointMake(0.0f, (boundsSize.height*self.reflectionScale) + self.objectBorderWidth*2);
                    CGContextDrawLinearGradient(gradientContext, gradient, gradientStartPoint,
                                                gradientEndPoint, kCGGradientDrawsAfterEndLocation);
                    CGImageRef gradientMask = CGBitmapContextCreateImage(gradientContext);
                    CGGradientRelease(gradient);
                    CGColorSpaceRelease(colorSpace);
                    UIGraphicsEndImageContext();

                    //gradient image
                    UIGraphicsBeginImageContextWithOptions(CGSizeMake(boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale), NO, 0.0f);
                    CGContextRef context = UIGraphicsGetCurrentContext();
                    CGContextClipToMask(context, CGRectMake(0.0f, 0.0f,
                                                            boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale), gradientMask);
                    CGImageRelease(gradientMask);
                    CGContextSetFillColorWithColor(context, [[UIColor blackColor] colorWithAlphaComponent:self.imageView.alpha].CGColor);
                    CGContextFillRect(context, CGRectMake(0.0f, 0.0f,
                                                          boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale));
                    gradientImage = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                }

                UIGraphicsBeginImageContextWithOptions(self.superViewSize, NO, 2.0f);
                CGContextRef context = UIGraphicsGetCurrentContext();
                CGContextConcatCTM(UIGraphicsGetCurrentContext(), videoTransform);
                pnt = CGPointApplyAffineTransform(CGPointMake(self.center.x, self.center.y), CGAffineTransformInvert(videoTransform));
                CGContextSetFillColorWithColor(context, [self.objectChromaColor colorWithAlphaComponent:self.imageView.alpha].CGColor);

                if (self.isReflection)
                {
                    CGContextFillRect(context, CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y - boundsSize.height*0.5f - self.objectBorderWidth, boundsSize.width + self.objectBorderWidth*2, boundsSize.height * (1.0f + self.reflectionScale) + self.objectBorderWidth*2 + self.reflectionGap));
                }
                else
                {
                    CGContextFillRect(context, CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y - boundsSize.height*0.5f - self.objectBorderWidth, boundsSize.width + self.objectBorderWidth*2, boundsSize.height + self.objectBorderWidth*2));
                }

                CGContextSaveGState(context);

                //shadow
                if (self.objectShadowStyle == 2)
                {
                    CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), CGSizeMake(self.objectShadowOffset, self.objectShadowOffset), self.objectShadowBlur, self.objectShadowColor.CGColor);
                }

                //draw image
                [image drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y - boundsSize.height*0.5f - self.objectBorderWidth, boundsSize.width + self.objectBorderWidth*2, boundsSize.height + self.objectBorderWidth*2) blendMode:kCGBlendModeNormal alpha:1.0f];

                if (self.isReflection)
                {
                    [reflectionImage drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y + boundsSize.height*0.5f - self.objectBorderWidth + self.reflectionGap, boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale) blendMode:kCGBlendModeNormal alpha:1.0f];
                }

                //erase inner of path
                path = [self getErasePath:pnt];
                CGContextAddPath(context, path.CGPath);
                CGContextSetBlendMode(context, kCGBlendModeClear);
                CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
                CGContextFillPath(context);
                CGContextRestoreGState(context);

                if (self.isReflection)
                {
                    path = [self getErasePath:CGPointMake(pnt.x, pnt.y + boundsSize.height + self.reflectionGap)];
                    CGContextAddPath(context, path.CGPath);
                    CGContextSetBlendMode(context, kCGBlendModeClear);
                    CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
                    CGContextFillPath(context);

                    //black gradient
                    [gradientImage drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y + boundsSize.height*0.5f + self.reflectionGap, boundsSize.width + self.objectBorderWidth*2, boundsSize.height*self.reflectionScale + self.objectBorderWidth*2) blendMode:kCGBlendModeNormal alpha:1.0f];
                }

                CGContextConcatCTM(UIGraphicsGetCurrentContext(), CGAffineTransformInvert(videoTransform));
                image = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
            }
            else
            {
                UIGraphicsBeginImageContextWithOptions(CGSizeMake(image.size.width+self.objectBorderWidth*imageSize.width/originalBoundSize.width*2, image.size.height+self.objectBorderWidth*imageSize.width/originalBoundSize.width*2), NO, 2.0f);
                [image drawInRect:CGRectMake(self.objectBorderWidth*imageSize.width/originalBoundSize.width, self.objectBorderWidth*imageSize.width/originalBoundSize.width, image.size.width, image.size.height) blendMode:kCGBlendModeNormal alpha:self.imageView.alpha];

                CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(),  [self.objectBorderColor colorWithAlphaComponent:self.imageView.alpha].CGColor);

                CGFloat pattern[] = {self.objectBorderWidth, self.objectBorderWidth};
                CGContextSetLineDash(UIGraphicsGetCurrentContext(), 0.0f, pattern, 2);

                path = [self getPatternBorderPath:image.size];
                path.lineWidth = self.objectBorderWidth*imageSize.width/originalBoundSize.width;
                path.lineCapStyle = kCGLineCapButt;
                path.lineJoinStyle = kCGLineJoinMiter;
                [path stroke];

                image = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();

                CGSize reflectionSize = CGSizeMake(boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2) * self.reflectionScale);
                CGRect reflectionRect = CGRectMake(0.0f, 0.0f, boundsSize.width + self.objectBorderWidth*2, boundsSize.height+self.objectBorderWidth*2);

                if (self.isReflection)
                {
                    reflectionImage = [self renderingReflectionImage:image size:reflectionSize rect:reflectionRect];
                }

                UIGraphicsBeginImageContextWithOptions(self.superViewSize, NO, 2.0f);
                CGContextConcatCTM(UIGraphicsGetCurrentContext(), videoTransform);
                pnt = CGPointApplyAffineTransform(CGPointMake(self.center.x, self.center.y), CGAffineTransformInvert(videoTransform));

                if (self.objectShadowStyle == 2)
                {
                    CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), CGSizeMake(self.objectShadowOffset, self.objectShadowOffset), self.objectShadowBlur, self.objectShadowColor.CGColor);
                }

                [image drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y - boundsSize.height*0.5f - self.objectBorderWidth, boundsSize.width + self.objectBorderWidth*2, boundsSize.height+self.objectBorderWidth*2) blendMode:kCGBlendModeNormal alpha:1.0f];

                if (self.isReflection)
                {
                    [reflectionImage drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y + boundsSize.height*0.5f + self.reflectionGap, reflectionSize.width, reflectionSize.height) blendMode:kCGBlendModeNormal alpha:self.reflectionAlpha];
                }

                CGContextConcatCTM(UIGraphicsGetCurrentContext(), CGAffineTransformInvert(videoTransform));
                image = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
            }
            break;
        case 4: //middle dot line
            if (self.isImitationPhoto)
            {
                UIGraphicsBeginImageContextWithOptions(CGSizeMake(image.size.width + self.objectBorderWidth*imageSize.width/originalBoundSize.width*2, image.size.height + self.objectBorderWidth*imageSize.width/originalBoundSize.width*2), NO, 2.0f);
                [image drawInRect:CGRectMake(self.objectBorderWidth*imageSize.width/originalBoundSize.width, self.objectBorderWidth*imageSize.width/originalBoundSize.width, image.size.width, image.size.height) blendMode:kCGBlendModeNormal alpha:1.0f];

                CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(),  [self.objectBorderColor colorWithAlphaComponent:self.imageView.alpha].CGColor);

                CGFloat middleDotLinePattern[] = {1.5f*self.objectBorderWidth, 1.5f*self.objectBorderWidth};
                CGContextSetLineDash(UIGraphicsGetCurrentContext(), 0.0f, middleDotLinePattern, 2);

                path = [self getPatternBorderPath:image.size];
                path.lineWidth = self.objectBorderWidth;
                path.lineCapStyle = kCGLineCapButt;
                path.lineJoinStyle = kCGLineJoinMiter;
                [path stroke];

                image = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();

                if (self.isReflection)
                {
                    //reflection image
                    CGSize reflectionSize = CGSizeMake(boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale);
                    CGRect reflectionRect = CGRectMake(0.0f, 0.0f, boundsSize.width + self.objectBorderWidth*2, boundsSize.height + self.objectBorderWidth*2);
                    reflectionImage = [self renderingReflectionImage:image size:reflectionSize rect:reflectionRect];

                    //gradient mask
                    UIGraphicsBeginImageContextWithOptions(CGSizeMake(boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale), YES, 0.0f);
                    CGContextRef gradientContext = UIGraphicsGetCurrentContext();
                    CGFloat colors[] = {1.0f, 1.0f, 0.0f, 1.0f};
                    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
                    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, colors, NULL, 2);
                    CGPoint gradientStartPoint = CGPointMake(0.0f, 0.0f);
                    CGPoint gradientEndPoint = CGPointMake(0.0f, (boundsSize.height*self.reflectionScale) + self.objectBorderWidth*2);
                    CGContextDrawLinearGradient(gradientContext, gradient, gradientStartPoint,
                                                gradientEndPoint, kCGGradientDrawsAfterEndLocation);
                    CGImageRef gradientMask = CGBitmapContextCreateImage(gradientContext);
                    CGGradientRelease(gradient);
                    CGColorSpaceRelease(colorSpace);
                    UIGraphicsEndImageContext();

                    //gradient image
                    UIGraphicsBeginImageContextWithOptions(CGSizeMake(boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale), NO, 0.0f);
                    CGContextRef context = UIGraphicsGetCurrentContext();
                    CGContextClipToMask(context, CGRectMake(0.0f, 0.0f,
                                                            boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale), gradientMask);
                    CGImageRelease(gradientMask);
                    CGContextSetFillColorWithColor(context, [[UIColor blackColor] colorWithAlphaComponent:self.imageView.alpha].CGColor);
                    CGContextFillRect(context, CGRectMake(0.0f, 0.0f,
                                                          boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale));
                    gradientImage = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                }

                UIGraphicsBeginImageContextWithOptions(self.superViewSize, NO, 2.0f);
                CGContextRef context = UIGraphicsGetCurrentContext();

                CGContextConcatCTM(UIGraphicsGetCurrentContext(), videoTransform);
                pnt = CGPointApplyAffineTransform(CGPointMake(self.center.x, self.center.y), CGAffineTransformInvert(videoTransform));

                //draw black background
                CGContextSetFillColorWithColor(context, [self.objectChromaColor colorWithAlphaComponent:self.imageView.alpha].CGColor);

                if (self.isReflection)
                {
                    CGContextFillRect(context, CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y - boundsSize.height*0.5f - self.objectBorderWidth, boundsSize.width + self.objectBorderWidth*2, boundsSize.height * (1.0f + self.reflectionScale) + self.objectBorderWidth*2 + self.reflectionGap));
                }
                else
                {
                    CGContextFillRect(context, CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y - boundsSize.height*0.5f - self.objectBorderWidth, boundsSize.width + self.objectBorderWidth*2, boundsSize.height + self.objectBorderWidth*2));
                }

                CGContextSaveGState(context);

                //shadow
                if (self.objectShadowStyle == 2)
                {
                    CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), CGSizeMake(self.objectShadowOffset, self.objectShadowOffset), self.objectShadowBlur, self.objectShadowColor.CGColor);
                }

                //draw image
                [image drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y - boundsSize.height*0.5f - self.objectBorderWidth, boundsSize.width + self.objectBorderWidth*2, boundsSize.height + self.objectBorderWidth*2) blendMode:kCGBlendModeNormal alpha:1.0f];

                if (self.isReflection)
                {
                    [reflectionImage drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y + boundsSize.height*0.5f - self.objectBorderWidth + self.reflectionGap, boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale) blendMode:kCGBlendModeNormal alpha:1.0f];
                }

                //erase inner of path
                path = [self getErasePath:pnt];
                CGContextAddPath(context, path.CGPath);
                CGContextSetBlendMode(context, kCGBlendModeClear);
                CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
                CGContextFillPath(context);
                CGContextRestoreGState(context);

                if (self.isReflection)
                {
                    path = [self getErasePath:CGPointMake(pnt.x, pnt.y + boundsSize.height + self.reflectionGap)];
                    CGContextAddPath(context, path.CGPath);
                    CGContextSetBlendMode(context, kCGBlendModeClear);
                    CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
                    CGContextFillPath(context);

                    //black gradient
                    [gradientImage drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y + boundsSize.height*0.5f + self.reflectionGap, boundsSize.width + self.objectBorderWidth*2, boundsSize.height*self.reflectionScale + self.objectBorderWidth*2) blendMode:kCGBlendModeNormal alpha:1.0f];
                }

                CGContextConcatCTM(UIGraphicsGetCurrentContext(), CGAffineTransformInvert(videoTransform));

                image = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
            }
            else
            {
                UIGraphicsBeginImageContextWithOptions(CGSizeMake(image.size.width+self.objectBorderWidth*imageSize.width/originalBoundSize.width*2, image.size.height+self.objectBorderWidth*imageSize.width/originalBoundSize.width*2), NO, 2.0f);
                [image drawInRect:CGRectMake(self.objectBorderWidth*imageSize.width/originalBoundSize.width, self.objectBorderWidth*imageSize.width/originalBoundSize.width, image.size.width, image.size.height) blendMode:kCGBlendModeNormal alpha:self.imageView.alpha];

                CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(),  [self.objectBorderColor colorWithAlphaComponent:self.imageView.alpha].CGColor);

                CGFloat middleDotLinePattern[] = {1.5f*self.objectBorderWidth, 1.5f*self.objectBorderWidth};
                CGContextSetLineDash(UIGraphicsGetCurrentContext(), 0.0f, middleDotLinePattern, 2);

                path = [self getPatternBorderPath:image.size];
                path.lineWidth = self.objectBorderWidth*imageSize.width/originalBoundSize.width;
                path.lineCapStyle = kCGLineCapButt;
                path.lineJoinStyle = kCGLineJoinMiter;
                [path stroke];

                image = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();

                CGSize reflectionSize = CGSizeMake(boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2) * self.reflectionScale);
                CGRect reflectionRect = CGRectMake(0.0f, 0.0f, boundsSize.width + self.objectBorderWidth*2, boundsSize.height+self.objectBorderWidth*2);

                if (self.isReflection)
                {
                    reflectionImage = [self renderingReflectionImage:image size:reflectionSize rect:reflectionRect];
                }

                UIGraphicsBeginImageContextWithOptions(self.superViewSize, NO, 2.0f);
                CGContextConcatCTM(UIGraphicsGetCurrentContext(), videoTransform);
                pnt = CGPointApplyAffineTransform(CGPointMake(self.center.x, self.center.y), CGAffineTransformInvert(videoTransform));

                if (self.objectShadowStyle == 2)
                {
                    CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), CGSizeMake(self.objectShadowOffset, self.objectShadowOffset), self.objectShadowBlur, self.objectShadowColor.CGColor);
                }

                [image drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y - boundsSize.height*0.5f - self.objectBorderWidth, boundsSize.width + self.objectBorderWidth*2, boundsSize.height+self.objectBorderWidth*2) blendMode:kCGBlendModeNormal alpha:1.0f];

                if (self.isReflection)
                {
                    [reflectionImage drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y + boundsSize.height*0.5f + self.reflectionGap, reflectionSize.width, reflectionSize.height) blendMode:kCGBlendModeNormal alpha:self.reflectionAlpha];
                }

                CGContextConcatCTM(UIGraphicsGetCurrentContext(), CGAffineTransformInvert(videoTransform));
                image = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
            }
            break;
        case 5: //long dot line
            if (self.isImitationPhoto)
            {
                UIGraphicsBeginImageContextWithOptions(CGSizeMake(image.size.width + self.objectBorderWidth*imageSize.width/originalBoundSize.width*2, image.size.height + self.objectBorderWidth*imageSize.width/originalBoundSize.width*2), NO, 2.0f);
                [image drawInRect:CGRectMake(self.objectBorderWidth*imageSize.width/originalBoundSize.width, self.objectBorderWidth*imageSize.width/originalBoundSize.width, image.size.width, image.size.height) blendMode:kCGBlendModeNormal alpha:1.0f];

                CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(),  [self.objectBorderColor colorWithAlphaComponent:self.imageView.alpha].CGColor);

                CGFloat longDotLinePattern[] = {3.0f*self.objectBorderWidth, 3.0f*self.objectBorderWidth};
                CGContextSetLineDash(UIGraphicsGetCurrentContext(), 0.0f, longDotLinePattern, 2);

                path = [self getPatternBorderPath:image.size];
                path.lineWidth = self.objectBorderWidth;
                path.lineCapStyle = kCGLineCapButt;
                path.lineJoinStyle = kCGLineJoinMiter;
                [path stroke];

                image = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();

                if (self.isReflection)
                {
                    //reflection image
                    CGSize reflectionSize = CGSizeMake(boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale);
                    CGRect reflectionRect = CGRectMake(0.0f, 0.0f, boundsSize.width + self.objectBorderWidth*2, boundsSize.height + self.objectBorderWidth*2);
                    reflectionImage = [self renderingReflectionImage:image size:reflectionSize rect:reflectionRect];

                    //gradient mask
                    UIGraphicsBeginImageContextWithOptions(CGSizeMake(boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale), YES, 0.0f);
                    CGContextRef gradientContext = UIGraphicsGetCurrentContext();
                    CGFloat colors[] = {1.0f, 1.0f, 0.0f, 1.0f};
                    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
                    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, colors, NULL, 2);
                    CGPoint gradientStartPoint = CGPointMake(0.0f, 0.0f);
                    CGPoint gradientEndPoint = CGPointMake(0.0f, (boundsSize.height*self.reflectionScale) + self.objectBorderWidth*2);
                    CGContextDrawLinearGradient(gradientContext, gradient, gradientStartPoint,
                                                gradientEndPoint, kCGGradientDrawsAfterEndLocation);
                    CGImageRef gradientMask = CGBitmapContextCreateImage(gradientContext);
                    CGGradientRelease(gradient);
                    CGColorSpaceRelease(colorSpace);
                    UIGraphicsEndImageContext();

                    //gradient image
                    UIGraphicsBeginImageContextWithOptions(CGSizeMake(boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale), NO, 0.0f);
                    CGContextRef context = UIGraphicsGetCurrentContext();
                    CGContextClipToMask(context, CGRectMake(0.0f, 0.0f,
                                                            boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale), gradientMask);
                    CGImageRelease(gradientMask);
                    CGContextSetFillColorWithColor(context, [[UIColor blackColor] colorWithAlphaComponent:self.imageView.alpha].CGColor);
                    CGContextFillRect(context, CGRectMake(0.0f, 0.0f,
                                                          boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale));
                    gradientImage = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                }

                UIGraphicsBeginImageContextWithOptions(self.superViewSize, NO, 2.0f);
                CGContextRef context = UIGraphicsGetCurrentContext();

                CGContextConcatCTM(UIGraphicsGetCurrentContext(), videoTransform);
                pnt = CGPointApplyAffineTransform(CGPointMake(self.center.x, self.center.y), CGAffineTransformInvert(videoTransform));

                //draw black background
                CGContextSetFillColorWithColor(context, [self.objectChromaColor colorWithAlphaComponent:self.imageView.alpha].CGColor);

                if (self.isReflection)
                {
                    CGContextFillRect(context, CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y - boundsSize.height*0.5f - self.objectBorderWidth, boundsSize.width + self.objectBorderWidth*2, boundsSize.height * (1.0f + self.reflectionScale) + self.objectBorderWidth*2 + self.reflectionGap));
                }
                else
                {
                    CGContextFillRect(context, CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y - boundsSize.height*0.5f - self.objectBorderWidth, boundsSize.width + self.objectBorderWidth*2, boundsSize.height + self.objectBorderWidth*2));
                }

                CGContextSaveGState(context);

                //shadow
                if (self.objectShadowStyle == 2)
                {
                    CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), CGSizeMake(self.objectShadowOffset, self.objectShadowOffset), self.objectShadowBlur, self.objectShadowColor.CGColor);
                }

                //draw image
                [image drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y - boundsSize.height*0.5f - self.objectBorderWidth, boundsSize.width + self.objectBorderWidth*2, boundsSize.height + self.objectBorderWidth*2) blendMode:kCGBlendModeNormal alpha:1.0f];

                if (self.isReflection)
                {
                    [reflectionImage drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y + boundsSize.height*0.5f - self.objectBorderWidth + self.reflectionGap, boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale) blendMode:kCGBlendModeNormal alpha:1.0f];
                }

                //erase inner of path
                path = [self getErasePath:pnt];
                CGContextAddPath(context, path.CGPath);
                CGContextSetBlendMode(context, kCGBlendModeClear);
                CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
                CGContextFillPath(context);
                CGContextRestoreGState(context);

                if (self.isReflection)
                {
                    path = [self getErasePath:CGPointMake(pnt.x, pnt.y + boundsSize.height + self.reflectionGap)];
                    CGContextAddPath(context, path.CGPath);
                    CGContextSetBlendMode(context, kCGBlendModeClear);
                    CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
                    CGContextFillPath(context);

                    //black gradient
                    [gradientImage drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y + boundsSize.height*0.5f + self.reflectionGap, boundsSize.width + self.objectBorderWidth*2, boundsSize.height*self.reflectionScale + self.objectBorderWidth*2) blendMode:kCGBlendModeNormal alpha:1.0f];
                }

                CGContextConcatCTM(UIGraphicsGetCurrentContext(), CGAffineTransformInvert(videoTransform));

                image = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
            }
            else
            {
                UIGraphicsBeginImageContextWithOptions(CGSizeMake(image.size.width+self.objectBorderWidth*imageSize.width/originalBoundSize.width*2, image.size.height+self.objectBorderWidth*imageSize.width/originalBoundSize.width*2), NO, 2.0f);
                [image drawInRect:CGRectMake(self.objectBorderWidth*imageSize.width/originalBoundSize.width, self.objectBorderWidth*imageSize.width/originalBoundSize.width, image.size.width, image.size.height) blendMode:kCGBlendModeNormal alpha:self.imageView.alpha];

                CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(),  [self.objectBorderColor colorWithAlphaComponent:self.imageView.alpha].CGColor);

                CGFloat longDotLinePattern[] = {3.0f*self.objectBorderWidth, 3.0f*self.objectBorderWidth};
                CGContextSetLineDash(UIGraphicsGetCurrentContext(), 0.0f, longDotLinePattern, 2);

                path = [self getPatternBorderPath:image.size];
                path.lineWidth = self.objectBorderWidth*imageSize.width/originalBoundSize.width;
                path.lineCapStyle = kCGLineCapButt;
                path.lineJoinStyle = kCGLineJoinMiter;
                [path stroke];

                image = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();

                CGSize reflectionSize = CGSizeMake(boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2) * self.reflectionScale);
                CGRect reflectionRect = CGRectMake(0.0f, 0.0f, boundsSize.width + self.objectBorderWidth*2, boundsSize.height+self.objectBorderWidth*2);

                if (self.isReflection)
                    reflectionImage = [self renderingReflectionImage:image size:reflectionSize rect:reflectionRect];

                UIGraphicsBeginImageContextWithOptions(self.superViewSize, NO, 2.0f);
                CGContextConcatCTM(UIGraphicsGetCurrentContext(), videoTransform);
                pnt = CGPointApplyAffineTransform(CGPointMake(self.center.x, self.center.y), CGAffineTransformInvert(videoTransform));

                if (self.objectShadowStyle == 2)
                    CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), CGSizeMake(self.objectShadowOffset, self.objectShadowOffset), self.objectShadowBlur, self.objectShadowColor.CGColor);

                [image drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y - boundsSize.height*0.5f - self.objectBorderWidth, boundsSize.width + self.objectBorderWidth*2, boundsSize.height+self.objectBorderWidth*2) blendMode:kCGBlendModeNormal alpha:1.0f];

                if (self.isReflection)
                    [reflectionImage drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y + boundsSize.height*0.5f + self.reflectionGap, reflectionSize.width, reflectionSize.height) blendMode:kCGBlendModeNormal alpha:self.reflectionAlpha];

                CGContextConcatCTM(UIGraphicsGetCurrentContext(), CGAffineTransformInvert(videoTransform));
                image = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
            }
            break;
        case 6: //circle dot line
            if (self.isImitationPhoto)
            {
                UIGraphicsBeginImageContextWithOptions(CGSizeMake(image.size.width + self.objectBorderWidth*imageSize.width/originalBoundSize.width*2, image.size.height + self.objectBorderWidth*imageSize.width/originalBoundSize.width*2), NO, 2.0f);
                [image drawInRect:CGRectMake(self.objectBorderWidth*imageSize.width/originalBoundSize.width, self.objectBorderWidth*imageSize.width/originalBoundSize.width, image.size.width, image.size.height) blendMode:kCGBlendModeNormal alpha:1.0f];

                CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(),  [self.objectBorderColor colorWithAlphaComponent:self.imageView.alpha].CGColor);

                CGFloat circleDotLinePattern[] = {0.1f, 2.0f*self.objectBorderWidth};
                CGContextSetLineDash(UIGraphicsGetCurrentContext(), 0.0f, circleDotLinePattern, 2);

                path = [self getPatternBorderPath:image.size];
                path.lineWidth = self.objectBorderWidth;
                path.lineCapStyle = kCGLineCapRound;
                path.lineJoinStyle = kCGLineJoinMiter;
                [path stroke];

                image = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();

                if (self.isReflection)
                {
                    //reflection image
                    CGSize reflectionSize = CGSizeMake(boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale);
                    CGRect reflectionRect = CGRectMake(0.0f, 0.0f, boundsSize.width + self.objectBorderWidth*2, boundsSize.height + self.objectBorderWidth*2);
                    reflectionImage = [self renderingReflectionImage:image size:reflectionSize rect:reflectionRect];

                    //gradient mask
                    UIGraphicsBeginImageContextWithOptions(CGSizeMake(boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale), YES, 0.0f);
                    CGContextRef gradientContext = UIGraphicsGetCurrentContext();
                    CGFloat colors[] = {1.0f, 1.0f, 0.0f, 1.0f};
                    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
                    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, colors, NULL, 2);
                    CGPoint gradientStartPoint = CGPointMake(0.0f, 0.0f);
                    CGPoint gradientEndPoint = CGPointMake(0.0f, (boundsSize.height*self.reflectionScale) + self.objectBorderWidth*2);
                    CGContextDrawLinearGradient(gradientContext, gradient, gradientStartPoint,
                                                gradientEndPoint, kCGGradientDrawsAfterEndLocation);
                    CGImageRef gradientMask = CGBitmapContextCreateImage(gradientContext);
                    CGGradientRelease(gradient);
                    CGColorSpaceRelease(colorSpace);
                    UIGraphicsEndImageContext();

                    //gradient image
                    UIGraphicsBeginImageContextWithOptions(CGSizeMake(boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale), NO, 0.0f);
                    CGContextRef context = UIGraphicsGetCurrentContext();
                    CGContextClipToMask(context, CGRectMake(0.0f, 0.0f,
                                                            boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale), gradientMask);
                    CGImageRelease(gradientMask);
                    CGContextSetFillColorWithColor(context, [[UIColor blackColor] colorWithAlphaComponent:self.imageView.alpha].CGColor);
                    CGContextFillRect(context, CGRectMake(0.0f, 0.0f,
                                                          boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale));
                    gradientImage = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                }

                UIGraphicsBeginImageContextWithOptions(self.superViewSize, NO, 2.0f);
                CGContextRef context = UIGraphicsGetCurrentContext();

                CGContextConcatCTM(UIGraphicsGetCurrentContext(), videoTransform);
                pnt = CGPointApplyAffineTransform(CGPointMake(self.center.x, self.center.y), CGAffineTransformInvert(videoTransform));

                //draw black background
                CGContextSetFillColorWithColor(context, [self.objectChromaColor colorWithAlphaComponent:self.imageView.alpha].CGColor);

                if (self.isReflection)
                {
                    CGContextFillRect(context, CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y - boundsSize.height*0.5f - self.objectBorderWidth, boundsSize.width + self.objectBorderWidth*2, boundsSize.height * (1.0f + self.reflectionScale) + self.objectBorderWidth*2 + self.reflectionGap));
                }
                else
                {
                    CGContextFillRect(context, CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y - boundsSize.height*0.5f - self.objectBorderWidth, boundsSize.width + self.objectBorderWidth*2, boundsSize.height + self.objectBorderWidth*2));
                }

                CGContextSaveGState(context);

                //shadow
                if (self.objectShadowStyle == 2)
                {
                    CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), CGSizeMake(self.objectShadowOffset, self.objectShadowOffset), self.objectShadowBlur, self.objectShadowColor.CGColor);
                }

                //draw image
                [image drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y - boundsSize.height*0.5f - self.objectBorderWidth, boundsSize.width + self.objectBorderWidth*2, boundsSize.height + self.objectBorderWidth*2) blendMode:kCGBlendModeNormal alpha:1.0f];

                if (self.isReflection)
                {
                    [reflectionImage drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y + boundsSize.height*0.5f - self.objectBorderWidth + self.reflectionGap, boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale) blendMode:kCGBlendModeNormal alpha:1.0f];
                }

                //erase inner of path
                path = [self getErasePath:pnt];
                CGContextAddPath(context, path.CGPath);
                CGContextSetBlendMode(context, kCGBlendModeClear);
                CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
                CGContextFillPath(context);
                CGContextRestoreGState(context);

                if (self.isReflection)
                {
                    path = [self getErasePath:CGPointMake(pnt.x, pnt.y + boundsSize.height + self.reflectionGap)];
                    CGContextAddPath(context, path.CGPath);
                    CGContextSetBlendMode(context, kCGBlendModeClear);
                    CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
                    CGContextFillPath(context);

                    //black gradient
                    [gradientImage drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y + boundsSize.height*0.5f + self.reflectionGap, boundsSize.width + self.objectBorderWidth*2, boundsSize.height*self.reflectionScale + self.objectBorderWidth*2) blendMode:kCGBlendModeNormal alpha:1.0f];
                }

                CGContextConcatCTM(UIGraphicsGetCurrentContext(), CGAffineTransformInvert(videoTransform));

                image = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
            }
            else
            {
                UIGraphicsBeginImageContextWithOptions(CGSizeMake(image.size.width+self.objectBorderWidth*imageSize.width/originalBoundSize.width*2, image.size.height+self.objectBorderWidth*imageSize.width/originalBoundSize.width*2), NO, 2.0f);
                [image drawInRect:CGRectMake(self.objectBorderWidth*imageSize.width/originalBoundSize.width, self.objectBorderWidth*imageSize.width/originalBoundSize.width, image.size.width, image.size.height) blendMode:kCGBlendModeNormal alpha:self.imageView.alpha];

                CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(),  [self.objectBorderColor colorWithAlphaComponent:self.imageView.alpha].CGColor);

                CGFloat circleDotLinePattern[] = {0.1f, 2.0f*self.objectBorderWidth};
                CGContextSetLineDash(UIGraphicsGetCurrentContext(), 0.0f, circleDotLinePattern, 2);

                path = [self getPatternBorderPath:image.size];
                path.lineWidth = self.objectBorderWidth*imageSize.width/originalBoundSize.width;
                path.lineCapStyle = kCGLineCapRound;
                path.lineJoinStyle = kCGLineJoinMiter;
                [path stroke];

                image = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();

                CGSize reflectionSize = CGSizeMake(boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2) * self.reflectionScale);
                CGRect reflectionRect = CGRectMake(0.0f, 0.0f, boundsSize.width + self.objectBorderWidth*2, boundsSize.height+self.objectBorderWidth*2);

                if (self.isReflection)
                    reflectionImage = [self renderingReflectionImage:image size:reflectionSize rect:reflectionRect];

                UIGraphicsBeginImageContextWithOptions(self.superViewSize, NO, 2.0f);
                CGContextConcatCTM(UIGraphicsGetCurrentContext(), videoTransform);
                pnt = CGPointApplyAffineTransform(CGPointMake(self.center.x, self.center.y), CGAffineTransformInvert(videoTransform));

                if (self.objectShadowStyle == 2)
                    CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), CGSizeMake(self.objectShadowOffset, self.objectShadowOffset), self.objectShadowBlur, self.objectShadowColor.CGColor);

                [image drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y - boundsSize.height*0.5f - self.objectBorderWidth, boundsSize.width + self.objectBorderWidth*2, boundsSize.height+self.objectBorderWidth*2) blendMode:kCGBlendModeNormal alpha:1.0f];

                if (self.isReflection)
                    [reflectionImage drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y + boundsSize.height*0.5f + self.reflectionGap, reflectionSize.width, reflectionSize.height) blendMode:kCGBlendModeNormal alpha:self.reflectionAlpha];

                CGContextConcatCTM(UIGraphicsGetCurrentContext(), CGAffineTransformInvert(videoTransform));
                image = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
            }
            break;
        case 7: //two dots line
        {
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(image.size.width+self.objectBorderWidth*imageSize.width/originalBoundSize.width*2, image.size.height+self.objectBorderWidth*imageSize.width/originalBoundSize.width*2), NO, 2.0f);

            [image drawInRect:CGRectMake(self.objectBorderWidth*imageSize.width/originalBoundSize.width, self.objectBorderWidth*imageSize.width/originalBoundSize.width, image.size.width, image.size.height) blendMode:kCGBlendModeNormal alpha:self.imageView.alpha];

            UIImage* borderImage = [UIImage imageNamed:@"dotline_pattern"];
            borderImage = [borderImage rescaleImageToSize:CGSizeMake(self.objectBorderWidth*imageSize.width/originalBoundSize.width, self.objectBorderWidth*imageSize.width/originalBoundSize.width)];

            borderImage = [borderImage imageWithOverlayColor:[self.objectBorderColor colorWithAlphaComponent:self.imageView.alpha]];

            colorRef = [UIColor colorWithPatternImage:borderImage].CGColor;
            CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(),  colorRef);

            path = [self getPatternBorderPath:image.size];
            path.lineWidth = self.objectBorderWidth*imageSize.width/originalBoundSize.width;
            [path stroke];

            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();

            CGSize reflectionSize = CGSizeMake(boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2) * self.reflectionScale);
            CGRect reflectionRect = CGRectMake(0.0f, 0.0f, boundsSize.width + self.objectBorderWidth*2, boundsSize.height+self.objectBorderWidth*2);

            if (self.isReflection)
                reflectionImage = [self renderingReflectionImage:image size:reflectionSize rect:reflectionRect];

            if (self.isImitationPhoto && self.isReflection)
            {
                //gradient mask
                UIGraphicsBeginImageContextWithOptions(CGSizeMake(boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale), YES, 0.0f);
                CGContextRef gradientContext = UIGraphicsGetCurrentContext();
                CGFloat colors[] = {1.0f, 1.0f, 0.0f, 1.0f};
                CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
                CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, colors, NULL, 2);
                CGPoint gradientStartPoint = CGPointMake(0.0f, 0.0f);
                CGPoint gradientEndPoint = CGPointMake(0.0f, (boundsSize.height*self.reflectionScale) + self.objectBorderWidth*2);
                CGContextDrawLinearGradient(gradientContext, gradient, gradientStartPoint,
                                            gradientEndPoint, kCGGradientDrawsAfterEndLocation);
                CGImageRef gradientMask = CGBitmapContextCreateImage(gradientContext);
                CGGradientRelease(gradient);
                CGColorSpaceRelease(colorSpace);
                UIGraphicsEndImageContext();

                //gradient image
                UIGraphicsBeginImageContextWithOptions(CGSizeMake(boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale), NO, 0.0f);
                CGContextRef context = UIGraphicsGetCurrentContext();
                CGContextClipToMask(context, CGRectMake(0.0f, 0.0f,
                                                        boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale), gradientMask);
                CGImageRelease(gradientMask);
                CGContextSetFillColorWithColor(context, [self.objectChromaColor colorWithAlphaComponent:self.imageView.alpha].CGColor);
                CGContextFillRect(context, CGRectMake(0.0f, 0.0f,
                                                      boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale));
                gradientImage = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
            }


            UIGraphicsBeginImageContextWithOptions(self.superViewSize, NO, 2.0f);
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextConcatCTM(UIGraphicsGetCurrentContext(), videoTransform);

            pnt = CGPointApplyAffineTransform(CGPointMake(self.center.x, self.center.y), CGAffineTransformInvert(videoTransform));

            if (self.isImitationPhoto)
            {
                //draw black background
                CGContextSetFillColorWithColor(context, [self.objectChromaColor colorWithAlphaComponent:self.imageView.alpha].CGColor);

                if (self.isReflection)
                {
                    CGContextFillRect(context, CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y - boundsSize.height*0.5f - self.objectBorderWidth, boundsSize.width + self.objectBorderWidth*2, boundsSize.height * (1.0f + self.reflectionScale) + self.objectBorderWidth*2 + self.reflectionGap));
                }
                else
                {
                    CGContextFillRect(context, CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y - boundsSize.height*0.5f - self.objectBorderWidth, boundsSize.width + self.objectBorderWidth*2, boundsSize.height + self.objectBorderWidth*2));
                }

                CGContextSaveGState(context);

                if (self.objectShadowStyle == 2)
                {
                    CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), CGSizeMake(self.objectShadowOffset, self.objectShadowOffset), self.objectShadowBlur, self.objectShadowColor.CGColor);
                }

                [image drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y - boundsSize.height*0.5f - self.objectBorderWidth, boundsSize.width + self.objectBorderWidth*2, boundsSize.height+self.objectBorderWidth*2) blendMode:kCGBlendModeNormal alpha:1.0f];

                if (self.isReflection)
                {
                    [reflectionImage drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y + boundsSize.height*0.5f - self.objectBorderWidth + self.reflectionGap, boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale) blendMode:kCGBlendModeNormal alpha:1.0f];
                }

                //erase inner of path
                path = [self getErasePath:pnt];
                CGContextAddPath(context, path.CGPath);
                CGContextSetBlendMode(context, kCGBlendModeClear);
                CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
                CGContextFillPath(context);
                CGContextRestoreGState(context);

                if (self.isReflection)
                {
                    path = [self getErasePath:CGPointMake(pnt.x, pnt.y + boundsSize.height + self.reflectionGap)];
                    CGContextAddPath(context, path.CGPath);
                    CGContextSetBlendMode(context, kCGBlendModeClear);
                    CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
                    CGContextFillPath(context);

                    //black gradient
                    [gradientImage drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y + boundsSize.height*0.5f + self.reflectionGap, boundsSize.width + self.objectBorderWidth*2, boundsSize.height*self.reflectionScale + self.objectBorderWidth*2) blendMode:kCGBlendModeNormal alpha:1.0f];
                }
            }
            else
            {
                if (self.objectShadowStyle == 2)
                {
                    CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), CGSizeMake(self.objectShadowOffset, self.objectShadowOffset), self.objectShadowBlur, self.objectShadowColor.CGColor);
                }

                [image drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y - boundsSize.height*0.5f - self.objectBorderWidth, boundsSize.width + self.objectBorderWidth*2, boundsSize.height+self.objectBorderWidth*2) blendMode:kCGBlendModeNormal alpha:1.0f];

                if (self.isReflection)
                {
                    [reflectionImage drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y + boundsSize.height*0.5f + self.reflectionGap, reflectionSize.width, reflectionSize.height) blendMode:kCGBlendModeNormal alpha:self.reflectionAlpha];
                }
            }

            CGContextConcatCTM(UIGraphicsGetCurrentContext(), CGAffineTransformInvert(videoTransform));
            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
            break;
        case 8: //jigsaw line
        {
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(image.size.width+self.objectBorderWidth*imageSize.width/originalBoundSize.width*2, image.size.height+self.objectBorderWidth*imageSize.width/originalBoundSize.width*2), NO, 2.0f);
            [image drawInRect:CGRectMake(self.objectBorderWidth*imageSize.width/originalBoundSize.width, self.objectBorderWidth*imageSize.width/originalBoundSize.width, image.size.width, image.size.height) blendMode:kCGBlendModeNormal alpha:self.imageView.alpha];
            UIImage* borderImage = [UIImage imageNamed:@"dotline_pattern"];

            borderImage = [borderImage imageWithOverlayColor:[self.objectBorderColor colorWithAlphaComponent:self.imageView.alpha]];

            colorRef = [UIColor colorWithPatternImage:borderImage].CGColor;
            CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(),  colorRef);

            path = [self getPatternBorderPath:image.size];
            path.lineWidth = self.objectBorderWidth*imageSize.width/originalBoundSize.width;
            [path stroke];

            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();

            CGSize reflectionSize = CGSizeMake(boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2) * self.reflectionScale);
            CGRect reflectionRect = CGRectMake(0.0f, 0.0f, boundsSize.width + self.objectBorderWidth*2, boundsSize.height+self.objectBorderWidth*2);

            if (self.isReflection)
                reflectionImage = [self renderingReflectionImage:image size:reflectionSize rect:reflectionRect];

            if (self.isImitationPhoto && self.isReflection)
            {
                //gradient mask
                UIGraphicsBeginImageContextWithOptions(CGSizeMake(boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale), YES, 0.0f);
                CGContextRef gradientContext = UIGraphicsGetCurrentContext();
                CGFloat colors[] = {1.0f, 1.0f, 0.0f, 1.0f};
                CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
                CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, colors, NULL, 2);
                CGPoint gradientStartPoint = CGPointMake(0.0f, 0.0f);
                CGPoint gradientEndPoint = CGPointMake(0.0f, (boundsSize.height*self.reflectionScale) + self.objectBorderWidth*2);
                CGContextDrawLinearGradient(gradientContext, gradient, gradientStartPoint,
                                            gradientEndPoint, kCGGradientDrawsAfterEndLocation);
                CGImageRef gradientMask = CGBitmapContextCreateImage(gradientContext);
                CGGradientRelease(gradient);
                CGColorSpaceRelease(colorSpace);
                UIGraphicsEndImageContext();

                //gradient image
                UIGraphicsBeginImageContextWithOptions(CGSizeMake(boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale), NO, 0.0f);
                CGContextRef context = UIGraphicsGetCurrentContext();
                CGContextClipToMask(context, CGRectMake(0.0f, 0.0f,
                                                        boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale), gradientMask);
                CGImageRelease(gradientMask);
                CGContextSetFillColorWithColor(context, [self.objectChromaColor colorWithAlphaComponent:self.imageView.alpha].CGColor);
                CGContextFillRect(context, CGRectMake(0.0f, 0.0f,
                                                      boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale));
                gradientImage = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
            }

            UIGraphicsBeginImageContextWithOptions(self.superViewSize, NO, 2.0f);
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextConcatCTM(UIGraphicsGetCurrentContext(), videoTransform);

            pnt = CGPointApplyAffineTransform(CGPointMake(self.center.x, self.center.y), CGAffineTransformInvert(videoTransform));

            if (self.isImitationPhoto)
            {
                //draw black background
                CGContextSetFillColorWithColor(context, [self.objectChromaColor colorWithAlphaComponent:self.imageView.alpha].CGColor);

                if (self.isReflection)
                {
                    CGContextFillRect(context, CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y - boundsSize.height*0.5f - self.objectBorderWidth, boundsSize.width + self.objectBorderWidth*2, boundsSize.height * (1.0f + self.reflectionScale) + self.objectBorderWidth*2 + self.reflectionGap));
                }
                else
                {
                    CGContextFillRect(context, CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y - boundsSize.height*0.5f - self.objectBorderWidth, boundsSize.width + self.objectBorderWidth*2, boundsSize.height + self.objectBorderWidth*2));
                }

                CGContextSaveGState(context);

                if (self.objectShadowStyle == 2)
                {
                    CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), CGSizeMake(self.objectShadowOffset, self.objectShadowOffset), self.objectShadowBlur, self.objectShadowColor.CGColor);
                }

                [image drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y - boundsSize.height*0.5f - self.objectBorderWidth, boundsSize.width + self.objectBorderWidth*2, boundsSize.height+self.objectBorderWidth*2) blendMode:kCGBlendModeNormal alpha:1.0f];

                if (self.isReflection)
                {
                    [reflectionImage drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y + boundsSize.height*0.5f - self.objectBorderWidth + self.reflectionGap, boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale) blendMode:kCGBlendModeNormal alpha:1.0f];
                }

                //erase inner of path
                path = [self getErasePath:pnt];
                CGContextAddPath(context, path.CGPath);
                CGContextSetBlendMode(context, kCGBlendModeClear);
                CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
                CGContextFillPath(context);
                CGContextRestoreGState(context);

                if (self.isReflection)
                {
                    path = [self getErasePath:CGPointMake(pnt.x, pnt.y + boundsSize.height + self.reflectionGap)];
                    CGContextAddPath(context, path.CGPath);
                    CGContextSetBlendMode(context, kCGBlendModeClear);
                    CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
                    CGContextFillPath(context);

                    //black gradient
                    [gradientImage drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y + boundsSize.height*0.5f + self.reflectionGap, boundsSize.width + self.objectBorderWidth*2, boundsSize.height*self.reflectionScale + self.objectBorderWidth*2) blendMode:kCGBlendModeNormal alpha:1.0f];
                }
            }
            else
            {
                if (self.objectShadowStyle == 2)
                {
                    CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), CGSizeMake(self.objectShadowOffset, self.objectShadowOffset), self.objectShadowBlur, self.objectShadowColor.CGColor);
                }

                [image drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y - boundsSize.height*0.5f - self.objectBorderWidth, boundsSize.width + self.objectBorderWidth*2, boundsSize.height+self.objectBorderWidth*2) blendMode:kCGBlendModeNormal alpha:1.0f];

                if (self.isReflection)
                {
                    [reflectionImage drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y + boundsSize.height*0.5f + self.reflectionGap, reflectionSize.width, reflectionSize.height) blendMode:kCGBlendModeNormal alpha:self.reflectionAlpha];
                }

            }

            CGContextConcatCTM(UIGraphicsGetCurrentContext(), CGAffineTransformInvert(videoTransform));
            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
            break;
        case 9: //flower line
        {
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(image.size.width+self.objectBorderWidth*imageSize.width/originalBoundSize.width*2, image.size.height+self.objectBorderWidth*imageSize.width/originalBoundSize.width*2), NO, 2.0f);
            [image drawInRect:CGRectMake(self.objectBorderWidth*imageSize.width/originalBoundSize.width, self.objectBorderWidth*imageSize.width/originalBoundSize.width, image.size.width, image.size.height) blendMode:kCGBlendModeNormal alpha:self.imageView.alpha];
            UIImage* borderImage = [UIImage imageNamed:@"flower"];
            borderImage = [borderImage rescaleImageToSize:CGSizeMake(self.objectBorderWidth*imageSize.width/originalBoundSize.width, self.objectBorderWidth*imageSize.width/originalBoundSize.width)];

            borderImage = [borderImage imageWithOverlayColor:[self.objectBorderColor colorWithAlphaComponent:self.imageView.alpha]];

            colorRef = [UIColor colorWithPatternImage:borderImage].CGColor;
            CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(),  colorRef);

            path = [self getPatternBorderPath:image.size];
            path.lineWidth = self.objectBorderWidth*imageSize.width/originalBoundSize.width;
            [path stroke];

            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();

            CGSize reflectionSize = CGSizeMake(boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2) * self.reflectionScale);
            CGRect reflectionRect = CGRectMake(0.0f, 0.0f, boundsSize.width + self.objectBorderWidth*2, boundsSize.height+self.objectBorderWidth*2);

            if (self.isReflection)
            {
                reflectionImage = [self renderingReflectionImage:image size:reflectionSize rect:reflectionRect];
            }

            if (self.isImitationPhoto && self.isReflection)
            {
                //gradient mask
                UIGraphicsBeginImageContextWithOptions(CGSizeMake(boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale), YES, 0.0f);
                CGContextRef gradientContext = UIGraphicsGetCurrentContext();
                CGFloat colors[] = {1.0f, 1.0f, 0.0f, 1.0f};
                CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
                CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, colors, NULL, 2);
                CGPoint gradientStartPoint = CGPointMake(0.0f, 0.0f);
                CGPoint gradientEndPoint = CGPointMake(0.0f, (boundsSize.height*self.reflectionScale) + self.objectBorderWidth*2);
                CGContextDrawLinearGradient(gradientContext, gradient, gradientStartPoint,
                                            gradientEndPoint, kCGGradientDrawsAfterEndLocation);
                CGImageRef gradientMask = CGBitmapContextCreateImage(gradientContext);
                CGGradientRelease(gradient);
                CGColorSpaceRelease(colorSpace);
                UIGraphicsEndImageContext();

                //gradient image
                UIGraphicsBeginImageContextWithOptions(CGSizeMake(boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale), NO, 0.0f);
                CGContextRef context = UIGraphicsGetCurrentContext();
                CGContextClipToMask(context, CGRectMake(0.0f, 0.0f,
                                                        boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale), gradientMask);
                CGImageRelease(gradientMask);
                CGContextSetFillColorWithColor(context, [self.objectChromaColor colorWithAlphaComponent:self.imageView.alpha].CGColor);
                CGContextFillRect(context, CGRectMake(0.0f, 0.0f,
                                                      boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale));
                gradientImage = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
            }

            UIGraphicsBeginImageContextWithOptions(self.superViewSize, NO, 2.0f);
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextConcatCTM(UIGraphicsGetCurrentContext(), videoTransform);

            pnt = CGPointApplyAffineTransform(CGPointMake(self.center.x, self.center.y), CGAffineTransformInvert(videoTransform));

            if (self.isImitationPhoto)
            {
                //draw black background
                CGContextSetFillColorWithColor(context, [self.objectChromaColor colorWithAlphaComponent:self.imageView.alpha].CGColor);

                if (self.isReflection)
                {
                    CGContextFillRect(context, CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y - boundsSize.height*0.5f - self.objectBorderWidth, boundsSize.width + self.objectBorderWidth*2, boundsSize.height * (1.0f + self.reflectionScale) + self.objectBorderWidth*2 + self.reflectionGap));
                }
                else
                {
                    CGContextFillRect(context, CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y - boundsSize.height*0.5f - self.objectBorderWidth, boundsSize.width + self.objectBorderWidth*2, boundsSize.height + self.objectBorderWidth*2));
                }

                CGContextSaveGState(context);

                if (self.objectShadowStyle == 2)
                {
                    CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), CGSizeMake(self.objectShadowOffset, self.objectShadowOffset), self.objectShadowBlur, self.objectShadowColor.CGColor);
                }

                [image drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y - boundsSize.height*0.5f - self.objectBorderWidth, boundsSize.width + self.objectBorderWidth*2, boundsSize.height+self.objectBorderWidth*2) blendMode:kCGBlendModeNormal alpha:1.0f];

                if (self.isReflection)
                {
                    [reflectionImage drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y + boundsSize.height*0.5f - self.objectBorderWidth + self.reflectionGap, boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale) blendMode:kCGBlendModeNormal alpha:1.0f];
                }

                //erase inner of path
                path = [self getErasePath:pnt];
                CGContextAddPath(context, path.CGPath);
                CGContextSetBlendMode(context, kCGBlendModeClear);
                CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
                CGContextFillPath(context);
                CGContextRestoreGState(context);

                if (self.isReflection)
                {
                    path = [self getErasePath:CGPointMake(pnt.x, pnt.y + boundsSize.height + self.reflectionGap)];
                    CGContextAddPath(context, path.CGPath);
                    CGContextSetBlendMode(context, kCGBlendModeClear);
                    CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
                    CGContextFillPath(context);

                    //black gradient
                    [gradientImage drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y + boundsSize.height*0.5f + self.reflectionGap, boundsSize.width + self.objectBorderWidth*2, boundsSize.height*self.reflectionScale + self.objectBorderWidth*2) blendMode:kCGBlendModeNormal alpha:1.0f];
                }
            }
            else
            {
                if (self.objectShadowStyle == 2)
                {
                    CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), CGSizeMake(self.objectShadowOffset, self.objectShadowOffset), self.objectShadowBlur, self.objectShadowColor.CGColor);
                }

                [image drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y - boundsSize.height*0.5f - self.objectBorderWidth, boundsSize.width + self.objectBorderWidth*2, boundsSize.height+self.objectBorderWidth*2) blendMode:kCGBlendModeNormal alpha:1.0f];

                if (self.isReflection)
                {
                    [reflectionImage drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y + boundsSize.height*0.5f + self.reflectionGap, reflectionSize.width, reflectionSize.height) blendMode:kCGBlendModeNormal alpha:self.reflectionAlpha];
                }
            }

            CGContextConcatCTM(UIGraphicsGetCurrentContext(), CGAffineTransformInvert(videoTransform));
            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
            break;
        case 10: //black circle line
        {
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(image.size.width+self.objectBorderWidth*imageSize.width/originalBoundSize.width*2, image.size.height+self.objectBorderWidth*imageSize.width/originalBoundSize.width*2), NO, 2.0f);
            [image drawInRect:CGRectMake(self.objectBorderWidth*imageSize.width/originalBoundSize.width, self.objectBorderWidth*imageSize.width/originalBoundSize.width, image.size.width, image.size.height) blendMode:kCGBlendModeNormal alpha:self.imageView.alpha];
            UIImage* borderImage = [UIImage imageNamed:@"circle"];
            borderImage = [borderImage rescaleImageToSize:CGSizeMake(self.objectBorderWidth*imageSize.width/originalBoundSize.width, self.objectBorderWidth*imageSize.width/originalBoundSize.width)];

            borderImage = [borderImage imageWithOverlayColor:[self.objectBorderColor colorWithAlphaComponent:self.imageView.alpha]];

            colorRef = [UIColor colorWithPatternImage:borderImage].CGColor;
            CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(),  colorRef);

            path = [self getPatternBorderPath:image.size];
            path.lineWidth = self.objectBorderWidth*imageSize.width/originalBoundSize.width;
            [path stroke];

            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();

            CGSize reflectionSize = CGSizeMake(boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2) * self.reflectionScale);
            CGRect reflectionRect = CGRectMake(0.0f, 0.0f, boundsSize.width + self.objectBorderWidth*2, boundsSize.height+self.objectBorderWidth*2);

            if (self.isReflection)
                reflectionImage = [self renderingReflectionImage:image size:reflectionSize rect:reflectionRect];

            if (self.isImitationPhoto && self.isReflection)
            {
                //gradient mask
                UIGraphicsBeginImageContextWithOptions(CGSizeMake(boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale), YES, 0.0f);
                CGContextRef gradientContext = UIGraphicsGetCurrentContext();
                CGFloat colors[] = {1.0f, 1.0f, 0.0f, 1.0f};
                CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
                CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, colors, NULL, 2);
                CGPoint gradientStartPoint = CGPointMake(0.0f, 0.0f);
                CGPoint gradientEndPoint = CGPointMake(0.0f, (boundsSize.height*self.reflectionScale) + self.objectBorderWidth*2);
                CGContextDrawLinearGradient(gradientContext, gradient, gradientStartPoint,
                                            gradientEndPoint, kCGGradientDrawsAfterEndLocation);
                CGImageRef gradientMask = CGBitmapContextCreateImage(gradientContext);
                CGGradientRelease(gradient);
                CGColorSpaceRelease(colorSpace);
                UIGraphicsEndImageContext();

                //gradient image
                UIGraphicsBeginImageContextWithOptions(CGSizeMake(boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale), NO, 0.0f);
                CGContextRef context = UIGraphicsGetCurrentContext();
                CGContextClipToMask(context, CGRectMake(0.0f, 0.0f,
                                                        boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale), gradientMask);
                CGImageRelease(gradientMask);
                CGContextSetFillColorWithColor(context, [self.objectChromaColor colorWithAlphaComponent:self.imageView.alpha].CGColor);
                CGContextFillRect(context, CGRectMake(0.0f, 0.0f,
                                                      boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale));
                gradientImage = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
            }

            UIGraphicsBeginImageContextWithOptions(self.superViewSize, NO, 2.0f);
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextConcatCTM(UIGraphicsGetCurrentContext(), videoTransform);

            pnt = CGPointApplyAffineTransform(CGPointMake(self.center.x, self.center.y), CGAffineTransformInvert(videoTransform));

            if (self.isImitationPhoto)
            {
                //draw black background
                CGContextSetFillColorWithColor(context, [self.objectChromaColor colorWithAlphaComponent:self.imageView.alpha].CGColor);

                if (self.isReflection)
                {
                    CGContextFillRect(context, CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y - boundsSize.height*0.5f - self.objectBorderWidth, boundsSize.width + self.objectBorderWidth*2, boundsSize.height * (1.0f + self.reflectionScale) + self.objectBorderWidth*2 + self.reflectionGap));
                }
                else
                {
                    CGContextFillRect(context, CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y - boundsSize.height*0.5f - self.objectBorderWidth, boundsSize.width + self.objectBorderWidth*2, boundsSize.height + self.objectBorderWidth*2));
                }

                CGContextSaveGState(context);

                if (self.objectShadowStyle == 2)
                {
                    CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), CGSizeMake(self.objectShadowOffset, self.objectShadowOffset), self.objectShadowBlur, self.objectShadowColor.CGColor);
                }

                [image drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y - boundsSize.height*0.5f - self.objectBorderWidth, boundsSize.width + self.objectBorderWidth*2, boundsSize.height+self.objectBorderWidth*2) blendMode:kCGBlendModeNormal alpha:1.0f];

                if (self.isReflection)
                {
                    [reflectionImage drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y + boundsSize.height*0.5f - self.objectBorderWidth + self.reflectionGap, boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale) blendMode:kCGBlendModeNormal alpha:1.0f];
                }

                //erase inner of path
                path = [self getErasePath:pnt];
                CGContextAddPath(context, path.CGPath);
                CGContextSetBlendMode(context, kCGBlendModeClear);
                CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
                CGContextFillPath(context);
                CGContextRestoreGState(context);

                if (self.isReflection)
                {
                    path = [self getErasePath:CGPointMake(pnt.x, pnt.y + boundsSize.height + self.reflectionGap)];
                    CGContextAddPath(context, path.CGPath);
                    CGContextSetBlendMode(context, kCGBlendModeClear);
                    CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
                    CGContextFillPath(context);

                    //black gradient
                    [gradientImage drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y + boundsSize.height*0.5f + self.reflectionGap, boundsSize.width + self.objectBorderWidth*2, boundsSize.height*self.reflectionScale + self.objectBorderWidth*2) blendMode:kCGBlendModeNormal alpha:1.0f];
                }

            }
            else
            {
                if (self.objectShadowStyle == 2)
                {
                    CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), CGSizeMake(self.objectShadowOffset, self.objectShadowOffset), self.objectShadowBlur, self.objectShadowColor.CGColor);
                }

                [image drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y - boundsSize.height*0.5f - self.objectBorderWidth, boundsSize.width + self.objectBorderWidth*2, boundsSize.height+self.objectBorderWidth*2) blendMode:kCGBlendModeNormal alpha:1.0f];

                if (self.isReflection)
                {
                    [reflectionImage drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y + boundsSize.height*0.5f + self.reflectionGap, reflectionSize.width, reflectionSize.height) blendMode:kCGBlendModeNormal alpha:self.reflectionAlpha];
                }
            }

            CGContextConcatCTM(UIGraphicsGetCurrentContext(), CGAffineTransformInvert(videoTransform));
            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
            break;
        default:
            break;
    }

    return image;
}


-(UIImage*) renderingImageViewForChromakey:(BOOL)isBlack
{
    CGSize imageSize = CGSizeZero;
    CGSize originalBoundSize = CGSizeZero;
    CGSize boundsSize = CGSizeZero;
    CGAffineTransform videoTransform = self.transform;
    
    UIImage* image = nil;
    
    if (self.mediaUrl)
    {
        imageSize = self.imageView.image.size;
        originalBoundSize = self.originalBounds.size;
        boundsSize = self.bounds.size;
        CGFloat cropOriginX = (-1.0f)*self.videoView.frame.origin.x * imageSize.width / self.videoView.frame.size.width;
        CGFloat cropOriginY = (-1.0f)*self.videoView.frame.origin.y * imageSize.height / self.videoView.frame.size.height;
        CGFloat cropWidth = self.bounds.size.width * imageSize.width / self.videoView.frame.size.width;
        CGFloat cropHeight = self.bounds.size.height * imageSize.height / self.videoView.frame.size.height;
        CGRect cropRect = CGRectMake(cropOriginX, cropOriginY, cropWidth, cropHeight);
        
        image = [self.imageView.image cropImageToRect:cropRect];
    }
    else
    {
        imageSize = self.imageView.image.size;
        originalBoundSize = self.originalBounds.size;
        boundsSize = self.bounds.size;
        CGFloat cropOriginX = (-1.0f)*self.imageView.frame.origin.x * imageSize.width / self.imageView.frame.size.width;
        CGFloat cropOriginY = (-1.0f)*self.imageView.frame.origin.y * imageSize.height / self.imageView.frame.size.height;
        CGFloat cropWidth = self.bounds.size.width * imageSize.width / self.imageView.frame.size.width;
        CGFloat cropHeight = self.bounds.size.height * imageSize.height / self.imageView.frame.size.height;
        CGRect cropRect = CGRectMake(cropOriginX, cropOriginY, cropWidth, cropHeight);
        
        image = [self.imageView.image cropImageToRect:cropRect];
    }
    
    if (self.objectCornerRadius != 0.0f)
        image = [self renderImageWithCorner:image];
    
    CGPoint pnt = CGPointZero;
    UIBezierPath* path;
    UIImage* reflectionImage = nil;
    
    if (self.objectBorderStyle == 1)
    {
        if (self.isReflection)
        {
            //reflection image
            CGSize reflectionSize = CGSizeMake(boundsSize.width, boundsSize.height * self.reflectionScale);
            CGRect reflectionRect = CGRectMake(0.0f, 0.0f, boundsSize.width, boundsSize.height);
            reflectionImage = [self renderingReflectionImage:image size:reflectionSize rect:reflectionRect];
        }
        
        UIGraphicsBeginImageContextWithOptions(self.superViewSize, NO, 2.0f);
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGContextConcatCTM(UIGraphicsGetCurrentContext(), videoTransform);
        pnt = CGPointApplyAffineTransform(CGPointMake(self.center.x, self.center.y), CGAffineTransformInvert(videoTransform));
        
        //draw black background
        if (isBlack)
            CGContextSetFillColorWithColor(context, [[UIColor blackColor] colorWithAlphaComponent:self.imageView.alpha].CGColor);
        else
            CGContextSetFillColorWithColor(context, [self.objectChromaColor colorWithAlphaComponent:self.imageView.alpha].CGColor);
        
        if (self.isReflection)
            CGContextFillRect(context, CGRectMake(pnt.x - boundsSize.width*0.5f - 2.0f, pnt.y - boundsSize.height*0.5f - 2.0f, boundsSize.width + 4.0f, boundsSize.height * (1.0f + self.reflectionScale) + 4.0f + self.reflectionGap));
        else
            CGContextFillRect(context, CGRectMake(pnt.x - boundsSize.width*0.5f - 2.0f, pnt.y - boundsSize.height*0.5f - 2.0f, boundsSize.width + 4.0f, boundsSize.height + 4.0f));
        
        CGContextSaveGState(context);
        
        if (self.isReflection)
            [reflectionImage drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f, pnt.y + boundsSize.height*0.5f + self.reflectionGap, boundsSize.width, boundsSize.height * self.reflectionScale) blendMode:kCGBlendModeNormal alpha:1.0f];
        
        //erase inner of path
        path = [self getErasePath:pnt];
        CGContextAddPath(context, path.CGPath);
        CGContextSetBlendMode(context, kCGBlendModeClear);
        CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
        CGContextFillPath(context);
        CGContextRestoreGState(context);
        
        if (self.isReflection)
        {
            path = [self getErasePath:CGPointMake(pnt.x, pnt.y + boundsSize.height + self.reflectionGap)];
            CGContextAddPath(context, path.CGPath);
            CGContextSetBlendMode(context, kCGBlendModeClear);
            CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
            CGContextFillPath(context);
        }
        
        CGContextConcatCTM(UIGraphicsGetCurrentContext(), CGAffineTransformInvert(videoTransform));
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    else
    {
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(image.size.width + self.objectBorderWidth*imageSize.width/originalBoundSize.width*2, image.size.height + self.objectBorderWidth*imageSize.width/originalBoundSize.width*2), NO, 2.0f);
        [image drawInRect:CGRectMake(self.objectBorderWidth*imageSize.width/originalBoundSize.width, self.objectBorderWidth*imageSize.width/originalBoundSize.width, image.size.width, image.size.height) blendMode:kCGBlendModeNormal alpha:1.0f];
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        if (self.isReflection)
        {
            CGSize reflectionSize = CGSizeMake(boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale);
            CGRect reflectionRect = CGRectMake(0.0f, 0.0f, boundsSize.width + self.objectBorderWidth*2, boundsSize.height + self.objectBorderWidth*2);
            reflectionImage = [self renderingReflectionImage:image size:reflectionSize rect:reflectionRect];
        }
        
        UIGraphicsBeginImageContextWithOptions(self.superViewSize, NO, 2.0f);
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGContextConcatCTM(UIGraphicsGetCurrentContext(), videoTransform);
        pnt = CGPointApplyAffineTransform(CGPointMake(self.center.x, self.center.y), CGAffineTransformInvert(videoTransform));
        
        //draw black background
        if (isBlack)
            CGContextSetFillColorWithColor(context, [[UIColor blackColor] colorWithAlphaComponent:self.imageView.alpha].CGColor);
        else
            CGContextSetFillColorWithColor(context, [self.objectChromaColor colorWithAlphaComponent:self.imageView.alpha].CGColor);
        
        if (self.isReflection)
        {
            CGContextFillRect(context, CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y - boundsSize.height*0.5f - self.objectBorderWidth, boundsSize.width + self.objectBorderWidth*2, boundsSize.height * (1.0f + self.reflectionScale) + self.objectBorderWidth*2 + self.reflectionGap));
        }
        else
        {
            CGContextFillRect(context, CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y - boundsSize.height*0.5f - self.objectBorderWidth, boundsSize.width + self.objectBorderWidth*2, boundsSize.height + self.objectBorderWidth*2));
        }
        
        CGContextSaveGState(context);
        
        if (self.isReflection)
            [reflectionImage drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y + boundsSize.height*0.5f - self.objectBorderWidth + self.reflectionGap, boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale) blendMode:kCGBlendModeNormal alpha:1.0f];
        
        //erase inner of path
        path = [self getErasePath:pnt];
        CGContextAddPath(context, path.CGPath);
        CGContextSetBlendMode(context, kCGBlendModeClear);
        CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
        CGContextFillPath(context);
        CGContextRestoreGState(context);
        
        if (self.isReflection)
        {
            path = [self getErasePath:CGPointMake(pnt.x, pnt.y + boundsSize.height + self.reflectionGap)];
            CGContextAddPath(context, path.CGPath);
            CGContextSetBlendMode(context, kCGBlendModeClear);
            CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
            CGContextFillPath(context);
        }
        
        CGContextConcatCTM(UIGraphicsGetCurrentContext(), CGAffineTransformInvert(videoTransform));
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    return image;
}

-(UIImage*) renderingOutlineAndShadow
{
    CGSize originalBoundSize = self.originalBounds.size;
    CGSize boundsSize = self.bounds.size;
    CGAffineTransform videoTransform = self.transform;
    CGFloat cropOriginX = (-1.0f)*self.imageView.frame.origin.x * self.imageView.image.size.width / self.imageView.frame.size.width;
    CGFloat cropOriginY = (-1.0f)*self.imageView.frame.origin.y * self.imageView.image.size.height / self.imageView.frame.size.height;
    CGFloat cropWidth = self.bounds.size.width * self.imageView.image.size.width / self.imageView.frame.size.width;
    CGFloat cropHeight = self.bounds.size.height * self.imageView.image.size.height / self.imageView.frame.size.height;
    CGRect cropRect = CGRectMake(cropOriginX, cropOriginY, cropWidth, cropHeight);
    
    UIImage* image = [self.imageView.image cropImageToRect:cropRect];
    
    if (self.objectCornerRadius != 0.0f)
        image = [self renderImageWithCorner:image];
    
    
    CGSize imageSize = self.imageView.image.size;
    
    if (self.isShape)
    {
        if (self.bounds.size.width >= self.bounds.size.height)
        {
            imageSize = CGSizeMake(image.size.width, image.size.width*(self.bounds.size.height/self.bounds.size.width));
        }
        else
        {
            imageSize = CGSizeMake(image.size.height*(self.bounds.size.width/self.bounds.size.height), image.size.height);
        }
        
        image = [image rescaleImageToSize:imageSize];
    }

    
    CGColorRef colorRef = nil;
    CGPoint pnt = CGPointZero;
    UIBezierPath* path;
    UIImage* reflectionImage = nil;
    UIImage* gradientImage = nil;
    
    switch (self.objectBorderStyle)
    {
        case 1: //no outline
        {
            if (self.isReflection)
            {
                //reflection image
                CGSize reflectionSize = CGSizeMake(boundsSize.width, boundsSize.height * self.reflectionScale);
                CGRect reflectionRect = CGRectMake(0.0f, 0.0f, boundsSize.width, boundsSize.height);
                reflectionImage = [self renderingReflectionImage:image size:reflectionSize rect:reflectionRect];
                
                //gradient mask
                UIGraphicsBeginImageContextWithOptions(CGSizeMake(boundsSize.width, boundsSize.height * self.reflectionScale), YES, 0.0f);
                CGContextRef gradientContext = UIGraphicsGetCurrentContext();
                CGFloat colors[] = {1.0f, 1.0f, 0.0f, 0.5f};
                CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
                CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, colors, NULL, 2);
                CGPoint gradientStartPoint = CGPointMake(0.0f, 0.0f);
                CGPoint gradientEndPoint = CGPointMake(0.0f, boundsSize.height * self.reflectionScale);
                CGContextDrawLinearGradient(gradientContext, gradient, gradientStartPoint,
                                            gradientEndPoint, kCGGradientDrawsAfterEndLocation);
                CGImageRef gradientMask = CGBitmapContextCreateImage(gradientContext);
                CGGradientRelease(gradient);
                CGColorSpaceRelease(colorSpace);
                UIGraphicsEndImageContext();
                
                //gradient image
                UIGraphicsBeginImageContextWithOptions(CGSizeMake(boundsSize.width, boundsSize.height * self.reflectionScale), NO, 0.0f);
                CGContextRef context = UIGraphicsGetCurrentContext();
                CGContextClipToMask(context, CGRectMake(0.0f, 0.0f,
                                                        boundsSize.width, boundsSize.height * self.reflectionScale), gradientMask);
                CGImageRelease(gradientMask);
                CGContextSetFillColorWithColor(context, [[UIColor blackColor] colorWithAlphaComponent:self.imageView.alpha].CGColor);
                CGContextFillRect(context, CGRectMake(0.0f, 0.0f,
                                                      boundsSize.width, boundsSize.height * self.reflectionScale));
                gradientImage = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
            }
            
            UIGraphicsBeginImageContextWithOptions(self.superViewSize, NO, 2.0f);
            CGContextRef context = UIGraphicsGetCurrentContext();
            
            CGContextConcatCTM(UIGraphicsGetCurrentContext(), videoTransform);
            pnt = CGPointApplyAffineTransform(CGPointMake(self.center.x, self.center.y), CGAffineTransformInvert(videoTransform));
            
            //shadow
            if (self.objectShadowStyle == 2)
                CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), CGSizeMake(self.objectShadowOffset, self.objectShadowOffset), self.objectShadowBlur, self.objectShadowColor.CGColor);
            
            //draw image
            [image drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f, pnt.y - boundsSize.height*0.5f, boundsSize.width, boundsSize.height) blendMode:kCGBlendModeNormal alpha:self.imageView.alpha];
            
            if (self.isReflection)
                [reflectionImage drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f, pnt.y + boundsSize.height*0.5f + self.reflectionGap, boundsSize.width, boundsSize.height * self.reflectionScale) blendMode:kCGBlendModeNormal alpha:1.0f];
            
            //erase inner of path
            path = [self getErasePath:pnt];
            CGContextAddPath(context, path.CGPath);
            CGContextSetBlendMode(context, kCGBlendModeClear);
            CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
            CGContextFillPath(context);
            
            if (self.isReflection)
            {
                path = [self getErasePath:CGPointMake(pnt.x, pnt.y + boundsSize.height + self.reflectionGap)];
                CGContextAddPath(context, path.CGPath);
                CGContextSetBlendMode(context, kCGBlendModeClear);
                CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
                CGContextFillPath(context);
                
                //black gradient
                [gradientImage drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f, pnt.y + boundsSize.height*0.5f + self.reflectionGap, boundsSize.width, boundsSize.height * self.reflectionScale) blendMode:kCGBlendModeNormal alpha:1.0f];
            }
            
            CGContextConcatCTM(UIGraphicsGetCurrentContext(), CGAffineTransformInvert(videoTransform));
            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
            break;
        case 2: //line
        {
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(image.size.width + self.objectBorderWidth*imageSize.width/originalBoundSize.width*2, image.size.height + self.objectBorderWidth*imageSize.width/originalBoundSize.width*2), NO, 2.0f);
            [image drawInRect:CGRectMake(self.objectBorderWidth*imageSize.width/originalBoundSize.width, self.objectBorderWidth*imageSize.width/originalBoundSize.width, image.size.width, image.size.height) blendMode:kCGBlendModeNormal alpha:1.0f];
            
            CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(),  [self.objectBorderColor colorWithAlphaComponent:self.imageView.alpha].CGColor);
            
            path = [self getPatternBorderPath:image.size];
            path.lineWidth = self.objectBorderWidth*imageSize.width/originalBoundSize.width;
            [path stroke];
            
            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            if (self.isReflection)
            {
                CGSize reflectionSize = CGSizeMake(boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale);
                CGRect reflectionRect = CGRectMake(0.0f, 0.0f, boundsSize.width + self.objectBorderWidth*2, boundsSize.height + self.objectBorderWidth*2);
                reflectionImage = [self renderingReflectionImage:image size:reflectionSize rect:reflectionRect];
                
                //gradient mask
                UIGraphicsBeginImageContextWithOptions(CGSizeMake(boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale), YES, 0.0f);
                CGContextRef gradientContext = UIGraphicsGetCurrentContext();
                CGFloat colors[] = {1.0f, 1.0f, 0.0f, 1.0f};
                CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
                CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, colors, NULL, 2);
                CGPoint gradientStartPoint = CGPointMake(0.0f, 0.0f);
                CGPoint gradientEndPoint = CGPointMake(0.0f, (boundsSize.height*self.reflectionScale) + self.objectBorderWidth*2);
                CGContextDrawLinearGradient(gradientContext, gradient, gradientStartPoint,
                                            gradientEndPoint, kCGGradientDrawsAfterEndLocation);
                CGImageRef gradientMask = CGBitmapContextCreateImage(gradientContext);
                CGGradientRelease(gradient);
                CGColorSpaceRelease(colorSpace);
                UIGraphicsEndImageContext();
                
                //gradient image
                UIGraphicsBeginImageContextWithOptions(CGSizeMake(boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale), NO, 0.0f);
                CGContextRef context = UIGraphicsGetCurrentContext();
                CGContextClipToMask(context, CGRectMake(0.0f, 0.0f,
                                                        boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale), gradientMask);
                CGImageRelease(gradientMask);
                CGContextSetFillColorWithColor(context, [[UIColor blackColor] colorWithAlphaComponent:self.imageView.alpha].CGColor);
                CGContextFillRect(context, CGRectMake(0.0f, 0.0f,
                                                      boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale));
                gradientImage = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
            }
            
            UIGraphicsBeginImageContextWithOptions(self.superViewSize, NO, 2.0f);
            CGContextRef context = UIGraphicsGetCurrentContext();
            
            CGContextConcatCTM(UIGraphicsGetCurrentContext(), videoTransform);
            pnt = CGPointApplyAffineTransform(CGPointMake(self.center.x, self.center.y), CGAffineTransformInvert(videoTransform));
            
            //shadow
            if (self.objectShadowStyle == 2)
                CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), CGSizeMake(self.objectShadowOffset, self.objectShadowOffset), self.objectShadowBlur, self.objectShadowColor.CGColor);
            
            //draw image
            [image drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y - boundsSize.height*0.5f - self.objectBorderWidth, boundsSize.width + self.objectBorderWidth*2, boundsSize.height + self.objectBorderWidth*2) blendMode:kCGBlendModeNormal alpha:1.0f];
            
            if (self.isReflection)
                [reflectionImage drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y + boundsSize.height*0.5f - self.objectBorderWidth + self.reflectionGap, boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale) blendMode:kCGBlendModeNormal alpha:1.0f];
            
            //erase inner of path
            path = [self getErasePath:pnt];
            CGContextAddPath(context, path.CGPath);
            CGContextSetBlendMode(context, kCGBlendModeClear);
            CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
            CGContextFillPath(context);
            
            if (self.isReflection)
            {
                path = [self getErasePath:CGPointMake(pnt.x, pnt.y + boundsSize.height + self.reflectionGap)];
                CGContextAddPath(context, path.CGPath);
                CGContextSetBlendMode(context, kCGBlendModeClear);
                CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
                CGContextFillPath(context);
                
                //black gradient
                [gradientImage drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y + boundsSize.height*0.5f + self.reflectionGap, boundsSize.width + self.objectBorderWidth*2, boundsSize.height*self.reflectionScale + self.objectBorderWidth*2) blendMode:kCGBlendModeNormal alpha:1.0f];
            }
            
            CGContextConcatCTM(UIGraphicsGetCurrentContext(), CGAffineTransformInvert(videoTransform));
            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
            break;
        case 3: //shot dot line
        {
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(image.size.width + self.objectBorderWidth*imageSize.width/originalBoundSize.width*2, image.size.height + self.objectBorderWidth*imageSize.width/originalBoundSize.width*2), NO, 2.0f);
            [image drawInRect:CGRectMake(self.objectBorderWidth*imageSize.width/originalBoundSize.width, self.objectBorderWidth*imageSize.width/originalBoundSize.width, image.size.width, image.size.height) blendMode:kCGBlendModeNormal alpha:1.0f];
            
            CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(),  [self.objectBorderColor colorWithAlphaComponent:self.imageView.alpha].CGColor);
            
            CGFloat pattern[] = {self.objectBorderWidth, self.objectBorderWidth};
            CGContextSetLineDash(UIGraphicsGetCurrentContext(), 0.0f, pattern, 2);
            
            path = [self getPatternBorderPath:image.size];
            path.lineWidth = self.objectBorderWidth;
            path.lineCapStyle = kCGLineCapButt;
            path.lineJoinStyle = kCGLineJoinMiter;
            [path stroke];
            
            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            if (self.isReflection)
            {
                CGSize reflectionSize = CGSizeMake(boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale);
                CGRect reflectionRect = CGRectMake(0.0f, 0.0f, boundsSize.width + self.objectBorderWidth*2, boundsSize.height + self.objectBorderWidth*2);
                reflectionImage = [self renderingReflectionImage:image size:reflectionSize rect:reflectionRect];
                
                //gradient mask
                UIGraphicsBeginImageContextWithOptions(CGSizeMake(boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale), YES, 0.0f);
                CGContextRef gradientContext = UIGraphicsGetCurrentContext();
                CGFloat colors[] = {1.0f, 1.0f, 0.0f, 1.0f};
                CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
                CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, colors, NULL, 2);
                CGPoint gradientStartPoint = CGPointMake(0.0f, 0.0f);
                CGPoint gradientEndPoint = CGPointMake(0.0f, (boundsSize.height*self.reflectionScale) + self.objectBorderWidth*2);
                CGContextDrawLinearGradient(gradientContext, gradient, gradientStartPoint,
                                            gradientEndPoint, kCGGradientDrawsAfterEndLocation);
                CGImageRef gradientMask = CGBitmapContextCreateImage(gradientContext);
                CGGradientRelease(gradient);
                CGColorSpaceRelease(colorSpace);
                UIGraphicsEndImageContext();
                
                //gradient image
                UIGraphicsBeginImageContextWithOptions(CGSizeMake(boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale), NO, 0.0f);
                CGContextRef context = UIGraphicsGetCurrentContext();
                CGContextClipToMask(context, CGRectMake(0.0f, 0.0f,
                                                        boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale), gradientMask);
                CGImageRelease(gradientMask);
                CGContextSetFillColorWithColor(context, [[UIColor blackColor] colorWithAlphaComponent:self.imageView.alpha].CGColor);
                CGContextFillRect(context, CGRectMake(0.0f, 0.0f,
                                                      boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale));
                gradientImage = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
            }
            
            UIGraphicsBeginImageContextWithOptions(self.superViewSize, NO, 2.0f);
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextConcatCTM(UIGraphicsGetCurrentContext(), videoTransform);
            pnt = CGPointApplyAffineTransform(CGPointMake(self.center.x, self.center.y), CGAffineTransformInvert(videoTransform));
            
            //shadow
            if (self.objectShadowStyle == 2)
            {
                CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), CGSizeMake(self.objectShadowOffset, self.objectShadowOffset), self.objectShadowBlur, self.objectShadowColor.CGColor);
            }
            
            //draw image
            [image drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y - boundsSize.height*0.5f - self.objectBorderWidth, boundsSize.width + self.objectBorderWidth*2, boundsSize.height + self.objectBorderWidth*2) blendMode:kCGBlendModeNormal alpha:1.0f];
            
            if (self.isReflection)
            {
                [reflectionImage drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y + boundsSize.height*0.5f - self.objectBorderWidth + self.reflectionGap, boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale) blendMode:kCGBlendModeNormal alpha:1.0f];
            }
            
            //erase inner of path
            path = [self getErasePath:pnt];
            CGContextAddPath(context, path.CGPath);
            CGContextSetBlendMode(context, kCGBlendModeClear);
            CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
            CGContextFillPath(context);
            
            if (self.isReflection)
            {
                path = [self getErasePath:CGPointMake(pnt.x, pnt.y + boundsSize.height + self.reflectionGap)];
                CGContextAddPath(context, path.CGPath);
                CGContextSetBlendMode(context, kCGBlendModeClear);
                CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
                CGContextFillPath(context);
                
                //black gradient
                [gradientImage drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y + boundsSize.height*0.5f + self.reflectionGap, boundsSize.width + self.objectBorderWidth*2, boundsSize.height*self.reflectionScale + self.objectBorderWidth*2) blendMode:kCGBlendModeNormal alpha:1.0f];
            }
            
            CGContextConcatCTM(UIGraphicsGetCurrentContext(), CGAffineTransformInvert(videoTransform));
            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
            break;
        case 4: //middle dot line
        {
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(image.size.width + self.objectBorderWidth*imageSize.width/originalBoundSize.width*2, image.size.height + self.objectBorderWidth*imageSize.width/originalBoundSize.width*2), NO, 2.0f);
            [image drawInRect:CGRectMake(self.objectBorderWidth*imageSize.width/originalBoundSize.width, self.objectBorderWidth*imageSize.width/originalBoundSize.width, image.size.width, image.size.height) blendMode:kCGBlendModeNormal alpha:1.0f];
            
            CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(),  [self.objectBorderColor colorWithAlphaComponent:self.imageView.alpha].CGColor);
            
            CGFloat middleDotLinePattern[] = {1.5f*self.objectBorderWidth, 1.5f*self.objectBorderWidth};
            CGContextSetLineDash(UIGraphicsGetCurrentContext(), 0.0f, middleDotLinePattern, 2);
            
            path = [self getPatternBorderPath:image.size];
            path.lineWidth = self.objectBorderWidth;
            path.lineCapStyle = kCGLineCapButt;
            path.lineJoinStyle = kCGLineJoinMiter;
            [path stroke];
            
            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            if (self.isReflection)
            {
                //reflection image
                CGSize reflectionSize = CGSizeMake(boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale);
                CGRect reflectionRect = CGRectMake(0.0f, 0.0f, boundsSize.width + self.objectBorderWidth*2, boundsSize.height + self.objectBorderWidth*2);
                reflectionImage = [self renderingReflectionImage:image size:reflectionSize rect:reflectionRect];
                
                //gradient mask
                UIGraphicsBeginImageContextWithOptions(CGSizeMake(boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale), YES, 0.0f);
                CGContextRef gradientContext = UIGraphicsGetCurrentContext();
                CGFloat colors[] = {1.0f, 1.0f, 0.0f, 1.0f};
                CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
                CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, colors, NULL, 2);
                CGPoint gradientStartPoint = CGPointMake(0.0f, 0.0f);
                CGPoint gradientEndPoint = CGPointMake(0.0f, (boundsSize.height*self.reflectionScale) + self.objectBorderWidth*2);
                CGContextDrawLinearGradient(gradientContext, gradient, gradientStartPoint,
                                            gradientEndPoint, kCGGradientDrawsAfterEndLocation);
                CGImageRef gradientMask = CGBitmapContextCreateImage(gradientContext);
                CGGradientRelease(gradient);
                CGColorSpaceRelease(colorSpace);
                UIGraphicsEndImageContext();
                
                //gradient image
                UIGraphicsBeginImageContextWithOptions(CGSizeMake(boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale), NO, 0.0f);
                CGContextRef context = UIGraphicsGetCurrentContext();
                CGContextClipToMask(context, CGRectMake(0.0f, 0.0f,
                                                        boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale), gradientMask);
                CGImageRelease(gradientMask);
                CGContextSetFillColorWithColor(context, [[UIColor blackColor] colorWithAlphaComponent:self.imageView.alpha].CGColor);
                CGContextFillRect(context, CGRectMake(0.0f, 0.0f,
                                                      boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale));
                gradientImage = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
            }
            
            UIGraphicsBeginImageContextWithOptions(self.superViewSize, NO, 2.0f);
            CGContextRef context = UIGraphicsGetCurrentContext();
            
            CGContextConcatCTM(UIGraphicsGetCurrentContext(), videoTransform);
            pnt = CGPointApplyAffineTransform(CGPointMake(self.center.x, self.center.y), CGAffineTransformInvert(videoTransform));
            
            //shadow
            if (self.objectShadowStyle == 2)
            {
                CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), CGSizeMake(self.objectShadowOffset, self.objectShadowOffset), self.objectShadowBlur, self.objectShadowColor.CGColor);
            }
            
            //draw image
            [image drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y - boundsSize.height*0.5f - self.objectBorderWidth, boundsSize.width + self.objectBorderWidth*2, boundsSize.height + self.objectBorderWidth*2) blendMode:kCGBlendModeNormal alpha:1.0f];
            
            if (self.isReflection)
            {
                [reflectionImage drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y + boundsSize.height*0.5f - self.objectBorderWidth + self.reflectionGap, boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale) blendMode:kCGBlendModeNormal alpha:1.0f];
            }
            
            //erase inner of path
            path = [self getErasePath:pnt];
            CGContextAddPath(context, path.CGPath);
            CGContextSetBlendMode(context, kCGBlendModeClear);
            CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
            CGContextFillPath(context);
            
            if (self.isReflection)
            {
                path = [self getErasePath:CGPointMake(pnt.x, pnt.y + boundsSize.height + self.reflectionGap)];
                CGContextAddPath(context, path.CGPath);
                CGContextSetBlendMode(context, kCGBlendModeClear);
                CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
                CGContextFillPath(context);
                
                //black gradient
                [gradientImage drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y + boundsSize.height*0.5f + self.reflectionGap, boundsSize.width + self.objectBorderWidth*2, boundsSize.height*self.reflectionScale + self.objectBorderWidth*2) blendMode:kCGBlendModeNormal alpha:1.0f];
            }
            
            CGContextConcatCTM(UIGraphicsGetCurrentContext(), CGAffineTransformInvert(videoTransform));
            
            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
            break;
        case 5: //long dot line
        {
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(image.size.width + self.objectBorderWidth*imageSize.width/originalBoundSize.width*2, image.size.height + self.objectBorderWidth*imageSize.width/originalBoundSize.width*2), NO, 2.0f);
            [image drawInRect:CGRectMake(self.objectBorderWidth*imageSize.width/originalBoundSize.width, self.objectBorderWidth*imageSize.width/originalBoundSize.width, image.size.width, image.size.height) blendMode:kCGBlendModeNormal alpha:1.0f];
            
            CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(),  [self.objectBorderColor colorWithAlphaComponent:self.imageView.alpha].CGColor);
            
            CGFloat longDotLinePattern[] = {3.0f*self.objectBorderWidth, 3.0f*self.objectBorderWidth};
            CGContextSetLineDash(UIGraphicsGetCurrentContext(), 0.0f, longDotLinePattern, 2);
            
            path = [self getPatternBorderPath:image.size];
            path.lineWidth = self.objectBorderWidth;
            path.lineCapStyle = kCGLineCapButt;
            path.lineJoinStyle = kCGLineJoinMiter;
            [path stroke];
            
            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            if (self.isReflection)
            {
                //reflection image
                CGSize reflectionSize = CGSizeMake(boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale);
                CGRect reflectionRect = CGRectMake(0.0f, 0.0f, boundsSize.width + self.objectBorderWidth*2, boundsSize.height + self.objectBorderWidth*2);
                reflectionImage = [self renderingReflectionImage:image size:reflectionSize rect:reflectionRect];
                
                //gradient mask
                UIGraphicsBeginImageContextWithOptions(CGSizeMake(boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale), YES, 0.0f);
                CGContextRef gradientContext = UIGraphicsGetCurrentContext();
                CGFloat colors[] = {1.0f, 1.0f, 0.0f, 1.0f};
                CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
                CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, colors, NULL, 2);
                CGPoint gradientStartPoint = CGPointMake(0.0f, 0.0f);
                CGPoint gradientEndPoint = CGPointMake(0.0f, (boundsSize.height*self.reflectionScale) + self.objectBorderWidth*2);
                CGContextDrawLinearGradient(gradientContext, gradient, gradientStartPoint,
                                            gradientEndPoint, kCGGradientDrawsAfterEndLocation);
                CGImageRef gradientMask = CGBitmapContextCreateImage(gradientContext);
                CGGradientRelease(gradient);
                CGColorSpaceRelease(colorSpace);
                UIGraphicsEndImageContext();
                
                //gradient image
                UIGraphicsBeginImageContextWithOptions(CGSizeMake(boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale), NO, 0.0f);
                CGContextRef context = UIGraphicsGetCurrentContext();
                CGContextClipToMask(context, CGRectMake(0.0f, 0.0f,
                                                        boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale), gradientMask);
                CGImageRelease(gradientMask);
                CGContextSetFillColorWithColor(context, [[UIColor blackColor] colorWithAlphaComponent:self.imageView.alpha].CGColor);
                CGContextFillRect(context, CGRectMake(0.0f, 0.0f,
                                                      boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale));
                gradientImage = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
            }
            
            UIGraphicsBeginImageContextWithOptions(self.superViewSize, NO, 2.0f);
            CGContextRef context = UIGraphicsGetCurrentContext();
            
            CGContextConcatCTM(UIGraphicsGetCurrentContext(), videoTransform);
            pnt = CGPointApplyAffineTransform(CGPointMake(self.center.x, self.center.y), CGAffineTransformInvert(videoTransform));
            
            //shadow
            if (self.objectShadowStyle == 2)
            {
                CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), CGSizeMake(self.objectShadowOffset, self.objectShadowOffset), self.objectShadowBlur, self.objectShadowColor.CGColor);
            }
            
            //draw image
            [image drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y - boundsSize.height*0.5f - self.objectBorderWidth, boundsSize.width + self.objectBorderWidth*2, boundsSize.height + self.objectBorderWidth*2) blendMode:kCGBlendModeNormal alpha:1.0f];
            
            if (self.isReflection)
            {
                [reflectionImage drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y + boundsSize.height*0.5f - self.objectBorderWidth + self.reflectionGap, boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale) blendMode:kCGBlendModeNormal alpha:1.0f];
            }
            
            //erase inner of path
            path = [self getErasePath:pnt];
            CGContextAddPath(context, path.CGPath);
            CGContextSetBlendMode(context, kCGBlendModeClear);
            CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
            CGContextFillPath(context);
            
            if (self.isReflection)
            {
                path = [self getErasePath:CGPointMake(pnt.x, pnt.y + boundsSize.height + self.reflectionGap)];
                CGContextAddPath(context, path.CGPath);
                CGContextSetBlendMode(context, kCGBlendModeClear);
                CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
                CGContextFillPath(context);
                
                //black gradient
                [gradientImage drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y + boundsSize.height*0.5f + self.reflectionGap, boundsSize.width + self.objectBorderWidth*2, boundsSize.height*self.reflectionScale + self.objectBorderWidth*2) blendMode:kCGBlendModeNormal alpha:1.0f];
            }
            
            CGContextConcatCTM(UIGraphicsGetCurrentContext(), CGAffineTransformInvert(videoTransform));
            
            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
            break;
        case 6: //circle dot line
        {
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(image.size.width + self.objectBorderWidth*imageSize.width/originalBoundSize.width*2, image.size.height + self.objectBorderWidth*imageSize.width/originalBoundSize.width*2), NO, 2.0f);
            [image drawInRect:CGRectMake(self.objectBorderWidth*imageSize.width/originalBoundSize.width, self.objectBorderWidth*imageSize.width/originalBoundSize.width, image.size.width, image.size.height) blendMode:kCGBlendModeNormal alpha:1.0f];
            
            CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(),  [self.objectBorderColor colorWithAlphaComponent:self.imageView.alpha].CGColor);
            
            CGFloat circleDotLinePattern[] = {0.1f, 2.0f*self.objectBorderWidth};
            CGContextSetLineDash(UIGraphicsGetCurrentContext(), 0.0f, circleDotLinePattern, 2);
            
            path = [self getPatternBorderPath:image.size];
            path.lineWidth = self.objectBorderWidth;
            path.lineCapStyle = kCGLineCapRound;
            path.lineJoinStyle = kCGLineJoinMiter;
            [path stroke];
            
            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            if (self.isReflection)
            {
                //reflection image
                CGSize reflectionSize = CGSizeMake(boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale);
                CGRect reflectionRect = CGRectMake(0.0f, 0.0f, boundsSize.width + self.objectBorderWidth*2, boundsSize.height + self.objectBorderWidth*2);
                reflectionImage = [self renderingReflectionImage:image size:reflectionSize rect:reflectionRect];
                
                //gradient mask
                UIGraphicsBeginImageContextWithOptions(CGSizeMake(boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale), YES, 0.0f);
                CGContextRef gradientContext = UIGraphicsGetCurrentContext();
                CGFloat colors[] = {1.0f, 1.0f, 0.0f, 1.0f};
                CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
                CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, colors, NULL, 2);
                CGPoint gradientStartPoint = CGPointMake(0.0f, 0.0f);
                CGPoint gradientEndPoint = CGPointMake(0.0f, (boundsSize.height*self.reflectionScale) + self.objectBorderWidth*2);
                CGContextDrawLinearGradient(gradientContext, gradient, gradientStartPoint,
                                            gradientEndPoint, kCGGradientDrawsAfterEndLocation);
                CGImageRef gradientMask = CGBitmapContextCreateImage(gradientContext);
                CGGradientRelease(gradient);
                CGColorSpaceRelease(colorSpace);
                UIGraphicsEndImageContext();
                
                //gradient image
                UIGraphicsBeginImageContextWithOptions(CGSizeMake(boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale), NO, 0.0f);
                CGContextRef context = UIGraphicsGetCurrentContext();
                CGContextClipToMask(context, CGRectMake(0.0f, 0.0f,
                                                        boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale), gradientMask);
                CGImageRelease(gradientMask);
                CGContextSetFillColorWithColor(context, [[UIColor blackColor] colorWithAlphaComponent:self.imageView.alpha].CGColor);
                CGContextFillRect(context, CGRectMake(0.0f, 0.0f,
                                                      boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale));
                gradientImage = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
            }
            
            UIGraphicsBeginImageContextWithOptions(self.superViewSize, NO, 2.0f);
            CGContextRef context = UIGraphicsGetCurrentContext();
            
            CGContextConcatCTM(UIGraphicsGetCurrentContext(), videoTransform);
            pnt = CGPointApplyAffineTransform(CGPointMake(self.center.x, self.center.y), CGAffineTransformInvert(videoTransform));
            
            //shadow
            if (self.objectShadowStyle == 2)
            {
                CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), CGSizeMake(self.objectShadowOffset, self.objectShadowOffset), self.objectShadowBlur, self.objectShadowColor.CGColor);
            }
            
            //draw image
            [image drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y - boundsSize.height*0.5f - self.objectBorderWidth, boundsSize.width + self.objectBorderWidth*2, boundsSize.height + self.objectBorderWidth*2) blendMode:kCGBlendModeNormal alpha:1.0f];
            
            if (self.isReflection)
            {
                [reflectionImage drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y + boundsSize.height*0.5f - self.objectBorderWidth + self.reflectionGap, boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale) blendMode:kCGBlendModeNormal alpha:1.0f];
            }
            
            //erase inner of path
            path = [self getErasePath:pnt];
            CGContextAddPath(context, path.CGPath);
            CGContextSetBlendMode(context, kCGBlendModeClear);
            CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
            CGContextFillPath(context);
            
            if (self.isReflection)
            {
                path = [self getErasePath:CGPointMake(pnt.x, pnt.y + boundsSize.height + self.reflectionGap)];
                CGContextAddPath(context, path.CGPath);
                CGContextSetBlendMode(context, kCGBlendModeClear);
                CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
                CGContextFillPath(context);
                
                //black gradient
                [gradientImage drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y + boundsSize.height*0.5f + self.reflectionGap, boundsSize.width + self.objectBorderWidth*2, boundsSize.height*self.reflectionScale + self.objectBorderWidth*2) blendMode:kCGBlendModeNormal alpha:1.0f];
            }
            
            CGContextConcatCTM(UIGraphicsGetCurrentContext(), CGAffineTransformInvert(videoTransform));
            
            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
            break;
        case 7: //two dots line
        {
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(image.size.width+self.objectBorderWidth*imageSize.width/originalBoundSize.width*2, image.size.height+self.objectBorderWidth*imageSize.width/originalBoundSize.width*2), NO, 2.0f);
            
            [image drawInRect:CGRectMake(self.objectBorderWidth*imageSize.width/originalBoundSize.width, self.objectBorderWidth*imageSize.width/originalBoundSize.width, image.size.width, image.size.height) blendMode:kCGBlendModeNormal alpha:self.imageView.alpha];
            
            UIImage* borderImage = [UIImage imageNamed:@"dotline_pattern"];
            borderImage = [borderImage rescaleImageToSize:CGSizeMake(self.objectBorderWidth*imageSize.width/originalBoundSize.width, self.objectBorderWidth*imageSize.width/originalBoundSize.width)];
            
            borderImage = [borderImage imageWithOverlayColor:[self.objectBorderColor colorWithAlphaComponent:self.imageView.alpha]];
            
            colorRef = [UIColor colorWithPatternImage:borderImage].CGColor;
            CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(),  colorRef);
            
            path = [self getPatternBorderPath:image.size];
            path.lineWidth = self.objectBorderWidth*imageSize.width/originalBoundSize.width;
            [path stroke];
            
            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            CGSize reflectionSize = CGSizeMake(boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2) * self.reflectionScale);
            CGRect reflectionRect = CGRectMake(0.0f, 0.0f, boundsSize.width + self.objectBorderWidth*2, boundsSize.height+self.objectBorderWidth*2);
            
            if (self.isReflection)
                reflectionImage = [self renderingReflectionImage:image size:reflectionSize rect:reflectionRect];
            
            if (self.isImitationPhoto && self.isReflection)
            {
                //gradient mask
                UIGraphicsBeginImageContextWithOptions(CGSizeMake(boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale), YES, 0.0f);
                CGContextRef gradientContext = UIGraphicsGetCurrentContext();
                CGFloat colors[] = {1.0f, 1.0f, 0.0f, 1.0f};
                CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
                CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, colors, NULL, 2);
                CGPoint gradientStartPoint = CGPointMake(0.0f, 0.0f);
                CGPoint gradientEndPoint = CGPointMake(0.0f, (boundsSize.height*self.reflectionScale) + self.objectBorderWidth*2);
                CGContextDrawLinearGradient(gradientContext, gradient, gradientStartPoint,
                                            gradientEndPoint, kCGGradientDrawsAfterEndLocation);
                CGImageRef gradientMask = CGBitmapContextCreateImage(gradientContext);
                CGGradientRelease(gradient);
                CGColorSpaceRelease(colorSpace);
                UIGraphicsEndImageContext();
                
                //gradient image
                UIGraphicsBeginImageContextWithOptions(CGSizeMake(boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale), NO, 0.0f);
                CGContextRef context = UIGraphicsGetCurrentContext();
                CGContextClipToMask(context, CGRectMake(0.0f, 0.0f,
                                                        boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale), gradientMask);
                CGImageRelease(gradientMask);
                CGContextSetFillColorWithColor(context, [[UIColor blackColor] colorWithAlphaComponent:self.imageView.alpha].CGColor);
                CGContextFillRect(context, CGRectMake(0.0f, 0.0f,
                                                      boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale));
                gradientImage = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
            }
            
            
            UIGraphicsBeginImageContextWithOptions(self.superViewSize, NO, 2.0f);
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextConcatCTM(UIGraphicsGetCurrentContext(), videoTransform);
            
            pnt = CGPointApplyAffineTransform(CGPointMake(self.center.x, self.center.y), CGAffineTransformInvert(videoTransform));
            
            if (self.objectShadowStyle == 2)
            {
                CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), CGSizeMake(self.objectShadowOffset, self.objectShadowOffset), self.objectShadowBlur, self.objectShadowColor.CGColor);
            }
            
            [image drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y - boundsSize.height*0.5f - self.objectBorderWidth, boundsSize.width + self.objectBorderWidth*2, boundsSize.height+self.objectBorderWidth*2) blendMode:kCGBlendModeNormal alpha:1.0f];
            
            if (self.isReflection)
            {
                [reflectionImage drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y + boundsSize.height*0.5f - self.objectBorderWidth + self.reflectionGap, boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale) blendMode:kCGBlendModeNormal alpha:1.0f];
            }
            
            //erase inner of path
            path = [self getErasePath:pnt];
            CGContextAddPath(context, path.CGPath);
            CGContextSetBlendMode(context, kCGBlendModeClear);
            CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
            CGContextFillPath(context);
            
            if (self.isReflection)
            {
                path = [self getErasePath:CGPointMake(pnt.x, pnt.y + boundsSize.height + self.reflectionGap)];
                CGContextAddPath(context, path.CGPath);
                CGContextSetBlendMode(context, kCGBlendModeClear);
                CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
                CGContextFillPath(context);
                
                //black gradient
                [gradientImage drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y + boundsSize.height*0.5f + self.reflectionGap, boundsSize.width + self.objectBorderWidth*2, boundsSize.height*self.reflectionScale + self.objectBorderWidth*2) blendMode:kCGBlendModeNormal alpha:1.0f];
            }
            
            CGContextConcatCTM(UIGraphicsGetCurrentContext(), CGAffineTransformInvert(videoTransform));
            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
            break;
        case 8: //jigsaw line
        {
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(image.size.width+self.objectBorderWidth*imageSize.width/originalBoundSize.width*2, image.size.height+self.objectBorderWidth*imageSize.width/originalBoundSize.width*2), NO, 2.0f);
            [image drawInRect:CGRectMake(self.objectBorderWidth*imageSize.width/originalBoundSize.width, self.objectBorderWidth*imageSize.width/originalBoundSize.width, image.size.width, image.size.height) blendMode:kCGBlendModeNormal alpha:self.imageView.alpha];
            UIImage* borderImage = [UIImage imageNamed:@"dotline_pattern"];
            
            borderImage = [borderImage imageWithOverlayColor:[self.objectBorderColor colorWithAlphaComponent:self.imageView.alpha]];
            
            colorRef = [UIColor colorWithPatternImage:borderImage].CGColor;
            CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(),  colorRef);
            
            path = [self getPatternBorderPath:image.size];
            path.lineWidth = self.objectBorderWidth*imageSize.width/originalBoundSize.width;
            [path stroke];
            
            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            CGSize reflectionSize = CGSizeMake(boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2) * self.reflectionScale);
            CGRect reflectionRect = CGRectMake(0.0f, 0.0f, boundsSize.width + self.objectBorderWidth*2, boundsSize.height+self.objectBorderWidth*2);
            
            if (self.isReflection)
                reflectionImage = [self renderingReflectionImage:image size:reflectionSize rect:reflectionRect];
            
            if (self.isImitationPhoto && self.isReflection)
            {
                //gradient mask
                UIGraphicsBeginImageContextWithOptions(CGSizeMake(boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale), YES, 0.0f);
                CGContextRef gradientContext = UIGraphicsGetCurrentContext();
                CGFloat colors[] = {1.0f, 1.0f, 0.0f, 1.0f};
                CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
                CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, colors, NULL, 2);
                CGPoint gradientStartPoint = CGPointMake(0.0f, 0.0f);
                CGPoint gradientEndPoint = CGPointMake(0.0f, (boundsSize.height*self.reflectionScale) + self.objectBorderWidth*2);
                CGContextDrawLinearGradient(gradientContext, gradient, gradientStartPoint,
                                            gradientEndPoint, kCGGradientDrawsAfterEndLocation);
                CGImageRef gradientMask = CGBitmapContextCreateImage(gradientContext);
                CGGradientRelease(gradient);
                CGColorSpaceRelease(colorSpace);
                UIGraphicsEndImageContext();
                
                //gradient image
                UIGraphicsBeginImageContextWithOptions(CGSizeMake(boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale), NO, 0.0f);
                CGContextRef context = UIGraphicsGetCurrentContext();
                CGContextClipToMask(context, CGRectMake(0.0f, 0.0f,
                                                        boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale), gradientMask);
                CGImageRelease(gradientMask);
                CGContextSetFillColorWithColor(context, [[UIColor blackColor] colorWithAlphaComponent:self.imageView.alpha].CGColor);
                CGContextFillRect(context, CGRectMake(0.0f, 0.0f,
                                                      boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale));
                gradientImage = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
            }
            
            UIGraphicsBeginImageContextWithOptions(self.superViewSize, NO, 2.0f);
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextConcatCTM(UIGraphicsGetCurrentContext(), videoTransform);
            
            pnt = CGPointApplyAffineTransform(CGPointMake(self.center.x, self.center.y), CGAffineTransformInvert(videoTransform));
            
            if (self.objectShadowStyle == 2)
            {
                CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), CGSizeMake(self.objectShadowOffset, self.objectShadowOffset), self.objectShadowBlur, self.objectShadowColor.CGColor);
            }
            
            [image drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y - boundsSize.height*0.5f - self.objectBorderWidth, boundsSize.width + self.objectBorderWidth*2, boundsSize.height+self.objectBorderWidth*2) blendMode:kCGBlendModeNormal alpha:1.0f];
            
            if (self.isReflection)
            {
                [reflectionImage drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y + boundsSize.height*0.5f - self.objectBorderWidth + self.reflectionGap, boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale) blendMode:kCGBlendModeNormal alpha:1.0f];
            }
            
            //erase inner of path
            path = [self getErasePath:pnt];
            CGContextAddPath(context, path.CGPath);
            CGContextSetBlendMode(context, kCGBlendModeClear);
            CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
            CGContextFillPath(context);
            
            if (self.isReflection)
            {
                path = [self getErasePath:CGPointMake(pnt.x, pnt.y + boundsSize.height + self.reflectionGap)];
                CGContextAddPath(context, path.CGPath);
                CGContextSetBlendMode(context, kCGBlendModeClear);
                CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
                CGContextFillPath(context);
                
                //black gradient
                [gradientImage drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y + boundsSize.height*0.5f + self.reflectionGap, boundsSize.width + self.objectBorderWidth*2, boundsSize.height*self.reflectionScale + self.objectBorderWidth*2) blendMode:kCGBlendModeNormal alpha:1.0f];
            }
            
            CGContextConcatCTM(UIGraphicsGetCurrentContext(), CGAffineTransformInvert(videoTransform));
            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
            break;
        case 9: //flower line
        {
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(image.size.width+self.objectBorderWidth*imageSize.width/originalBoundSize.width*2, image.size.height+self.objectBorderWidth*imageSize.width/originalBoundSize.width*2), NO, 2.0f);
            [image drawInRect:CGRectMake(self.objectBorderWidth*imageSize.width/originalBoundSize.width, self.objectBorderWidth*imageSize.width/originalBoundSize.width, image.size.width, image.size.height) blendMode:kCGBlendModeNormal alpha:self.imageView.alpha];
            UIImage* borderImage = [UIImage imageNamed:@"flower"];
            borderImage = [borderImage rescaleImageToSize:CGSizeMake(self.objectBorderWidth*imageSize.width/originalBoundSize.width, self.objectBorderWidth*imageSize.width/originalBoundSize.width)];
            
            borderImage = [borderImage imageWithOverlayColor:[self.objectBorderColor colorWithAlphaComponent:self.imageView.alpha]];
            
            colorRef = [UIColor colorWithPatternImage:borderImage].CGColor;
            CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(),  colorRef);
            
            path = [self getPatternBorderPath:image.size];
            path.lineWidth = self.objectBorderWidth*imageSize.width/originalBoundSize.width;
            [path stroke];
            
            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            CGSize reflectionSize = CGSizeMake(boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2) * self.reflectionScale);
            CGRect reflectionRect = CGRectMake(0.0f, 0.0f, boundsSize.width + self.objectBorderWidth*2, boundsSize.height+self.objectBorderWidth*2);
            
            if (self.isReflection)
            {
                reflectionImage = [self renderingReflectionImage:image size:reflectionSize rect:reflectionRect];
            }
            
            if (self.isImitationPhoto && self.isReflection)
            {
                //gradient mask
                UIGraphicsBeginImageContextWithOptions(CGSizeMake(boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale), YES, 0.0f);
                CGContextRef gradientContext = UIGraphicsGetCurrentContext();
                CGFloat colors[] = {1.0f, 1.0f, 0.0f, 1.0f};
                CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
                CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, colors, NULL, 2);
                CGPoint gradientStartPoint = CGPointMake(0.0f, 0.0f);
                CGPoint gradientEndPoint = CGPointMake(0.0f, (boundsSize.height*self.reflectionScale) + self.objectBorderWidth*2);
                CGContextDrawLinearGradient(gradientContext, gradient, gradientStartPoint,
                                            gradientEndPoint, kCGGradientDrawsAfterEndLocation);
                CGImageRef gradientMask = CGBitmapContextCreateImage(gradientContext);
                CGGradientRelease(gradient);
                CGColorSpaceRelease(colorSpace);
                UIGraphicsEndImageContext();
                
                //gradient image
                UIGraphicsBeginImageContextWithOptions(CGSizeMake(boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale), NO, 0.0f);
                CGContextRef context = UIGraphicsGetCurrentContext();
                CGContextClipToMask(context, CGRectMake(0.0f, 0.0f,
                                                        boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale), gradientMask);
                CGImageRelease(gradientMask);
                CGContextSetFillColorWithColor(context, [[UIColor blackColor] colorWithAlphaComponent:self.imageView.alpha].CGColor);
                CGContextFillRect(context, CGRectMake(0.0f, 0.0f,
                                                      boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale));
                gradientImage = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
            }
            
            UIGraphicsBeginImageContextWithOptions(self.superViewSize, NO, 2.0f);
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextConcatCTM(UIGraphicsGetCurrentContext(), videoTransform);
            
            pnt = CGPointApplyAffineTransform(CGPointMake(self.center.x, self.center.y), CGAffineTransformInvert(videoTransform));
            
            if (self.objectShadowStyle == 2)
            {
                CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), CGSizeMake(self.objectShadowOffset, self.objectShadowOffset), self.objectShadowBlur, self.objectShadowColor.CGColor);
            }
            
            [image drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y - boundsSize.height*0.5f - self.objectBorderWidth, boundsSize.width + self.objectBorderWidth*2, boundsSize.height+self.objectBorderWidth*2) blendMode:kCGBlendModeNormal alpha:1.0f];
            
            if (self.isReflection)
            {
                [reflectionImage drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y + boundsSize.height*0.5f - self.objectBorderWidth + self.reflectionGap, boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale) blendMode:kCGBlendModeNormal alpha:1.0f];
            }
            
            //erase inner of path
            path = [self getErasePath:pnt];
            CGContextAddPath(context, path.CGPath);
            CGContextSetBlendMode(context, kCGBlendModeClear);
            CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
            CGContextFillPath(context);
            
            if (self.isReflection)
            {
                path = [self getErasePath:CGPointMake(pnt.x, pnt.y + boundsSize.height + self.reflectionGap)];
                CGContextAddPath(context, path.CGPath);
                CGContextSetBlendMode(context, kCGBlendModeClear);
                CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
                CGContextFillPath(context);
                
                //black gradient
                [gradientImage drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y + boundsSize.height*0.5f + self.reflectionGap, boundsSize.width + self.objectBorderWidth*2, boundsSize.height*self.reflectionScale + self.objectBorderWidth*2) blendMode:kCGBlendModeNormal alpha:1.0f];
            }
            
            CGContextConcatCTM(UIGraphicsGetCurrentContext(), CGAffineTransformInvert(videoTransform));
            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
            break;
        case 10: //black circle line
        {
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(image.size.width+self.objectBorderWidth*imageSize.width/originalBoundSize.width*2, image.size.height+self.objectBorderWidth*imageSize.width/originalBoundSize.width*2), NO, 2.0f);
            [image drawInRect:CGRectMake(self.objectBorderWidth*imageSize.width/originalBoundSize.width, self.objectBorderWidth*imageSize.width/originalBoundSize.width, image.size.width, image.size.height) blendMode:kCGBlendModeNormal alpha:self.imageView.alpha];
            UIImage* borderImage = [UIImage imageNamed:@"circle"];
            borderImage = [borderImage rescaleImageToSize:CGSizeMake(self.objectBorderWidth*imageSize.width/originalBoundSize.width, self.objectBorderWidth*imageSize.width/originalBoundSize.width)];
            
            borderImage = [borderImage imageWithOverlayColor:[self.objectBorderColor colorWithAlphaComponent:self.imageView.alpha]];
            
            colorRef = [UIColor colorWithPatternImage:borderImage].CGColor;
            CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(),  colorRef);
            
            path = [self getPatternBorderPath:image.size];
            path.lineWidth = self.objectBorderWidth*imageSize.width/originalBoundSize.width;
            [path stroke];
            
            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            CGSize reflectionSize = CGSizeMake(boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2) * self.reflectionScale);
            CGRect reflectionRect = CGRectMake(0.0f, 0.0f, boundsSize.width + self.objectBorderWidth*2, boundsSize.height+self.objectBorderWidth*2);
            
            if (self.isReflection)
                reflectionImage = [self renderingReflectionImage:image size:reflectionSize rect:reflectionRect];
            
            if (self.isImitationPhoto && self.isReflection)
            {
                //gradient mask
                UIGraphicsBeginImageContextWithOptions(CGSizeMake(boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale), YES, 0.0f);
                CGContextRef gradientContext = UIGraphicsGetCurrentContext();
                CGFloat colors[] = {1.0f, 1.0f, 0.0f, 1.0f};
                CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
                CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, colors, NULL, 2);
                CGPoint gradientStartPoint = CGPointMake(0.0f, 0.0f);
                CGPoint gradientEndPoint = CGPointMake(0.0f, (boundsSize.height*self.reflectionScale) + self.objectBorderWidth*2);
                CGContextDrawLinearGradient(gradientContext, gradient, gradientStartPoint,
                                            gradientEndPoint, kCGGradientDrawsAfterEndLocation);
                CGImageRef gradientMask = CGBitmapContextCreateImage(gradientContext);
                CGGradientRelease(gradient);
                CGColorSpaceRelease(colorSpace);
                UIGraphicsEndImageContext();
                
                //gradient image
                UIGraphicsBeginImageContextWithOptions(CGSizeMake(boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale), NO, 0.0f);
                CGContextRef context = UIGraphicsGetCurrentContext();
                CGContextClipToMask(context, CGRectMake(0.0f, 0.0f,
                                                        boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale), gradientMask);
                CGImageRelease(gradientMask);
                CGContextSetFillColorWithColor(context, [[UIColor blackColor] colorWithAlphaComponent:self.imageView.alpha].CGColor);
                CGContextFillRect(context, CGRectMake(0.0f, 0.0f,
                                                      boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale));
                gradientImage = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
            }
            
            UIGraphicsBeginImageContextWithOptions(self.superViewSize, NO, 2.0f);
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextConcatCTM(UIGraphicsGetCurrentContext(), videoTransform);
            
            pnt = CGPointApplyAffineTransform(CGPointMake(self.center.x, self.center.y), CGAffineTransformInvert(videoTransform));
            
            if (self.objectShadowStyle == 2)
            {
                CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), CGSizeMake(self.objectShadowOffset, self.objectShadowOffset), self.objectShadowBlur, self.objectShadowColor.CGColor);
            }
            
            [image drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y - boundsSize.height*0.5f - self.objectBorderWidth, boundsSize.width + self.objectBorderWidth*2, boundsSize.height+self.objectBorderWidth*2) blendMode:kCGBlendModeNormal alpha:1.0f];
            
            if (self.isReflection)
            {
                [reflectionImage drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y + boundsSize.height*0.5f - self.objectBorderWidth + self.reflectionGap, boundsSize.width + self.objectBorderWidth*2, (boundsSize.height + self.objectBorderWidth*2)*self.reflectionScale) blendMode:kCGBlendModeNormal alpha:1.0f];
            }
            
            //erase inner of path
            path = [self getErasePath:pnt];
            CGContextAddPath(context, path.CGPath);
            CGContextSetBlendMode(context, kCGBlendModeClear);
            CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
            CGContextFillPath(context);
            CGContextRestoreGState(context);
            
            if (self.isReflection)
            {
                path = [self getErasePath:CGPointMake(pnt.x, pnt.y + boundsSize.height + self.reflectionGap)];
                CGContextAddPath(context, path.CGPath);
                CGContextSetBlendMode(context, kCGBlendModeClear);
                CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
                CGContextFillPath(context);
                
                //black gradient
                [gradientImage drawInRect:CGRectMake(pnt.x - boundsSize.width*0.5f - self.objectBorderWidth, pnt.y + boundsSize.height*0.5f + self.reflectionGap, boundsSize.width + self.objectBorderWidth*2, boundsSize.height*self.reflectionScale + self.objectBorderWidth*2) blendMode:kCGBlendModeNormal alpha:1.0f];
            }
            
            CGContextConcatCTM(UIGraphicsGetCurrentContext(), CGAffineTransformInvert(videoTransform));
            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
            break;
        default:
            break;
    }
    
    return image;
}


#pragma mark -
#pragma mark - Render UITextView to UIImageView


-(UIImage*) renderingTextView
{
    UIImage* image = nil;
    UIImage* reflectionImage = nil;
    
    CGColorRef colorRef = nil;
    CGPoint pnt = CGPointZero;
    UIBezierPath* path;
    CGSize reflectionSize = CGSizeZero;
    CGRect reflectionRect = CGRectZero;
    
    UIGraphicsBeginImageContextWithOptions(self.textView.bounds.size, NO, 2.0f);
    self.textView.layer.shadowColor = [UIColor clearColor].CGColor;
    [self.textView.layer renderInContext:UIGraphicsGetCurrentContext()];

    if (self.objectShadowStyle == 2)
        self.textView.layer.shadowColor = self.objectShadowColor.CGColor;
    
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if (self.objectCornerRadius != 0.0f)
        image = [self renderTextWithCorner:image];

    switch (self.objectBorderStyle)
    {
        case 1: //no outline
        {
            reflectionSize = CGSizeMake(self.bounds.size.width, self.bounds.size.height * self.reflectionScale);
            reflectionRect = CGRectMake(0.0f, 0.0f, self.bounds.size.width, self.bounds.size.height);
    
            if (self.isReflection)
                reflectionImage = [self renderingReflectionImage:image size:reflectionSize rect:reflectionRect];

            UIGraphicsBeginImageContextWithOptions(self.superViewSize, NO, 2.0f);
            CGContextConcatCTM(UIGraphicsGetCurrentContext(), self.transform);
            pnt = CGPointApplyAffineTransform(CGPointMake(self.center.x, self.center.y), CGAffineTransformInvert(self.transform));

            if (self.objectShadowStyle == 2)
            {
                CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), CGSizeMake(self.objectShadowOffset, self.objectShadowOffset), self.objectShadowBlur, self.objectShadowColor.CGColor);
            }
            
            [image drawInRect:CGRectMake(pnt.x - self.bounds.size.width*0.5f, pnt.y - self.bounds.size.height*0.5f, self.bounds.size.width, self.bounds.size.height)  blendMode:kCGBlendModeNormal alpha:1.0f];
            
            if (self.isReflection)
            {
                [reflectionImage drawInRect:CGRectMake(pnt.x - self.bounds.size.width*0.5f, pnt.y + self.bounds.size.height*0.5f + self.reflectionGap, reflectionSize.width, reflectionSize.height) blendMode:kCGBlendModeNormal alpha:self.reflectionAlpha];
            }

            CGContextConcatCTM(UIGraphicsGetCurrentContext(), CGAffineTransformInvert(self.transform));
            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
            break;
        case 2: //line
        {
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(self.textView.frame.size.width+self.objectBorderWidth*2, self.textView.frame.size.height+self.objectBorderWidth*2), NO, 2.0f);
            [image drawInRect:CGRectMake(self.objectBorderWidth, self.objectBorderWidth, self.textView.frame.size.width, self.textView.frame.size.height)  blendMode:kCGBlendModeNormal alpha:1.0f];
            
            CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(),  [self.objectBorderColor colorWithAlphaComponent:self.textView.alpha].CGColor);
            
            path = [self getTextPatternBorderPath];
            path.lineWidth = self.objectBorderWidth;
            [path stroke];
            
            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            reflectionSize = CGSizeMake(self.bounds.size.width + self.objectBorderWidth*2, (self.bounds.size.height + self.objectBorderWidth*2) * self.reflectionScale);
            reflectionRect = CGRectMake(0.0f, 0.0f, self.bounds.size.width + self.objectBorderWidth*2, self.bounds.size.height+self.objectBorderWidth*2);
            
            if (self.isReflection)
            {
                reflectionImage = [self renderingReflectionImage:image size:reflectionSize rect:reflectionRect];
            }
            
            UIGraphicsBeginImageContextWithOptions(self.superViewSize, NO, 2.0f);
            CGContextConcatCTM(UIGraphicsGetCurrentContext(), self.transform);
            pnt = CGPointApplyAffineTransform(CGPointMake(self.center.x, self.center.y), CGAffineTransformInvert(self.transform));
            
            if (self.objectShadowStyle == 2)
            {
                CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), CGSizeMake(self.objectShadowOffset, self.objectShadowOffset), self.objectShadowBlur, self.objectShadowColor.CGColor);
            }
            
            [image drawInRect:CGRectMake(pnt.x - self.bounds.size.width*0.5f - self.objectBorderWidth, pnt.y - self.bounds.size.height*0.5f - self.objectBorderWidth, self.bounds.size.width + self.objectBorderWidth*2, self.bounds.size.height+self.objectBorderWidth*2) blendMode:kCGBlendModeNormal alpha:1.0f];
            
            if (self.isReflection)
            {
                [reflectionImage drawInRect:CGRectMake(pnt.x - self.bounds.size.width*0.5f - self.objectBorderWidth, pnt.y + self.bounds.size.height*0.5f + self.reflectionGap, reflectionSize.width, reflectionSize.height) blendMode:kCGBlendModeNormal alpha:self.reflectionAlpha];
            }
            
            CGContextConcatCTM(UIGraphicsGetCurrentContext(), CGAffineTransformInvert(self.transform));
            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
            break;
        case 3: //shot dot line
        {
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(self.textView.frame.size.width+self.objectBorderWidth*2, self.textView.frame.size.height+self.objectBorderWidth*2), NO, 2.0f);
            [image drawInRect:CGRectMake(self.objectBorderWidth, self.objectBorderWidth, self.textView.frame.size.width, self.textView.frame.size.height)  blendMode:kCGBlendModeNormal alpha:1.0f];
            
            CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(),  [self.objectBorderColor colorWithAlphaComponent:self.textView.alpha].CGColor);
            
            CGFloat pattern[] = {self.objectBorderWidth, self.objectBorderWidth};
            CGContextSetLineDash(UIGraphicsGetCurrentContext(), 0.0f, pattern, 2);
            
            path = [self getTextPatternBorderPath];
            path.lineWidth = self.objectBorderWidth;
            path.lineCapStyle = kCGLineCapButt;
            path.lineJoinStyle = kCGLineJoinMiter;
            [path stroke];
            
            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            reflectionSize = CGSizeMake(self.bounds.size.width + self.objectBorderWidth*2, (self.bounds.size.height + self.objectBorderWidth*2) * self.reflectionScale);
            reflectionRect = CGRectMake(0.0f, 0.0f, self.bounds.size.width + self.objectBorderWidth*2, self.bounds.size.height+self.objectBorderWidth*2);
            
            if (self.isReflection)
            {
                reflectionImage = [self renderingReflectionImage:image size:reflectionSize rect:reflectionRect];
            }
            
            UIGraphicsBeginImageContextWithOptions(self.superViewSize, NO, 2.0f);
            CGContextConcatCTM(UIGraphicsGetCurrentContext(), self.transform);
            pnt = CGPointApplyAffineTransform(CGPointMake(self.center.x, self.center.y), CGAffineTransformInvert(self.transform));
            
            if (self.objectShadowStyle == 2)
            {
                CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), CGSizeMake(self.objectShadowOffset, self.objectShadowOffset), self.objectShadowBlur, self.objectShadowColor.CGColor);
            }
            
            [image drawInRect:CGRectMake(pnt.x - self.bounds.size.width*0.5f - self.objectBorderWidth, pnt.y - self.bounds.size.height*0.5f - self.objectBorderWidth, self.bounds.size.width + self.objectBorderWidth*2, self.bounds.size.height+self.objectBorderWidth*2) blendMode:kCGBlendModeNormal alpha:1.0f];
            
            if (self.isReflection)
            {
                [reflectionImage drawInRect:CGRectMake(pnt.x - self.bounds.size.width*0.5f - self.objectBorderWidth, pnt.y + self.bounds.size.height*0.5f + self.reflectionGap, reflectionSize.width, reflectionSize.height) blendMode:kCGBlendModeNormal alpha:self.reflectionAlpha];
            }
            
            CGContextConcatCTM(UIGraphicsGetCurrentContext(), CGAffineTransformInvert(self.transform));
            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
            break;
        case 4: //middle dot line
        {
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(self.textView.frame.size.width+self.objectBorderWidth*2, self.textView.frame.size.height+self.objectBorderWidth*2), NO, 2.0f);
            [image drawInRect:CGRectMake(self.objectBorderWidth, self.objectBorderWidth, self.textView.frame.size.width, self.textView.frame.size.height)  blendMode:kCGBlendModeNormal alpha:1.0f];
            
            CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(),  [self.objectBorderColor colorWithAlphaComponent:self.textView.alpha].CGColor);
            
            CGFloat middleDotLinePattern[] = {1.5f*self.objectBorderWidth, 1.5f*self.objectBorderWidth};
            CGContextSetLineDash(UIGraphicsGetCurrentContext(), 0.0f, middleDotLinePattern, 2);
            
            path = [self getTextPatternBorderPath];
            path.lineWidth = self.objectBorderWidth;
            path.lineCapStyle = kCGLineCapButt;
            path.lineJoinStyle = kCGLineJoinMiter;
            [path stroke];
            
            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            reflectionSize = CGSizeMake(self.bounds.size.width + self.objectBorderWidth*2, (self.bounds.size.height + self.objectBorderWidth*2) * self.reflectionScale);
            reflectionRect = CGRectMake(0.0f, 0.0f, self.bounds.size.width + self.objectBorderWidth*2, self.bounds.size.height+self.objectBorderWidth*2);
            
            if (self.isReflection)
            {
                reflectionImage = [self renderingReflectionImage:image size:reflectionSize rect:reflectionRect];
            }
            
            UIGraphicsBeginImageContextWithOptions(self.superViewSize, NO, 2.0f);
            CGContextConcatCTM(UIGraphicsGetCurrentContext(), self.transform);
            pnt = CGPointApplyAffineTransform(CGPointMake(self.center.x, self.center.y), CGAffineTransformInvert(self.transform));
            
            if (self.objectShadowStyle == 2)
            {
                CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), CGSizeMake(self.objectShadowOffset, self.objectShadowOffset), self.objectShadowBlur, self.objectShadowColor.CGColor);
            }
            
            [image drawInRect:CGRectMake(pnt.x - self.bounds.size.width*0.5f - self.objectBorderWidth, pnt.y - self.bounds.size.height*0.5f - self.objectBorderWidth, self.bounds.size.width + self.objectBorderWidth*2, self.bounds.size.height+self.objectBorderWidth*2) blendMode:kCGBlendModeNormal alpha:1.0f];
            
            if (self.isReflection)
            {
                [reflectionImage drawInRect:CGRectMake(pnt.x - self.bounds.size.width*0.5f - self.objectBorderWidth, pnt.y + self.bounds.size.height*0.5f + self.reflectionGap, reflectionSize.width, reflectionSize.height) blendMode:kCGBlendModeNormal alpha:self.reflectionAlpha];
            }
            
            CGContextConcatCTM(UIGraphicsGetCurrentContext(), CGAffineTransformInvert(self.transform));
            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
            break;
        case 5: //long dot line
        {
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(self.textView.frame.size.width+self.objectBorderWidth*2, self.textView.frame.size.height+self.objectBorderWidth*2), NO, 2.0f);
            [image drawInRect:CGRectMake(self.objectBorderWidth, self.objectBorderWidth, self.textView.frame.size.width, self.textView.frame.size.height)  blendMode:kCGBlendModeNormal alpha:1.0f];
            
            CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(),  [self.objectBorderColor colorWithAlphaComponent:self.textView.alpha].CGColor);
            
            CGFloat longDotLinePattern[] = {3.0f*self.objectBorderWidth, 3.0f*self.objectBorderWidth};
            CGContextSetLineDash(UIGraphicsGetCurrentContext(), 0.0f, longDotLinePattern, 2);
            
            path = [self getTextPatternBorderPath];
            path.lineWidth = self.objectBorderWidth;
            path.lineCapStyle = kCGLineCapButt;
            path.lineJoinStyle = kCGLineJoinMiter;
            [path stroke];
            
            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            reflectionSize = CGSizeMake(self.bounds.size.width + self.objectBorderWidth*2, (self.bounds.size.height + self.objectBorderWidth*2) * self.reflectionScale);
            reflectionRect = CGRectMake(0.0f, 0.0f, self.bounds.size.width + self.objectBorderWidth*2, self.bounds.size.height+self.objectBorderWidth*2);
            
            if (self.isReflection)
            {
                reflectionImage = [self renderingReflectionImage:image size:reflectionSize rect:reflectionRect];
            }
            
            UIGraphicsBeginImageContextWithOptions(self.superViewSize, NO, 2.0f);
            CGContextConcatCTM(UIGraphicsGetCurrentContext(), self.transform);
            pnt = CGPointApplyAffineTransform(CGPointMake(self.center.x, self.center.y), CGAffineTransformInvert(self.transform));
            
            if (self.objectShadowStyle == 2)
            {
                CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), CGSizeMake(self.objectShadowOffset, self.objectShadowOffset), self.objectShadowBlur, self.objectShadowColor.CGColor);
            }
            
            [image drawInRect:CGRectMake(pnt.x - self.bounds.size.width*0.5f - self.objectBorderWidth, pnt.y - self.bounds.size.height*0.5f - self.objectBorderWidth, self.bounds.size.width + self.objectBorderWidth*2, self.bounds.size.height+self.objectBorderWidth*2) blendMode:kCGBlendModeNormal alpha:1.0f];
            
            if (self.isReflection)
            {
                [reflectionImage drawInRect:CGRectMake(pnt.x - self.bounds.size.width*0.5f - self.objectBorderWidth, pnt.y + self.bounds.size.height*0.5f + self.reflectionGap, reflectionSize.width, reflectionSize.height) blendMode:kCGBlendModeNormal alpha:self.reflectionAlpha];
            }
            
            CGContextConcatCTM(UIGraphicsGetCurrentContext(), CGAffineTransformInvert(self.transform));
            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
            break;
        case 6: //circle dot line
        {
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(self.textView.frame.size.width+self.objectBorderWidth*2, self.textView.frame.size.height+self.objectBorderWidth*2), NO, 2.0f);
            [image drawInRect:CGRectMake(self.objectBorderWidth, self.objectBorderWidth, self.textView.frame.size.width, self.textView.frame.size.height)  blendMode:kCGBlendModeNormal alpha:1.0f];
            
            CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(),  [self.objectBorderColor colorWithAlphaComponent:self.textView.alpha].CGColor);
            
            CGFloat circleDotLinePattern[] = {0.1f, 2.0f*self.objectBorderWidth};
            CGContextSetLineDash(UIGraphicsGetCurrentContext(), 0.0f, circleDotLinePattern, 2);
            
            path = [self getTextPatternBorderPath];
            path.lineWidth = self.objectBorderWidth;
            path.lineCapStyle = kCGLineCapRound;
            path.lineJoinStyle = kCGLineJoinMiter;
            [path stroke];
            
            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            reflectionSize = CGSizeMake(self.bounds.size.width + self.objectBorderWidth*2, (self.bounds.size.height + self.objectBorderWidth*2) * self.reflectionScale);
            reflectionRect = CGRectMake(0.0f, 0.0f, self.bounds.size.width + self.objectBorderWidth*2, self.bounds.size.height+self.objectBorderWidth*2);
            
            if (self.isReflection)
            {
                reflectionImage = [self renderingReflectionImage:image size:reflectionSize rect:reflectionRect];
            }
            
            UIGraphicsBeginImageContextWithOptions(self.superViewSize, NO, 2.0f);
            CGContextConcatCTM(UIGraphicsGetCurrentContext(), self.transform);
            pnt = CGPointApplyAffineTransform(CGPointMake(self.center.x, self.center.y), CGAffineTransformInvert(self.transform));
            
            if (self.objectShadowStyle == 2)
            {
                CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), CGSizeMake(self.objectShadowOffset, self.objectShadowOffset), self.objectShadowBlur, self.objectShadowColor.CGColor);
            }
            
            [image drawInRect:CGRectMake(pnt.x - self.bounds.size.width*0.5f - self.objectBorderWidth, pnt.y - self.bounds.size.height*0.5f - self.objectBorderWidth, self.bounds.size.width + self.objectBorderWidth*2, self.bounds.size.height+self.objectBorderWidth*2) blendMode:kCGBlendModeNormal alpha:1.0f];
            
            if (self.isReflection)
            {
                [reflectionImage drawInRect:CGRectMake(pnt.x - self.bounds.size.width*0.5f - self.objectBorderWidth, pnt.y + self.bounds.size.height*0.5f + self.reflectionGap, reflectionSize.width, reflectionSize.height) blendMode:kCGBlendModeNormal alpha:self.reflectionAlpha];
            }
            
            CGContextConcatCTM(UIGraphicsGetCurrentContext(), CGAffineTransformInvert(self.transform));
            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
            break;
        case 7: //two dots line
        {
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(self.textView.frame.size.width+self.objectBorderWidth*2, self.textView.frame.size.height+self.objectBorderWidth*2), NO, 2.0f);

            [image drawInRect:CGRectMake(self.objectBorderWidth, self.objectBorderWidth, self.textView.frame.size.width, self.textView.frame.size.height)  blendMode:kCGBlendModeNormal alpha:1.0f];
            
            UIImage* borderImage = [UIImage imageNamed:@"dotline_pattern"];
            borderImage = [borderImage rescaleImageToSize:CGSizeMake(self.objectBorderWidth, self.objectBorderWidth)];
            borderImage = [borderImage imageWithOverlayColor:[self.objectBorderColor colorWithAlphaComponent:self.textView.alpha]];
            colorRef = [UIColor colorWithPatternImage:borderImage].CGColor;
            CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(),  colorRef);
            
            path = [self getTextPatternBorderPath];
            path.lineWidth = self.objectBorderWidth;
            [path stroke];
            
            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            reflectionSize = CGSizeMake(self.bounds.size.width + self.objectBorderWidth*2, (self.bounds.size.height + self.objectBorderWidth*2) * self.reflectionScale);
            reflectionRect = CGRectMake(0.0f, 0.0f, self.bounds.size.width + self.objectBorderWidth*2, self.bounds.size.height+self.objectBorderWidth*2);
            
            if (self.isReflection)
            {
                reflectionImage = [self renderingReflectionImage:image size:reflectionSize rect:reflectionRect];
            }

            UIGraphicsBeginImageContextWithOptions(self.superViewSize, NO, 2.0f);
            CGContextConcatCTM(UIGraphicsGetCurrentContext(), self.transform);
            pnt = CGPointApplyAffineTransform(CGPointMake(self.center.x, self.center.y), CGAffineTransformInvert(self.transform));
            
            if (self.objectShadowStyle == 2)
            {
                CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), CGSizeMake(self.objectShadowOffset, self.objectShadowOffset), self.objectShadowBlur, self.objectShadowColor.CGColor);
            }
            
            [image drawInRect:CGRectMake(pnt.x - self.bounds.size.width*0.5f - self.objectBorderWidth, pnt.y - self.bounds.size.height*0.5f - self.objectBorderWidth, self.bounds.size.width + self.objectBorderWidth*2, self.bounds.size.height+self.objectBorderWidth*2) blendMode:kCGBlendModeNormal alpha:1.0f];
            
            if (self.isReflection)
            {
                [reflectionImage drawInRect:CGRectMake(pnt.x - self.bounds.size.width*0.5f - self.objectBorderWidth, pnt.y + self.bounds.size.height*0.5f + self.reflectionGap, reflectionSize.width, reflectionSize.height) blendMode:kCGBlendModeNormal alpha:self.reflectionAlpha];
            }

            CGContextConcatCTM(UIGraphicsGetCurrentContext(), CGAffineTransformInvert(self.transform));
            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
            break;
        case 8: //jigsaw line
        {
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(self.textView.frame.size.width+self.objectBorderWidth*2, self.textView.frame.size.height+self.objectBorderWidth*2), NO, 2.0f);
            
            [image drawInRect:CGRectMake(self.objectBorderWidth, self.objectBorderWidth, self.textView.frame.size.width, self.textView.frame.size.height)  blendMode:kCGBlendModeNormal alpha:1.0f];
            
            UIImage* borderImage = [UIImage imageNamed:@"dotline_pattern"];
            borderImage = [borderImage imageWithOverlayColor:[self.objectBorderColor colorWithAlphaComponent:self.textView.alpha]];
            colorRef = [UIColor colorWithPatternImage:borderImage].CGColor;
            CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(),  colorRef);

            path = [self getTextPatternBorderPath];
            path.lineWidth = self.objectBorderWidth;
            [path stroke];

            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            reflectionSize = CGSizeMake(self.bounds.size.width + self.objectBorderWidth*2, (self.bounds.size.height + self.objectBorderWidth*2) * self.reflectionScale);
            reflectionRect = CGRectMake(0.0f, 0.0f, self.bounds.size.width + self.objectBorderWidth*2, self.bounds.size.height+self.objectBorderWidth*2);
            
            if (self.isReflection)
            {
                reflectionImage = [self renderingReflectionImage:image size:reflectionSize rect:reflectionRect];
            }

            UIGraphicsBeginImageContextWithOptions(self.superViewSize, NO, 2.0f);
            CGContextConcatCTM(UIGraphicsGetCurrentContext(), self.transform);
            pnt = CGPointApplyAffineTransform(CGPointMake(self.center.x, self.center.y), CGAffineTransformInvert(self.transform));
            
            if (self.objectShadowStyle == 2)
            {
                CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), CGSizeMake(self.objectShadowOffset, self.objectShadowOffset), self.objectShadowBlur, self.objectShadowColor.CGColor);
            }
            
            [image drawInRect:CGRectMake(pnt.x - self.bounds.size.width*0.5f - self.objectBorderWidth, pnt.y - self.bounds.size.height*0.5f - self.objectBorderWidth, self.bounds.size.width + self.objectBorderWidth*2, self.bounds.size.height+self.objectBorderWidth*2) blendMode:kCGBlendModeNormal alpha:1.0f];
            
            if (self.isReflection)
            {
                [reflectionImage drawInRect:CGRectMake(pnt.x - self.bounds.size.width*0.5f - self.objectBorderWidth, pnt.y + self.bounds.size.height*0.5f + self.reflectionGap, reflectionSize.width, reflectionSize.height) blendMode:kCGBlendModeNormal alpha:self.reflectionAlpha];
            }

            CGContextConcatCTM(UIGraphicsGetCurrentContext(), CGAffineTransformInvert(self.transform));
            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
            break;
        case 9: //flower line
        {
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(self.textView.frame.size.width+self.objectBorderWidth*2, self.textView.frame.size.height+self.objectBorderWidth*2), NO, 2.0f);
            
            [image drawInRect:CGRectMake(self.objectBorderWidth, self.objectBorderWidth, self.textView.frame.size.width, self.textView.frame.size.height)  blendMode:kCGBlendModeNormal alpha:1.0f];
            
            UIImage* borderImage = [UIImage imageNamed:@"flower"];
            borderImage = [borderImage rescaleImageToSize:CGSizeMake(self.objectBorderWidth, self.objectBorderWidth)];
            borderImage = [borderImage imageWithOverlayColor:[self.objectBorderColor colorWithAlphaComponent:self.textView.alpha]];
            colorRef = [UIColor colorWithPatternImage:borderImage].CGColor;
            CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(),  colorRef);

            path = [self getTextPatternBorderPath];
            path.lineWidth = self.objectBorderWidth;
            [path stroke];

            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            reflectionSize = CGSizeMake(self.bounds.size.width + self.objectBorderWidth*2, (self.bounds.size.height + self.objectBorderWidth*2) * self.reflectionScale);
            reflectionRect = CGRectMake(0.0f, 0.0f, self.bounds.size.width + self.objectBorderWidth*2, self.bounds.size.height+self.objectBorderWidth*2);
            
            if (self.isReflection)
            {
                reflectionImage = [self renderingReflectionImage:image size:reflectionSize rect:reflectionRect];
            }

            UIGraphicsBeginImageContextWithOptions(self.superViewSize, NO, 2.0f);
            CGContextConcatCTM(UIGraphicsGetCurrentContext(), self.transform);
            pnt = CGPointApplyAffineTransform(CGPointMake(self.center.x, self.center.y), CGAffineTransformInvert(self.transform));
            
            if (self.objectShadowStyle == 2)
            {
                CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), CGSizeMake(self.objectShadowOffset, self.objectShadowOffset), self.objectShadowBlur, self.objectShadowColor.CGColor);
            }
            
            [image drawInRect:CGRectMake(pnt.x - self.bounds.size.width*0.5f - self.objectBorderWidth, pnt.y - self.bounds.size.height*0.5f - self.objectBorderWidth, self.bounds.size.width + self.objectBorderWidth*2, self.bounds.size.height+self.objectBorderWidth*2) blendMode:kCGBlendModeNormal alpha:1.0f];
            
            if (self.isReflection)
            {
                [reflectionImage drawInRect:CGRectMake(pnt.x - self.bounds.size.width*0.5f - self.objectBorderWidth, pnt.y + self.bounds.size.height*0.5f + self.reflectionGap, reflectionSize.width, reflectionSize.height) blendMode:kCGBlendModeNormal alpha:self.reflectionAlpha];
            }

            CGContextConcatCTM(UIGraphicsGetCurrentContext(), CGAffineTransformInvert(self.transform));
            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
            break;
        case 10: //black circle line
        {
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(self.textView.frame.size.width+self.objectBorderWidth*2, self.textView.frame.size.height+self.objectBorderWidth*2), NO, 2.0f);
            
            [image drawInRect:CGRectMake(self.objectBorderWidth, self.objectBorderWidth, self.textView.frame.size.width, self.textView.frame.size.height)  blendMode:kCGBlendModeNormal alpha:1.0f];
            
            UIImage* borderImage = [UIImage imageNamed:@"circle"];
            borderImage = [borderImage rescaleImageToSize:CGSizeMake(self.objectBorderWidth, self.objectBorderWidth)];
            borderImage = [borderImage imageWithOverlayColor:[self.objectBorderColor colorWithAlphaComponent:self.textView.alpha]];
            colorRef = [UIColor colorWithPatternImage:borderImage].CGColor;
            CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(),  colorRef);

            path = [self getTextPatternBorderPath];
            path.lineWidth = self.objectBorderWidth;
            [path stroke];

            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            reflectionSize = CGSizeMake(self.bounds.size.width + self.objectBorderWidth*2, (self.bounds.size.height + self.objectBorderWidth*2) * self.reflectionScale);
            reflectionRect = CGRectMake(0.0f, 0.0f, self.bounds.size.width + self.objectBorderWidth*2, self.bounds.size.height+self.objectBorderWidth*2);
            
            if (self.isReflection)
            {
                reflectionImage = [self renderingReflectionImage:image size:reflectionSize rect:reflectionRect];
            }

            UIGraphicsBeginImageContextWithOptions(self.superViewSize, NO, 2.0f);
            CGContextConcatCTM(UIGraphicsGetCurrentContext(), self.transform);
            pnt = CGPointApplyAffineTransform(CGPointMake(self.center.x, self.center.y), CGAffineTransformInvert(self.transform));
            
            if (self.objectShadowStyle == 2)
            {
                CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), CGSizeMake(self.objectShadowOffset, self.objectShadowOffset), self.objectShadowBlur, self.objectShadowColor.CGColor);
            }
            
            [image drawInRect:CGRectMake(pnt.x - self.bounds.size.width*0.5f - self.objectBorderWidth, pnt.y - self.bounds.size.height*0.5f - self.objectBorderWidth, self.bounds.size.width + self.objectBorderWidth*2, self.bounds.size.height+self.objectBorderWidth*2) blendMode:kCGBlendModeNormal alpha:1.0f];
            
            if (self.isReflection)
            {
                [reflectionImage drawInRect:CGRectMake(pnt.x - self.bounds.size.width*0.5f - self.objectBorderWidth, pnt.y + self.bounds.size.height*0.5f + self.reflectionGap, reflectionSize.width, reflectionSize.height) blendMode:kCGBlendModeNormal alpha:self.reflectionAlpha];
            }

            CGContextConcatCTM(UIGraphicsGetCurrentContext(), CGAffineTransformInvert(self.transform));
            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
            break;
    }
    
    return image;
}


-(UIImage*) renderingTextViewOutlineAndShadow
{
    UIImage* image = nil;
    UIImage* reflectionImage = nil;
    
    CGColorRef colorRef = nil;
    CGPoint pnt = CGPointZero;
    UIBezierPath* path;
    CGSize reflectionSize = CGSizeZero;
    CGRect reflectionRect = CGRectZero;
    
    self.textView.hidden = YES;
    
    UIGraphicsBeginImageContextWithOptions(self.textView.bounds.size, NO, 2.0f);
    self.textView.layer.shadowColor = [UIColor clearColor].CGColor;
    [self.textView.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    if (self.objectShadowStyle == 2)
        self.textView.layer.shadowColor = self.objectShadowColor.CGColor;
    
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.textView.hidden = NO;
    
    if (self.objectCornerRadius != 0.0f)
        image = [self renderTextWithCorner:image];
    
    switch (self.objectBorderStyle)
    {
        case 1: //no outline
        {
            reflectionSize = CGSizeMake(self.bounds.size.width, self.bounds.size.height * self.reflectionScale);
            reflectionRect = CGRectMake(0.0f, 0.0f, self.bounds.size.width, self.bounds.size.height);
            
            if (self.isReflection)
                reflectionImage = [self renderingReflectionImage:image size:reflectionSize rect:reflectionRect];
            
            UIGraphicsBeginImageContextWithOptions(self.superViewSize, NO, 2.0f);
            CGContextConcatCTM(UIGraphicsGetCurrentContext(), self.transform);
            pnt = CGPointApplyAffineTransform(CGPointMake(self.center.x, self.center.y), CGAffineTransformInvert(self.transform));
            
            if (self.objectShadowStyle == 2)
            {
                CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), CGSizeMake(self.objectShadowOffset, self.objectShadowOffset), self.objectShadowBlur, self.objectShadowColor.CGColor);
            }
            
            [image drawInRect:CGRectMake(pnt.x - self.bounds.size.width*0.5f, pnt.y - self.bounds.size.height*0.5f, self.bounds.size.width, self.bounds.size.height)  blendMode:kCGBlendModeNormal alpha:1.0f];
            
            if (self.isReflection)
            {
                [reflectionImage drawInRect:CGRectMake(pnt.x - self.bounds.size.width*0.5f, pnt.y + self.bounds.size.height*0.5f + self.reflectionGap, reflectionSize.width, reflectionSize.height) blendMode:kCGBlendModeNormal alpha:self.reflectionAlpha];
            }
            
            CGContextConcatCTM(UIGraphicsGetCurrentContext(), CGAffineTransformInvert(self.transform));
            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
            break;
        case 2: //line
        {
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(self.textView.frame.size.width+self.objectBorderWidth*2, self.textView.frame.size.height+self.objectBorderWidth*2), NO, 2.0f);
            [image drawInRect:CGRectMake(self.objectBorderWidth, self.objectBorderWidth, self.textView.frame.size.width, self.textView.frame.size.height)  blendMode:kCGBlendModeNormal alpha:1.0f];
            
            CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(),  [self.objectBorderColor colorWithAlphaComponent:self.textView.alpha].CGColor);
            
            path = [self getTextPatternBorderPath];
            path.lineWidth = self.objectBorderWidth;
            [path stroke];
            
            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            reflectionSize = CGSizeMake(self.bounds.size.width + self.objectBorderWidth*2, (self.bounds.size.height + self.objectBorderWidth*2) * self.reflectionScale);
            reflectionRect = CGRectMake(0.0f, 0.0f, self.bounds.size.width + self.objectBorderWidth*2, self.bounds.size.height+self.objectBorderWidth*2);
            
            if (self.isReflection)
            {
                reflectionImage = [self renderingReflectionImage:image size:reflectionSize rect:reflectionRect];
            }
            
            UIGraphicsBeginImageContextWithOptions(self.superViewSize, NO, 2.0f);
            CGContextConcatCTM(UIGraphicsGetCurrentContext(), self.transform);
            pnt = CGPointApplyAffineTransform(CGPointMake(self.center.x, self.center.y), CGAffineTransformInvert(self.transform));
            
            if (self.objectShadowStyle == 2)
            {
                CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), CGSizeMake(self.objectShadowOffset, self.objectShadowOffset), self.objectShadowBlur, self.objectShadowColor.CGColor);
            }
            
            [image drawInRect:CGRectMake(pnt.x - self.bounds.size.width*0.5f - self.objectBorderWidth, pnt.y - self.bounds.size.height*0.5f - self.objectBorderWidth, self.bounds.size.width + self.objectBorderWidth*2, self.bounds.size.height+self.objectBorderWidth*2) blendMode:kCGBlendModeNormal alpha:1.0f];
            
            if (self.isReflection)
            {
                [reflectionImage drawInRect:CGRectMake(pnt.x - self.bounds.size.width*0.5f - self.objectBorderWidth, pnt.y + self.bounds.size.height*0.5f + self.reflectionGap, reflectionSize.width, reflectionSize.height) blendMode:kCGBlendModeNormal alpha:self.reflectionAlpha];
            }
            
            CGContextConcatCTM(UIGraphicsGetCurrentContext(), CGAffineTransformInvert(self.transform));
            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
            break;
        case 3: //shot dot line
        {
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(self.textView.frame.size.width+self.objectBorderWidth*2, self.textView.frame.size.height+self.objectBorderWidth*2), NO, 2.0f);
            [image drawInRect:CGRectMake(self.objectBorderWidth, self.objectBorderWidth, self.textView.frame.size.width, self.textView.frame.size.height)  blendMode:kCGBlendModeNormal alpha:1.0f];
            
            CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(),  [self.objectBorderColor colorWithAlphaComponent:self.textView.alpha].CGColor);
            
            CGFloat pattern[] = {self.objectBorderWidth, self.objectBorderWidth};
            CGContextSetLineDash(UIGraphicsGetCurrentContext(), 0.0f, pattern, 2);
            
            path = [self getTextPatternBorderPath];
            path.lineWidth = self.objectBorderWidth;
            path.lineCapStyle = kCGLineCapButt;
            path.lineJoinStyle = kCGLineJoinMiter;
            [path stroke];
            
            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            reflectionSize = CGSizeMake(self.bounds.size.width + self.objectBorderWidth*2, (self.bounds.size.height + self.objectBorderWidth*2) * self.reflectionScale);
            reflectionRect = CGRectMake(0.0f, 0.0f, self.bounds.size.width + self.objectBorderWidth*2, self.bounds.size.height+self.objectBorderWidth*2);
            
            if (self.isReflection)
            {
                reflectionImage = [self renderingReflectionImage:image size:reflectionSize rect:reflectionRect];
            }
            
            UIGraphicsBeginImageContextWithOptions(self.superViewSize, NO, 2.0f);
            CGContextConcatCTM(UIGraphicsGetCurrentContext(), self.transform);
            pnt = CGPointApplyAffineTransform(CGPointMake(self.center.x, self.center.y), CGAffineTransformInvert(self.transform));
            
            if (self.objectShadowStyle == 2)
            {
                CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), CGSizeMake(self.objectShadowOffset, self.objectShadowOffset), self.objectShadowBlur, self.objectShadowColor.CGColor);
            }
            
            [image drawInRect:CGRectMake(pnt.x - self.bounds.size.width*0.5f - self.objectBorderWidth, pnt.y - self.bounds.size.height*0.5f - self.objectBorderWidth, self.bounds.size.width + self.objectBorderWidth*2, self.bounds.size.height+self.objectBorderWidth*2) blendMode:kCGBlendModeNormal alpha:1.0f];
            
            if (self.isReflection)
            {
                [reflectionImage drawInRect:CGRectMake(pnt.x - self.bounds.size.width*0.5f - self.objectBorderWidth, pnt.y + self.bounds.size.height*0.5f + self.reflectionGap, reflectionSize.width, reflectionSize.height) blendMode:kCGBlendModeNormal alpha:self.reflectionAlpha];
            }
            
            CGContextConcatCTM(UIGraphicsGetCurrentContext(), CGAffineTransformInvert(self.transform));
            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
            break;
        case 4: //middle dot line
        {
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(self.textView.frame.size.width+self.objectBorderWidth*2, self.textView.frame.size.height+self.objectBorderWidth*2), NO, 2.0f);
            [image drawInRect:CGRectMake(self.objectBorderWidth, self.objectBorderWidth, self.textView.frame.size.width, self.textView.frame.size.height)  blendMode:kCGBlendModeNormal alpha:1.0f];
            
            CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(),  [self.objectBorderColor colorWithAlphaComponent:self.textView.alpha].CGColor);
            
            CGFloat middleDotLinePattern[] = {1.5f*self.objectBorderWidth, 1.5f*self.objectBorderWidth};
            CGContextSetLineDash(UIGraphicsGetCurrentContext(), 0.0f, middleDotLinePattern, 2);
            
            path = [self getTextPatternBorderPath];
            path.lineWidth = self.objectBorderWidth;
            path.lineCapStyle = kCGLineCapButt;
            path.lineJoinStyle = kCGLineJoinMiter;
            [path stroke];
            
            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            reflectionSize = CGSizeMake(self.bounds.size.width + self.objectBorderWidth*2, (self.bounds.size.height + self.objectBorderWidth*2) * self.reflectionScale);
            reflectionRect = CGRectMake(0.0f, 0.0f, self.bounds.size.width + self.objectBorderWidth*2, self.bounds.size.height+self.objectBorderWidth*2);
            
            if (self.isReflection)
            {
                reflectionImage = [self renderingReflectionImage:image size:reflectionSize rect:reflectionRect];
            }
            
            UIGraphicsBeginImageContextWithOptions(self.superViewSize, NO, 2.0f);
            CGContextConcatCTM(UIGraphicsGetCurrentContext(), self.transform);
            pnt = CGPointApplyAffineTransform(CGPointMake(self.center.x, self.center.y), CGAffineTransformInvert(self.transform));
            
            if (self.objectShadowStyle == 2)
            {
                CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), CGSizeMake(self.objectShadowOffset, self.objectShadowOffset), self.objectShadowBlur, self.objectShadowColor.CGColor);
            }
            
            [image drawInRect:CGRectMake(pnt.x - self.bounds.size.width*0.5f - self.objectBorderWidth, pnt.y - self.bounds.size.height*0.5f - self.objectBorderWidth, self.bounds.size.width + self.objectBorderWidth*2, self.bounds.size.height+self.objectBorderWidth*2) blendMode:kCGBlendModeNormal alpha:1.0f];
            
            if (self.isReflection)
            {
                [reflectionImage drawInRect:CGRectMake(pnt.x - self.bounds.size.width*0.5f - self.objectBorderWidth, pnt.y + self.bounds.size.height*0.5f + self.reflectionGap, reflectionSize.width, reflectionSize.height) blendMode:kCGBlendModeNormal alpha:self.reflectionAlpha];
            }
            
            CGContextConcatCTM(UIGraphicsGetCurrentContext(), CGAffineTransformInvert(self.transform));
            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
            break;
        case 5: //long dot line
        {
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(self.textView.frame.size.width+self.objectBorderWidth*2, self.textView.frame.size.height+self.objectBorderWidth*2), NO, 2.0f);
            [image drawInRect:CGRectMake(self.objectBorderWidth, self.objectBorderWidth, self.textView.frame.size.width, self.textView.frame.size.height)  blendMode:kCGBlendModeNormal alpha:1.0f];
            
            CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(),  [self.objectBorderColor colorWithAlphaComponent:self.textView.alpha].CGColor);
            
            CGFloat longDotLinePattern[] = {3.0f*self.objectBorderWidth, 3.0f*self.objectBorderWidth};
            CGContextSetLineDash(UIGraphicsGetCurrentContext(), 0.0f, longDotLinePattern, 2);
            
            path = [self getTextPatternBorderPath];
            path.lineWidth = self.objectBorderWidth;
            path.lineCapStyle = kCGLineCapButt;
            path.lineJoinStyle = kCGLineJoinMiter;
            [path stroke];
            
            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            reflectionSize = CGSizeMake(self.bounds.size.width + self.objectBorderWidth*2, (self.bounds.size.height + self.objectBorderWidth*2) * self.reflectionScale);
            reflectionRect = CGRectMake(0.0f, 0.0f, self.bounds.size.width + self.objectBorderWidth*2, self.bounds.size.height+self.objectBorderWidth*2);
            
            if (self.isReflection)
            {
                reflectionImage = [self renderingReflectionImage:image size:reflectionSize rect:reflectionRect];
            }
            
            UIGraphicsBeginImageContextWithOptions(self.superViewSize, NO, 2.0f);
            CGContextConcatCTM(UIGraphicsGetCurrentContext(), self.transform);
            pnt = CGPointApplyAffineTransform(CGPointMake(self.center.x, self.center.y), CGAffineTransformInvert(self.transform));
            
            if (self.objectShadowStyle == 2)
            {
                CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), CGSizeMake(self.objectShadowOffset, self.objectShadowOffset), self.objectShadowBlur, self.objectShadowColor.CGColor);
            }
            
            [image drawInRect:CGRectMake(pnt.x - self.bounds.size.width*0.5f - self.objectBorderWidth, pnt.y - self.bounds.size.height*0.5f - self.objectBorderWidth, self.bounds.size.width + self.objectBorderWidth*2, self.bounds.size.height+self.objectBorderWidth*2) blendMode:kCGBlendModeNormal alpha:1.0f];
            
            if (self.isReflection)
            {
                [reflectionImage drawInRect:CGRectMake(pnt.x - self.bounds.size.width*0.5f - self.objectBorderWidth, pnt.y + self.bounds.size.height*0.5f + self.reflectionGap, reflectionSize.width, reflectionSize.height) blendMode:kCGBlendModeNormal alpha:self.reflectionAlpha];
            }
            
            CGContextConcatCTM(UIGraphicsGetCurrentContext(), CGAffineTransformInvert(self.transform));
            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
            break;
        case 6: //circle dot line
        {
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(self.textView.frame.size.width+self.objectBorderWidth*2, self.textView.frame.size.height+self.objectBorderWidth*2), NO, 2.0f);
            [image drawInRect:CGRectMake(self.objectBorderWidth, self.objectBorderWidth, self.textView.frame.size.width, self.textView.frame.size.height)  blendMode:kCGBlendModeNormal alpha:1.0f];
            
            CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(),  [self.objectBorderColor colorWithAlphaComponent:self.textView.alpha].CGColor);
            
            CGFloat circleDotLinePattern[] = {0.1f, 2.0f*self.objectBorderWidth};
            CGContextSetLineDash(UIGraphicsGetCurrentContext(), 0.0f, circleDotLinePattern, 2);
            
            path = [self getTextPatternBorderPath];
            path.lineWidth = self.objectBorderWidth;
            path.lineCapStyle = kCGLineCapRound;
            path.lineJoinStyle = kCGLineJoinMiter;
            [path stroke];
            
            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            reflectionSize = CGSizeMake(self.bounds.size.width + self.objectBorderWidth*2, (self.bounds.size.height + self.objectBorderWidth*2) * self.reflectionScale);
            reflectionRect = CGRectMake(0.0f, 0.0f, self.bounds.size.width + self.objectBorderWidth*2, self.bounds.size.height+self.objectBorderWidth*2);
            
            if (self.isReflection)
            {
                reflectionImage = [self renderingReflectionImage:image size:reflectionSize rect:reflectionRect];
            }
            
            UIGraphicsBeginImageContextWithOptions(self.superViewSize, NO, 2.0f);
            CGContextConcatCTM(UIGraphicsGetCurrentContext(), self.transform);
            pnt = CGPointApplyAffineTransform(CGPointMake(self.center.x, self.center.y), CGAffineTransformInvert(self.transform));
            
            if (self.objectShadowStyle == 2)
            {
                CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), CGSizeMake(self.objectShadowOffset, self.objectShadowOffset), self.objectShadowBlur, self.objectShadowColor.CGColor);
            }
            
            [image drawInRect:CGRectMake(pnt.x - self.bounds.size.width*0.5f - self.objectBorderWidth, pnt.y - self.bounds.size.height*0.5f - self.objectBorderWidth, self.bounds.size.width + self.objectBorderWidth*2, self.bounds.size.height+self.objectBorderWidth*2) blendMode:kCGBlendModeNormal alpha:1.0f];
            
            if (self.isReflection)
            {
                [reflectionImage drawInRect:CGRectMake(pnt.x - self.bounds.size.width*0.5f - self.objectBorderWidth, pnt.y + self.bounds.size.height*0.5f + self.reflectionGap, reflectionSize.width, reflectionSize.height) blendMode:kCGBlendModeNormal alpha:self.reflectionAlpha];
            }
            
            CGContextConcatCTM(UIGraphicsGetCurrentContext(), CGAffineTransformInvert(self.transform));
            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
            break;
        case 7: //two dots line
        {
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(self.textView.frame.size.width+self.objectBorderWidth*2, self.textView.frame.size.height+self.objectBorderWidth*2), NO, 2.0f);
            
            [image drawInRect:CGRectMake(self.objectBorderWidth, self.objectBorderWidth, self.textView.frame.size.width, self.textView.frame.size.height)  blendMode:kCGBlendModeNormal alpha:1.0f];
            
            UIImage* borderImage = [UIImage imageNamed:@"dotline_pattern"];
            borderImage = [borderImage rescaleImageToSize:CGSizeMake(self.objectBorderWidth, self.objectBorderWidth)];
            borderImage = [borderImage imageWithOverlayColor:[self.objectBorderColor colorWithAlphaComponent:self.textView.alpha]];
            colorRef = [UIColor colorWithPatternImage:borderImage].CGColor;
            CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(),  colorRef);
            
            path = [self getTextPatternBorderPath];
            path.lineWidth = self.objectBorderWidth;
            [path stroke];
            
            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            reflectionSize = CGSizeMake(self.bounds.size.width + self.objectBorderWidth*2, (self.bounds.size.height + self.objectBorderWidth*2) * self.reflectionScale);
            reflectionRect = CGRectMake(0.0f, 0.0f, self.bounds.size.width + self.objectBorderWidth*2, self.bounds.size.height+self.objectBorderWidth*2);
            
            if (self.isReflection)
            {
                reflectionImage = [self renderingReflectionImage:image size:reflectionSize rect:reflectionRect];
            }
            
            UIGraphicsBeginImageContextWithOptions(self.superViewSize, NO, 2.0f);
            CGContextConcatCTM(UIGraphicsGetCurrentContext(), self.transform);
            pnt = CGPointApplyAffineTransform(CGPointMake(self.center.x, self.center.y), CGAffineTransformInvert(self.transform));
            
            if (self.objectShadowStyle == 2)
            {
                CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), CGSizeMake(self.objectShadowOffset, self.objectShadowOffset), self.objectShadowBlur, self.objectShadowColor.CGColor);
            }
            
            [image drawInRect:CGRectMake(pnt.x - self.bounds.size.width*0.5f - self.objectBorderWidth, pnt.y - self.bounds.size.height*0.5f - self.objectBorderWidth, self.bounds.size.width + self.objectBorderWidth*2, self.bounds.size.height+self.objectBorderWidth*2) blendMode:kCGBlendModeNormal alpha:1.0f];
            
            if (self.isReflection)
            {
                [reflectionImage drawInRect:CGRectMake(pnt.x - self.bounds.size.width*0.5f - self.objectBorderWidth, pnt.y + self.bounds.size.height*0.5f + self.reflectionGap, reflectionSize.width, reflectionSize.height) blendMode:kCGBlendModeNormal alpha:self.reflectionAlpha];
            }
            
            CGContextConcatCTM(UIGraphicsGetCurrentContext(), CGAffineTransformInvert(self.transform));
            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
            break;
        case 8: //jigsaw line
        {
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(self.textView.frame.size.width+self.objectBorderWidth*2, self.textView.frame.size.height+self.objectBorderWidth*2), NO, 2.0f);
            
            [image drawInRect:CGRectMake(self.objectBorderWidth, self.objectBorderWidth, self.textView.frame.size.width, self.textView.frame.size.height)  blendMode:kCGBlendModeNormal alpha:1.0f];
            
            UIImage* borderImage = [UIImage imageNamed:@"dotline_pattern"];
            borderImage = [borderImage imageWithOverlayColor:[self.objectBorderColor colorWithAlphaComponent:self.textView.alpha]];
            colorRef = [UIColor colorWithPatternImage:borderImage].CGColor;
            CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(),  colorRef);
            
            path = [self getTextPatternBorderPath];
            path.lineWidth = self.objectBorderWidth;
            [path stroke];
            
            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            reflectionSize = CGSizeMake(self.bounds.size.width + self.objectBorderWidth*2, (self.bounds.size.height + self.objectBorderWidth*2) * self.reflectionScale);
            reflectionRect = CGRectMake(0.0f, 0.0f, self.bounds.size.width + self.objectBorderWidth*2, self.bounds.size.height+self.objectBorderWidth*2);
            
            if (self.isReflection)
            {
                reflectionImage = [self renderingReflectionImage:image size:reflectionSize rect:reflectionRect];
            }
            
            UIGraphicsBeginImageContextWithOptions(self.superViewSize, NO, 2.0f);
            CGContextConcatCTM(UIGraphicsGetCurrentContext(), self.transform);
            pnt = CGPointApplyAffineTransform(CGPointMake(self.center.x, self.center.y), CGAffineTransformInvert(self.transform));
            
            if (self.objectShadowStyle == 2)
            {
                CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), CGSizeMake(self.objectShadowOffset, self.objectShadowOffset), self.objectShadowBlur, self.objectShadowColor.CGColor);
            }
            
            [image drawInRect:CGRectMake(pnt.x - self.bounds.size.width*0.5f - self.objectBorderWidth, pnt.y - self.bounds.size.height*0.5f - self.objectBorderWidth, self.bounds.size.width + self.objectBorderWidth*2, self.bounds.size.height+self.objectBorderWidth*2) blendMode:kCGBlendModeNormal alpha:1.0f];
            
            if (self.isReflection)
            {
                [reflectionImage drawInRect:CGRectMake(pnt.x - self.bounds.size.width*0.5f - self.objectBorderWidth, pnt.y + self.bounds.size.height*0.5f + self.reflectionGap, reflectionSize.width, reflectionSize.height) blendMode:kCGBlendModeNormal alpha:self.reflectionAlpha];
            }
            
            CGContextConcatCTM(UIGraphicsGetCurrentContext(), CGAffineTransformInvert(self.transform));
            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
            break;
        case 9: //flower line
        {
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(self.textView.frame.size.width+self.objectBorderWidth*2, self.textView.frame.size.height+self.objectBorderWidth*2), NO, 2.0f);
            
            [image drawInRect:CGRectMake(self.objectBorderWidth, self.objectBorderWidth, self.textView.frame.size.width, self.textView.frame.size.height)  blendMode:kCGBlendModeNormal alpha:1.0f];
            
            UIImage* borderImage = [UIImage imageNamed:@"flower"];
            borderImage = [borderImage rescaleImageToSize:CGSizeMake(self.objectBorderWidth, self.objectBorderWidth)];
            borderImage = [borderImage imageWithOverlayColor:[self.objectBorderColor colorWithAlphaComponent:self.textView.alpha]];
            colorRef = [UIColor colorWithPatternImage:borderImage].CGColor;
            CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(),  colorRef);
            
            path = [self getTextPatternBorderPath];
            path.lineWidth = self.objectBorderWidth;
            [path stroke];
            
            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            reflectionSize = CGSizeMake(self.bounds.size.width + self.objectBorderWidth*2, (self.bounds.size.height + self.objectBorderWidth*2) * self.reflectionScale);
            reflectionRect = CGRectMake(0.0f, 0.0f, self.bounds.size.width + self.objectBorderWidth*2, self.bounds.size.height+self.objectBorderWidth*2);
            
            if (self.isReflection)
            {
                reflectionImage = [self renderingReflectionImage:image size:reflectionSize rect:reflectionRect];
            }
            
            UIGraphicsBeginImageContextWithOptions(self.superViewSize, NO, 2.0f);
            CGContextConcatCTM(UIGraphicsGetCurrentContext(), self.transform);
            pnt = CGPointApplyAffineTransform(CGPointMake(self.center.x, self.center.y), CGAffineTransformInvert(self.transform));
            
            if (self.objectShadowStyle == 2)
            {
                CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), CGSizeMake(self.objectShadowOffset, self.objectShadowOffset), self.objectShadowBlur, self.objectShadowColor.CGColor);
            }
            
            [image drawInRect:CGRectMake(pnt.x - self.bounds.size.width*0.5f - self.objectBorderWidth, pnt.y - self.bounds.size.height*0.5f - self.objectBorderWidth, self.bounds.size.width + self.objectBorderWidth*2, self.bounds.size.height+self.objectBorderWidth*2) blendMode:kCGBlendModeNormal alpha:1.0f];
            
            if (self.isReflection)
            {
                [reflectionImage drawInRect:CGRectMake(pnt.x - self.bounds.size.width*0.5f - self.objectBorderWidth, pnt.y + self.bounds.size.height*0.5f + self.reflectionGap, reflectionSize.width, reflectionSize.height) blendMode:kCGBlendModeNormal alpha:self.reflectionAlpha];
            }
            
            CGContextConcatCTM(UIGraphicsGetCurrentContext(), CGAffineTransformInvert(self.transform));
            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
            break;
        case 10: //black circle line
        {
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(self.textView.frame.size.width+self.objectBorderWidth*2, self.textView.frame.size.height+self.objectBorderWidth*2), NO, 2.0f);
            
            [image drawInRect:CGRectMake(self.objectBorderWidth, self.objectBorderWidth, self.textView.frame.size.width, self.textView.frame.size.height)  blendMode:kCGBlendModeNormal alpha:1.0f];
            
            UIImage* borderImage = [UIImage imageNamed:@"circle"];
            borderImage = [borderImage rescaleImageToSize:CGSizeMake(self.objectBorderWidth, self.objectBorderWidth)];
            borderImage = [borderImage imageWithOverlayColor:[self.objectBorderColor colorWithAlphaComponent:self.textView.alpha]];
            colorRef = [UIColor colorWithPatternImage:borderImage].CGColor;
            CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(),  colorRef);
            
            path = [self getTextPatternBorderPath];
            path.lineWidth = self.objectBorderWidth;
            [path stroke];
            
            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            reflectionSize = CGSizeMake(self.bounds.size.width + self.objectBorderWidth*2, (self.bounds.size.height + self.objectBorderWidth*2) * self.reflectionScale);
            reflectionRect = CGRectMake(0.0f, 0.0f, self.bounds.size.width + self.objectBorderWidth*2, self.bounds.size.height+self.objectBorderWidth*2);
            
            if (self.isReflection)
            {
                reflectionImage = [self renderingReflectionImage:image size:reflectionSize rect:reflectionRect];
            }
            
            UIGraphicsBeginImageContextWithOptions(self.superViewSize, NO, 2.0f);
            CGContextConcatCTM(UIGraphicsGetCurrentContext(), self.transform);
            pnt = CGPointApplyAffineTransform(CGPointMake(self.center.x, self.center.y), CGAffineTransformInvert(self.transform));
            
            if (self.objectShadowStyle == 2)
            {
                CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), CGSizeMake(self.objectShadowOffset, self.objectShadowOffset), self.objectShadowBlur, self.objectShadowColor.CGColor);
            }
            
            [image drawInRect:CGRectMake(pnt.x - self.bounds.size.width*0.5f - self.objectBorderWidth, pnt.y - self.bounds.size.height*0.5f - self.objectBorderWidth, self.bounds.size.width + self.objectBorderWidth*2, self.bounds.size.height+self.objectBorderWidth*2) blendMode:kCGBlendModeNormal alpha:1.0f];
            
            if (self.isReflection)
            {
                [reflectionImage drawInRect:CGRectMake(pnt.x - self.bounds.size.width*0.5f - self.objectBorderWidth, pnt.y + self.bounds.size.height*0.5f + self.reflectionGap, reflectionSize.width, reflectionSize.height) blendMode:kCGBlendModeNormal alpha:self.reflectionAlpha];
            }
            
            CGContextConcatCTM(UIGraphicsGetCurrentContext(), CGAffineTransformInvert(self.transform));
            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
            break;
        default:
            break;
    }
    
    return image;
}


-(void) changeTextObjectFrame
{
    CGAffineTransform transform = self.transform;
    self.transform = CGAffineTransformIdentity;
    
    CGSize size = [self.textView sizeThatFits:CGSizeMake(self.textView.frame.size.width, CGFLOAT_MAX)];

    if (size.height != self.textView.frame.size.height)
    {
        self.textView.frame = CGRectMake(self.textView.frame.origin.x, self.textView.frame.origin.y, self.textView.frame.size.width, size.height);
    }

    self.frame = CGRectMake(self.frame.origin.x+self.frame.size.width/2.0f -self.textView.frame.size.width/2, self.frame.origin.y, self.textView.frame.size.width, self.textView.frame.size.height);
    self.mediaView.frame = CGRectMake(0.0f, 0.0f, self.textView.frame.size.width, self.textView.frame.size.height);
    
    self.maskArrowLeft.center = CGPointMake(self.maskArrowLeft.frame.size.width/2, self.bounds.size.height/2);
    self.maskArrowRight.center = CGPointMake(self.bounds.size.width-self.maskArrowRight.frame.size.width/2, self.bounds.size.height/2);
    self.maskArrowTop.center = CGPointMake(self.bounds.size.width/2, self.maskArrowTop.frame.size.height/2);
    self.maskArrowBottom.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height-self.maskArrowBottom.frame.size.height/2);

    [self applySelectedLinePath];
    self.selectedLineLayer.frame = self.bounds;
    
    self.originalBounds = self.bounds;
    
    self.borderLineLayer.frame = CGRectMake(-self.objectBorderWidth, -self.objectBorderWidth, self.mediaView.bounds.size.width+self.objectBorderWidth*2.0f, self.mediaView.bounds.size.height+self.objectBorderWidth*2.0f);
    [self applyBorderLinePath];
    
    self.transform = transform;
    
    [self applyShadow];
}

#pragma mark -

-(void) applyTextColor:(UIColor*) color
{
    self.textView.textColor = color;

    NSMutableDictionary *attributes = [self.textView.typingAttributes mutableCopy];
    
    [attributes setObject:self.textView.textColor forKey:NSForegroundColorAttributeName];    //text color
    
    if (self.isStroke)
    {
        [attributes setObject:self.textView.textColor forKey:NSStrokeColorAttributeName];
        [attributes setObject:@5.0 forKey:NSStrokeWidthAttributeName];
    }
    else
    {
        [attributes setObject:[UIColor clearColor] forKey:NSStrokeColorAttributeName];
        [attributes setObject:@0.0 forKey:NSStrokeWidthAttributeName];
    }
    
    NSAttributedString *attString = [[NSAttributedString alloc] initWithString:self.textView.text attributes:attributes];
    self.textView.attributedText = attString;
    [self.textView setTypingAttributes:attributes];
    
    if ([self.delegate respondsToSelector:@selector(textChanged:)])
    {
        [self.delegate textChanged:self];
    }
}

-(void) applyTextAlignment:(NSTextAlignment) alignment
{
    self.textView.textAlignment = alignment;
    rememberedTextAlignment = alignment;
    
    NSMutableDictionary *attributes = [self.textView.typingAttributes mutableCopy];
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [style setAlignment:self.textView.textAlignment];
    [style setLineBreakMode:NSLineBreakByWordWrapping];
    [attributes setObject:style forKey:NSParagraphStyleAttributeName];   //alignment
    NSAttributedString *attString = [[NSAttributedString alloc] initWithString:self.textView.text attributes:attributes];
    self.textView.attributedText = attString;
    [self.textView setTypingAttributes:attributes];
    
    if ([self.delegate respondsToSelector:@selector(textChanged:)])
    {
        [self.delegate textChanged:self];
    }
}

-(void) applyTextUnderline:(BOOL) isUnderline
{
    self.isUnderline = isUnderline;
    isRememberedUnderline = isUnderline;
    
    NSMutableDictionary *attributes = [self.textView.typingAttributes mutableCopy];
    
    if (isUnderline)
        [attributes setObject:[NSNumber numberWithInt:NSUnderlineStyleSingle] forKey:NSUnderlineStyleAttributeName];
    else
        [attributes setObject:[NSNumber numberWithInt:NSUnderlineStyleNone] forKey:NSUnderlineStyleAttributeName];
    
    NSAttributedString *attString = [[NSAttributedString alloc] initWithString:self.textView.text attributes:attributes];
    self.textView.attributedText = attString;
    [self.textView setTypingAttributes:attributes];

    if ([self.delegate respondsToSelector:@selector(textChanged:)])
    {
        [self.delegate textChanged:self];
    }
}

-(void) applyTextStroke:(BOOL) isStroke
{
    self.isStroke = isStroke;
    isRememberedStroke = isStroke;
    
    NSMutableDictionary *attributes = [self.textView.typingAttributes mutableCopy];

    if (isStroke)
    {
        [attributes setObject:self.textView.textColor forKey:NSStrokeColorAttributeName];
        [attributes setObject:@5.0 forKey:NSStrokeWidthAttributeName];
    }
    else
    {
        [attributes setObject:[UIColor clearColor] forKey:NSStrokeColorAttributeName];
        [attributes setObject:@0.0 forKey:NSStrokeWidthAttributeName];
    }

    NSAttributedString *attString = [[NSAttributedString alloc] initWithString:self.textView.text attributes:attributes];
    self.textView.attributedText = attString;
    [self.textView setTypingAttributes:attributes];
    
    if ([self.delegate respondsToSelector:@selector(textChanged:)])
    {
        [self.delegate textChanged:self];
    }
}

-(void) applyTextFont:(NSString*)fontName size:(CGFloat)fontSize bold:(BOOL)isBold italic:(BOOL)isItalic
{
    self.textObjectFontSize = fontSize;
    
    UIFont *newFont = [self fontwithBoldTrait:isBold
                                  italicTrait:isItalic
                                     fontName:fontName
                                     fontSize:self.textObjectFontSize
                               fromDictionary:self.textView.typingAttributes];
    if (newFont)
    {
        rememberedFont = newFont;
        [self applyAttributeToTypingAttribute:newFont forKey:NSFontAttributeName];
        self.textView.font = newFont;
    }
    
    if ([self isBold:self.textView.font])
    {
        self.isBold = YES;
        isRememberedBold = YES;
        
        if ([self.delegate respondsToSelector:@selector(changeBoldBtn:)])
            [self.delegate changeBoldBtn:YES];
    }
    else
    {
        self.isBold = NO;
        isRememberedBold = NO;
    
        if ([self.delegate respondsToSelector:@selector(changeBoldBtn:)])
            [self.delegate changeBoldBtn:NO];
    }
    
    if ([self isItalic:self.textView.font])
    {
        self.isItalic = YES;
        isRememberedItalic = YES;
    
        if ([self.delegate respondsToSelector:@selector(changeItalicBtn:)])
            [self.delegate changeItalicBtn:YES];
    }
    else
    {
        self.isItalic = NO;
        isRememberedItalic = NO;
    
        if ([self.delegate respondsToSelector:@selector(changeItalicBtn:)])
            [self.delegate changeItalicBtn:NO];
    }
    
    [self changeTextObjectFrame];

    if ([self.delegate respondsToSelector:@selector(textChanged:)])
    {
        [self.delegate textChanged:self];
    }
}

#pragma mark - init attributed
-(void) initTextAttributed
{
    NSMutableDictionary *attributes = [self.textView.typingAttributes mutableCopy];
    
    [attributes setObject:self.textView.font forKey:NSFontAttributeName];    //font
    [attributes setObject:self.textView.textColor forKey:NSForegroundColorAttributeName];    //text color
    
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [style setAlignment:self.textView.textAlignment];
    [style setLineBreakMode:NSLineBreakByWordWrapping];
    [attributes setObject:style forKey:NSParagraphStyleAttributeName];   //alignment
    
    if (self.isUnderline)
        [attributes setObject:[NSNumber numberWithInt:NSUnderlineStyleSingle] forKey:NSUnderlineStyleAttributeName];
    else
        [attributes setObject:[NSNumber numberWithInt:NSUnderlineStyleNone] forKey:NSUnderlineStyleAttributeName];
    
    if (self.isStroke)    //stroke
    {
        [attributes setObject:self.textView.textColor forKey:NSStrokeColorAttributeName];
        [attributes setObject:@5.0 forKey:NSStrokeWidthAttributeName];
    }
    else
    {
        [attributes setObject:[UIColor clearColor] forKey:NSStrokeColorAttributeName];
        [attributes setObject:@0.0 forKey:NSStrokeWidthAttributeName];
    }
    
    NSAttributedString *attString = [[NSAttributedString alloc] initWithString:self.textView.text attributes:attributes];
    self.textView.attributedText = attString;
    [self.textView setTypingAttributes:attributes];
}


// Returns a font with given attributes. For any missing parameter takes the attribute from a given dictionary
- (UIFont *)fontwithBoldTrait:(BOOL)isBold italicTrait:(BOOL)isItalic fontName:(NSString *)fontName fontSize:(CGFloat)fontSize fromDictionary:(NSDictionary *)dictionary
{
	UIFont *newFont = nil;
	UIFont *font = [dictionary objectForKey:NSFontAttributeName];
    
	BOOL newBold = isBold;//(isBold) ? isBold : [self isBold:font];
	BOOL newItalic = isItalic;//(isItalic) ? isItalic : [self isItalic:font];
	CGFloat newFontSize = fontSize;

	if (fontName)
	{
		newFont = [self fontWithName:fontName size:newFontSize boldTrait:newBold italicTrait:newItalic];
	}
	else
	{
		newFont = [self fontWithBoldTrait:newBold italicTrait:newItalic andSize:newFontSize font:font];
	}
	
	return newFont;
}


- (UIFont *)fontWithName:(NSString *)name size:(CGFloat)size boldTrait:(BOOL)isBold italicTrait:(BOOL)isItalic
{
    UIFont *font = [UIFont fontWithName:name size:1];
	NSString *postScriptName = CFBridgingRelease(CTFontCopyPostScriptName((__bridge CTFontRef)(font)));
	
	CTFontSymbolicTraits traits = 0;
	CTFontRef newFontRef;
	CTFontRef fontWithoutTrait = CTFontCreateWithName((__bridge CFStringRef)(postScriptName), size, NULL);
    
	if (isItalic)
		traits |= kCTFontItalicTrait;
	
	if (isBold)
		traits |= kCTFontBoldTrait;
	
	if (traits == 0)
		newFontRef= CTFontCreateCopyWithAttributes(fontWithoutTrait, 0.0, NULL, NULL);
	else
		newFontRef = CTFontCreateCopyWithSymbolicTraits(fontWithoutTrait, 0.0, NULL, traits, traits);
	
	if (newFontRef)
	{
		NSString *fontNameKey = CFBridgingRelease(CTFontCopyName(newFontRef, kCTFontPostScriptNameKey));
        UIFont* resultFont = [UIFont fontWithName:fontNameKey size:CTFontGetSize(newFontRef)];
        
        CFRelease(newFontRef);
        CFRelease(fontWithoutTrait);
        
		return resultFont;
	}
    else
    {
        newFontRef= CTFontCreateCopyWithAttributes(fontWithoutTrait, 0.0, NULL, NULL);

        NSString *fontNameKey = CFBridgingRelease(CTFontCopyName(newFontRef, kCTFontPostScriptNameKey));
        UIFont* resultFont = [UIFont fontWithName:fontNameKey size:CTFontGetSize(newFontRef)];
        
        CFRelease(newFontRef);
        CFRelease(fontWithoutTrait);
        
        return resultFont;
    }
	
    CFRelease(fontWithoutTrait);

	return nil;
}

- (UIFont *)fontWithBoldTrait:(BOOL)bold italicTrait:(BOOL)italic andSize:(CGFloat)size font:(UIFont*)font
{
	CTFontRef fontRef = (__bridge CTFontRef)font;
	NSString *familyName = CFBridgingRelease(CTFontCopyName(fontRef, kCTFontFamilyNameKey));
    
    UIFont *fontName = [UIFont fontWithName:familyName size:1];
	NSString *postScriptName = CFBridgingRelease(CTFontCopyPostScriptName((__bridge CTFontRef)(fontName)));
    
    UIFont* resultFontName = [self fontWithName:postScriptName size:size boldTrait:bold italicTrait:italic];

	return resultFontName;
}

- (void)applyAttributeToTypingAttribute:(id)attribute forKey:(NSString *)key
{
	NSMutableDictionary *dictionary = [self.textView.typingAttributes mutableCopy];
	[dictionary setObject:attribute forKey:key];
	[self.textView setTypingAttributes:dictionary];
}

- (BOOL)isBold:(UIFont*) font
{
	CTFontSymbolicTraits trait = CTFontGetSymbolicTraits((__bridge CTFontRef)font);
	
	if ((trait & kCTFontTraitBold) == kCTFontTraitBold)
		return YES;
	
	return NO;
}

- (BOOL)isItalic:(UIFont*) font
{
	CTFontSymbolicTraits trait = CTFontGetSymbolicTraits((__bridge CTFontRef)font);
	
	if ((trait & kCTFontTraitItalic) == kCTFontTraitItalic)
		return YES;
	
	return NO;
}


#pragma mark -
#pragma mark - UITextView Delegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
 
    if ([self.textView.text isEqualToString:@"Press long to edit text "])
        [self.textView setText:@""];
    
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView{

    if ([self.textView.text isEqualToString:@""])
        [self.textView setText:@"Press long to edit text "];
    
    self.textView.editable = NO;
    self.textView.userInteractionEnabled = NO;

    if ([self.delegate respondsToSelector:@selector(textChanged:)])
    {
        [self.delegate textChanged:self];
    }
}

- (void)textViewDidChange:(UITextView *)textView
{
    @autoreleasepool
    {
        [self changeTextObjectFrame];
    }
}


#pragma mark - LongPressText Gesture

-(void) longPressText:(UILongPressGestureRecognizer*) gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
        [self object_actived];
        
        if (!self.textView.editable)
        {
            self.textView.editable = YES;
            self.textView.userInteractionEnabled = YES;
            [self.textView becomeFirstResponder];
        }
    }
}

#pragma mark -
#pragma mark Keyboard Controls Delegate

- (void)keyboardControls:(BSKeyboardControls *)keyboardControls selectedField:(UIView *)field inDirection:(BSKeyboardControlsDirection)direction
{

}

- (void)keyboardControlsDonePressed:(BSKeyboardControls *)keyboardControls
{
    [self.textView resignFirstResponder];
}


#pragma mark -
#pragma mark - UITextViewExtrasDelegate

-(void) hit
{
    if (self.isArrowActived)
    {
        self.isArrowActived = NO;
        [self addGestureRecognizer:self.moveGesture];
    }
}


void (^TransformAnimation)(CGPoint position, UIView *view, CGFloat maxAngle) = ^(CGPoint position, UIView *view, CGFloat maxAngle)
{
    CGFloat dx = position.x - view.center.x;
    CGFloat dy = position.y - view.center.y;
    // Get values for x and y axis
    CGFloat yTransformation = dx / view.window.frame.size.width;
    CGFloat xTransformation = -dy / view.window.frame.size.height;
    // Calculate the angle depending on the distance from the center
    CGFloat maxX = view.window.frame.size.width - view.center.x;
    CGFloat maxY = view.window.frame.size.height - view.center.y;
    CGFloat angle = (sqrt(dx*dx + dy*dy) / sqrt(maxX*maxX + maxY*maxY)) * maxAngle;
    
    // Begin the transformation anim
    CATransform3D layerTransform = CATransform3DIdentity;
    layerTransform.m34 = 1.0f / -300; // perspective effect
    view.layer.transform = CATransform3DRotate(layerTransform,
                                               angle / (180.0f / M_PI),
                                               xTransformation,
                                               yTransformation,
                                               0);
};


#pragma mark - 
#pragma mark - KenBurns Focus

-(void) showKenBurnsFocusImageView
{
    if ((self.mediaType == MEDIA_PHOTO)||(self.mediaType == MEDIA_TEXT))
    {
        self.kbFocusImageView.hidden = NO;
        
        [self.kbFocusImageView.layer removeAllAnimations];

        CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        [scaleAnimation setRepeatCount:MAXFLOAT];
        [scaleAnimation setDuration:1.0];
        [scaleAnimation setAutoreverses:YES];
        scaleAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        scaleAnimation.fromValue = [NSNumber numberWithFloat:1.0f];
        scaleAnimation.toValue = [NSNumber numberWithDouble:0.3f];
        [self.kbFocusImageView.layer addAnimation:scaleAnimation forKey:nil];
    }
}

-(void) hideKenBurnsFocusImageView
{
    if ((self.mediaType == MEDIA_PHOTO)||(self.mediaType == MEDIA_TEXT))
    {
        self.kbFocusImageView.hidden = YES;
        
        [self.kbFocusImageView.layer removeAllAnimations];
    }
}


@end
