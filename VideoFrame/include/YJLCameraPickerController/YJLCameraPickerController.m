//
//  YJLCameraPickerController.m
//  VideoFrame
//
//  Created by Yinjing Li on 5/7/14.
//  Copyright (c) 2014 Yinjing Li. All rights reserved.
//

#import "YJLCameraPickerController.h"

@implementation YJLCameraPickerController


-(void) viewDidLoad
{
    [super viewDidLoad];
    
}

-(BOOL)prefersStatusBarHidden
{
    return YES;
}


#pragma mark -
#pragma mark - ******************** BUTTONS ACTIONS ********************

- (void)onTakePhoto:(id)sender
{
    if (isMultiplePhotos)
    {
        if (photosCount >= 10)
        {
            [self.multipleCountLabel setText:@"10"];
            
            UIAlertView *errormsg=[[UIAlertView alloc] initWithTitle:@"Video Dreamer" message:@"You took 10 photos already!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [errormsg show];
            
            return;
        }
        
        photosCount++;
        [self.usePhotosBtn setAlpha:1.0f];
        [self.usePhotosBtn setUserInteractionEnabled:YES];
        [self.multipleCountLabel setText:[NSString stringWithFormat:@"%d", (int)photosCount]];
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self removeCustomOverlayView];
            
            [[SHKActivityIndicator currentIndicator] displayActivity:(@"importing...") isLock:YES];

        });
    }
    
    [self performSelectorOnMainThread:@selector(takePicture) withObject:nil waitUntilDone:NO];
}

- (void)onTakeVideo:(id)sender
{
    if (isRec)  // end rec
    {
        [self.fronBackBtn setEnabled:YES];
        
        isRec = NO;
        
        [self.takeBtn setImage:[UIImage imageNamed:@"video_take_on"] forState:UIControlStateNormal];
        [self.takeBtn setImage:[UIImage imageNamed:@"video_take_off"] forState:UIControlStateSelected];
        [self.takeBtn setImage:[UIImage imageNamed:@"video_take_off"] forState:UIControlStateHighlighted];
        
        [recTimer invalidate];
        recTimer = nil;
        
        self.redDotImageView.hidden = YES;
        
        [self performSelectorOnMainThread:@selector(stopVideoCapture) withObject:nil waitUntilDone:NO];

        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self removeCustomOverlayView];

            [[SHKActivityIndicator currentIndicator] displayActivity:(@"importing...") isLock:YES];

        });
    }
    else    // start rec
    {
        [self.fronBackBtn setEnabled:NO];
        
        isRec = YES;
        
        [self.takeBtn setImage:[UIImage imageNamed:@"video_take_off"] forState:UIControlStateNormal];
        [self.takeBtn setImage:[UIImage imageNamed:@"video_take_on"] forState:UIControlStateSelected];
        [self.takeBtn setImage:[UIImage imageNamed:@"video_take_on"] forState:UIControlStateHighlighted];
        
        startInterval = [NSDate timeIntervalSinceReferenceDate];
        
        if(recTimer != nil)
        {
            [recTimer invalidate];
            recTimer = nil;
        }
        
        recTimer = [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(recTimerUpdate:) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:recTimer forMode:NSRunLoopCommonModes];
        
        [self performSelectorOnMainThread:@selector(startVideoCapture) withObject:nil waitUntilDone:NO];

        [self.takeBtn setEnabled:NO];
    }
}

- (void)onCancelCamera:(id)sender
{
    [recTimer invalidate];
    recTimer = nil;
    
    [self removeCustomOverlayView];

    if (self.cameraOverlayDelegate && [self.cameraOverlayDelegate respondsToSelector:@selector(actionCameraCancel)])
        [self.cameraOverlayDelegate actionCameraCancel];
}

- (void)onFrontBackCamera:(id)sender
{
    if (self.cameraDevice == UIImagePickerControllerCameraDeviceRear)
        self.cameraDevice = UIImagePickerControllerCameraDeviceFront;
    else
        self.cameraDevice = UIImagePickerControllerCameraDeviceRear;
}

- (void)onChangedPhotoSwitch
{
    isMultiplePhotos = self.photosSwitch.on;
    
    if (isMultiplePhotos)
    {
        [UIView animateWithDuration:0.2f animations:^{
            [self.redDotImageView setAlpha:1.0f];
            [self.multipleCountLabel setAlpha:1.0f];
            [self.multipleTitleLabel setAlpha:1.0f];
        }];
    }
    else
    {
        [UIView animateWithDuration:0.2f animations:^{
            [self.redDotImageView setAlpha:0.2f];
            [self.multipleCountLabel setAlpha:0.2f];
            [self.multipleTitleLabel setAlpha:0.2f];
            [self.usePhotosBtn setAlpha:0.2f];
            [self.usePhotosBtn setUserInteractionEnabled:NO];
        }];
    }
    
    if (self.cameraOverlayDelegate && [self.cameraOverlayDelegate respondsToSelector:@selector(selectedMultiplePhotos:)])
        [self.cameraOverlayDelegate selectedMultiplePhotos:isMultiplePhotos];
}

- (void)onUsePhotos:(id)sender
{
    dispatch_async(dispatch_get_main_queue(), ^{

        [[SHKActivityIndicator currentIndicator] displayActivity:(@"importing...") isLock:YES];

        [self removeCustomOverlayView];

        if (self.cameraOverlayDelegate && [self.cameraOverlayDelegate respondsToSelector:@selector(actionUsePhotos)])
            [self.cameraOverlayDelegate actionUsePhotos];
        
    });
}


#pragma mark - 
#pragma mark - recoding timer

- (void)recTimerUpdate:(NSTimer*) timer
{
    if (self.redDotImageView.hidden)
        self.redDotImageView.hidden = NO;
    else
        self.redDotImageView.hidden = YES;
    
    NSTimeInterval countInterval = [NSDate timeIntervalSinceReferenceDate];
    countInterval = countInterval - startInterval;
    NSString* timeStr = [self timeToStr:countInterval];
    [self.timeCountLabel setText:timeStr];
    
    if (!self.takeBtn.enabled && (countInterval > 1.0f)) {
        [self.takeBtn setEnabled:YES];
    }
}

- (NSString *)timeToStr:(CGFloat)time
{
    NSInteger hour = floor(time / 3600.0f);
    NSInteger min = floor(time / 60.0f);
    NSInteger sec = floor(time - min * 60.0f);
    
    NSString *hourStr = [NSString stringWithFormat:hour >= 10 ? @"%d" : @"0%d", (int)hour];
    NSString *minStr = [NSString stringWithFormat:min >= 10 ? @"%d" : @"0%d", (int)min];
    NSString *secStr = [NSString stringWithFormat:sec >= 10 ? @"%d" : @"0%d", (int)sec];
    
    return [NSString stringWithFormat:@"%@:%@:%@", hourStr, minStr, secStr];
}


#pragma mark -
#pragma mark - ************** UPDATE OVERLAY UI *******************
#pragma mark -
#pragma mark - orientation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if ((self.sourceType == UIImagePickerControllerSourceTypeCamera) && ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone))
        return NO;
    else if ((self.sourceType == UIImagePickerControllerSourceTypeCamera) && ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad))
        return YES;

    return YES;
}

- (BOOL)shouldAutorotate
{
    if ((self.sourceType == UIImagePickerControllerSourceTypeCamera) && ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone))
    {
        UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
        [self updateiPhoneCameraOverlayButtons:orientation];
        
        return NO;
    }
    else if ((self.sourceType == UIImagePickerControllerSourceTypeCamera) && ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad))
    {
        UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
        [self updateiPadCameraOverlayButtonsIOS8:orientation];
        
        return NO;
    }
    
    return YES;
}

- (UIInterfaceOrientationMask) supportedInterfaceOrientations
{
    if ((self.sourceType == UIImagePickerControllerSourceTypeCamera) && ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone))
        return UIInterfaceOrientationMaskPortrait;

    return UIInterfaceOrientationMaskAll;
}


#pragma mark -
#pragma mark - update camera overaly buttons with orientation

- (void)updateiPhoneCameraOverlayButtons:(UIDeviceOrientation) orientation
{
    switch (orientation)
    {
        case UIDeviceOrientationPortrait:
            if (isTakePhoto)
            {
                self.fronBackBtn.transform = CGAffineTransformIdentity;
                self.photosSwitch.transform = CGAffineTransformIdentity;
                self.photosTitleLabel.transform = CGAffineTransformIdentity;
                self.redDotImageView.transform = CGAffineTransformIdentity;
                self.multipleCountLabel.transform = CGAffineTransformIdentity;
                self.multipleTitleLabel.transform = CGAffineTransformIdentity;
                self.takeBtn.transform = CGAffineTransformIdentity;
                self.usePhotosBtn.transform = CGAffineTransformIdentity;
                self.cancelBtn.transform = CGAffineTransformIdentity;
            }
            else
            {
                self.fronBackBtn.transform = CGAffineTransformIdentity;
                self.redDotImageView.transform = CGAffineTransformIdentity;
                self.cancelBtn.transform = CGAffineTransformIdentity;
                self.topGrayView.transform = CGAffineTransformIdentity;
                self.timeCountLabel.transform = CGAffineTransformIdentity;
            }
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            if (isTakePhoto)
            {
                self.fronBackBtn.transform = CGAffineTransformMakeRotation(M_PI);
                self.photosSwitch.transform = CGAffineTransformMakeRotation(M_PI);
                self.photosTitleLabel.transform = CGAffineTransformMakeRotation(M_PI);
                self.redDotImageView.transform = CGAffineTransformMakeRotation(M_PI);
                self.multipleCountLabel.transform = CGAffineTransformMakeRotation(M_PI);
                self.multipleTitleLabel.transform = CGAffineTransformMakeRotation(M_PI);
                self.takeBtn.transform = CGAffineTransformMakeRotation(M_PI);
                self.usePhotosBtn.transform = CGAffineTransformMakeRotation(M_PI);
                self.cancelBtn.transform = CGAffineTransformMakeRotation(M_PI);
            }
            else
            {
                self.fronBackBtn.transform = CGAffineTransformMakeRotation(M_PI);
                self.cancelBtn.transform = CGAffineTransformMakeRotation(M_PI);
                self.redDotImageView.transform = CGAffineTransformMakeRotation(M_PI);
                self.timeCountLabel.transform = CGAffineTransformMakeRotation(M_PI);
                self.redDotImageView.transform = CGAffineTransformTranslate(self.redDotImageView.transform, -(self.overlayView.frame.size.width/2 - self.redDotImageView.center.x)*2.0f, 0.0f);
                self.topGrayView.transform = CGAffineTransformIdentity;
            }
            break;
        case UIDeviceOrientationLandscapeLeft:
            if (isTakePhoto)
            {
                self.fronBackBtn.transform = CGAffineTransformMakeRotation(M_PI/2);
                self.photosSwitch.transform = CGAffineTransformMakeRotation(M_PI/2);
                self.photosSwitch.transform = CGAffineTransformTranslate(self.photosSwitch.transform, 0.0f, -10.0f);
                self.photosTitleLabel.transform = CGAffineTransformMakeRotation(M_PI/2);
                self.photosTitleLabel.transform = CGAffineTransformTranslate(self.photosTitleLabel.transform, -20.0f, 20.0f);
                self.redDotImageView.transform = CGAffineTransformMakeRotation(M_PI/2);
                self.multipleCountLabel.transform = CGAffineTransformMakeRotation(M_PI/2);
                self.multipleTitleLabel.transform = CGAffineTransformMakeRotation(M_PI/2);
                self.multipleTitleLabel.transform = CGAffineTransformTranslate(self.multipleTitleLabel.transform, -20.0f, 15.0f);
                self.takeBtn.transform = CGAffineTransformMakeRotation(M_PI/2);
                self.usePhotosBtn.transform = CGAffineTransformMakeRotation(M_PI/2);
                self.usePhotosBtn.transform = CGAffineTransformTranslate(self.usePhotosBtn.transform, 20.0f, -20.0f);
                self.cancelBtn.transform = CGAffineTransformMakeRotation(M_PI/2);
                self.cancelBtn.transform = CGAffineTransformTranslate(self.cancelBtn.transform, -18.0f, 20.0f);
            }
            else
            {
                self.fronBackBtn.transform = CGAffineTransformMakeRotation(M_PI/2);
                self.redDotImageView.transform = CGAffineTransformMakeRotation(M_PI/2);
                self.timeCountLabel.transform = CGAffineTransformMakeRotation(M_PI/2);
                self.topGrayView.transform = CGAffineTransformMakeRotation(M_PI/2);
                self.cancelBtn.transform = CGAffineTransformMakeRotation(M_PI/2);
                
                if (isFive)
                {
                    self.timeCountLabel.transform = CGAffineTransformTranslate(self.timeCountLabel.transform, 230.0f, -140.0f);
                    self.topGrayView.transform = CGAffineTransformTranslate(self.topGrayView.transform, 225.0f, -140.0f);
                    self.redDotImageView.transform = CGAffineTransformTranslate(self.redDotImageView.transform, 180.0f, -185.0f);
                }
                else
                {
                    self.timeCountLabel.transform = CGAffineTransformTranslate(self.timeCountLabel.transform, 210.0f, -140.0f);
                    self.topGrayView.transform = CGAffineTransformTranslate(self.topGrayView.transform, 225.0f, -140.0f);
                    self.redDotImageView.transform = CGAffineTransformTranslate(self.redDotImageView.transform, 160.0f, -185.0f);
                }
            }
            break;
        case UIDeviceOrientationLandscapeRight:
            if (isTakePhoto)
            {
                self.fronBackBtn.transform = CGAffineTransformMakeRotation(-M_PI/2);
                self.photosSwitch.transform = CGAffineTransformMakeRotation(-M_PI/2);
                self.photosSwitch.transform = CGAffineTransformTranslate(self.photosSwitch.transform, 0.0f, -10.0f);
                self.photosTitleLabel.transform = CGAffineTransformMakeRotation(-M_PI/2);
                self.photosTitleLabel.transform = CGAffineTransformTranslate(self.photosTitleLabel.transform, 20.0f, 10.0f);
                self.redDotImageView.transform = CGAffineTransformMakeRotation(-M_PI/2);
                self.redDotImageView.transform = CGAffineTransformTranslate(self.redDotImageView.transform, 0.0f, -10.0f);
                self.multipleCountLabel.transform = CGAffineTransformMakeRotation(-M_PI/2);
                self.multipleCountLabel.transform = CGAffineTransformTranslate(self.multipleCountLabel.transform, 0.0f, -10.0f);
                self.multipleTitleLabel.transform = CGAffineTransformMakeRotation(-M_PI/2);
                self.multipleTitleLabel.transform = CGAffineTransformTranslate(self.multipleTitleLabel.transform, 20.0f, 15.0f);
                self.takeBtn.transform = CGAffineTransformMakeRotation(-M_PI/2);
                self.usePhotosBtn.transform = CGAffineTransformMakeRotation(-M_PI/2);
                self.usePhotosBtn.transform = CGAffineTransformTranslate(self.usePhotosBtn.transform, -20.0f, -20.0f);
                self.cancelBtn.transform = CGAffineTransformMakeRotation(-M_PI/2);
                self.cancelBtn.transform = CGAffineTransformTranslate(self.cancelBtn.transform, 18.0f, 20.0f);
            }
            else
            {
                self.fronBackBtn.transform = CGAffineTransformMakeRotation(-M_PI/2);
                self.redDotImageView.transform = CGAffineTransformMakeRotation(-M_PI/2);
                self.timeCountLabel.transform = CGAffineTransformMakeRotation(-M_PI/2);
                self.topGrayView.transform = CGAffineTransformMakeRotation(-M_PI/2);
                self.cancelBtn.transform = CGAffineTransformMakeRotation(-M_PI/2);
                self.timeCountLabel.transform = CGAffineTransformTranslate(self.timeCountLabel.transform, -210.0f, -140.0f);
                self.topGrayView.transform = CGAffineTransformTranslate(self.topGrayView.transform, -225.0f, -140.0f);
                self.redDotImageView.transform = CGAffineTransformTranslate(self.redDotImageView.transform, -260.0f, -95.0f);
            }
            break;
            
        default:
            break;
    };
}

