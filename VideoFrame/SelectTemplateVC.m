//
//  SelectTemplateVC.m
//  VideoFrame
//
//  Created by Yinjing Li on 11/13/13.
//  Copyright (c) 2013 Yinjing Li and Fredercik Weber. All rights reserved.
//

#import "SelectTemplateVC.h"

#import "Definition.h"
#import "MakeVideoVC.h"
#import "SettingsView.h"
#import "CustomModalView.h"
#import "ProjectManager.h"
#import "ProjectThumbView.h"
#import "SHKActivityIndicator.h"
#import "iCarousel.h"
#import "CustomAssetPickerController.h"
#import "YJLActionMenu.h"
#import "ProjectGalleryPickerController.h"
#import "MyCloudDocument.h"

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)


@interface SelectTemplateVC () <CustomModalViewDelegate, ProjectThumbViewDelegate, UIGestureRecognizerDelegate, iCarouselDelegate, iCarouselDataSource, CustomAssetPickerControllerDelegate, UINavigationControllerDelegate, SettingsViewDelegate, ProjectGalleryPickerControllerDelegate, UIAlertViewDelegate>

@property (retain, nonatomic) IBOutlet NSLayoutConstraint *bottomSpacing;
@property (retain, nonatomic) IBOutlet NSLayoutConstraint *topSpacing;
@property (retain, nonatomic) IBOutlet NSLayoutConstraint *iphoneInstagramWidth;
@property (retain, nonatomic) IBOutlet NSLayoutConstraint *iPadPortraitCenterX;
@property (retain, nonatomic) IBOutlet NSLayoutConstraint *iPhonePortraitCenterX;
@property float deltaX;
@property float deltaY;
@property float orgY;
@property float instagramOriX;
@end


@implementation SelectTemplateVC


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self)
    {
        // Custom initialization
    }
    
    return self;
}

-(BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _deltaX = 15.0f;
    _instagramOriX = self.tempInstagramBtn.center.x;
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];

    //check bundle build version
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *build = infoDictionary[(NSString*)kCFBundleVersionKey];
    self.versionLabel.text = [NSString stringWithFormat:@"v%@", build];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    tapGesture.delegate = self;
    [self.view addGestureRecognizer:tapGesture];
    [tapGesture setNumberOfTapsRequired:1];
    
    //detect Max FrameRate from Device
    [self detectFramePerSec];
    
    self.playBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    self.playBtn.layer.borderWidth = 2.0f;
    self.playBtn.layer.cornerRadius = self.playBtn.bounds.size.width/2.0f;
    self.playBtn.clipsToBounds = YES;
    
    _orgY = _savedProjectLabel.frame.origin.y;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)])
    {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    
    self.makeVideoVC = nil;
    
    isDeleteBtnShow = NO;
    isWorkspace = NO;
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown)
        {
            [self.tempInstagramBtn setImage:[UIImage imageNamed:@"instagram"] forState:UIControlStateNormal];
            [self.tempInstagramBtn setImage:[UIImage imageNamed:@"instagram"] forState:UIControlStateSelected];
            self.tempInstagramBtn.frame = CGRectMake(self.tempInstagramBtn.frame.origin.x, self.tempInstagramBtn.frame.origin.y, 92.0f, 122.0f);
            
            CGSize result = [[UIScreen mainScreen] bounds].size;
                    
                         //Load 4 inch xib
            _deltaX = 30;
            self.settingsBtn.center = CGPointMake(_deltaX, self.settingsBtn.center.y);
            self.settingLbl.center = CGPointMake( self.settingsBtn.center.x, self.settingLbl.center.y);
                
            self.infoBtn.center = CGPointMake( result.width - _deltaX, self.infoBtn.center.y);
            self.infoLbl.center = CGPointMake( self.infoBtn.center.x, self.settingLbl.center.y);
            self.savedProjectLabel.frame = CGRectMake( self.savedProjectLabel.frame.origin.x, _orgY, self.savedProjectLabel.frame.size.width, self.savedProjectLabel.frame.size.height);
        
            _topSpacing.constant = 50.0f;
            _bottomSpacing.constant = 50.0f;
            _iphoneInstagramWidth.constant = 80.0f;
            _iPhonePortraitCenterX.constant = -5.0f;
            
        }
        else
        {
            CGSize result = [[UIScreen mainScreen] bounds].size;
            float width = result.width;
            float rate = width / 568;
            
            _deltaX = 45 * rate;
            self.settingsBtn.center = CGPointMake(_deltaX, self.settingsBtn.center.y);
            self.settingLbl.center = CGPointMake( self.settingsBtn.center.x, self.settingLbl.center.y);
                
            self.infoBtn.center = CGPointMake( result.width - _deltaX, self.infoBtn.center.y);
            self.infoLbl.center = CGPointMake( self.infoBtn.center.x, self.settingLbl.center.y);
            
            _topSpacing.constant = 10.0f;
            _bottomSpacing.constant = 15.0f;
            _iphoneInstagramWidth.constant = 100.0f;
            _iPhonePortraitCenterX.constant = 0.0f;
        }
    }
    else
    {
        if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown)
        {
            [self.tempInstagramBtn setImage:[UIImage imageNamed:@"instagram"] forState:UIControlStateNormal];
            [self.tempInstagramBtn setImage:[UIImage imageNamed:@"instagram"] forState:UIControlStateSelected];
            self.tempInstagramBtn.frame = CGRectMake(self.tempInstagramBtn.frame.origin.x, self.tempInstagramBtn.frame.origin.y, 184.0f, 243.0f);
            self.tempInstagramBtn.center = CGPointMake( _instagramOriX, self.tempInstagramBtn.center.y);
            _iPadPortraitCenterX.constant = 15.f;
        }
        else if (orientation == UIInterfaceOrientationLandscapeRight || orientation == UIInterfaceOrientationLandscapeLeft)
        {
            [self.tempInstagramBtn setImage:[UIImage imageNamed:@"1080p"] forState:UIControlStateNormal];
            [self.tempInstagramBtn setImage:[UIImage imageNamed:@"1080p"] forState:UIControlStateSelected];
            self.tempInstagramBtn.frame = CGRectMake(self.tempInstagramBtn.frame.origin.x, self.tempInstagramBtn.frame.origin.y, 220.0f, 210.0f);
            
            _iPadPortraitCenterX.constant = 0.f;
        }
    }
    
    // init Settings View
    if (!self.settingsView)
    {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
            CGSize result = [[UIScreen mainScreen] bounds].size;
            float width = result.width;
            float height  = result.height;
            
            if (width > 730 || height > 730 ) {
                self.settingsView = [[[NSBundle mainBundle] loadNibNamed:@"SettingsView_iPad" owner:self options:nil] objectAtIndex:0];
            }else{
                self.settingsView = [[[NSBundle mainBundle] loadNibNamed:@"SettingsView" owner:self options:nil] objectAtIndex:0];
            }
        }
        else
            self.settingsView = [[[NSBundle mainBundle] loadNibNamed:@"SettingsView_iPad" owner:self options:nil] objectAtIndex:0];

        [self.settingsView initSettingsView];
        self.settingsView.delegate = self;
    }
    
    // get saved Projects
    [self getProjects];
    
    //check iCloud`s last updated date
    [self checkCloudsLastUpdateDate];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}


