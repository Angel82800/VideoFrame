//
//  CustomModalView.h
//  VideoFrame
//
//  Created by Yinjing Li on 11/14/13.
//  Copyright (c) 2013 Yinjing Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>


extern NSString * const kCustomDidShowNotification;
extern NSString * const kCustomDidHidewNotification;


@protocol CustomModalViewDelegate <NSObject>
@optional

-(void) didClosedCustomModalView;

@end


@interface CustomModalView : UIView<UIGestureRecognizerDelegate>

@property(nonatomic, weak) id <CustomModalViewDelegate> delegate;

@property (assign, readonly) BOOL isVisible;

@property (assign) CGFloat animationDuration;
@property (assign) CGFloat animationDelay;
@property (assign) UIViewAnimationOptions animationOptions;
@property (assign) BOOL dismissButtonRight;
@property (nonatomic, copy) void (^defaultHideBlock)(void);

- (id)initWithView:(UIView*)view isCenter:(BOOL)centerFlag;
- (id)initWithView:(UIView*)view bgColor:(UIColor*) color;
- (id)initWithViewController:(UIViewController*)viewController view:(UIView*)view;
- (id)initWithViewController:(UIViewController*)viewController title:(NSString*)title message:(NSString*)message;
- (id)initWithParentView:(UIView*)parentView view:(UIView*)view isCenter:(BOOL)centerFlag;
- (id)initWithParentView:(UIView*)parentView title:(NSString*)title message:(NSString*)message isCenter:(BOOL)centerFlag;
- (id)initWithTitle:(NSString*)title message:(NSString*)message isCenter:(BOOL)centerFlag;

- (void)show;
- (void)showWithDuration:(CGFloat)duration delay:(NSTimeInterval)delay options:(UIViewAnimationOptions)options completion:(void (^)(void))completion;

- (void)hideCustomModalView;
- (void)hideCloseButton:(BOOL)hide;


@end