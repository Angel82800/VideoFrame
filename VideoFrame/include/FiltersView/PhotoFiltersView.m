//
//  PhotoFiltersView.m
//  VideoFrame
//
//  Created by Yinjing Li on 9/12/14.
//  Copyright (c) 2014 Yinjing Li. All rights reserved.
//

#import "PhotoFiltersView.h"

#import <AssetsLibrary/AssetsLibrary.h>
#import <CoreImage/CoreImage.h>

#import "SHKActivityIndicator.h"
#import "Definition.h"
#import "UIImageExtras.h"
#import "YJLActionMenu.h"

@implementation PhotoFiltersView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];

    if (self)
    {
        self.backgroundColor = [UIColor blackColor];

        CGRect imageViewFrame = CGRectZero;
        CGRect scrollViewFrame = CGRectZero;
        CGRect originalThumbFrame = CGRectZero;
        
        selectedFilterValue = 0.5f;
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        {
            thumbWidth = 60.0f;
            thumbHeight = 80.0f;

            imageViewFrame = CGRectMake(50.0f, 50.0f, self.frame.size.width - 100.0f, self.frame.size.height - 150.0f);
            scrollViewFrame = CGRectMake(15.0f + thumbWidth, self.frame.size.height - 90.0f, self.frame.size.width - 25.0f - thumbWidth, 80.0f);
            originalThumbFrame = CGRectMake(10.0f, self.frame.size.height - 90.0f, thumbWidth, thumbHeight);
        }
        else
        {
            thumbWidth = 90.0f;
            thumbHeight = 120.0f;

            imageViewFrame = CGRectMake(100.0f, 70.0f, self.frame.size.width - 200.0f, self.frame.size.height - 210.0f);
            scrollViewFrame = CGRectMake(15.0f + thumbWidth, self.frame.size.height - 130.0f, self.frame.size.width - 25.0f - thumbWidth, 120.0f);
            originalThumbFrame = CGRectMake(10.0f, self.frame.size.height - 130.0f, thumbWidth, thumbHeight);
        }
        
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 10.0f, self.frame.size.width, 30.0f)];
        self.titleLabel.text = @"Choose Filter";
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
            self.titleLabel.font = [UIFont fontWithName:MYRIADPRO size:20];
        else
            self.titleLabel.font = [UIFont fontWithName:MYRIADPRO size:25];
        self.titleLabel.textColor = [UIColor whiteColor];
        [self addSubview:self.titleLabel];

        
        self.applyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.applyBtn setFrame:CGRectMake(self.frame.size.width - 55.0f, 10.0f, 45.0f, 30.0f)];
        [self.applyBtn setTitle:@" Apply " forState:UIControlStateNormal];
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
            [self.applyBtn.titleLabel setFont: [UIFont fontWithName:MYRIADPRO size:15]];
        else
            [self.applyBtn.titleLabel setFont: [UIFont fontWithName:MYRIADPRO size:20]];
        [self.applyBtn setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
        [self.applyBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        self.applyBtn.backgroundColor = [UIColor blackColor];
        self.applyBtn.layer.borderColor = [UIColor whiteColor].CGColor;
        self.applyBtn.layer.borderWidth = 1.0f;
        self.applyBtn.layer.cornerRadius = 5.0f;
        [self.applyBtn addTarget:self action:@selector(actionShowMenu) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.applyBtn];
        
        CGFloat labelWidth = [self.applyBtn.titleLabel.text sizeWithAttributes:@{NSFontAttributeName: self.applyBtn.titleLabel.font}].width;
        CGFloat labelHeight = [self.applyBtn.titleLabel.text sizeWithAttributes:@{NSFontAttributeName: self.applyBtn.titleLabel.font}].height;
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
            [self.applyBtn setFrame:CGRectMake(self.frame.size.width - (labelWidth + 15.0f), 10.0f, labelWidth + 10.0f, labelHeight + 15.0f)];
        else
            [self.applyBtn setFrame:CGRectMake(self.frame.size.width - (labelWidth + 25.0f), 10.0f, labelWidth + 20.0f, labelHeight + 20.0f)];

        
        self.imageView = [[UIImageView alloc] initWithFrame:imageViewFrame];
        self.imageView.backgroundColor = [UIColor clearColor];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:self.imageView];
        
        
        self.filterSlider = [[UISlider alloc] initWithFrame:CGRectMake(50.0f, self.imageView.frame.origin.y+self.imageView.frame.size.height-40.0f, self.frame.size.width - 100.0f, 40.0f)];
        [self.filterSlider setBackgroundColor:[UIColor clearColor]];
        [self.filterSlider setValue:selectedFilterValue];
        [self.filterSlider addTarget:self action:@selector(filterSliderChanged) forControlEvents:UIControlEventValueChanged];
        [self.filterSlider setMinimumValue:0.1f];
        [self.filterSlider setMaximumValue:1.0f];
        [self addSubview:self.filterSlider];

        
        self.filterScrollView = [[UIScrollView alloc] initWithFrame:scrollViewFrame];
        self.filterScrollView.backgroundColor = [UIColor clearColor];
        [self.filterScrollView setScrollEnabled:YES];
        [self.filterScrollView setShowsHorizontalScrollIndicator:YES];
        [self.filterScrollView setShowsVerticalScrollIndicator:NO];
        [self addSubview:self.filterScrollView];
        
        
        self.thumbArray = [[NSMutableArray alloc] init];
        selectedFilterIndex = 0;
        selectedFilterValue = 0.5f;

        
        /************************************* template code *************************************************/
        //thumbnail view
        
        PhotoFilterThumbView* thumbView = [[PhotoFilterThumbView alloc] initWithFrame:originalThumbFrame];
        [thumbView setIndex:0];
        [thumbView setName:@"Original"];
        thumbView.delegate = self;
        [self addSubview:thumbView];
        
        [self.thumbArray addObject:thumbView];

        NSArray* ciFilterNamesArray = [[NSArray alloc] initWithObjects:
                                       @"Original",
                                       @"Brightness",
                                       @"Saturation",
                                       @"Contrast",
                                       @"Blue",
                                       @"Green",
                                       @"Red",
                                       @"Brown",
                                       @"DarkGray",
                                       @"Gray",
                                       @"LightGray",
                                       @"Magenta",
                                       @"Orange",
                                       @"Purple",
                                       @"White",
                                       @"Yellow",
                                       @"Sepia",
                                       @"RedCross",
                                       @"GreenCross",
                                       @"BlueCross",
                                       @"Cube",
                                       @"Invert",
                                       @"Matrix",
                                       @"MonoChrome",
                                       @"Posterize",
                                       @"Convolution1",
                                       @"Convolution2",
                                       @"Convolution3",
                                       @"Convolution4",
                                       @"Exposure",
                                       @"FalseColor",
                                       @"GammaAdjust",
                                       @"ShadowAdjust",
                                       @"HueAdjust",
                                       @"LinearToSRGB",
                                       @"MaskToAlpha",
                                       @"MaxComponent",
                                       @"MinComponent",
                                       @"Chrome",
                                       @"Fade",
                                       @"Instant",
                                       @"Mono",
                                       @"Noir",
                                       @"Process",
                                       @"Tonal",
                                       @"Transfer",
                                       @"Pixellate",
                                       @"Sharpen",
                                       @"SRGBToLinear",
                                       @"Temperature",
                                       @"UnsharpMask",
                                       @"Vibrance",
                                       @"Vignette",
                                       @"WhitePoint",
                                       @"DotScreen",
                                       @"CircularScreen",
                                       @"HatchedScreen",
                                       @"LineScreen",
                                       @"Bloom",
                                       @"GaussianBlur",
                                       @"Gloom",
                                       @"PinchDistortion",
                                       @"VortexDistortion",
                                       nil];
        
        for (int i=1; i<ciFilterNamesArray.count; i++)
        {
            NSString* thumbName = [ciFilterNamesArray objectAtIndex:i];
            
            PhotoFilterThumbView* thumbView = [[PhotoFilterThumbView alloc] initWithFrame:CGRectMake((5.0f+thumbWidth)*(i-1), 0.0f, thumbWidth, thumbHeight)];
            [thumbView setIndex:i];
            [thumbView setName:thumbName];
            thumbView.delegate = self;
            [self.filterScrollView addSubview:thumbView];

            [self.thumbArray addObject:thumbView];
        }
        
        [self.filterScrollView setContentSize:CGSizeMake((5.0f+thumbWidth)*(self.thumbArray.count-1), thumbHeight)];
    }
    
    return self;
}