#pragma mark -
#pragma mark - orientation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        if ((toInterfaceOrientation == UIInterfaceOrientationPortrait || toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) && (orientation == UIInterfaceOrientationLandscapeRight || orientation == UIInterfaceOrientationLandscapeLeft))
        {
            [self.tempInstagramBtn setImage:[UIImage imageNamed:@"instagram"] forState:UIControlStateNormal];
            [self.tempInstagramBtn setImage:[UIImage imageNamed:@"instagram"] forState:UIControlStateSelected];
            self.tempInstagramBtn.frame = CGRectMake(self.tempInstagramBtn.frame.origin.x, self.tempInstagramBtn.frame.origin.y, 92.0f, 122.0f);
            
            _topSpacing.constant = 50.0f;
            _bottomSpacing.constant = 50.0f;
            _iphoneInstagramWidth.constant = 80.0f;
            _iPhonePortraitCenterX.constant = -5.0f;
        }
        else if ((toInterfaceOrientation == UIInterfaceOrientationLandscapeRight || toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft) && (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown))
        {
            [self.tempInstagramBtn setImage:[UIImage imageNamed:@"1080p"] forState:UIControlStateNormal];
            [self.tempInstagramBtn setImage:[UIImage imageNamed:@"1080p"] forState:UIControlStateSelected];
            self.tempInstagramBtn.frame = CGRectMake(self.tempInstagramBtn.frame.origin.x, self.tempInstagramBtn.frame.origin.y, 132.0f, 112.0f);

            _topSpacing.constant = 10.0f;
            _bottomSpacing.constant = 15.0f;
            _iphoneInstagramWidth.constant = 100.0f;
            _iPhonePortraitCenterX.constant = 0.0f;
        }
    }
    else
    {
        if ((toInterfaceOrientation == UIInterfaceOrientationPortrait || toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) && (orientation == UIInterfaceOrientationLandscapeRight || orientation == UIInterfaceOrientationLandscapeLeft))
        {
            [self.tempInstagramBtn setImage:[UIImage imageNamed:@"instagram"] forState:UIControlStateNormal];
            [self.tempInstagramBtn setImage:[UIImage imageNamed:@"instagram"] forState:UIControlStateSelected];
            self.tempInstagramBtn.frame = CGRectMake(self.tempInstagramBtn.frame.origin.x, self.tempInstagramBtn.frame.origin.y, 184.0f, 243.0f);
            _iPadPortraitCenterX.constant = 15.0f;
        }
        else if ((toInterfaceOrientation == UIInterfaceOrientationLandscapeRight || toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft) && (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown))
        {
            [self.tempInstagramBtn setImage:[UIImage imageNamed:@"1080p"] forState:UIControlStateNormal];
            [self.tempInstagramBtn setImage:[UIImage imageNamed:@"1080p"] forState:UIControlStateSelected];
            self.tempInstagramBtn.frame = CGRectMake(self.tempInstagramBtn.frame.origin.x, self.tempInstagramBtn.frame.origin.y, 220.0f, 210.0f);
            _iPadPortraitCenterX.constant = 0.0f;
        }
    }
    
    if (self.customModalView)
    {
        [self.customModalView hideCustomModalView];
        self.customModalView = nil;
    }
    
    if (self.settingsView != nil)
    {
        [self.settingsView hideActionSettingsView];
    }
    
    return;
}


#pragma mark -
#pragma mark - get device`s supported frame rate

-(void) detectFramePerSec
{
    
    grFrameRate = 30.0f;
    
    CGFloat maxRate = 30.0f;
    
    AVCaptureDevice* videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    for (AVCaptureDeviceFormat* vFormat in [videoDevice formats]) {
        CGFloat frameRate = ((AVFrameRateRange*)[vFormat.videoSupportedFrameRateRanges objectAtIndex:0]).maxFrameRate;
        
        if (frameRate > maxRate)
            maxRate = frameRate;
    }
    
    if (maxRate > 60.0f)
        grFrameRate = 60.0f;
    else if(maxRate > 30.0f)
        grFrameRate = 40.0f;
    else
        grFrameRate = 30.0f;
}


#pragma mark -
#pragma mark - Projects Processing