- (void)updateiPadCameraOverlayButtons:(UIDeviceOrientation) orientation
{
    if (isTakePhoto)
    {
        if (templateIndex == TEMPLATE_1080P)
        {
            switch (orientation) {
                case UIDeviceOrientationLandscapeLeft:
                    self.topBlackView.frame = CGRectMake(0.0f, 0.0f, self.overlayView.frame.size.width, 96.0f);
                    self.bottomBlackView.frame = CGRectMake(0.0f, self.overlayView.frame.size.height - 96.0f, self.overlayView.frame.size.width, 96.0f);
                    self.lineX1View.frame = CGRectMake(self.overlayView.frame.size.width/3.0f, 0.0f, 1.0f, self.overlayView.frame.size.height);
                    self.lineX2View.frame = CGRectMake(self.overlayView.frame.size.width/3.0f*2.0f, 0.0f, 1.0f, self.overlayView.frame.size.height);
                    self.lineY1View.frame = CGRectMake(0.0f, (self.overlayView.frame.size.height - 192.0f)/3.0f + 96.0f, self.overlayView.frame.size.width, 1.0f);
                    self.lineY2View.frame = CGRectMake(0.0f, (self.overlayView.frame.size.height - 192.0f)/3.0f*2.0f + 96.0f, self.overlayView.frame.size.width, 1.0f);
                    break;
                case UIDeviceOrientationLandscapeRight:
                    self.topBlackView.frame = CGRectMake(0.0f, 0.0f, self.overlayView.frame.size.width, 96.0f);
                    self.bottomBlackView.frame = CGRectMake(0.0f, self.overlayView.frame.size.height - 96.0f, self.overlayView.frame.size.width, 96.0f);
                    self.lineX1View.frame = CGRectMake(self.overlayView.frame.size.width/3.0f, 0.0f, 1.0f, self.overlayView.frame.size.height);
                    self.lineX2View.frame = CGRectMake(self.overlayView.frame.size.width/3.0f*2.0f, 0.0f, 1.0f, self.overlayView.frame.size.height);
                    self.lineY1View.frame = CGRectMake(0.0f, (self.overlayView.frame.size.height - 192.0f)/3.0f + 96.0f, self.overlayView.frame.size.width, 1.0f);
                    self.lineY2View.frame = CGRectMake(0.0f, (self.overlayView.frame.size.height - 192.0f)/3.0f*2.0f + 96.0f, self.overlayView.frame.size.width, 1.0f);
                    break;
                case UIDeviceOrientationPortrait:
                    self.topBlackView.frame = CGRectMake(0.0f, 0.0f, 96.0f, self.overlayView.frame.size.height);
                    self.bottomBlackView.frame = CGRectMake(self.overlayView.frame.size.width - 96.0f, 0.0f, 96.0f, self.overlayView.frame.size.height);
                    self.lineX1View.frame = CGRectMake((self.overlayView.frame.size.width - 192.0f)/3.0f + 96.0f, 0.0f, 1.0f, self.overlayView.frame.size.height);
                    self.lineX2View.frame = CGRectMake((self.overlayView.frame.size.width - 192.0f)/3.0f*2.0f + 96.0f, 0.0f, 1.0f, self.overlayView.frame.size.height);
                    self.lineY1View.frame = CGRectMake(0.0f, self.overlayView.frame.size.height/3.0f, self.overlayView.frame.size.width, 1.0f);
                    self.lineY2View.frame = CGRectMake(0.0f, self.overlayView.frame.size.height/3.0f*2.0f, self.overlayView.frame.size.width, 1.0f);
                    break;
                case UIDeviceOrientationPortraitUpsideDown:
                    self.topBlackView.frame = CGRectMake(0.0f, 0.0f, 96.0f, self.overlayView.frame.size.height);
                    self.bottomBlackView.frame = CGRectMake(self.overlayView.frame.size.width - 96.0f, 0.0f, 96.0f, self.overlayView.frame.size.height);
                    self.lineX1View.frame = CGRectMake((self.overlayView.frame.size.width - 192.0f)/3.0f + 96.0f, 0.0f, 1.0f, self.overlayView.frame.size.height);
                    self.lineX2View.frame = CGRectMake((self.overlayView.frame.size.width - 192.0f)/3.0f*2.0f + 96.0f, 0.0f, 1.0f, self.overlayView.frame.size.height);
                    self.lineY1View.frame = CGRectMake(0.0f, self.overlayView.frame.size.height/3.0f, self.overlayView.frame.size.width, 1.0f);
                    self.lineY2View.frame = CGRectMake(0.0f, self.overlayView.frame.size.height/3.0f*2.0f, self.overlayView.frame.size.width, 1.0f);
                    break;
                    
                default:
                    break;
            }
        }
        else if (templateIndex == TEMPLATE_SQUARE)
        {
            switch (orientation) {
                case UIDeviceOrientationLandscapeLeft:
                    self.lineX1View.frame = CGRectMake((self.overlayView.frame.size.width-256.0f)/3.0f+128.0f, 0.0f, 1.0f, self.overlayView.frame.size.height);
                    self.lineX2View.frame = CGRectMake((self.overlayView.frame.size.width-256.0f)/3.0f*2.0f+128.0f, 0.0f, 1.0f, self.overlayView.frame.size.height);
                    self.lineY1View.frame = CGRectMake(0.0f, self.overlayView.frame.size.height/3.0f, self.overlayView.frame.size.width, 1.0f);
                    self.lineY2View.frame = CGRectMake(0.0f, self.overlayView.frame.size.height/3.0f*2.0f, self.overlayView.frame.size.width, 1.0f);
                    self.topBlackView.frame = CGRectMake(0.0f, 0.0f, 128.0f, self.overlayView.frame.size.height);
                    self.bottomBlackView.frame = CGRectMake(self.overlayView.frame.size.width - 128.0f, 0.0f, 128.0f, self.overlayView.frame.size.height);
                    break;
                case UIDeviceOrientationLandscapeRight:
                    self.lineX1View.frame = CGRectMake((self.overlayView.frame.size.width-256.0f)/3.0f+128.0f, 0.0f, 1.0f, self.overlayView.frame.size.height);
                    self.lineX2View.frame = CGRectMake((self.overlayView.frame.size.width-256.0f)/3.0f*2.0f+128.0f, 0.0f, 1.0f, self.overlayView.frame.size.height);
                    self.lineY1View.frame = CGRectMake(0.0f, self.overlayView.frame.size.height/3.0f, self.overlayView.frame.size.width, 1.0f);
                    self.lineY2View.frame = CGRectMake(0.0f, self.overlayView.frame.size.height/3.0f*2.0f, self.overlayView.frame.size.width, 1.0f);
                    self.topBlackView.frame = CGRectMake(0.0f, 0.0f, 128.0f, self.overlayView.frame.size.height);
                    self.bottomBlackView.frame = CGRectMake(self.overlayView.frame.size.width - 128.0f, 0.0f, 128.0f, self.overlayView.frame.size.height);
                    break;
                case UIDeviceOrientationPortrait:
                    self.lineX1View.frame = CGRectMake(self.overlayView.frame.size.width/3.0f, 0.0f, 1.0f, self.overlayView.frame.size.height);
                    self.lineX2View.frame = CGRectMake(self.overlayView.frame.size.width/3.0f*2.0f, 0.0f, 1.0f, self.overlayView.frame.size.height);
                    self.lineY1View.frame = CGRectMake(0.0f, (self.overlayView.frame.size.height - 256.0f)/3.0f + 128.0f, self.overlayView.frame.size.width, 1.0f);
                    self.lineY2View.frame = CGRectMake(0.0f, (self.overlayView.frame.size.height - 256.0f)/3.0f*2.0f + 128.0f, self.overlayView.frame.size.width, 1.0f);
                    self.topBlackView.frame = CGRectMake(0.0f, 0.0f, self.overlayView.frame.size.width, 128.0f);
                    self.bottomBlackView.frame = CGRectMake(0.0f, self.overlayView.frame.size.height - 128.0f, self.overlayView.frame.size.width, 128.0f);
                    break;
                case UIDeviceOrientationPortraitUpsideDown:
                    self.lineX1View.frame = CGRectMake(self.overlayView.frame.size.width/3.0f, 0.0f, 1.0f, self.overlayView.frame.size.height);
                    self.lineX2View.frame = CGRectMake(self.overlayView.frame.size.width/3.0f*2.0f, 0.0f, 1.0f, self.overlayView.frame.size.height);
                    self.lineY1View.frame = CGRectMake(0.0f, (self.overlayView.frame.size.height - 256.0f)/3.0f + 128.0f, self.overlayView.frame.size.width, 1.0f);
                    self.lineY2View.frame = CGRectMake(0.0f, (self.overlayView.frame.size.height - 256.0f)/3.0f*2.0f + 128.0f, self.overlayView.frame.size.width, 1.0f);
                    self.topBlackView.frame = CGRectMake(0.0f, 0.0f, self.overlayView.frame.size.width, 128.0f);
                    self.bottomBlackView.frame = CGRectMake(0.0f, self.overlayView.frame.size.height - 128.0f, self.overlayView.frame.size.width, 128.0f);
                    break;
                    
                default:
                    break;
            }
        }
    }
    else
    {
        self.redDotImageView.frame = CGRectMake(self.grayView.frame.size.width - 93.0f, self.grayView.frame.size.height/4.0f, 6.0f, 6.0f);
        self.timeCountLabel.frame = CGRectMake(self.grayView.frame.size.width - 90.0f, self.grayView.frame.size.height/4.0f - 14.5f, 85.0f, 35.0f);
        
        if (templateIndex == TEMPLATE_SQUARE)
        {
            switch (orientation) {
                case UIDeviceOrientationLandscapeLeft:
                    self.topBlackView.frame = CGRectMake(0.0f, 0.0f, 128.0f, self.overlayView.frame.size.height);
                    self.bottomBlackView.frame = CGRectMake(self.overlayView.frame.size.width - 128.0f, 0.0f, 128.0f, self.overlayView.frame.size.height);
                    break;
                case UIDeviceOrientationLandscapeRight:
                    self.topBlackView.frame = CGRectMake(0.0f, 0.0f, 128.0f, self.overlayView.frame.size.height);
                    self.bottomBlackView.frame = CGRectMake(self.overlayView.frame.size.width - 128.0f, 0.0f, 128.0f, self.overlayView.frame.size.height);
                    break;
                case UIDeviceOrientationPortrait:
                    self.topBlackView.frame = CGRectMake(0.0f, 0.0f, self.overlayView.frame.size.width, 128.0f);
                    self.bottomBlackView.frame = CGRectMake(0.0f, self.overlayView.frame.size.height - 128.0f, self.overlayView.frame.size.width, 128.0f);
                    break;
                case UIDeviceOrientationPortraitUpsideDown:
                    self.topBlackView.frame = CGRectMake(0.0f, 0.0f, self.overlayView.frame.size.width, 128.0f);
                    self.bottomBlackView.frame = CGRectMake(0.0f, self.overlayView.frame.size.height - 128.0f, self.overlayView.frame.size.width, 128.0f);
                    break;
                    
                default:
                    break;
            }
        }
    }
}


