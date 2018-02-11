//
//  TimePickerView.h
//  VideoFrame
//
//  Created by Yinjing Li on 7/18/14.
//  Copyright (c) 2014 Yinjing Li. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "Definition.h"


@class TimePickerView;

@protocol TimePickerViewDelegate <NSObject>

-(void) didCancel;
-(void) timePickerViewSeleted:(CGFloat) time;

@end


@interface TimePickerView : UIView<UIPickerViewDataSource,UIPickerViewDelegate>
{
@private

}

@property(nonatomic, weak) id<TimePickerViewDelegate> delegate;

@property(nonatomic, strong) UIPickerView *myPickerView;

@property(nonatomic, strong) UIToolbar *actionToolbar;

@property(nonatomic, strong) NSArray *arraysForComponenets;
@property(nonatomic, strong) NSMutableArray* minuteArray;
@property(nonatomic, strong) NSMutableArray* secondArray;
@property(nonatomic, strong) NSMutableArray* millisecondArray;

@property(nonatomic, assign) NSInteger indexOfMinute;
@property(nonatomic, assign) NSInteger indexOfSecond;
@property(nonatomic, assign) NSInteger indexOfMilliSecond;
@property(nonatomic, assign) NSInteger mediaType;

-(id) initWithTitle:(NSString*) title;

-(void) setComponents;
-(void) setTime:(CGFloat) time;
-(void) initializePicker;

@end