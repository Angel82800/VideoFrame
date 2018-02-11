
#import "CircleProgressBar.h"

#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)
#define DefaultProgressBarTrackColor [UIColor colorWithRed:0.933 green:0.933 blue:0.855 alpha:0.3]
#define DefaultHintBackgroundColor [UIColor colorWithRed:0.2509 green:0.2353 blue:0.2353 alpha:0.5]
#define DefaultHintTextFontPhone [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:15.0f]
#define DefaultHintTextFontPad [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:25.0f]
#define DefaultHintDurationTextFontPhone [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:11.0f]
#define DefaultHintDurationTextFontPad [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:17.0f]
#define DefaultHintTextColor [UIColor whiteColor]

#define kDefClearMiddle 45
#define distanceBetween(p1,p2) sqrt(pow((p2.x-p1.x),2) + pow((p2.y-p1.y),2))


const CGFloat AnimationChangeTimeDuration = 0.2f;
const CGFloat AnimationChangeTimeStep = 0.01f;

const StringGenerationBlock DefaultHintTextGenerationBlock = ^NSString *(CGFloat progress) {
    return [NSString stringWithFormat:@"%.0f%%", progress * 100];
};

const StringGenerationBlockForDuration DefaultDurationTextGenerationBlick = ^NSString *(NSString* duration) {
    return duration;
};


@interface CircleProgressBar (Private)

- (CGFloat)progressAccordingToBounds:(CGFloat)progress;
- (UIColor*)hintViewBackgroundColorForDrawing;
- (UIColor*)progressBarProgressColorForDrawing;
- (UIColor*)progressBarTrackColorForDrawing;
- (UIColor*)hintTextColorForDrawing;
- (UIFont*)hintTextFontForDrawing;
- (UIFont*)hintDurationTextFontForDrawing;
- (NSString*)stringRepresentationOfProgress:(CGFloat)progress;
- (NSString*)stringRepresentationOfDuration:(NSString*)duration;
- (void)drawProgressBar:(CGContextRef)context progressAngle:(CGFloat)progressAngle center:(CGPoint)center radius:(CGFloat)radius;
- (void)drawBackground:(CGContextRef)context;
- (void)drawSimpleHintTextAtCenter:(CGPoint)center;
- (void)drawAttributedHintTextAtCenter:(CGPoint)center;
- (void)drawHint:(CGContextRef)context center:(CGPoint)center radius:(CGFloat)radius;
- (void)animateProgressBarChangeFrom:(CGFloat)startProgress to:(CGFloat)endProgress duration:(CGFloat)duration;
- (void)updateProgressBarForAnimation;

@end

@implementation CircleProgressBar
{
    NSTimer *_animationTimer;
    CGFloat _currentAnimationProgress, _startProgress, _endProgress, _animationProgressStep;
    StringGenerationBlock _hintTextGenerationBlock;
    AttributedStringGenerationBlock _hintAttributedTextGenerationBlock;
    StringGenerationBlockForDuration _hintTextDurationGenerationBlock;
    AttributedStringGenerationBlockForDuration _hintAttributedTextDurationGenerationBlock;
}

-(id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        self._centerPoint = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/3*2);
        self.backgroundColor = [UIColor clearColor];
    }
    
    return self;
}

- (void)setProgressBarWidth:(CGFloat)progressBarWidth
{
    _progressBarWidth = progressBarWidth;
    
    [self setNeedsDisplay];
}

- (void)setHintViewSpacingForDrawing:(CGFloat) hintViewSpacingForDrawing
{
    _hintViewSpacingForDrawing = hintViewSpacingForDrawing;
}

- (void)setProgress:(CGFloat)progress timeStr:(NSString*)duration
{
    _duration = duration;
    
    progress = [self progressAccordingToBounds:progress];
    _progress = progress;
    
    [self setNeedsDisplay];
}

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated
{
    [self setProgress:progress animated:animated duration:AnimationChangeTimeDuration];
}

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated duration:(CGFloat)duration
{
    progress = [self progressAccordingToBounds:progress];
    
    if (_progress == progress)
    {
        return;
    }
    
    [_animationTimer invalidate];
    _animationTimer = nil;
    
    if (animated)
    {
        [self animateProgressBarChangeFrom:_progress to:progress duration:duration];
    }
    else
    {
        _progress = progress;
        [self setNeedsDisplay];
    }
    
    if ([_delegate respondsToSelector:@selector(didChangedProgress:)])
    {
        [_delegate didChangedProgress:_progress];
    }
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGPoint innerCenter = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
    CGFloat radius = MIN(innerCenter.x, innerCenter.y) - 2.0f;
    CGFloat currentProgressAngle = (_progress * 360) + _startAngle;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, rect);

    [self drawBackground:context];
    
    [self drawProgressBar:context progressAngle:currentProgressAngle center:innerCenter radius:radius];
    
    if (!_hintHidden) {
        [self drawHint:context center:innerCenter radius:radius];
    }
}