- (void)updateiPadCameraOverlayButtonsIOS8:(UIDeviceOrientation) orientation
{
    switch (startOrientation)
    {
        case UIInterfaceOrientationPortrait:
            switch (orientation)
        {
            case UIDeviceOrientationPortrait:
                self.grayView.transform = CGAffineTransformIdentity;
                self.grayView.frame = CGRectMake(768.0f - self.grayView.frame.size.width, 0.0f, self.grayView.frame.size.width, 1024.0f);
                break;
            case UIDeviceOrientationPortraitUpsideDown:
                self.grayView.transform = CGAffineTransformMakeRotation(M_PI);
                self.grayView.frame = CGRectMake(0.0f, 0.0f, self.grayView.frame.size.width, 1024.0f);
                break;
            case UIDeviceOrientationLandscapeLeft:
                self.grayView.transform = CGAffineTransformMakeRotation(M_PI/2);
                self.grayView.transform = CGAffineTransformTranslate(self.grayView.transform, (1024.0f - self.grayView.frame.size.height)/2.0f, 768.0f/2.0f);
                self.grayView.frame = CGRectMake(0.0f, self.grayView.frame.origin.y, 768.0f, self.grayView.frame.size.height);
                break;
            case UIDeviceOrientationLandscapeRight:
                self.grayView.transform = CGAffineTransformMakeRotation(-M_PI/2);
                self.grayView.transform = CGAffineTransformTranslate(self.grayView.transform, (1024.0f - self.grayView.frame.size.height)/2.0f, 768.0f/2.0f);
                self.grayView.frame = CGRectMake(0.0f, self.grayView.frame.origin.y, 768.0f, self.grayView.frame.size.height);
                break;
                
            default:
                break;
        }
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            switch (orientation)
        {
            case UIDeviceOrientationPortrait:
                self.grayView.transform = CGAffineTransformMakeRotation(M_PI);
                self.grayView.frame = CGRectMake(0.0f, 0.0f, self.grayView.frame.size.width, 1024.0f);
                break;
            case UIDeviceOrientationPortraitUpsideDown:
                self.grayView.transform = CGAffineTransformIdentity;
                self.grayView.frame = CGRectMake(768.0f - self.grayView.frame.size.width, 0.0f, self.grayView.frame.size.width, 1024.0f);
                break;
            case UIDeviceOrientationLandscapeLeft:
                self.grayView.transform = CGAffineTransformMakeRotation(-M_PI/2);
                self.grayView.transform = CGAffineTransformTranslate(self.grayView.transform, (1024.0f - self.grayView.frame.size.height)/2.0f, 768.0f/2.0f);
                self.grayView.frame = CGRectMake(0.0f, self.grayView.frame.origin.y, 768.0f, self.grayView.frame.size.height);
                break;
            case UIDeviceOrientationLandscapeRight:
                self.grayView.transform = CGAffineTransformMakeRotation(M_PI/2);
                self.grayView.transform = CGAffineTransformTranslate(self.grayView.transform, (1024.0f - self.grayView.frame.size.height)/2.0f, 768.0f/2.0f);
                self.grayView.frame = CGRectMake(0.0f, self.grayView.frame.origin.y, 768.0f, self.grayView.frame.size.height);
                break;
                
            default:
                break;
        }
            break;
        case UIInterfaceOrientationLandscapeLeft:
            switch (orientation)
        {
            case UIDeviceOrientationPortrait:
                self.grayView.transform = CGAffineTransformMakeRotation(M_PI/2);
                self.grayView.transform = CGAffineTransformTranslate(self.grayView.transform, (768.0f - self.grayView.frame.size.height)/2.0f, 1024.0f/2.0f);
                self.grayView.frame = CGRectMake(0.0f, self.grayView.frame.origin.y, 1024.0f, self.grayView.frame.size.height);
                break;
            case UIDeviceOrientationPortraitUpsideDown:
                self.grayView.transform = CGAffineTransformMakeRotation(-M_PI/2);
                self.grayView.transform = CGAffineTransformTranslate(self.grayView.transform, (768.0f - self.grayView.frame.size.height)/2.0f, 1024.0f/2.0f);
                self.grayView.frame = CGRectMake(0.0f, self.grayView.frame.origin.y, 1024.0f, self.grayView.frame.size.height);
                break;
            case UIDeviceOrientationLandscapeLeft:
                self.grayView.transform = CGAffineTransformMakeRotation(M_PI);
                self.grayView.frame = CGRectMake(0.0f, 0.0f, self.grayView.frame.size.width, 768.0f);
                break;
            case UIDeviceOrientationLandscapeRight:
                self.grayView.transform = CGAffineTransformIdentity;
                self.grayView.frame = CGRectMake(1024.0f - self.grayView.frame.size.width, 0.0f, self.grayView.frame.size.width, 768.0f);
                break;

            default:
                break;
        }
            break;
        case UIInterfaceOrientationLandscapeRight:
            switch (orientation)
        {
            case UIDeviceOrientationPortrait:
                self.grayView.transform = CGAffineTransformMakeRotation(-M_PI/2);
                self.grayView.transform = CGAffineTransformTranslate(self.grayView.transform, (768.0f - self.grayView.frame.size.height)/2.0f, 1024.0f/2.0f);
                self.grayView.frame = CGRectMake(0.0f, self.grayView.frame.origin.y, 1024.0f, self.grayView.frame.size.height);
                break;
            case UIDeviceOrientationPortraitUpsideDown:
                self.grayView.transform = CGAffineTransformMakeRotation(M_PI/2);
                self.grayView.transform = CGAffineTransformTranslate(self.grayView.transform, (768.0f - self.grayView.frame.size.height)/2.0f, 1024.0f/2.0f);
                self.grayView.frame = CGRectMake(0.0f, self.grayView.frame.origin.y, 1024.0f, self.grayView.frame.size.height);
                break;
            case UIDeviceOrientationLandscapeLeft:
                self.grayView.transform = CGAffineTransformIdentity;
                self.grayView.frame = CGRectMake(1024.0f - self.grayView.frame.size.width, 0.0f, self.grayView.frame.size.width, 768.0f);
                break;
            case UIDeviceOrientationLandscapeRight:
                self.grayView.transform = CGAffineTransformMakeRotation(M_PI);
                self.grayView.frame = CGRectMake(0.0f, 0.0f, self.grayView.frame.size.width, 768.0f);
                break;
                
            default:
                break;
        }
            break;
            
        default:
            break;
    }
}

#pragma mark -
#pragma mark - Overlay View init

- (void) initOverlayViewWithFrame:(CGRect)frame isPhoto:(BOOL)isPhoto type:(int) templateType
{
    self.overlayView = [[UIView alloc] initWithFrame:frame];
    [self.overlayView setBackgroundColor:[UIColor clearColor]];
    [self.overlayView setUserInteractionEnabled:YES];
    self.overlayView.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                                         UIViewAutoresizingFlexibleWidth |
                                         UIViewAutoresizingFlexibleRightMargin |
                                         UIViewAutoresizingFlexibleTopMargin |
                                         UIViewAutoresizingFlexibleHeight |
                                         UIViewAutoresizingFlexibleBottomMargin);
    self.overlayView.clipsToBounds = YES;
    isMultiplePhotos = NO;
    isTakePhoto = isPhoto;
    isRec = NO;
    isFive = NO;
    photosCount = 0;
    templateIndex = templateType;
    
    if (isTakePhoto)    //Photo camera
    {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        {
            if (([UIScreen mainScreen].bounds.size.width > 480.0f)||([UIScreen mainScreen].bounds.size.height > 480.0f))
                isFive = YES;
            
            if (isFive)
                [self initPhotoCameraOverlayViewForiPhone5];    //iphone5 photo camera
            else
                [self initPhotoCameraOverlayViewForiPhone4];    //iphone4 photo camera
        }
        else
        {
            [self initPhotoCameraOverlayViewForiPad];   //ipad photo camera
        }
    }
    else    //Video camera
    {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        {
            if (([UIScreen mainScreen].bounds.size.width > 480.0f)||([UIScreen mainScreen].bounds.size.height > 480.0f))
                isFive = YES;
            
            if (isFive)
                [self initVideoCameraOverlayViewForiPhone5];    //iphone5 video camera
            else
                [self initVideoCameraOverlayViewForiPhone4];    //iphone4 video camera
        }
        else
            [self initVideoCameraOverlayViewForiPad];   //ipad video camera
    }
    
//    self.cameraOverlayView = self.overlayView;

    [self.view.window addSubview:self.overlayView];
}

- (void)removeCustomOverlayView
{
    [self.overlayView removeFromSuperview];
}

