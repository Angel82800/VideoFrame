//
//  SettingsView.m
//  VideoFrame
//
//  Created by Yinjing Li on 4/24/14.
//  Copyright (c) 2014 Yinjing Li. All rights reserved.
//

#import "SettingsView.h"
#import "YJLActionMenu.h"
#import "UIImageExtras.h"
#import "MyCloudDocument.h"
#import "SHKActivityIndicator.h"


@implementation SettingsView


-(void) initSettingsView
{
    self.backgroundColor = [UIColor blackColor];
    
    [self.photoDurationBtn setBackgroundColor:[UIColor clearColor]];
    [self.photoDurationBtn setTitle:[NSString stringWithFormat:@"%.1fs", grPhotoDefaultDuration] forState:UIControlStateNormal];
    [self.photoDurationBtn.titleLabel setAdjustsFontSizeToFitWidth:YES];
    [self.photoDurationBtn.titleLabel setMinimumScaleFactor:0.1f];
    self.photoDurationBtn.titleLabel.font = [UIFont fontWithName:MYRIADPRO size:15.0f];
    [self.photoDurationBtn setTintColor:[UIColor whiteColor]];
    [self.photoDurationBtn.layer setBorderColor:[UIColor whiteColor].CGColor];
    [self.photoDurationBtn.layer setBorderWidth:1.0f];
    [self.photoDurationBtn.layer setCornerRadius:3.0f];
    
    [self.textDurationBtn setBackgroundColor:[UIColor clearColor]];
    [self.textDurationBtn setTitle:[NSString stringWithFormat:@"%.1fs", grTextDefaultDuration] forState:UIControlStateNormal];
    [self.textDurationBtn.titleLabel setAdjustsFontSizeToFitWidth:YES];
    [self.textDurationBtn.titleLabel setMinimumScaleFactor:0.1f];
    self.textDurationBtn.titleLabel.font = [UIFont fontWithName:MYRIADPRO size:15.0f];
    [self.textDurationBtn setTintColor:[UIColor whiteColor]];
    [self.textDurationBtn.layer setBorderColor:[UIColor whiteColor].CGColor];
    [self.textDurationBtn.layer setBorderWidth:1.0f];
    [self.textDurationBtn.layer setCornerRadius:3.0f];
    
    [self.startActionBtn setBackgroundColor:[UIColor clearColor]];
    [self.startActionBtn setTitle:@"None\n0.00s" forState:UIControlStateNormal];
    [self.startActionBtn.titleLabel setNumberOfLines:0];
    [self.startActionBtn.titleLabel setAdjustsFontSizeToFitWidth:YES];
    [self.startActionBtn.titleLabel setMinimumScaleFactor:0.1f];
    self.startActionBtn.titleLabel.font = [UIFont fontWithName:MYRIADPRO size:10];
    self.startActionBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.startActionBtn setTintColor:[UIColor whiteColor]];
    [self.startActionBtn.layer setBorderColor:[UIColor whiteColor].CGColor];
    [self.startActionBtn.layer setBorderWidth:1.0f];
    [self.startActionBtn.layer setCornerRadius:3.0f];
    
    [self.endActionBtn setBackgroundColor:[UIColor clearColor]];
    [self.endActionBtn setTitle:@"None\n0.00s" forState:UIControlStateNormal];
    [self.endActionBtn.titleLabel setNumberOfLines:0];
    [self.endActionBtn.titleLabel setAdjustsFontSizeToFitWidth:YES];
    [self.endActionBtn.titleLabel setMinimumScaleFactor:0.1f];
    self.endActionBtn.titleLabel.font = [UIFont fontWithName:MYRIADPRO size:10];
    self.endActionBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.endActionBtn setTintColor:[UIColor whiteColor]];
    [self.endActionBtn.layer setBorderColor:[UIColor whiteColor].CGColor];
    [self.endActionBtn.layer setBorderWidth:1.0f];
    [self.endActionBtn.layer setCornerRadius:3.0f];
    
    [self.timelineBtn setTintColor:[UIColor lightGrayColor]];
    [self.timelineBtn setBackgroundColor:[UIColor clearColor]];
    [self.timelineBtn.layer setBorderColor:[UIColor whiteColor].CGColor];
    [self.timelineBtn.layer setBorderWidth:1.0f];
    [self.timelineBtn.layer setCornerRadius:3.0f];
    
    if (gnTimelineType == TIMELINE_TYPE_1)
        [self.timelineBtn setImage:[UIImage imageNamed:@"timeline_1"] forState:UIControlStateNormal];
    else if (gnTimelineType == TIMELINE_TYPE_2)
        [self.timelineBtn setImage:[UIImage imageNamed:@"timeline_2"] forState:UIControlStateNormal];
    else if (gnTimelineType == TIMELINE_TYPE_3)
        [self.timelineBtn setImage:[UIImage imageNamed:@"timeline_3"] forState:UIControlStateNormal];
    
    [self.outputQualityBtn setBackgroundColor:[UIColor clearColor]];
    [self.outputQualityBtn setTitle:@"HD" forState:UIControlStateNormal];
    self.outputQualityBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.outputQualityBtn.titleLabel.font = [UIFont fontWithName:MYRIADPRO size:15.0f];
    [self.outputQualityBtn.titleLabel setAdjustsFontSizeToFitWidth:YES];
    [self.outputQualityBtn.titleLabel setMinimumScaleFactor:0.1f];
    [self.outputQualityBtn setTintColor:[UIColor whiteColor]];
    [self.outputQualityBtn.layer setBorderColor:[UIColor whiteColor].CGColor];
    [self.outputQualityBtn.layer setBorderWidth:1.0f];
    [self.outputQualityBtn.layer setCornerRadius:3.0f];
    
    [self updateOutputQualityButtonTitle];
    
    [self.previewLengthBtn setBackgroundColor:[UIColor clearColor]];
    [self.previewLengthBtn setTitle:[NSString stringWithFormat:@"%.1fs", grPreviewDuration] forState:UIControlStateNormal];
    [self.previewLengthBtn.titleLabel setAdjustsFontSizeToFitWidth:YES];
    [self.previewLengthBtn.titleLabel setMinimumScaleFactor:0.1f];
    self.previewLengthBtn.titleLabel.font = [UIFont fontWithName:MYRIADPRO size:15.0f];
    [self.previewLengthBtn setTintColor:[UIColor whiteColor]];
    [self.previewLengthBtn.layer setBorderColor:[UIColor whiteColor].CGColor];
    [self.previewLengthBtn.layer setBorderWidth:1.0f];
    [self.previewLengthBtn.layer setCornerRadius:3.0f];
    
    [self.outlineBtn setBackgroundColor:[UIColor clearColor]];
    [self.outlineBtn.layer setBorderWidth:1.0f];
    [self.outlineBtn.layer setCornerRadius:3.0f];
    [self.outlineBtn.layer setBorderColor:[UIColor whiteColor].CGColor];
    self.outlineBtn.titleLabel.textColor = [UIColor whiteColor];
    
    if (gnDefaultOutlineType == 1)
    {
        [self.outlineBtn setImage:nil forState:UIControlStateNormal];
        [self.outlineBtn setTitle:@"OFF" forState:UIControlStateNormal];
        [self.outlineBtn setTintColor:[UIColor whiteColor]];
    }
    else
    {
        [self.outlineBtn setTitle:@"" forState:UIControlStateNormal];
        
        NSString* fileName = [NSString stringWithFormat:@"style_iphone_%d", gnDefaultOutlineType];
        [self.outlineBtn setImage:[UIImage imageNamed:fileName] forState:UIControlStateNormal];
        [self.outlineBtn setTintColor:defaultOutlineColor];
    }
    
    [self.startWithBtn setBackgroundColor:[UIColor clearColor]];
    
    if (gnStartWithType == START_WITH_TEMPLATE)
        [self.startWithBtn setTitle:@"Template Page" forState:UIControlStateNormal];
    else if (gnStartWithType == START_WITH_PHOTOCAM)
        [self.startWithBtn setTitle:@"PhotoCam" forState:UIControlStateNormal];
    else if (gnStartWithType == START_WITH_VIDEOCAM)
        [self.startWithBtn setTitle:@"VideoCam" forState:UIControlStateNormal];
    
    self.startWithBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.startWithBtn.titleLabel.font = [UIFont fontWithName:MYRIADPRO size:15.0f];
    [self.startWithBtn setTintColor:[UIColor whiteColor]];
    [self.startWithBtn.layer setBorderColor:[UIColor whiteColor].CGColor];
    [self.startWithBtn.layer setBorderWidth:1.0f];
    [self.startWithBtn.layer setCornerRadius:3.0f];
    
    if(isKenBurnsEnabled)
        self.kbSwitch.on = YES;
    else
        self.kbSwitch.on = NO;
    
    [self.kbZoomBtn setBackgroundColor:[UIColor clearColor]];
    if(gnKBZoomInOutType == KB_IN)
        [self.kbZoomBtn setTitle:@"Zoom In" forState:UIControlStateNormal];
    else
        [self.kbZoomBtn setTitle:@"Zoom Out" forState:UIControlStateNormal];
    self.kbZoomBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.kbZoomBtn.titleLabel.font = [UIFont fontWithName:MYRIADPRO size:15.0f];
    [self.kbZoomBtn setTintColor:[UIColor whiteColor]];
    [self.kbZoomBtn.layer setBorderColor:[UIColor whiteColor].CGColor];
    [self.kbZoomBtn.layer setBorderWidth:1.0f];
    [self.kbZoomBtn.layer setCornerRadius:3.0f];

    [self.kbScaleBtn setBackgroundColor:[UIColor clearColor]];
    [self.kbScaleBtn setTitle:[NSString stringWithFormat:@"%.1fx", grKBScale] forState:UIControlStateNormal];
    self.kbScaleBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.kbScaleBtn.titleLabel.font = [UIFont fontWithName:MYRIADPRO size:15.0f];
    [self.kbScaleBtn setTintColor:[UIColor whiteColor]];
    [self.kbScaleBtn.layer setBorderColor:[UIColor whiteColor].CGColor];
    [self.kbScaleBtn.layer setBorderWidth:1.0f];
    [self.kbScaleBtn.layer setCornerRadius:3.0f];
    
    [self.backupBtn setBackgroundColor:[UIColor clearColor]];
    [self.backupBtn setTitle:@"Backup" forState:UIControlStateNormal];
    self.backupBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.backupBtn.titleLabel.font = [UIFont fontWithName:MYRIADPRO size:15.0f];
    [self.backupBtn setTintColor:[UIColor whiteColor]];
    [self.backupBtn.layer setBorderColor:[UIColor whiteColor].CGColor];
    [self.backupBtn.layer setBorderWidth:1.0f];
    [self.backupBtn.layer setCornerRadius:3.0f];
    
    [self.restoreBtn setBackgroundColor:[UIColor clearColor]];
    [self.restoreBtn setTitle:@"Restore" forState:UIControlStateNormal];
    self.restoreBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.restoreBtn.titleLabel.font = [UIFont fontWithName:MYRIADPRO size:15.0f];
    [self.restoreBtn setTintColor:[UIColor whiteColor]];
    [self.restoreBtn.layer setBorderColor:[UIColor whiteColor].CGColor];
    [self.restoreBtn.layer setBorderWidth:1.0f];
    [self.restoreBtn.layer setCornerRadius:3.0f];

    [self.projectBackupBtn setBackgroundColor:[UIColor clearColor]];
    [self.projectBackupBtn setTitle:@"Backup" forState:UIControlStateNormal];
    self.projectBackupBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.projectBackupBtn.titleLabel.font = [UIFont fontWithName:MYRIADPRO size:15.0f];
    [self.projectBackupBtn setTintColor:[UIColor whiteColor]];
    [self.projectBackupBtn.layer setBorderColor:[UIColor whiteColor].CGColor];
    [self.projectBackupBtn.layer setBorderWidth:1.0f];
    [self.projectBackupBtn.layer setCornerRadius:3.0f];
    
    [self.projectRestoreBtn setBackgroundColor:[UIColor clearColor]];
    [self.projectRestoreBtn setTitle:@"Restore" forState:UIControlStateNormal];
    self.projectRestoreBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.projectRestoreBtn.titleLabel.font = [UIFont fontWithName:MYRIADPRO size:15.0f];
    [self.projectRestoreBtn setTintColor:[UIColor whiteColor]];
    [self.projectRestoreBtn.layer setBorderColor:[UIColor whiteColor].CGColor];
    [self.projectRestoreBtn.layer setBorderWidth:1.0f];
    [self.projectRestoreBtn.layer setCornerRadius:3.0f];

    [self.learnBtn setBackgroundColor:[UIColor clearColor]];
    [self.learnBtn setTitle:@"Learn How" forState:UIControlStateNormal];
    self.learnBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.learnBtn.titleLabel.font = [UIFont fontWithName:MYRIADPRO size:15.0f];
    [self.learnBtn setTintColor:[UIColor whiteColor]];
    [self.learnBtn.layer setBorderColor:[UIColor whiteColor].CGColor];
    [self.learnBtn.layer setBorderWidth:1.0f];
    [self.learnBtn.layer setCornerRadius:3.0f];

    CGRect menuFrame = CGRectZero;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        menuFrame = CGRectMake(0.0f, 0.0f, 200.0f, 295.0f);
    else
        menuFrame = CGRectMake(0.0f, 0.0f, 300.0f, 450.0f);
    
    self.outlineView = [[OutlineView alloc] initWithFrame:menuFrame];
    self.outlineView.delegate = self;
}


