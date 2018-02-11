//
//  RecentColorView.h
//  VideoFrame
//
//  Created by Yinjing Li on 12/13/14.
//  Copyright (c) 2014 Yinjing Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Definition.h"
#import "UIColor-Expanded.h"


@protocol RecentColorViewDelegate <NSObject>

@optional
-(void) selectColor:(NSInteger) colorIndex;
-(void) deleteColor:(NSInteger) colorIndex;
-(void) deleteColorEnabled;
@end


@interface ColorDeleteButton : UIButton

@end


@interface RecentColorView : UIView<UIGestureRecognizerDelegate>
{
    NSInteger colorIndex;
}

@property(nonatomic, weak) id <RecentColorViewDelegate> delegate;

@property(nonatomic, strong) ColorDeleteButton* deleteBtn;

-(id) initWithFrame:(CGRect)frame index:(NSInteger) tagColor string:(NSString*) strColor;

@end
