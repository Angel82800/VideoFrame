//
//  ShadowView.h
//  VideoFrame
//
//  Created by Yinjing Li on 12/2/14.
//  Copyright (c) 2014 Yinjing Li. All rights reserved.
//


#import "ShapeColorView.h"
#import <QuartzCore/QuartzCore.h>

@implementation ShapeColorView


#pragma mark - init

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        // Initialization code
        
        self.backgroundColor = [UIColor clearColor];
        
        self.shapeOverlayColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
        
        CGFloat rFontSize = 0.0f;
    
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
            rFontSize = 10.0f;
        else
            rFontSize = 14.0f;

        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        {
            //original button
            self.originalBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [self.originalBtn setFrame:CGRectMake(0.0f, 0.0f, self.frame.size.width*0.4f, 35.0f)];
            [self.originalBtn setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
            self.originalBtn.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
            [self.originalBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
            self.originalBtn.backgroundColor = [UIColor clearColor];
            [self setSelectedBackgroundViewFor:self.originalBtn];
            self.originalBtn.layer.masksToBounds = YES;
            [self.originalBtn setTitle:@"ORIGINAL" forState:UIControlStateNormal];
            self.originalBtn.titleLabel.font = [UIFont fontWithName:MYRIADPRO size:rFontSize];
            self.originalBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
            self.originalBtn.titleLabel.minimumScaleFactor = 0.1f;
            self.originalBtn.titleLabel.numberOfLines = 0;
            self.originalBtn.layer.borderColor = [UIColor whiteColor].CGColor;
            self.originalBtn.layer.borderWidth = 1.0f;
            self.originalBtn.layer.cornerRadius = 1.0f;
            [self.originalBtn addTarget:self action:@selector(selectOriginal:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:self.originalBtn];

            //overlay button
            self.overlayBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [self.overlayBtn setFrame:CGRectMake(0.0f, 35.0f, self.frame.size.width*0.4f, 35.0f)];
            [self.overlayBtn setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
            self.overlayBtn.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
            [self.overlayBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
            self.overlayBtn.backgroundColor = [UIColor clearColor];
            [self setSelectedBackgroundViewFor:self.overlayBtn];
            self.overlayBtn.layer.masksToBounds = YES;
            [self.overlayBtn setTitle:@"OVERLAY" forState:UIControlStateNormal];
            self.overlayBtn.titleLabel.font = [UIFont fontWithName:MYRIADPRO size:rFontSize];
            self.overlayBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
            self.overlayBtn.titleLabel.minimumScaleFactor = 0.1f;
            self.overlayBtn.titleLabel.numberOfLines = 0;
            self.overlayBtn.layer.borderColor = [UIColor whiteColor].CGColor;
            self.overlayBtn.layer.borderWidth = 1.0f;
            self.overlayBtn.layer.cornerRadius = 1.0f;
            [self.overlayBtn addTarget:self action:@selector(selectOverlay:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:self.overlayBtn];

            self.overlayColorLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0f, 70.0f, self.frame.size.width-5.0f, 20.0f)];
            self.overlayColorLabel.backgroundColor = [UIColor clearColor];
            self.overlayColorLabel.textAlignment = NSTextAlignmentLeft;
            self.overlayColorLabel.text = @"Color";
            self.overlayColorLabel.font = [UIFont fontWithName:MYRIADPRO size:rFontSize];
            self.overlayColorLabel.adjustsFontSizeToFitWidth = YES;
            self.overlayColorLabel.minimumScaleFactor = 0.1f;
            self.overlayColorLabel.numberOfLines = 0;
            self.overlayColorLabel.textColor = [UIColor whiteColor];
            [self addSubview:self.overlayColorLabel];

            //color picker
            self.overlayColorPickerView = [[KZColorPicker alloc] initWithFrame:CGRectMake(0, self.frame.size.height - (self.frame.size.width - 60), self.frame.size.width, self.frame.size.width - 60)];
            self.overlayColorPickerView.selectedColor = self.shapeOverlayColor;
            self.overlayColorPickerView.oldColor = self.shapeOverlayColor;
            [self.overlayColorPickerView addTarget:self action:@selector(shapeColorPickerChanged:) forControlEvents:UIControlEventValueChanged];
            [self addSubview:self.overlayColorPickerView];
            
            //leftbox view
            self.leftBoxView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height-30, 30, 30)];
            self.leftBoxView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"leftBox"]];
            self.leftBoxView.userInteractionEnabled = YES;
            [self addSubview:self.leftBoxView];
            
            UIPanGestureRecognizer* moveGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(shapeColorMenuMove:)];
            [moveGesture setMinimumNumberOfTouches:1];
            [moveGesture setMaximumNumberOfTouches:1];
            moveGesture.delegate = self;
            [self.leftBoxView addGestureRecognizer:moveGesture];
        }
        else
        {
            //orginal button
            self.originalBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [self.originalBtn setFrame:CGRectMake(0.0f, 0.0f, self.frame.size.width*0.4f, 57.5f)];
            [self.originalBtn setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
            self.originalBtn.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
            [self.originalBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
            self.originalBtn.backgroundColor = [UIColor clearColor];
            [self setSelectedBackgroundViewFor:self.originalBtn];
            self.originalBtn.layer.masksToBounds = YES;
            [self.originalBtn setTitle:@"ORIGINAL" forState:UIControlStateNormal];
            self.originalBtn.titleLabel.font = [UIFont fontWithName:MYRIADPRO size:rFontSize];
            self.originalBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
            self.originalBtn.titleLabel.minimumScaleFactor = 0.1f;
            self.originalBtn.titleLabel.numberOfLines = 0;
            self.originalBtn.layer.borderColor = [UIColor whiteColor].CGColor;
            self.originalBtn.layer.borderWidth = 1.0f;
            self.originalBtn.layer.cornerRadius = 1.0f;
            [self.originalBtn addTarget:self action:@selector(selectOriginal:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:self.originalBtn];
            
            //overlay button
            self.overlayBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [self.overlayBtn setFrame:CGRectMake(0.0f, 57.5f, self.frame.size.width*0.4f, 57.5f)];
            [self.overlayBtn setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
            self.overlayBtn.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
            [self.overlayBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
            self.overlayBtn.backgroundColor = [UIColor clearColor];
            [self setSelectedBackgroundViewFor:self.overlayBtn];
            self.overlayBtn.layer.masksToBounds = YES;
            [self.overlayBtn setTitle:@"OVERLAY" forState:UIControlStateNormal];
            self.overlayBtn.titleLabel.font = [UIFont fontWithName:MYRIADPRO size:rFontSize];
            self.overlayBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
            self.overlayBtn.titleLabel.minimumScaleFactor = 0.1f;
            self.overlayBtn.titleLabel.numberOfLines = 0;
            self.overlayBtn.layer.borderColor = [UIColor whiteColor].CGColor;
            self.overlayBtn.layer.borderWidth = 1.0f;
            self.overlayBtn.layer.cornerRadius = 1.0f;
            [self.overlayBtn addTarget:self action:@selector(selectOverlay:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:self.overlayBtn];

            //overlay color
            self.overlayColorLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0f, 115.0f, self.frame.size.width-5.0f, 20.0f)];
            self.overlayColorLabel.backgroundColor = [UIColor clearColor];
            self.overlayColorLabel.textAlignment = NSTextAlignmentLeft;
            self.overlayColorLabel.text = @"Color";
            self.overlayColorLabel.font = [UIFont fontWithName:MYRIADPRO size:rFontSize];
            self.overlayColorLabel.adjustsFontSizeToFitWidth = YES;
            self.overlayColorLabel.minimumScaleFactor = 0.1f;
            self.overlayColorLabel.numberOfLines = 0;
            self.overlayColorLabel.textColor = [UIColor whiteColor];
            [self addSubview:self.overlayColorLabel];
            
            //color picker
            self.overlayColorPickerView = [[KZColorPicker alloc] initWithFrame:CGRectMake(0, self.frame.size.height - (self.frame.size.width - 70), self.frame.size.width, self.frame.size.width - 70)];
            self.overlayColorPickerView.selectedColor = self.shapeOverlayColor;
            self.overlayColorPickerView.oldColor = self.shapeOverlayColor;
            [self.overlayColorPickerView addTarget:self action:@selector(shapeColorPickerChanged:) forControlEvents:UIControlEventValueChanged];
            [self addSubview:self.overlayColorPickerView];
            
            //leftbox view
            self.leftBoxView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height-40, 40, 40)];
            self.leftBoxView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"leftBox"]];
            self.leftBoxView.userInteractionEnabled = YES;
            [self addSubview:self.leftBoxView];
            
            UIPanGestureRecognizer* moveGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(shapeColorMenuMove:)];
            [moveGesture setMinimumNumberOfTouches:1];
            [moveGesture setMaximumNumberOfTouches:1];
            moveGesture.delegate = self;
            [self.leftBoxView addGestureRecognizer:moveGesture];
       }
        
        UIView* lineView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, self.overlayBtn.frame.origin.y+self.overlayBtn.frame.size.height, self.frame.size.width, 1.0f)];
        lineView.backgroundColor = [UIColor whiteColor];
        [self addSubview:lineView];

        CGFloat originY = 20.0f;
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
            originY = 15.0f;
        
        //color preview
        self.colorPreviewView = [[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width*0.4f + 5.0f, 5.0f, self.frame.size.width*0.2f, originY)];
        self.colorPreviewView.backgroundColor = [UIColor whiteColor];
        self.colorPreviewView.userInteractionEnabled = YES;
        [self addSubview:self.colorPreviewView];
        
        UITapGestureRecognizer *selectGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionColorPreviewToRecent:)];
        selectGesture.delegate = self;
        [self.colorPreviewView addGestureRecognizer:selectGesture];
        [selectGesture setNumberOfTapsRequired:1];
        
        self.addLabel = [[UILabel alloc] initWithFrame:self.colorPreviewView.bounds];
        self.addLabel.backgroundColor = [UIColor clearColor];
        self.addLabel.text = @"+";
        self.addLabel.font = [UIFont fontWithName:MYRIADPRO size:rFontSize*1.2f];
        self.addLabel.adjustsFontSizeToFitWidth = YES;
        self.addLabel.minimumScaleFactor = 0.1f;
        self.addLabel.textAlignment = NSTextAlignmentCenter;
        self.addLabel.textColor = [UIColor whiteColor];
        self.addLabel.layer.shadowColor = [UIColor blackColor].CGColor;
        self.addLabel.layer.shadowOffset = CGSizeMake(0.5f, 0.5f);
        self.addLabel.layer.shadowOpacity = 1.0f;
        [self.colorPreviewView addSubview:self.addLabel];
        
        self.xLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.colorPreviewView.frame.origin.x + self.colorPreviewView.frame.size.width + 5.0f, 5.0f, 10.0f, originY)];
        self.xLabel.backgroundColor = [UIColor whiteColor];
        self.xLabel.text = @"#";
        self.xLabel.font = [UIFont fontWithName:MYRIADPRO size:rFontSize*1.2f];
        self.xLabel.adjustsFontSizeToFitWidth = YES;
        self.xLabel.minimumScaleFactor = 0.1f;
        self.xLabel.textAlignment = NSTextAlignmentRight;
        self.xLabel.textColor = [UIColor blackColor];
        [self addSubview:self.xLabel];
        
        self.hexTextField = [[UITextField alloc] initWithFrame:CGRectMake(self.xLabel.frame.origin.x + self.xLabel.frame.size.width, 5.0f, self.frame.size.width - (self.xLabel.frame.origin.x + self.xLabel.frame.size.width) - 5.0f, originY)];
        self.hexTextField.backgroundColor = [UIColor whiteColor];
        self.hexTextField.text = @"FFFFFF";
        self.hexTextField.font = [UIFont fontWithName:MYRIADPRO size:rFontSize*1.2f];
        self.hexTextField.adjustsFontSizeToFitWidth = YES;
        self.hexTextField.textAlignment = NSTextAlignmentLeft;
        self.hexTextField.textColor = [UIColor blackColor];
        self.hexTextField.keyboardAppearance = UIKeyboardAppearanceDark;
        self.hexTextField.delegate = self;
        [self addSubview:self.hexTextField];
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        {
            [self setIPhoneKeyboard:[[BSKeyboardControls alloc] initWithFields:@[self.hexTextField,]]];
            [self.iPhoneKeyboard setDelegate:self];
        }
        
        UILabel* recentTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width*0.4f + 5.0f, 10.0f + originY, self.frame.size.width*0.2f, 10.0f)];
        recentTitleLabel.backgroundColor = [UIColor clearColor];
        recentTitleLabel.text = @"Recent";
        recentTitleLabel.textColor = [UIColor whiteColor];
        recentTitleLabel.font = [UIFont fontWithName:MYRIADPRO size:10.0f];
        recentTitleLabel.adjustsFontSizeToFitWidth = YES;
        recentTitleLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:recentTitleLabel];
        
        self.recentColorScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(self.frame.size.width*0.4f + 5.0f, 20.0f + originY, self.frame.size.width*0.6f - 10.0f, lineView.frame.origin.y - (22.0f + originY))];
        self.recentColorScrollView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.recentColorScrollView];
        self.recentColorScrollView.delegate = self;
        self.recentColorScrollView.scrollEnabled = YES;
        self.recentColorScrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
        
        [self updateRecentColorScrollView];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
        tapGesture.delegate = self;
        [self addGestureRecognizer:tapGesture];
        [tapGesture setNumberOfTapsRequired:1];
    }
    
    return self;
}