#pragma mark -
#pragma mark -

- (IBAction) onPhotoDuration:(id) sender
{
    self.superview.hidden = YES;
    
    isDurationType = PHOTO_DURATION;
    
    TimePickerView *picker = [[TimePickerView alloc] initWithTitle:@"Default"];
    picker.delegate = self;
    [picker setComponents];
    [picker setMediaType:MEDIA_PHOTO];
    [picker setTime:grPhotoDefaultDuration];
    [picker initializePicker];
    
    if (self.customModalView != nil)
    {
        [self.customModalView hideCustomModalView];
        self.customModalView = nil;
    }

    self.customModalView = [[CustomModalView alloc] initWithView:picker bgColor:[UIColor whiteColor]];
    self.customModalView.delegate = self;
    self.customModalView.dismissButtonRight = YES;
    [self.customModalView show];
}

- (IBAction) onTextDuration:(id) sender
{
    self.superview.hidden = YES;

    isDurationType = TEXT_DURATION;
    
    TimePickerView *picker = [[TimePickerView alloc] initWithTitle:@"Default"];
    picker.delegate = self;
    [picker setComponents];
    [picker setMediaType:MEDIA_TEXT];
    [picker setTime:grTextDefaultDuration];
    [picker initializePicker];
    
    if (self.customModalView != nil)
    {
        [self.customModalView hideCustomModalView];
        self.customModalView = nil;
    }
    
    self.customModalView = [[CustomModalView alloc] initWithView:picker bgColor:[UIColor whiteColor]];
    self.customModalView.delegate = self;
    self.customModalView.dismissButtonRight = YES;
    [self.customModalView show];
}