-(void) getProjects {
    
    [self.projectNamesArray removeAllObjects];
    self.projectNamesArray = nil;

    NSError *error;
    NSFileManager *localFileManager = [NSFileManager defaultManager];
    NSString* documentsPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSArray* filesArray = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsPath error:&error];
    NSArray* sortedFiles = nil;
    
    if (filesArray.count > 0) {
        NSMutableArray* filesAndProperties = [NSMutableArray arrayWithCapacity:[filesArray count]];
        
        for(NSString* file in filesArray) {
            error = nil;

            NSString* filePath = [documentsPath stringByAppendingPathComponent:file];
            NSDictionary* properties = [[NSFileManager defaultManager]
                                        attributesOfItemAtPath:filePath
                                        error:&error];
            NSDate* modDate = [properties objectForKey:NSFileModificationDate];
            
            if(error == nil) {
                [filesAndProperties addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                               file, @"path",
                                               modDate, @"lastModDate",
                                               nil]];
            }
        }
        
        sortedFiles = [filesAndProperties sortedArrayUsingComparator:
                                ^(id path1, id path2)
                                {
                                    NSComparisonResult comp = [[path2 objectForKey:@"lastModDate"] compare:
                                                               [path1 objectForKey:@"lastModDate"]];
                                    if (comp == NSOrderedDescending)
                                        comp = NSOrderedAscending;
                                    else if(comp == NSOrderedAscending)
                                        comp = NSOrderedDescending;

                                    return comp;
                                }];
    }
    
    [self.projectNamesArray removeAllObjects];
    self.projectNamesArray = nil;
    self.projectNamesArray = [[NSMutableArray alloc] init];

    [self.projectThumbViewArray removeAllObjects];
    self.projectThumbViewArray = nil;
    self.projectThumbViewArray = [[NSMutableArray alloc] init];
    
    for (int i=0; i<sortedFiles.count; i++) {
        NSDictionary* dict = [sortedFiles objectAtIndex:i];

        NSString* projectName = [dict objectForKey:@"path"];
        NSString* projectPath = [documentsPath stringByAppendingPathComponent:projectName];
        NSString* filePath = [projectPath stringByAppendingPathComponent:@"screenshot.png"];
        
        UIImage* screenshotImage = [UIImage imageWithContentsOfFile:filePath];
        
        if (screenshotImage) {
            [self.projectNamesArray addObject:[dict objectForKey:@"path"]];

            CGSize thumbSize = CGSizeMake(self.projectView.bounds.size.height*0.9f * 2.0f, self.projectView.bounds.size.height*0.9f);
            
            ProjectThumbView* thumbView = [[ProjectThumbView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, thumbSize.width, thumbSize.height) caption:projectName name:projectName image:screenshotImage];
            [thumbView setDelegate:self];
            
            [self.projectThumbViewArray addObject:thumbView];
        }
        else {
            [localFileManager removeItemAtPath:projectPath error:&error ];
            continue;
        }
    }
    
    localFileManager = nil;
    
    
    //Project Carousel

    if (!self.projectCarousel) {
        self.projectCarousel = [[iCarousel alloc] initWithFrame:self.projectView.bounds];
        self.projectCarousel.delegate = self;
        self.projectCarousel.dataSource = self;
        self.projectCarousel.backgroundColor = [UIColor clearColor];
        self.projectCarousel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
        [self.projectView addSubview:self.projectCarousel];
    }

    if (self.projectThumbViewArray.count > 5)
        self.projectCarousel.type = iCarouselTypeCylinder;
    else
        self.projectCarousel.type = iCarouselTypeCoverFlow;

    [self.projectCarousel reloadData];
    
    if (self.projectThumbViewArray.count == 0)
        self.savedProjectLabel.hidden = YES;
    else
        self.savedProjectLabel.hidden = NO;
    
}

-(void) tapGesture:(UITapGestureRecognizer*) gesture
{
    [self actionProjectDeleteDesabled];
}

-(void) actionProjectDeleteDesabled
{
    isDeleteBtnShow = NO;

    for (int i=0; i<self.projectThumbViewArray.count; i++)
    {
        ProjectThumbView* thumbView = [self.projectThumbViewArray objectAtIndex:i];
        thumbView.deleteBtn.hidden = YES;
        [thumbView.thumbImageView setUserInteractionEnabled:YES];
        [thumbView vibrateDesable];
    }
}


#pragma mark - 
#pragma mark - ProjectThumbViewDelegate

-(void) selectedProject:(NSString*) projectName
{
    gstrCurrentProjectName = [projectName copy];
    
    [[SHKActivityIndicator currentIndicator] displayActivity:(@"Opening...") isLock:YES];

    [self performSelector:@selector(openProject) withObject:nil afterDelay:0.02f];
}

-(void) deleteProject:(NSString*) projectName
{
    NSError *error;
    
    //delete project on the local directory
    NSString *docsDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString* projectPath = [docsDir stringByAppendingPathComponent:projectName];
    NSFileManager *localFileManager = [NSFileManager defaultManager];
    [localFileManager removeItemAtPath:projectPath error:&error ];
    
    //delete project on the array
    for (int i=0; i<self.projectNamesArray.count; i++)
    {
        NSString* name = [self.projectNamesArray objectAtIndex:i];
        
        if([projectName isEqualToString:name])
        {
            [self.projectNamesArray removeObjectAtIndex:i];
            
            ProjectThumbView* thumbView = [self.projectThumbViewArray objectAtIndex:i];
            [thumbView removeFromSuperview];
            [self.projectThumbViewArray removeObjectAtIndex:i];
            
            break;
        }
    }
    
    [localFileManager release];
    
    if (self.projectThumbViewArray.count > 5)
        self.projectCarousel.type = iCarouselTypeCylinder;
    else
        self.projectCarousel.type = iCarouselTypeCoverFlow;
    
    [self.projectCarousel reloadData];
}

