//
//  MotionPickerView.h
//  VideoFrame
//
//  Created by Yinjing Li on 7/18/14.
//  Copyright (c) 2014 Yinjing Li. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "Definition.h"


@class MotionPickerView;

@protocol MotionPickerViewDelegate <NSObject>

-(void) didCancelMotionPicker;

-(void) motionPickerViewSeleted:(CGFloat) motion;

@end


@interface MotionPickerView : UIView<UIPickerViewDataSource,UIPickerViewDelegate>
{
@private

}

@property(nonatomic, weak) id<MotionPickerViewDelegate> delegate;

@property(nonatomic, strong) UIPickerView *myPickerView;

@property(nonatomic, strong) UIToolbar *actionToolbar;

@property(nonatomic, strong) NSArray *arraysForComponenets;
@property(nonatomic, strong) NSMutableArray* motionArray;

@property(nonatomic, assign) NSInteger indexOfMotion;

@property(nonatomic, assign) NSInteger mediaType;

-(id) initWithTitle:(NSString*) title;
-(void) setComponents:(int) value;
-(void) setMotionValue:(int) motion;
-(void) initializePicker;

@end