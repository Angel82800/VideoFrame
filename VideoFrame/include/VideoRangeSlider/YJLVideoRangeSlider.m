
#import "YJLVideoRangeSlider.h"
#import "AppDelegate.h"

@interface YJLVideoRangeSlider ()

@property (nonatomic, strong) AVAssetImageGenerator *imageGenerator;
@property (nonatomic, strong) NSURL *mediaUrl;
@property (nonatomic, strong) YJLSliderLeft *leftThumb;
@property (nonatomic, strong) YJLSliderRight *rightThumb;
@property (nonatomic, strong) YJLCenterView* centerView;

@end


@implementation YJLVideoRangeSlider


- (id)initWithFrame:(CGRect)frame videoUrl:(NSURL *)videoUrl
{
    frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
    
    self = [super initWithFrame:frame];
    
    if (self)
    {
        isLR = YES;
        isMoveStart = NO;
        _mediaUrl = videoUrl;
        _yPosition = self.center.y;
        _frame_width = frame.size.width;
        self.media_type = MEDIA_VIDEO;
        self.isSelected = YES;
        self.isGrouped = NO;
        self.scaleFactor = 1.0f;
        
        int thumbWidth = 20.0f;
        
        self.backgroundColor = [UIColor clearColor];
        
        /* center view */
        _centerView = [[YJLCenterView alloc] initWithFrame:CGRectMake(frame.origin.x, 0.0f, frame.size.width, frame.size.height)];
        _centerView.colorIndex = MEDIA_VIDEO;
        _centerView.backgroundColor = [UIColor gradientFromColor:frame.size.height colorIndex:MEDIA_VIDEO];
        _centerView.clipsToBounds = YES;
        [self addSubview:_centerView];
        
        UIPanGestureRecognizer *centerPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveTimeSlider:)];
        [_centerView addGestureRecognizer:centerPan];
        
        /* left control */
        _leftThumb = [[YJLSliderLeft alloc] initWithFrame:CGRectMake(frame.origin.x, 0, thumbWidth, frame.size.height) type:MEDIA_VIDEO];
        _leftThumb.contentMode = UIViewContentModeLeft;
        _leftThumb.userInteractionEnabled = YES;
        _leftThumb.clipsToBounds = YES;
        _leftThumb.backgroundColor = [UIColor clearColor];
        [self addSubview:_leftThumb];
        
        /* right control */
        _rightThumb = [[YJLSliderRight alloc] initWithFrame:CGRectMake(frame.origin.x, 0, thumbWidth, frame.size.height) type:MEDIA_VIDEO];
        _rightThumb.contentMode = UIViewContentModeRight;
        _rightThumb.userInteractionEnabled = YES;
        _rightThumb.clipsToBounds = YES;
        _rightThumb.backgroundColor = [UIColor clearColor];
        [self addSubview:_rightThumb];
        
        /* select tap gesture */
        UITapGestureRecognizer *selectGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(slider_selected:)];
        selectGesture.delegate = self;
        [_centerView addGestureRecognizer:selectGesture];
        [selectGesture setNumberOfTapsRequired:1];

        _rightPosition = frame.origin.x + frame.size.width;
        _leftPosition = frame.origin.x;
        
        /* get thumbnail */
        [self getMovieFrame];
        
        [self isActived];
        
        /* animation button */
        float font = 0.0f;
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
            font = 8;
        else
            font = 12;
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
            self.startAnimationLabel = [[UILabel alloc] initWithFrame:CGRectMake(thumbWidth, 0, 40, frame.size.height-2)];
        else
            self.startAnimationLabel = [[UILabel alloc] initWithFrame:CGRectMake(thumbWidth, 5, 50, frame.size.height-10)];

        [self.startAnimationLabel setBackgroundColor:[UIColor colorWithWhite:0.2f alpha:0.2f]];
        self.startAnimationLabel.layer.borderColor = [UIColor whiteColor].CGColor;
        self.startAnimationLabel.layer.borderWidth = 0.5f;
        self.startAnimationLabel.shadowColor = [UIColor blackColor];
        self.startAnimationLabel.shadowOffset = CGSizeMake(0, 1);
        [self.startAnimationLabel setFont:[UIFont fontWithName:MYRIADPRO size:font]];
        self.startAnimationLabel.lineBreakMode = NSLineBreakByClipping;
        [self.startAnimationLabel setAdjustsFontSizeToFitWidth:YES];
        [self.startAnimationLabel setMinimumScaleFactor:0.1f];
        [self.startAnimationLabel setNumberOfLines:2];
        [self.startAnimationLabel setTextColor:[UIColor whiteColor]];
        [self.startAnimationLabel setTextAlignment:NSTextAlignmentCenter];
        [_centerView addSubview:self.startAnimationLabel];
        self.startAnimationLabel.userInteractionEnabled = YES;
        [self.startAnimationLabel setText:@"None\n0.00s"];

        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionStart:)];
        tapGesture.delegate = self;
        [tapGesture setNumberOfTapsRequired:1];
        [self.startAnimationLabel addGestureRecognizer:tapGesture];

        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
            self.endAnimationLabel = [[UILabel alloc] initWithFrame:CGRectMake(_centerView.frame.size.width - thumbWidth - 40, 0, 40, frame.size.height-2)];
        else
            self.endAnimationLabel = [[UILabel alloc] initWithFrame:CGRectMake(_centerView.frame.size.width - thumbWidth - 50, 5, 50, frame.size.height-10)];
        
        [self.endAnimationLabel setBackgroundColor:[UIColor colorWithWhite:0.2f alpha:0.2f]];
        self.endAnimationLabel.layer.borderColor = [UIColor whiteColor].CGColor;
        self.endAnimationLabel.layer.borderWidth = 0.5f;
        self.endAnimationLabel.shadowColor = [UIColor blackColor];
        self.endAnimationLabel.shadowOffset = CGSizeMake(0, 1);
        [self.endAnimationLabel setFont:[UIFont fontWithName:MYRIADPRO size:font]];
        self.endAnimationLabel.lineBreakMode = NSLineBreakByClipping;
        [self.endAnimationLabel setAdjustsFontSizeToFitWidth:YES];
        [self.endAnimationLabel setMinimumScaleFactor:0.1f];
        [self.endAnimationLabel setNumberOfLines:2];
        [self.endAnimationLabel setTextColor:[UIColor whiteColor]];
        [self.endAnimationLabel setTextAlignment:NSTextAlignmentCenter];
        [_centerView addSubview:self.endAnimationLabel];
        self.endAnimationLabel.userInteractionEnabled = YES;
        [self.endAnimationLabel setText:@"None\n0.00s"];

        tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionEnd:)];
        tapGesture.delegate = self;
        [tapGesture setNumberOfTapsRequired:1];
        [self.endAnimationLabel addGestureRecognizer:tapGesture];

        self.startActionType = gnStartActionTypeDef;
        self.endActionType = gnEndActionTypeDef;
        self.startActionTime = grStartActionTimeDef;
        self.endActionTime = grEndActionTimeDef;

        if (self.startActionType != ACTION_NONE)
        {
            NSString* startActionTypeStr = [gaActionNameArray objectAtIndex:self.startActionType];
            [self.startAnimationLabel setText:[NSString stringWithFormat:@"%@\n%.2fs", startActionTypeStr, self.startActionTime]];
            self.startAnimationLabel.frame = CGRectMake(_leftThumb.frame.size.width, (self.frame.size.height-self.startAnimationLabel.frame.size.height)/2.0f, self.startAnimationLabel.frame.size.width, self.startAnimationLabel.frame.size.height);
        }
        
        if (self.endActionType != ACTION_NONE)
        {
            NSString* endActionTypeStr = [gaActionNameArray objectAtIndex:self.endActionType];
            [self.endAnimationLabel setText:[NSString stringWithFormat:@"%@\n%.2fs", endActionTypeStr, self.endActionTime]];
            self.endAnimationLabel.frame = CGRectMake(_centerView.frame.size.width - _rightThumb.frame.size.width - self.endAnimationLabel.frame.size.width, (self.frame.size.height-self.endAnimationLabel.frame.size.height)/2.0f, self.endAnimationLabel.frame.size.width, self.endAnimationLabel.frame.size.height);
        }

        [self drawRuler];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame musicUrl:(NSURL *)musicUrl
{
    self = [super initWithFrame:frame];

    if (self)
    {
        _yPosition = self.center.y;
        isLR = YES;
        isMoveStart = NO;
        _mediaUrl = musicUrl;
        self.media_type = MEDIA_MUSIC;
        self.isSelected = YES;
        self.isGrouped = NO;
        _frame_width = frame.size.width;
        self.scaleFactor = 1.0f;

        int thumbWidth = 0;
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
            thumbWidth = 10;
        else
            thumbWidth = 20;
        
        self.backgroundColor = [UIColor clearColor];
        
        /* center view */
        _centerView = [[YJLCenterView alloc] initWithFrame:CGRectMake(frame.origin.x, 0.0f, frame.size.width, frame.size.height)];
        _centerView.colorIndex = MEDIA_MUSIC;
        _centerView.backgroundColor = [UIColor gradientFromColor:frame.size.height colorIndex:MEDIA_MUSIC];
        _centerView.clipsToBounds = YES;
        [self addSubview:_centerView];
        
        UIPanGestureRecognizer *centerPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveTimeSlider:)];
        [_centerView addGestureRecognizer:centerPan];
        
        /* left control */
        _leftThumb = [[YJLSliderLeft alloc] initWithFrame:CGRectMake(frame.origin.x, 0, thumbWidth, frame.size.height) type:MEDIA_MUSIC];
        _leftThumb.contentMode = UIViewContentModeLeft;
        _leftThumb.userInteractionEnabled = YES;
        _leftThumb.clipsToBounds = YES;
        _leftThumb.backgroundColor = [UIColor clearColor];
        [self addSubview:_leftThumb];

        /* right control */
        _rightThumb = [[YJLSliderRight alloc] initWithFrame:CGRectMake(frame.origin.x, 0, thumbWidth, frame.size.height) type:MEDIA_MUSIC];
        _rightThumb.contentMode = UIViewContentModeRight;
        _rightThumb.userInteractionEnabled = YES;
        _rightThumb.clipsToBounds = YES;
        _rightThumb.backgroundColor = [UIColor clearColor];
        [self addSubview:_rightThumb];

        _rightPosition = frame.origin.x + frame.size.width;
        _leftPosition = frame.origin.x;
        
        self.myAsset = [AVURLAsset URLAssetWithURL:_mediaUrl options:nil];

        UIImage* thumbnailImage = [UIImage imageNamed:@"musicSymbol"];
        thumbnailImage = [thumbnailImage imageWithOverlayColor:[UIColor grayColor]];
        
        self.thumbnailImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.height*0.9f, frame.size.height*0.9f)];
        [self.thumbnailImageView setImage:thumbnailImage];
        self.thumbnailImageView.userInteractionEnabled = NO;

        float font = 0.0f;

        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
            font = 8;
        else
            font = 12;

        self.durationLabel = [[UILabel alloc] initWithFrame:self.bounds];
        self.durationLabel.backgroundColor = [UIColor clearColor];
        self.durationLabel.textAlignment = NSTextAlignmentCenter;
        self.durationLabel.font = [UIFont fontWithName:MYRIADPRO size:(font+2)];
        self.durationLabel.adjustsFontSizeToFitWidth = YES;
        self.durationLabel.minimumScaleFactor = 0.1f;
        self.durationLabel.numberOfLines = 2;
        float time = (float)self.myAsset.duration.value / (float)self.myAsset.duration.timescale;
        NSString* timeStr = [self timeToStr:time];
        [self.durationLabel setText:[NSString stringWithFormat:@"MUSIC\n%@", timeStr]];
        self.durationLabel.textColor = [UIColor whiteColor];
        self.durationLabel.shadowColor = [UIColor blackColor];
        self.durationLabel.shadowOffset = CGSizeMake(0, 1);
        [_centerView addSubview:self.durationLabel];
        self.durationLabel.userInteractionEnabled = NO;

        self.groupImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100.0f, self.bounds.size.height)];
        self.groupImageView.backgroundColor = [UIColor clearColor];
        [self.groupImageView setImage:[UIImage imageNamed:@"group"]];
        [_centerView addSubview:self.groupImageView];
        self.groupImageView.userInteractionEnabled = NO;
        self.groupImageView.hidden = YES;

        //use this for custom font
        self.thumbnailImageView.center = CGPointMake(_centerView.bounds.size.width/2, _centerView.bounds.size.height/2);
        self.durationLabel.center = CGPointMake(_centerView.bounds.size.width/2, _centerView.bounds.size.height/2);
        self.groupImageView.center = CGPointMake(_centerView.bounds.size.width/2, _centerView.bounds.size.height/2);
        _durationSeconds = CMTimeGetSeconds([self.myAsset duration]);
        self.scaleFactor = self.frame.size.width / _durationSeconds;
        
        /* select tap gesture */
        UITapGestureRecognizer *selectGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(slider_selected:)];
        selectGesture.delegate = self;
        [_centerView addGestureRecognizer:selectGesture];
        [selectGesture setNumberOfTapsRequired:1];

        [self isActived];
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
            self.startAnimationLabel = [[UILabel alloc] initWithFrame:CGRectMake(thumbWidth, 0, 40, frame.size.height-2)];
        else
            self.startAnimationLabel = [[UILabel alloc] initWithFrame:CGRectMake(thumbWidth, 5, 50, frame.size.height-10)];
        
        [self.startAnimationLabel setBackgroundColor:[UIColor colorWithWhite:0.2f alpha:0.2f]];
        self.startAnimationLabel.layer.borderColor = [UIColor whiteColor].CGColor;
        self.startAnimationLabel.layer.borderWidth = 0.5f;
        self.startAnimationLabel.shadowColor = [UIColor blackColor];
        self.startAnimationLabel.shadowOffset = CGSizeMake(0, 1);
        [self.startAnimationLabel setFont:[UIFont fontWithName:MYRIADPRO size:font]];
        self.startAnimationLabel.lineBreakMode = NSLineBreakByClipping;
        [self.startAnimationLabel setAdjustsFontSizeToFitWidth:YES];
        [self.startAnimationLabel setMinimumScaleFactor:0.1f];
        [self.startAnimationLabel setNumberOfLines:2];
        [self.startAnimationLabel setTextColor:[UIColor whiteColor]];
        [self.startAnimationLabel setTextAlignment:NSTextAlignmentCenter];
        [_centerView addSubview:self.startAnimationLabel];
        self.startAnimationLabel.userInteractionEnabled = YES;
        [self.startAnimationLabel setText:@"None\n0.00s"];

        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionStart:)];
        tapGesture.delegate = self;
        [tapGesture setNumberOfTapsRequired:1];
        [self.startAnimationLabel addGestureRecognizer:tapGesture];
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
            self.endAnimationLabel = [[UILabel alloc] initWithFrame:CGRectMake(_centerView.frame.size.width - thumbWidth - 40, 0, 40, frame.size.height-2)];
        else
            self.endAnimationLabel = [[UILabel alloc] initWithFrame:CGRectMake(_centerView.frame.size.width - thumbWidth - 50, 5, 50, frame.size.height-10)];
        
        [self.endAnimationLabel setBackgroundColor:[UIColor colorWithWhite:0.2f alpha:0.2f]];
        self.endAnimationLabel.layer.borderColor = [UIColor whiteColor].CGColor;
        self.endAnimationLabel.layer.borderWidth = 0.5f;
        self.endAnimationLabel.shadowColor = [UIColor blackColor];
        self.endAnimationLabel.shadowOffset = CGSizeMake(0, 1);
        [self.endAnimationLabel setFont:[UIFont fontWithName:MYRIADPRO size:font]];
        self.endAnimationLabel.lineBreakMode = NSLineBreakByClipping;
        [self.endAnimationLabel setAdjustsFontSizeToFitWidth:YES];
        [self.endAnimationLabel setMinimumScaleFactor:0.1f];
        [self.endAnimationLabel setNumberOfLines:2];
        [self.endAnimationLabel setTextColor:[UIColor whiteColor]];
        [self.endAnimationLabel setTextAlignment:NSTextAlignmentCenter];
        [_centerView addSubview:self.endAnimationLabel];
        self.endAnimationLabel.userInteractionEnabled = YES;
        [self.endAnimationLabel setText:@"None\n0.00s"];

        tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionEnd:)];
        tapGesture.delegate = self;
        [tapGesture setNumberOfTapsRequired:1];
        [self.endAnimationLabel addGestureRecognizer:tapGesture];
        
        self.startActionType = ACTION_NONE;
        self.endActionType = ACTION_NONE;
        self.startActionTime = MIN_DURATION;
        self.endActionTime = MIN_DURATION;

        if (self.startActionType != ACTION_NONE)
        {
            [self.startAnimationLabel setText:[NSString stringWithFormat:@"Fade\n%.2fs", self.startActionTime]];
            self.startAnimationLabel.frame = CGRectMake(_leftThumb.frame.size.width, (self.frame.size.height-self.startAnimationLabel.frame.size.height)/2.0f, self.startAnimationLabel.frame.size.width, self.startAnimationLabel.frame.size.height);
        }
        
        if (self.endActionType != ACTION_NONE)
        {
            [self.endAnimationLabel setText:[NSString stringWithFormat:@"Fade\n%.2fs", self.endActionTime]];
            self.endAnimationLabel.frame = CGRectMake(_centerView.frame.size.width - _rightThumb.frame.size.width - self.endAnimationLabel.frame.size.width, (self.frame.size.height-self.endAnimationLabel.frame.size.height)/2.0f, self.endAnimationLabel.frame.size.width, self.endAnimationLabel.frame.size.height);
        }

        [self drawRuler];
        
        /*************************** Wave Form View ************************************/
        self.waveform = [[FDWaveformView alloc] initWithFrame:_centerView.bounds];
        self.waveform.delegate = self;
        self.waveform.alpha = 0.0f;
        self.waveform.audioURL = musicUrl;
        self.waveform.progressSamples = 10000;
        self.waveform.doesAllowScrubbing = YES;
        [_centerView addSubview:self.waveform];
        [_centerView sendSubviewToBack:self.waveform];
        [self.waveform createWaveform];

        self.waveform.userInteractionEnabled = NO;
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame image:(UIImage *)image scale:(CGFloat)scale type:(int) mediaType
{
    self = [super initWithFrame:frame];

    if (self)
    {
        _yPosition = self.center.y;
        isLR = YES;
        isMoveStart = NO;
        self.media_type = mediaType;
        self.isSelected = YES;
        self.isGrouped = NO;
        _frame_width = frame.size.width;
        self.scaleFactor = scale;
        _mediaUrl = nil;

        int thumbWidth = 0;

        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
            thumbWidth = 10;
        else
            thumbWidth = 20;
        
        self.backgroundColor = [UIColor clearColor];
        
        /* center view */
        _centerView = [[YJLCenterView alloc] initWithFrame:CGRectMake(frame.origin.x, 0.0f, frame.size.width, frame.size.height)];
        _centerView.colorIndex = mediaType;
        _centerView.backgroundColor = [UIColor gradientFromColor:frame.size.height colorIndex:mediaType];
        _centerView.clipsToBounds = YES;
        [self addSubview:_centerView];
        
        UIPanGestureRecognizer *centerPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveTimeSlider:)];
        [_centerView addGestureRecognizer:centerPan];
        
        UITapGestureRecognizer *selectGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(slider_selected:)];
        selectGesture.delegate = self;
        [_centerView addGestureRecognizer:selectGesture];
        [selectGesture setNumberOfTapsRequired:1];


        /* left control */
        _leftThumb = [[YJLSliderLeft alloc] initWithFrame:CGRectMake(frame.origin.x, 0, thumbWidth, frame.size.height) type:mediaType];
        _leftThumb.contentMode = UIViewContentModeLeft;
        _leftThumb.userInteractionEnabled = YES;
        _leftThumb.clipsToBounds = YES;
        _leftThumb.backgroundColor = [UIColor clearColor];
        [self addSubview:_leftThumb];
        
        UIPanGestureRecognizer *leftPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleLeftPan:)];
        [_leftThumb addGestureRecognizer:leftPan];
        
        /* right control */
        _rightThumb = [[YJLSliderRight alloc] initWithFrame:CGRectMake(frame.origin.x, 0, thumbWidth, frame.size.height) type:mediaType];
        _rightThumb.contentMode = UIViewContentModeRight;
        _rightThumb.userInteractionEnabled = YES;
        _rightThumb.clipsToBounds = YES;
        _rightThumb.backgroundColor = [UIColor clearColor];
        [self addSubview:_rightThumb];
        
        UIPanGestureRecognizer *rightPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleRightPan:)];
        [_rightThumb addGestureRecognizer:rightPan];
        
        _rightPosition = frame.origin.x + frame.size.width;
        _leftPosition = frame.origin.x;
        
        self.thumbnailImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.height*2.0f, frame.size.height)];
        [self.thumbnailImageView setImage:image];
        [self.thumbnailImageView setContentMode:UIViewContentModeScaleAspectFit];
        [_centerView addSubview:self.thumbnailImageView];
        self.thumbnailImageView.center = CGPointMake(_centerView.bounds.size.width/2, _centerView.bounds.size.height/2);
        self.thumbnailImageView.userInteractionEnabled = NO;
        
        float font = 0.0f;
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
            font = 8;
        else
            font = 12;
        
        self.durationLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100.0f, self.bounds.size.height)];
        self.durationLabel.backgroundColor = [UIColor clearColor];
        self.durationLabel.textAlignment = NSTextAlignmentCenter;
        self.durationLabel.adjustsFontSizeToFitWidth = YES;
        self.durationLabel.minimumScaleFactor = 0.1f;
        self.durationLabel.numberOfLines = 2;
        self.durationLabel.font = [UIFont fontWithName:MYRIADPRO size:font+2];
        float time = _frame_width / self.scaleFactor;
        NSString* timeStr = [self timeToStr:time];
        
        if (mediaType == MEDIA_PHOTO)
            [self.durationLabel setText:[NSString stringWithFormat:@"PHOTO\n%@", timeStr]];
        else if (mediaType == MEDIA_GIF)
            [self.durationLabel setText:[NSString stringWithFormat:@"GIF\n%@", timeStr]];
        
        self.durationLabel.textColor = [UIColor whiteColor];
        self.durationLabel.shadowColor = [UIColor blackColor];
        self.durationLabel.shadowOffset = CGSizeMake(0, 1);
        [_centerView addSubview:self.durationLabel];
        self.durationLabel.center = CGPointMake(_centerView.bounds.size.width/2, _centerView.bounds.size.height/2);
        self.durationLabel.userInteractionEnabled = NO;

        self.groupImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100.0f, self.bounds.size.height)];
        self.groupImageView.backgroundColor = [UIColor clearColor];
        [self.groupImageView setImage:[UIImage imageNamed:@"group"]];
        [_centerView addSubview:self.groupImageView];
        self.groupImageView.userInteractionEnabled = NO;
        self.groupImageView.hidden = YES;
        self.groupImageView.center = CGPointMake(_centerView.bounds.size.width/2, _centerView.bounds.size.height/2);

        _durationSeconds = time;
        
        [self isActived];
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
            self.startAnimationLabel = [[UILabel alloc] initWithFrame:CGRectMake(thumbWidth, 0, 40, frame.size.height-2)];
        else
            self.startAnimationLabel = [[UILabel alloc] initWithFrame:CGRectMake(thumbWidth, 5, 50, frame.size.height-10)];
        
        [self.startAnimationLabel setBackgroundColor:[UIColor colorWithWhite:0.2f alpha:0.2f]];
        self.startAnimationLabel.layer.borderColor = [UIColor whiteColor].CGColor;
        self.startAnimationLabel.layer.borderWidth = 0.5f;
        self.startAnimationLabel.shadowColor = [UIColor blackColor];
        self.startAnimationLabel.shadowOffset = CGSizeMake(0, 1);
        [self.startAnimationLabel setFont:[UIFont fontWithName:MYRIADPRO size:font]];
        self.startAnimationLabel.lineBreakMode = NSLineBreakByClipping;
        [self.startAnimationLabel setAdjustsFontSizeToFitWidth:YES];
        [self.startAnimationLabel setMinimumScaleFactor:0.1f];
        [self.startAnimationLabel setNumberOfLines:2];
        [self.startAnimationLabel setTextColor:[UIColor whiteColor]];
        [self.startAnimationLabel setTextAlignment:NSTextAlignmentCenter];
        [_centerView addSubview:self.startAnimationLabel];
        self.startAnimationLabel.userInteractionEnabled = YES;
        [self.startAnimationLabel setText:@"None\n0.00s"];


        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionStart:)];
        tapGesture.delegate = self;
        [tapGesture setNumberOfTapsRequired:1];
        [self.startAnimationLabel addGestureRecognizer:tapGesture];

        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
            self.endAnimationLabel = [[UILabel alloc] initWithFrame:CGRectMake(_centerView.frame.size.width - thumbWidth - 40, 0, 40, frame.size.height-2)];
        else
            self.endAnimationLabel = [[UILabel alloc] initWithFrame:CGRectMake(_centerView.frame.size.width - thumbWidth - 50, 5, 50, frame.size.height-10)];
        
        [self.endAnimationLabel setBackgroundColor:[UIColor colorWithWhite:0.2f alpha:0.2f]];
        self.endAnimationLabel.layer.borderColor = [UIColor whiteColor].CGColor;
        self.endAnimationLabel.layer.borderWidth = 0.5f;
        self.endAnimationLabel.shadowColor = [UIColor blackColor];
        self.endAnimationLabel.shadowOffset = CGSizeMake(0, 1);
        [self.endAnimationLabel setFont:[UIFont fontWithName:MYRIADPRO size:font]];
        self.endAnimationLabel.lineBreakMode = NSLineBreakByClipping;
        [self.endAnimationLabel setAdjustsFontSizeToFitWidth:YES];
        [self.endAnimationLabel setMinimumScaleFactor:0.1f];
        [self.endAnimationLabel setNumberOfLines:2];
        [self.endAnimationLabel setTextColor:[UIColor whiteColor]];
        [self.endAnimationLabel setTextAlignment:NSTextAlignmentCenter];
        [_centerView addSubview:self.endAnimationLabel];
        self.endAnimationLabel.userInteractionEnabled = YES;
        [self.endAnimationLabel setText:@"None\n0.00s"];


        tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionEnd:)];
        tapGesture.delegate = self;
        [tapGesture setNumberOfTapsRequired:1];
        [self.endAnimationLabel addGestureRecognizer:tapGesture];


        self.startActionType = gnStartActionTypeDef;
        self.endActionType = gnEndActionTypeDef;
        self.startActionTime = grStartActionTimeDef;
        self.endActionTime = grEndActionTimeDef;
        
        if (self.startActionType != ACTION_NONE)
        {
            NSString* startActionTypeStr = [gaActionNameArray objectAtIndex:self.startActionType];
            [self.startAnimationLabel setText:[NSString stringWithFormat:@"%@\n%.2fs", startActionTypeStr, self.startActionTime]];
            self.startAnimationLabel.frame = CGRectMake(_leftThumb.frame.size.width, (self.frame.size.height-self.startAnimationLabel.frame.size.height)/2.0f, self.startAnimationLabel.frame.size.width, self.startAnimationLabel.frame.size.height);
        }
        
        if (self.endActionType != ACTION_NONE)
        {
            NSString* endActionTypeStr = [gaActionNameArray objectAtIndex:self.endActionType];
            [self.endAnimationLabel setText:[NSString stringWithFormat:@"%@\n%.2fs", endActionTypeStr, self.endActionTime]];
            self.endAnimationLabel.frame = CGRectMake(_centerView.frame.size.width - _rightThumb.frame.size.width - self.endAnimationLabel.frame.size.width, (self.frame.size.height-self.endAnimationLabel.frame.size.height)/2.0f, self.endAnimationLabel.frame.size.width, self.endAnimationLabel.frame.size.height);
        }
        
        [self drawRuler];
    }
    
    return self;
}