- (void)initPhotoCameraOverlayViewForiPhone5
{
    if (templateIndex == TEMPLATE_SQUARE)
    {
        self.topBlackView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.overlayView.frame.size.width, (self.overlayView.frame.size.height - self.overlayView.frame.size.width)/2)];
        [self.topBlackView setBackgroundColor:[UIColor blackColor]];
        self.topBlackView.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                                              UIViewAutoresizingFlexibleRightMargin |
                                              UIViewAutoresizingFlexibleTopMargin |
                                              UIViewAutoresizingFlexibleBottomMargin|
                                              UIViewAutoresizingFlexibleWidth);
        [self.overlayView addSubview:self.topBlackView];
        
        self.bottomBlackView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, self.overlayView.frame.size.height - (self.overlayView.frame.size.height - self.overlayView.frame.size.width)/2, self.overlayView.frame.size.width, (self.overlayView.frame.size.height - self.overlayView.frame.size.width)/2)];
        [self.bottomBlackView setBackgroundColor:[UIColor blackColor]];
        self.bottomBlackView.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                                                 UIViewAutoresizingFlexibleRightMargin |
                                                 UIViewAutoresizingFlexibleTopMargin |
                                                 UIViewAutoresizingFlexibleBottomMargin|
                                                 UIViewAutoresizingFlexibleWidth);
        [self.overlayView addSubview:self.bottomBlackView];
    }

    //gray view
    self.grayView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, self.overlayView.frame.size.height - 70.0f, self.overlayView.frame.size.width, 70.0f)];
    [self.grayView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.3f]];
    self.grayView.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                                      UIViewAutoresizingFlexibleRightMargin |
                                      UIViewAutoresizingFlexibleTopMargin |
                                      UIViewAutoresizingFlexibleWidth |
                                      UIViewAutoresizingFlexibleBottomMargin);
    [self.overlayView addSubview:self.grayView];
    
    //front back button
    self.fronBackBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.fronBackBtn setImage:[UIImage imageNamed:@"front_back"] forState:UIControlStateNormal];
    [self.fronBackBtn setFrame:CGRectMake(self.overlayView.frame.size.width - 45.0f, 30.0f, 30.0f, 25.0f)];
    self.fronBackBtn.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                                         UIViewAutoresizingFlexibleRightMargin |
                                         UIViewAutoresizingFlexibleTopMargin |
                                         UIViewAutoresizingFlexibleBottomMargin);
    [self.fronBackBtn addTarget:self action:@selector(onFrontBackCamera:) forControlEvents:UIControlEventTouchUpInside];
    [self.overlayView addSubview:self.fronBackBtn];
    
    //photos switch
    self.photosSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
    [self.photosSwitch setFrame:CGRectMake(5.0f, self.overlayView.frame.size.height - 60.0f, self.photosSwitch.frame.size.width, self.photosSwitch.frame.size.height)];
    [self.photosSwitch addTarget:self action:@selector(onChangedPhotoSwitch) forControlEvents:UIControlEventValueChanged];
    [self.photosSwitch setBackgroundColor:[UIColor clearColor]];
    self.photosSwitch.on = NO;
    self.photosSwitch.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                                          UIViewAutoresizingFlexibleRightMargin |
                                          UIViewAutoresizingFlexibleTopMargin |
                                          UIViewAutoresizingFlexibleBottomMargin);
    [self.overlayView addSubview:self.photosSwitch];
    
    //photos title lable
    self.photosTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(60.0f, self.overlayView.frame.size.height - 40.0f, 60.0f, 35.0f)];
    [self.photosTitleLabel setBackgroundColor:[UIColor clearColor]];
    [self.photosTitleLabel setText:@"PHOTOS"];
    [self.photosTitleLabel setTextColor:[UIColor whiteColor]];
    [self.photosTitleLabel setMinimumScaleFactor:0.1f];
    [self.photosTitleLabel setAdjustsFontSizeToFitWidth:YES];
    [self.photosTitleLabel setFont:[UIFont fontWithName:MYRIADPRO size:10.0f]];
    [self.photosTitleLabel setTextAlignment:NSTextAlignmentCenter];
    self.photosTitleLabel.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                                              UIViewAutoresizingFlexibleRightMargin |
                                              UIViewAutoresizingFlexibleTopMargin |
                                              UIViewAutoresizingFlexibleBottomMargin);
    [self.overlayView addSubview:self.photosTitleLabel];
    
    //red dot
    self.redDotImageView = [[UIImageView alloc] initWithFrame:CGRectMake(75.0f, self.overlayView.frame.size.height - 60.0f, 30.0f, 30.0f)];
    [self.redDotImageView setImage:[UIImage imageNamed:@"red_dot"]];
    [self.redDotImageView setBackgroundColor:[UIColor clearColor]];
    self.redDotImageView.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                                             UIViewAutoresizingFlexibleRightMargin |
                                             UIViewAutoresizingFlexibleTopMargin |
                                             UIViewAutoresizingFlexibleBottomMargin);
    [self.overlayView addSubview:self.redDotImageView];
    
    //multiple count label
    self.multipleCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(75.0f, self.overlayView.frame.size.height - 60.0f, 30.0f, 30.0f)];
    [self.multipleCountLabel setBackgroundColor:[UIColor clearColor]];
    [self.multipleCountLabel setText:@"0"];
    [self.multipleCountLabel setTextColor:[UIColor whiteColor]];
    [self.multipleCountLabel setMinimumScaleFactor:0.1f];
    [self.multipleCountLabel setTextAlignment:NSTextAlignmentCenter];
    [self.multipleCountLabel setAdjustsFontSizeToFitWidth:YES];
    self.multipleCountLabel.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                                                UIViewAutoresizingFlexibleRightMargin |
                                                UIViewAutoresizingFlexibleTopMargin |
                                                UIViewAutoresizingFlexibleBottomMargin);
    [self.overlayView addSubview:self.multipleCountLabel];
    
    //multiple count title label
    self.multipleTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(2.0f, self.overlayView.frame.size.height - 40.0f, 55.0f, 35.0f)];
    [self.multipleTitleLabel setBackgroundColor:[UIColor clearColor]];
    [self.multipleTitleLabel setText:@"MULTIPLE"];
    [self.multipleTitleLabel setTextColor:[UIColor whiteColor]];
    [self.multipleTitleLabel setMinimumScaleFactor:0.1f];
    [self.multipleTitleLabel setAdjustsFontSizeToFitWidth:YES];
    [self.multipleTitleLabel setFont:[UIFont fontWithName:MYRIADPRO size:10.0f]];
    [self.multipleTitleLabel setTextAlignment:NSTextAlignmentCenter];
    self.multipleTitleLabel.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                                                UIViewAutoresizingFlexibleRightMargin |
                                                UIViewAutoresizingFlexibleTopMargin |
                                                UIViewAutoresizingFlexibleBottomMargin);
    [self.overlayView addSubview:self.multipleTitleLabel];
    
    //take photo button
    self.takeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.takeBtn setImage:[UIImage imageNamed:@"photo_take_on"] forState:UIControlStateNormal];
    [self.takeBtn setImage:[UIImage imageNamed:@"photo_take_off"] forState:UIControlStateSelected];
    [self.takeBtn setImage:[UIImage imageNamed:@"photo_take_off"] forState:UIControlStateHighlighted];
    [self.takeBtn setFrame:CGRectMake(self.overlayView.frame.size.width/2 - 35.0f, self.overlayView.frame.size.height - 75.0f, 70.0f, 70.0f)];
    self.takeBtn.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                                     UIViewAutoresizingFlexibleRightMargin |
                                     UIViewAutoresizingFlexibleTopMargin |
                                     UIViewAutoresizingFlexibleBottomMargin);
    [self.takeBtn addTarget:self action:@selector(onTakePhoto:) forControlEvents:UIControlEventTouchUpInside];
    [self.overlayView addSubview:self.takeBtn];
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width > [UIScreen mainScreen].bounds.size.height ? [UIScreen mainScreen].bounds.size.height : [UIScreen mainScreen].bounds.size.width;

    //usePhotos button
    self.usePhotosBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.usePhotosBtn setTitle:@"Use Photos" forState:UIControlStateNormal];
    [self.usePhotosBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.usePhotosBtn setTitleColor:[UIColor grayColor] forState:UIControlStateSelected];
    self.usePhotosBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    self.usePhotosBtn.layer.borderWidth = 1.0f;
    self.usePhotosBtn.layer.cornerRadius = 3.0f;
    [self.usePhotosBtn.titleLabel setMinimumScaleFactor:0.1f];
    [self.usePhotosBtn.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [self.usePhotosBtn.titleLabel setAdjustsFontSizeToFitWidth:YES];
    [self.usePhotosBtn.titleLabel setFont:[UIFont fontWithName:MYRIADPRO size:14.0f]];
    [self.usePhotosBtn setFrame:CGRectMake(screenWidth - 100.0f, self.overlayView.frame.size.height - 78.0f, 80.0f, 35.0f)];
    self.usePhotosBtn.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                                          UIViewAutoresizingFlexibleRightMargin |
                                          UIViewAutoresizingFlexibleTopMargin |
                                          UIViewAutoresizingFlexibleBottomMargin);
    [self.usePhotosBtn addTarget:self action:@selector(onUsePhotos:) forControlEvents:UIControlEventTouchUpInside];
    [self.overlayView addSubview:self.usePhotosBtn];
    
    //cancel button
    self.cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.cancelBtn setTitle:@"Cancel" forState:UIControlStateNormal];
    [self.cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.cancelBtn setTitleColor:[UIColor grayColor] forState:UIControlStateSelected];
    self.cancelBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    self.cancelBtn.layer.borderWidth = 1.0f;
    self.cancelBtn.layer.cornerRadius = 3.0f;
    [self.cancelBtn.titleLabel setMinimumScaleFactor:0.1f];
    [self.cancelBtn.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [self.cancelBtn.titleLabel setAdjustsFontSizeToFitWidth:YES];
    [self.cancelBtn.titleLabel setFont:[UIFont fontWithName:MYRIADPRO size:14.0f]];
    [self.cancelBtn setFrame:CGRectMake(screenWidth - 100.0f, self.overlayView.frame.size.height - 40.0f, 80.0f, 35.0f)];
    self.cancelBtn.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                                       UIViewAutoresizingFlexibleRightMargin |
                                       UIViewAutoresizingFlexibleTopMargin |
                                       UIViewAutoresizingFlexibleBottomMargin);
    [self.cancelBtn addTarget:self action:@selector(onCancelCamera:) forControlEvents:UIControlEventTouchUpInside];
    [self.overlayView addSubview:self.cancelBtn];
    
    [self.redDotImageView setAlpha:0.2f];
    [self.multipleCountLabel setAlpha:0.2f];
    [self.multipleTitleLabel setAlpha:0.2f];
    [self.usePhotosBtn setAlpha:0.2f];
    [self.usePhotosBtn setUserInteractionEnabled:NO];
}

- (void)initPhotoCameraOverlayViewForiPhone4
{
    if (templateIndex == TEMPLATE_1080P)
    {
        self.topBlackView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 25.0f, self.overlayView.frame.size.height)];
        [self.topBlackView setBackgroundColor:[UIColor blackColor]];
        self.topBlackView.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                                              UIViewAutoresizingFlexibleRightMargin |
                                              UIViewAutoresizingFlexibleTopMargin |
                                              UIViewAutoresizingFlexibleBottomMargin|
                                              UIViewAutoresizingFlexibleWidth);
        [self.overlayView addSubview:self.topBlackView];
        
        self.bottomBlackView = [[UIView alloc] initWithFrame:CGRectMake(self.overlayView.frame.size.width - 25.0f, 0.0f, 25.0f, self.overlayView.frame.size.height)];
        [self.bottomBlackView setBackgroundColor:[UIColor blackColor]];
        self.bottomBlackView.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                                                 UIViewAutoresizingFlexibleRightMargin |
                                                 UIViewAutoresizingFlexibleTopMargin |
                                                 UIViewAutoresizingFlexibleBottomMargin|
                                                 UIViewAutoresizingFlexibleWidth);
        [self.overlayView addSubview:self.bottomBlackView];
    }
    else if (templateIndex == TEMPLATE_SQUARE)
    {
        self.topBlackView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.overlayView.frame.size.width, 80.0f)];
        [self.topBlackView setBackgroundColor:[UIColor blackColor]];
        self.topBlackView.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                                              UIViewAutoresizingFlexibleRightMargin |
                                              UIViewAutoresizingFlexibleTopMargin |
                                              UIViewAutoresizingFlexibleBottomMargin|
                                              UIViewAutoresizingFlexibleWidth);
        [self.overlayView addSubview:self.topBlackView];
        
        self.bottomBlackView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, self.overlayView.frame.size.height - 80.0f, self.overlayView.frame.size.width, 80.0f)];
        [self.bottomBlackView setBackgroundColor:[UIColor blackColor]];
        self.bottomBlackView.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                                                 UIViewAutoresizingFlexibleRightMargin |
                                                 UIViewAutoresizingFlexibleTopMargin |
                                                 UIViewAutoresizingFlexibleBottomMargin|
                                                 UIViewAutoresizingFlexibleWidth);
        [self.overlayView addSubview:self.bottomBlackView];
    }

    //gray view
    self.grayView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, self.overlayView.frame.size.height - 80.0f, self.overlayView.frame.size.width, 80.0f)];
    [self.grayView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.3f]];
    self.grayView.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                                      UIViewAutoresizingFlexibleRightMargin |
                                      UIViewAutoresizingFlexibleTopMargin |
                                      UIViewAutoresizingFlexibleWidth |
                                      UIViewAutoresizingFlexibleBottomMargin);
    [self.overlayView addSubview:self.grayView];
    
    //front back button
    self.fronBackBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.fronBackBtn setImage:[UIImage imageNamed:@"front_back"] forState:UIControlStateNormal];
    [self.fronBackBtn setFrame:CGRectMake(self.overlayView.frame.size.width - 40.0f, 15.0f, 26.0f, 20.0f)];
    self.fronBackBtn.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                                         UIViewAutoresizingFlexibleRightMargin |
                                         UIViewAutoresizingFlexibleTopMargin |
                                         UIViewAutoresizingFlexibleBottomMargin);
    [self.fronBackBtn addTarget:self action:@selector(onFrontBackCamera:) forControlEvents:UIControlEventTouchUpInside];
    [self.overlayView addSubview:self.fronBackBtn];
    
    //photos switch
    self.photosSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
    [self.photosSwitch setFrame:CGRectMake(5.0f, self.overlayView.frame.size.height - 60.0f, self.photosSwitch.frame.size.width, self.photosSwitch.frame.size.height)];
    [self.photosSwitch addTarget:self action:@selector(onChangedPhotoSwitch) forControlEvents:UIControlEventValueChanged];
    [self.photosSwitch setBackgroundColor:[UIColor clearColor]];
    self.photosSwitch.on = NO;
    self.photosSwitch.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                                          UIViewAutoresizingFlexibleRightMargin |
                                          UIViewAutoresizingFlexibleTopMargin |
                                          UIViewAutoresizingFlexibleBottomMargin);
    [self.overlayView addSubview:self.photosSwitch];
    
    //photos title lable
    self.photosTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(60.0f, self.overlayView.frame.size.height - 40.0f, 60.0f, 35.0f)];
    [self.photosTitleLabel setBackgroundColor:[UIColor clearColor]];
    [self.photosTitleLabel setText:@"PHOTOS"];
    [self.photosTitleLabel setTextColor:[UIColor whiteColor]];
    [self.photosTitleLabel setMinimumScaleFactor:0.1f];
    [self.photosTitleLabel setAdjustsFontSizeToFitWidth:YES];
    [self.photosTitleLabel setFont:[UIFont fontWithName:MYRIADPRO size:10.0f]];
    [self.photosTitleLabel setTextAlignment:NSTextAlignmentCenter];
    self.photosTitleLabel.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                                              UIViewAutoresizingFlexibleRightMargin |
                                              UIViewAutoresizingFlexibleTopMargin |
                                              UIViewAutoresizingFlexibleBottomMargin);
    [self.overlayView addSubview:self.photosTitleLabel];
    
    //red dot
    self.redDotImageView = [[UIImageView alloc] initWithFrame:CGRectMake(75.0f, self.overlayView.frame.size.height - 60.0f, 30.0f, 30.0f)];
    [self.redDotImageView setImage:[UIImage imageNamed:@"red_dot"]];
    [self.redDotImageView setBackgroundColor:[UIColor clearColor]];
    self.redDotImageView.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                                             UIViewAutoresizingFlexibleRightMargin |
                                             UIViewAutoresizingFlexibleTopMargin |
                                             UIViewAutoresizingFlexibleBottomMargin);
    [self.overlayView addSubview:self.redDotImageView];
    
    //multiple count label
    self.multipleCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(75.0f, self.overlayView.frame.size.height - 60.0f, 30.0f, 30.0f)];
    [self.multipleCountLabel setBackgroundColor:[UIColor clearColor]];
    [self.multipleCountLabel setText:@"0"];
    [self.multipleCountLabel setTextColor:[UIColor whiteColor]];
    [self.multipleCountLabel setMinimumScaleFactor:0.1f];
    [self.multipleCountLabel setTextAlignment:NSTextAlignmentCenter];
    [self.multipleCountLabel setAdjustsFontSizeToFitWidth:YES];
    self.multipleCountLabel.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                                                UIViewAutoresizingFlexibleRightMargin |
                                                UIViewAutoresizingFlexibleTopMargin |
                                                UIViewAutoresizingFlexibleBottomMargin);
    [self.overlayView addSubview:self.multipleCountLabel];
    
    //multiple count title label
    self.multipleTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(2.0f, self.overlayView.frame.size.height - 40.0f, 55.0f, 35.0f)];
    [self.multipleTitleLabel setBackgroundColor:[UIColor clearColor]];
    [self.multipleTitleLabel setText:@"MULTIPLE"];
    [self.multipleTitleLabel setTextColor:[UIColor whiteColor]];
    [self.multipleTitleLabel setMinimumScaleFactor:0.1f];
    [self.multipleTitleLabel setAdjustsFontSizeToFitWidth:YES];
    [self.multipleTitleLabel setFont:[UIFont fontWithName:MYRIADPRO size:10.0f]];
    [self.multipleTitleLabel setTextAlignment:NSTextAlignmentCenter];
    self.multipleTitleLabel.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                                                UIViewAutoresizingFlexibleRightMargin |
                                                UIViewAutoresizingFlexibleTopMargin |
                                                UIViewAutoresizingFlexibleBottomMargin);
    [self.overlayView addSubview:self.multipleTitleLabel];
    
    //take photo button
    self.takeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.takeBtn setImage:[UIImage imageNamed:@"photo_take_on"] forState:UIControlStateNormal];
    [self.takeBtn setImage:[UIImage imageNamed:@"photo_take_off"] forState:UIControlStateSelected];
    [self.takeBtn setImage:[UIImage imageNamed:@"photo_take_off"] forState:UIControlStateHighlighted];
    [self.takeBtn setFrame:CGRectMake(self.overlayView.frame.size.width/2 - 35.0f, self.overlayView.frame.size.height - 75.0f, 70.0f, 70.0f)];
    self.takeBtn.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                                     UIViewAutoresizingFlexibleRightMargin |
                                     UIViewAutoresizingFlexibleTopMargin |
                                     UIViewAutoresizingFlexibleBottomMargin);
    [self.takeBtn addTarget:self action:@selector(onTakePhoto:) forControlEvents:UIControlEventTouchUpInside];
    [self.overlayView addSubview:self.takeBtn];
    
    //usePhotos button
    self.usePhotosBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.usePhotosBtn setTitle:@"Use Photos" forState:UIControlStateNormal];
    [self.usePhotosBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.usePhotosBtn setTitleColor:[UIColor grayColor] forState:UIControlStateSelected];
    self.usePhotosBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    self.usePhotosBtn.layer.borderWidth = 1.0f;
    self.usePhotosBtn.layer.cornerRadius = 3.0f;
    [self.usePhotosBtn.titleLabel setMinimumScaleFactor:0.1f];
    [self.usePhotosBtn.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [self.usePhotosBtn.titleLabel setAdjustsFontSizeToFitWidth:YES];
    [self.usePhotosBtn.titleLabel setFont:[UIFont fontWithName:MYRIADPRO size:14.0f]];
    [self.usePhotosBtn setFrame:CGRectMake(220.0f, self.overlayView.frame.size.height - 77.0f, 80.0f, 35.0f)];
    self.usePhotosBtn.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                                          UIViewAutoresizingFlexibleRightMargin |
                                          UIViewAutoresizingFlexibleTopMargin |
                                          UIViewAutoresizingFlexibleBottomMargin);
    [self.usePhotosBtn addTarget:self action:@selector(onUsePhotos:) forControlEvents:UIControlEventTouchUpInside];
    [self.overlayView addSubview:self.usePhotosBtn];
    
    //cancel button
    self.cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.cancelBtn setTitle:@"Cancel" forState:UIControlStateNormal];
    [self.cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.cancelBtn setTitleColor:[UIColor grayColor] forState:UIControlStateSelected];
    self.cancelBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    self.cancelBtn.layer.borderWidth = 1.0f;
    self.cancelBtn.layer.cornerRadius = 3.0f;
    [self.cancelBtn.titleLabel setMinimumScaleFactor:0.1f];
    [self.cancelBtn.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [self.cancelBtn.titleLabel setAdjustsFontSizeToFitWidth:YES];
    [self.cancelBtn.titleLabel setFont:[UIFont fontWithName:MYRIADPRO size:14.0f]];
    [self.cancelBtn setFrame:CGRectMake(220.0f, self.overlayView.frame.size.height - 39.0f, 80.0f, 35.0f)];
    self.cancelBtn.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                                       UIViewAutoresizingFlexibleRightMargin |
                                       UIViewAutoresizingFlexibleTopMargin |
                                       UIViewAutoresizingFlexibleBottomMargin);
    [self.cancelBtn addTarget:self action:@selector(onCancelCamera:) forControlEvents:UIControlEventTouchUpInside];
    [self.overlayView addSubview:self.cancelBtn];
    
    [self.redDotImageView setAlpha:0.2f];
    [self.multipleCountLabel setAlpha:0.2f];
    [self.multipleTitleLabel setAlpha:0.2f];
    [self.usePhotosBtn setAlpha:0.2f];
    [self.usePhotosBtn setUserInteractionEnabled:NO];
}