- (void) initialize
{
    [self.overlayColorPickerView setOldColor:self.shapeOverlayColor];
    [self.overlayColorPickerView setSelectedColor:self.shapeOverlayColor];
    
    if (self.shapeOverlayStyle == 1)
    {
        [self.originalBtn setBackgroundColor:UIColorFromRGB(0x9da1a0)];
        [self.overlayBtn setBackgroundColor:[UIColor clearColor]];
    }
    else if (self.shapeOverlayStyle == 2)
    {
        [self.originalBtn setBackgroundColor:[UIColor clearColor]];
        [self.overlayBtn setBackgroundColor:UIColorFromRGB(0x9da1a0)];
    }
    
    self.colorPreviewView.backgroundColor = self.shapeOverlayColor;
    
    NSString* hexString = [self.shapeOverlayColor hexStringFromColor];
    self.hexTextField.text = [hexString uppercaseString];
    
    [self updateRecentColorScrollView];
}

- (void) setSelectedBackgroundViewFor:(UIButton *) button
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(button.bounds.size.width, button.bounds.size.height), NO, 0.0);
    [UIColorFromRGB(0x9da1a0) set];
    CGContextFillRect(UIGraphicsGetCurrentContext(), CGRectMake(0.5f, 0.5f, button.bounds.size.width - 0.5f, button.bounds.size.height - 0.5f));
    UIImage* resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    [button setBackgroundImage:resultImage forState:UIControlStateHighlighted];
    [button setBackgroundImage:resultImage forState:UIControlStateSelected|UIControlStateHighlighted];
}