- (id)initWithFrameText:(NSString*) text frame:(CGRect)frame scale:(CGFloat)scale
{
    self = [super initWithFrame:frame];

    if (self)
    {
        _yPosition = self.center.y;
        isLR = YES;
        isMoveStart = NO;
        self.media_type = MEDIA_TEXT;
        self.isSelected = YES;
        self.isGrouped = NO;
        _frame_width = frame.size.width;
        self.scaleFactor = scale;
        _mediaUrl = nil;

        int thumbWidth = 0;

        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
            thumbWidth = 10;
        else
            thumbWidth = 20;
        
        self.backgroundColor = [UIColor clearColor];
        
        /* center view */
        _centerView = [[YJLCenterView alloc] initWithFrame:CGRectMake(frame.origin.x, 0.0f, frame.size.width, frame.size.height)];
        _centerView.colorIndex = MEDIA_TEXT;
        _centerView.backgroundColor = [UIColor gradientFromColor:frame.size.height colorIndex:MEDIA_TEXT];
        _centerView.clipsToBounds = YES;
        [self addSubview:_centerView];
        
        UIPanGestureRecognizer *centerPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveTimeSlider:)];
        [_centerView addGestureRecognizer:centerPan];
        
        /* left control */
        _leftThumb = [[YJLSliderLeft alloc] initWithFrame:CGRectMake(frame.origin.x, 0, thumbWidth, frame.size.height) type:MEDIA_TEXT];
        _leftThumb.contentMode = UIViewContentModeLeft;
        _leftThumb.userInteractionEnabled = YES;
        _leftThumb.clipsToBounds = YES;
        _leftThumb.backgroundColor = [UIColor clearColor];
        [self addSubview:_leftThumb];
        
        UIPanGestureRecognizer *leftPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleLeftPan:)];
        [_leftThumb addGestureRecognizer:leftPan];
        
        /* right control */
        _rightThumb = [[YJLSliderRight alloc] initWithFrame:CGRectMake(frame.origin.x, 0, thumbWidth, frame.size.height) type:MEDIA_TEXT];
        _rightThumb.contentMode = UIViewContentModeRight;
        _rightThumb.userInteractionEnabled = YES;
        _rightThumb.clipsToBounds = YES;
        _rightThumb.backgroundColor = [UIColor clearColor];
        [self addSubview:_rightThumb];
        
        UIPanGestureRecognizer *rightPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleRightPan:)];
        [_rightThumb addGestureRecognizer:rightPan];
        
        _rightPosition = frame.origin.x + frame.size.width;
        _leftPosition = frame.origin.x;

        float thumbnailFont = 0.0f;
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
            thumbnailFont = 15;
        else
            thumbnailFont = 20;
        
        self.thumbnailLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.height*3.0f, frame.size.height*1.5f)];
        self.thumbnailLabel.backgroundColor = [UIColor clearColor];
        self.thumbnailLabel.textAlignment = NSTextAlignmentCenter;
        self.thumbnailLabel.font = [UIFont fontWithName:MYRIADPRO size:thumbnailFont];
        self.thumbnailLabel.numberOfLines = 0;
        [self.thumbnailLabel setText:text];
        self.thumbnailLabel.textColor = [UIColor blackColor];
        self.thumbnailLabel.shadowColor = [UIColor whiteColor];
        self.thumbnailLabel.shadowOffset = CGSizeMake(0, 1);
        [_centerView addSubview:self.thumbnailLabel];
        self.thumbnailLabel.center = CGPointMake(_centerView.bounds.size.width/2, _centerView.bounds.size.height/2);
        self.thumbnailLabel.userInteractionEnabled = NO;
        self.thumbnailLabel.hidden = YES;
        
        self.thumbnailImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.height*2.0f, frame.size.height)];
        [self.thumbnailImageView setContentMode:UIViewContentModeScaleAspectFit];
        self.thumbnailImageView.center = CGPointMake(_centerView.bounds.size.width/2, _centerView.bounds.size.height/2);
        self.thumbnailImageView.userInteractionEnabled = NO;
        [_centerView addSubview:self.thumbnailImageView];


        UIGraphicsBeginImageContext(self.thumbnailLabel.bounds.size);
        self.thumbnailLabel.hidden = NO;
        [self.thumbnailLabel.layer renderInContext:UIGraphicsGetCurrentContext()];
        self.thumbnailLabel.hidden = YES;
        UIImage* thumbnailImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        [self.thumbnailImageView setImage:thumbnailImage];
        
        float font = 0.0f;
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
            font = 8;
        else
            font = 12;
        
        self.durationLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100.0f, self.bounds.size.height)];
        self.durationLabel.backgroundColor = [UIColor clearColor];
        self.durationLabel.textAlignment = NSTextAlignmentCenter;
        self.durationLabel.font = [UIFont fontWithName:MYRIADPRO size:(font+2)];
        self.durationLabel.adjustsFontSizeToFitWidth = YES;
        self.durationLabel.minimumScaleFactor = 0.1f;
        self.durationLabel.numberOfLines = 2;
        float time = _frame_width / self.scaleFactor;
        NSString* timeStr = [self timeToStr:time];
        [self.durationLabel setText:[NSString stringWithFormat:@"TEXT\n%@", timeStr]];
        self.durationLabel.textColor = [UIColor whiteColor];
        self.durationLabel.shadowColor = [UIColor blackColor];
        self.durationLabel.shadowOffset = CGSizeMake(0, 1);
        [_centerView addSubview:self.durationLabel];
        self.durationLabel.center = CGPointMake(_centerView.bounds.size.width/2, _centerView.bounds.size.height/2);
        self.durationLabel.userInteractionEnabled = NO;
        
        self.groupImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100.0f, self.bounds.size.height)];
        self.groupImageView.backgroundColor = [UIColor clearColor];
        [self.groupImageView setImage:[UIImage imageNamed:@"group"]];
        [_centerView addSubview:self.groupImageView];
        self.groupImageView.userInteractionEnabled = NO;
        self.groupImageView.hidden = YES;
        self.groupImageView.center = CGPointMake(_centerView.bounds.size.width/2, _centerView.bounds.size.height/2);

        _durationSeconds = time;
        
        /* select tap gesture */
        UITapGestureRecognizer *selectGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(slider_selected:)];
        selectGesture.delegate = self;
        [_centerView addGestureRecognizer:selectGesture];
        [selectGesture setNumberOfTapsRequired:1];

        [self isActived];
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
            self.startAnimationLabel = [[UILabel alloc] initWithFrame:CGRectMake(thumbWidth, 0, 40, frame.size.height-2)];
        else
            self.startAnimationLabel = [[UILabel alloc] initWithFrame:CGRectMake(thumbWidth, 5, 50, frame.size.height-10)];
        
        [self.startAnimationLabel setBackgroundColor:[UIColor colorWithWhite:0.2f alpha:0.2f]];
        self.startAnimationLabel.layer.borderColor = [UIColor whiteColor].CGColor;
        self.startAnimationLabel.layer.borderWidth = 0.5f;
        self.startAnimationLabel.shadowColor = [UIColor blackColor];
        self.startAnimationLabel.shadowOffset = CGSizeMake(0, 1);
        [self.startAnimationLabel setFont:[UIFont fontWithName:MYRIADPRO size:font]];
        self.startAnimationLabel.lineBreakMode = NSLineBreakByClipping;
        [self.startAnimationLabel setAdjustsFontSizeToFitWidth:YES];
        [self.startAnimationLabel setMinimumScaleFactor:0.1f];
        [self.startAnimationLabel setNumberOfLines:2];
        [self.startAnimationLabel setTextColor:[UIColor whiteColor]];
        [self.startAnimationLabel setTextAlignment:NSTextAlignmentCenter];
        [_centerView addSubview:self.startAnimationLabel];
        self.startAnimationLabel.userInteractionEnabled = YES;
        [self.startAnimationLabel setText:@"None\n0.00s"];

        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionStart:)];
        tapGesture.delegate = self;
        [tapGesture setNumberOfTapsRequired:1];
        [self.startAnimationLabel addGestureRecognizer:tapGesture];

        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
            self.endAnimationLabel = [[UILabel alloc] initWithFrame:CGRectMake(_centerView.frame.size.width - thumbWidth - 40, 0, 40, frame.size.height-2)];
        else
            self.endAnimationLabel = [[UILabel alloc] initWithFrame:CGRectMake(_centerView.frame.size.width - thumbWidth - 50, 5, 50, frame.size.height-10)];
        
        [self.endAnimationLabel setBackgroundColor:[UIColor colorWithWhite:0.2f alpha:0.2f]];
        self.endAnimationLabel.layer.borderColor = [UIColor whiteColor].CGColor;
        self.endAnimationLabel.layer.borderWidth = 0.5f;
        self.endAnimationLabel.shadowColor = [UIColor blackColor];
        self.endAnimationLabel.shadowOffset = CGSizeMake(0, 1);
        [self.endAnimationLabel setFont:[UIFont fontWithName:MYRIADPRO size:font]];
        self.endAnimationLabel.lineBreakMode = NSLineBreakByClipping;
        [self.endAnimationLabel setAdjustsFontSizeToFitWidth:YES];
        [self.endAnimationLabel setMinimumScaleFactor:0.1f];
        [self.endAnimationLabel setNumberOfLines:2];
        [self.endAnimationLabel setTextColor:[UIColor whiteColor]];
        [self.endAnimationLabel setTextAlignment:NSTextAlignmentCenter];
        [_centerView addSubview:self.endAnimationLabel];
        self.endAnimationLabel.userInteractionEnabled = YES;
        [self.endAnimationLabel setText:@"None\n0.00s"];

        tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionEnd:)];
        tapGesture.delegate = self;
        [tapGesture setNumberOfTapsRequired:1];
        [self.endAnimationLabel addGestureRecognizer:tapGesture];

        self.startActionType = gnStartActionTypeDef;
        self.endActionType = gnEndActionTypeDef;
        self.startActionTime = grStartActionTimeDef;
        self.endActionTime = grEndActionTimeDef;
        
        if (self.startActionType != ACTION_NONE)
        {
            NSString* startActionTypeStr = [gaActionNameArray objectAtIndex:self.startActionType];
            [self.startAnimationLabel setText:[NSString stringWithFormat:@"%@\n%.2fs", startActionTypeStr, self.startActionTime]];
            self.startAnimationLabel.frame = CGRectMake(_leftThumb.frame.size.width, (self.frame.size.height-self.startAnimationLabel.frame.size.height)/2.0f, self.startAnimationLabel.frame.size.width, self.startAnimationLabel.frame.size.height);
        }
        
        if (self.endActionType != ACTION_NONE)
        {
            NSString* endActionTypeStr = [gaActionNameArray objectAtIndex:self.endActionType];
            [self.endAnimationLabel setText:[NSString stringWithFormat:@"%@\n%.2fs", endActionTypeStr, self.endActionTime]];
            self.endAnimationLabel.frame = CGRectMake(_centerView.frame.size.width - _rightThumb.frame.size.width - self.endAnimationLabel.frame.size.width, (self.frame.size.height-self.endAnimationLabel.frame.size.height)/2.0f, self.endAnimationLabel.frame.size.width, self.endAnimationLabel.frame.size.height);
        }
        
        [self drawRuler];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];

    if (self)
    {
        // Initialization code
    }
    
    return self;
}