-(void) actionProjectDeleteEnabled
{
    isDeleteBtnShow = YES;
    
    if (self.projectThumbViewArray.count == 0)
        isDeleteBtnShow = NO;
    
    for (int i=0; i<self.projectThumbViewArray.count; i++)
    {
        ProjectThumbView* thumbView = [self.projectThumbViewArray objectAtIndex:i];
        thumbView.deleteBtn.hidden = NO;
        [thumbView.thumbImageView setUserInteractionEnabled:NO];
        [thumbView vibrateEnable];
    }
}


#pragma mark -
#pragma mark - open project

-(void) openProject
{
    NSFileManager *localFileManager = [NSFileManager defaultManager];
    
    NSString *folderDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *folderPath = [folderDir stringByAppendingPathComponent:gstrCurrentProjectName];
    NSString* plistFileName = [folderPath stringByAppendingPathComponent:@"project.plist"];
    
    if ([localFileManager fileExistsAtPath:plistFileName])
    {
        NSMutableDictionary* plistDict = [[NSMutableDictionary alloc] initWithContentsOfFile:plistFileName];
        
        gnOrientation = [[plistDict objectForKey:@"gnOrientation"] intValue];
        gnInstagramOrientation = [[plistDict objectForKey:@"gnInstagramOrientation"] intValue];
        gnTemplateIndex = [[plistDict objectForKey:@"gnTemplateIndex"] intValue];
        
        if ((gnOrientation == ORIENTATION_LANDSCAPE)&&(gnTemplateIndex == TEMPLATE_LANDSCAPE))
        {
            if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
                gnVisibleMaxCount = 6;
            else
                gnVisibleMaxCount = 12;
        }
        else if ((gnOrientation == ORIENTATION_PORTRAIT)&&(gnTemplateIndex == TEMPLATE_PORTRAIT))
        {
            if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
            {
                if (isIPhoneFive)
                    gnVisibleMaxCount = 13;
                else
                    gnVisibleMaxCount = 10;
            }
            else
            {
                gnVisibleMaxCount = 17;
            }
        }
        else if ((gnOrientation == ORIENTATION_PORTRAIT)&&(gnTemplateIndex == TEMPLATE_SQUARE))
        {
            if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
            {
                if (isIPhoneFive)
                    gnVisibleMaxCount = 13;
                else
                    gnVisibleMaxCount = 10;
            }
            else
            {
                gnVisibleMaxCount = 17;
            }
        }
        else if ((gnOrientation == ORIENTATION_LANDSCAPE)&&(gnTemplateIndex == TEMPLATE_1080P))
        {
            if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
                gnVisibleMaxCount = 6;
            else
                gnVisibleMaxCount = 12;
        }
        
        [localFileManager release];
        [plistDict release];
    }
    else
    {
        [localFileManager release];
        
        [[SHKActivityIndicator currentIndicator] hide];

        return;
    }
    
    [self actionProjectDeleteDesabled];
    
    [self.customModalView hideCustomModalView];
    self.customModalView = nil;
    
    for (int i=0; i<self.projectThumbViewArray.count; i++)
    {
        ProjectThumbView* thumbView = [self.projectThumbViewArray objectAtIndex:i];
        [thumbView removeFromSuperview];
        thumbView = nil;
    }
    
    [self.projectThumbViewArray removeAllObjects];
    self.projectThumbViewArray = nil;
    
    [self.projectNamesArray removeAllObjects];
    self.projectNamesArray = nil;
    
    [self.projectCarousel removeFromSuperview];
    self.projectCarousel = nil;

    [self fixDeviceOrientation];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        self.makeVideoVC = [[MakeVideoVC alloc] initWithNibName:@"MakeVideoVC" bundle:nil];
    else
        self.makeVideoVC = [[MakeVideoVC alloc] initWithNibName:@"MakeVideoVC_iPad" bundle:[NSBundle mainBundle]];
    
    [self.navigationController pushViewController:self.makeVideoVC animated:NO];
}


-(void) fixDeviceOrientation
{
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    if((orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown)&&(gnTemplateIndex == TEMPLATE_LANDSCAPE || gnTemplateIndex == TEMPLATE_1080P))
    {
        NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:[[[UIDevice currentDevice] class] instanceMethodSignatureForSelector:@selector(setOrientation:)]];
        invocation.target = [UIDevice currentDevice];
        invocation.selector = @selector(setOrientation:);
        int orientationLandscapeRight = UIInterfaceOrientationLandscapeRight;
        [invocation setArgument:&orientationLandscapeRight atIndex:2];
        [invocation invoke];
    }
    else if((orientation == UIInterfaceOrientationLandscapeRight || orientation == UIInterfaceOrientationLandscapeLeft)&&(gnTemplateIndex == TEMPLATE_PORTRAIT || gnTemplateIndex == TEMPLATE_SQUARE))
    {
        NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:[[[UIDevice currentDevice] class] instanceMethodSignatureForSelector:@selector(setOrientation:)]];
        invocation.target = [UIDevice currentDevice];
        invocation.selector = @selector(setOrientation:);
        int orientationPortrait = UIInterfaceOrientationPortrait;
        [invocation setArgument:&orientationPortrait atIndex:2];
        [invocation invoke];
    }
}


#pragma mark -
#pragma mark - Select a template size

