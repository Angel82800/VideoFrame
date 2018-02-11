//
//  ActionSettingsPickerView.m
//  VideoFrame
//
//  Created by Yinjing Li on 3/6/14.
//  Copyright (c) 2014 Yinjing Li. All rights reserved.
//

#import "ActionSettingsPickerView.h"
#import "Definition.h"

#import <QuartzCore/QuartzCore.h>

@implementation ActionSettingsPickerView


-(id) initWithTitle:(NSString*) title
{
    self = [super init];
    
    if (self)
    {
        [super setFrame:CGRectMake(0, 0, 320, 272)];

        NSString *cancelButtonTitle = @"Cancel";
        NSString* otherButtonTitle = @"Apply";
        
        self.actionToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
        self.actionToolbar.barStyle = UIBarStyleDefault;
        
        if ([title isEqualToString:@""] || title == nil)
        {
            UIView* centerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 130.0f, 44.0f)];
            [centerView setBackgroundColor:[UIColor clearColor]];
            
            self.changeAllBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [self.changeAllBtn setFrame:CGRectMake(0.0f, 9.0f, 26.0f, 26.0f)];
            
            if (isActionChangeAll)
            {
                [self.changeAllBtn setBackgroundImage:[UIImage imageNamed:@"dark_check_on"] forState:UIControlStateNormal];
                [self.changeAllBtn setBackgroundImage:[UIImage imageNamed:@"dark_check_off"] forState:UIControlStateSelected];
                [self.changeAllBtn setBackgroundImage:[UIImage imageNamed:@"dark_check_off"] forState:UIControlStateHighlighted];
                self.changeAllBtn.tag = 2;
            }
            else
            {
                [self.changeAllBtn setBackgroundImage:[UIImage imageNamed:@"dark_check_off"] forState:UIControlStateNormal];
                [self.changeAllBtn setBackgroundImage:[UIImage imageNamed:@"dark_check_on"] forState:UIControlStateSelected];
                [self.changeAllBtn setBackgroundImage:[UIImage imageNamed:@"dark_check_on"] forState:UIControlStateHighlighted];
                self.changeAllBtn.tag = 1;
            }
            
            [self.changeAllBtn addTarget:self action:@selector(actionChangeAll:) forControlEvents:UIControlEventTouchUpInside];
            [centerView addSubview:self.changeAllBtn];
            
            
            self.typeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
            [self.typeBtn setFrame:CGRectMake(30.0f, 5.0f, 100.0f, 34.0f)];
            [self.typeBtn setBackgroundColor:[UIColor clearColor]];
            [self.typeBtn.titleLabel setTextAlignment:NSTextAlignmentCenter];
            [self.typeBtn.titleLabel setAdjustsFontSizeToFitWidth:YES];
            [self.typeBtn.titleLabel setMinimumScaleFactor:0.1f];
            [self.typeBtn.titleLabel setFont:[UIFont fontWithName:MYRIADPRO size:15.0f]];
            [self.typeBtn.titleLabel setNumberOfLines:0];
            [self.typeBtn setTitle:@"CHECK TO CHANGE ALL" forState:UIControlStateNormal];
            [self.typeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [self.typeBtn addTarget:self action:@selector(actionChangeAll:) forControlEvents:UIControlEventTouchUpInside];
            [centerView addSubview:self.typeBtn];
            
            if (isActionChangeAll)
                self.typeBtn.tag = 2;
            else
                self.typeBtn.tag = 1;
            
            
            UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:cancelButtonTitle style:UIBarButtonItemStyleDone target:self action:@selector(pickerCancelClicked:)];
            [cancelButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:MYRIADPRO size:18.0f], NSFontAttributeName, [UIColor blackColor], NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];

            UIBarButtonItem *flexSpace1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
            
            UIBarButtonItem *changeAllButton = [[UIBarButtonItem alloc] initWithCustomView:centerView];
            [changeAllButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:MYRIADPRO size:18.0f], NSFontAttributeName, [UIColor blackColor], NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];

            UIBarButtonItem *flexSpace2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
            
            UIBarButtonItem *applyBtn = [[UIBarButtonItem alloc] initWithTitle:otherButtonTitle style:UIBarButtonItemStyleDone target:self action:@selector(pickerApplyClicked:)];
            [applyBtn setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:MYRIADPRO size:18.0f], NSFontAttributeName, [UIColor blackColor], NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];

            [self.actionToolbar setItems:[NSArray arrayWithObjects:cancelButton, flexSpace1, changeAllButton, flexSpace2, applyBtn, nil] animated:YES];
        }
        else
        {
            UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:cancelButtonTitle style:UIBarButtonItemStyleDone target:self action:@selector(pickerCancelClicked:)];
            [cancelButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:MYRIADPRO size:18.0f], NSFontAttributeName, [UIColor blackColor], NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];

            UIBarButtonItem *flexSpace1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
            
            UIView* centerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 150.0f, 44.0f)];
            [centerView setBackgroundColor:[UIColor clearColor]];
            
            UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 150.0f, 44.0f)];
            [label setFont:[UIFont fontWithName:MYRIADPRO size:18.0f]];
            [label setBackgroundColor:[UIColor clearColor]];
            [label setTextAlignment:NSTextAlignmentCenter];
            [label setAdjustsFontSizeToFitWidth:YES];
            [label setMinimumScaleFactor:0.1f];
            [label setNumberOfLines:1];
            [label setTextColor:[UIColor grayColor]];
            [label setText:title];
            
            [centerView addSubview:label];
            
            
            UIBarButtonItem *lableButton = [[UIBarButtonItem alloc] initWithCustomView:centerView];
            UIBarButtonItem *flexSpace2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
            
            UIBarButtonItem *applyBtn = [[UIBarButtonItem alloc] initWithTitle:otherButtonTitle style:UIBarButtonItemStyleDone target:self action:@selector(pickerApplyClicked:)];
            [applyBtn setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:MYRIADPRO size:18.0f], NSFontAttributeName, [UIColor blackColor], NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];

            [self.actionToolbar setItems:[NSArray arrayWithObjects:cancelButton, flexSpace1, lableButton, flexSpace2, applyBtn, nil] animated:YES];
        }
        
        [self addSubview:self.actionToolbar];
        
        if ([[UIDevice currentDevice].systemVersion floatValue] >= 9.0f)
        {
            self.myPickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 44, 320, 200)];
        }
        else
        {
            self.myPickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 44, 320, 0)];
        }
        
        [self.myPickerView setShowsSelectionIndicator:YES];
        [self.myPickerView setDelegate:self];
        [self.myPickerView setDataSource:self];
        [self addSubview:self.myPickerView];
        
        [super setFrame:CGRectMake(0, 0, 320, self.actionToolbar.frame.size.height + self.myPickerView.frame.size.height)];
    }
    
    return self;
}