#pragma mark - 
#pragma mark - Set actions for a duplicate / open project

-(void)setActions:(int) startActionType startTime:(CGFloat) startActionTime endType:(int) endActionType endTime:(CGFloat)endActionTime
{
    self.startActionType = startActionType;
    self.startActionTime = startActionTime;
    self.endActionType = endActionType;
    self.endActionTime = endActionTime;
    
    if (self.media_type == MEDIA_MUSIC)
    {
        if (self.startActionType != ACTION_NONE)
        {
            [self.startAnimationLabel setText:[NSString stringWithFormat:@"Fade\n%.2fs", self.startActionTime]];
            self.startAnimationLabel.frame = CGRectMake(_leftThumb.frame.size.width, (self.frame.size.height-self.startAnimationLabel.frame.size.height)/2.0f, self.startAnimationLabel.frame.size.width, self.startAnimationLabel.frame.size.height);
        }
        else
        {
            [self.startAnimationLabel setText:@"None\n0.00s"];
        }
        
        if (self.endActionType != ACTION_NONE)
        {
            [self.endAnimationLabel setText:[NSString stringWithFormat:@"Fade\n%.2fs", self.endActionTime]];
            self.endAnimationLabel.frame = CGRectMake(_centerView.frame.size.width - _rightThumb.frame.size.width - self.endAnimationLabel.frame.size.width, (self.frame.size.height-self.endAnimationLabel.frame.size.height)/2.0f, self.endAnimationLabel.frame.size.width, self.endAnimationLabel.frame.size.height);
        }
        else
        {
            [self.endAnimationLabel setText:@"None\n0.00s"];
        }
    }
    else
    {
        if (self.startActionType != ACTION_NONE)
        {
            NSString* startActionTypeStr = [gaActionNameArray objectAtIndex:self.startActionType];
            [self.startAnimationLabel setText:[NSString stringWithFormat:@"%@\n%.2fs", startActionTypeStr, self.startActionTime]];
            self.startAnimationLabel.frame = CGRectMake(_leftThumb.frame.size.width, (self.frame.size.height-self.startAnimationLabel.frame.size.height)/2.0f, self.startAnimationLabel.frame.size.width, self.startAnimationLabel.frame.size.height);
        }
        else
        {
            [self.startAnimationLabel setText:@"None\n0.00s"];
        }
        
        if (self.endActionType != ACTION_NONE)
        {
            NSString* endActionTypeStr = [gaActionNameArray objectAtIndex:self.endActionType];
            [self.endAnimationLabel setText:[NSString stringWithFormat:@"%@\n%.2fs", endActionTypeStr, self.endActionTime]];
            self.endAnimationLabel.frame = CGRectMake(_centerView.frame.size.width - _rightThumb.frame.size.width - self.endAnimationLabel.frame.size.width, (self.frame.size.height-self.endAnimationLabel.frame.size.height)/2.0f, self.endAnimationLabel.frame.size.width, self.endAnimationLabel.frame.size.height);
        }
        else
        {
            [self.endAnimationLabel setText:@"None\n0.00s"];
        }
    }
}

