//
//  UITextViewExtras.h
//  VideoFrame
//
//  Created by Yinjing Li on 3/14/14.
//  Copyright (c) 2014 Yinjing Li. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol UITextViewExtrasDelegate <NSObject>

-(void) hit;

@end


@interface UITextViewExtras : UITextView


@property(nonatomic, weak) id<UITextViewExtrasDelegate> customDelegate;



@end