- (void)initPhotoCameraOverlayViewForiPad
{
    startOrientation = [[UIApplication sharedApplication] statusBarOrientation];

    //lines
    self.lineX1View = [[UIView alloc] initWithFrame:CGRectMake(self.overlayView.frame.size.width/3.0f, 0.0f, 1.0f, self.overlayView.frame.size.height)];
    [self.lineX1View setBackgroundColor:[UIColor lightGrayColor]];
    self.lineX1View.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                                 UIViewAutoresizingFlexibleRightMargin |
                                 UIViewAutoresizingFlexibleTopMargin |
                                 UIViewAutoresizingFlexibleBottomMargin|
                                 UIViewAutoresizingFlexibleHeight);
    [self.overlayView addSubview:self.lineX1View];
    
    self.lineX2View = [[UIView alloc] initWithFrame:CGRectMake(self.overlayView.frame.size.width/3.0f*2.0f, 0.0f, 1.0f, self.overlayView.frame.size.height)];
    [self.lineX2View setBackgroundColor:[UIColor lightGrayColor]];
    self.lineX2View.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                                 UIViewAutoresizingFlexibleRightMargin |
                                 UIViewAutoresizingFlexibleTopMargin |
                                 UIViewAutoresizingFlexibleBottomMargin|
                                 UIViewAutoresizingFlexibleHeight);
    [self.overlayView addSubview:self.lineX2View];
    
    self.lineY1View = [[UIView alloc] initWithFrame:CGRectMake(0.0f, self.overlayView.frame.size.height/3.0f, self.overlayView.frame.size.width, 1.0f)];
    [self.lineY1View setBackgroundColor:[UIColor lightGrayColor]];
    self.lineY1View.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                                 UIViewAutoresizingFlexibleRightMargin |
                                 UIViewAutoresizingFlexibleTopMargin |
                                 UIViewAutoresizingFlexibleBottomMargin|
                                 UIViewAutoresizingFlexibleWidth);
    [self.overlayView addSubview:self.lineY1View];
    
    self.lineY2View = [[UIView alloc] initWithFrame:CGRectMake(0.0f, self.overlayView.frame.size.height/3.0f*2.0f, self.overlayView.frame.size.width, 1.0f)];
    [self.lineY2View setBackgroundColor:[UIColor lightGrayColor]];
    self.lineY2View.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                                 UIViewAutoresizingFlexibleRightMargin |
                                 UIViewAutoresizingFlexibleTopMargin |
                                 UIViewAutoresizingFlexibleBottomMargin|
                                 UIViewAutoresizingFlexibleWidth);
    [self.overlayView addSubview:self.lineY2View];
    
    
    if (templateIndex == TEMPLATE_1080P)
    {
        self.lineX1View.frame = CGRectMake(self.overlayView.frame.size.width/3.0f, 0.0f, 1.0f, self.overlayView.frame.size.height);
        self.lineX2View.frame = CGRectMake(self.overlayView.frame.size.width/3.0f*2.0f, 0.0f, 1.0f, self.overlayView.frame.size.height);
        self.lineY1View.frame = CGRectMake(0.0f, (self.overlayView.frame.size.height - 192.0f)/3.0f + 96.0f, self.overlayView.frame.size.width, 1.0f);
        self.lineY2View.frame = CGRectMake(0.0f, (self.overlayView.frame.size.height - 192.0f)/3.0f*2.0f + 96.0f, self.overlayView.frame.size.width, 1.0f);
        
        self.topBlackView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.overlayView.frame.size.width, 96.0f)];
        [self.topBlackView setBackgroundColor:[UIColor blackColor]];
        self.topBlackView.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                                     UIViewAutoresizingFlexibleRightMargin |
                                     UIViewAutoresizingFlexibleTopMargin |
                                     UIViewAutoresizingFlexibleBottomMargin|
                                     UIViewAutoresizingFlexibleWidth);
        [self.overlayView addSubview:self.topBlackView];
        
        self.bottomBlackView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, self.overlayView.frame.size.height - 96.0f, self.overlayView.frame.size.width, 96.0f)];
        [self.bottomBlackView setBackgroundColor:[UIColor blackColor]];
        self.bottomBlackView.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                                     UIViewAutoresizingFlexibleRightMargin |
                                     UIViewAutoresizingFlexibleTopMargin |
                                     UIViewAutoresizingFlexibleBottomMargin|
                                     UIViewAutoresizingFlexibleWidth);
        [self.overlayView addSubview:self.bottomBlackView];
        
        switch (startOrientation)
        {
            case UIInterfaceOrientationPortrait:
                self.topBlackView.frame = CGRectMake(0.0f, 0.0f, 96.0f, self.overlayView.frame.size.height);
                self.bottomBlackView.frame = CGRectMake(self.overlayView.frame.size.width - 96.0f, 0.0f, 96.0f, self.overlayView.frame.size.height);
                
                self.lineX1View.frame = CGRectMake((self.overlayView.frame.size.width - 192.0f)/3.0f + 96.0f, 0.0f, 1.0f, self.overlayView.frame.size.height);
                self.lineX2View.frame = CGRectMake((self.overlayView.frame.size.width - 192.0f)/3.0f*2.0f + 96.0f, 0.0f, 1.0f, self.overlayView.frame.size.height);
                self.lineY1View.frame = CGRectMake(0.0f, self.overlayView.frame.size.height/3.0f, self.overlayView.frame.size.width, 1.0f);
                self.lineY2View.frame = CGRectMake(0.0f, self.overlayView.frame.size.height/3.0f*2.0f, self.overlayView.frame.size.width, 1.0f);
                break;
            case UIInterfaceOrientationPortraitUpsideDown:
                self.topBlackView.frame = CGRectMake(0.0f, 0.0f, 96.0f, self.overlayView.frame.size.height);
                self.bottomBlackView.frame = CGRectMake(self.overlayView.frame.size.width - 96.0f, 0.0f, 96.0f, self.overlayView.frame.size.height);
                
                self.lineX1View.frame = CGRectMake((self.overlayView.frame.size.width - 192.0f)/3.0f + 96.0f, 0.0f, 1.0f, self.overlayView.frame.size.height);
                self.lineX2View.frame = CGRectMake((self.overlayView.frame.size.width - 192.0f)/3.0f*2.0f + 96.0f, 0.0f, 1.0f, self.overlayView.frame.size.height);
                self.lineY1View.frame = CGRectMake(0.0f, self.overlayView.frame.size.height/3.0f, self.overlayView.frame.size.width, 1.0f);
                self.lineY2View.frame = CGRectMake(0.0f, self.overlayView.frame.size.height/3.0f*2.0f, self.overlayView.frame.size.width, 1.0f);
                break;
            case UIInterfaceOrientationLandscapeLeft:
                self.topBlackView.frame = CGRectMake(0.0f, 0.0f, self.overlayView.frame.size.width, 96.0f);
                self.bottomBlackView.frame = CGRectMake(0.0f, self.overlayView.frame.size.height - 96.0f, self.overlayView.frame.size.width, 96.0f);
                
                self.lineX1View.frame = CGRectMake(self.overlayView.frame.size.width/3.0f, 0.0f, 1.0f, self.overlayView.frame.size.height);
                self.lineX2View.frame = CGRectMake(self.overlayView.frame.size.width/3.0f*2.0f, 0.0f, 1.0f, self.overlayView.frame.size.height);
                self.lineY1View.frame = CGRectMake(0.0f, (self.overlayView.frame.size.height - 192.0f)/3.0f + 96.0f, self.overlayView.frame.size.width, 1.0f);
                self.lineY2View.frame = CGRectMake(0.0f, (self.overlayView.frame.size.height - 192.0f)/3.0f*2.0f + 96.0f, self.overlayView.frame.size.width, 1.0f);
                break;
            case UIInterfaceOrientationLandscapeRight:
                self.topBlackView.frame = CGRectMake(0.0f, 0.0f, self.overlayView.frame.size.width, 96.0f);
                self.bottomBlackView.frame = CGRectMake(0.0f, self.overlayView.frame.size.height - 96.0f, self.overlayView.frame.size.width, 96.0f);
                
                self.lineX1View.frame = CGRectMake(self.overlayView.frame.size.width/3.0f, 0.0f, 1.0f, self.overlayView.frame.size.height);
                self.lineX2View.frame = CGRectMake(self.overlayView.frame.size.width/3.0f*2.0f, 0.0f, 1.0f, self.overlayView.frame.size.height);
                self.lineY1View.frame = CGRectMake(0.0f, (self.overlayView.frame.size.height - 192.0f)/3.0f + 96.0f, self.overlayView.frame.size.width, 1.0f);
                self.lineY2View.frame = CGRectMake(0.0f, (self.overlayView.frame.size.height - 192.0f)/3.0f*2.0f + 96.0f, self.overlayView.frame.size.width, 1.0f);
                break;
                
            default:
                break;
        }
    }
    else if (templateIndex == TEMPLATE_SQUARE)
    {
        self.lineX1View.frame = CGRectMake(self.overlayView.frame.size.width/3.0f, 0.0f, 1.0f, self.overlayView.frame.size.height);
        self.lineX2View.frame = CGRectMake(self.overlayView.frame.size.width/3.0f*2.0f, 0.0f, 1.0f, self.overlayView.frame.size.height);
        self.lineY1View.frame = CGRectMake(0.0f, (self.overlayView.frame.size.height - 256.0f)/3.0f + 128.0f, self.overlayView.frame.size.width, 1.0f);
        self.lineY2View.frame = CGRectMake(0.0f, (self.overlayView.frame.size.height - 256.0f)/3.0f*2.0f + 128.0f, self.overlayView.frame.size.width, 1.0f);

        self.topBlackView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.overlayView.frame.size.width, 128.0f)];
        [self.topBlackView setBackgroundColor:[UIColor blackColor]];
        self.topBlackView.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                                              UIViewAutoresizingFlexibleRightMargin |
                                              UIViewAutoresizingFlexibleTopMargin |
                                              UIViewAutoresizingFlexibleBottomMargin|
                                              UIViewAutoresizingFlexibleWidth);
        [self.overlayView addSubview:self.topBlackView];
        
        self.bottomBlackView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, self.overlayView.frame.size.height - 128.0f, self.overlayView.frame.size.width, 128.0f)];
        [self.bottomBlackView setBackgroundColor:[UIColor blackColor]];
        self.bottomBlackView.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                                                 UIViewAutoresizingFlexibleRightMargin |
                                                 UIViewAutoresizingFlexibleTopMargin |
                                                 UIViewAutoresizingFlexibleBottomMargin|
                                                 UIViewAutoresizingFlexibleWidth);
        [self.overlayView addSubview:self.bottomBlackView];
        
        
        switch (startOrientation)
        {
            case UIInterfaceOrientationPortrait:
                self.topBlackView.frame = CGRectMake(0.0f, 0.0f, self.overlayView.frame.size.width, 128.0f);
                self.bottomBlackView.frame = CGRectMake(0.0f, self.overlayView.frame.size.height - 128.0f, self.overlayView.frame.size.width, 128.0f);
                
                self.lineX1View.frame = CGRectMake(self.overlayView.frame.size.width/3.0f, 0.0f, 1.0f, self.overlayView.frame.size.height);
                self.lineX2View.frame = CGRectMake(self.overlayView.frame.size.width/3.0f*2.0f, 0.0f, 1.0f, self.overlayView.frame.size.height);
                self.lineY1View.frame = CGRectMake(0.0f, (self.overlayView.frame.size.height - 256.0f)/3.0f + 128.0f, self.overlayView.frame.size.width, 1.0f);
                self.lineY2View.frame = CGRectMake(0.0f, (self.overlayView.frame.size.height - 256.0f)/3.0f*2.0f + 128.0f, self.overlayView.frame.size.width, 1.0f);
                break;
            case UIInterfaceOrientationPortraitUpsideDown:
                self.topBlackView.frame = CGRectMake(0.0f, 0.0f, self.overlayView.frame.size.width, 128.0f);
                self.bottomBlackView.frame = CGRectMake(0.0f, self.overlayView.frame.size.height - 128.0f, self.overlayView.frame.size.width, 128.0f);
                
                self.lineX1View.frame = CGRectMake(self.overlayView.frame.size.width/3.0f, 0.0f, 1.0f, self.overlayView.frame.size.height);
                self.lineX2View.frame = CGRectMake(self.overlayView.frame.size.width/3.0f*2.0f, 0.0f, 1.0f, self.overlayView.frame.size.height);
                self.lineY1View.frame = CGRectMake(0.0f, (self.overlayView.frame.size.height - 256.0f)/3.0f + 128.0f, self.overlayView.frame.size.width, 1.0f);
                self.lineY2View.frame = CGRectMake(0.0f, (self.overlayView.frame.size.height - 256.0f)/3.0f*2.0f + 128.0f, self.overlayView.frame.size.width, 1.0f);
                break;
            case UIInterfaceOrientationLandscapeLeft:
                self.topBlackView.frame = CGRectMake(0.0f, 0.0f, 128.0f, self.overlayView.frame.size.height);
                self.bottomBlackView.frame = CGRectMake(self.overlayView.frame.size.width - 128.0f, 0.0f, 128.0f, self.overlayView.frame.size.height);
                
                self.lineX1View.frame = CGRectMake(0.0f, self.overlayView.frame.size.height/3.0f, self.overlayView.frame.size.width, 1.0f);
                self.lineX2View.frame = CGRectMake(0.0f, self.overlayView.frame.size.height/3.0f*2.0f, self.overlayView.frame.size.width, 1.0f);
                self.lineY1View.frame = CGRectMake((self.overlayView.frame.size.width - 256.0f)/3.0f + 128.0f, 0.0f, 1.0f, self.overlayView.frame.size.height);
                self.lineY2View.frame = CGRectMake((self.overlayView.frame.size.width - 256.0f)/3.0f*2.0f + 128.0f, 0.0f, 1.0f, self.overlayView.frame.size.height);
                break;
            case UIInterfaceOrientationLandscapeRight:
                self.topBlackView.frame = CGRectMake(0.0f, 0.0f, 128.0f, self.overlayView.frame.size.height);
                self.bottomBlackView.frame = CGRectMake(self.overlayView.frame.size.width - 128.0f, 0.0f, 128.0f, self.overlayView.frame.size.height);
                
                self.lineX1View.frame = CGRectMake(0.0f, self.overlayView.frame.size.height/3.0f, self.overlayView.frame.size.width, 1.0f);
                self.lineX2View.frame = CGRectMake(0.0f, self.overlayView.frame.size.height/3.0f*2.0f, self.overlayView.frame.size.width, 1.0f);
                self.lineY1View.frame = CGRectMake((self.overlayView.frame.size.width - 256.0f)/3.0f + 128.0f, 0.0f, 1.0f, self.overlayView.frame.size.height);
                self.lineY2View.frame = CGRectMake((self.overlayView.frame.size.width - 256.0f)/3.0f*2.0f + 128.0f, 0.0f, 1.0f, self.overlayView.frame.size.height);
                break;
                
            default:
                break;
        }
    }
    
    
    //gray view
    self.grayView = [[UIView alloc] initWithFrame:CGRectMake(self.overlayView.frame.size.width - 100.0f, 0.0f, 100.0f, self.overlayView.frame.size.height)];
    [self.grayView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.3f]];
    self.grayView.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                                      UIViewAutoresizingFlexibleRightMargin |
                                      UIViewAutoresizingFlexibleTopMargin |
                                      UIViewAutoresizingFlexibleHeight |
                                      UIViewAutoresizingFlexibleBottomMargin);
    [self.overlayView addSubview:self.grayView];
    
    //front back button
    self.fronBackBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.fronBackBtn setImage:[UIImage imageNamed:@"front_back"] forState:UIControlStateNormal];
    [self.fronBackBtn setFrame:CGRectMake(self.grayView.frame.size.width - 68.9f, 30.0f, 37.8f, 29.4f)];
    self.fronBackBtn.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                                         UIViewAutoresizingFlexibleRightMargin |
                                         UIViewAutoresizingFlexibleTopMargin |
                                         UIViewAutoresizingFlexibleBottomMargin);
    [self.fronBackBtn addTarget:self action:@selector(onFrontBackCamera:) forControlEvents:UIControlEventTouchUpInside];
    [self.grayView addSubview:self.fronBackBtn];
    
    //red dot
    self.redDotImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.grayView.frame.size.width - 67.5f, 100.0f, 35.0f, 35.0f)];
    [self.redDotImageView setImage:[UIImage imageNamed:@"red_dot"]];
    [self.redDotImageView setBackgroundColor:[UIColor clearColor]];
    self.redDotImageView.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                                             UIViewAutoresizingFlexibleRightMargin |
                                             UIViewAutoresizingFlexibleTopMargin |
                                             UIViewAutoresizingFlexibleBottomMargin);
    [self.grayView addSubview:self.redDotImageView];
    
    //multiple count label
    self.multipleCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.grayView.frame.size.width - 67.5f, 100.0f, 35.0f, 35.0f)];
    [self.multipleCountLabel setBackgroundColor:[UIColor clearColor]];
    [self.multipleCountLabel setText:@"0"];
    [self.multipleCountLabel setTextColor:[UIColor whiteColor]];
    [self.multipleCountLabel setMinimumScaleFactor:0.1f];
    [self.multipleCountLabel setTextAlignment:NSTextAlignmentCenter];
    [self.multipleCountLabel setAdjustsFontSizeToFitWidth:YES];
    self.multipleCountLabel.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                                                UIViewAutoresizingFlexibleRightMargin |
                                                UIViewAutoresizingFlexibleTopMargin |
                                                UIViewAutoresizingFlexibleBottomMargin);
    [self.grayView addSubview:self.multipleCountLabel];
    
    //multiple count title label
    self.multipleTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.grayView.frame.size.width - 80.0f, 210.0f, 60.0f, 35.0f)];
    [self.multipleTitleLabel setBackgroundColor:[UIColor clearColor]];
    [self.multipleTitleLabel setText:@"MULTIPLE"];
    [self.multipleTitleLabel setFont:[UIFont fontWithName:MYRIADPRO size:12.0f]];
    [self.multipleTitleLabel setTextColor:[UIColor whiteColor]];
    [self.multipleTitleLabel setMinimumScaleFactor:0.1f];
    [self.multipleTitleLabel setAdjustsFontSizeToFitWidth:YES];
    [self.multipleTitleLabel setTextAlignment:NSTextAlignmentCenter];
    self.multipleTitleLabel.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                                                UIViewAutoresizingFlexibleRightMargin |
                                                UIViewAutoresizingFlexibleTopMargin |
                                                UIViewAutoresizingFlexibleBottomMargin);
    [self.grayView addSubview:self.multipleTitleLabel];
    
    //photos switch
    self.photosSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
    [self.photosSwitch setFrame:CGRectMake(self.grayView.frame.size.width - 50.0f - self.photosSwitch.frame.size.width/2, 185.0f, self.photosSwitch.frame.size.width, self.photosSwitch.frame.size.height)];
    [self.photosSwitch addTarget:self action:@selector(onChangedPhotoSwitch) forControlEvents:UIControlEventValueChanged];
    [self.photosSwitch setBackgroundColor:[UIColor clearColor]];
    self.photosSwitch.on = NO;
    self.photosSwitch.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                                          UIViewAutoresizingFlexibleRightMargin |
                                          UIViewAutoresizingFlexibleTopMargin |
                                          UIViewAutoresizingFlexibleBottomMargin);
    [self.grayView addSubview:self.photosSwitch];
    
    //photos title lable
    self.photosTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.grayView.frame.size.width - 80.0f, 130.0f, 60.0f, 35.0f)];
    [self.photosTitleLabel setBackgroundColor:[UIColor clearColor]];
    [self.photosTitleLabel setText:@"PHOTOS"];
    [self.photosTitleLabel setFont:[UIFont fontWithName:MYRIADPRO size:12.0f]];
    [self.photosTitleLabel setTextColor:[UIColor whiteColor]];
    [self.photosTitleLabel setMinimumScaleFactor:0.1f];
    [self.photosTitleLabel setAdjustsFontSizeToFitWidth:YES];
    [self.photosTitleLabel setTextAlignment:NSTextAlignmentCenter];
    self.photosTitleLabel.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                                              UIViewAutoresizingFlexibleRightMargin |
                                              UIViewAutoresizingFlexibleTopMargin |
                                              UIViewAutoresizingFlexibleBottomMargin);
    [self.grayView addSubview:self.photosTitleLabel];
    
    //take photo button
    self.takeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.takeBtn setImage:[UIImage imageNamed:@"photo_take_on"] forState:UIControlStateNormal];
    [self.takeBtn setImage:[UIImage imageNamed:@"photo_take_off"] forState:UIControlStateSelected];
    [self.takeBtn setImage:[UIImage imageNamed:@"photo_take_off"] forState:UIControlStateHighlighted];
    [self.takeBtn setFrame:CGRectMake(self.grayView.frame.size.width - 83.25f, self.grayView.frame.size.height/2.0f - 33.25f, 66.5f, 66.5f)];
    self.takeBtn.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                                     UIViewAutoresizingFlexibleRightMargin |
                                     UIViewAutoresizingFlexibleTopMargin |
                                     UIViewAutoresizingFlexibleBottomMargin);
    [self.takeBtn addTarget:self action:@selector(onTakePhoto:) forControlEvents:UIControlEventTouchUpInside];
    [self.grayView addSubview:self.takeBtn];
    
    //usePhotos button
    self.usePhotosBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.usePhotosBtn setTitle:@"Use Photos" forState:UIControlStateNormal];
    [self.usePhotosBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.usePhotosBtn setTitleColor:[UIColor grayColor] forState:UIControlStateSelected];
    self.usePhotosBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    [self.usePhotosBtn.titleLabel setFont:[UIFont fontWithName:MYRIADPRO size:14.0f]];
    self.usePhotosBtn.layer.borderWidth = 1.0f;
    self.usePhotosBtn.layer.cornerRadius = 3.0f;
    [self.usePhotosBtn.titleLabel setMinimumScaleFactor:0.1f];
    [self.usePhotosBtn.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [self.usePhotosBtn.titleLabel setAdjustsFontSizeToFitWidth:YES];
    [self.usePhotosBtn setFrame:CGRectMake(self.grayView.frame.size.width - 90.0f, self.grayView.frame.size.height - 110.0f, 80.0f, 30.0f)];
    self.usePhotosBtn.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                                          UIViewAutoresizingFlexibleRightMargin |
                                          UIViewAutoresizingFlexibleTopMargin |
                                          UIViewAutoresizingFlexibleBottomMargin);
    [self.usePhotosBtn addTarget:self action:@selector(onUsePhotos:) forControlEvents:UIControlEventTouchUpInside];
    [self.grayView addSubview:self.usePhotosBtn];
    
    //cancel button
    self.cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.cancelBtn setTitle:@"Cancel" forState:UIControlStateNormal];
    [self.cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.cancelBtn setTitleColor:[UIColor grayColor] forState:UIControlStateSelected];
    [self.cancelBtn.titleLabel setFont:[UIFont fontWithName:MYRIADPRO size:14.0f]];
    self.cancelBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    self.cancelBtn.layer.borderWidth = 1.0f;
    self.cancelBtn.layer.cornerRadius = 3.0f;
    [self.cancelBtn setFrame:CGRectMake(self.grayView.frame.size.width - 90.0f, self.grayView.frame.size.height - 60.0f, 80.0f, 30.0f)];
    self.cancelBtn.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                                       UIViewAutoresizingFlexibleRightMargin |
                                       UIViewAutoresizingFlexibleTopMargin |
                                       UIViewAutoresizingFlexibleBottomMargin);
    [self.cancelBtn addTarget:self action:@selector(onCancelCamera:) forControlEvents:UIControlEventTouchUpInside];
    [self.grayView addSubview:self.cancelBtn];
    
    [self.redDotImageView setAlpha:0.2f];
    [self.multipleCountLabel setAlpha:0.2f];
    [self.multipleTitleLabel setAlpha:0.2f];
    [self.usePhotosBtn setAlpha:0.2f];
    [self.usePhotosBtn setUserInteractionEnabled:NO];
}