- (IBAction) onStartAction:(id) sender
{
    [self setStartEndAction:YES];
}

- (IBAction) onEndAction:(id) sender
{
    [self setStartEndAction:NO];
}

- (IBAction) onTimeline:(id) sender
{
    NSArray *menuItems =
    @[
      [YJLActionMenuItem menuItem:@"Stacked"
                            image:[[UIImage imageNamed:@"timeline_1"] rescaleImageToSize:CGSizeMake(30.0f, 15.0f)]
                           target:self
                           action:@selector(onTimeline_1)],
      
      [YJLActionMenuItem menuItem:@"Staggered"
                            image:[[UIImage imageNamed:@"timeline_2"] rescaleImageToSize:CGSizeMake(30.0f, 15.0f)]
                           target:self
                           action:@selector(onTimeline_2)],
      
      [YJLActionMenuItem menuItem:@"Overlapped"
                            image:[[UIImage imageNamed:@"timeline_3"] rescaleImageToSize:CGSizeMake(30.0f, 15.0f)]
                           target:self
                           action:@selector(onTimeline_3)],
      ];
    
    CGRect frame = [self.superview convertRect:self.timelineBtn.frame fromView:self];
    
    [YJLActionMenu showMenuInView:self.superview
                         fromRect:frame
                        menuItems:menuItems isWhiteBG:NO];
}

- (void) onTimeline_1
{
    gnTimelineType = TIMELINE_TYPE_1;
    
    [self.timelineBtn setImage:[UIImage imageNamed:@"timeline_1"] forState:UIControlStateNormal];
    
    [self saveProjectSettingstoPlist];
}

- (void) onTimeline_2
{
    gnTimelineType = TIMELINE_TYPE_2;
    
    [self.timelineBtn setImage:[UIImage imageNamed:@"timeline_2"] forState:UIControlStateNormal];
    
    [self saveProjectSettingstoPlist];
}

- (void) onTimeline_3
{
    gnTimelineType = TIMELINE_TYPE_3;
    
    [self.timelineBtn setImage:[UIImage imageNamed:@"timeline_3"] forState:UIControlStateNormal];
    
    [self saveProjectSettingstoPlist];
}

- (IBAction) onPreviewLength:(id) sender
{
    self.superview.hidden = YES;

    isDurationType = PREVIEW_DURATION;
    
    TimePickerView *picker = [[TimePickerView alloc] initWithTitle:@"Default"];
    picker.delegate = self;
    [picker setComponents];
    [picker setTime:grPreviewDuration];
    [picker initializePicker];
    
    if (self.customModalView != nil)
    {
        [self.customModalView hideCustomModalView];
        self.customModalView = nil;
    }
    
    self.customModalView = [[CustomModalView alloc] initWithView:picker bgColor:[UIColor whiteColor]];
    self.customModalView.delegate = self;
    self.customModalView.dismissButtonRight = YES;
    [self.customModalView show];
}

- (IBAction) onOutline:(id) sender
{
    if (self.customModalView != nil)
    {
        [self.customModalView hideCustomModalView];
        self.customModalView = nil;
    }
    
    [self.outlineView setObjectBorderStyle:gnDefaultOutlineType];
    [self.outlineView setObjectBorderWidth:grDefaultOutlineWidth];
    [self.outlineView setObjectBorderColor:defaultOutlineColor];
    [self.outlineView setObjectCornerRadius:grDefaultOutlineCorner];
    [self.outlineView setMaxCornerValue:50.0f];
    [self.outlineView initialize];
    
    self.customModalView = [[CustomModalView alloc] initWithView:self.outlineView isCenter:NO];
    self.customModalView.delegate = self;
    self.customModalView.dismissButtonRight = YES;
    [self.customModalView show];
}

- (IBAction) onStartWith:(id) sender
{
    NSArray *menuItems =
    @[
      [YJLActionMenuItem menuItem:@"Template Page"
                            image:nil
                           target:self
                           action:@selector(onTemplate)],
      
      [YJLActionMenuItem menuItem:@"PhotoCam"
                            image:nil
                           target:self
                           action:@selector(onPhotoCam)],
      
      [YJLActionMenuItem menuItem:@"VideoCam"
                            image:nil
                           target:self
                           action:@selector(onVideoCam)],
      ];
    
    CGRect frame = [self.superview convertRect:self.startWithBtn.frame fromView:self];
    [YJLActionMenu showMenuInView:self.superview
                         fromRect:frame
                        menuItems:menuItems isWhiteBG:NO];
}

- (void) onTemplate
{
    gnStartWithType = START_WITH_TEMPLATE;
    
    [self.startWithBtn setTitle:@"Template Page" forState:UIControlStateNormal];
    
    [self saveProjectSettingstoPlist];
}

- (void) onPhotoCam
{
    gnStartWithType = START_WITH_PHOTOCAM;

    [self.startWithBtn setTitle:@"PhotoCam" forState:UIControlStateNormal];
    
    [self saveProjectSettingstoPlist];
}

- (void) onVideoCam
{
    gnStartWithType = START_WITH_VIDEOCAM;

    [self.startWithBtn setTitle:@"VideoCam" forState:UIControlStateNormal];
    
    [self saveProjectSettingstoPlist];
}

- (IBAction) onOutputQuality:(id) sender
{
    NSArray *menuItems =
    @[
      [YJLActionMenuItem menuItem:@"HD"
                            image:nil
                           target:self
                           action:@selector(onSelectedHD)],
      
      [YJLActionMenuItem menuItem:@"Universal"
                            image:nil
                           target:self
                           action:@selector(onSelectedUniversal)],

      [YJLActionMenuItem menuItem:@"SDTV"
                            image:nil
                           target:self
                           action:@selector(onSelectedSdtv)],
      ];
    
    CGRect frame = [self.superview convertRect:self.outputQualityBtn.frame fromView:self];
    [YJLActionMenu showMenuInView:self.superview
                         fromRect:frame
                        menuItems:menuItems isWhiteBG:NO];
}

-(void) onSelectedHD
{
    gnOutputQuality = OUTPUT_HD;
    
    [self updateOutputQualityButtonTitle];
    
    [self saveProjectSettingstoPlist];
}

-(void) onSelectedUniversal
{
    gnOutputQuality = OUTPUT_UNIVERSAL;
    
    [self updateOutputQualityButtonTitle];
    
    [self saveProjectSettingstoPlist];
}

-(void) onSelectedSdtv
{
    gnOutputQuality = OUTPUT_SDTV;
    
    [self updateOutputQualityButtonTitle];
    
    [self saveProjectSettingstoPlist];
}

-(void) updateOutputQualityButtonTitle
{
    switch (gnOutputQuality)
    {
        case OUTPUT_HD:
            [self.outputQualityBtn setTitle:@"HD" forState:UIControlStateNormal];
            break;
        case OUTPUT_UNIVERSAL:
            [self.outputQualityBtn setTitle:@"Universal" forState:UIControlStateNormal];
            break;
        case OUTPUT_SDTV:
            [self.outputQualityBtn setTitle:@"SDTV" forState:UIControlStateNormal];
            break;
            
        default:
            break;
    }
}


#pragma mark -
#pragma mark - Update Settings

