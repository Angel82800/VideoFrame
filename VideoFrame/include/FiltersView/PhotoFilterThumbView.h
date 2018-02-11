//
//  PhotoFilterThumbView.h
//  VideoFrame
//
//  Created by Yinjing Li on 6/20/14.
//  Copyright (c) 2014 Yinjing Li. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol PhotoFilterThumbViewDelegate <NSObject>

@optional
-(void) selectedFilter:(NSInteger) index;
@end




@interface PhotoFilterThumbView : UIView<UIGestureRecognizerDelegate>
{

}

@property(nonatomic, weak) id <PhotoFilterThumbViewDelegate> delegate;

@property(nonatomic, strong) UIImageView* thumbImageView;

@property(nonatomic, strong) UILabel* filterNameLabel;

@property(nonatomic, strong) NSString* filterName;

@property(nonatomic, assign) NSInteger filterIndex;


-(void) setName:(NSString*) name;
-(void) setIndex:(NSInteger) index;
-(void) setThumbImage:(UIImage*) image;
-(void) enableThumbBorder;
-(void) desableThumbBorder;


@end
