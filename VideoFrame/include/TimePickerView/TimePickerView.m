//
//  TimePickerView.m
//  VideoFrame
//
//  Created by Yinjing Li on 7/18/14.
//  Copyright (c) 2014 Yinjing Li. All rights reserved.
//

#import "TimePickerView.h"
#import <QuartzCore/QuartzCore.h>

@implementation TimePickerView


@synthesize delegate;


-(id) initWithTitle:(NSString*) title
{
    self = [super init];
    
    if (self)
    {
        [super setFrame:CGRectMake(0, 0, 320.0f, 320.0f)];
        
        _actionToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320.0f, 44.0f)];
        _actionToolbar.barStyle = UIBarStyleDefault;
        
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleDone target:self action:@selector(pickerCancelClicked:)];
        [cancelButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:MYRIADPRO size:18.0f], NSFontAttributeName, [UIColor blackColor], NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];

        UIBarButtonItem *flexSpace1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
        
        UIBarButtonItem *defaultBtn;
        
        if (([title isEqualToString:@"Video Duration"])||([title isEqualToString:@"Ken Burns Duration"]))
        {
            defaultBtn = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStyleDone target:self action:nil];
        }
        else
        {
            defaultBtn = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStyleDone target:self action:@selector(defaultClicked:)];
        }
        
        [defaultBtn setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:MYRIADPRO size:18.0f], NSFontAttributeName, [UIColor blackColor], NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];


        UIBarButtonItem *flexSpace2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];

        UIBarButtonItem *applyBtn = [[UIBarButtonItem alloc] initWithTitle:@"Apply" style:UIBarButtonItemStyleDone target:self action:@selector(pickerApplyClicked:)];
        
        [applyBtn setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:MYRIADPRO size:18.0f], NSFontAttributeName, [UIColor blackColor], NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];

        [_actionToolbar setItems:[NSArray arrayWithObjects:cancelButton, flexSpace1, defaultBtn, flexSpace2, applyBtn, nil] animated:YES];
        [self addSubview:_actionToolbar];

        
        if ([[UIDevice currentDevice].systemVersion floatValue] >= 9.0f)
        {
            self.myPickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 44, 320, 200)];
        }
        else
        {
            self.myPickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 44 , 320, 0)];
        }

        self.myPickerView.backgroundColor = [UIColor whiteColor];
        [self.myPickerView setShowsSelectionIndicator:YES];
        [self.myPickerView setDelegate:self];
        [self.myPickerView setDataSource:self];
        [self addSubview:self.myPickerView];
        
        UILabel* mmLabel = [[UILabel alloc] initWithFrame:CGRectMake(70.0f, self.myPickerView.bounds.size.height*0.5f - 23.0f, 50.0f, 44.0f)];
        [mmLabel setBackgroundColor:[UIColor clearColor]];
        [mmLabel setFont:[UIFont fontWithName:MYRIADPRO size:18.0f]];
        [mmLabel setText:@"min"];
        [mmLabel setTextColor:[UIColor grayColor]];
        [self.myPickerView addSubview:mmLabel];
        
        UILabel* ssLabel = [[UILabel alloc] initWithFrame:CGRectMake(172.5f, self.myPickerView.bounds.size.height*0.5f - 23.0f, 50.0f, 44.0f)];
        [ssLabel setBackgroundColor:[UIColor clearColor]];
        [ssLabel setFont:[UIFont fontWithName:MYRIADPRO size:18.0f]];
        [ssLabel setText:@"sec"];
        [ssLabel setTextColor:[UIColor grayColor]];
        [self.myPickerView addSubview:ssLabel];
        
        UILabel* fffLabel = [[UILabel alloc] initWithFrame:CGRectMake(281.5f, self.myPickerView.bounds.size.height*0.5f - 23.0f, 50.0f, 44.0f)];
        [fffLabel setBackgroundColor:[UIColor clearColor]];
        [fffLabel setFont:[UIFont fontWithName:MYRIADPRO size:18.0f]];
        [fffLabel setText:@"ms"];
        [fffLabel setTextColor:[UIColor grayColor]];
        [self.myPickerView addSubview:fffLabel];
        
        [super setFrame:CGRectMake(0, 0, 320.0f, _actionToolbar.frame.size.height + self.myPickerView.frame.size.height)];
    }
    
    return self;
}


