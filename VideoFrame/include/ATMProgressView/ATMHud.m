/*
 *  ATMHud.m
 *  ATMHud
 *
 *  Created by Marcel Müller on 2011-03-01.
 *  Copyright (c) 2010-2011, Marcel Müller (atomcraft)
 *  All rights reserved.
 *
 *	https://github.com/atomton/ATMHud
 */

#import "ATMHud.h"
#import <QuartzCore/QuartzCore.h>
#import <AudioToolbox/AudioServices.h>
#import "ATMHudView.h"
#import "ATMProgressLayer.h"
#import "ATMHudDelegate.h"
#import "ATMSoundFX.h"
#import "ATMHudQueueItem.h"

@interface ATMHud (Private)
- (void)construct;
@end

@implementation ATMHud

- (id)init {
	if ((self = [super init])) {
		[self construct];
	}
	return self;
}

- (id)initWithDelegate:(id)hudDelegate {
	if ((self = [super init])) {
		_delegate = hudDelegate;
		[self construct];
	}
	return self;
}

- (void)loadView {
    
	UIView *base = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	base.backgroundColor = [UIColor clearColor];
	base.autoresizingMask = (UIViewAutoresizingFlexibleWidth |
							 UIViewAutoresizingFlexibleHeight);
	base.userInteractionEnabled = NO;
	[base addSubview:self.__view];
    
	self.view = base;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}


+ (NSString *)buildInfo {
	return @"atomHUD 1.2 • 2011-03-01";
}

#pragma mark -
#pragma mark Overrides
- (void)setAppearScaleFactor:(CGFloat)value {
	if (value == 0) {
		value = 0.01;
	}
	_appearScaleFactor = value;
}

- (void)setDisappearScaleFactor:(CGFloat)value {
	if (value == 0) {
		value = 0.01;
	}
	_disappearScaleFactor = value;
}

- (void)setAlpha:(CGFloat)value {
	_alpha = value;
	[CATransaction begin];
	[CATransaction setDisableActions:YES];
    self.__view.backgroundLayer.backgroundColor = [UIColor colorWithWhite:0.0 alpha:value].CGColor;
	[CATransaction commit];
}

- (void)setShadowEnabled:(BOOL)value {
	_shadowEnabled = value;
	if (_shadowEnabled) {
        self.__view.layer.shadowOpacity = 0.4;
	} else {
		self.__view.layer.shadowOpacity = 0.0;
	}
}

#pragma mark -
#pragma mark Property forwards

- (void)setCaption:(NSString *)caption {
    
	self.__view.caption = caption;
}

- (void)setImage:(UIImage *)image {
	self.__view.image = image;
}

- (void)setActivity:(BOOL)activity {
	self.__view.showActivity = activity;
	if (activity) {
		[self.__view.activity startAnimating];
	} else {
		[self.__view.activity stopAnimating];
	}
}

- (void)setActivityStyle:(UIActivityIndicatorViewStyle)activityStyle {
	self.__view.activityStyle = activityStyle;
	if (activityStyle == UIActivityIndicatorViewStyleWhiteLarge) {
		self.__view.activitySize = CGSizeMake(37, 37);
	} else {
		self.__view.activitySize = CGSizeMake(20, 20);
	}
}

- (void)setFixedSize:(CGSize)fixedSize {
	self.__view.fixedSize = fixedSize;
}

- (void)setProgress:(CGFloat)progress {
	self.__view.progress = progress;
	
	[self.__view.progressLayer setTheProgress:progress];
	[self.__view.progressLayer setNeedsDisplay];
}

- (CGFloat) getProgress{
    return self.__view.progress;
}

#pragma mark -
#pragma mark Queue
- (void)addQueueItem:(ATMHudQueueItem *)item {
	[_displayQueue addObject:item];
}

- (void)addQueueItems:(NSArray *)items {
	[_displayQueue addObjectsFromArray:items];
}

- (void)clearQueue {
	[_displayQueue removeAllObjects];
}