- (void)shapeColorMenuMove:(UIPanGestureRecognizer *)gestureRecognizer
{
    CGPoint translatedPoint = [gestureRecognizer translationInView:self.superview];
    
    if([gestureRecognizer state] == UIGestureRecognizerStateBegan)
    {
        firstX = self.superview.center.x;
        firstY = self.superview.center.y;
    }
    
    translatedPoint = CGPointMake(firstX+translatedPoint.x, firstY+translatedPoint.y);
    [self.superview setCenter:translatedPoint];
}


#pragma mark -
#pragma mark - ColorPicker Changed

- (void) shapeColorPickerChanged:(KZColorPicker *)cp
{
    self.shapeOverlayColor = cp.selectedColor;
    self.leftBoxView.backgroundColor = [UIColor colorWithPatternImage:[[UIImage imageNamed:@"leftBox"] imageWithOverlayColor:self.shapeOverlayColor]];
    self.colorPreviewView.backgroundColor = self.shapeOverlayColor;

    NSString* hexString = [self.shapeOverlayColor hexStringFromColor];
    self.hexTextField.text = [hexString uppercaseString];

    [self changeShapeOverlayColor];
    [self deleteDesabled];
}


#pragma mark -
#pragma mark - selected No Shadow

- (void) selectOriginal:(id) sender
{
    self.shapeOverlayStyle = 1;
    [self.originalBtn setBackgroundColor:UIColorFromRGB(0x9da1a0)];
    [self.overlayBtn setBackgroundColor:[UIColor clearColor]];
    [self changeShapeOverlayColor];
}


