/*
 *  ATMHudView.m
 *  ATMHud
 *
 *  Created by Marcel Müller on 2011-03-01.
 *  Copyright (c) 2010-2011, Marcel Müller (atomcraft)
 *  All rights reserved.
 *
 *	https://github.com/atomton/ATMHud
 */

#import "ATMHudView.h"
#import "ATMTextLayer.h"
#import "ATMProgressLayer.h"
#import "ATMHud.h"
#import <QuartzCore/QuartzCore.h>
#import "ATMHudDelegate.h"
#import "ATMHudQueueItem.h"
#import "Definition.h"



@implementation ATMHudView


- (CGRect)sharpRect:(CGRect)rect
{
	CGRect r = rect;
	r.origin.x = (int)r.origin.x;
	r.origin.y = (int)r.origin.y;

    return r;
}

- (CGPoint)sharpPoint:(CGPoint)point
{
	CGPoint pp = point;
	pp.x = (int)pp.x;
	pp.y = (int)pp.y;

    return pp;
}

- (id)initWithFrame:(CGRect)frame andController:(ATMHud *)c
{
    if ((self = [super initWithFrame:frame]))
    {
		self.p = c;
		self.backgroundColor = [UIColor clearColor];
		self.alpha = 0.0;
		
		_backgroundLayer = [[CALayer alloc] init];
		_backgroundLayer.cornerRadius = 10;
		_backgroundLayer.backgroundColor = [UIColor colorWithWhite:0.0 alpha:_p.alpha].CGColor;
		[self.layer addSublayer:_backgroundLayer];
		
		_captionLayer = [[ATMTextLayer alloc] init];
		_captionLayer.contentsScale = [[UIScreen mainScreen] scale];
		_captionLayer.anchorPoint = CGPointMake(0, 0);
		[self.layer addSublayer:_captionLayer];
		
		_imageLayer = [[CALayer alloc] init];
		_imageLayer.anchorPoint = CGPointMake(0, 0);
		[self.layer addSublayer:_imageLayer];
		
		_progressLayer = [[ATMProgressLayer alloc] init];
		_progressLayer.contentsScale = [[UIScreen mainScreen] scale];
		_progressLayer.anchorPoint = CGPointMake(0, 0);
		[self.layer addSublayer:_progressLayer];
		
		_activity = [[UIActivityIndicatorView alloc] init];
		_activity.hidesWhenStopped = YES;
		[self addSubview:_activity];
		
		self.layer.shadowColor = [UIColor blackColor].CGColor;
		self.layer.shadowRadius = 8.0;
		self.layer.shadowOffset = CGSizeMake(0.0, 3.0);
		self.layer.shadowOpacity = 0.4;
		
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
         
            UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
            if(orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown)
                _progressRect = CGRectMake(0, 0, 220, 20);
            else
                _progressRect = CGRectMake(0, 0, 320, 20);
        }
        else
            _progressRect = CGRectMake(0, 0, 500, 20);
        
		_activityStyle = UIActivityIndicatorViewStyleWhite;
		_activitySize = CGSizeMake(20, 20);

    }
    return self;
}

- (void)setProgress:(CGFloat)pp
{
	pp = MIN(MAX(0,pp),1);
	
	if (pp > 0 && pp < 0.08) pp = 0.08;
	if(pp == _progress) return;
	_progress = pp;
}