- (void)startQueue {
	_queuePosition = 0;
	if (!CGSizeEqualToSize(self.__view.fixedSize, CGSizeZero)) {
		CGSize newSize = self.__view.fixedSize;
		CGSize targetSize;
		ATMHudQueueItem *queueItem;
		for (int i = 0; i < [_displayQueue count]; i++) {
			queueItem = [_displayQueue objectAtIndex:i];
			
			targetSize = [self.__view calculateSizeForQueueItem:queueItem];
			if (targetSize.width > newSize.width) {
				newSize.width = targetSize.width;
			}
			if (targetSize.height > newSize.height) {
				newSize.height = targetSize.height;
			}
		}
		[self setFixedSize:newSize];
	}
	[self showQueueAtIndex:_queuePosition];
}

- (void)showNextInQueue {
	_queuePosition++;
	[self showQueueAtIndex:_queuePosition];
}

- (void)showQueueAtIndex:(NSInteger)index {
	if ([_displayQueue count] > 0) {
		_queuePosition = index;
		if (_queuePosition == [_displayQueue count]) {
			[self hide];
			return;
		}
		ATMHudQueueItem *item = [_displayQueue objectAtIndex:_queuePosition];
		
		self.__view.caption = item.caption;
		self.__view.image = item.image;
		
		BOOL flag = item.showActivity;
		self.__view.showActivity = flag;
		if (flag) {
			[self.__view.activity startAnimating];
		} else {
			[self.__view.activity stopAnimating];
		}
		
		self.accessoryPosition = item.accessoryPosition;
		[self setActivityStyle:item.activityStyle];
		
		if (_queuePosition == 0) {
			[self.__view show];
		} else {
			[self.__view update];
		}
	}
}

#pragma mark -
#pragma mark Controlling
- (void)show {
	[self.__view show];
    _dismissButton.center = CGPointMake(self.__view.frame.origin.x + self.__view.frame.size.width, self.__view.frame.origin.y);
}

- (void)update {
	[self.__view update];
}

- (void)hide {
	[self.__view hide];
    _dismissButton.alpha = 0.0f;
}

- (void)hideAfter:(NSTimeInterval)delay {
	[self performSelector:@selector(hide) withObject:nil afterDelay:delay];
}

#pragma mark -
#pragma mark Internal methods
- (void)construct {
	_margin = _padding = 10.0;
	_alpha = 0.7;
	_progressBorderRadius = 8.0;
	_progressBorderWidth = 2.0;
	_progressBarRadius = 5.0;
	_progressBarInset = 3.0;
	_accessoryPosition = ATMHudAccessoryPositionBottom;
	_appearScaleFactor = _disappearScaleFactor = 1.4;
	
	self.__view = [[ATMHudView alloc] initWithFrame:CGRectZero andController:self];
	self.__view.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin |
							   UIViewAutoresizingFlexibleRightMargin |
							   UIViewAutoresizingFlexibleBottomMargin |
							   UIViewAutoresizingFlexibleLeftMargin);
	
	_displayQueue = [[NSMutableArray alloc] init];
	_queuePosition = 0;
	_center = CGPointZero;
	_blockTouches = NO;
	_allowSuperviewInteraction = NO;
    
    
    _dismissButton = [[ATMCloseButton alloc] init];
    _dismissButton.center = CGPointMake(self.__view.frame.size.width, 0.0f);
    [_dismissButton addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_dismissButton];
    _dismissButton.alpha = 0.0f;

}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	if (!_blockTouches) {
		UITouch *aTouch = [touches anyObject];
		if (aTouch.tapCount == 1) {
			CGPoint p = [aTouch locationInView:self.view];
			if (CGRectContainsPoint(self.__view.frame, p)) {
				if ([(id)self.delegate respondsToSelector:@selector(userDidTapHud:)]) {
					[self.delegate userDidTapHud:self];
				}
			}
		}
	}
}

