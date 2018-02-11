//
//  AVChooseView.h
//  VideoFrame
//
//  Created by Yinjing Li on 3/31/14.
//  Copyright (c) 2014 Yinjing Li. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Definition.h"


@protocol AVChooseDelegate <NSObject>
@optional

-(void) onPhotoFromCamera;
-(void) onPhotoFromGallery;
-(void) onVideoFromCamera;
-(void) onVideoFromGallery;

@end


@interface AVChooseView : UIView

@property(nonatomic, weak) id <AVChooseDelegate> delegate;

@property(nonatomic, strong) UILabel* titleLabel;

@property(nonatomic, strong) UIButton* photoCamBtn;
@property(nonatomic, strong) UIButton* videoCamBtn;
@property(nonatomic, strong) UIButton* photoGalleryBtn;
@property(nonatomic, strong) UIButton* videoGalleryBtn;

@end
