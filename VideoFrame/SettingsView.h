//
//  SettingsView.h
//  VideoFrame
//
//  Created by Yinjing Li on 4/24/14.
//  Copyright (c) 2014 Yinjing Li. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Definition.h"
#import "AppDelegate.h"
#import "ActionSettingsPickerView.h"
#import "OutlineView.h"
#import "CustomModalView.h"
#import "TimePickerView.h"


#define PHOTO_DURATION 1
#define TEXT_DURATION 2
#define PREVIEW_DURATION 3


@protocol SettingsViewDelegate <NSObject>
@optional
-(void) didBackupProjects;
-(void) didRestoreProjects;

@end


@interface SettingsView : UIView<UIGestureRecognizerDelegate, ActionSettingsPickerView, CustomModalViewDelegate, OutlineViewDelegate, TimePickerViewDelegate>
{
    CGFloat firstX;
    CGFloat firstY;
    
    int isDurationType;
    
    BOOL isEmpty;
}

@property(nonatomic, weak) id <SettingsViewDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIButton* photoDurationBtn;
@property (weak, nonatomic) IBOutlet UIButton* textDurationBtn;
@property (weak, nonatomic) IBOutlet UIButton* startActionBtn;
@property (weak, nonatomic) IBOutlet UIButton* endActionBtn;
@property (weak, nonatomic) IBOutlet UIButton* timelineBtn;
@property (weak, nonatomic) IBOutlet UIButton* outputQualityBtn;
@property (weak, nonatomic) IBOutlet UIButton* previewLengthBtn;
@property (weak, nonatomic) IBOutlet UIButton* outlineBtn;
@property (weak, nonatomic) IBOutlet UIButton* startWithBtn;
@property (weak, nonatomic) IBOutlet UIButton *kbZoomBtn;
@property (weak, nonatomic) IBOutlet UIButton *kbScaleBtn;

@property (weak, nonatomic) IBOutlet UIButton* backupBtn;
@property (weak, nonatomic) IBOutlet UIButton* restoreBtn;
@property (weak, nonatomic) IBOutlet UIButton* projectBackupBtn;
@property (weak, nonatomic) IBOutlet UIButton* projectRestoreBtn;
@property (weak, nonatomic) IBOutlet UIButton* learnBtn;

@property (weak, nonatomic) IBOutlet UISwitch *kbSwitch;


@property(nonatomic, strong) ActionSettingsPickerView *actionSettingsPicker;
@property(nonatomic, strong) OutlineView* outlineView;
@property(nonatomic, strong) CustomModalView* customModalView;

-(void) initSettingsView;
-(void) updateSettings;
-(void) hideActionSettingsView;

@end