- (IBAction)onDidSelectTemplate:(id)sender
{
    [self actionProjectDeleteDesabled];

    [self.customModalView hideCustomModalView];
    self.customModalView = nil;
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];

    switch ([sender tag])
    {
        case 1://landscape
            gnOrientation = ORIENTATION_LANDSCAPE;
            gnTemplateIndex = TEMPLATE_LANDSCAPE;
            
            if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
                gnVisibleMaxCount = 6;
            else
                gnVisibleMaxCount = 12;

            break;
            
        case 2://portrait
            gnOrientation = ORIENTATION_PORTRAIT;
            gnTemplateIndex = TEMPLATE_PORTRAIT;
            
            if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
            {
                if (isIPhoneFive)
                    gnVisibleMaxCount = 13;
                else
                    gnVisibleMaxCount = 10;
            }
            else
            {
                gnVisibleMaxCount = 17;
            }
            
            break;
            
        case 3://square or 1080p
            if(orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown)
            {
                gnOrientation = ORIENTATION_PORTRAIT;
                gnInstagramOrientation = ORIENTATION_PORTRAIT;
                gnTemplateIndex = TEMPLATE_SQUARE;
                
                if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
                {
                    if (isIPhoneFive)
                        gnVisibleMaxCount = 13;
                    else
                        gnVisibleMaxCount = 10;
                }
                else
                {
                    gnVisibleMaxCount = 17;
                }
            }
            else if(orientation == UIInterfaceOrientationLandscapeRight || orientation == UIInterfaceOrientationLandscapeLeft)
            {
                gnOrientation = ORIENTATION_LANDSCAPE;
                gnInstagramOrientation = ORIENTATION_LANDSCAPE;
                gnTemplateIndex = TEMPLATE_1080P;
                
                if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
                    gnVisibleMaxCount = 6;
                else
                    gnVisibleMaxCount = 12;
            }
            
            break;
            
        default:
            break;
    }
    
    for (int i=0; i<self.projectThumbViewArray.count; i++)
    {
        ProjectThumbView* thumbView = [self.projectThumbViewArray objectAtIndex:i];
        [thumbView removeFromSuperview];
        thumbView = nil;
    }
    
    [self.projectThumbViewArray removeAllObjects];
    self.projectThumbViewArray = nil;

    [self.projectNamesArray removeAllObjects];
    self.projectNamesArray = nil;

    [self.projectCarousel removeFromSuperview];
    self.projectCarousel = nil;

    gstrCurrentProjectName = nil;

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        self.makeVideoVC = [[MakeVideoVC alloc] initWithNibName:@"MakeVideoVC" bundle:nil];
    else
        self.makeVideoVC = [[MakeVideoVC alloc] initWithNibName:@"MakeVideoVC_iPad" bundle:[NSBundle mainBundle]];
    
    [self.navigationController pushViewController:self.makeVideoVC animated:NO];
}


#pragma mark - 
#pragma mark - Settings Button Click Event

- (IBAction)onSettings:(id)sender
{
    [self actionProjectDeleteDesabled];

    [self.customModalView hideCustomModalView];
    self.customModalView = nil;
    
    [self.settingsView updateSettings];
    
    self.customModalView = [[CustomModalView alloc] initWithView:self.settingsView isCenter:YES];
    self.customModalView.delegate = self;
    self.customModalView.dismissButtonRight = YES;
    [self.customModalView show];
}


#pragma mark -
#pragma mark - Info Button Click Event

- (IBAction)onInfo:(id)sender
{
    [self actionProjectDeleteDesabled];
    
    NSArray *menuItems =
    @[
      [YJLActionMenuItem menuItem:@"Guide Video"
                            image:nil
                           target:self
                           action:@selector(actionInfoVideo)],
      
      [YJLActionMenuItem menuItem:@"How to remove iCloud documents"
                            image:nil
                           target:self
                           action:@selector(actionHowToRemoveICloud)],
      
      [YJLActionMenuItem menuItem:@"DreamClouds.Net"
                            image:nil
                           target:self
                           action:@selector(actionGoToDreamSite)],

      [YJLActionMenuItem menuItem:@"Vimeo Examples"
                            image:nil
                           target:self
                           action:@selector(actionGoToVimeoExamples)],

      [YJLActionMenuItem menuItem:@"Twitter User Group"
                            image:nil
                           target:self
                           action:@selector(actionGoToTwitter)],

      [YJLActionMenuItem menuItem:@"Facebook  Users Group"
                            image:nil
                           target:self
                           action:@selector(actionGoToFacebook)],

      [YJLActionMenuItem menuItem:@"Email Help"
                            image:nil
                           target:self
                           action:@selector(actionGoToEmail)],

      ];
    
    [YJLActionMenu showMenuInView:self.navigationController.view
                         fromRect:self.infoBtn.frame
                        menuItems:menuItems isWhiteBG:NO];
}

-(void) actionInfoVideo
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"VideoDreamTutorial" ofType:@"mp4" inDirectory:NO];
    NSURL *movieURL = [NSURL fileURLWithPath:path];
    
    if (self.infoVideoPlayer)
    {
        [self.infoVideoPlayer pause];
        [self.infoVideoPlayer.view removeFromSuperview];
        self.infoVideoPlayer = nil;
    }
    
    self.infoVideoPlayer = [[MPMoviePlayerController alloc] initWithContentURL:movieURL];
    self.infoVideoPlayer.view.frame = self.view.bounds;
    self.infoVideoPlayer.controlStyle = MPMovieControlStyleFullscreen;
    [self.view addSubview:self.infoVideoPlayer.view];
    self.infoVideoPlayer.repeatMode = MPMovieRepeatModeNone;
    [self.infoVideoPlayer prepareToPlay];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(myMovieFinishedCallback:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:self.infoVideoPlayer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayerPlaybackStateDidChange:) name:MPMoviePlayerPlaybackStateDidChangeNotification object:self.infoVideoPlayer];
    
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    if (UIInterfaceOrientationIsPortrait(orientation))
        gnOrientation = ORIENTATION_PORTRAIT;
    else if (UIInterfaceOrientationIsLandscape(orientation))
        gnOrientation = ORIENTATION_LANDSCAPE;
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) actionHowToRemoveICloud
{
    NSString* path = @"http://support.apple.com/kb/PH12794";
    NSURL* url = [NSURL URLWithString:path];
    
    [[UIApplication sharedApplication] openURL:url];
}