- (void) updateSettings
{
    if (gnStartActionTypeDef != ACTION_NONE)
    {
        NSString* startActionTypeStr = [gaActionNameArray objectAtIndex:gnStartActionTypeDef];
        [self.startActionBtn setTitle:[NSString stringWithFormat:@"%@\n%.2fs", startActionTypeStr, grStartActionTimeDef] forState:UIControlStateNormal];
    }
    
    if (gnEndActionTypeDef != ACTION_NONE)
    {
        NSString* endActionTypeStr = [gaActionNameArray objectAtIndex:gnEndActionTypeDef];
        [self.endActionBtn setTitle:[NSString stringWithFormat:@"%@\n%.2fs", endActionTypeStr, grEndActionTimeDef] forState:UIControlStateNormal];
    }
    
    if (gnDefaultOutlineType == 1)
    {
        [self.outlineBtn setImage:nil forState:UIControlStateNormal];
        [self.outlineBtn setTitle:@"OFF" forState:UIControlStateNormal];
        [self.outlineBtn setTintColor:[UIColor whiteColor]];
    }
    else
    {
        [self.outlineBtn setTitle:@"" forState:UIControlStateNormal];
        
        NSString* fileName = [NSString stringWithFormat:@"style_iphone_%d", gnDefaultOutlineType];
        [self.outlineBtn setImage:[UIImage imageNamed:fileName] forState:UIControlStateNormal];
        [self.outlineBtn setTintColor:defaultOutlineColor];
    }
    
    if (isKenBurnsEnabled)
    {
        [self.kbSwitch setOn:YES];
        
        self.kbZoomBtn.hidden = NO;
        self.kbScaleBtn.hidden = NO;
        
        self.kbZoomBtn.alpha = 1.0f;
        self.kbScaleBtn.alpha = 1.0f;
    }
    else
    {
        [self.kbSwitch setOn:NO];

        self.kbZoomBtn.hidden = YES;
        self.kbScaleBtn.hidden = YES;
        
        self.kbZoomBtn.alpha = 0.0f;
        self.kbScaleBtn.alpha = 0.0f;
    }
}


#pragma mark -
#pragma mark - TimePickerViewDelegate

-(void) didCancel
{
    self.superview.hidden = NO;

    if (self.customModalView != nil)
    {
        [self.customModalView hideCustomModalView];
        self.customModalView = nil;
    }
}

-(void) timePickerViewSeleted:(CGFloat) time
{
    self.superview.hidden = NO;

    if (isDurationType == PHOTO_DURATION)
    {
        grPhotoDefaultDuration = time;
        [self.photoDurationBtn setTitle:[NSString stringWithFormat:@"%.1fs", grPhotoDefaultDuration] forState:UIControlStateNormal];
    }
    else if(isDurationType == TEXT_DURATION)
    {
        grTextDefaultDuration = time;
        [self.textDurationBtn setTitle:[NSString stringWithFormat:@"%.1fs", grTextDefaultDuration] forState:UIControlStateNormal];
    }
    else if(isDurationType == PREVIEW_DURATION)
    {
        grPreviewDuration = time;
        [self.previewLengthBtn setTitle:[NSString stringWithFormat:@"%.1fs", grPreviewDuration] forState:UIControlStateNormal];
    }
    
    if (self.customModalView != nil)
    {
        [self.customModalView hideCustomModalView];
        self.customModalView = nil;
    }
    
    [self saveProjectSettingstoPlist];
}


#pragma mark - 
#pragma mark - Save project settings plist

-(void) saveProjectSettingstoPlist
{
    NSFileManager* localFileManager = [NSFileManager defaultManager];
    NSString* folderDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Library"];
    NSString* plistFolderPath = [folderDir stringByAppendingPathComponent:@"Preferences"];

    //Project settings in plist
    NSMutableDictionary *plistDict = nil;
    
    NSString* plistFileName = [plistFolderPath stringByAppendingPathComponent:@"ProjectSettings.plist"];
    
    if (![localFileManager fileExistsAtPath:plistFileName])
    {
        [localFileManager createFileAtPath:plistFileName contents:nil attributes:nil];
        
        plistDict = [NSMutableDictionary dictionary];
    }
    else
    {
        plistDict = [[NSMutableDictionary alloc] initWithContentsOfFile:plistFileName];
    }
    
    [plistDict setObject:[NSNumber numberWithFloat:grPhotoDefaultDuration] forKey:@"grPhotoDefaultDuration"];
    [plistDict setObject:[NSNumber numberWithFloat:grTextDefaultDuration] forKey:@"grTextDefaultDuration"];
    [plistDict setObject:[NSNumber numberWithInt:gnStartActionTypeDef] forKey:@"startActionTypeDef"];
    [plistDict setObject:[NSNumber numberWithFloat:grStartActionTimeDef] forKey:@"startActionTimeDef"];
    [plistDict setObject:[NSNumber numberWithInt:gnEndActionTypeDef] forKey:@"endActionTypeDef"];
    [plistDict setObject:[NSNumber numberWithFloat:grEndActionTimeDef] forKey:@"endActionTimeDef"];
    [plistDict setObject:[NSNumber numberWithInt:gnTimelineType] forKey:@"gnTimelineType"];
    [plistDict setObject:[NSNumber numberWithInt:gnOutputQuality] forKey:@"gnOutputQuality"];
    [plistDict setObject:[NSNumber numberWithFloat:grPreviewDuration] forKey:@"grPreviewDuration"];
    [plistDict setObject:[NSNumber numberWithInt:gnDefaultOutlineType] forKey:@"gnDefaultOutlineType"];
    
    NSString* hexString = [defaultOutlineColor hexStringFromColor];
    hexString = [hexString uppercaseString];
    [plistDict setObject:hexString forKey:@"defaultOutlineColor"];
    
    [plistDict setObject:[NSNumber numberWithFloat:grDefaultOutlineWidth] forKey:@"grDefaultOutlineWidth"];
    [plistDict setObject:[NSNumber numberWithFloat:grDefaultOutlineCorner] forKey:@"grDefaultOutlineCorner"];
    [plistDict setObject:[NSNumber numberWithInt:gnStartWithType] forKey:@"gnStartWithType"];
    [plistDict setObject:[NSNumber numberWithBool:isKenBurnsEnabled] forKey:@"isKenBurnsEnabled"];
    [plistDict setObject:[NSNumber numberWithInt:gnKBZoomInOutType] forKey:@"gnKBZoomInOutType"];
    [plistDict setObject:[NSNumber numberWithFloat:grKBScale] forKey:@"grKBScale"];

    [plistDict writeToFile:plistFileName atomically:YES];
}


#pragma mark -
#pragma mark - Start/End Action