#pragma mark -
#pragma mark - selected Shadow

- (void) selectOverlay:(id) sender
{
    self.shapeOverlayStyle = 2;
    [self.originalBtn setBackgroundColor:[UIColor clearColor]];
    [self.overlayBtn setBackgroundColor:UIColorFromRGB(0x9da1a0)];
    [self changeShapeOverlayColor];
}

- (void) changeShapeOverlayColor
{
    if ([self.delegate respondsToSelector:@selector(changeShapeColor:style:)])
    {
        [self.delegate changeShapeColor:self.shapeOverlayColor style:self.shapeOverlayStyle];
    }
}


#pragma mark -
#pragma mark - BSKeyboardControls Delegate

- (void)keyboardControlsDonePressed:(BSKeyboardControls *)keyboardControls
{
    [self.hexTextField resignFirstResponder];
}


#pragma mark -
#pragma mark - UITextField Delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    textField.text = [textField.text uppercaseString];
    
    self.shapeOverlayColor = [UIColor colorWithHexString:textField.text];
    [self.overlayColorPickerView setOldColor:self.shapeOverlayColor];
    [self.overlayColorPickerView setSelectedColor:self.shapeOverlayColor];
    self.leftBoxView.backgroundColor = [UIColor colorWithPatternImage:[[UIImage imageNamed:@"leftBox"] imageWithOverlayColor:self.shapeOverlayColor]];
    self.colorPreviewView.backgroundColor = self.shapeOverlayColor;
    
    NSString* hexString = [self.shapeOverlayColor hexStringFromColor];
    self.hexTextField.text = [hexString uppercaseString];
    
    [self changeShapeOverlayColor];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string length] == 0)
        return YES;
    
    if (range.location >= 8)
        return NO;
    
    string = [string uppercaseString];
    
    //compare string with A-F, 0-9
    NSCharacterSet* myCharSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789ABCDEF"];
    
    for (int i=0; i<[string length]; i++)
    {
        unichar c = [string characterAtIndex:i];
        
        if ([myCharSet characterIsMember:c])
            return YES;
    }
    
    return NO;
}