#pragma mark - Setters with View Update

- (void)setProgressBarProgressColor:(UIColor *)progressBarProgressColor
{
    _progressBarProgressColor = progressBarProgressColor;
    [self setNeedsDisplay];
}

- (void)setProgressBarTrackColor:(UIColor *)progressBarTrackColor
{
    _progressBarTrackColor = progressBarTrackColor;
    [self setNeedsDisplay];
}

- (void)setHintHidden:(BOOL)isHintHidden
{
    _hintHidden = isHintHidden;
    [self setNeedsDisplay];
}

- (void)setHintViewSpacing:(CGFloat)hintViewSpacing
{
    _hintViewSpacing = hintViewSpacing;
    [self setNeedsDisplay];
}

- (void)setHintViewBackgroundColor:(UIColor *)hintViewBackgroundColor
{
    _hintViewBackgroundColor = hintViewBackgroundColor;
    [self setNeedsDisplay];
}

- (void)setHintTextFont:(UIFont *)hintTextFont
{
    _hintTextFont = hintTextFont;
    [self setNeedsDisplay];
}

- (void)setHintTextColor:(UIColor *)hintTextColor
{
    _hintTextColor = hintTextColor;
    [self setNeedsDisplay];
}

- (void)setHintTextGenerationBlock:(StringGenerationBlock)generationBlock
{
    _hintTextGenerationBlock = generationBlock;
    [self setNeedsDisplay];
}

- (void)setHintAttributedGenerationBlock:(AttributedStringGenerationBlock)generationBlock
{
    _hintAttributedTextGenerationBlock = generationBlock;
    [self setNeedsDisplay];
}

- (void)setStartAngle:(CGFloat)startAngle
{
    _startAngle = startAngle;
    [self setNeedsDisplay];
}


#pragma mark - 
#pragma mark - Pan Gesture

- (void)panGestureRecognized:(UIPanGestureRecognizer *)sender
{
    CGPoint location = [sender locationInView:self];
    
    if (sender.state == UIGestureRecognizerStateChanged || sender.state == UIGestureRecognizerStateBegan)
    {
        CGPoint sliderStartPoint = self._lastPosition;
        
        if(CGPointEqualToPoint(self._lastPosition, CGPointZero))
            sliderStartPoint = location;
        
        CGFloat angle = [self angleBetweenCenterPoint:self._centerPoint point1:sliderStartPoint point2:location];
        
        self._lastPosition = location;
        
        if(angle != 0)
        {
            CGFloat progressAdded = (-1.0f) * angle / (2*M_PI);
            
            [self setProgress:(_progress + progressAdded) animated:NO];
        }
    }
    
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        self._lastPosition = CGPointZero;
    }
}

-(CGFloat)angleBetweenCenterPoint:(CGPoint)centerPoint point1:(CGPoint)p1 point2:(CGPoint)p2
{
    CGPoint v1 = CGPointMake(p1.x - centerPoint.x, p1.y - centerPoint.y);
    CGPoint v2 = CGPointMake(p2.x - centerPoint.x, p2.y - centerPoint.y);

    CGFloat angle = atan2f(v2.x*v1.y - v1.x*v2.y, v1.x*v2.x + v1.y*v2.y);
    
    return angle;
}


@end


@implementation CircleProgressBar (Private)

#pragma mark - Common

- (CGFloat)progressAccordingToBounds:(CGFloat)progress
{
    progress = MIN(progress, 5);    // max is 500% (fast motion)
    progress = MAX(progress, 0.1);  // min is 10% (slow motion)
    return progress;
}

#pragma mark - Base Drawing

- (void)drawBackground:(CGContextRef)context
{
    CGContextSetFillColorWithColor(context, self.backgroundColor.CGColor);
    CGContextFillRect(context, self.bounds);
}

#pragma mark - ProgressBar Drawing