- (void)initVideoCameraOverlayViewForiPhone5
{
    if (templateIndex == TEMPLATE_SQUARE)
    {
        self.topBlackView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.overlayView.frame.size.width, (self.overlayView.frame.size.height - self.overlayView.frame.size.width)/2)];
        [self.topBlackView setBackgroundColor:[UIColor blackColor]];
        self.topBlackView.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                                              UIViewAutoresizingFlexibleRightMargin |
                                              UIViewAutoresizingFlexibleTopMargin |
                                              UIViewAutoresizingFlexibleBottomMargin|
                                              UIViewAutoresizingFlexibleWidth);
        [self.overlayView addSubview:self.topBlackView];
        
        self.bottomBlackView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, self.overlayView.frame.size.height - (self.overlayView.frame.size.height - self.overlayView.frame.size.width)/2, self.overlayView.frame.size.width, (self.overlayView.frame.size.height - self.overlayView.frame.size.width)/2)];
        [self.bottomBlackView setBackgroundColor:[UIColor blackColor]];
        self.bottomBlackView.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                                                 UIViewAutoresizingFlexibleRightMargin |
                                                 UIViewAutoresizingFlexibleTopMargin |
                                                 UIViewAutoresizingFlexibleBottomMargin|
                                                 UIViewAutoresizingFlexibleWidth);
        [self.overlayView addSubview:self.bottomBlackView];
    }

    self.grayView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, self.overlayView.frame.size.height - 80.0f, self.overlayView.frame.size.width, 80.0f)];
    [self.grayView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.3f]];
    self.grayView.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                                      UIViewAutoresizingFlexibleRightMargin |
                                      UIViewAutoresizingFlexibleTopMargin |
                                      UIViewAutoresizingFlexibleWidth |
                                      UIViewAutoresizingFlexibleBottomMargin);
    [self.overlayView addSubview:self.grayView];
    
    self.topGrayView = [[UIView alloc] initWithFrame:CGRectMake(self.overlayView.frame.size.width/4, 20.0f, self.overlayView.frame.size.width/2, 30.0f)];
    [self.topGrayView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.3f]];
    self.topGrayView.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                                         UIViewAutoresizingFlexibleRightMargin |
                                         UIViewAutoresizingFlexibleTopMargin |
                                         UIViewAutoresizingFlexibleWidth |
                                         UIViewAutoresizingFlexibleBottomMargin);
    self.topGrayView.layer.cornerRadius = 5.0f;
    [self.overlayView addSubview:self.topGrayView];
    
    //front back button
    self.fronBackBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.fronBackBtn setImage:[UIImage imageNamed:@"front_back"] forState:UIControlStateNormal];
    [self.fronBackBtn setFrame:CGRectMake(self.overlayView.frame.size.width - 40.0f, 25.0f, 26.0f, 20.0f)];
    self.fronBackBtn.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                                         UIViewAutoresizingFlexibleRightMargin |
                                         UIViewAutoresizingFlexibleTopMargin |
                                         UIViewAutoresizingFlexibleBottomMargin);
    [self.fronBackBtn addTarget:self action:@selector(onFrontBackCamera:) forControlEvents:UIControlEventTouchUpInside];
    [self.overlayView addSubview:self.fronBackBtn];
    
    //take photo button
    self.takeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.takeBtn setImage:[UIImage imageNamed:@"video_take_on"] forState:UIControlStateNormal];
    [self.takeBtn setImage:[UIImage imageNamed:@"video_take_off"] forState:UIControlStateSelected];
    [self.takeBtn setImage:[UIImage imageNamed:@"video_take_off"] forState:UIControlStateHighlighted];
    [self.takeBtn setFrame:CGRectMake(self.overlayView.frame.size.width/2 - 35.0f, self.overlayView.frame.size.height - 75.0f, 70.0f, 70.0f)];
    self.takeBtn.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                                     UIViewAutoresizingFlexibleRightMargin |
                                     UIViewAutoresizingFlexibleTopMargin |
                                     UIViewAutoresizingFlexibleBottomMargin);
    [self.takeBtn addTarget:self action:@selector(onTakeVideo:) forControlEvents:UIControlEventTouchUpInside];
    [self.overlayView addSubview:self.takeBtn];
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width > [UIScreen mainScreen].bounds.size.height ? [UIScreen mainScreen].bounds.size.height : [UIScreen mainScreen].bounds.size.width;
    
    //cancel button
    self.cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.cancelBtn setTitle:@"Cancel" forState:UIControlStateNormal];
    [self.cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.cancelBtn setTitleColor:[UIColor grayColor] forState:UIControlStateSelected];
    self.cancelBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    self.cancelBtn.layer.borderWidth = 1.0f;
    self.cancelBtn.layer.cornerRadius = 3.0f;
    [self.cancelBtn.titleLabel setMinimumScaleFactor:0.1f];
    [self.cancelBtn.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [self.cancelBtn.titleLabel setAdjustsFontSizeToFitWidth:YES];
    [self.cancelBtn.titleLabel setFont:[UIFont fontWithName:MYRIADPRO size:14.0f]];
    [self.cancelBtn setFrame:CGRectMake(screenWidth - 100.0f, self.overlayView.frame.size.height - 57.5f, 80.0f, 35.0f)];
    self.cancelBtn.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                                       UIViewAutoresizingFlexibleRightMargin |
                                       UIViewAutoresizingFlexibleTopMargin |
                                       UIViewAutoresizingFlexibleBottomMargin);
    [self.cancelBtn addTarget:self action:@selector(onCancelCamera:) forControlEvents:UIControlEventTouchUpInside];
    [self.overlayView addSubview:self.cancelBtn];
    
    //recoding time count label
    self.timeCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.overlayView.frame.size.width - 90.0f, self.overlayView.frame.size.height/4.0f - 14.5f, 85.0f, 35.0f)];
    [self.timeCountLabel setBackgroundColor:[UIColor clearColor]];
    [self.timeCountLabel setText:@"00:00:00"];
    [self.timeCountLabel setTextColor:[UIColor whiteColor]];
    [self.timeCountLabel setMinimumScaleFactor:0.1f];
    [self.timeCountLabel setTextAlignment:NSTextAlignmentCenter];
    [self.timeCountLabel setAdjustsFontSizeToFitWidth:YES];
    self.timeCountLabel.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                                            UIViewAutoresizingFlexibleRightMargin |
                                            UIViewAutoresizingFlexibleTopMargin |
                                            UIViewAutoresizingFlexibleBottomMargin);
    [self.overlayView addSubview:self.timeCountLabel];
    self.timeCountLabel.center = CGPointMake(self.overlayView.frame.size.width/2, self.fronBackBtn.center.y);
    
    //red dot
    self.redDotImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.overlayView.frame.size.width - 93.0f, self.overlayView.frame.size.height/4.0f, 6.0f, 6.0f)];
    [self.redDotImageView setImage:[UIImage imageNamed:@"red_dot"]];
    [self.redDotImageView setBackgroundColor:[UIColor clearColor]];
    self.redDotImageView.autoresizingMask = (UIViewAutoresizingFlexibleRightMargin |
                                             UIViewAutoresizingFlexibleTopMargin |
                                             UIViewAutoresizingFlexibleBottomMargin);
    [self.overlayView addSubview:self.redDotImageView];
    self.redDotImageView.center = CGPointMake(self.timeCountLabel.frame.origin.x - 3.0f, self.fronBackBtn.center.y);
    self.redDotImageView.hidden = YES;
    [self.usePhotosBtn setUserInteractionEnabled:NO];
}