#pragma mark -
#pragma mark - Action Tap Color Preview to Add Recent

- (void) actionColorPreviewToRecent:(UITapGestureRecognizer*) recognizer
{
    [self saveCurrentColorToRecent];
    [self updateRecentColorScrollView];
}


#pragma mark - Save color to Recent

-(void) saveCurrentColorToRecent
{
    //get hex string
    NSString* hexString = [self.shapeOverlayColor hexStringFromColor];
    hexString = [hexString uppercaseString];
    
    //if current hex string is exist on recent color array, then return. else if then add current hex string to recent color array
    for (int i=0; i<gaRecentColorArray.count; i++)
    {
        NSString* recentString = [gaRecentColorArray objectAtIndex:i];
        
        if ([hexString isEqualToString:recentString])
            return;
    }
    
    [gaRecentColorArray addObject:hexString];
    
    //Save hex color string to plist
    NSFileManager *localFileManager = [NSFileManager defaultManager];
    NSString *folderDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Library"];
    NSString *folderPath = [folderDir stringByAppendingPathComponent:@"Preferences"];
    NSError *error;
    
    NSString* plistFileName = [folderPath stringByAppendingPathComponent:@"RecentColor.plist"];
    
    if (![localFileManager fileExistsAtPath:plistFileName])
        [localFileManager removeItemAtPath:plistFileName error:&error ];
    [localFileManager createFileAtPath:plistFileName contents:nil attributes:nil];
    
    NSMutableDictionary *plistDict = [NSMutableDictionary dictionary];
    
    [plistDict setObject:[NSNumber numberWithInt:(int)gaRecentColorArray.count] forKey:@"RecentColorCount"];
    
    for (int i=0; i<gaRecentColorArray.count; i++)
    {
        NSString* recentString = [gaRecentColorArray objectAtIndex:i];
        
        [plistDict setObject:recentString forKey:[NSString stringWithFormat:@"%d-RecentColorString", i]];
    }
    
    [plistDict writeToFile:plistFileName atomically:YES];
}