-(void) initializePicker
{
    [self.myPickerView selectRow:self.indexOfActionType inComponent:0 animated:YES];
    [self.myPickerView selectRow:self.indexOfActionTime inComponent:1 animated:YES];
}


#pragma mark - Cancel button
-(void) pickerCancelClicked:(UIBarButtonItem*)barButton
{
    if ([self.delegate respondsToSelector:@selector(didCancelActionSettings)])
        [self.delegate didCancelActionSettings];
}

#pragma mark - apply button
-(void) pickerApplyClicked:(UIBarButtonItem*)barButton
{
    if ([self.delegate respondsToSelector:@selector(actionSheetPickerView:didSelectTitles:typeIndex:)])
    {
        NSMutableArray *selectedTitles = [[NSMutableArray alloc] init];

        for (NSInteger component = 0; component<self.myPickerView.numberOfComponents; component++)
        {
            NSInteger row = [self.myPickerView selectedRowInComponent:component];
            
            if (row!= -1)
            {
                [selectedTitles addObject:[[_titlesForComponenets objectAtIndex:component] objectAtIndex:row]];
            }
            else
            {
                [selectedTitles addObject:[NSNull null]];
            }
        }

        NSInteger selectedIndexOfActionType = [self.myPickerView selectedRowInComponent:0];

        [self.delegate actionSheetPickerView:self didSelectTitles:selectedTitles typeIndex:selectedIndexOfActionType];
    }
}