-(void) setComponents
{
    self.arraysForComponenets = nil;
    
    [self.minuteArray removeAllObjects];
    self.minuteArray = nil;
    
    [self.secondArray removeAllObjects];
    self.secondArray = nil;
    
    [self.millisecondArray removeAllObjects];
    self.millisecondArray = nil;

    self.minuteArray = [[NSMutableArray alloc] init];
    self.secondArray = [[NSMutableArray alloc] init];
    self.millisecondArray = [[NSMutableArray alloc] init];
    
    for (int i=0; i<60; i++)
    {
        [self.minuteArray addObject:[NSString stringWithFormat:@"%02d", i]];
        [self.secondArray addObject:[NSString stringWithFormat:@"%02d", i]];
    }
    
    for (int i=0; i<1000; i = i+10)
    {
        [self.millisecondArray addObject:[NSString stringWithFormat:@"%03d", i]];
    }

    [self setArraysForComponenets:[NSArray arrayWithObjects:self.minuteArray, self.secondArray, self.millisecondArray, nil]];
}

-(void) setTime:(CGFloat) time
{
    NSInteger min = floor(time / 60);
    NSInteger sec = floor(time - min * 60);
    NSInteger ms = roundf((time - (min*60 + sec))*1000);
    
    if (ms == 1000)
    {
        ms = 0;
        sec++;
    }

    ms = ms / 10;
    
    [self setIndexOfMinute:min];
    [self setIndexOfSecond:sec];
    [self setIndexOfMilliSecond:ms];
}

-(void) initializePicker
{
    [self.myPickerView selectRow:self.indexOfMinute inComponent:0 animated:YES];
    [self.myPickerView selectRow:self.indexOfSecond inComponent:1 animated:YES];
    [self.myPickerView selectRow:self.indexOfMilliSecond inComponent:2 animated:YES];
}


#pragma mark -
#pragma mark - Cancel button

-(void) pickerCancelClicked:(UIBarButtonItem*)barButton
{
    if ([self.delegate respondsToSelector:@selector(didCancel)])
        [self.delegate didCancel];
}


#pragma mark -
#pragma mark - apply button

-(void) pickerApplyClicked:(UIBarButtonItem*)barButton
{
    if ([self.delegate respondsToSelector:@selector(timePickerViewSeleted:)])
    {
        NSInteger minIndex = [self.myPickerView selectedRowInComponent:0];
        NSInteger secIndex = [self.myPickerView selectedRowInComponent:1];
        NSInteger msIndex = [self.myPickerView selectedRowInComponent:2];

        CGFloat time = minIndex*60.0f + secIndex + msIndex*10.0f/1000.0f;

        [self.delegate timePickerViewSeleted:time];
    }
}

#pragma mark -
#pragma mark - default button

-(void) defaultClicked:(UIBarButtonItem*)barButton
{
    NSInteger minIndex = 0;
    NSInteger secIndex = 0;
    NSInteger msIndex = 0;
    
    if ((self.mediaType == MEDIA_PHOTO)||(self.mediaType == MEDIA_GIF))
    {
        secIndex = 3;
    }
    else if (self.mediaType == MEDIA_TEXT)
    {
        secIndex = 6;
    }
    else
    {
        secIndex = 5;
    }
    
    [self.myPickerView selectRow:minIndex inComponent:0 animated:YES];
    [self.myPickerView selectRow:secIndex inComponent:1 animated:YES];
    [self.myPickerView selectRow:msIndex inComponent:2 animated:YES];

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
    NSInteger minuteIndex = [pickerView selectedRowInComponent:0];
    NSInteger secondIndex = [pickerView selectedRowInComponent:1];
    NSInteger msIndex = [pickerView selectedRowInComponent:2];
    
    if (((component == 0)&&(row == 0)&&(secondIndex == 0)&&(msIndex == 0)) || ((component == 1)&&(row == 0)&&(minuteIndex == 0)&&(msIndex == 0)) || ((component == 2)&&(row == 0)&&(minuteIndex == 0)&&(secondIndex == 0)))
    {
        [self.myPickerView selectRow:0 inComponent:0 animated:YES];
        [self.myPickerView selectRow:0 inComponent:1 animated:YES];
        [self.myPickerView selectRow:1 inComponent:2 animated:YES];
    }

    [self.myPickerView reloadAllComponents];
}

-(CGFloat) pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    return ((pickerView.bounds.size.width-20)-2*(self.arraysForComponenets.count-1))/self.arraysForComponenets.count;
}

-(UIView*) pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel* label = (UILabel*)view;
    
    if (!label)
    {
        label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, pickerView.frame.size.width, 44)];
        // Setup label properties - frame, font, colors etc
        
        float font = 0.0f;
    
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
            font = 15;
        else
            font = 18;
        
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