-(void)setMaxGap:(NSInteger)maxGap
{
    _leftPosition = 0;
    _rightPosition = _frame_width*maxGap/_durationSeconds;
    _maxGap = maxGap;
}

-(void)setMinGap:(NSInteger)minGap
{
    _leftPosition = 0;
    _rightPosition = _frame_width*minGap/_durationSeconds;
    _minGap = minGap;
}

- (void)delegateNotification
{
    if ([_delegate respondsToSelector:@selector(videoRange:didChangeLeftPosition:rightPosition:)])
    {
        [_delegate videoRange:self didChangeLeftPosition:self.leftPosition rightPosition:self.rightPosition];
    }
}

#pragma mark - changed Text Thumbnail
-(void) changedTextThumbnail:(NSString*) string
{
    [self.thumbnailLabel setText:string];
    
    UIGraphicsBeginImageContext(self.thumbnailLabel.bounds.size);
    self.thumbnailLabel.hidden = NO;
    [self.thumbnailLabel.layer renderInContext:UIGraphicsGetCurrentContext()];
    self.thumbnailLabel.hidden = YES;
    UIImage* thumbnailImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [self.thumbnailImageView setImage:thumbnailImage];
}

#pragma mark - Change Slider Frame by ScaleFactor
-(void) changeSliderFrame:(CGFloat)scaleFactor
{
    if (scaleFactor == 0.0f)
    {
        scaleFactor = 0.1f;
        NSLog(@"scaleFactor was 0.0f");
    }
    
    if (self.scaleFactor == 0.0f)
    {
        self.scaleFactor = 0.1f;
        NSLog(@"self.scaleFactor was 0.0f");
    }
    
    CGFloat oldScaleFactor = self.scaleFactor;
    self.scaleFactor = scaleFactor;
    
    _frame_width = self.scaleFactor*_durationSeconds;
    
    self.frame = CGRectMake(0, self.frame.origin.y, _frame_width, self.frame.size.height);

    _rightPosition = _rightPosition*self.scaleFactor/oldScaleFactor;
    _leftPosition = _leftPosition*self.scaleFactor/oldScaleFactor;
}