-(void) actionGoToDreamSite
{
    NSString* path = @"http://www.dreamclouds.net/";
    NSURL* url = [NSURL URLWithString:path];
    
    [[UIApplication sharedApplication] openURL:url];
}

-(void) actionGoToVimeoExamples
{
    NSString* path = @"http://vimeo.com/videodreamer";
    NSURL* url = [NSURL URLWithString:path];
    
    [[UIApplication sharedApplication] openURL:url];
}

-(void) actionGoToTwitter
{
    NSString* path = @"https://twitter.com/DreamCloudsApps";
    NSURL* url = [NSURL URLWithString:path];
    
    [[UIApplication sharedApplication] openURL:url];
}

-(void) actionGoToFacebook
{
    NSString* path = @"https://www.facebook.com/VideoDreamerUsers";
    NSURL* url = [NSURL URLWithString:path];
    
    [[UIApplication sharedApplication] openURL:url];
}

-(void) actionGoToEmail
{
    NSString* path = @"http://contact.dreamclouds.net";
    NSURL* url = [NSURL URLWithString:path];
    
    [[UIApplication sharedApplication] openURL:url];
}


#pragma mark -
#pragma mark - MPMoviePlayerController Delegate

- (void) moviePlayerPlaybackStateDidChange: (NSNotification *) notification
{
    if (self.infoVideoPlayer.playbackState == MPMoviePlaybackStateStopped)
    {
        [self.infoVideoPlayer setContentURL:[self.infoVideoPlayer contentURL]];
        [self.infoVideoPlayer play];
    }
}

-(void)myMovieFinishedCallback:(NSNotification*)aNotification
{
    self.infoVideoPlayer.currentPlaybackTime = 0.0f;
    
    if ((self.infoVideoPlayer.playbackState == MPMoviePlaybackStatePaused)||(self.infoVideoPlayer.playbackState == MPMoviePlaybackStateSeekingBackward))
    {
        [self.infoVideoPlayer pause];
        [self.infoVideoPlayer.view removeFromSuperview];
        self.infoVideoPlayer = nil;
        
        gnOrientation = ORIENTATION_ALL;
    }
}


#pragma mark -
#pragma mark - Play Saved Video

-(IBAction)actionPlaySavedVideo:(id)sender
{
    if ([PHPhotoLibrary authorizationStatus] == ALAuthorizationStatusDenied)
    {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Video Dreamer is unable to access Camera Roll"
                                  message:@"To enable access to the Camera Roll, follow these steps:\r\n Go to: Settings -> Privacy -> Photos and turn ON access for Video Dreamer."
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        
        [alertView show];
        
        return;
    }
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];

    if (UIInterfaceOrientationIsPortrait(orientation))
        gnOrientation = ORIENTATION_PORTRAIT;
    else if (UIInterfaceOrientationIsLandscape(orientation))
        gnOrientation = ORIENTATION_LANDSCAPE;
    
    if (!customAssetPicker)
    {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
        customAssetPicker = [sb instantiateViewControllerWithIdentifier:@"CustomAssetPickerController"];
        customAssetPicker.customAssetDelegate = self;
        customAssetPicker.filterType = PHAssetMediaTypeVideo;
    }
    
    [self presentViewController:customAssetPicker animated:YES completion:nil];
}


#pragma mark - 
#pragma mark - iCarousel

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    return self.projectThumbViewArray.count;
}

- (void)carouselDidScroll:(iCarousel *)carousel
{
    
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
    if (self.projectThumbViewArray.count > 0)
    {
        if (view == nil)
        {
            ProjectThumbView* thumbView = [self.projectThumbViewArray objectAtIndex:index];
            
            view = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.projectView.bounds.size.height*2.0f, self.projectView.bounds.size.height)];
            view.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.7f];
            view.layer.borderColor = [UIColor whiteColor].CGColor;
            view.layer.borderWidth = 1.0f;
            view.layer.cornerRadius = 5.0f;
            view.contentMode = UIViewContentModeScaleToFill;
            view.userInteractionEnabled = YES;
            [view addSubview:thumbView];
            
            thumbView.frame = CGRectMake((view.bounds.size.width-thumbView.bounds.size.width)/2.0f, (view.bounds.size.height-thumbView.bounds.size.height)/2.0f, thumbView.bounds.size.width, thumbView.bounds.size.height);
        }
    }
    else
    {
        return nil;
    }
    
    return view;
}

- (NSUInteger)numberOfPlaceholdersInCarousel:(iCarousel *)carousel
{
    return 2;
}

- (UIView *)carousel:(iCarousel *)carousel placeholderViewAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
    if (self.projectThumbViewArray.count > 0)
    {
        if (view == nil)
        {
            ProjectThumbView* thumbView = [self.projectThumbViewArray objectAtIndex:index];
            
            view = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.projectView.bounds.size.height*2.0f, self.projectView.bounds.size.height)];
            view.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.7f];
            view.layer.borderColor = [UIColor whiteColor].CGColor;
            view.layer.borderWidth = 1.0f;
            view.layer.cornerRadius = 5.0f;
            view.contentMode = UIViewContentModeScaleToFill;
            view.userInteractionEnabled = YES;
            [view addSubview:thumbView];
            
            thumbView.frame = CGRectMake((view.bounds.size.width-thumbView.bounds.size.width)/2.0f, (view.bounds.size.height-thumbView.bounds.size.height)/2.0f, thumbView.bounds.size.width, thumbView.bounds.size.height);
        }
    }
    else
    {
        return nil;
    }
    
    return view;
}