-(void) actionShowMenu
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSArray *menuItems = nil;
        
        menuItems =
        @[
          [YJLActionMenuItem menuItem:@"Cancel"
                                image:nil
                               target:self
                               action:@selector(didCancel)],
          
          [YJLActionMenuItem menuItem:@"Apply Filter"
                                image:nil
                               target:self
                               action:@selector(didApply)],
          
          [YJLActionMenuItem menuItem:@"Save to Album"
                                image:nil
                               target:self
                               action:@selector(didSaveFilterToAlbum)],
          ];
        
        [YJLActionMenu showMenuInView:self
                             fromRect:self.applyBtn.frame
                            menuItems:menuItems isWhiteBG:NO];
    });
}


#pragma mark -
#pragma mark - Did cancel

-(void) didCancel
{
    self.originalImage = nil;
    self.originalThumbImage = nil;
    self.imageView.image = nil;
    
    if ([self.delegate respondsToSelector:@selector(didCancelFilter)]) {
        [self.delegate didCancelFilter];
    }
}


#pragma mark -
#pragma mark - Did Apply Filter

-(void) didApply
{
    if (isTextObject)
    {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Video Dreamer"
                                  message:@"This type layer must be rasterized before proceeding.\n Its text will no longer be editable. Rasterize the type?"
                                  delegate:nil
                                  cancelButtonTitle:@"Cancel"
                                  otherButtonTitles:@"Ok", nil];
        alertView.delegate = self;
        [alertView show];
    }
    else
    {
        self.originalImage = nil;
        self.originalThumbImage = nil;

        if ([self.delegate respondsToSelector:@selector(didApplyFilter:index:value:)])
        {
            [self.delegate didApplyFilter:self.imageView.image index:selectedFilterIndex value:selectedFilterValue];
        }
        
    }
}


#pragma mark -
#pragma mark - Save current filter image to Album

-(void) didSaveFilterToAlbum
{
    [[SHKActivityIndicator currentIndicator] displayActivity:(@"Saving...") isLock:YES];

    UIImageWriteToSavedPhotosAlbum(self.imageView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}


- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    [[SHKActivityIndicator currentIndicator] hide];

    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:@"Saved"
                              message:@"You can look this photo/video on the Camera Roll."
                              delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)//Cancel
    {
        
    }
    else if (buttonIndex == 1)//Ok - rasterize Text to Photo for a filter
    {
        self.originalImage = nil;
        self.originalThumbImage = nil;

        if ([self.delegate respondsToSelector:@selector(didApplyRasterizedFilter:index:value:)])
        {
            [self.delegate didApplyRasterizedFilter:self.imageView.image index:selectedFilterIndex value:selectedFilterValue];
        }
    }
}