- (UIColor*)progressBarProgressColorForDrawing
{
    if (_progress <= 1) //(10, 100%)
    {
        return [UIColor redColor];
    }
    else if(_progress <= 2) //(101, 200%)
    {
        return [UIColor greenColor];
    }
    else if(_progress <= 3) //(201, 300%)
    {
        return [UIColor orangeColor];
    }
    else if(_progress <= 4) //(301, 400%)
    {
        return [UIColor brownColor];
    }
    else if(_progress <= 5) //(401, 500%)
    {
        return [UIColor yellowColor];
    }
    
    return [UIColor yellowColor];
}

- (UIColor*)progressBarTrackColorForDrawing
{
    if (_progress <= 1) //(10, 100%)
    {
        return DefaultProgressBarTrackColor;
    }
    else if(_progress <= 2) //(101, 200%)
    {
        return [UIColor redColor];
    }
    else if(_progress <= 3) //(201, 300%)
    {
        return [UIColor greenColor];
    }
    else if(_progress <= 4) //(301, 400%)
    {
        return [UIColor orangeColor];
    }
    else if(_progress < 5) //(401, 500%)
    {
        return [UIColor brownColor];
    }
    
    return [UIColor yellowColor];
}

- (void)drawProgressBar:(CGContextRef)context progressAngle:(CGFloat)progressAngle center:(CGPoint)center radius:(CGFloat)radius
{
    CGFloat barWidth = self.progressBarWidth;
    
    if (barWidth > radius)
        barWidth = radius;
    
    CGContextSetFillColorWithColor(context, self.progressBarProgressColorForDrawing.CGColor);
    CGContextBeginPath(context);
    CGContextAddArc(context, center.x, center.y, radius, DEGREES_TO_RADIANS(_startAngle - 90), DEGREES_TO_RADIANS(progressAngle - 90), 0);
    CGContextAddArc(context, center.x, center.y, radius - barWidth, DEGREES_TO_RADIANS(progressAngle - 90), DEGREES_TO_RADIANS(_startAngle - 90), 1);
    CGContextClosePath(context);
    CGContextFillPath(context);

    CGContextSetFillColorWithColor(context, self.progressBarTrackColorForDrawing.CGColor);
    CGContextBeginPath(context);
    CGContextAddArc(context, center.x, center.y, radius, DEGREES_TO_RADIANS(progressAngle - 90), DEGREES_TO_RADIANS(_startAngle + 360 - 90), 0);
    CGContextAddArc(context, center.x, center.y, radius - barWidth, DEGREES_TO_RADIANS(_startAngle + 360 - 90), DEGREES_TO_RADIANS(progressAngle - 90), 1);
    CGContextClosePath(context);
    CGContextFillPath(context);
    
    CGContextSetFillColorWithColor(context, self.progressBarProgressColorForDrawing.CGColor);
    CGContextBeginPath(context);
    CGContextAddArc(context, center.x, center.y - (radius - barWidth/2.0f), barWidth/2.0f, DEGREES_TO_RADIANS(0), DEGREES_TO_RADIANS(360), 0);
    CGContextClosePath(context);
    CGContextFillPath(context);

    CGContextSetFillColorWithColor(context, [UIColor darkGrayColor].CGColor);
    CGContextBeginPath(context);
    CGPoint endPoint = CGPointMake((center.x + (radius - barWidth/2.0f) * cosf(DEGREES_TO_RADIANS(progressAngle-90))), (center.y + (radius - barWidth/2.0f)* sinf(DEGREES_TO_RADIANS(progressAngle-90))));
    CGContextAddArc(context, endPoint.x, endPoint.y, barWidth/2.0f, DEGREES_TO_RADIANS(0), DEGREES_TO_RADIANS(360), 0);
    CGContextClosePath(context);
    CGContextFillPath(context);
}

#pragma mark - Hint Drawing

- (UIColor*)hintViewBackgroundColorForDrawing
{
    return (_hintViewBackgroundColor != nil ? _hintViewBackgroundColor : DefaultHintBackgroundColor);
}

- (UIFont*)hintTextFontForDrawing
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        return (_hintTextFont != nil ? _hintTextFont : DefaultHintTextFontPhone);
    }

    return (_hintTextFont != nil ? _hintTextFont : DefaultHintTextFontPad);
}

- (UIFont*)hintDurationTextFontForDrawing
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        return (_hintDurationTextFont != nil ? _hintDurationTextFont : DefaultHintDurationTextFontPhone);
    }
    
    return (_hintDurationTextFont != nil ? _hintDurationTextFont : DefaultHintDurationTextFontPad);
}

- (UIColor*)hintTextColorForDrawing
{
    return (_hintTextColor != nil ? _hintTextColor : DefaultHintTextColor);
}

