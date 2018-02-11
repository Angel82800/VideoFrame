//
//  KBSettingsView.m
//  VideoFrame
//
//  Created by Yinjing Li on 9/30/14.
//  Copyright (c) 2014 Yinjing Li. All rights reserved.
//

#import "KBSettingsView.h"
#import "Definition.h"
#import "YJLActionMenu.h"


@implementation KBSettingsView

@synthesize delegate = _delegate;
@synthesize kbStatusLabel = _kbStatusLabel;
@synthesize kbZoomBtn = _kbZoomBtn;
@synthesize kbPreviewBtn = _kbPreviewBtn;
@synthesize kbApplyBtn = _kbApplyBtn;
@synthesize kbSwitch = _kbSwitch;
@synthesize kbScaleBtn = _kbScaleBtn;
@synthesize kbZoomLabel = _kbZoomLabel;
@synthesize kbScaleLabel = _kbScaleLabel;

-(void) awakeFromNib
{
    mbKbEnabled = NO;
    mnKbIn = KB_IN;
    mfKbScale = 1.1f;
    
    self.kbZoomBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    self.kbZoomBtn.layer.borderWidth = 1.0f;
    self.kbZoomBtn.layer.cornerRadius = 2.0f;
    
    self.kbScaleBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    self.kbScaleBtn.layer.borderWidth = 1.0f;
    self.kbScaleBtn.layer.cornerRadius = 2.0f;

    self.kbPreviewBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    self.kbPreviewBtn.layer.borderWidth = 1.0f;
    self.kbPreviewBtn.layer.cornerRadius = 2.0f;
    self.kbPreviewBtn.tag = 1;

    self.kbApplyBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    self.kbApplyBtn.layer.borderWidth = 1.0f;
    self.kbApplyBtn.layer.cornerRadius = 2.0f;
    [super awakeFromNib];
}


#pragma mark - 
#pragma mark - Set Params

-(void) setKbEnabled:(BOOL) enabled
{
    mbKbEnabled = enabled;
    self.kbSwitch.on = mbKbEnabled;
    
    if (mbKbEnabled)
    {
        self.kbStatusLabel.text = @"Enabled";
        self.kbZoomBtn.enabled = YES;
        self.kbScaleBtn.enabled = YES;
        self.kbPreviewBtn.enabled = YES;
        self.kbZoomBtn.alpha = 1.0f;
        self.kbScaleBtn.alpha = 1.0f;
        self.kbPreviewBtn.alpha = 1.0f;
    }
    else
    {
        self.kbStatusLabel.text = @"Disabled";
        self.kbZoomBtn.enabled = NO;
        self.kbScaleBtn.enabled = NO;
        self.kbPreviewBtn.enabled = NO;
        self.kbZoomBtn.alpha = 0.5f;
        self.kbScaleBtn.alpha = 0.5f;
        self.kbPreviewBtn.alpha = 0.5f;
    }
}

-(void) setKbIn:(NSInteger) inOut
{
    mnKbIn = inOut;
    
    NSString* inString = @"In";
    
    if (mnKbIn == KB_IN)
        inString = @"In";
    else
        inString = @"Out";
    
    [self.kbZoomBtn setTitle:inString forState:UIControlStateNormal];
}

-(void) setKbScale:(CGFloat) scale
{
    mfKbScale = scale;
    
    [self.kbScaleBtn setTitle:[NSString stringWithFormat:@"%.1fx", mfKbScale] forState:UIControlStateNormal];
}


#pragma mark -
#pragma mark - Actions

-(IBAction)actionCheckToAll:(id)sender
{
    isKenBurnsChangeAll = !isKenBurnsChangeAll;
    
    if (isKenBurnsChangeAll)
    {
        [self.kbCheckToAllBtn setBackgroundImage:[UIImage imageNamed:@"dark_check_on"] forState:UIControlStateNormal];
        [self.kbCheckToAllBtn setBackgroundImage:[UIImage imageNamed:@"dark_check_off"] forState:UIControlStateSelected];
        [self.kbCheckToAllBtn setBackgroundImage:[UIImage imageNamed:@"dark_check_off"] forState:UIControlStateHighlighted];
    }
    else
    {
        [self.kbCheckToAllBtn setBackgroundImage:[UIImage imageNamed:@"dark_check_off"] forState:UIControlStateNormal];
        [self.kbCheckToAllBtn setBackgroundImage:[UIImage imageNamed:@"dark_check_on"] forState:UIControlStateSelected];
        [self.kbCheckToAllBtn setBackgroundImage:[UIImage imageNamed:@"dark_check_on"] forState:UIControlStateHighlighted];
    }
}

-(IBAction)actionChangedSwitch:(id)sender
{
    mbKbEnabled = self.kbSwitch.on;
    
    if (mbKbEnabled)
    {
        self.kbStatusLabel.text = @"Enabled";
        self.kbZoomBtn.enabled = YES;
        self.kbScaleBtn.enabled = YES;
        self.kbPreviewBtn.enabled = YES;
        self.kbZoomBtn.alpha = 1.0f;
        self.kbScaleBtn.alpha = 1.0f;
        self.kbPreviewBtn.alpha = 1.0f;
    }
    else
    {
        self.kbStatusLabel.text = @"Disabled";
        self.kbZoomBtn.enabled = NO;
        self.kbScaleBtn.enabled = NO;
        self.kbPreviewBtn.enabled = NO;
        self.kbZoomBtn.alpha = 0.5f;
        self.kbScaleBtn.alpha = 0.5f;
        self.kbPreviewBtn.alpha = 0.5f;
    }
}