- (void)initVideoCameraOverlayViewForiPhone4
{
    if (templateIndex == TEMPLATE_1080P)
    {
        self.topBlackView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 25.0f, self.overlayView.frame.size.height)];
        [self.topBlackView setBackgroundColor:[UIColor blackColor]];
        self.topBlackView.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                                              UIViewAutoresizingFlexibleRightMargin |
                                              UIViewAutoresizingFlexibleTopMargin |
                                              UIViewAutoresizingFlexibleBottomMargin|
                                              UIViewAutoresizingFlexibleWidth);
        [self.overlayView addSubview:self.topBlackView];
        
        self.bottomBlackView = [[UIView alloc] initWithFrame:CGRectMake(self.overlayView.frame.size.width - 25.0f, 0.0f, 25.0f, self.overlayView.frame.size.height)];
        [self.bottomBlackView setBackgroundColor:[UIColor blackColor]];
        self.bottomBlackView.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                                                 UIViewAutoresizingFlexibleRightMargin |
                                                 UIViewAutoresizingFlexibleTopMargin |
                                                 UIViewAutoresizingFlexibleBottomMargin|
                                                 UIViewAutoresizingFlexibleWidth);
        [self.overlayView addSubview:self.bottomBlackView];
    }
    else if (templateIndex == TEMPLATE_SQUARE)
    {
        self.topBlackView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.overlayView.frame.size.width, 80.0f)];
        [self.topBlackView setBackgroundColor:[UIColor blackColor]];
        self.topBlackView.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                                              UIViewAutoresizingFlexibleRightMargin |
                                              UIViewAutoresizingFlexibleTopMargin |
                                              UIViewAutoresizingFlexibleBottomMargin|
                                              UIViewAutoresizingFlexibleWidth);
        [self.overlayView addSubview:self.topBlackView];
        
        self.bottomBlackView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, self.overlayView.frame.size.height - 80.0f, self.overlayView.frame.size.width, 80.0f)];
        [self.bottomBlackView setBackgroundColor:[UIColor blackColor]];
        self.bottomBlackView.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                                                 UIViewAutoresizingFlexibleRightMargin |
                                                 UIViewAutoresizingFlexibleTopMargin |
                                                 UIViewAutoresizingFlexibleBottomMargin|
                                                 UIViewAutoresizingFlexibleWidth);
        [self.overlayView addSubview:self.bottomBlackView];
    }

    //gray view
    self.grayView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, self.overlayView.frame.size.height - 80.0f, self.overlayView.frame.size.width, 80.0f)];
    [self.grayView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.3f]];
    self.grayView.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                                      UIViewAutoresizingFlexibleRightMargin |
                                      UIViewAutoresizingFlexibleTopMargin |
                                      UIViewAutoresizingFlexibleWidth |
                                      UIViewAutoresizingFlexibleBottomMargin);
    [self.overlayView addSubview:self.grayView];
    
    self.topGrayView = [[UIView alloc] initWithFrame:CGRectMake(self.overlayView.frame.size.width/4, 0.0f, self.overlayView.frame.size.width/2, 30.0f)];
    [self.topGrayView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.3f]];
    self.topGrayView.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                                         UIViewAutoresizingFlexibleRightMargin |
                                         UIViewAutoresizingFlexibleTopMargin |
                                         UIViewAutoresizingFlexibleWidth |
                                         UIViewAutoresizingFlexibleBottomMargin);
    self.topGrayView.layer.cornerRadius = 5.0f;
    [self.overlayView addSubview:self.topGrayView];
    
    //front back button
    self.fronBackBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.fronBackBtn setImage:[UIImage imageNamed:@"front_back"] forState:UIControlStateNormal];
    [self.fronBackBtn setFrame:CGRectMake(self.overlayView.frame.size.width - 40.0f, 25.0f, 26.0f, 20.0f)];
    self.fronBackBtn.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                                         UIViewAutoresizingFlexibleRightMargin |
                                         UIViewAutoresizingFlexibleTopMargin |
                                         UIViewAutoresizingFlexibleBottomMargin);
    [self.fronBackBtn addTarget:self action:@selector(onFrontBackCamera:) forControlEvents:UIControlEventTouchUpInside];
    [self.overlayView addSubview:self.fronBackBtn];
    
    //take photo button
    self.takeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.takeBtn setImage:[UIImage imageNamed:@"video_take_on"] forState:UIControlStateNormal];
    [self.takeBtn setImage:[UIImage imageNamed:@"video_take_off"] forState:UIControlStateSelected];
    [self.takeBtn setImage:[UIImage imageNamed:@"video_take_off"] forState:UIControlStateHighlighted];
    [self.takeBtn setFrame:CGRectMake(self.overlayView.frame.size.width/2 - 35.0f, self.overlayView.frame.size.height - 75.0f, 70.0f, 70.0f)];
    self.takeBtn.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                                     UIViewAutoresizingFlexibleRightMargin |
                                     UIViewAutoresizingFlexibleTopMargin |
                                     UIViewAutoresizingFlexibleBottomMargin);
    [self.takeBtn addTarget:self action:@selector(onTakeVideo:) forControlEvents:UIControlEventTouchUpInside];
    [self.overlayView addSubview:self.takeBtn];
    
    //cancel button
    self.cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.cancelBtn setTitle:@"Cancel" forState:UIControlStateNormal];
    [self.cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.cancelBtn setTitleColor:[UIColor grayColor] forState:UIControlStateSelected];
    self.cancelBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    self.cancelBtn.layer.borderWidth = 1.0f;
    self.cancelBtn.layer.cornerRadius = 3.0f;
    [self.cancelBtn.titleLabel setMinimumScaleFactor:0.1f];
    [self.cancelBtn.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [self.cancelBtn.titleLabel setAdjustsFontSizeToFitWidth:YES];
    [self.cancelBtn.titleLabel setFont:[UIFont fontWithName:MYRIADPRO size:14.0f]];
    [self.cancelBtn setFrame:CGRectMake(220.0f, self.overlayView.frame.size.height - 57.5f, 80.0f, 35.0f)];
    self.cancelBtn.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                                       UIViewAutoresizingFlexibleRightMargin |
                                       UIViewAutoresizingFlexibleTopMargin |
                                       UIViewAutoresizingFlexibleBottomMargin);
    [self.cancelBtn addTarget:self action:@selector(onCancelCamera:) forControlEvents:UIControlEventTouchUpInside];
    [self.overlayView addSubview:self.cancelBtn];
    
    //recoding time count label
    self.timeCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.overlayView.frame.size.width - 90.0f, self.overlayView.frame.size.height/4.0f - 14.5f, 85.0f, 35.0f)];
    [self.timeCountLabel setBackgroundColor:[UIColor clearColor]];
    [self.timeCountLabel setText:@"00:00:00"];
    [self.timeCountLabel setTextColor:[UIColor whiteColor]];
    [self.timeCountLabel setMinimumScaleFactor:0.1f];
    [self.timeCountLabel setTextAlignment:NSTextAlignmentCenter];
    [self.timeCountLabel setAdjustsFontSizeToFitWidth:YES];
    self.timeCountLabel.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                                            UIViewAutoresizingFlexibleRightMargin |
                                            UIViewAutoresizingFlexibleTopMargin |
                                            UIViewAutoresizingFlexibleBottomMargin);
    [self.overlayView addSubview:self.timeCountLabel];
    self.timeCountLabel.center = CGPointMake(self.overlayView.frame.size.width/2, self.fronBackBtn.center.y);
    
    //red dot
    self.redDotImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.overlayView.frame.size.width - 93.0f, self.overlayView.frame.size.height/4.0f, 6.0f, 6.0f)];
    [self.redDotImageView setImage:[UIImage imageNamed:@"red_dot"]];
    [self.redDotImageView setBackgroundColor:[UIColor clearColor]];
    self.redDotImageView.autoresizingMask = (UIViewAutoresizingFlexibleRightMargin |
                                             UIViewAutoresizingFlexibleTopMargin |
                                             UIViewAutoresizingFlexibleBottomMargin);
    [self.overlayView addSubview:self.redDotImageView];
    self.redDotImageView.center = CGPointMake(self.timeCountLabel.frame.origin.x - 3.0f, self.fronBackBtn.center.y);
    self.redDotImageView.hidden = YES;
}

