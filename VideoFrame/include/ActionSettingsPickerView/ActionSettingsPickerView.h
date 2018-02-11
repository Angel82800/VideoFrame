//
//  ActionSettingsPickerView.h
//  VideoFrame
//
//  Created by Yinjing Li on 3/6/14.
//  Copyright (c) 2014 Yinjing Li. All rights reserved.
//


#import <Foundation/Foundation.h>


@class ActionSettingsPickerView;

@protocol ActionSettingsPickerView <NSObject>

-(void) didCancelActionSettings;

-(void) actionSheetPickerView:(ActionSettingsPickerView *)pickerView didSelectTitles:(NSArray*)titles typeIndex:(NSInteger)actionTypeIndex;

@end


@interface ActionSettingsPickerView : UIView<UIPickerViewDataSource,UIPickerViewDelegate>
{
@private

}

@property(nonatomic, weak) id<ActionSettingsPickerView> delegate;

@property(nonatomic, strong) UIPickerView *myPickerView;

@property(nonatomic, strong) UIToolbar *actionToolbar;

@property(nonatomic, strong) UIButton* changeAllBtn;
@property(nonatomic, strong) UIButton* typeBtn;

@property(nonatomic, strong) NSArray *titlesForComponenets;
@property(nonatomic, strong) NSArray *widthsForComponents;

@property(nonatomic, assign) BOOL isStart;
@property(nonatomic, assign) BOOL isRangePickerView;

@property(nonatomic, assign) NSInteger indexOfActionType;
@property(nonatomic, assign) NSInteger indexOfActionTime;


-(id) initWithTitle:(NSString*) title;
-(void) initializePicker;

@end