- (void) setStartEndAction:(BOOL) isStart
{
    self.superview.hidden = YES;

    NSMutableArray* timeArray = [[NSMutableArray alloc] init];
    [timeArray addObject:[NSString stringWithFormat:@"%.2fs", MIN_DURATION]];

    CGFloat duration = (isStart == YES) ? grStartActionTimeDef : grEndActionTimeDef;
    CGFloat actionTime = 0.0f;

    while (actionTime < 15.0f)
    {
        actionTime += 0.5f;
        NSString* timeStr = [NSString stringWithFormat:@"%.2fs", actionTime];
        [timeArray addObject:timeStr];
    }
    
    if (self.actionSettingsPicker != nil)
        self.actionSettingsPicker = nil;

    self.actionSettingsPicker = [[ActionSettingsPickerView alloc] initWithTitle:@"Action Settings"];
    self.actionSettingsPicker.delegate = self;
    [self.actionSettingsPicker setTitlesForComponenets:[NSArray arrayWithObjects:gaActionNameArray,
                                                        [NSArray arrayWithArray:timeArray],
                                                        nil]];
    NSInteger selectedActionTypeIndex = 0;
    NSInteger selectedActionTimeIndex = 0;
    
    for (int i=0; i<timeArray.count; i++)
    {
        NSString* str = [timeArray objectAtIndex:i];
        CGFloat time = [str floatValue];
        
        if (time == duration)
        {
            selectedActionTimeIndex = i;
            break;
        }
    }
    
    selectedActionTypeIndex = (isStart == YES) ? gnStartActionTypeDef : gnEndActionTypeDef;
    
    [self.actionSettingsPicker setIndexOfActionType:selectedActionTypeIndex];
    [self.actionSettingsPicker setIndexOfActionTime:selectedActionTimeIndex];
    [self.actionSettingsPicker setIsStart:isStart];
    [self.actionSettingsPicker initializePicker];
    
    if (self.customModalView != nil)
    {
        [self.customModalView hideCustomModalView];
        self.customModalView = nil;
    }
    
    self.customModalView = [[CustomModalView alloc] initWithView:self.actionSettingsPicker bgColor:[UIColor whiteColor]];
    self.customModalView.delegate = self;
    self.customModalView.dismissButtonRight = YES;
    [self.customModalView show];
}


#pragma mark -
#pragma mark - ActionSettingsPickerView Delegate

-(void)actionSheetPickerView:(ActionSettingsPickerView *)pickerView didSelectTitles:(NSArray *)titles typeIndex:(NSInteger)actionTypeIndex
{
    self.superview.hidden = NO;

    //action type
    NSString* actionTypeStr = [titles objectAtIndex:0];
    int actionType = (int)actionTypeIndex;
    
    //action time
    NSString* actionTimeStr = [titles objectAtIndex:1];
    CGFloat actionTime = [actionTimeStr floatValue];
    
    if (pickerView.isStart)
    {
        if (actionType == 0)
            actionTime = 0.0f;
        
        gnStartActionTypeDef = actionType;
        grStartActionTimeDef = actionTime;

        [self.startActionBtn setTitle:[NSString stringWithFormat:@"%@\n%.2fs", actionTypeStr, actionTime] forState:UIControlStateNormal];
    }
    else
    {
        if (actionType == 0)
            actionTime = 0.0f;

        gnEndActionTypeDef = actionType;
        grEndActionTimeDef = actionTime;
        
        [self.endActionBtn setTitle:[NSString stringWithFormat:@"%@\n%.2fs", actionTypeStr, actionTime] forState:UIControlStateNormal];
    }
    
    if (self.customModalView != nil)
    {
        [self.customModalView hideCustomModalView];
        self.customModalView = nil;
    }
    
    [self saveProjectSettingstoPlist];
}

-(void) didCancelActionSettings
{
    self.superview.hidden = NO;

    if (self.customModalView != nil)
    {
        [self.customModalView hideCustomModalView];
        self.customModalView = nil;
    }
}

- (void) hideActionSettingsView
{
    self.superview.hidden = NO;

    if (self.customModalView)
    {
        [self.customModalView hideCustomModalView];
        self.customModalView = nil;
    }
}


#pragma mark - 
#pragma mark - OutlineView Delegate

-(void)changeBorder:(int)style borderColor:(UIColor *)color borderWidth:(CGFloat)width cornerRadius:(CGFloat)radius
{
    gnDefaultOutlineType = style;
    defaultOutlineColor = color;
    grDefaultOutlineWidth = width;
    grDefaultOutlineCorner = radius;
    
    if (gnDefaultOutlineType == 1)
    {
        [self.outlineBtn setImage:nil forState:UIControlStateNormal];
        [self.outlineBtn setTitle:@"OFF" forState:UIControlStateNormal];
        [self.outlineBtn setTintColor:[UIColor whiteColor]];
    }
    else
    {
        [self.outlineBtn setTitle:@"" forState:UIControlStateNormal];
        
        NSString* fileName = [NSString stringWithFormat:@"style_iphone_%d", gnDefaultOutlineType];
        [self.outlineBtn setImage:[UIImage imageNamed:fileName] forState:UIControlStateNormal];
        [self.outlineBtn setTintColor:defaultOutlineColor];
    }
    
    [self saveProjectSettingstoPlist];
}


#pragma mark - 
#pragma mark - iCloud

-(IBAction) backupDataToICloud:(id) sender
{
    //Save thumbnail to iCloud

    NSURL *ubiq = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
    
    if (ubiq)
    {
        [[SHKActivityIndicator currentIndicator] displayActivity:(@"Backup to iCloud...") isLock:YES];

        [self performSelector:@selector(saveData) withObject:nil afterDelay:0.2f];   //save data to iCloud
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please login to iCloud first!"  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil, nil];
        [alert show];
    }
}

-(IBAction) restoreDataFromICloud:(id) sender
{
    NSURL *ubiq = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
    
    if (ubiq)
    {
        [[SHKActivityIndicator currentIndicator] displayActivity:(@"Restore from iCloud...") isLock:YES];

        [self performSelector:@selector(restoreData) withObject:nil afterDelay:0.2f];   //restore data from iCloud
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please login to iCloud first!"  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil, nil];
        [alert show];
    }
}


#pragma mark -
#pragma mark - Restore Data from iCloud