#pragma mark - Change Slider Frame by duration

-(void) changeSliderFrameByDuration:(CGFloat)duration
{
    _durationSeconds = duration;
    _frame_width = self.scaleFactor*_durationSeconds;
    
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, _leftPosition + _frame_width, self.frame.size.height);
    _rightPosition = _leftPosition+_frame_width;
}

-(void) changeMusicWaveByRange:(CGFloat) startPosition end:(CGFloat)endPosition
{
    if (self.media_type == MEDIA_MUSIC)
    {
        [self.waveform changeStartEndSamples:(unsigned long int)startPosition end:(unsigned long int)endPosition];
    }
}

-(void) updateWaveform:(NSURL*) musicUrl
{
    self.waveform.audioURL = musicUrl;
    [self.waveform createWaveform];
}

-(void) changeSliderByLeftPosition:(CGFloat) left
{
    _leftPosition = _leftPosition - left;
    _rightPosition = _rightPosition - left;
    
    [self layoutSubviews];
}

-(void) changeSliderPosition:(CGFloat)left right:(CGFloat) right
{
    _leftPosition = left;
    _rightPosition = right;
    
    [self layoutSubviews];
}

-(void) replaceSliderLeftPosition:(CGFloat) left right:(CGFloat) right
{
    if ((self.media_type == MEDIA_PHOTO)||(self.media_type == MEDIA_GIF))
    {
        _leftPosition = left;
        _rightPosition = right;
    }
    else if (self.media_type == MEDIA_VIDEO)
    {
        _rightPosition = _rightPosition - (_leftPosition - left);
        _leftPosition = left;
    }
    
    [self layoutSubviews];
}