- (NSString*)stringRepresentationOfProgress:(CGFloat)progress
{
    return (_hintTextGenerationBlock != nil ? _hintTextGenerationBlock(progress) : DefaultHintTextGenerationBlock(progress));
}

-(NSString*)stringRepresentationOfDuration:(NSString*)duration
{
    return (_hintTextDurationGenerationBlock != nil ? _hintTextDurationGenerationBlock(duration) : DefaultDurationTextGenerationBlick(duration));
}

- (void)drawSimpleHintTextAtCenter:(CGPoint)center
{
    NSString *progressString = [self stringRepresentationOfProgress:_progress];
    NSString *durationString = [self stringRepresentationOfDuration:_duration];
    
    CGSize hintTextSize = [progressString boundingRectWithSize:CGSizeZero options:NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName: self.hintTextFontForDrawing} context:nil].size;
    CGSize hintDurationTextSize = [durationString boundingRectWithSize:CGSizeZero options:NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName: self.hintDurationTextFontForDrawing} context:nil].size;

    [progressString drawAtPoint:CGPointMake(center.x - hintTextSize.width / 2, center.y - (hintTextSize.height + hintDurationTextSize.height)/2.0f) withAttributes:@{NSFontAttributeName: self.hintTextFontForDrawing, NSForegroundColorAttributeName: self.hintTextColorForDrawing}];

    [durationString drawAtPoint:CGPointMake(center.x - hintDurationTextSize.width / 2, center.y - (hintTextSize.height + hintDurationTextSize.height)/2.0f + hintTextSize.height) withAttributes:@{NSFontAttributeName: self.hintDurationTextFontForDrawing, NSForegroundColorAttributeName: self.hintTextColorForDrawing}];
}

- (void)drawAttributedHintTextAtCenter:(CGPoint)center
{
    NSAttributedString *progressString = _hintAttributedTextGenerationBlock(_progress);
    CGSize hintTextSize = [progressString boundingRectWithSize:CGSizeZero options:NSStringDrawingUsesFontLeading context:nil].size;
    [progressString drawAtPoint:CGPointMake(center.x - hintTextSize.width / 2, center.y - hintTextSize.height / 2)];
    
    NSAttributedString *durationString = _hintAttributedTextDurationGenerationBlock(_duration);
    CGSize hintDurationTextSize = [durationString boundingRectWithSize:CGSizeZero options:NSStringDrawingUsesFontLeading context:nil].size;
    [progressString drawAtPoint:CGPointMake(center.x - hintDurationTextSize.width / 2, center.y + hintTextSize.height / 2)];
}

- (void)drawHint:(CGContextRef)context center:(CGPoint)center radius:(CGFloat)radius
{
    CGFloat barWidth = self.progressBarWidth;
    
    if (barWidth + self.hintViewSpacingForDrawing > radius)
        return;
    
    CGContextSetFillColorWithColor(context, self.hintViewBackgroundColorForDrawing.CGColor);
    CGContextBeginPath(context);
    CGContextAddArc(context, center.x, center.y, radius - barWidth - self.hintViewSpacingForDrawing, DEGREES_TO_RADIANS(0), DEGREES_TO_RADIANS(360), 1);
    CGContextClosePath(context);
    CGContextFillPath(context);
    
    if (_hintAttributedTextGenerationBlock != nil)
    {
        [self drawAttributedHintTextAtCenter:center];
    }
    else
    {
        [self drawSimpleHintTextAtCenter:center];
    }
}

#pragma mark - Amination

- (void)animateProgressBarChangeFrom:(CGFloat)startProgress to:(CGFloat)endProgress duration:(CGFloat)duration
{
    _currentAnimationProgress = _startProgress = startProgress;
    _endProgress = endProgress;
    
    _animationProgressStep = (_endProgress - _startProgress) * AnimationChangeTimeStep / duration;
    
    _animationTimer = [NSTimer scheduledTimerWithTimeInterval:AnimationChangeTimeStep target:self selector:@selector(updateProgressBarForAnimation) userInfo:nil repeats:YES];
}

- (void)updateProgressBarForAnimation
{
    _currentAnimationProgress += _animationProgressStep;
    _progress = _currentAnimationProgress;
    
    if ((_animationProgressStep > 0 && _currentAnimationProgress >= _endProgress) || (_animationProgressStep < 0 && _currentAnimationProgress <= _endProgress)) {
        [_animationTimer invalidate];
        _animationTimer = nil;
        _progress = _endProgress;
    }
    
    [self setNeedsDisplay];
}

@end