-(CGFloat) pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    if (_widthsForComponents)
    {
        if ([[_widthsForComponents objectAtIndex:component] isKindOfClass:[NSNumber class]])
        {
            CGFloat width = [[_widthsForComponents objectAtIndex:component] floatValue];

            if (width == 0)
                return ((pickerView.bounds.size.width-20)-2*(_titlesForComponenets.count-1))/_titlesForComponenets.count;
            else
                return width;
        }
        else
            return ((pickerView.bounds.size.width-20)-2*(_titlesForComponenets.count-1))/_titlesForComponenets.count;
    }
    else
    {
        return ((pickerView.bounds.size.width-20)-2*(_titlesForComponenets.count-1))/_titlesForComponenets.count;
    }
}

-(NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return [_titlesForComponenets count];
}

-(NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [[_titlesForComponenets objectAtIndex:component] count];
}

-(NSString*) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSInteger selectedIndexOfActionType = [pickerView selectedRowInComponent:0];
    if ((selectedIndexOfActionType == 0)&&(component == 1)&&(row == 0)) {// if selected None, can not set a duration.
        return @"0.00s";
    }

    return [[_titlesForComponenets objectAtIndex:component] objectAtIndex:row];
}

-(void) pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSInteger selectedIndexOfActionType = [pickerView selectedRowInComponent:0];
    if (selectedIndexOfActionType == 0) {// if selected None, can not set a duration.
        [self.myPickerView selectRow:0 inComponent:1 animated:YES];
        [self.myPickerView reloadAllComponents];
        return;
    }

    [self.myPickerView reloadAllComponents];

    if (_isRangePickerView && pickerView.numberOfComponents == 3)
    {
        if (component == 0)
        {
            [pickerView selectRow:MAX([pickerView selectedRowInComponent:2], row) inComponent:2 animated:YES];
        }
        else if (component == 2)
        {
            [pickerView selectRow:MIN([pickerView selectedRowInComponent:0], row) inComponent:0 animated:YES];
        }
    }
}

-(UIView*) pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel* label = (UILabel*)view;
    
    if (!label)
    {
        label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, pickerView.frame.size.width, 44)];
        // Setup label properties - frame, font, colors etc
        
        float font = 0.0f;
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
            font = 15;
        }
        else{
            font = 18;
        }
        
        label.lineBreakMode = NSLineBreakByWordWrapping;
        label.font = [UIFont fontWithName:MYRIADPRO size:font];
        label.adjustsFontSizeToFitWidth = YES;
        label.minimumScaleFactor = 0.1f;
        label.numberOfLines = 0;
        label.textAlignment = NSTextAlignmentCenter;
        
        label.text = [[_titlesForComponenets objectAtIndex:component] objectAtIndex:row];
        
        NSInteger selectedIndexOfActionType = [pickerView selectedRowInComponent:0];
        
        if ((selectedIndexOfActionType == 0)&&(component == 1)&&(row == 0))
        {
            label.text = @"0.00s";
        }
    }
    
    return label;
}

-(void) actionChangeAll:(id) sender
{
    if ([sender tag] == 1)
    {
        [self.changeAllBtn setBackgroundImage:[UIImage imageNamed:@"dark_check_on"] forState:UIControlStateNormal];
        [self.changeAllBtn setBackgroundImage:[UIImage imageNamed:@"dark_check_off"] forState:UIControlStateSelected];
        [self.changeAllBtn setBackgroundImage:[UIImage imageNamed:@"dark_check_off"] forState:UIControlStateHighlighted];
        self.changeAllBtn.tag = 2;
        self.typeBtn.tag = 2;
        
        isActionChangeAll = YES;
    }
    else if ([sender tag] == 2)
    {
        [self.changeAllBtn setBackgroundImage:[UIImage imageNamed:@"dark_check_off"] forState:UIControlStateNormal];
        [self.changeAllBtn setBackgroundImage:[UIImage imageNamed:@"dark_check_on"] forState:UIControlStateSelected];
        [self.changeAllBtn setBackgroundImage:[UIImage imageNamed:@"dark_check_on"] forState:UIControlStateHighlighted];
        self.changeAllBtn.tag = 1;
        self.typeBtn.tag = 1;
        
        isActionChangeAll = NO;
    }
}


@end