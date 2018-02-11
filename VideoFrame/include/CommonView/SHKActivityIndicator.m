//
//  SHKActivityIndicator.m
//  VideoFrame
//
//  Created by Yinjing Li on 3/6/14.
//  Copyright (c) 2014 Yinjing Li. All rights reserved.
//


#import "SHKActivityIndicator.h"
#import <QuartzCore/QuartzCore.h>

#define SHKdegreesToRadians(x) (M_PI * x / 180.0)

@implementation SHKActivityIndicator


static SHKActivityIndicator *currentIndicator = nil;

+ (SHKActivityIndicator *)currentIndicator
{
	if (currentIndicator == nil)
	{
		UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];		
		CGFloat width = 160;
		CGFloat height = 160;
		CGRect centeredFrame = CGRectMake(round(keyWindow.bounds.size.width/2 - width/2),
										  round(keyWindow.bounds.size.height/2 - height/2),
										  width,
										  height);
		
		currentIndicator = [[super allocWithZone:NULL] initWithFrame:centeredFrame];
		
		currentIndicator.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
		currentIndicator.opaque = NO;
		currentIndicator.alpha = 0;		
		currentIndicator.layer.cornerRadius = 10;		
		currentIndicator.userInteractionEnabled = NO;
		currentIndicator.autoresizesSubviews = YES;
		currentIndicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |  UIViewAutoresizingFlexibleTopMargin |  UIViewAutoresizingFlexibleBottomMargin;		
		[currentIndicator setProperRotation:NO];
		
		[[NSNotificationCenter defaultCenter] addObserver:currentIndicator
												 selector:@selector(setProperRotation)
													 name:UIDeviceOrientationDidChangeNotification
												   object:nil];
	}
	
	return currentIndicator;
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -


- (void)setLockView:(BOOL)isLock
{
	if (!isLock && self.backgroundView != nil)
		self.backgroundView = nil;
    
	else if (isLock)
	{
		if (self.backgroundView == nil)
		{
			self.backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0,0,1024,1024)];
			self.backgroundView.backgroundColor = [UIColor clearColor];
            [[[UIApplication sharedApplication] keyWindow] addSubview:self.backgroundView];
		}
        
   		[[[UIApplication sharedApplication] keyWindow] bringSubviewToFront:self.backgroundView];
	}
}

#pragma mark Creating Message

- (void)show
{	
	if ([self superview] != [[UIApplication sharedApplication] keyWindow]) 
		[[[UIApplication sharedApplication] keyWindow] addSubview:self];
	
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hide) object:nil];
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3];
	
	self.alpha = 1;
	
	[UIView commitAnimations];
}

- (void)hideAfterDelay
{
	[self performSelector:@selector(hide) withObject:nil afterDelay:1.0];
}

- (void)hide
{
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.4];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(hidden)];
	
	self.alpha = 0;
	[[[UIApplication sharedApplication] keyWindow] sendSubviewToBack:self.backgroundView];    
    
    [self.backgroundView removeFromSuperview];
    self.backgroundView = nil;
    
	[UIView commitAnimations];
}

- (void)persist
{	
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hide) object:nil];
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:0.1];
	
	self.alpha = 1;
	
	[UIView commitAnimations];
}

- (void)hidden
{
	if (currentIndicator.alpha > 0)
		return;
	
	[currentIndicator removeFromSuperview];
	currentIndicator = nil;
}

- (void)displayActivity:(NSString *)m isLock:(BOOL)l
{		
    [self setLockView:l];
	[self setSubMessage:m];
	[self showSpinner];	
	
	[self.centerMessageLabel removeFromSuperview];
	self.centerMessageLabel = nil;
	
	if ([self superview] == nil)
		[self show];
	else
		[self persist];
}

- (void)displayActivityLockOnly:(BOOL) lock
{
    [self setLockView:lock];
	[self setSubMessage:@""];
    
    currentIndicator.hidden = YES;
	
	[self.centerMessageLabel removeFromSuperview];
	self.centerMessageLabel = nil;
	
	if ([self superview] == nil)
		[self show];
	else
		[self persist];
}

