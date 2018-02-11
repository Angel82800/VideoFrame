//
//  YJLCameraPickerController.h
//  VideoFrame
//
//  Created by Yinjing Li on 5/7/14.
//  Copyright (c) 2014 Yinjing Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "Definition.h"
#import "SHKActivityIndicator.h"

@protocol YJLCameraOverlayDelegate;

@interface YJLCameraPickerController : UIImagePickerController
{
    BOOL isFive;
    BOOL isTakePhoto;
    BOOL isRec;
    BOOL isMultiplePhotos;
    
    NSTimer* recTimer;
    NSTimeInterval startInterval;
    
    NSInteger photosCount;
    
    int templateIndex;
    
    UIInterfaceOrientation startOrientation;
}

@property(nonatomic, weak) id <YJLCameraOverlayDelegate> cameraOverlayDelegate;

@property(nonatomic, strong) UIView* overlayView;
@property(nonatomic, strong) UIView* grayView;
@property(nonatomic, strong) UIView* topGrayView;
@property(nonatomic, strong) UIView* topBlackView;
@property(nonatomic, strong) UIView* bottomBlackView;
@property(nonatomic, strong) UIView* leftBlackView;
@property(nonatomic, strong) UIView* rightBlackView;
@property(nonatomic, strong) UIView* lineX1View;
@property(nonatomic, strong) UIView* lineX2View;
@property(nonatomic, strong) UIView* lineY1View;
@property(nonatomic, strong) UIView* lineY2View;

@property(nonatomic, strong) UIButton* takeBtn;
@property(nonatomic, strong) UIButton* fronBackBtn;
@property(nonatomic, strong) UIButton* cancelBtn;
@property(nonatomic, strong) UIButton* usePhotosBtn;

@property(nonatomic, strong) UILabel* multipleCountLabel;
@property(nonatomic, strong) UILabel* multipleTitleLabel;
@property(nonatomic, strong) UILabel* photosTitleLabel;
@property(nonatomic, strong) UILabel* timeCountLabel;

@property(nonatomic, strong) UISwitch* photosSwitch;

@property(nonatomic, strong) UIImageView* redDotImageView;

- (void) initOverlayViewWithFrame:(CGRect)frame isPhoto:(BOOL)isPhoto type:(int) templateType;
- (void)removeCustomOverlayView;

@end


@protocol YJLCameraOverlayDelegate <NSObject>
@optional
- (void)actionCameraCancel;
- (void)selectedMultiplePhotos:(BOOL) multiplePhotos;
- (void)actionUsePhotos;
@end