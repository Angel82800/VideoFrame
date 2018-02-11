//
//  ProjectThumbView.m
//  VideoFrame
//
//  Created by Yinjing Li on 6/20/14.
//  Copyright (c) 2014 Yinjing Li. All rights reserved.
//

#import "ProjectThumbView.h"
#import "Definition.h"
#import "UIImageExtras.h"
#import "CALayer+WiggleAnimationAdditions.h"


@implementation ProjectThumbView


- (id)initWithFrame:(CGRect)frame caption:(NSString*) captionStr name:(NSString*)projectName image:(UIImage*) screenshot
{
    self = [super initWithFrame:frame];

    if (self)
    {
        strProjectCaption = captionStr;
        strProjectName = projectName;
        
        self.thumbImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, self.bounds.size.height*0.8f)];
        [self.thumbImageView setImage:screenshot];
        self.thumbImageView.contentMode = UIViewContentModeScaleAspectFit;
        self.thumbImageView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.thumbImageView];
        self.thumbImageView.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *selectGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSelected:)];
        selectGesture.delegate = self;
        [self.thumbImageView addGestureRecognizer:selectGesture];
        [selectGesture setNumberOfTapsRequired:1];
        
        self.captionLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.bounds.origin.x, self.bounds.size.height*0.8f, self.bounds.size.width, self.bounds.size.height*0.2f)];
        [self.captionLabel setText:captionStr];
        [self.captionLabel setTextColor:[UIColor whiteColor]];
        [self.captionLabel setBackgroundColor:[UIColor clearColor]];

        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
            [self.captionLabel setFont:[UIFont fontWithName:MYRIADPRO size:10.0f]];
        else
            [self.captionLabel setFont:[UIFont fontWithName:MYRIADPRO size:14.0f]];
        
        [self.captionLabel setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:self.captionLabel];
        
        self.deleteBtn = [[YJLCustomDeleteButton alloc] init];
        self.deleteBtn.center = CGPointMake(self.bounds.size.width - self.deleteBtn.bounds.size.width/2.0f, self.deleteBtn.bounds.size.height/2.0f);
        [self.deleteBtn addTarget:self action:@selector(onDelete:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.deleteBtn];
        self.deleteBtn.hidden = YES;
        
        UILongPressGestureRecognizer *pressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longGesture:)];
        pressGesture.delegate = self;
        [self addGestureRecognizer:pressGesture];
    }
    
    return self;
}

- (CALayer *)wiggleLayer
{
    return [self layer];
}

-(void)onSelected:(UITapGestureRecognizer*) recognize
{
    if ([self.delegate respondsToSelector:@selector(selectedProject:)])
    {
        [self.delegate selectedProject:strProjectName];
    }
}

-(void)onDelete:(id)sender
{
    UIAlertView *msg=[[UIAlertView alloc] initWithTitle:@"Video Dreamer" message:@"Delete Project?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    [msg performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
}

#pragma mark -
#pragma mark - UIAlertView

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)//No delete
    {

    }
    else if (buttonIndex == 1)//delete this project
    {
        if ([self.delegate respondsToSelector:@selector(deleteProject:)])
        {
            [self.delegate deleteProject:strProjectName];
        }
    }
}

-(void)longGesture:(UILongPressGestureRecognizer*) gesture
{
    if ((gesture.state == UIGestureRecognizerStateBegan) && [self.delegate respondsToSelector:@selector(actionProjectDeleteEnabled)])
    {
        [self.delegate actionProjectDeleteEnabled];
    }
}

-(void) vibrateEnable
{
    CALayer *wiggleLayer = [self wiggleLayer];
    [wiggleLayer bts_startWiggling];
}

-(void) vibrateDesable
{
    CALayer *wiggleLayer= [self wiggleLayer];
    [wiggleLayer bts_stopWiggling];
}


@end