#pragma mark - Gestures

- (void)handleLeftPan:(UIPanGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan || gesture.state == UIGestureRecognizerStateChanged)
    {
        if (gesture.state == UIGestureRecognizerStateBegan)
        {
            if (!self.isSelected)
            {
                [self isActived];
                
                if ([self.delegate respondsToSelector:@selector(timelineObjectSelected:)])
                {
                    [self.delegate timelineObjectSelected:self.objectIndex];
                }
            }
            
            if (self.objectIndex > 0)
            {
                if ([_delegate respondsToSelector:@selector(previewShow:)])
                {
                    [_delegate previewShow:self.objectIndex];
                }
            }
        }
        
        CGPoint translation = [gesture translationInView:self];
        
        _leftPosition += translation.x;
        
        if (_leftPosition < 0)
            _leftPosition = 0;
        
        if ((_rightPosition - _leftPosition <= _leftThumb.frame.size.width + _rightThumb.frame.size.width) ||
            ((self.maxGap > 0) && (self.rightPosition-self.leftPosition > self.maxGap)) ||
            ((self.minGap > 0) && (self.rightPosition-self.leftPosition < self.minGap)))
        {
            _leftPosition -= translation.x;
        }
        
        [gesture setTranslation:CGPointZero inView:self];
        
        [self setNeedsLayout];
        
        [self delegateNotification];
    }
    else if (gesture.state == UIGestureRecognizerStateEnded)
    {
        if ([_delegate respondsToSelector:@selector(previewHide)])
        {
            [_delegate previewHide];
        }
    }
}

- (void)handleRightPan:(UIPanGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan || gesture.state == UIGestureRecognizerStateChanged)
    {
        if (gesture.state == UIGestureRecognizerStateBegan)
        {
            if (!self.isSelected)
            {
                [self isActived];
                
                if ([self.delegate respondsToSelector:@selector(timelineObjectSelected:)])
                {
                    [self.delegate timelineObjectSelected:self.objectIndex];
                }
            }
            
            if (self.objectIndex > 0)
            {
                if ([_delegate respondsToSelector:@selector(previewShow:)])
                {
                    [_delegate previewShow:self.objectIndex];
                }
            }
        }

        CGPoint translation = [gesture translationInView:self];
        _rightPosition += translation.x;
        
        if (_rightPosition < 0)
            _rightPosition = 0;
        
        if (_rightPosition-_leftPosition <= 0)
            _rightPosition -= translation.x;
        
        if ((_rightPosition-_leftPosition <= _leftThumb.frame.size.width+_rightThumb.frame.size.width) ||
            ((self.maxGap > 0) && (self.rightPosition-self.leftPosition > self.maxGap)) ||
            ((self.minGap > 0) && (self.rightPosition-self.leftPosition < self.minGap)))
        {
            _rightPosition -= translation.x;
        }
        
        [gesture setTranslation:CGPointZero inView:self];
        
        [self setNeedsLayout];
        
        [self delegateNotification];
    }
    else if (gesture.state == UIGestureRecognizerStateEnded)
    {
        if ([_delegate respondsToSelector:@selector(previewHide)])
        {
            [_delegate previewHide];
        }
    }
}

- (void)moveTimeSlider:(UIPanGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan || gesture.state == UIGestureRecognizerStateChanged)
    {
        CGPoint translation = [gesture translationInView:self];

        if (gesture.state == UIGestureRecognizerStateBegan)
        {
            isMoveStart = YES;
            
            if (!self.isSelected)
            {
                [self isActived];
                
                if ([self.delegate respondsToSelector:@selector(timelineObjectSelected:)])
                {
                    [self.delegate timelineObjectSelected:self.objectIndex];
                }
            }
            
            if (self.objectIndex > 0)
            {
                if ([_delegate respondsToSelector:@selector(previewShow:)])
                {
                    [_delegate previewShow:self.objectIndex];
                }
            }
        }
        else if (gesture.state == UIGestureRecognizerStateChanged)
        {
            if (isMoveStart)
            {
                isMoveStart = NO;
                
                if (fabs(translation.x) >= fabs(translation.y))
                    isLR = YES;
                else
                    isLR = NO;
            }

            if (isLR)
            {
                _leftPosition += translation.x;
                _rightPosition += translation.x;
                
                [gesture setTranslation:CGPointZero inView:self];
                
                [self setNeedsLayout];
                
                if (self.isGrouped)
                {
                    if ([_delegate respondsToSelector:@selector(changeGroupPosition:)])
                    {
                        [_delegate changeGroupPosition:translation.x];
                    }
                }
                
                [self delegateNotification];
            }
            else
            {
                _yPosition += translation.y;
                
                if (_yPosition <= grSliderHeight/2.0f)
                    _yPosition = grSliderHeight/2.0f;
                else if (_yPosition >= grMaxContentHeight - grSliderHeight/2.0f)
                    _yPosition = grMaxContentHeight - grSliderHeight/2.0f;
                
                [gesture setTranslation:CGPointZero inView:self];
                
                [self setNeedsLayout];
                
                [self changeSliderYPosition];
                
                [self delegateNotification];
            }
        }
    }
    else if (gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateCancelled || gesture.state == UIGestureRecognizerStateFailed)
    {
        isMoveStart = NO;

        if ([_delegate respondsToSelector:@selector(didEndGesture)])
        {
            [_delegate didEndGesture];
        }
        
        if ([_delegate respondsToSelector:@selector(previewHide)])
        {
            [_delegate previewHide];
        }
    }
}