- (void)playSound:(NSString *)soundPath {
	_sound = [[ATMSoundFX alloc] initWithContentsOfFile:soundPath];
	[_sound play];
}


- (void) showDismissButton{
    [UIView animateWithDuration:0.2f animations:^{
        _dismissButton.alpha = 1.0f;
    }];
}

- (void) hideDismissButton{
    _dismissButton.alpha = 0.0f;
}


@end


#pragma mark - ATMCloseButton

@implementation ATMCloseButton

- (id)init{
    if(!(self = [super initWithFrame:(CGRect){0, 0, 32, 32}])){
        return nil;
    }
    static UIImage *closeButtonImage;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        closeButtonImage = [self closeButtonImage];
    });
    [self setBackgroundImage:closeButtonImage forState:UIControlStateNormal];
    self.accessibilityTraits |= UIAccessibilityTraitButton;
    self.accessibilityLabel = NSLocalizedString(@"Dismiss Alert", @"Dismiss Alert Close Button");
    self.accessibilityHint = NSLocalizedString(@"Dismisses this alert.",@"Dismiss Alert close button hint");
    return self;
}

- (UIImage *)closeButtonImage{
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0);
    
    //// General Declarations
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //// Color Declarations
    UIColor *topGradient = [UIColor colorWithRed:0.21 green:0.21 blue:0.21 alpha:0.9];
    UIColor *bottomGradient = [UIColor colorWithRed:0.03 green:0.03 blue:0.03 alpha:0.9];
    
    //// Gradient Declarations
    NSArray *gradientColors = @[(id)topGradient.CGColor,
                                (id)bottomGradient.CGColor];
    CGFloat gradientLocations[] = {0, 1};
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)gradientColors, gradientLocations);
    
    //// Shadow Declarations
    CGColorRef shadow = [UIColor blackColor].CGColor;
    CGSize shadowOffset = CGSizeMake(0, 1);
    CGFloat shadowBlurRadius = 3;
    CGColorRef shadow2 = [UIColor blackColor].CGColor;
    CGSize shadow2Offset = CGSizeMake(0, 1);
    CGFloat shadow2BlurRadius = 0;
    
    
    //// Oval Drawing
    UIBezierPath *ovalPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(4, 3, 24, 24)];
    CGContextSaveGState(context);
    [ovalPath addClip];
    CGContextDrawLinearGradient(context, gradient, CGPointMake(16, 3), CGPointMake(16, 27), 0);
    CGContextRestoreGState(context);
    
    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, shadowOffset, shadowBlurRadius, shadow);
    [[UIColor whiteColor] setStroke];
    ovalPath.lineWidth = 2;
    [ovalPath stroke];
    CGContextRestoreGState(context);
    
    
    //// Bezier Drawing
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint:CGPointMake(22.36, 11.46)];
    [bezierPath addLineToPoint:CGPointMake(18.83, 15)];
    [bezierPath addLineToPoint:CGPointMake(22.36, 18.54)];
    [bezierPath addLineToPoint:CGPointMake(19.54, 21.36)];
    [bezierPath addLineToPoint:CGPointMake(16, 17.83)];
    [bezierPath addLineToPoint:CGPointMake(12.46, 21.36)];
    [bezierPath addLineToPoint:CGPointMake(9.64, 18.54)];
    [bezierPath addLineToPoint:CGPointMake(13.17, 15)];
    [bezierPath addLineToPoint:CGPointMake(9.64, 11.46)];
    [bezierPath addLineToPoint:CGPointMake(12.46, 8.64)];
    [bezierPath addLineToPoint:CGPointMake(16, 12.17)];
    [bezierPath addLineToPoint:CGPointMake(19.54, 8.64)];
    [bezierPath addLineToPoint:CGPointMake(22.36, 11.46)];
    [bezierPath closePath];
    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, shadow2Offset, shadow2BlurRadius, shadow2);
    [[UIColor whiteColor] setFill];
    [bezierPath fill];
    CGContextRestoreGState(context);
    
    
    //// Cleanup
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