-(void)restoreData
{
    NSFileManager* localFileManager = [NSFileManager defaultManager];
    NSString* folderDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Library"];
    NSString* plistFolderPath = [folderDir stringByAppendingPathComponent:@"Preferences"];
    NSString* thumbFolderPath = [plistFolderPath stringByAppendingPathComponent:@"CustomThumbnails"];

    
    //load ProjectSettings.plist from iCloud
    NSString* plistFileName = [plistFolderPath stringByAppendingPathComponent:@"ProjectSettings.plist"];

    NSURL *containerUbiquitousURL = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
    NSURL *destinationUbiquitousURL = [[containerUbiquitousURL URLByAppendingPathComponent:@"Documents"] URLByAppendingPathComponent:@"ProjectSettings.plist"];
    
    MyCloudDocument *mydoc = [[MyCloudDocument alloc] initWithFileURL:destinationUbiquitousURL];
    
    [mydoc openWithCompletionHandler:^(BOOL success) {
        
        if (success)
        {
            NSError* error = nil;
            NSData* plistData = mydoc.dataContent;
            
            if ([localFileManager fileExistsAtPath:plistFileName])
                [localFileManager removeItemAtPath:plistFileName error:&error];
            
            [plistData writeToFile:plistFileName atomically:YES];
            
            NSMutableDictionary *plistDict = [[NSMutableDictionary alloc] initWithContentsOfFile:plistFileName];
            
            grPhotoDefaultDuration = [[plistDict objectForKey:@"grPhotoDefaultDuration"] floatValue];
            grTextDefaultDuration = [[plistDict objectForKey:@"grTextDefaultDuration"] floatValue];
            gnStartActionTypeDef = [[plistDict objectForKey:@"startActionTypeDef"] intValue];
            grStartActionTimeDef = [[plistDict objectForKey:@"startActionTimeDef"] floatValue];
            gnEndActionTypeDef = [[plistDict objectForKey:@"endActionTypeDef"] intValue];
            grEndActionTimeDef = [[plistDict objectForKey:@"endActionTimeDef"] floatValue];
            gnTimelineType = [[plistDict objectForKey:@"gnTimelineType"] intValue];
            gnOutputQuality = [[plistDict objectForKey:@"gnOutputQuality"] intValue];
            grPreviewDuration = [[plistDict objectForKey:@"grPreviewDuration"] floatValue];
            gnDefaultOutlineType = [[plistDict objectForKey:@"gnDefaultOutlineType"] intValue];
            
            NSString* hexColor = [plistDict objectForKey:@"defaultOutlineColor"];
            defaultOutlineColor = [UIColor colorWithHexString:hexColor];
            
            grDefaultOutlineWidth = [[plistDict objectForKey:@"grDefaultOutlineWidth"] floatValue];
            grDefaultOutlineCorner = [[plistDict objectForKey:@"grDefaultOutlineCorner"] floatValue];
            gnStartWithType = [[plistDict objectForKey:@"gnStartWithType"] intValue];
            
            //update UI
            [self.photoDurationBtn setTitle:[NSString stringWithFormat:@"%.1fs", grPhotoDefaultDuration] forState:UIControlStateNormal];
            [self.textDurationBtn setTitle:[NSString stringWithFormat:@"%.1fs", grTextDefaultDuration] forState:UIControlStateNormal];
            [self.previewLengthBtn setTitle:[NSString stringWithFormat:@"%.1fs", grPreviewDuration] forState:UIControlStateNormal];
            
            [self updateSettings];
            [self updateOutputQualityButtonTitle];

            if (gnStartWithType == START_WITH_TEMPLATE)
                [self.startWithBtn setTitle:@"Template Page" forState:UIControlStateNormal];
            else if (gnStartWithType == START_WITH_PHOTOCAM)
                [self.startWithBtn setTitle:@"PhotoCam" forState:UIControlStateNormal];
            else if (gnStartWithType == START_WITH_VIDEOCAM)
                [self.startWithBtn setTitle:@"VideoCam" forState:UIControlStateNormal];

            if(gnTimelineType == TIMELINE_TYPE_1)
                [self.timelineBtn setImage:[UIImage imageNamed:@"timeline_1"] forState:UIControlStateNormal];
            else if (gnTimelineType == TIMELINE_TYPE_2)
                [self.timelineBtn setImage:[UIImage imageNamed:@"timeline_2"] forState:UIControlStateNormal];
            else if (gnTimelineType == TIMELINE_TYPE_3)
                [self.timelineBtn setImage:[UIImage imageNamed:@"timeline_3"] forState:UIControlStateNormal];
            
            [mydoc closeWithCompletionHandler:^(BOOL success) {
                
            }];
        }
        
    }];

    
    //load RecentColor.plist from iCloud
    plistFileName = [plistFolderPath stringByAppendingPathComponent:@"RecentColor.plist"];

    containerUbiquitousURL = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
    destinationUbiquitousURL = [[containerUbiquitousURL URLByAppendingPathComponent:@"Documents"] URLByAppendingPathComponent:@"RecentColor.plist"];
    
    mydoc = [[MyCloudDocument alloc] initWithFileURL:destinationUbiquitousURL];
    
    [mydoc openWithCompletionHandler:^(BOOL success) {
        
        if (success)
        {
            NSError* error = nil;
            NSData* plistData = mydoc.dataContent;
            
            if ([localFileManager fileExistsAtPath:plistFileName])
                [localFileManager removeItemAtPath:plistFileName error:&error];
            
            [plistData writeToFile:plistFileName atomically:YES];
            
            [gaRecentColorArray removeAllObjects];
            gaRecentColorArray = nil;
            
            gaRecentColorArray = [[NSMutableArray alloc] init];
            
            NSMutableDictionary *plistDict = [[NSMutableDictionary alloc] initWithContentsOfFile:plistFileName];
            
            int recentArrayCount = [[plistDict objectForKey:@"RecentColorCount"] intValue];
            
            for (int i=0; i<recentArrayCount; i++)
            {
                NSString* recentString = [plistDict objectForKey:[NSString stringWithFormat:@"%d-RecentColorString", i]];
                
                [gaRecentColorArray addObject:recentString];
            }
            
            [mydoc closeWithCompletionHandler:^(BOOL success) {
                
            }];
        }

    }];

    
    //load custom video name from iCloud
    plistFileName = [plistFolderPath stringByAppendingPathComponent:@"VideoName.plist"];
    
    containerUbiquitousURL = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
    destinationUbiquitousURL = [[containerUbiquitousURL URLByAppendingPathComponent:@"Documents"] URLByAppendingPathComponent:@"VideoName.plist"];
    
    mydoc = [[MyCloudDocument alloc] initWithFileURL:destinationUbiquitousURL];
    
    [mydoc openWithCompletionHandler:^(BOOL success) {
        
        if (success)
        {
            NSError* error = nil;
            NSData* plistData = mydoc.dataContent;
            
            if ([localFileManager fileExistsAtPath:plistFileName])
                [localFileManager removeItemAtPath:plistFileName error:&error];
            
            [plistData writeToFile:plistFileName atomically:YES];
            
            [mydoc closeWithCompletionHandler:^(BOOL success) {
                
            }];
        }
        
    }];

    
    //load ThumbFileName.plist from iCloud
    plistFileName = [plistFolderPath stringByAppendingPathComponent:@"ThumbFileName.plist"];

    containerUbiquitousURL = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
    destinationUbiquitousURL = [[containerUbiquitousURL URLByAppendingPathComponent:@"Documents"] URLByAppendingPathComponent:@"ThumbFileName.plist"];

    mydoc = [[MyCloudDocument alloc] initWithFileURL:destinationUbiquitousURL];

    [mydoc openWithCompletionHandler:^(BOOL success) {
        
        if (success)
        {
            NSError* error = nil;
            NSData* plistData = mydoc.dataContent;
            
            if ([localFileManager fileExistsAtPath:plistFileName])
                [localFileManager removeItemAtPath:plistFileName error:&error];
            
            [plistData writeToFile:plistFileName atomically:YES];
            
            BOOL isDirectory = NO;
            BOOL exist = [localFileManager fileExistsAtPath:thumbFolderPath isDirectory:&isDirectory];
            
            if (!exist)
            {
                [localFileManager createDirectoryAtPath:thumbFolderPath withIntermediateDirectories:NO attributes:nil error:nil];
            }
            
            //load thumbnail image from iCloud
            NSMutableDictionary *plistDict = nil;
            plistDict = [[NSMutableDictionary alloc] initWithContentsOfFile:plistFileName];
            
            NSArray* allValues = plistDict.allValues;
            
            for (int i=0; i<allValues.count; i++)
            {
                NSString* fileName = [allValues objectAtIndex:i];
                NSString* filePath = [thumbFolderPath stringByAppendingPathComponent:fileName];
                
                NSURL *containerUbiquitousURL = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
                NSURL *destinationUbiquitousURL = [[containerUbiquitousURL URLByAppendingPathComponent:@"Documents"] URLByAppendingPathComponent:fileName];
                
                MyCloudDocument *thumbDoc = [[MyCloudDocument alloc] initWithFileURL:destinationUbiquitousURL];
                
                [thumbDoc openWithCompletionHandler:^(BOOL success) {
                    
                    if (success)
                    {
                        NSError* error = nil;
                        NSData* imageData = thumbDoc.dataContent;
                        
                        if ([localFileManager fileExistsAtPath:filePath])
                            [localFileManager removeItemAtPath:filePath error:&error];
                        
                        [imageData writeToFile:filePath atomically:YES];
                        
                        [thumbDoc closeWithCompletionHandler:^(BOOL success) {
                            
                        }];
                    }
                    else
                    {
                        NSLog(@"failed to open %@ from iCloud", fileName);
                    }
                    
                    if (i == (allValues.count-1))
                    {
                        [[SHKActivityIndicator currentIndicator] hide];
                        
                        [self iCloudInstruction:NO];
                    }
                    
                }];
            }
            
            [mydoc closeWithCompletionHandler:^(BOOL success) {
                
            }];
        }
        else
        {
            [[SHKActivityIndicator currentIndicator] hide];
        }
        
    }];
}