- (void)layoutSubviews
{
    CGFloat inset = _leftThumb.frame.size.width / 2;
    
    int thumbWidth = 0;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        thumbWidth = 10;
    else
        thumbWidth = 20;

    _leftThumb.frame = CGRectMake(_leftThumb.frame.origin.x, 0.0f, thumbWidth*grZoomScale, self.bounds.size.height);
    _rightThumb.frame = CGRectMake(_rightThumb.frame.origin.x, 0.0f, thumbWidth*grZoomScale, self.bounds.size.height);
    
    [_leftThumb setNeedsDisplay];
    [_rightThumb setNeedsDisplay];
    
    _leftThumb.center = CGPointMake(_leftPosition+inset, _leftThumb.frame.size.height/2);
    _rightThumb.center = CGPointMake(_rightPosition-inset, _rightThumb.frame.size.height/2);
    
    _centerView.frame = CGRectMake(_leftThumb.frame.origin.x, _centerView.frame.origin.y, _rightThumb.frame.origin.x - _leftThumb.frame.origin.x + _leftThumb.frame.size.width,_centerView.frame.size.height);
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        self.startAnimationLabel.frame = CGRectMake(_leftThumb.frame.size.width, (self.frame.size.height-self.startAnimationLabel.frame.size.height)/2.0f, 40.0f*grSliderHeight/grSliderHeightMax, grSliderHeight - 2.0f*grSliderHeight/grSliderHeightMax);
        
        self.endAnimationLabel.frame = CGRectMake(_centerView.frame.size.width - _rightThumb.frame.size.width - self.endAnimationLabel.frame.size.width, (self.frame.size.height-self.endAnimationLabel.frame.size.height)/2.0f, 40.0f*grSliderHeight/grSliderHeightMax, grSliderHeight - 2.0f*grSliderHeight/grSliderHeightMax);
    }
    else
    {
        self.startAnimationLabel.frame = CGRectMake(_leftThumb.frame.size.width, (self.frame.size.height-self.startAnimationLabel.frame.size.height)/2.0f, 50.0f*grSliderHeight/grSliderHeightMax, grSliderHeight - 10.0f*grSliderHeight/grSliderHeightMax);
        
        self.endAnimationLabel.frame = CGRectMake(_centerView.frame.size.width - _rightThumb.frame.size.width - self.endAnimationLabel.frame.size.width, (self.frame.size.height-self.endAnimationLabel.frame.size.height)/2.0f, 50.0f*grSliderHeight/grSliderHeightMax, grSliderHeight - 10.0f*grSliderHeight/grSliderHeightMax);
    }
    
    self.thumbnailImageView.frame = CGRectMake(self.thumbnailImageView.frame.origin.x, self.thumbnailImageView.frame.origin.y, _centerView.bounds.size.height*2.0f, _centerView.bounds.size.height);
    self.thumbnailImageView.center = CGPointMake(_centerView.bounds.size.width/2, _centerView.bounds.size.height/2);
    
    if (self.thumbnailLabel)
    {
        self.thumbnailLabel.frame = CGRectMake(self.thumbnailLabel.frame.origin.x, self.thumbnailLabel.frame.origin.y, grSliderHeight*3.0f, grSliderHeight*1.5f);
        self.thumbnailLabel.center = CGPointMake(_centerView.bounds.size.width/2, _centerView.bounds.size.height/2);
    }

    self.durationLabel.frame = CGRectMake(self.startAnimationLabel.frame.origin.x + self.startAnimationLabel.frame.size.width, 0.0f, self.endAnimationLabel.frame.origin.x - (self.startAnimationLabel.frame.origin.x + self.startAnimationLabel.frame.size.width), grSliderHeight);
    self.durationLabel.center = CGPointMake(_centerView.bounds.size.width/2, _centerView.bounds.size.height/2);
    self.groupImageView.center = CGPointMake(_centerView.bounds.size.width/2, _centerView.bounds.size.height/2);
    
    self.frame = CGRectMake(0, self.frame.origin.y, _centerView.frame.origin.x + _centerView.frame.size.width, self.frame.size.height);

    NSString* timeStr = [self timeToStr:(self.rightPosition - self.leftPosition)];
    
    if (self.media_type == MEDIA_VIDEO)
    {
        [self.durationLabel setText:[NSString stringWithFormat:@"VIDEO\n%@", timeStr]];
    }
    else if (self.media_type == MEDIA_MUSIC)
    {
        [self.durationLabel setText:[NSString stringWithFormat:@"MUSIC\n%@", timeStr]];
        
        self.waveform.frame = _centerView.bounds;
        [self.waveform changeWaveFrame];
    }
    else if (self.media_type == MEDIA_PHOTO)
    {
        [self.durationLabel setText:[NSString stringWithFormat:@"PHOTO\n%@", timeStr]];
    }
    else if (self.media_type == MEDIA_GIF)
    {
        [self.durationLabel setText:[NSString stringWithFormat:@"GIF\n%@", timeStr]];
    }
    else
    {
        [self.durationLabel setText:[NSString stringWithFormat:@"TEXT\n%@", timeStr]];
    }
    
    [self drawRuler];
}

- (void) changeSliderYPosition
{
    self.center = CGPointMake(self.center.x, _yPosition);
}


#pragma mark - Video

-(void)getMovieFrame
{
    self.myAsset = [AVURLAsset URLAssetWithURL:_mediaUrl options:nil];
    self.imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:self.myAsset];
    self.imageGenerator.appliesPreferredTrackTransform = YES;

    if ([self isRetina])
        self.imageGenerator.maximumSize = CGSizeMake(_centerView.frame.size.width*2, _centerView.frame.size.height*2);
    else
        self.imageGenerator.maximumSize = CGSizeMake(_centerView.frame.size.width, _centerView.frame.size.height);
    
    NSError *error;
    CGImageRef halfWayImage = [self.imageGenerator copyCGImageAtTime:kCMTimeZero actualTime:NULL error:&error];
    
    if (halfWayImage != NULL)
    {
        UIImage *videoScreen;
        
        if ([self isRetina])
            videoScreen = [[UIImage alloc] initWithCGImage:halfWayImage scale:2.0 orientation:UIImageOrientationUp];
        else
            videoScreen = [[UIImage alloc] initWithCGImage:halfWayImage];

        self.thumbnailImageView = [[UIImageView alloc] initWithImage:videoScreen];
        [_centerView addSubview:self.thumbnailImageView];

        CGImageRelease(halfWayImage);
    }
    
    self.thumbnailImageView.userInteractionEnabled = NO;
    
    float font = 0.0f;

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        font = 10;
    else
        font = 14;
    
    self.durationLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100.0f, self.bounds.size.height)];
    self.durationLabel.backgroundColor = [UIColor clearColor];
    self.durationLabel.textAlignment = NSTextAlignmentCenter;
    self.durationLabel.adjustsFontSizeToFitWidth = YES;
    self.durationLabel.minimumScaleFactor = 0.1f;
    self.durationLabel.numberOfLines = 2;
    self.durationLabel.font = [UIFont fontWithName:MYRIADPRO size:font];
    float time = (float)self.myAsset.duration.value / (float)self.myAsset.duration.timescale;
    NSString* timeStr = [self timeToStr:time];
    [self.durationLabel setText:[NSString stringWithFormat:@"VIDEO\n%@", timeStr]];
    self.durationLabel.textColor = [UIColor whiteColor];
    self.durationLabel.shadowColor = [UIColor blackColor];
    self.durationLabel.shadowOffset = CGSizeMake(0, 1);
    [_centerView addSubview:self.durationLabel];
    self.durationLabel.userInteractionEnabled = NO;

    //use this for custom font
    self.thumbnailImageView.center = CGPointMake(_centerView.bounds.size.width/2, _centerView.bounds.size.height/2);
    self.durationLabel.center = CGPointMake(_centerView.bounds.size.width/2, _centerView.bounds.size.height/2);
    _durationSeconds = CMTimeGetSeconds([self.myAsset duration]);
    self.scaleFactor = self.frame.size.width / _durationSeconds;
    
    self.groupImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100.0f, self.bounds.size.height)];
    self.groupImageView.backgroundColor = [UIColor clearColor];
    [self.groupImageView setImage:[UIImage imageNamed:@"group"]];
    [_centerView addSubview:self.groupImageView];
    self.groupImageView.userInteractionEnabled = NO;
    self.groupImageView.hidden = YES;
    self.groupImageView.center = CGPointMake(_centerView.bounds.size.width/2, _centerView.bounds.size.height/2);
}