- (void)displayActivity:(NSString *)m
{		
    [self setLockView:YES];
	[self setSubMessage:m];
	[self showSpinner];	
	
	[self.centerMessageLabel removeFromSuperview];
	self.centerMessageLabel = nil;
	
	if ([self superview] == nil)
		[self show];
	else
		[self persist];
}

- (void)displayCompleted:(NSString *)m
{	
	[self setCenterMessage:@""];
	[self setSubMessage:m];
	
	[self.spinner removeFromSuperview];
	
	if ([self superview] == nil)
		[self show];
	else
		[self persist];
    
	[self hideAfterDelay];
}

- (void)displayCompleted
{	
	[self setCenterMessage:@""];
	[self setSubMessage:@""];
	
	[self.spinner removeFromSuperview];
	
	if ([self superview] == nil)
		[self show];
	else
		[self persist];
    
	[self hideAfterDelay];
}


- (void)displayErrorMessage:(NSString *)m
{	
	[self setCenterMessage:@"DateWars"];
	[self setSubMessage:m];
	
	[self.spinner removeFromSuperview];
	self.spinner = nil;
	
	if ([self superview] == nil)
		[self show];
	else
		[self persist];
    
	[self hideAfterDelay];
    
}

- (void)setCenterMessage:(NSString *)message
{	
	if (message == nil && self.centerMessageLabel != nil)
		self.centerMessageLabel = nil;

	else if (message != nil)
	{
		if (self.centerMessageLabel == nil)
		{
			self.centerMessageLabel = [[UILabel alloc] initWithFrame:CGRectMake(12,round(self.bounds.size.height/2-50/2),self.bounds.size.width-24,50)];
			self.centerMessageLabel.backgroundColor = [UIColor clearColor];
			self.centerMessageLabel.opaque = NO;
			self.centerMessageLabel.textColor = [UIColor whiteColor];
			self.centerMessageLabel.font = [UIFont fontWithName:@"MyriadPro-Semibold" size:40];
			self.centerMessageLabel.textAlignment = NSTextAlignmentCenter;
			self.centerMessageLabel.shadowColor = [UIColor darkGrayColor];
			self.centerMessageLabel.shadowOffset = CGSizeMake(1,1);
			self.centerMessageLabel.adjustsFontSizeToFitWidth = YES;
			
			[self addSubview:self.centerMessageLabel];
		}
		
		self.centerMessageLabel.text = message;
	}
}

- (void)setSubMessage:(NSString *)message
{	
	if (message == nil && self.subMessageLabel != nil)
		self.subMessageLabel = nil;
	
	else if (message != nil)
	{
		if (self.subMessageLabel == nil)
		{
			self.subMessageLabel = [[UILabel alloc] initWithFrame:CGRectMake(12,self.bounds.size.height-45,self.bounds.size.width-24,30)];
			self.subMessageLabel.backgroundColor = [UIColor clearColor];
			self.subMessageLabel.opaque = NO;
			self.subMessageLabel.textColor = [UIColor whiteColor];
			self.subMessageLabel.font = [UIFont fontWithName:@"MyriadPro-Semibold" size:17];
			self.subMessageLabel.textAlignment = NSTextAlignmentCenter;
			self.subMessageLabel.shadowColor = [UIColor darkGrayColor];
			self.subMessageLabel.shadowOffset = CGSizeMake(1,1);
			self.subMessageLabel.adjustsFontSizeToFitWidth = YES;
			
			[self addSubview:self.subMessageLabel];
		}
		
		self.subMessageLabel.text = message;
	}
}
	 
- (void)showSpinner
{	
	if (self.spinner == nil)
	{
		self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];

		self.spinner.frame = CGRectMake(round(self.bounds.size.width/2 - self.spinner.frame.size.width/2),
								round(self.bounds.size.height/2 - self.spinner.frame.size.height/2),
								self.spinner.frame.size.width,
								self.spinner.frame.size.height);
	}
	
	[self addSubview:self.spinner];
	[self.spinner startAnimating];
}

#pragma mark -
#pragma mark Rotation

- (void)setProperRotation
{
	[self setProperRotation:YES];
}

- (void)setProperRotation:(BOOL)animated
{
	if (animated)
	{
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.3];
	}
	
    if (animated)
		[UIView commitAnimations];
}


@end