-(IBAction)actionZoomBtn:(id)sender
{
    NSArray *menuItems =
    @[
      [YJLActionMenuItem menuItem:@"Zoom In"
                            image:nil
                           target:self
                           action:@selector(didSelectZoomIn)],
      
      [YJLActionMenuItem menuItem:@"Zoom Out"
                            image:nil
                           target:self
                           action:@selector(didSelectZoomOut)],
      ];
    
    CGRect frame = [self convertRect:self.kbZoomBtn.frame toView:self.superview];
    [YJLActionMenu showMenuInView:self.superview
                         fromRect:frame
                        menuItems:menuItems isWhiteBG:NO];
}

-(IBAction)actionScaleBtn:(id)sender
{
    NSArray *menuItems =
    @[
      [YJLActionMenuItem menuItem:@"1.1x"
                            image:nil
                           target:self
                           action:@selector(didScale:)
                            index:0],
      
      [YJLActionMenuItem menuItem:@"1.2x"
                            image:nil
                           target:self
                           action:@selector(didScale:)
                            index:1],
      
      [YJLActionMenuItem menuItem:@"1.3x"
                            image:nil
                           target:self
                           action:@selector(didScale:)
                            index:2],
      
      [YJLActionMenuItem menuItem:@"1.4x"
                            image:nil
                           target:self
                           action:@selector(didScale:)
                            index:3],
      
      [YJLActionMenuItem menuItem:@"1.5x"
                            image:nil
                           target:self
                           action:@selector(didScale:)
                            index:4],
      
      [YJLActionMenuItem menuItem:@"1.6x"
                            image:nil
                           target:self
                           action:@selector(didScale:)
                            index:5],

      [YJLActionMenuItem menuItem:@"1.7x"
                            image:nil
                           target:self
                           action:@selector(didScale:)
                            index:6],

      [YJLActionMenuItem menuItem:@"1.8x"
                            image:nil
                           target:self
                           action:@selector(didScale:)
                            index:7],

      [YJLActionMenuItem menuItem:@"1.9x"
                            image:nil
                           target:self
                           action:@selector(didScale:)
                            index:8],

      [YJLActionMenuItem menuItem:@"2.0x"
                            image:nil
                           target:self
                           action:@selector(didScale:)
                            index:9],

      [YJLActionMenuItem menuItem:@"2.1x"
                            image:nil
                           target:self
                           action:@selector(didScale:)
                            index:10],

      [YJLActionMenuItem menuItem:@"2.2x"
                            image:nil
                           target:self
                           action:@selector(didScale:)
                            index:11],

      [YJLActionMenuItem menuItem:@"2.3x"
                            image:nil
                           target:self
                           action:@selector(didScale:)
                            index:12],

      [YJLActionMenuItem menuItem:@"2.4x"
                            image:nil
                           target:self
                           action:@selector(didScale:)
                            index:13],

      [YJLActionMenuItem menuItem:@"2.5x"
                            image:nil
                           target:self
                           action:@selector(didScale:)
                            index:14],
      ];
    
    CGRect frame = [self convertRect:self.kbScaleBtn.frame toView:self.superview];
    [YJLActionMenu showMenuInView:self.superview
                         fromRect:frame
                        menuItems:menuItems isWhiteBG:NO];
}

-(IBAction)actionPreviewBtn:(id)sender
{
    if (self.kbPreviewBtn.tag == 1)
    {
        if ([self.delegate respondsToSelector:@selector(didPreviewKBSettingsView:inOut:scale:)])
        {
            [self.delegate didPreviewKBSettingsView:mbKbEnabled inOut:mnKbIn scale:mfKbScale];
        }

        self.kbPreviewBtn.tag = 2;
        [self.kbPreviewBtn setTitle:@"Stop" forState:UIControlStateNormal];
    }
    else if (self.kbPreviewBtn.tag == 2)
    {
        if ([self.delegate respondsToSelector:@selector(didStopPreview)])
        {
            [self.delegate didStopPreview];
        }
        
        self.kbPreviewBtn.tag = 1;
        [self.kbPreviewBtn setTitle:@"Preview" forState:UIControlStateNormal];
    }
}

-(IBAction)actionApplyBtn:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(didApplyKBSettingsView:inOut:scale:)])
    {
        [self.delegate didApplyKBSettingsView:mbKbEnabled inOut:mnKbIn scale:mfKbScale];
    }
}


#pragma mark -
#pragma mark - Ken Burns In/Out type

-(void) didSelectZoomIn
{
    mnKbIn = KB_IN;
    
    [self.kbZoomBtn setTitle:@"In" forState:UIControlStateNormal];
}

-(void) didSelectZoomOut
{
    mnKbIn = KB_OUT;
    
    [self.kbZoomBtn setTitle:@"Out" forState:UIControlStateNormal];
}


#pragma mark -
#pragma mark - Ken Burns Scale

-(void) didScale:(id) sender
{
    YJLActionMenuItem* menu = (YJLActionMenuItem*) sender;

    int index = menu.index;
    
    mfKbScale = 1.1f + index/10.0f;

    [self.kbScaleBtn setTitle:[NSString stringWithFormat:@"%.1fx", mfKbScale] forState:UIControlStateNormal];
}


@end
