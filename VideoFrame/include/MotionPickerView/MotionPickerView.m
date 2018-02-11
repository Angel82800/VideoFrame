//
//  MotionPickerView.m
//  VideoFrame
//
//  Created by Yinjing Li on 7/18/14.
//  Copyright (c) 2014 Yinjing Li. All rights reserved.
//

#import "MotionPickerView.h"
#import <QuartzCore/QuartzCore.h>

@implementation MotionPickerView


-(id) initWithTitle:(NSString*) title
{
    self = [super init];
    
    if (self)
    {
        [super setFrame:CGRectMake(0, 0, 320.0f, 260.0f)];

        _actionToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320.0f, 44.0f)];
        _actionToolbar.barStyle = UIBarStyleDefault;
        
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleDone target:self action:@selector(pickerCancelClicked:)];
        [cancelButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:MYRIADPRO size:18.0f], NSFontAttributeName, [UIColor blackColor], NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];

        UIBarButtonItem *flexSpace1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
        
        UIBarButtonItem *defaultBtn = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStyleDone target:self action:@selector(defaultClicked:)];
        [defaultBtn setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:MYRIADPRO size:18.0f], NSFontAttributeName, [UIColor blackColor], NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];

        UIBarButtonItem *flexSpace2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];

        UIBarButtonItem *applyBtn = [[UIBarButtonItem alloc] initWithTitle:@"Apply" style:UIBarButtonItemStyleDone target:self action:@selector(pickerApplyClicked:)];
        [applyBtn setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:MYRIADPRO size:18.0f], NSFontAttributeName, [UIColor blackColor], NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];

        [_actionToolbar setItems:[NSArray arrayWithObjects:cancelButton, flexSpace1, defaultBtn, flexSpace2, applyBtn, nil] animated:YES];
        
        [self addSubview:_actionToolbar];

        if ([[UIDevice currentDevice].systemVersion floatValue] >= 9.0f)
        {
            self.myPickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 44.0f , 320, 200)];
        }
        else
        {
            self.myPickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 44.0f , 320, 0)];
        }

        [self.myPickerView setShowsSelectionIndicator:YES];
        [self.myPickerView setDelegate:self];
        [self.myPickerView setDataSource:self];
        
        [self addSubview:self.myPickerView];
        
        UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(175.0f, self.myPickerView.bounds.size.height*0.5f - 22.0f, 50.0f, 44.0f)];
        [label setFont:[UIFont fontWithName:MYRIADPRO size:[UIFont systemFontSize]]];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setText:@"%"];
        [label setTextColor:[UIColor grayColor]];
        [self.myPickerView addSubview:label];
        
        [super setFrame:CGRectMake(0, 0, 320.0f, _actionToolbar.frame.size.height + self.myPickerView.frame.size.height)];
    }
    
    return self;
}


-(void) setComponents:(int) value
{
    self.arraysForComponenets = nil;
    
    [self.motionArray removeAllObjects];
    self.motionArray = nil;

    self.motionArray = [[NSMutableArray alloc] init];
    
    int max = 300;  //(value+10) > 301 ? 301 : (value+10);
    int min = 10;   //(value-10)>=10 ? (value-10) : 10;
    
    for (int i=min; i<max; i++)
    {
        [self.motionArray addObject:[NSString stringWithFormat:@"%d", i]];
    }

    [self setArraysForComponenets:[NSArray arrayWithObjects:self.motionArray, nil]];
}

-(void) setMotionValue:(int) motion
{
    NSInteger index = 0;
    
    for (int i=0; i<self.motionArray.count; i++)
    {
        NSString* string = [self.motionArray objectAtIndex:i];
        CGFloat value = [string intValue];
        
        if (value == motion)
        {
            index = i;
            break;
        }
    }
    
    [self setIndexOfMotion:index];
}

-(void) initializePicker
{
    [self.myPickerView selectRow:self.indexOfMotion inComponent:0 animated:YES];
}


#pragma mark -
#pragma mark - Cancel button

-(void) pickerCancelClicked:(UIBarButtonItem*)barButton
{
    if ([self.delegate respondsToSelector:@selector(didCancelMotionPicker)])
        [self.delegate didCancelMotionPicker];
}


#pragma mark -
#pragma mark - apply button

-(void) pickerApplyClicked:(UIBarButtonItem*)barButton
{
    if ([self.delegate respondsToSelector:@selector(motionPickerViewSeleted:)])
    {
        NSInteger index = [self.myPickerView selectedRowInComponent:0];
        
        NSString* str = [self.motionArray objectAtIndex:index];
        CGFloat motion = [str floatValue];
        
        [self.delegate motionPickerViewSeleted:motion];
    }
}

#pragma mark -
#pragma mark - default button

-(void) defaultClicked:(UIBarButtonItem*)barButton
{
    [self.myPickerView selectRow:90 inComponent:0 animated:YES];

    [self.myPickerView reloadAllComponents];
}


#pragma mark -
#pragma mark - UIPickerView

-(NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return [self.arraysForComponenets count];
}

-(NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [[self.arraysForComponenets objectAtIndex:component] count];
}

-(NSString*) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [[self.arraysForComponenets objectAtIndex:component] objectAtIndex:row];
}

-(void) pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    [self.myPickerView reloadAllComponents];
}

-(CGFloat) pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    return ((pickerView.bounds.size.width-20.0f) - 2.0f*(self.arraysForComponenets.count-1))/self.arraysForComponenets.count;
}

-(UIView*) pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel* label = (UILabel*)view;
    
    if (!label)
    {
        label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, pickerView.frame.size.width, 44.0f)];
        // Setup label properties - frame, font, colors etc
        
        float font = 0.0f;
    
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
            font = 15.0f;
        else
            font = 18.0f;
        
        label.lineBreakMode = NSLineBreakByWordWrapping;
        label.font = [UIFont fontWithName:MYRIADPRO size:font];
        label.adjustsFontSizeToFitWidth = YES;
        label.minimumScaleFactor = 0.1f;
        label.numberOfLines = 0;
        label.textAlignment = NSTextAlignmentCenter;
        
        label.text = [[self.arraysForComponenets objectAtIndex:component] objectAtIndex:row];
    }
    
    return label;
}


@end