- (void)calculate
{
	if (!_caption || [_caption isEqualToString:@""])
    {
		_activityRect = CGRectMake(_p.margin, _p.margin, _activitySize.width, _activitySize.height);
		_targetBounds = CGRectMake(0, 0, _p.margin*2 + _activitySize.width, _p.margin*2 + _activitySize.height);
	}
    else
    {
		BOOL hasFixedSize = NO;
        
        NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        paragraphStyle.alignment = NSTextAlignmentCenter;
        
        NSDictionary *attributes = @{ NSFontAttributeName: [UIFont fontWithName:MYRIADPRO size:14], NSParagraphStyleAttributeName: paragraphStyle };
        
        CGSize captionSize = [_caption boundingRectWithSize:CGSizeMake(160, 200) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
		
		if (_fixedSize.width > 0 & _fixedSize.height > 0)
        {
			CGSize s = _fixedSize;
		
            if (_progress > 0 && (_fixedSize.width < _progressRect.size.width + _p.margin*2))
            {
				s.width = _progressRect.size.width + _p.margin*2;
			}
            
			hasFixedSize = YES;
            
            captionSize = [_caption boundingRectWithSize:CGSizeMake(s.width - _p.margin*2, 200) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
            
			_targetBounds = CGRectMake(0, 0, s.width, s.height);
		}
		
		_captionRect = CGRectZero;
		_captionRect.size = captionSize;
		float adjustment = 0;
		CGFloat marginX = _p.margin;
		CGFloat marginY = _p.margin;
        
		if (!hasFixedSize)
        {
			if (_p.accessoryPosition == ATMHudAccessoryPositionTop || _p.accessoryPosition == ATMHudAccessoryPositionBottom)
            {
				if (_progress > 0)
                {
					adjustment = _p.padding+_progressRect.size.height;
                    
					if (captionSize.width+_p.margin*2 < _progressRect.size.width)
                    {
                        captionSize = [_caption boundingRectWithSize:CGSizeMake(_progressRect.size.width, 200) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
						_captionRect.size = captionSize;
						_targetBounds = CGRectMake(0, 0, _progressRect.size.width+_p.margin*2, captionSize.height+_p.margin*2+adjustment);
					}
                    else
                    {
						_targetBounds = CGRectMake(0, 0, captionSize.width+_p.margin*2, captionSize.height+_p.margin*2+adjustment);
					}
				}
                else
                {
					if (_image)
                    {
						adjustment = _p.padding+_image.size.height;
					}
                    else if (_showActivity)
                    {
						adjustment = _p.padding+_activitySize.height;
					}
                    
					_targetBounds = CGRectMake(0, 0, captionSize.width+_p.margin*2, captionSize.height+_p.margin*2+adjustment);
				}
			}
            else if (_p.accessoryPosition == ATMHudAccessoryPositionLeft || _p.accessoryPosition == ATMHudAccessoryPositionRight)
            {
				if (_image)
                {
					adjustment = _p.padding+_image.size.width;
				}
                else if (_showActivity)
                {
					adjustment = _p.padding+_activitySize.height;
				}
                
				_targetBounds = CGRectMake(0, 0, captionSize.width+_p.margin*2+adjustment, captionSize.height+_p.margin*2);
			}
		}
        else
        {
			if (_p.accessoryPosition == ATMHudAccessoryPositionTop || _p.accessoryPosition == ATMHudAccessoryPositionBottom)
            {
				if (_progress > 0)
                {
					adjustment = _p.padding+_progressRect.size.height;
				
                    if (captionSize.width+_p.margin*2 < _progressRect.size.width)
                    {
                        captionSize = [_caption boundingRectWithSize:CGSizeMake(_progressRect.size.width, 200) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;

						_captionRect.size = captionSize;
					}
				}
                else
                {
					if (_image)
                    {
						adjustment = _p.padding+_image.size.height;
					}
                    else if (_showActivity)
                    {
						adjustment = _p.padding+_activitySize.height;
					}
				}
				
				int deltaWidth = _targetBounds.size.width-captionSize.width;
				marginX = 0.5*deltaWidth;

                if (marginX < _p.margin)
                {
                    captionSize = [_caption boundingRectWithSize:CGSizeMake(160, 200) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
					_captionRect.size = captionSize;
					
					_targetBounds = CGRectMake(0, 0, captionSize.width+2*_p.margin, _targetBounds.size.height);
					marginX = _p.margin;
				}
				
				int deltaHeight = _targetBounds.size.height-(adjustment+captionSize.height);
				marginY = 0.5*deltaHeight;
				
                if (marginY < _p.margin)
                {
					_targetBounds = CGRectMake(0, 0, _targetBounds.size.width, captionSize.height+2*_p.margin+adjustment);
					marginY = _p.margin;
				}
			}
            else if (_p.accessoryPosition == ATMHudAccessoryPositionLeft || _p.accessoryPosition == ATMHudAccessoryPositionRight)
            {
				if (_image)
                {
					adjustment = _p.padding+_image.size.width;
				}
                else if (_showActivity)
                {
					adjustment = _p.padding+_activitySize.width;
				}
				
				int deltaWidth = _targetBounds.size.width-(adjustment+captionSize.width);
				marginX = 0.5*deltaWidth;
				
                if (marginX < _p.margin)
                {
                    captionSize = [_caption boundingRectWithSize:CGSizeMake(160, 200) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
					_captionRect.size = captionSize;
					
					_targetBounds = CGRectMake(0, 0, adjustment+captionSize.width+2*_p.margin, _targetBounds.size.height);
					marginX = _p.margin;
				}
				
				int deltaHeight = _targetBounds.size.height-captionSize.height;
				marginY = 0.5*deltaHeight;

                if (marginY < _p.margin)
                {
					_targetBounds = CGRectMake(0, 0, _targetBounds.size.width, captionSize.height+2*_p.margin);
					marginY = _p.margin;
				}
			}
		}
		
		switch (_p.accessoryPosition)
        {
			case ATMHudAccessoryPositionTop:
            {
				_activityRect = CGRectMake((_targetBounds.size.width - _activitySize.width)*0.5, marginY, _activitySize.width, _activitySize.height);
				
				_imageRect = CGRectZero;
				_imageRect.origin.x = (_targetBounds.size.width - _image.size.width)*0.5;
				_imageRect.origin.y = marginY;
				_imageRect.size = _image.size;
				
				_progressRect = CGRectMake((_targetBounds.size.width-_progressRect.size.width)*0.5, marginY, _progressRect.size.width, _progressRect.size.height);
				
				_captionRect.origin.x = (_targetBounds.size.width-captionSize.width)*0.5;
				_captionRect.origin.y = adjustment+marginY;
				break;
			}
				
			case ATMHudAccessoryPositionRight:
            {
				_activityRect = CGRectMake(marginX+_p.padding+captionSize.width, (_targetBounds.size.height-_activitySize.height)*0.5, _activitySize.width, _activitySize.height);
				
				_imageRect = CGRectZero;
				_imageRect.origin.x = marginX+_p.padding+captionSize.width;
				_imageRect.origin.y = (_targetBounds.size.height-_image.size.height)*0.5;
				_imageRect.size = _image.size;
				
				_captionRect.origin.x = marginX;
				_captionRect.origin.y = marginY;
				break;
			}
				
			case ATMHudAccessoryPositionBottom:
            {
				_activityRect = CGRectMake((_targetBounds.size.width-_activitySize.width)*0.5, _captionRect.size.height+marginY+_p.padding, _activitySize.width, _activitySize.height);
				
				_imageRect = CGRectZero;
				_imageRect.origin.x = (_targetBounds.size.width-_image.size.width)*0.5;
				_imageRect.origin.y = _captionRect.size.height+marginY+_p.padding;
				_imageRect.size = _image.size;
				
				_progressRect = CGRectMake((_targetBounds.size.width-_progressRect.size.width)*0.5, _captionRect.size.height+marginY+_p.padding, _progressRect.size.width, _progressRect.size.height);
				
				_captionRect.origin.x = (_targetBounds.size.width-captionSize.width)*0.5;
				_captionRect.origin.y = marginY;
				break;
			}
				
			case ATMHudAccessoryPositionLeft:
            {
				_activityRect = CGRectMake(marginX, (_targetBounds.size.height-_activitySize.height)*0.5, _activitySize.width, _activitySize.height);
				
				_imageRect = CGRectZero;
				_imageRect.origin.x = marginX;
				_imageRect.origin.y = (_targetBounds.size.height-_image.size.height)*0.5;
				_imageRect.size = _image.size;
				
				_captionRect.origin.x = marginX+adjustment;
				_captionRect.origin.y = marginY;
				break;
			}
		}
	}
}

- (CGSize)sizeForActivityStyle:(UIActivityIndicatorViewStyle)style
{
	if (style == UIActivityIndicatorViewStyleWhiteLarge)
    {
		return CGSizeMake(37, 37);
	}
    else
    {
		return CGSizeMake(20, 20);
	}
}

- (CGSize)calculateSizeForQueueItem:(ATMHudQueueItem *)item
{
	CGSize targetSize = CGSizeZero;
	CGSize styleSize = [self sizeForActivityStyle:item.activityStyle];

    if (!item.caption || [item.caption isEqualToString:@""])
    {
		targetSize = CGSizeMake(_p.margin*2+styleSize.width, _p.margin*2+styleSize.height);
	}
    else
    {
		BOOL hasFixedSize = NO;
        
        NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        paragraphStyle.alignment = NSTextAlignmentCenter;
        
        NSDictionary *attributes = @{ NSFontAttributeName: [UIFont fontWithName:MYRIADPRO size:14], NSParagraphStyleAttributeName: paragraphStyle };
        
        CGSize captionSize = [_caption boundingRectWithSize:CGSizeMake(160, 200) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
		
		float adjustment = 0;
		CGFloat marginX = 0;
		CGFloat marginY = 0;
        
		if (!hasFixedSize)
        {
			if (item.accessoryPosition == ATMHudAccessoryPositionTop || item.accessoryPosition == ATMHudAccessoryPositionBottom)
            {
				if (item.image)
                {
					adjustment = _p.padding+item.image.size.height;
				}
                else if (item.showActivity)
                {
					adjustment = _p.padding+styleSize.height;
				}
                
				targetSize = CGSizeMake(captionSize.width+_p.margin*2, captionSize.height+_p.margin*2+adjustment);
			}
            else if (item.accessoryPosition == ATMHudAccessoryPositionLeft || item.accessoryPosition == ATMHudAccessoryPositionRight)
            {
				if (item.image)
                {
					adjustment = _p.padding+item.image.size.width;
				}
                else if (item.showActivity)
                {
					adjustment = _p.padding+styleSize.width;
				}
                
				targetSize = CGSizeMake(captionSize.width+_p.margin*2+adjustment, captionSize.height+_p.margin*2);
			}
		}
        else
        {
			if (item.accessoryPosition == ATMHudAccessoryPositionTop || item.accessoryPosition == ATMHudAccessoryPositionBottom)
            {
				if (item.image)
                {
					adjustment = _p.padding+item.image.size.height;
				}
                else if (item.showActivity)
                {
					adjustment = _p.padding+styleSize.height;
				}
				
				int deltaWidth = targetSize.width-captionSize.width;
				marginX = 0.5*deltaWidth;
                
				if (marginX < _p.margin)
                {
                    captionSize = [_caption boundingRectWithSize:CGSizeMake(160, 200) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
					targetSize = CGSizeMake(captionSize.width+2*_p.margin, targetSize.height);
				}
				
				int deltaHeight = targetSize.height-(adjustment+captionSize.height);
				marginY = 0.5*deltaHeight;

                if (marginY < _p.margin)
                {
					targetSize = CGSizeMake(targetSize.width, captionSize.height+2*_p.margin+adjustment);
				}
			}
            else if (item.accessoryPosition == ATMHudAccessoryPositionLeft || item.accessoryPosition == ATMHudAccessoryPositionRight)
            {
				if (item.image)
                {
					adjustment = _p.padding+item.image.size.width;
				}
                else if (item.showActivity)
                {
					adjustment = _p.padding+styleSize.width;
				}
				
				int deltaWidth = targetSize.width-(adjustment+captionSize.width);
				marginX = 0.5*deltaWidth;
                
				if (marginX < _p.margin)
                {
                    captionSize = [_caption boundingRectWithSize:CGSizeMake(160, 200) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
					targetSize = CGSizeMake(adjustment+captionSize.width+2*_p.margin, targetSize.height);
				}
				
				int deltaHeight = targetSize.height-captionSize.height;
				marginY = 0.5*deltaHeight;

                if (marginY < _p.margin)
                {
					targetSize = CGSizeMake(targetSize.width, captionSize.height+2*_p.margin);
				}
			}
		}
	}
    
	return targetSize;
}

- (void)applyWithMode:(ATMHudApplyMode)mode
{
	switch (mode)
    {
		case ATMHudApplyModeShow:
        {
			if (CGPointEqualToPoint(_p.center, CGPointZero))
            {
				self.frame = CGRectMake((self.superview.bounds.size.width-_targetBounds.size.width)*0.5, (self.superview.bounds.size.height-_targetBounds.size.height)*0.5, _targetBounds.size.width, _targetBounds.size.height);
			}
            else
            {
				self.bounds = CGRectMake(0, 0, _targetBounds.size.width, _targetBounds.size.height);
				self.center = _p.center;
			}
            
            if (_showActivity)
            {
                _activity.activityIndicatorViewStyle = _activityStyle;
                _activity.frame = [self sharpRect:_activityRect];
            }
            
            CGRect r = self.frame;
            [self setFrame:[self sharpRect:r]];
            
            if ([(id)_p.delegate respondsToSelector:@selector(hudWillAppear:)])
            {
                [_p.delegate hudWillAppear:_p];
            }
            
            self.transform = CGAffineTransformMakeScale(1.0, 1.0);
            self.alpha = 1.0;

            if (!_p.allowSuperviewInteraction)
            {
                self.superview.userInteractionEnabled = YES;
            }
            
            if (![_p.showSound isEqualToString:@""] && _p.showSound != NULL)
            {
                [_p playSound:_p.showSound];
            }
            
            if ([(id)_p.delegate respondsToSelector:@selector(hudDidAppear:)])
            {
                [_p.delegate hudDidAppear:_p];
            }
			
			_backgroundLayer.position = CGPointMake(0.5*_targetBounds.size.width, 0.5*_targetBounds.size.height);
			_backgroundLayer.bounds = _targetBounds;
			
			_captionLayer.position = [self sharpPoint:CGPointMake(_captionRect.origin.x, _captionRect.origin.y)];
			_captionLayer.bounds = CGRectMake(0, 0, _captionRect.size.width, _captionRect.size.height);
			CABasicAnimation *cAnimation = [CABasicAnimation animationWithKeyPath:@"caption"];
			cAnimation.duration = 0.001;
			cAnimation.toValue = _caption;
			[_captionLayer addAnimation:cAnimation forKey:@"captionAnimation"];
			_captionLayer.caption = _caption;
			
			_imageLayer.contents = (id)_image.CGImage;
			_imageLayer.position = [self sharpPoint:CGPointMake(_imageRect.origin.x, _imageRect.origin.y)];
			_imageLayer.bounds = CGRectMake(0, 0, _imageRect.size.width, _imageRect.size.height);
			
			_progressLayer.position = [self sharpPoint:CGPointMake(_progressRect.origin.x, _progressRect.origin.y)];
			_progressLayer.bounds = CGRectMake(0, 0, _progressRect.size.width, _progressRect.size.height);
			_progressLayer.progressBorderRadius = _p.progressBorderRadius;
			_progressLayer.progressBorderWidth = _p.progressBorderWidth;
			_progressLayer.progressBarRadius = _p.progressBarRadius;
			_progressLayer.progressBarInset = _p.progressBarInset;
			_progressLayer.theProgress = _progress;
			[_progressLayer setNeedsDisplay];

			break;
		}
			
		case ATMHudApplyModeUpdate:
        {
			if ([(id)_p.delegate respondsToSelector:@selector(hudWillUpdate:)])
            {
				[_p.delegate hudWillUpdate:_p];
			}
			
			if (CGPointEqualToPoint(_p.center, CGPointZero))
            {
				self.frame = CGRectMake((self.superview.bounds.size.width-_targetBounds.size.width)*0.5, (self.superview.bounds.size.height-_targetBounds.size.height)*0.5, _targetBounds.size.width, _targetBounds.size.height);
			}
            else
            {
				self.bounds = CGRectMake(0, 0, _targetBounds.size.width, _targetBounds.size.height);
				self.center = _p.center;
			}
			
			CABasicAnimation *ccAnimation = [CABasicAnimation animationWithKeyPath:@"caption"];
			ccAnimation.duration = 0.001;
			ccAnimation.toValue = @"";
			ccAnimation.delegate = (id)self;
			[_captionLayer addAnimation:ccAnimation forKey:@"captionClearAnimation"];
			_captionLayer.caption = @"";
			
			[CATransaction begin];
			[CATransaction setDisableActions:YES];
			[CATransaction setCompletionBlock:^{
				_backgroundLayer.bounds = _targetBounds;
				
				_progressLayer.theProgress = _progress;
				[_progressLayer setNeedsDisplay];
				
				CABasicAnimation *cAnimation = [CABasicAnimation animationWithKeyPath:@"caption"];
				cAnimation.duration = 0.001;
				cAnimation.toValue = _caption;
				[_captionLayer addAnimation:cAnimation forKey:@"captionAnimation"];
				_captionLayer.caption = _caption;
				
				if (_showActivity) {
					_activity.activityIndicatorViewStyle = _activityStyle;
					_activity.frame = [self sharpRect:_activityRect];
				}
				
				CGRect r = self.frame;
				[self setFrame:[self sharpRect:r]];
				
				if (![_p.updateSound isEqualToString:@""] && _p.updateSound != NULL) {
					[_p playSound:_p.updateSound];
				}
				if ([(id)_p.delegate respondsToSelector:@selector(hudDidUpdate:)]) {
					[_p.delegate hudDidUpdate:_p];
				}
			}];
			
			_backgroundLayer.position = CGPointMake(0.5*_targetBounds.size.width, 0.5*_targetBounds.size.height);
			_imageLayer.position = [self sharpPoint:CGPointMake(_imageRect.origin.x, _imageRect.origin.y)];
			_progressLayer.position = [self sharpPoint:CGPointMake(_progressRect.origin.x, _progressRect.origin.y)];
			
			_imageLayer.bounds = CGRectMake(0, 0, _imageRect.size.width, _imageRect.size.height);
			_progressLayer.bounds = CGRectMake(0, 0, _progressRect.size.width, _progressRect.size.height);
			
			_progressLayer.progressBorderRadius = _p.progressBorderRadius;
			_progressLayer.progressBorderWidth = _p.progressBorderWidth;
			_progressLayer.progressBarRadius = _p.progressBarRadius;
			_progressLayer.progressBarInset = _p.progressBarInset;
			
			_captionLayer.position = [self sharpPoint:CGPointMake(_captionRect.origin.x, _captionRect.origin.y)];
			_captionLayer.bounds = CGRectMake(0, 0, _captionRect.size.width, _captionRect.size.height);
			
			_imageLayer.contents = (id)_image.CGImage;
			[CATransaction commit];
			break;
		}
			
		case ATMHudApplyModeHide: {
			if ([(id)_p.delegate respondsToSelector:@selector(hudWillDisappear:)]) {
				[_p.delegate hudWillDisappear:_p];
			}
			if (![_p.hideSound isEqualToString:@""] && _p.hideSound != NULL) {
				[_p playSound:_p.hideSound];
			}
			
			[UIView animateWithDuration:.1 
							 animations:^{ 
								 self.alpha = 0.0;
								 self.transform = CGAffineTransformMakeScale(_p.disappearScaleFactor, _p.disappearScaleFactor);
							 } 
							 completion:^(BOOL finished){
								 if (finished) {
									 self.superview.userInteractionEnabled = NO;
									 self.transform = CGAffineTransformMakeScale(1.0, 1.0);
									 [self reset];
									 if ([(id)_p.delegate respondsToSelector:@selector(hudDidDisappear:)]) {
										 [_p.delegate hudDidDisappear:_p];
									 } 
								 }
							 }];
			break;
		}
	}
}

- (void)show {
	[self calculate];
	[self applyWithMode:ATMHudApplyModeShow];
}

- (void)hide {
	[self applyWithMode:ATMHudApplyModeHide];
}

- (void)update {
	[self calculate];
	[self applyWithMode:ATMHudApplyModeUpdate];
}

- (void)reset {
	[_p setCaption:@""];
	[_p setImage:nil];
	[_p setProgress:0];
	[_p setActivity:NO];
	[_p setActivityStyle:UIActivityIndicatorViewStyleWhite];
	[_p setAccessoryPosition:ATMHudAccessoryPositionBottom];
	[_p setBlockTouches:NO];
	[_p setAllowSuperviewInteraction:NO];
	// TODO: Reset or not reset, that is the question.
	[_p setFixedSize:CGSizeZero];
	[_p setCenter:CGPointZero];
	
	[CATransaction begin];
	[CATransaction setDisableActions:YES];
	_imageLayer.contents = nil;
	[CATransaction commit];
	
	CABasicAnimation *cAnimation = [CABasicAnimation animationWithKeyPath:@"caption"];
	cAnimation.duration = 0.001;
	cAnimation.toValue = @"";
	[_captionLayer addAnimation:cAnimation forKey:@"captionAnimation"];
	_captionLayer.caption = @"";
	
	[_p setShowSound:@""];
	[_p setUpdateSound:@""];
	[_p setHideSound:@""];
}


@end