#pragma mark -
#pragma mark - Backup Data to iCloud

-(void)saveData
{
    isEmpty = YES;
    
    NSFileManager* localFileManager = [NSFileManager defaultManager];
    NSString* folderDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Library"];
    NSString* plistFolderPath = [folderDir stringByAppendingPathComponent:@"Preferences"];
    NSString* thumbFolderPath = [plistFolderPath stringByAppendingPathComponent:@"CustomThumbnails"];
    
    //Save project settings plist to iCloud
    NSString* plistFileName = [plistFolderPath stringByAppendingPathComponent:@"ProjectSettings.plist"];
    
    BOOL isDirectory = NO;
    BOOL exist = [localFileManager fileExistsAtPath:plistFileName isDirectory:&isDirectory];
    
    if (exist)
    {
        isEmpty = NO;
        
        NSURL *containerUbiquitousURL = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
        NSURL *destinationUbiquitousURL = [[containerUbiquitousURL URLByAppendingPathComponent:@"Documents"] URLByAppendingPathComponent:@"ProjectSettings.plist"];
        
        MyCloudDocument *mydoc = [[MyCloudDocument alloc] initWithFileURL:destinationUbiquitousURL];
        mydoc.dataContent = [NSData dataWithContentsOfFile:plistFileName];
        
        [mydoc saveToURL:[mydoc fileURL] forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success)
         {
             if (success)
             {

             }
             else
             {
                 NSLog(@"Saving failed ProjectSettings.plist to icloud");
             }
         }];
    }

    
    //Save recent color plist to iCloud
    plistFileName = [plistFolderPath stringByAppendingPathComponent:@"RecentColor.plist"];
    
    isDirectory = NO;
    exist = [localFileManager fileExistsAtPath:plistFileName isDirectory:&isDirectory];
    
    if (exist)
    {
        isEmpty = NO;
        
        NSURL *containerUbiquitousURL = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
        NSURL *destinationUbiquitousURL = [[containerUbiquitousURL URLByAppendingPathComponent:@"Documents"] URLByAppendingPathComponent:@"RecentColor.plist"];
        
        MyCloudDocument *mydoc = [[MyCloudDocument alloc] initWithFileURL:destinationUbiquitousURL];
        mydoc.dataContent = [NSData dataWithContentsOfFile:plistFileName];
        
        [mydoc saveToURL:[mydoc fileURL] forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success)
         {
             if (success)
             {
                 
             }
             else
             {
                 NSLog(@"Saving failed RecentColor.plist to icloud");
             }
         }];
    }

    //Save custom video name plist to iCloud
    plistFileName = [plistFolderPath stringByAppendingPathComponent:@"VideoName.plist"];
    
    isDirectory = NO;
    exist = [localFileManager fileExistsAtPath:plistFileName isDirectory:&isDirectory];
    
    if (exist)
    {
        isEmpty = NO;

        NSURL *containerUbiquitousURL = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
        NSURL *destinationUbiquitousURL = [[containerUbiquitousURL URLByAppendingPathComponent:@"Documents"] URLByAppendingPathComponent:@"VideoName.plist"];
        
        MyCloudDocument *mydoc = [[MyCloudDocument alloc] initWithFileURL:destinationUbiquitousURL];
        mydoc.dataContent = [NSData dataWithContentsOfFile:plistFileName];
        
        [mydoc saveToURL:[mydoc fileURL] forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success)
         {
             if (success)
             {
                 
             }
             else
             {
                 NSLog(@"Saving failed VideoName.plist to icloud");
             }
         }];
    }
    
    //Save thumbnail file name plist to iCloud
    plistFileName = [plistFolderPath stringByAppendingPathComponent:@"ThumbFileName.plist"];
    
    isDirectory = NO;
    exist = [localFileManager fileExistsAtPath:plistFileName isDirectory:&isDirectory];

    if (exist)
    {
        isEmpty = NO;

        NSURL *containerUbiquitousURL = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
        NSURL *destinationUbiquitousURL = [[containerUbiquitousURL URLByAppendingPathComponent:@"Documents"] URLByAppendingPathComponent:@"ThumbFileName.plist"];

        MyCloudDocument *mydoc = [[MyCloudDocument alloc] initWithFileURL:destinationUbiquitousURL];
        mydoc.dataContent = [NSData dataWithContentsOfFile:plistFileName];
        
        [mydoc saveToURL:[mydoc fileURL] forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success)
         {
             if (success)
             {
                 
             }
             else
             {
                 NSLog(@"Saving failed ThumbFileName.plist to icloud");
             }
         }];
    }
    
    
    //Save custom thumbnails to iCloud
    isDirectory = NO;
    exist = [localFileManager fileExistsAtPath:thumbFolderPath isDirectory:&isDirectory];
    
    if (exist)
    {
        NSArray* files = [localFileManager contentsOfDirectoryAtPath:thumbFolderPath error:nil];
        
        if (files.count == 0)
        {
            [[SHKActivityIndicator currentIndicator] hide];
            
            NSString* lastUpdatePlistFileName = [plistFolderPath stringByAppendingPathComponent:@"LastUpdate.plist"];
            
            BOOL isDirectory = NO;
            BOOL exist = [localFileManager fileExistsAtPath:lastUpdatePlistFileName isDirectory:&isDirectory];
            
            NSMutableDictionary* lastUpdatePlistDict = nil;
            
            if (!exist)
            {
                [localFileManager createFileAtPath:lastUpdatePlistFileName contents:nil attributes:nil];
                
                lastUpdatePlistDict = [NSMutableDictionary dictionary];
            }
            else
            {
                lastUpdatePlistDict = [[NSMutableDictionary alloc] initWithContentsOfFile:lastUpdatePlistFileName];
            }
            
            NSDate* currentDate = [NSDate date];
            
            [lastUpdatePlistDict setObject:currentDate forKey:@"LastUpdatedDate"];
            [lastUpdatePlistDict writeToFile:lastUpdatePlistFileName atomically:YES];
        }
        
        for (int i=0; i<files.count; i++)
        {
            isEmpty = NO;

            NSString* file = [files objectAtIndex:i];
            NSString* filePath = [thumbFolderPath stringByAppendingPathComponent:file];
            
            NSURL *containerUbiquitousURL = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
            NSURL *destinationUbiquitousURL = [[containerUbiquitousURL URLByAppendingPathComponent:@"Documents"] URLByAppendingPathComponent:[filePath lastPathComponent]];
            
            MyCloudDocument *mydoc = [[MyCloudDocument alloc] initWithFileURL:destinationUbiquitousURL];
            mydoc.dataContent = [NSData dataWithContentsOfFile:filePath];
            
            [mydoc saveToURL:[mydoc fileURL] forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success)
             {
                 if (i == (files.count-1))
                 {
                     [[SHKActivityIndicator currentIndicator] hide];
                     
                     [self iCloudInstruction:YES];
                     
                     NSString* lastUpdatePlistFileName = [plistFolderPath stringByAppendingPathComponent:@"LastUpdate.plist"];
                     
                     BOOL isDirectory = NO;
                     BOOL exist = [localFileManager fileExistsAtPath:lastUpdatePlistFileName isDirectory:&isDirectory];

                     NSMutableDictionary* lastUpdatePlistDict = nil;
                     
                     if (!exist)
                     {
                         [localFileManager createFileAtPath:lastUpdatePlistFileName contents:nil attributes:nil];
                         
                         lastUpdatePlistDict = [NSMutableDictionary dictionary];
                     }
                     else
                     {
                         lastUpdatePlistDict = [[NSMutableDictionary alloc] initWithContentsOfFile:lastUpdatePlistFileName];
                     }
                     
                     NSDate* currentDate = [NSDate date];

                     [lastUpdatePlistDict setObject:currentDate forKey:@"LastUpdatedDate"];
                     [lastUpdatePlistDict writeToFile:lastUpdatePlistFileName atomically:YES];
                 }
                 
                 if (success)
                 {
                     
                 }
                 else
                 {
                     NSLog(@"Saving failed %@ to icloud", file);
                 }
             }];
        }
    }
    else
    {
        [[SHKActivityIndicator currentIndicator] hide];
    }
    
    if (isEmpty)
    {
        [[SHKActivityIndicator currentIndicator] hide];
    }
}