- (void)initVideoCameraOverlayViewForiPad
{
    startOrientation = [[UIApplication sharedApplication] statusBarOrientation];

    if (templateIndex == TEMPLATE_1080P)
    {
        self.topBlackView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.overlayView.frame.size.width, 96.0f)];
        [self.topBlackView setBackgroundColor:[UIColor blackColor]];
        self.topBlackView.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                                              UIViewAutoresizingFlexibleRightMargin |
                                              UIViewAutoresizingFlexibleTopMargin |
                                              UIViewAutoresizingFlexibleBottomMargin|
                                              UIViewAutoresizingFlexibleWidth);
        [self.overlayView addSubview:self.topBlackView];
        
        self.bottomBlackView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, self.overlayView.frame.size.height - 96.0f, self.overlayView.frame.size.width, 96.0f)];
        [self.bottomBlackView setBackgroundColor:[UIColor blackColor]];
        self.bottomBlackView.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                                                 UIViewAutoresizingFlexibleRightMargin |
                                                 UIViewAutoresizingFlexibleTopMargin |
                                                 UIViewAutoresizingFlexibleBottomMargin|
                                                 UIViewAutoresizingFlexibleWidth);
        [self.overlayView addSubview:self.bottomBlackView];
        
        switch (startOrientation)
        {
            case UIInterfaceOrientationPortrait:
                self.topBlackView.frame = CGRectMake(0.0f, 0.0f, 96.0f, self.overlayView.frame.size.height);
                self.bottomBlackView.frame = CGRectMake(self.overlayView.frame.size.width - 96.0f, 0.0f, 96.0f, self.overlayView.frame.size.height);
                break;
            case UIInterfaceOrientationPortraitUpsideDown:
                self.topBlackView.frame = CGRectMake(0.0f, 0.0f, 96.0f, self.overlayView.frame.size.height);
                self.bottomBlackView.frame = CGRectMake(self.overlayView.frame.size.width - 96.0f, 0.0f, 96.0f, self.overlayView.frame.size.height);
                break;
            case UIInterfaceOrientationLandscapeLeft:
                self.topBlackView.frame = CGRectMake(0.0f, 0.0f, self.overlayView.frame.size.width, 96.0f);
                self.bottomBlackView.frame = CGRectMake(0.0f, self.overlayView.frame.size.height - 96.0f, self.overlayView.frame.size.width, 96.0f);
                break;
            case UIInterfaceOrientationLandscapeRight:
                self.topBlackView.frame = CGRectMake(0.0f, 0.0f, self.overlayView.frame.size.width, 96.0f);
                self.bottomBlackView.frame = CGRectMake(0.0f, self.overlayView.frame.size.height - 96.0f, self.overlayView.frame.size.width, 96.0f);
                break;
                
            default:
                break;
        }
    }
    else if (templateIndex == TEMPLATE_SQUARE)
    {
        self.topBlackView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.overlayView.frame.size.width, 128.0f)];
        [self.topBlackView setBackgroundColor:[UIColor blackColor]];
        self.topBlackView.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                                              UIViewAutoresizingFlexibleRightMargin |
                                              UIViewAutoresizingFlexibleTopMargin |
                                              UIViewAutoresizingFlexibleBottomMargin|
                                              UIViewAutoresizingFlexibleWidth);
        [self.overlayView addSubview:self.topBlackView];
        
        self.bottomBlackView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, self.overlayView.frame.size.height - 128.0f, self.overlayView.frame.size.width, 128.0f)];
        [self.bottomBlackView setBackgroundColor:[UIColor blackColor]];
        self.bottomBlackView.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                                                 UIViewAutoresizingFlexibleRightMargin |
                                                 UIViewAutoresizingFlexibleTopMargin |
                                                 UIViewAutoresizingFlexibleBottomMargin|
                                                 UIViewAutoresizingFlexibleWidth);
        [self.overlayView addSubview:self.bottomBlackView];
        
        
        switch (startOrientation)
        {
            case UIInterfaceOrientationPortrait:
                self.topBlackView.frame = CGRectMake(0.0f, 0.0f, self.overlayView.frame.size.width, 128.0f);
                self.bottomBlackView.frame = CGRectMake(0.0f, self.overlayView.frame.size.height - 128.0f, self.overlayView.frame.size.width, 128.0f);
                break;
            case UIInterfaceOrientationPortraitUpsideDown:
                self.topBlackView.frame = CGRectMake(0.0f, 0.0f, self.overlayView.frame.size.width, 128.0f);
                self.bottomBlackView.frame = CGRectMake(0.0f, self.overlayView.frame.size.height - 128.0f, self.overlayView.frame.size.width, 128.0f);
                break;
            case UIInterfaceOrientationLandscapeLeft:
                self.topBlackView.frame = CGRectMake(0.0f, 0.0f, 128.0f, self.overlayView.frame.size.height);
                self.bottomBlackView.frame = CGRectMake(self.overlayView.frame.size.width - 128.0f, 0.0f, 128.0f, self.overlayView.frame.size.height);
                break;
            case UIInterfaceOrientationLandscapeRight:
                self.topBlackView.frame = CGRectMake(0.0f, 0.0f, 128.0f, self.overlayView.frame.size.height);
                self.bottomBlackView.frame = CGRectMake(self.overlayView.frame.size.width - 128.0f, 0.0f, 128.0f, self.overlayView.frame.size.height);
                break;
                
            default:
                break;
        }
    }

    
    //gray view
    self.grayView = [[UIView alloc] initWithFrame:CGRectMake(self.overlayView.frame.size.width - 100.0f, 0.0f, 100.0f, self.overlayView.frame.size.height)];
    [self.grayView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.3f]];
    self.grayView.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                                      UIViewAutoresizingFlexibleRightMargin |
                                      UIViewAutoresizingFlexibleTopMargin |
                                      UIViewAutoresizingFlexibleHeight |
                                      UIViewAutoresizingFlexibleBottomMargin);
    [self.overlayView addSubview:self.grayView];
    
    //front back button
    self.fronBackBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.fronBackBtn setImage:[UIImage imageNamed:@"front_back"] forState:UIControlStateNormal];
    [self.fronBackBtn setFrame:CGRectMake(self.grayView.frame.size.width - 68.9f, 30.0f, 37.8f, 29.4f)];
    self.fronBackBtn.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                                         UIViewAutoresizingFlexibleRightMargin |
                                         UIViewAutoresizingFlexibleTopMargin |
                                         UIViewAutoresizingFlexibleBottomMargin);
    [self.fronBackBtn addTarget:self action:@selector(onFrontBackCamera:) forControlEvents:UIControlEventTouchUpInside];
    [self.grayView addSubview:self.fronBackBtn];
    
    //red dot
    self.redDotImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.grayView.frame.size.width - 93.0f, self.grayView.frame.size.height/4.0f, 6.0f, 6.0f)];
    [self.redDotImageView setImage:[UIImage imageNamed:@"red_dot"]];
    [self.redDotImageView setBackgroundColor:[UIColor clearColor]];
    self.redDotImageView.autoresizingMask = (UIViewAutoresizingFlexibleRightMargin |
                                             UIViewAutoresizingFlexibleTopMargin |
                                             UIViewAutoresizingFlexibleBottomMargin);
    [self.grayView addSubview:self.redDotImageView];
    self.redDotImageView.hidden = YES;
    
    //recoding time count label
    self.timeCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.grayView.frame.size.width - 90.0f, self.grayView.frame.size.height/4.0f - 14.5f, 85.0f, 35.0f)];
    [self.timeCountLabel setBackgroundColor:[UIColor clearColor]];
    [self.timeCountLabel setText:@"00:00:00"];
    [self.timeCountLabel setTextColor:[UIColor whiteColor]];
    [self.timeCountLabel setMinimumScaleFactor:0.1f];
    [self.timeCountLabel setTextAlignment:NSTextAlignmentCenter];
    [self.timeCountLabel setAdjustsFontSizeToFitWidth:YES];
    self.timeCountLabel.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                                            UIViewAutoresizingFlexibleRightMargin |
                                            UIViewAutoresizingFlexibleTopMargin |
                                            UIViewAutoresizingFlexibleBottomMargin);
    [self.grayView addSubview:self.timeCountLabel];
    
    //take photo button
    self.takeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.takeBtn setImage:[UIImage imageNamed:@"video_take_on"] forState:UIControlStateNormal];
    [self.takeBtn setImage:[UIImage imageNamed:@"video_take_off"] forState:UIControlStateSelected];
    [self.takeBtn setImage:[UIImage imageNamed:@"video_take_off"] forState:UIControlStateHighlighted];
    [self.takeBtn setFrame:CGRectMake(self.grayView.frame.size.width - 83.25f, self.grayView.frame.size.height/2.0f - 33.25f, 66.5f, 66.5f)];
    self.takeBtn.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                                     UIViewAutoresizingFlexibleRightMargin |
                                     UIViewAutoresizingFlexibleTopMargin |
                                     UIViewAutoresizingFlexibleBottomMargin);
    [self.takeBtn addTarget:self action:@selector(onTakeVideo:) forControlEvents:UIControlEventTouchUpInside];
    [self.grayView addSubview:self.takeBtn];
    
    //cancel button
    self.cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.cancelBtn setTitle:@"Cancel" forState:UIControlStateNormal];
    [self.cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.cancelBtn setTitleColor:[UIColor grayColor] forState:UIControlStateSelected];
    [self.cancelBtn.titleLabel setFont:[UIFont fontWithName:MYRIADPRO size:14.0f]];
    self.cancelBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    self.cancelBtn.layer.borderWidth = 1.0f;
    self.cancelBtn.layer.cornerRadius = 3.0f;
    [self.cancelBtn setFrame:CGRectMake(self.grayView.frame.size.width - 90.0f, self.grayView.frame.size.height - 60.0f, 80.0f, 30.0f)];
    self.cancelBtn.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                                       UIViewAutoresizingFlexibleRightMargin |
                                       UIViewAutoresizingFlexibleTopMargin |
                                       UIViewAutoresizingFlexibleBottomMargin);
    [self.cancelBtn addTarget:self action:@selector(onCancelCamera:) forControlEvents:UIControlEventTouchUpInside];
    [self.grayView addSubview:self.cancelBtn];
}

@end