-(void) updateRecentColorScrollView
{
    for (RecentColorView* view in self.recentColorScrollView.subviews)
    {
        if (view.tag > 0)
            [view removeFromSuperview];
    }
    
    CGFloat width = (self.recentColorScrollView.frame.size.width - 7.0f)/6.0f;
    CGFloat height = (self.recentColorScrollView.frame.size.height - 5.0f)/4.0f;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        height = height*2.0f;
    
    for (int i=0; i<gaRecentColorArray.count; i++)
    {
        NSString* colorString = [gaRecentColorArray objectAtIndex:i];
        
        RecentColorView* recentView = [[RecentColorView alloc] initWithFrame:CGRectMake(1.0f + (width+1.0f)*(i%6), 1.0f + (height+1.0f)*(i/6), width, height) index:i+1 string:colorString];
        recentView.delegate = self;
        [self.recentColorScrollView addSubview:recentView];
    }
    
    [self.recentColorScrollView setContentSize:CGSizeMake(self.recentColorScrollView.bounds.size.width, 1.0f + (height+1.0f)*(gaRecentColorArray.count/6 + 1))];
}


#pragma mark -
#pragma mark - RecentColorViewDelegate

-(void) selectColor:(NSInteger) colorIndex
{
    NSString* colorString = [gaRecentColorArray objectAtIndex:colorIndex-1];
    
    self.shapeOverlayColor = [UIColor colorWithHexString:colorString];
    self.leftBoxView.backgroundColor = [UIColor colorWithPatternImage:[[UIImage imageNamed:@"leftBox"] imageWithOverlayColor:self.shapeOverlayColor]];
    self.colorPreviewView.backgroundColor = self.shapeOverlayColor;
    [self.overlayColorPickerView setOldColor:self.shapeOverlayColor];
    [self.overlayColorPickerView setSelectedColor:self.shapeOverlayColor];
    
    self.hexTextField.text = colorString;
    
    [self changeShapeOverlayColor];
}

-(void) deleteColor:(NSInteger) colorIndex
{
    [gaRecentColorArray removeObjectAtIndex:(colorIndex-1)];
    
    [self updateRecentColorScrollView];
    
    for (RecentColorView* view in self.recentColorScrollView.subviews)
    {
        if (view.tag > 0)
            view.deleteBtn.hidden = NO;
    }
}

-(void) deleteColorEnabled
{
    for (RecentColorView* view in self.recentColorScrollView.subviews)
    {
        if (view.tag > 0)
            view.deleteBtn.hidden = NO;
    }
}

-(void) deleteDesabled
{
    for (RecentColorView* view in self.recentColorScrollView.subviews)
    {
        if (view.tag > 0)
            view.deleteBtn.hidden = YES;
    }
}

-(void) tapGesture:(UITapGestureRecognizer*) gesture
{
    [self deleteDesabled];
}


@end