- (CATransform3D)carousel:(iCarousel *)_carousel itemTransformForOffset:(CGFloat)offset baseTransform:(CATransform3D)transform
{
    transform = CATransform3DRotate(transform, M_PI / 8.0f, 0.0f, 1.0f, 0.0f);

    return CATransform3DTranslate(transform, 0.0f, 0.0f, offset * _carousel.itemWidth);
}

- (CGFloat)carousel:(iCarousel *)_carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value
{
    switch (option)
    {
        case iCarouselOptionWrap:
        {
            return YES;
        }
        case iCarouselOptionSpacing:
        {
            return value * 1.05f;
        }
        case iCarouselOptionFadeMax:
        {
            if (_carousel.type == iCarouselTypeCustom)
                return 0.0f;

            return value;
        }
        default:
        {
            return value;
        }
    }
}


#pragma mark -
#pragma mark - CustomAssetPickerControllerDelegate

- (void)customAssetsPickerController:(CustomAssetPickerController *)picker didFinishPickingAssets:(NSArray *)assets
{
    dispatch_async(dispatch_get_main_queue(), ^{

        self.openInProjectVideoAsset = [assets objectAtIndex:0];

        [customAssetPicker dismissViewControllerAnimated:NO completion:^{
            customAssetPicker = nil;
            
            [[SHKActivityIndicator currentIndicator] hide];
        }];

        gnOrientation = ORIENTATION_LANDSCAPE;
        gnInstagramOrientation = ORIENTATION_LANDSCAPE;
        gnTemplateIndex = TEMPLATE_1080P;
        
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
        
        if(UIInterfaceOrientationIsPortrait(orientation))
        {
            NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:[[[UIDevice currentDevice] class] instanceMethodSignatureForSelector:@selector(setOrientation:)]];
            invocation.target = [UIDevice currentDevice];
            invocation.selector = @selector(setOrientation:);
            int orientationLandscapeRight = UIInterfaceOrientationLandscapeRight;
            [invocation setArgument:&orientationLandscapeRight atIndex:2];
            [invocation invoke];
        }

        [self performSelector:@selector(openInProjectWithVideo) withObject:nil afterDelay:0.5f];
    });
}

- (void)customAssetsPickerController:(CustomAssetPickerController *)picker didFinishPickingMovies:(NSArray *)movies
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        MPMediaItemCollection* item = [movies objectAtIndex:0];
        
        MPMediaItem *representativeItem = [item representativeItem];
        self.openInProjectVideoUrl = [representativeItem valueForProperty:MPMediaItemPropertyAssetURL];
        
        [customAssetPicker dismissViewControllerAnimated:NO completion:^{
            customAssetPicker = nil;
            
            [[SHKActivityIndicator currentIndicator] hide];
        }];
        
        gnOrientation = ORIENTATION_LANDSCAPE;
        gnInstagramOrientation = ORIENTATION_LANDSCAPE;
        gnTemplateIndex = TEMPLATE_1080P;
        
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
        
        if(UIInterfaceOrientationIsPortrait(orientation))
        {
            NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:[[[UIDevice currentDevice] class] instanceMethodSignatureForSelector:@selector(setOrientation:)]];
            invocation.target = [UIDevice currentDevice];
            invocation.selector = @selector(setOrientation:);
            int orientationLandscapeRight = UIInterfaceOrientationLandscapeRight;
            [invocation setArgument:&orientationLandscapeRight atIndex:2];
            [invocation invoke];
        }
        
        [self performSelector:@selector(openInProjectWithMovie) withObject:nil afterDelay:0.5f];
    });
}

-(void) openInProjectWithVideo
{
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        gnVisibleMaxCount = 6;
    else
        gnVisibleMaxCount = 12;
    
    for (int i=0; i<self.projectThumbViewArray.count; i++)
    {
        ProjectThumbView* thumbView = [self.projectThumbViewArray objectAtIndex:i];
        [thumbView removeFromSuperview];
        thumbView = nil;
    }
    
    [self.projectThumbViewArray removeAllObjects];
    self.projectThumbViewArray = nil;
    
    [self.projectNamesArray removeAllObjects];
    self.projectNamesArray = nil;
    
    [self.projectCarousel removeFromSuperview];
    self.projectCarousel = nil;

    gstrCurrentProjectName = nil;
    
    [[PHImageManager defaultManager] requestAVAssetForVideo:self.openInProjectVideoAsset options:nil resultHandler:^(AVAsset *avAsset, AVAudioMix *audioMix, NSDictionary *info) {
        
        if ([avAsset isKindOfClass:[AVURLAsset class]]) //normal video
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                self.openInProjectVideoUrl = [(AVURLAsset*)avAsset URL];
                
                if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
                    self.makeVideoVC = [[MakeVideoVC alloc] initWithNibName:@"MakeVideoVC" bundle:nil];
                else
                    self.makeVideoVC = [[MakeVideoVC alloc] initWithNibName:@"MakeVideoVC_iPad" bundle:[NSBundle mainBundle]];
                
                self.makeVideoVC.openInProjectVideoUrl = self.openInProjectVideoUrl;
                
                [self.navigationController pushViewController:self.makeVideoVC animated:NO];
                
            });
        }
        else  //Slow-Mo video
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [[PHImageManager defaultManager] requestImageDataForAsset:self.openInProjectVideoAsset options:nil resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
                    
                    self.openInProjectVideoUrl = [info objectForKey:@"PHImageFileURLKey"];
                    
                    if (self.openInProjectVideoUrl)
                    {
                        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
                            self.makeVideoVC = [[MakeVideoVC alloc] initWithNibName:@"MakeVideoVC" bundle:nil];
                        else
                            self.makeVideoVC = [[MakeVideoVC alloc] initWithNibName:@"MakeVideoVC_iPad" bundle:[NSBundle mainBundle]];
                        
                        self.makeVideoVC.openInProjectVideoUrl = self.openInProjectVideoUrl;
                        
                        [self.navigationController pushViewController:self.makeVideoVC animated:NO];
                    }
                }];
            });
        }
        
    }];
}


