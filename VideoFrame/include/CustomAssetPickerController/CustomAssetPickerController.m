//
//  CustomAssetPickerController.m
//  VideoFrame
//
//  Created by Yinjing Li on 9/22/14.
//  Copyright (c) 2014 Yinjing Li. All rights reserved.
//

#import "CustomAssetPickerController.h"

@interface CustomAssetPickerController ()

@end


@implementation CustomAssetPickerController

@synthesize filterType = _filterType;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)prefersStatusBarHidden
{
    return YES;
}

-(void) desableMultipleSelection
{
    
}

@end
