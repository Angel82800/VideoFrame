//
//  SHKActivityIndicator.h
//  VideoFrame
//
//  Created by Yinjing Li on 3/6/14.
//  Copyright (c) 2014 Yinjing Li. All rights reserved.
//


#import <Foundation/Foundation.h>


@interface SHKActivityIndicator : UIView
{

}

@property (nonatomic, strong) UILabel *centerMessageLabel;
@property (nonatomic, strong) UILabel *subMessageLabel;
@property (nonatomic, strong) UIView *backgroundView;

@property (nonatomic, strong) UIActivityIndicatorView *spinner;

+ (SHKActivityIndicator *)currentIndicator;

- (void)show;
- (void)hideAfterDelay;
- (void)hide;
- (void)hidden;
- (void)displayActivity:(NSString *)m;
- (void)displayActivityLockOnly:(BOOL) lock;
- (void)displayActivity:(NSString *)m isLock:(BOOL)l;
- (void)displayCompleted:(NSString *)m;
- (void)displayCompleted;
- (void)displayErrorMessage:(NSString *)m;
- (void)setCenterMessage:(NSString *)message;
- (void)setSubMessage:(NSString *)message;
- (void)showSpinner;
- (void)setProperRotation;
- (void)setProperRotation:(BOOL)animated;

@end