#pragma mark -
#pragma mark - Set Original Image and Thumbnails


-(void) setImage:(UIImage*) image isText:(BOOL) flag
{
    isTextObject = flag;

    CGSize originalThumbSize = image.size;
    
    if (originalThumbSize.height > thumbWidth*2.0f)
        originalThumbSize = CGSizeMake(originalThumbSize.width*thumbWidth*2.0f/originalThumbSize.height, thumbWidth*2.0f);

    self.imageView.image = image;

    self.originalImage = nil;
    self.originalImage = [[UIImage alloc] initWithCGImage:image.CGImage];
    
    self.originalThumbImage = nil;
    self.originalThumbImage = [[UIImage alloc] initWithCGImage:image.CGImage];
    self.originalThumbImage = [self.originalThumbImage rescaleImageToSize:originalThumbSize];
    
    if (_thumbnailQueue != nil)
    {
        [_thumbnailQueue cancelAllOperations];
        _thumbnailQueue = nil;
    }
    _thumbnailQueue = [NSOperationQueue mainQueue];

    for (int i=0; i<self.thumbArray.count; i++)
    {
        NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        
            dispatch_async(dispatch_get_main_queue(), ^{
        
                PhotoFilterThumbView* thumbView = [self.thumbArray objectAtIndex:i];
                
                CIContext* context = [CIContext contextWithOptions:nil];

                float filterValue = 0.5f;
                switch (i)
                {
                    case 1://Brightness
                    {
                        filterValue = 0.0f;
                    }
                        break;
                    case 2://Saturation
                    {
                        filterValue = 1.0f;
                    }
                        break;
                    case 3://Contrast
                    {
                        filterValue = 2.0f;
                    }
                        break;
                        
                    default:
                    {
                        filterValue = 0.5f;
                    }
                        break;
                }

                CIImage* thumbImage = [self getFilteredImage:[CIImage imageWithCGImage:self.originalThumbImage.CGImage] index:i value:filterValue];
                
                CGImageRef cgimg = [context createCGImage:thumbImage fromRect:[thumbImage extent]];

                [thumbView setThumbImage:[UIImage imageWithCGImage:cgimg]];
                
                CGImageRelease(cgimg);
            });
        }];
        
        [_thumbnailQueue addOperation:operation];
    }
}


-(void)setupFilterSlider:(NSInteger) index
{
    switch (index)
    {
        case 1://Brightness
        {
            selectedFilterValue = 0.0f;
            
            [self.filterSlider setMinimumValue:-1.0f];
            [self.filterSlider setMaximumValue:1.0f];
        }
            break;
        case 2://Saturation
        {
            selectedFilterValue = 1.0f;
            
            [self.filterSlider setMinimumValue:0.0f];
            [self.filterSlider setMaximumValue:2.0f];
        }
            break;
        case 3://Contrast
        {
            selectedFilterValue = 2.0f;
            
            [self.filterSlider setMinimumValue:0.0f];
            [self.filterSlider setMaximumValue:4.0f];
        }
            break;
        case 24://ColorPosterize
        {
            selectedFilterValue = 5.0f;
            
            [self.filterSlider setMinimumValue:0.0f];
            [self.filterSlider setMaximumValue:10.0f];
        }
            break;
            
        default:
        {
            selectedFilterValue = 0.5f;
            
            [self.filterSlider setMinimumValue:0.0f];
            [self.filterSlider setMaximumValue:1.0f];
        }
            break;
    }
    
    [self.filterSlider setValue:selectedFilterValue];
}


#pragma mark -
#pragma mark - Set selected filter index, change a thumbnail enable/desable state, change preview image

-(void) setSelectedFilter:(NSInteger) filterIndex value:(float) filterValue
{
    if (selectedFilterIndex != filterIndex)
    {
        PhotoFilterThumbView* thumbView = [self.thumbArray objectAtIndex:selectedFilterIndex];
        [thumbView desableThumbBorder];
    }
    
    selectedFilterIndex = filterIndex;
    selectedFilterValue = filterValue;
    [self.filterSlider setValue:selectedFilterValue];
    
    PhotoFilterThumbView* thumbView = [self.thumbArray objectAtIndex:selectedFilterIndex];
    [thumbView enableThumbBorder];

    [self checkFilterSliderShow:selectedFilterIndex];

    [self applyFilters];
}


#pragma mark -
#pragma mark - FilterThumbViewDelegate

-(void) selectedFilter:(NSInteger) index
{
    if (selectedFilterIndex != index)
    {
        [self setupFilterSlider:index];
        
        PhotoFilterThumbView* thumbView = [self.thumbArray objectAtIndex:selectedFilterIndex];
        [thumbView desableThumbBorder];
    }

    selectedFilterIndex = index;

    PhotoFilterThumbView* thumbView = [self.thumbArray objectAtIndex:selectedFilterIndex];
    [thumbView enableThumbBorder];

    [self checkFilterSliderShow:selectedFilterIndex];
    
    [self applyFilters];
}

-(void) checkFilterSliderShow:(NSInteger)index
{
    switch (index)
    {
        case 0: case 20: case 21: case 22: case 24: case 25: case 26: case 27: case 28: case 30: case 34: case 35: case 36: case 37: case 38: case 39: case 40: case 41: case 42: case 43: case 44: case 45: case 46: case 48: case 49: case 50: case 51: case 52: case 54: case 55: case 56: case 57: case 58: case 59: case 60: case 61: case 62:
            self.filterSlider.hidden = YES;
            break;
            
        default:
            self.filterSlider.hidden = NO;
            break;
    }
}