-(void)iCloudInstruction:(BOOL) isBackup
{
    if (isBackup)
    {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Backup Successful!"
                                  message:@""
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        
        [alertView show];
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Restore Successful!"
                                  message:@""
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        
        [alertView show];
    }
}


#pragma mark - 
#pragma mark - Action Project Backup/Restore

-(IBAction)actionBackupProject:(id)sender
{
    NSURL *ubiq = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
    
    if (ubiq)
    {
        if ([self.delegate respondsToSelector:@selector(didBackupProjects)])
        {
            [self.delegate didBackupProjects];
        }
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please login to iCloud first!"  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil, nil];
        [alert show];
    }
}

-(IBAction)actionRestoreProject:(id)sender
{
    NSURL *ubiq = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
    
    if (ubiq)
    {
        if ([self.delegate respondsToSelector:@selector(didRestoreProjects)])
        {
            [self.delegate didRestoreProjects];
        }
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please login to iCloud first!"  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil, nil];
        [alert show];
    }
}


#pragma mark -
#pragma mark - Learn How

-(IBAction)actionLearnHow:(id)sender
{
    NSString* path = @"http://support.apple.com/kb/PH12794";
    NSURL* url = [NSURL URLWithString:path];
    
    [[UIApplication sharedApplication] openURL:url];
}


#pragma mark - 
#pragma mark - Ken Burns

- (IBAction)actionKenBurnsOnOff:(id)sender
{
    if (self.kbSwitch.on)
    {
        isKenBurnsEnabled = YES;
        
        self.kbZoomBtn.hidden = NO;
        self.kbScaleBtn.hidden = NO;

        [UIView animateWithDuration:0.2f animations:^{
            self.kbZoomBtn.alpha = 1.0f;
            self.kbScaleBtn.alpha = 1.0f;
        }];

    }
    else
    {
        isKenBurnsEnabled = NO;
        
        [UIView animateWithDuration:0.2f animations:^{
            self.kbZoomBtn.alpha = 0.0f;
            self.kbScaleBtn.alpha = 0.0f;
        } completion:^(BOOL finished) {
            self.kbZoomBtn.hidden = YES;
            self.kbScaleBtn.hidden = YES;
        }];

    }
    
    [self saveProjectSettingstoPlist];
}

- (IBAction)actionKenBurnsZoom:(id)sender
{
    NSArray *menuItems =
    @[
      [YJLActionMenuItem menuItem:@"Zoom In"
                            image:nil
                           target:self
                           action:@selector(selectZoomIn)],
      
      [YJLActionMenuItem menuItem:@"Zoom Out"
                            image:nil
                           target:self
                           action:@selector(selectZoomOut)],
      ];
    
    CGRect frame = [self convertRect:self.kbZoomBtn.frame toView:self.superview];
    [YJLActionMenu showMenuInView:self.superview
                         fromRect:frame
                        menuItems:menuItems isWhiteBG:NO];

}

-(void) selectZoomIn
{
    gnKBZoomInOutType = KB_IN;
    [self.kbZoomBtn setTitle:@"Zoom In" forState:UIControlStateNormal];
    [self saveProjectSettingstoPlist];
}

-(void) selectZoomOut
{
    gnKBZoomInOutType = KB_OUT;
    [self.kbZoomBtn setTitle:@"Zoom Out" forState:UIControlStateNormal];
    [self saveProjectSettingstoPlist];
}

- (IBAction)actionKenBurnsScale:(id)sender
{
    NSArray *menuItems =
    @[
      [YJLActionMenuItem menuItem:@"1.1x"
                            image:nil
                           target:self
                           action:@selector(changedScale:)
                            index:0],
      
      [YJLActionMenuItem menuItem:@"1.2x"
                            image:nil
                           target:self
                           action:@selector(changedScale:)
                            index:1],
      
      [YJLActionMenuItem menuItem:@"1.3x"
                            image:nil
                           target:self
                           action:@selector(changedScale:)
                            index:2],
      
      [YJLActionMenuItem menuItem:@"1.4x"
                            image:nil
                           target:self
                           action:@selector(changedScale:)
                            index:3],
      
      [YJLActionMenuItem menuItem:@"1.5x"
                            image:nil
                           target:self
                           action:@selector(changedScale:)
                            index:4],
      
      [YJLActionMenuItem menuItem:@"1.6x"
                            image:nil
                           target:self
                           action:@selector(changedScale:)
                            index:5],
      
      [YJLActionMenuItem menuItem:@"1.7x"
                            image:nil
                           target:self
                           action:@selector(changedScale:)
                            index:6],
      
      [YJLActionMenuItem menuItem:@"1.8x"
                            image:nil
                           target:self
                           action:@selector(changedScale:)
                            index:7],
      
      [YJLActionMenuItem menuItem:@"1.9x"
                            image:nil
                           target:self
                           action:@selector(changedScale:)
                            index:8],
      
      [YJLActionMenuItem menuItem:@"2.0x"
                            image:nil
                           target:self
                           action:@selector(changedScale:)
                            index:9],
      
      [YJLActionMenuItem menuItem:@"2.1x"
                            image:nil
                           target:self
                           action:@selector(changedScale:)
                            index:10],
      
      [YJLActionMenuItem menuItem:@"2.2x"
                            image:nil
                           target:self
                           action:@selector(changedScale:)
                            index:11],
      
      [YJLActionMenuItem menuItem:@"2.3x"
                            image:nil
                           target:self
                           action:@selector(changedScale:)
                            index:12],
      
      [YJLActionMenuItem menuItem:@"2.4x"
                            image:nil
                           target:self
                           action:@selector(changedScale:)
                            index:13],
      
      [YJLActionMenuItem menuItem:@"2.5x"
                            image:nil
                           target:self
                           action:@selector(changedScale:)
                            index:14],
      ];
    
    CGRect frame = [self convertRect:self.kbScaleBtn.frame toView:self.superview];
    [YJLActionMenu showMenuInView:self.superview
                         fromRect:frame
                        menuItems:menuItems isWhiteBG:NO];
}

-(void) changedScale:(id) sender
{
    YJLActionMenuItem* menu = (YJLActionMenuItem*) sender;
    int index = menu.index;
    grKBScale = 1.1f + index/10.0f;
    [self.kbScaleBtn setTitle:[NSString stringWithFormat:@"%.1fx", grKBScale] forState:UIControlStateNormal];
    [self saveProjectSettingstoPlist];
}


@end
