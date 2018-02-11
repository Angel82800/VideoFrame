//
//  VideoFilterThumbView.h
//  VideoFrame
//
//  Created by Yinjing Li on 02/20/15.
//  Copyright (c) 2015 Yinjing Li. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol VideoFilterThumbViewDelegate <NSObject>

@optional
-(void) selectedFilterThumb:(NSInteger) index;
@end


@interface VideoFilterThumbView : UIView<UIGestureRecognizerDelegate>
{

}


@property(nonatomic, weak) id <VideoFilterThumbViewDelegate> delegate;

@property(nonatomic, strong) UIImageView* videoThumbImageView;
@property(nonatomic, strong) UILabel* filterNameLabel;
@property(nonatomic, assign) NSInteger filterIndex;


-(void) setIndex:(NSInteger) index;
-(void) setVideoThumbImage:(UIImage*) image;
-(void) enableThumbBorder;
-(void) disableThumbBorder;


@end