#pragma mark -
#pragma mark - get filtered image from original image

-(void) applyFilters
{
    dispatch_async(dispatch_get_main_queue(), ^{

        if (selectedFilterIndex == 0)   //original
        {
            self.imageView.image = self.originalImage;
            
            PhotoFilterThumbView* thumbView = [self.thumbArray objectAtIndex:selectedFilterIndex];
            [thumbView enableThumbBorder];
        }
        else
        {
            CIImage* input = [CIImage imageWithCGImage:self.originalImage.CGImage];
            
            input = [self getFilteredImage:input index:selectedFilterIndex value:selectedFilterValue];
            
            CIContext *context = [CIContext contextWithOptions:nil];
            
            CGImageRef cgimg = [context createCGImage:input fromRect:[input extent]];
            self.imageView.image = [UIImage imageWithCGImage:cgimg];
            CGImageRelease(cgimg);
        }

    });
}

-(CIImage*) getFilteredImage:(CIImage*) beginImage index:(NSInteger) filterIndex value:(float)filterValue
{
    CIImage* output = nil;
    CIFilter* filter = nil;
    
    switch (filterIndex)
    {
        case 0://None
            return beginImage;
            break;
        case 1://Brightness
        {
            filter = [CIFilter filterWithName:@"CIColorControls"];
            [filter setValue:beginImage forKey:kCIInputImageKey];
            [filter setValue:[NSNumber numberWithFloat:filterValue] forKey:@"inputBrightness"];
        }
            break;
        case 2://Saturation
        {
            filter = [CIFilter filterWithName:@"CIColorControls"];
            [filter setValue:beginImage forKey:kCIInputImageKey];
            [filter setValue:[NSNumber numberWithFloat:filterValue] forKey:@"inputSaturation"];
        }
            break;
        case 3://Contrast
        {
            filter = [CIFilter filterWithName:@"CIColorControls"];
            [filter setValue:beginImage forKey:kCIInputImageKey];
            [filter setValue:[NSNumber numberWithFloat:filterValue] forKey:@"inputContrast"];
        }
            break;
        case 4://Blue
        {
            filter = [CIFilter filterWithName:@"CIColorMonochrome"];
            [filter setValue:beginImage forKey:kCIInputImageKey];
            [filter setValue:[CIColor colorWithCGColor:[UIColor blueColor].CGColor] forKey:@"inputColor"];
            [filter setValue:[NSNumber numberWithFloat:filterValue] forKey:@"inputIntensity"];
        }
            break;
        case 5://Green
        {
            filter = [CIFilter filterWithName:@"CIColorMonochrome"];
            [filter setValue:beginImage forKey:kCIInputImageKey];
            [filter setValue:[CIColor colorWithCGColor:[UIColor greenColor].CGColor] forKey:@"inputColor"];
            [filter setValue:[NSNumber numberWithFloat:filterValue] forKey:@"inputIntensity"];
        }
            break;
        case 6://Red
        {
            filter = [CIFilter filterWithName:@"CIColorMonochrome"];
            [filter setValue:beginImage forKey:kCIInputImageKey];
            [filter setValue:[CIColor colorWithCGColor:[UIColor redColor].CGColor] forKey:@"inputColor"];
            [filter setValue:[NSNumber numberWithFloat:filterValue] forKey:@"inputIntensity"];
        }
            break;
        case 7://Brown
        {
            filter = [CIFilter filterWithName:@"CIColorMonochrome"];
            [filter setValue:beginImage forKey:kCIInputImageKey];
            [filter setValue:[CIColor colorWithCGColor:[UIColor brownColor].CGColor] forKey:@"inputColor"];
            [filter setValue:[NSNumber numberWithFloat:filterValue] forKey:@"inputIntensity"];
        }
            break;
        case 8://DarkGray
        {
            filter = [CIFilter filterWithName:@"CIColorMonochrome"];
            [filter setValue:beginImage forKey:kCIInputImageKey];
            [filter setValue:[CIColor colorWithCGColor:[UIColor darkGrayColor].CGColor] forKey:@"inputColor"];
            [filter setValue:[NSNumber numberWithFloat:filterValue] forKey:@"inputIntensity"];
        }
            break;
        case 9://Gray
        {
            filter = [CIFilter filterWithName:@"CIColorMonochrome"];
            [filter setValue:beginImage forKey:kCIInputImageKey];
            [filter setValue:[CIColor colorWithCGColor:[UIColor grayColor].CGColor] forKey:@"inputColor"];
            [filter setValue:[NSNumber numberWithFloat:filterValue] forKey:@"inputIntensity"];
        }
            break;
        case 10://LightGray
        {
            filter = [CIFilter filterWithName:@"CIColorMonochrome"];
            [filter setValue:beginImage forKey:kCIInputImageKey];
            [filter setValue:[CIColor colorWithCGColor:[UIColor lightGrayColor].CGColor] forKey:@"inputColor"];
            [filter setValue:[NSNumber numberWithFloat:filterValue] forKey:@"inputIntensity"];
        }
            break;
        case 11://Magenta
        {
            filter = [CIFilter filterWithName:@"CIColorMonochrome"];
            [filter setValue:beginImage forKey:kCIInputImageKey];
            [filter setValue:[CIColor colorWithCGColor:[UIColor magentaColor].CGColor] forKey:@"inputColor"];
            [filter setValue:[NSNumber numberWithFloat:filterValue] forKey:@"inputIntensity"];
        }
            break;
        case 12://Orange
        {
            filter = [CIFilter filterWithName:@"CIColorMonochrome"];
            [filter setValue:beginImage forKey:kCIInputImageKey];
            [filter setValue:[CIColor colorWithCGColor:[UIColor orangeColor].CGColor] forKey:@"inputColor"];
            [filter setValue:[NSNumber numberWithFloat:filterValue] forKey:@"inputIntensity"];
        }
            break;
        case 13://Purple
        {
            filter = [CIFilter filterWithName:@"CIColorMonochrome"];
            [filter setValue:beginImage forKey:kCIInputImageKey];
            [filter setValue:[CIColor colorWithCGColor:[UIColor purpleColor].CGColor] forKey:@"inputColor"];
            [filter setValue:[NSNumber numberWithFloat:filterValue] forKey:@"inputIntensity"];
        }
            break;
        case 14://White
        {
            filter = [CIFilter filterWithName:@"CIColorMonochrome"];
            [filter setValue:beginImage forKey:kCIInputImageKey];
            [filter setValue:[CIColor colorWithCGColor:[UIColor whiteColor].CGColor] forKey:@"inputColor"];
            [filter setValue:[NSNumber numberWithFloat:filterValue] forKey:@"inputIntensity"];
        }
            break;
        case 15://Yellow
        {
            filter = [CIFilter filterWithName:@"CIColorMonochrome"];
            [filter setValue:beginImage forKey:kCIInputImageKey];
            [filter setValue:[CIColor colorWithCGColor:[UIColor yellowColor].CGColor] forKey:@"inputColor"];
            [filter setValue:[NSNumber numberWithFloat:filterValue] forKey:@"inputIntensity"];
        }
            break;
        case 16://Sepia
        {
            filter = [CIFilter filterWithName:@"CISepiaTone"];
            [filter setValue:beginImage forKey:kCIInputImageKey];
            [filter setValue:[NSNumber numberWithFloat:filterValue] forKey:@"inputIntensity"];
        }
            break;
        case 17://RedCross
        {
            filter = [CIFilter filterWithName:@"CIColorCrossPolynomial"];
            [filter setValue:beginImage forKey:kCIInputImageKey];
            [filter setValue:[CIVector vectorWithX:filterValue] forKey:@"inputRedCoefficients"];
        }
            break;
        case 18://GreenCross
        {
            filter = [CIFilter filterWithName:@"CIColorCrossPolynomial"];
            [filter setValue:beginImage forKey:kCIInputImageKey];
            [filter setValue:[CIVector vectorWithX:filterValue] forKey:@"inputGreenCoefficients"];
        }
            break;
        case 19://BlueCross
        {
            filter = [CIFilter filterWithName:@"CIColorCrossPolynomial"];
            [filter setValue:beginImage forKey:kCIInputImageKey];
            [filter setValue:[CIVector vectorWithX:filterValue] forKey:@"inputBlueCoefficients"];
        }
            break;
        case 20://ColorCube
        {
            filter = [CIFilter filterWithName:@"CIColorCube"];
            [filter setValue:beginImage forKey:kCIInputImageKey];
            [filter setValue:[NSNumber numberWithFloat:64.0f] forKey:@"inputCubeDimension"];
            
            const unsigned int size = 64;
            float *cubeData = (float *)malloc (size * size * size * sizeof (float) * 4);
            float *c = cubeData;
            rgb rgbInput;
            hsv hsvOutput;
            
            // Populate cube with a simple gradient going from 0 to 1
            for (int z = 0; z < size; z++){
                rgbInput.b = ((double)z)/(size-1); // Blue value
                for (int y = 0; y < size; y++){
                    rgbInput.g = ((double)y)/(size-1); // Green value
                    for (int x = 0; x < size; x ++){
                        rgbInput.r = ((double)x)/(size-1); // Red value
                        // Convert RGB to HSV
                        // You can find publicly available rgbToHSV functions on the Internet
                        hsvOutput = rgb2hsv(rgbInput);
                        // Use the hue value to determine which to make transparent
                        // The minimum and maximum hue angle depends on
                        // the color you want to remove
                        float alpha = (hsvOutput.h > 120 && hsvOutput.h < 100) ? 0.0f: 1.0f;
                        // Calculate premultiplied alpha values for the cube
                        c[0] = rgbInput.b * alpha;
                        c[1] = rgbInput.g * alpha;
                        c[2] = rgbInput.r * alpha;
                        c[3] = alpha;
                        c += 4; // advance our pointer into memory for the next color value
                    }
                }
            }
            // Create memory with the cube data
            NSData *data = [NSData dataWithBytesNoCopy:cubeData
                                                length:size * size * size * sizeof (float) * 4
                                          freeWhenDone:YES];
            
            [filter setValue:data forKey:@"inputCubeData"];
        }
            break;
        case 21://ColorInvert
        {
            filter = [CIFilter filterWithName:@"CIColorInvert"];
            [filter setValue:beginImage forKey:kCIInputImageKey];
        }
            break;
        case 22://ColorMatrix
        {
            filter = [CIFilter filterWithName:@"CIColorMatrix"];
            [filter setValue:beginImage forKey:kCIInputImageKey];
            [filter setValue:[CIVector vectorWithX:0.5f Y:0.0f Z:0.0f W:0.0f] forKey:@"inputRVector"];
            [filter setValue:[CIVector vectorWithX:0.0f Y:0.5f Z:0.0f W:0.0f] forKey:@"inputGVector"];
            [filter setValue:[CIVector vectorWithX:0.0f Y:0.0f Z:0.5f W:0.0f] forKey:@"inputBVector"];
            [filter setValue:[CIVector vectorWithX:0.0f Y:0.0f Z:0.0f W:0.5f] forKey:@"inputAVector"];
            [filter setValue:[CIVector vectorWithX:0.0f Y:0.0f Z:0.0f W:0.0f] forKey:@"inputBiasVector"];
        }
            break;
        case 23://ColorMonochrome
        {
            filter = [CIFilter filterWithName:@"CIColorMonochrome"];
            [filter setValue:beginImage forKey:kCIInputImageKey];
            [filter setValue:[CIColor colorWithRed:100.0f/255.0f green:200.0f/255.0f blue:50.0f/255.0f] forKey:@"inputColor"];
            [filter setValue:[NSNumber numberWithFloat:selectedFilterValue] forKey:@"inputIntensity"];
        }
            break;
        case 24://ColorPosterize
        {
            filter = [CIFilter filterWithName:@"CIColorPosterize"];
            [filter setValue:beginImage forKey:kCIInputImageKey];
            [filter setValue:[NSNumber numberWithFloat:10.0f] forKey:@"inputLevels"];
        }
            break;
        case 25://Convolution3X3
        {
            filter = [CIFilter filterWithName:@"CIConvolution3X3"];
            [filter setValue:beginImage forKey:kCIInputImageKey];
            [filter setValue:[NSNumber numberWithFloat:0.0f] forKey:@"inputBias"];
            
            const CGFloat weights3[] = {0.0f, -2.0f, 0.0f, -2.0f, 9.0f, -2.0f, 0.0f, -2.0f, 0.0f};
            [filter setValue:[CIVector vectorWithValues:weights3 count:9] forKey:@"inputWeights"];
        }
            break;
        case 26://Convolution5X5
        {
            filter = [CIFilter filterWithName:@"CIConvolution5X5"];
            [filter setValue:beginImage forKey:kCIInputImageKey];
            [filter setValue:[NSNumber numberWithFloat:0.0f] forKey:@"inputBias"];
            
            const CGFloat weights5[] = {0.5f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.5f};
            [filter setValue:[CIVector vectorWithValues:weights5 count:25] forKey:@"inputWeights"];
        }
            break;
        case 27://Convolution9Horizontal
        {
            filter = [CIFilter filterWithName:@"CIConvolution9Horizontal"];
            [filter setValue:beginImage forKey:kCIInputImageKey];
            [filter setValue:[NSNumber numberWithFloat:0.0f] forKey:@"inputBias"];
            
            const CGFloat weights9[] = {1.0f, -1.0f, 1.0f, 0.0f, 1.0f, 0.0f, -1.0f, 1.0f, -1.0f};
            [filter setValue:[CIVector vectorWithValues:weights9 count:9] forKey:@"inputWeights"];
        }
            break;
        case 28://Convolution9Vertical
        {
            filter = [CIFilter filterWithName:@"CIConvolution9Vertical"];
            [filter setValue:beginImage forKey:kCIInputImageKey];
            [filter setValue:[NSNumber numberWithFloat:0.0f] forKey:@"inputBias"];
            
            const CGFloat weights9v[] = {1.0f, -1.0f, 1.0f, 0.0f, 1.0f, 0.0f, -1.0f, 1.0f, -1.0f};
            [filter setValue:[CIVector vectorWithValues:weights9v count:9] forKey:@"inputWeights"];
        }
            break;
        case 29://CIExposureAdjust
        {
            filter = [CIFilter filterWithName:@"CIExposureAdjust"];
            [filter setValue:beginImage forKey:kCIInputImageKey];
            [filter setValue:[NSNumber numberWithFloat:selectedFilterValue] forKey:@"inputEV"];
        }
            break;
        case 30://CIFalseColor
        {
            filter = [CIFilter filterWithName:@"CIFalseColor"];
            [filter setValue:beginImage forKey:kCIInputImageKey];
            [filter setValue:[CIColor colorWithRed:1.0f green:0.5f blue:0.0f] forKey:@"inputColor0"];
            [filter setValue:[CIColor colorWithRed:0.0f green:0.0f blue:1.0f] forKey:@"inputColor1"];
        }
            break;
        case 31://CIGammaAdjust
        {
            filter = [CIFilter filterWithName:@"CIGammaAdjust"];
            [filter setValue:beginImage forKey:kCIInputImageKey];
            [filter setValue:[NSNumber numberWithFloat:selectedFilterValue] forKey:@"inputPower"];
        }
            break;
        case 32://CIHighlightShadowAdjust
        {
            filter = [CIFilter filterWithName:@"CIHighlightShadowAdjust"];
            [filter setValue:beginImage forKey:kCIInputImageKey];
            [filter setValue:[NSNumber numberWithFloat:selectedFilterValue] forKey:@"inputHighlightAmount"];
            [filter setValue:[NSNumber numberWithFloat:10.0f] forKey:@"inputShadowAmount"];
        }
            break;
        case 33://CIHueAdjust
        {
            filter = [CIFilter filterWithName:@"CIHueAdjust"];
            [filter setValue:beginImage forKey:kCIInputImageKey];
            [filter setValue:[NSNumber numberWithFloat:selectedFilterValue] forKey:@"inputAngle"];
        }
            break;
        case 34://CILinearToSRGBToneCurve
        {
            filter = [CIFilter filterWithName:@"CILinearToSRGBToneCurve"];
            [filter setValue:beginImage forKey:kCIInputImageKey];
        }
            break;
        case 35://CIMaskToAlpha
        {
            filter = [CIFilter filterWithName:@"CIMaskToAlpha"];
            [filter setValue:beginImage forKey:kCIInputImageKey];
        }
            break;
        case 36://CIMaximumComponent
        {
            filter = [CIFilter filterWithName:@"CIMaximumComponent"];
            [filter setValue:beginImage forKey:kCIInputImageKey];
        }
            break;
        case 37://CIMinimumComponent
        {
            filter = [CIFilter filterWithName:@"CIMinimumComponent"];
            [filter setValue:beginImage forKey:kCIInputImageKey];
        }
            break;
        case 38://CIPhotoEffectChrome
        {
            filter = [CIFilter filterWithName:@"CIPhotoEffectChrome"];
            [filter setValue:beginImage forKey:kCIInputImageKey];
        }
            break;
        case 39://CIPhotoEffectFade
        {
            filter = [CIFilter filterWithName:@"CIPhotoEffectFade"];
            [filter setValue:beginImage forKey:kCIInputImageKey];
        }
            break;
        case 40://CIPhotoEffectInstant
        {
            filter = [CIFilter filterWithName:@"CIPhotoEffectInstant"];
            [filter setValue:beginImage forKey:kCIInputImageKey];
        }
            break;
        case 41://CIPhotoEffectMono
        {
            filter = [CIFilter filterWithName:@"CIPhotoEffectMono"];
            [filter setValue:beginImage forKey:kCIInputImageKey];
        }
            break;
        case 42://CIPhotoEffectNoir
        {
            filter = [CIFilter filterWithName:@"CIPhotoEffectNoir"];
            [filter setValue:beginImage forKey:kCIInputImageKey];
        }
            break;
        case 43://CIPhotoEffectProcess
        {
            filter = [CIFilter filterWithName:@"CIPhotoEffectProcess"];
            [filter setValue:beginImage forKey:kCIInputImageKey];
        }
            break;
        case 44://CIPhotoEffectTonal
        {
            filter = [CIFilter filterWithName:@"CIPhotoEffectTonal"];
            [filter setValue:beginImage forKey:kCIInputImageKey];
        }
            break;
        case 45://CIPhotoEffectTransfer
        {
            filter = [CIFilter filterWithName:@"CIPhotoEffectTransfer"];
            [filter setValue:beginImage forKey:kCIInputImageKey];
        }
            break;
        case 46://CIPixellate
        {
            filter = [CIFilter filterWithName:@"CIPixellate"];
            [filter setValue:beginImage forKey:kCIInputImageKey];
        }
            break;
        case 47://CISharpenLuminance
        {
            filter = [CIFilter filterWithName:@"CISharpenLuminance"];
            [filter setValue:beginImage forKey:kCIInputImageKey];
            [filter setValue:[NSNumber numberWithFloat:selectedFilterValue] forKey:@"inputSharpness"];
        }
            break;
        case 48://CISRGBToneCurveToLinear
        {
            filter = [CIFilter filterWithName:@"CISRGBToneCurveToLinear"];
            [filter setValue:beginImage forKey:kCIInputImageKey];
        }
            break;
        case 49://CITemperatureAndTint
        {
            filter = [CIFilter filterWithName:@"CITemperatureAndTint"];
            [filter setValue:beginImage forKey:kCIInputImageKey];
            [filter setValue:[CIVector vectorWithX:500 Y:0] forKey:@"inputNeutral"];
            [filter setValue:[CIVector vectorWithX:8500 Y:0] forKey:@"inputTargetNeutral"];
        }
            break;
        case 50://CIUnsharpMask
        {
            filter = [CIFilter filterWithName:@"CIUnsharpMask"];
            [filter setValue:beginImage forKey:kCIInputImageKey];
            [filter setValue:[NSNumber numberWithFloat:10] forKey:@"inputRadius"];
            [filter setValue:[NSNumber numberWithFloat:2] forKey:@"inputIntensity"];
        }
            break;
        case 51://CIVibrance
        {
            filter = [CIFilter filterWithName:@"CIVibrance"];
            [filter setValue:beginImage forKey:kCIInputImageKey];
            [filter setValue:[NSNumber numberWithFloat:10] forKey:@"inputAmount"];
        }
            break;
        case 52://CIVignette
        {
            filter = [CIFilter filterWithName:@"CIVignette"];
            [filter setValue:beginImage forKey:kCIInputImageKey];
            [filter setValue:[NSNumber numberWithFloat:10] forKey:@"inputRadius"];
            [filter setValue:[NSNumber numberWithFloat:3] forKey:@"inputIntensity"];
        }
            break;
        case 53://CIWhitePointAdjust
        {
            filter = [CIFilter filterWithName:@"CIWhitePointAdjust"];
            [filter setValue:beginImage forKey:kCIInputImageKey];
            [filter setValue:[CIColor colorWithRed:selectedFilterValue green:selectedFilterValue blue:selectedFilterValue] forKey:@"inputColor"];
        }
            break;
        case 54://DotScreen
        {
            filter = [CIFilter filterWithName:@"CIDotScreen"];
            [filter setValue:beginImage forKey:kCIInputImageKey];
            [filter setValue:[NSNumber numberWithFloat:1.0f] forKey:@"inputAngle"];
            [filter setValue:[NSNumber numberWithFloat:6.0f] forKey:@"inputWidth"];
            [filter setValue:[NSNumber numberWithFloat:0.7f] forKey:@"inputSharpness"];
            [filter setValue:[CIVector vectorWithX:150.0f Y:150.0f] forKey:@"inputCenter"];
        }
            break;
        case 55://CircularScreen
        {
            filter = [CIFilter filterWithName:@"CICircularScreen"];
            [filter setValue:beginImage forKey:kCIInputImageKey];
            [filter setValue:[NSNumber numberWithFloat:6.0f] forKey:@"inputWidth"];
            [filter setValue:[NSNumber numberWithFloat:0.7f] forKey:@"inputSharpness"];
            [filter setValue:[CIVector vectorWithX:[beginImage extent].size.width/2.0f Y:[beginImage extent].size.height/2.0f] forKey:@"inputCenter"];
        }
            break;
        case 56://CIHatchedScreen
        {
            filter = [CIFilter filterWithName:@"CIHatchedScreen"];
            [filter setValue:beginImage forKey:kCIInputImageKey];
            [filter setValue:[CIVector vectorWithX:150.0f Y:150.0f] forKey:@"inputCenter"];
            [filter setValue:[NSNumber numberWithFloat:0.0f] forKey:@"inputAngle"];
            [filter setValue:[NSNumber numberWithFloat:6.0f] forKey:@"inputWidth"];
            [filter setValue:[NSNumber numberWithFloat:0.7f] forKey:@"inputSharpness"];
        }
            break;
        case 57://CILineScreen
        {
            filter = [CIFilter filterWithName:@"CILineScreen"];
            [filter setValue:beginImage forKey:kCIInputImageKey];
        }
            break;
        case 58://Bloom
        {
            filter = [CIFilter filterWithName:@"CIBloom"];
            [filter setValue:beginImage forKey:kCIInputImageKey];
            [filter setValue:[NSNumber numberWithFloat:5.0f] forKey:@"inputRadius"];
            [filter setValue:[NSNumber numberWithFloat:1.0f] forKey:@"inputIntensity"];
        }
            break;
        case 59://CIGaussianBlur
        {
            filter = [CIFilter filterWithName:@"CIGaussianBlur"];
            [filter setValue:beginImage forKey:kCIInputImageKey];
            [filter setValue:[NSNumber numberWithFloat:5.0f] forKey:@"inputRadius"];
        }
            break;
        case 60://CIGloom
        {
            filter = [CIFilter filterWithName:@"CIGloom"];
            [filter setValue:beginImage forKey:kCIInputImageKey];
            [filter setValue:[NSNumber numberWithFloat:10.0f] forKey:@"inputRadius"];
            [filter setValue:[NSNumber numberWithFloat:1.0f] forKey:@"inputIntensity"];
        }
            break;
        case 61://CIPinchDistortion
        {
            filter = [CIFilter filterWithName:@"CIPinchDistortion"];
            [filter setValue:beginImage forKey:kCIInputImageKey];
            [filter setValue:[CIVector vectorWithX:[beginImage extent].size.width/2.0f Y:[beginImage extent].size.height/2.0f] forKey:@"inputCenter"];
            [filter setValue:[NSNumber numberWithFloat:[beginImage extent].size.width/5.0f] forKey:@"inputRadius"];
            [filter setValue:[NSNumber numberWithFloat:0.5f] forKey:@"inputScale"];
        }
            break;
        case 62://CIVortexDistortion
        {
            filter = [CIFilter filterWithName:@"CIVortexDistortion"];
            [filter setValue:beginImage forKey:kCIInputImageKey];
            [filter setValue:[CIVector vectorWithX:[beginImage extent].size.width/2.0f Y:[beginImage extent].size.height/2.0f] forKey:@"inputCenter"];
            [filter setValue:[NSNumber numberWithFloat:[beginImage extent].size.width/5.0f] forKey:@"inputRadius"];
        }
            break;

        default:
            return beginImage;
            break;
    }
    
    output = [filter outputImage];
    
    return output;
}