-(void) openInProjectWithMovie
{
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        gnVisibleMaxCount = 6;
    else
        gnVisibleMaxCount = 12;
    
    for (int i=0; i<self.projectThumbViewArray.count; i++)
    {
        ProjectThumbView* thumbView = [self.projectThumbViewArray objectAtIndex:i];
        [thumbView removeFromSuperview];
        thumbView = nil;
    }
    
    [self.projectThumbViewArray removeAllObjects];
    self.projectThumbViewArray = nil;
    
    [self.projectNamesArray removeAllObjects];
    self.projectNamesArray = nil;
    
    [self.projectCarousel removeFromSuperview];
    self.projectCarousel = nil;

    gstrCurrentProjectName = nil;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        self.makeVideoVC = [[MakeVideoVC alloc] initWithNibName:@"MakeVideoVC" bundle:nil];
    else
        self.makeVideoVC = [[MakeVideoVC alloc] initWithNibName:@"MakeVideoVC_iPad" bundle:[NSBundle mainBundle]];
    
    self.makeVideoVC.openInProjectVideoUrl = self.openInProjectVideoUrl;
    
    [self.navigationController pushViewController:self.makeVideoVC animated:NO];
}


- (void)customAssetsPickerControllerDidCancel:(CustomAssetPickerController *)picker
{
    [customAssetPicker dismissViewControllerAnimated:YES completion:^{
        customAssetPicker = nil;
        gnOrientation = ORIENTATION_ALL;
    }];
}

- (void)customAssetsPickerController:(CustomAssetPickerController *)picker failedWithError:(NSError *)error
{
    gnOrientation = ORIENTATION_ALL;
}


#pragma mark - 
#pragma mark - SettingsViewDelegate

-(void) didBackupProjects
{
    if (self.customModalView != nil)
    {
        [self.customModalView hideCustomModalView];
        self.customModalView = nil;
    }

    if (!projectGalleryPicker)
    {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"ProjectGalleryStoryboard" bundle:nil];
        projectGalleryPicker = [sb instantiateViewControllerWithIdentifier:@"ProjectGalleryPickerController"];
        projectGalleryPicker.projectGalleryPickerDelegate = self;
        projectGalleryPicker.isBackup = YES;
    }
    
    [self presentViewController:projectGalleryPicker animated:YES completion:nil];
}

-(void) didRestoreProjects
{
    if (self.customModalView != nil)
    {
        [self.customModalView hideCustomModalView];
        self.customModalView = nil;
    }

    if (!projectGalleryPicker)
    {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"ProjectGalleryStoryboard" bundle:nil];
        projectGalleryPicker = [sb instantiateViewControllerWithIdentifier:@"ProjectGalleryPickerController"];
        projectGalleryPicker.projectGalleryPickerDelegate = self;
        projectGalleryPicker.isBackup = NO;
    }
    
    [self presentViewController:projectGalleryPicker animated:YES completion:nil];
}


#pragma mark -
#pragma mark - ProjectGalleryPickerControllerDelegate

-(void) projectGalleryPickerControllerDidCancel:(ProjectGalleryPickerController *)picker
{
    [projectGalleryPicker dismissViewControllerAnimated:YES completion:^{
        projectGalleryPicker = nil;
    }];
}

-(void) checkCloudsLastUpdateDate
{
    NSFileManager* localFileManager = [NSFileManager defaultManager];
    NSString* folderDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Library"];
    NSString* plistFolderPath = [folderDir stringByAppendingPathComponent:@"Preferences"];
    NSString* plistFileName = [plistFolderPath stringByAppendingPathComponent:@"LastUpdate.plist"];
    
    BOOL isDirectory = NO;
    BOOL exist = [localFileManager fileExistsAtPath:plistFileName isDirectory:&isDirectory];
    
    if (exist)
    {
        NSMutableDictionary *plistDict = [[NSMutableDictionary alloc] initWithContentsOfFile:plistFileName];
        
        NSDate *lastUpdatedDate = [plistDict objectForKey:@"LastUpdatedDate"];
        NSDate *currentTime = [NSDate date];
        
        NSTimeInterval dateInterval = [currentTime timeIntervalSinceDate:lastUpdatedDate];
        
        NSInteger days = floor(dateInterval/86400.0f);

        if (days >= 9)
        {
            UIAlertView *alertView = [[UIAlertView alloc]
                                      initWithTitle:@"Video Dreamer"
                                      message:@"You have not Backed up app settings in 10 days… Would you like to back up now?"
                                      delegate:self
                                      cancelButtonTitle:@"Yes"
                                      otherButtonTitles:@"Remind me later", nil];
            [alertView show];
        }
    }
    else
    {
        [localFileManager createFileAtPath:plistFileName contents:nil attributes:nil];
        
        NSMutableDictionary* plistDict = [NSMutableDictionary dictionary];
        
        NSDate* currentDate = [NSDate date];

        [plistDict setObject:currentDate forKey:@"LastUpdatedDate"];
        [plistDict writeToFile:plistFileName atomically:YES];
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        [self actionProjectDeleteDesabled];
        
        [self.customModalView hideCustomModalView];
        self.customModalView = nil;
        
        [self.settingsView updateSettings];
        
        self.customModalView = [[CustomModalView alloc] initWithView:self.settingsView isCenter:YES];
        self.customModalView.delegate = self;
        self.customModalView.dismissButtonRight = YES;
        [self.customModalView show];
    }
}

@end