#pragma mark - Properties

- (CGFloat)leftPosition
{
    return _leftPosition * _durationSeconds / _frame_width;
}

- (CGFloat)rightPosition
{
    return _rightPosition * _durationSeconds / _frame_width;
}

-(NSString *)trimDurationStr
{
    int delta = floor(self.rightPosition - self.leftPosition);
   
    return [NSString stringWithFormat:@"%d", delta];
}

-(NSString *)trimIntervalStr
{
    NSString *from = [self timeToStr:self.leftPosition];
    NSString *to = [self timeToStr:self.rightPosition];
    
    return [NSString stringWithFormat:@"%@ - %@", from, to];
}


#pragma mark - Helpers

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

-(BOOL)isRetina
{
    return ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] && ([UIScreen mainScreen].scale == 2.0));
}


#pragma mark - 
#pragma mark - Tap Gesture

- (void)slider_selected:(UITapGestureRecognizer *)gestureRecognizer
{
    if (!self.isSelected)
    {
        [self isActived];
        
        if ([self.delegate respondsToSelector:@selector(timelineObjectSelected:)])
        {
            [self.delegate timelineObjectSelected:self.objectIndex];
        }
    }

    if ([self.delegate respondsToSelector:@selector(onShowTimelineMenu:)])
    {
        [self.delegate onShowTimelineMenu:self.objectIndex];
    }
}


- (void) isActived
{
    self.isSelected = YES;
    self.centerView.layer.borderColor = [UIColor greenColor].CGColor;
    self.centerView.layer.borderWidth = 3.0f;
}

- (void) isNotActived
{
    self.isSelected = NO;
    self.centerView.layer.borderColor = [UIColor clearColor].CGColor;
}

- (void) actionStart:(UITapGestureRecognizer *)gestureRecognizer
{
    [self setSliderAction:YES];
}

- (void) actionEnd:(UITapGestureRecognizer *)gestureRecognizer
{
    [self setSliderAction:NO];
}


#pragma mark -
#pragma mark - Start/End Action Settings!!!

- (void) setSliderAction:(BOOL) isStart
{
    CGFloat duration = self.rightPosition - self.leftPosition;

    NSMutableArray* timeArray = [[NSMutableArray alloc] init];

    CGFloat actionTime = 0.0f;
    [timeArray addObject:[NSString stringWithFormat:@"%.2fs", MIN_DURATION]];
    
    if (isStart)
    {
        duration = duration - self.endActionTime;
    }
    else
    {
        duration = duration - self.startActionTime;
    }
    
    while (actionTime <= duration - 0.5f)
    {
        actionTime += 0.5f;
        NSString* timeStr = [NSString stringWithFormat:@"%.2fs", actionTime];
        [timeArray addObject:timeStr];
    }
    
    ActionSettingsPickerView *picker = [[ActionSettingsPickerView alloc] initWithTitle:@""];
    picker.delegate = self;
    
    if (self.media_type == MEDIA_MUSIC)
    {
        [picker setTitlesForComponenets:[NSArray arrayWithObjects:[NSArray arrayWithObjects:@"None", @"Fade", nil],
                                         [NSArray arrayWithArray:timeArray],
                                         nil]];
    }
    else
    {
        [picker setTitlesForComponenets:[NSArray arrayWithObjects:gaActionNameArray,
                                         [NSArray arrayWithArray:timeArray],
                                         nil]];
    }
    
    NSInteger selectedActionTypeIndex = 0;
    NSInteger selectedActionTimeIndex = 0;
    
    for (int i=0; i<timeArray.count; i++)
    {
        NSString* str = [timeArray objectAtIndex:i];
        CGFloat time = [str floatValue];
        
        if (isStart)
        {
            if (time == self.startActionTime)
            {
                selectedActionTimeIndex = i;
                break;
            }
        }
        else
        {
            if (time == self.endActionTime)
            {
                selectedActionTimeIndex = i;
                break;
            }
        }
    }

    if (isStart)
        selectedActionTypeIndex = self.startActionType;
    else
        selectedActionTypeIndex = self.endActionType;
    
    [picker setIndexOfActionType:selectedActionTypeIndex];
    [picker setIndexOfActionTime:selectedActionTimeIndex];
    [picker setIsStart:isStart];
    [picker initializePicker];
    
    if (self.customModalView != nil)
    {
        [self.customModalView hideCustomModalView];
        self.customModalView = nil;
    }
    
    self.customModalView = [[CustomModalView alloc] initWithView:picker bgColor:[UIColor whiteColor]];
    self.customModalView.delegate = self;
    self.customModalView.dismissButtonRight = YES;
    [self.customModalView show];
}


#pragma mark -
#pragma mark - ActionSettingsPickerView Delegate

-(void)actionSheetPickerView:(ActionSettingsPickerView *)pickerView didSelectTitles:(NSArray *)titles typeIndex:(NSInteger)actionTypeIndex
{
    //action type
    NSString* actionTypeStr = [titles objectAtIndex:0];
    int actionType = (int)actionTypeIndex;
    
    //action time
    NSString* actionTimeStr = [titles objectAtIndex:1];
    CGFloat actionTime = [actionTimeStr floatValue];
    
    if (pickerView.isStart)
    {
        self.startActionType = actionType;
        self.startActionTime = actionTime;
        
        if ((actionType == ACTION_NONE)&&(actionTime == MIN_DURATION))
            actionTime = 0.00f;
        
        [self.startAnimationLabel setText:[NSString stringWithFormat:@"%@\n%.2fs", actionTypeStr, actionTime]];
        self.startAnimationLabel.frame = CGRectMake(_leftThumb.frame.size.width, (self.frame.size.height-self.startAnimationLabel.frame.size.height)/2.0f, self.startAnimationLabel.frame.size.width, self.startAnimationLabel.frame.size.height);
        
        if (isActionChangeAll && ([self.delegate respondsToSelector:@selector(changeActionAll:isStart:actionTypeStr:actionType:actionTime:)]))
        {
            [self.delegate changeActionAll:self.media_type isStart:YES actionTypeStr:actionTypeStr actionType:self.startActionType actionTime:self.startActionTime];
        }
        
        isActionChangeAll = NO;
    }
    else
    {
        self.endActionType = actionType;
        self.endActionTime = actionTime;

        if ((actionType == ACTION_NONE)&&(actionTime == MIN_DURATION))
            actionTime = 0.00f;

        [self.endAnimationLabel setText:[NSString stringWithFormat:@"%@\n%.2fs", actionTypeStr, actionTime]];
        self.endAnimationLabel.frame = CGRectMake(_centerView.frame.size.width - _rightThumb.frame.size.width - self.endAnimationLabel.frame.size.width, (self.frame.size.height-self.endAnimationLabel.frame.size.height)/2.0f, self.endAnimationLabel.frame.size.width, self.endAnimationLabel.frame.size.height);
        
        if (isActionChangeAll && ([self.delegate respondsToSelector:@selector(changeActionAll:isStart:actionTypeStr:actionType:actionTime:)]))
        {
            [self.delegate changeActionAll:self.media_type isStart:NO actionTypeStr:actionTypeStr actionType:self.endActionType actionTime:self.endActionTime];
        }
        
        isActionChangeAll = NO;
    }
    
    if (self.customModalView != nil)
    {
        [self.customModalView hideCustomModalView];
        self.customModalView = nil;
    }
}


-(void) didCancelActionSettings
{
    if (self.customModalView != nil)
    {
        [self.customModalView hideCustomModalView];
        self.customModalView = nil;
    }
}

-(void) drawRuler
{
    self.centerView.duration = self.rightPosition - self.leftPosition;
    [self.centerView setNeedsDisplay];
}


#pragma mark -
#pragma mark FDWaveformViewDelegate

- (void)waveformViewDidRender:(FDWaveformView *)waveformView
{
    [UIView animateWithDuration:0.02f animations:^{
        waveformView.alpha = 1.0f;
    }];
}


@end
