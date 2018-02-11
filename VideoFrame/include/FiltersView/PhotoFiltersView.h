//
//  PhotoFiltersView.h
//  VideoFrame
//
//  Created by Yinjing Li on 9/12/14.
//  Copyright (c) 2014 Yinjing Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoFilterThumbView.h"


@protocol PhotoFiltersViewDelegate <NSObject>

@optional
-(void) didCancelFilter;
-(void) didApplyFilter:(UIImage*) filteredImage index:(NSInteger) filterIndex value:(float) filterValue;
-(void) didApplyRasterizedFilter:(UIImage*) filteredImage index:(NSInteger) filterIndex value:(float) filterValue;
@end


@interface PhotoFiltersView : UIView<PhotoFilterThumbViewDelegate>
{
    CGFloat thumbWidth;
    CGFloat thumbHeight;
    
    BOOL isTextObject;
    
    NSOperationQueue *_thumbnailQueue;
    
    NSInteger selectedFilterIndex;
    float selectedFilterValue;
}

@property(nonatomic, weak) id <PhotoFiltersViewDelegate> delegate;

@property(nonatomic, strong) UIButton* applyBtn;

@property(nonatomic, strong) UILabel* titleLabel;

@property(nonatomic, strong) UIImageView* imageView;

@property(nonatomic, strong) UIImage* originalImage;
@property(nonatomic, strong) UIImage* originalThumbImage;

@property(nonatomic, strong) UISlider* filterSlider;

@property(nonatomic, strong) UIScrollView* filterScrollView;

@property(nonatomic, strong) NSMutableArray* thumbArray;

-(void) setImage:(UIImage*) image isText:(BOOL) flag;
-(void) setSelectedFilter:(NSInteger) filterIndex value:(float) filterValue;

@end