#pragma mark - ColorCube

typedef struct {
    double r;       // percent
    double g;       // percent
    double b;       // percent
} rgb;

typedef struct {
    double h;       // angle in degrees
    double s;       // percent
    double v;       // percent
} hsv;

static hsv      rgb2hsv(rgb in);
hsv rgb2hsv(rgb in)
{
    hsv         out;
    double      min, max, delta;
    
    min = in.r < in.g ? in.r : in.g;
    min = min  < in.b ? min  : in.b;
    
    max = in.r > in.g ? in.r : in.g;
    max = max  > in.b ? max  : in.b;
    
    out.v = max;                                // v
    delta = max - min;
    if( max > 0.0 ) {
        out.s = (delta / max);                  // s
    } else {
        // r = g = b = 0                        // s = 0, v is undefined
        out.s = 0.0;
        out.h = NAN;                            // its now undefined
        return out;
    }
    if( in.r >= max )                           // > is bogus, just keeps compilor happy
        out.h = ( in.g - in.b ) / delta;        // between yellow & magenta
    else
        if( in.g >= max )
            out.h = 2.0 + ( in.b - in.r ) / delta;  // between cyan & yellow
        else
            out.h = 4.0 + ( in.r - in.g ) / delta;  // between magenta & cyan
    
    out.h *= 60.0;                              // degrees
    
    if( out.h < 0.0 )
        out.h += 360.0;
    
    return out;
}


-(void) filterSliderChanged
{
    selectedFilterValue = self.filterSlider.value;
    
    [self applyFilters];
}


@end
