//
//  FiltersView.m
//  VideoFrame
//
//  Created by Yinjing Li on 02/20/15.
//  Copyright (c) 2015 Yinjing Li. All rights reserved.
//

#import "VideoFiltersView.h"

#import <CoreImage/CoreImage.h>

#import "SHKActivityIndicator.h"
#import "Definition.h"
#import "UIImageExtras.h"
#import "YJLActionMenu.h"


@implementation VideoFiltersView


#pragma mark - 
#pragma mark - init

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];

    if (self)
    {
        self.backgroundColor = [UIColor blackColor];
        
        self.filterIndex = 0;
        self.filterValue = 0.5f;

        CGFloat font_2x = 1.0f;
        CGRect playButtonFrame = CGRectZero;
        CGRect titleLabelFrame = CGRectZero;
        CGRect imageViewFrame = CGRectZero;
        CGRect scrollViewFrame = CGRectZero;
        CGRect originalThumbFrame = CGRectZero;
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        {
            thumbWidth = 60.0f;
            thumbHeight = 80.0f;

            font_2x = 1.0f;
            playButtonFrame = CGRectMake(30.0f, 10.0f, 30.0f, 30.0f);
            titleLabelFrame = CGRectMake(self.frame.size.width/2.0f - 50.0f, 10.0f, 100.0f, 30.0f);
            imageViewFrame = CGRectMake(50.0f, 50.0f, self.frame.size.width - 100.0f, self.frame.size.height - 150.0f);
            scrollViewFrame = CGRectMake(15.0f + thumbWidth, self.frame.size.height - 90.0f, self.frame.size.width - 25.0f - thumbWidth, 80.0f);
            originalThumbFrame = CGRectMake(10.0f, self.frame.size.height - 90.0f, thumbWidth, thumbHeight);
        }
        else
        {
            thumbWidth = 90.0f;
            thumbHeight = 120.0f;

            font_2x = 1.6f;
            playButtonFrame = CGRectMake(50.0f, 10.0f, 50.0f, 50.0f);
            titleLabelFrame = CGRectMake(self.frame.size.width/2.0f - 100.0f, 10.0f, 200.0f, 50.0f);
            imageViewFrame = CGRectMake(100.0f, 70.0f, self.frame.size.width - 200.0f, self.frame.size.height - 210.0f);
            scrollViewFrame = CGRectMake(15.0f + thumbWidth, self.frame.size.height - 130.0f, self.frame.size.width - 25.0f - thumbWidth, 120.0f);
            originalThumbFrame = CGRectMake(10.0f, self.frame.size.height - 130.0f, thumbWidth, thumbHeight);
        }
        
        
        //title label
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


        //apply button
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

        
        //GPUImageView - filterView
        self.filterView = [[GPUImageView alloc] initWithFrame:imageViewFrame];
        self.filterView.backgroundColor = [UIColor clearColor];
        self.filterView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:self.filterView];
        
        
        //play button
        self.playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.playBtn setFrame:playButtonFrame];
        [self.playBtn setImage:[UIImage imageNamed:@"NewPlay"] forState:UIControlStateNormal];
        [self.playBtn setImage:[UIImage imageNamed:@"NewPlay"] forState:UIControlStateSelected];
        [self.playBtn setBackgroundColor:[UIColor clearColor]];
        [self.playBtn addTarget:self action:@selector(actionPlay:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.playBtn];
        
        
        //play seek position label
        self.videoPositionLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0f, titleLabelFrame.origin.y + titleLabelFrame.size.height + 10.0f, 50.0f, 30.0f)];
        self.videoPositionLabel.text = @"0:00";
        self.videoPositionLabel.backgroundColor = [UIColor clearColor];
        self.videoPositionLabel.textAlignment = NSTextAlignmentRight;
        self.videoPositionLabel.font = [UIFont fontWithName:MYRIADPRO size:FONT_SIZE*font_2x];
        self.videoPositionLabel.textColor = [UIColor whiteColor];
        self.videoPositionLabel.shadowColor = [UIColor blackColor];
        self.videoPositionLabel.shadowOffset = CGSizeMake(0, 1);
        [self addSubview:self.videoPositionLabel];
        
        
        //video length label
        self.videoLegthLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width - 55.0f, titleLabelFrame.origin.y + titleLabelFrame.size.height + 10.0f, 50.0f, 30.0f)];
        self.videoLegthLabel.text = @"0:00";
        self.videoLegthLabel.backgroundColor = [UIColor clearColor];
        self.videoLegthLabel.textAlignment = NSTextAlignmentLeft;
        self.videoLegthLabel.font = [UIFont fontWithName:MYRIADPRO size:FONT_SIZE*font_2x];
        self.videoLegthLabel.textColor = [UIColor whiteColor];
        self.videoLegthLabel.shadowColor = [UIColor blackColor];
        self.videoLegthLabel.shadowOffset = CGSizeMake(0, 1);
        [self addSubview:self.videoLegthLabel];
        
        
        //play seek slider
        self.seekSlider = [[UISlider alloc] initWithFrame:CGRectMake(60.0f, titleLabelFrame.origin.y + titleLabelFrame.size.height + 10.0f, self.frame.size.width - 120.0f, 30.0f)];
        self.seekSlider.backgroundColor = [UIColor clearColor];
        [self.seekSlider setMinimumTrackImage:[UIImage imageNamed:@"slider_min"] forState:UIControlStateNormal];
        [self.seekSlider setMaximumTrackImage:[UIImage imageNamed:@"slider_max"] forState:UIControlStateNormal];
        [self.seekSlider setThumbImage:[UIImage imageNamed:@"slider_thumb_ipad"] forState:UIControlStateNormal];
        [self.seekSlider setValue:0.0f];
        [self.seekSlider addTarget:self action:@selector(changeSeekSlider) forControlEvents:UIControlEventValueChanged];
        [self addSubview:self.seekSlider];
        
        
        //filter thumbnails scrollView
        self.filterScrollView = [[UIScrollView alloc] initWithFrame:scrollViewFrame];
        self.filterScrollView.backgroundColor = [UIColor clearColor];
        [self.filterScrollView setScrollEnabled:YES];
        [self.filterScrollView setShowsHorizontalScrollIndicator:YES];
        [self.filterScrollView setShowsVerticalScrollIndicator:NO];
        [self addSubview:self.filterScrollView];
        
        
        //init filter thumbnails
        self.thumbArray = [[NSMutableArray alloc] init];

        VideoFilterThumbView* thumbView = [[VideoFilterThumbView alloc] initWithFrame:originalThumbFrame];
        [thumbView setIndex:0];
        thumbView.delegate = self;
        [self addSubview:thumbView];
        
        [self.thumbArray addObject:thumbView];

        for (int i=1; i<=GPUIMAGE_PINCH; i++)
        {
            VideoFilterThumbView* thumbView = [[VideoFilterThumbView alloc] initWithFrame:CGRectMake((5.0f+thumbWidth)*(i-1), 0.0f, thumbWidth, thumbHeight)];
            [thumbView setIndex:i];
            thumbView.delegate = self;
            [self.filterScrollView addSubview:thumbView];

            [self.thumbArray addObject:thumbView];
        }
        
        [self.filterScrollView setContentSize:CGSizeMake((5.0f+thumbWidth)*(self.thumbArray.count-1), thumbHeight)];
        
        self.filterSlider = [[UISlider alloc] initWithFrame:CGRectMake(50.0f, scrollViewFrame.origin.y - 40.f, self.frame.size.width - 100.0f, 40.0f)];
        [self.filterSlider setBackgroundColor:[UIColor clearColor]];
        [self.filterSlider setValue:self.filterValue];
        [self.filterSlider addTarget:self action:@selector(filterSliderChanged) forControlEvents:UIControlEventValueChanged];
        [self.filterSlider setMinimumValue:0.1f];
        [self.filterSlider setMaximumValue:1.0f];
        [self addSubview:self.filterSlider];
    }
    
    return self;
}


#pragma mark -
#pragma mark - Init Video, Selected Filter

-(void) initParams:(NSURL*) originVideoUrl image:(UIImage*) thumbImage
{
    self.filterIndex = 0;
    self.originalVideoUrl = originVideoUrl;

    self.samplePipeline = nil;
    self.isPlaying = NO;
    
    [self.seekSlider setValue:0.0f];
    [self.videoPositionLabel setText:@"0:00"];
    [self.playBtn setImage:[UIImage imageNamed:@"NewPlay"] forState:UIControlStateNormal];
    [self.playBtn setImage:[UIImage imageNamed:@"NewPlay"] forState:UIControlStateSelected];

    
    [self checkFilterSlider];

    //init seek slider max value
    AVAsset* asset = [AVAsset assetWithURL:self.originalVideoUrl];
    [self.seekSlider setMaximumValue:CMTimeGetSeconds(asset.duration)];
    
    //init video length label
    int min = CMTimeGetSeconds(asset.duration) / 60;
    int sec = CMTimeGetSeconds(asset.duration) - (min * 60);
    NSString* string = [NSString stringWithFormat:@"%d:%02d", min, sec];
    [self.videoLegthLabel setText:string];

    //init thumbnails
    CGSize originalThumbSize = thumbImage.size.height > thumbWidth*2.0f ? CGSizeMake(thumbImage.size.width*thumbWidth*2.0f/thumbImage.size.height, thumbWidth*2.0f) :    thumbImage.size;
    UIImage* thumbnailImage = [thumbImage rescaleImageToSize:originalThumbSize];

    GPUImageOutput<GPUImageInput>* thumbFilter = nil;

    for (int i=0; i<self.thumbArray.count; i++)
    {
        VideoFilterThumbView* thumbView = [self.thumbArray objectAtIndex:i];
        
        switch (i)
        {
            case GPUIMAGE_NONE:
            {
                thumbFilter = [[GPUImageFilter alloc] init];
            }; break;
            case GPUIMAGE_SEPIA://(0.0, 1.0)
            {
                thumbFilter = [[GPUImageSepiaFilter alloc] init];
                [(GPUImageSepiaFilter *)thumbFilter setIntensity:1.0f];
            }; break;
            case GPUIMAGE_SATURATION://(0.0, 2.0)
            {
                thumbFilter = [[GPUImageSaturationFilter alloc] init];
                [(GPUImageSaturationFilter *)thumbFilter setSaturation:1.8f];
            }; break;
            case GPUIMAGE_CONTRAST://(0.0, 4.0)
            {
                thumbFilter = [[GPUImageContrastFilter alloc] init];
                [(GPUImageContrastFilter *)thumbFilter setContrast:2.0f];
            }; break;
            case GPUIMAGE_BRIGHTNESS://(-1.0, 1.0)
            {
                thumbFilter = [[GPUImageBrightnessFilter alloc] init];
                [(GPUImageBrightnessFilter *)thumbFilter setBrightness:-0.2f];
            }; break;
            case GPUIMAGE_LEVELS://(0.0, 1.0)
            {
                thumbFilter = [[GPUImageLevelsFilter alloc] init];
                [(GPUImageLevelsFilter *)thumbFilter setRedMin:0.5 gamma:1.0 max:1.0 minOut:0.0 maxOut:1.0];
                [(GPUImageLevelsFilter *)thumbFilter setGreenMin:0.5 gamma:1.0 max:1.0 minOut:0.0 maxOut:1.0];
                [(GPUImageLevelsFilter *)thumbFilter setBlueMin:0.5 gamma:1.0 max:1.0 minOut:0.0 maxOut:1.0];
            }; break;
            case GPUIMAGE_EXPOSURE://(-4.0, 4.0)
            {
                thumbFilter = [[GPUImageExposureFilter alloc] init];
                [(GPUImageExposureFilter *)thumbFilter setExposure:1.0f];
            }; break;
            case GPUIMAGE_RGB://(0.0, 2.0)
            {
                thumbFilter = [[GPUImageRGBFilter alloc] init];
                [(GPUImageRGBFilter *)thumbFilter setGreen:1.5];
            }; break;
            case GPUIMAGE_HUE://(0.0, 360.0)
            {
                thumbFilter = [[GPUImageHueFilter alloc] init];
                [(GPUImageHueFilter *)thumbFilter setHue:180.0f];
            }; break;
            case GPUIMAGE_COLORINVERT:
            {
                thumbFilter = [[GPUImageColorInvertFilter alloc] init];
            }; break;
            case GPUIMAGE_WHITEBALANCE://(2500, 7500)
            {
                thumbFilter = [[GPUImageWhiteBalanceFilter alloc] init];
                [(GPUImageWhiteBalanceFilter *)thumbFilter setTemperature:3000.0f];
            }; break;
            case GPUIMAGE_MONOCHROME://(0.0, 1.0)
            {
                thumbFilter = [[GPUImageMonochromeFilter alloc] init];
                [(GPUImageMonochromeFilter *)thumbFilter setIntensity:1.0f];
            }; break;
            case GPUIMAGE_SHARPEN://(-1.0, 4.0)
            {
                thumbFilter = [[GPUImageSharpenFilter alloc] init];
                [(GPUImageSharpenFilter *)thumbFilter setSharpness:2.0f];
            }; break;
            case GPUIMAGE_UNSHARPMASK://(0.0, 5.0)
            {
                thumbFilter = [[GPUImageUnsharpMaskFilter alloc] init];
                [(GPUImageUnsharpMaskFilter *)thumbFilter setIntensity:2.0f];
            }; break;
            case GPUIMAGE_GAMMA://(0.0, 3.0)
            {
                thumbFilter = [[GPUImageGammaFilter alloc] init];
                [(GPUImageGammaFilter *)thumbFilter setGamma:2.0];
            }; break;
            case GPUIMAGE_TONECURVE://(0.0, 1.0)
            {
                thumbFilter = [[GPUImageToneCurveFilter alloc] init];
                [(GPUImageToneCurveFilter *)thumbFilter setBlueControlPoints:[NSArray arrayWithObjects:[NSValue valueWithCGPoint:CGPointMake(0.0, 0.0)], [NSValue valueWithCGPoint:CGPointMake(0.5, 0.5)], [NSValue valueWithCGPoint:CGPointMake(1.0, 0.75)], nil]];
                [(GPUImageToneCurveFilter *)thumbFilter setBlueControlPoints:[NSArray arrayWithObjects:[NSValue valueWithCGPoint:CGPointMake(0.0, 0.0)], [NSValue valueWithCGPoint:CGPointMake(0.5, 0.5)], [NSValue valueWithCGPoint:CGPointMake(1.0, 0.75)], nil]];
            }; break;
            case GPUIMAGE_HIGHLIGHTSHADOW://(0.0, 1.0)
            {
                thumbFilter = [[GPUImageHighlightShadowFilter alloc] init];
                [(GPUImageHighlightShadowFilter *)thumbFilter setHighlights:0.5f];
            }; break;
            case GPUIMAGE_HAZE://(-0.2, 0.2)
            {
                thumbFilter = [[GPUImageHazeFilter alloc] init];
                [(GPUImageHazeFilter *)thumbFilter setDistance:0.2];
            }; break;
            case GPUIMAGE_GRAYSCALE:
            {
                thumbFilter = [[GPUImageGrayscaleFilter alloc] init];
            }; break;
            case GPUIMAGE_SKETCH://0.0, 1.0
            {
                thumbFilter = [[GPUImageSketchFilter alloc] init];
                [(GPUImageSketchFilter *)thumbFilter setEdgeStrength:0.45];
            }; break;
            case GPUIMAGE_SMOOTHTOON://1.0, 6.0
            {
                thumbFilter = [[GPUImageSmoothToonFilter alloc] init];
                [(GPUImageSmoothToonFilter *)thumbFilter setBlurRadiusInPixels:1.0];
            }; break;
            case GPUIMAGE_TILTSHIFT://0.2, 0.8
            {
                thumbFilter = [[GPUImageTiltShiftFilter alloc] init];
                [(GPUImageTiltShiftFilter *)thumbFilter setTopFocusLevel:0.4];
                [(GPUImageTiltShiftFilter *)thumbFilter setBottomFocusLevel:0.6];
                [(GPUImageTiltShiftFilter *)thumbFilter setFocusFallOffRate:0.2];
            }; break;
            case GPUIMAGE_EMBOSS://0.0, 5.0
            {
                thumbFilter = [[GPUImageEmbossFilter alloc] init];
                [(GPUImageEmbossFilter *)thumbFilter setIntensity:1.0];
            }; break;
            case GPUIMAGE_POSTERIZE://1.0, 20.0
            {
                thumbFilter = [[GPUImagePosterizeFilter alloc] init];
                [(GPUImagePosterizeFilter *)thumbFilter setColorLevels:10.0];
            }; break;
            case GPUIMAGE_PINCH://-2.0, 2.0
            {
                thumbFilter = [[GPUImagePinchDistortionFilter alloc] init];
                [(GPUImagePinchDistortionFilter *)thumbFilter setScale:0.5];
            }; break;
            case GPUIMAGE_VIGNETTE://0.5, 0.9
            {
                thumbFilter = [[GPUImageVignetteFilter alloc] init];
                [(GPUImageVignetteFilter *)thumbFilter setVignetteEnd:0.75];
            }; break;
            case GPUIMAGE_GAUSSIAN://0.0, 24.0
            {
                thumbFilter = [[GPUImageGaussianBlurFilter alloc] init];
                [(GPUImageGaussianBlurFilter *)thumbFilter setBlurRadiusInPixels:2.0];
            }; break;
            case GPUIMAGE_GAUSSIAN_SELECTIVE://0.0, 0.75f
            {
                thumbFilter = [[GPUImageGaussianSelectiveBlurFilter alloc] init];
                [(GPUImageGaussianSelectiveBlurFilter*)thumbFilter setExcludeCircleRadius:0.5f];
            }; break;
            case GPUIMAGE_GAUSSIAN_POSITION://0.0, 0.75
            {
                thumbFilter = [[GPUImageGaussianBlurPositionFilter alloc] init];
                [(GPUImageGaussianBlurPositionFilter*)thumbFilter setBlurRadius:0.5f];
            }; break;
            
            default:
                thumbFilter = [[GPUImageFilter alloc] init];
            break;
        }

        UIImage *quickFilteredImage = [thumbFilter imageByFilteringImage:thumbnailImage];

        [thumbView setVideoThumbImage:quickFilteredImage];
        [thumbView disableThumbBorder];
        
        thumbFilter = nil;
        quickFilteredImage = nil;
    }

    VideoFilterThumbView* newThumbView = [self.thumbArray objectAtIndex:self.filterIndex];
    [newThumbView enableThumbBorder];

    [self previewSelectedFilter];
}


#pragma mark -
#pragma mark - FilterThumbViewDelegate

-(void) selectedFilterThumb:(NSInteger) index
{
    if (index != self.filterIndex)
    {
        //remove old selected filter
        VideoFilterThumbView* oldThumbView = [self.thumbArray objectAtIndex:self.filterIndex];
        [oldThumbView disableThumbBorder];
        
        self.filterIndex = index;
        self.filterValue = 0.5f;
        
        VideoFilterThumbView* newThumbView = [self.thumbArray objectAtIndex:index];
        [newThumbView enableThumbBorder];
        
        [self checkFilterSlider];
        
        [self previewSelectedFilter];
    }
}


#pragma mark -
#pragma mark - setup Filter


-(GPUImageOutput<GPUImageInput>*) setupFilterWithFilterValue:(NSInteger) index value:(float) filterValue
{
    GPUImageOutput<GPUImageInput>* tempFilter = nil;
    
    switch (index)
    {
        case GPUIMAGE_NONE:
        {
            tempFilter = [[GPUImageFilter alloc] init];
        }; break;
        case GPUIMAGE_SEPIA://(0.0, 1.0)
        {
            tempFilter = [[GPUImageSepiaFilter alloc] init];
            [(GPUImageSepiaFilter *)tempFilter setIntensity:filterValue];
        }; break;
        case GPUIMAGE_SATURATION://(0.0, 2.0)
        {
            tempFilter = [[GPUImageSaturationFilter alloc] init];
            [(GPUImageSaturationFilter *)tempFilter setSaturation:filterValue];
        }; break;
        case GPUIMAGE_CONTRAST://(0.0, 4.0)
        {
            tempFilter = [[GPUImageContrastFilter alloc] init];
            [(GPUImageContrastFilter *)tempFilter setContrast:filterValue];
        }; break;
        case GPUIMAGE_BRIGHTNESS://(-1.0, 1.0)
        {
            tempFilter = [[GPUImageBrightnessFilter alloc] init];
            [(GPUImageBrightnessFilter *)tempFilter setBrightness:filterValue];
        }; break;
        case GPUIMAGE_LEVELS://(0.0, 1.0)
        {
            tempFilter = [[GPUImageLevelsFilter alloc] init];
            [(GPUImageLevelsFilter *)tempFilter setRedMin:filterValue gamma:1.0 max:1.0 minOut:0.0 maxOut:1.0];
            [(GPUImageLevelsFilter *)tempFilter setGreenMin:filterValue gamma:1.0 max:1.0 minOut:0.0 maxOut:1.0];
            [(GPUImageLevelsFilter *)tempFilter setBlueMin:filterValue gamma:1.0 max:1.0 minOut:0.0 maxOut:1.0];
        }; break;
        case GPUIMAGE_EXPOSURE://(-4.0, 4.0)
        {
            tempFilter = [[GPUImageExposureFilter alloc] init];
            [(GPUImageExposureFilter *)tempFilter setExposure:filterValue];
        }; break;
        case GPUIMAGE_RGB://(0.0, 2.0)
        {
            tempFilter = [[GPUImageRGBFilter alloc] init];
            [(GPUImageRGBFilter *)tempFilter setGreen:filterValue];
        }; break;
        case GPUIMAGE_HUE://(0.0, 360.0)
        {
            tempFilter = [[GPUImageHueFilter alloc] init];
            [(GPUImageHueFilter *)tempFilter setHue:filterValue];
        }; break;
        case GPUIMAGE_COLORINVERT:
        {
            tempFilter = [[GPUImageColorInvertFilter alloc] init];
        }; break;
        case GPUIMAGE_WHITEBALANCE://(2500, 7500)
        {
            tempFilter = [[GPUImageWhiteBalanceFilter alloc] init];
            [(GPUImageWhiteBalanceFilter *)tempFilter setTemperature:filterValue];
        }; break;
        case GPUIMAGE_MONOCHROME://(0.0, 1.0)
        {
            tempFilter = [[GPUImageMonochromeFilter alloc] init];
            [(GPUImageMonochromeFilter *)tempFilter setIntensity:filterValue];
        }; break;
        case GPUIMAGE_SHARPEN://(-1.0, 4.0)
        {
            tempFilter = [[GPUImageSharpenFilter alloc] init];
            [(GPUImageSharpenFilter *)tempFilter setSharpness:filterValue];
        }; break;
        case GPUIMAGE_UNSHARPMASK://(0.0, 5.0)
        {
            tempFilter = [[GPUImageUnsharpMaskFilter alloc] init];
            [(GPUImageUnsharpMaskFilter *)tempFilter setIntensity:filterValue];
        }; break;
        case GPUIMAGE_GAMMA://(0.0, 3.0)
        {
            tempFilter = [[GPUImageGammaFilter alloc] init];
            [(GPUImageGammaFilter *)tempFilter setGamma:filterValue];
        }; break;
        case GPUIMAGE_TONECURVE://(0.0, 1.0)
        {
            tempFilter = [[GPUImageToneCurveFilter alloc] init];
            [(GPUImageToneCurveFilter *)tempFilter setBlueControlPoints:[NSArray arrayWithObjects:[NSValue valueWithCGPoint:CGPointMake(0.0, 0.0)], [NSValue valueWithCGPoint:CGPointMake(0.5, 0.5)], [NSValue valueWithCGPoint:CGPointMake(1.0, 0.75)], nil]];
            [(GPUImageToneCurveFilter *)tempFilter setBlueControlPoints:[NSArray arrayWithObjects:[NSValue valueWithCGPoint:CGPointMake(0.0, 0.0)], [NSValue valueWithCGPoint:CGPointMake(0.5, 0.5)], [NSValue valueWithCGPoint:CGPointMake(1.0, 0.75)], nil]];
        }; break;
        case GPUIMAGE_HIGHLIGHTSHADOW://(0.0, 1.0)
        {
            tempFilter = [[GPUImageHighlightShadowFilter alloc] init];
            [(GPUImageHighlightShadowFilter *)tempFilter setHighlights:filterValue];
        }; break;
        case GPUIMAGE_HAZE://(-0.2, 0.2)
        {
            tempFilter = [[GPUImageHazeFilter alloc] init];
            [(GPUImageHazeFilter *)tempFilter setDistance:filterValue];
        }; break;
        case GPUIMAGE_GRAYSCALE:
        {
            tempFilter = [[GPUImageGrayscaleFilter alloc] init];
        }; break;
        case GPUIMAGE_SKETCH://0.0, 1.0
        {
            tempFilter = [[GPUImageSketchFilter alloc] init];
            [(GPUImageSketchFilter *)tempFilter setEdgeStrength:0.45];
        }; break;
        case GPUIMAGE_SMOOTHTOON://1.0, 6.0
        {
            tempFilter = [[GPUImageSmoothToonFilter alloc] init];
            [(GPUImageSmoothToonFilter *)tempFilter setBlurRadiusInPixels:1.0f];
        }; break;
        case GPUIMAGE_TILTSHIFT://0.2, 0.8
        {
            tempFilter = [[GPUImageTiltShiftFilter alloc] init];
            [(GPUImageTiltShiftFilter *)tempFilter setTopFocusLevel:0.4];
            [(GPUImageTiltShiftFilter *)tempFilter setBottomFocusLevel:0.6];
            [(GPUImageTiltShiftFilter *)tempFilter setFocusFallOffRate:filterValue];
        }; break;
        case GPUIMAGE_EMBOSS://0.0, 5.0
        {
            tempFilter = [[GPUImageEmbossFilter alloc] init];
            [(GPUImageEmbossFilter *)tempFilter setIntensity:filterValue];
        }; break;
        case GPUIMAGE_POSTERIZE://1.0, 20.0
        {
            tempFilter = [[GPUImagePosterizeFilter alloc] init];
            [(GPUImagePosterizeFilter *)tempFilter setColorLevels:filterValue];
        }; break;
        case GPUIMAGE_PINCH://-2.0, 2.0
        {
            tempFilter = [[GPUImagePinchDistortionFilter alloc] init];
            [(GPUImagePinchDistortionFilter *)tempFilter setScale:filterValue];
        }; break;
        case GPUIMAGE_VIGNETTE://0.5, 0.9
        {
            tempFilter = [[GPUImageVignetteFilter alloc] init];
            [(GPUImageVignetteFilter *)tempFilter setVignetteEnd:filterValue];
        }; break;
        case GPUIMAGE_GAUSSIAN://0.0, 24.0
        {
            tempFilter = [[GPUImageGaussianBlurFilter alloc] init];
            [(GPUImageGaussianBlurFilter *)tempFilter setBlurRadiusInPixels:2.0f];
        }; break;
        case GPUIMAGE_GAUSSIAN_SELECTIVE://0.0, 0.75f
        {
            tempFilter = [[GPUImageGaussianSelectiveBlurFilter alloc] init];
            [(GPUImageGaussianSelectiveBlurFilter*)tempFilter setExcludeCircleRadius:0.5f];
        }; break;
        case GPUIMAGE_GAUSSIAN_POSITION://0.0, 0.75
        {
            tempFilter = [[GPUImageGaussianBlurPositionFilter alloc] init];
            [(GPUImageGaussianBlurPositionFilter*)tempFilter setBlurRadius:0.5f];
        }; break;
    }
    
    return tempFilter;
}

-(void) checkFilterSlider
{
    self.filterSlider.hidden = NO;
    
    switch (self.filterIndex)
    {
        case GPUIMAGE_NONE:
        {
            self.filterValue = 0.5f;
            
            [self.filterSlider setMinimumValue:0.0f];
            [self.filterSlider setMaximumValue:1.0f];
            [self.filterSlider setValue:self.filterValue];
            
            self.filterSlider.hidden = YES;
        }; break;
        case GPUIMAGE_SEPIA://(0.0, 1.0)
        {
            self.filterValue = 1.0;
            
            [self.filterSlider setMinimumValue:0.0f];
            [self.filterSlider setMaximumValue:1.0f];
            [self.filterSlider setValue:self.filterValue];
        }; break;
        case GPUIMAGE_SATURATION://(0.0, 2.0)
        {
            self.filterValue = 1.8f;
            
            [self.filterSlider setMinimumValue:0.0f];
            [self.filterSlider setMaximumValue:2.0f];
            [self.filterSlider setValue:self.filterValue];
        }; break;
        case GPUIMAGE_CONTRAST://(0.0, 4.0)
        {
            self.filterValue = 2.0f;
            
            [self.filterSlider setMinimumValue:0.0f];
            [self.filterSlider setMaximumValue:4.0f];
            [self.filterSlider setValue:self.filterValue];
        }; break;
        case GPUIMAGE_BRIGHTNESS://(-1.0, 1.0)
        {
            self.filterValue = -0.2f;
            
            [self.filterSlider setMinimumValue:-1.0f];
            [self.filterSlider setMaximumValue:1.0f];
            [self.filterSlider setValue:self.filterValue];
        }; break;
        case GPUIMAGE_LEVELS://(0.0, 1.0)
        {
            self.filterValue = 0.5f;
            
            [self.filterSlider setMinimumValue:0.0f];
            [self.filterSlider setMaximumValue:1.0f];
            [self.filterSlider setValue:self.filterValue];
        }; break;
        case GPUIMAGE_EXPOSURE://(-4.0, 4.0)
        {
            self.filterValue = 1.0f;
            
            [self.filterSlider setMinimumValue:-4.0f];
            [self.filterSlider setMaximumValue:4.0f];
            [self.filterSlider setValue:self.filterValue];
        }; break;
        case GPUIMAGE_RGB://(0.0, 2.0)
        {
            self.filterValue = 1.5f;
            
            [self.filterSlider setMinimumValue:0.0f];
            [self.filterSlider setMaximumValue:2.0f];
            [self.filterSlider setValue:self.filterValue];
        }; break;
        case GPUIMAGE_HUE://(0.0, 360.0)
        {
            self.filterValue = 180.0f;
            
            [self.filterSlider setMinimumValue:0.0f];
            [self.filterSlider setMaximumValue:360.0f];
            [self.filterSlider setValue:self.filterValue];
        }; break;
        case GPUIMAGE_COLORINVERT:
        {
            self.filterValue = 0.5f;
            
            [self.filterSlider setMinimumValue:0.0f];
            [self.filterSlider setMaximumValue:1.0f];
            [self.filterSlider setValue:self.filterValue];
            
            self.filterSlider.hidden = YES;
        }; break;
        case GPUIMAGE_WHITEBALANCE://(2500, 7500)
        {
            self.filterValue = 3000.0f;
            
            [self.filterSlider setMinimumValue:2500];
            [self.filterSlider setMaximumValue:7500];
            [self.filterSlider setValue:self.filterValue];
        }; break;
        case GPUIMAGE_MONOCHROME://(0.0, 1.0)
        {
            self.filterValue = 1.0;
            
            [self.filterSlider setMinimumValue:0.0];
            [self.filterSlider setMaximumValue:1.0];
            [self.filterSlider setValue:self.filterValue];
        }; break;
        case GPUIMAGE_SHARPEN://(-1.0, 4.0)
        {
            self.filterValue = 2.0f;
            
            [self.filterSlider setMinimumValue:-1.0];
            [self.filterSlider setMaximumValue:4.0];
            [self.filterSlider setValue:self.filterValue];
        }; break;
        case GPUIMAGE_UNSHARPMASK://(0.0, 5.0)
        {
            self.filterValue = 2.0f;
            
            [self.filterSlider setMinimumValue:0.0];
            [self.filterSlider setMaximumValue:5.0];
            [self.filterSlider setValue:self.filterValue];
        }; break;
        case GPUIMAGE_GAMMA://(0.0, 3.0)
        {
            self.filterValue = 2.0f;
            
            [self.filterSlider setMinimumValue:0.0];
            [self.filterSlider setMaximumValue:3.0];
            [self.filterSlider setValue:self.filterValue];
        }; break;
        case GPUIMAGE_TONECURVE://(0.0, 1.0)
        {
            self.filterValue = 0.5;
            
            [self.filterSlider setMinimumValue:0.0];
            [self.filterSlider setMaximumValue:1.0];
            [self.filterSlider setValue:self.filterValue];
            self.filterSlider.hidden = YES;
        }; break;
        case GPUIMAGE_HIGHLIGHTSHADOW://(0.0, 1.0)
        {
            self.filterValue = 0.5;
            
            [self.filterSlider setMinimumValue:0.0];
            [self.filterSlider setMaximumValue:1.0];
            [self.filterSlider setValue:self.filterValue];
        }; break;
        case GPUIMAGE_HAZE://(-0.2, 0.2)
        {
            self.filterValue = 0.2;
            
            [self.filterSlider setMinimumValue:-0.2];
            [self.filterSlider setMaximumValue:0.2];
            [self.filterSlider setValue:self.filterValue];
        }; break;
        case GPUIMAGE_GRAYSCALE:
        {
            self.filterValue = 0.5f;
            
            [self.filterSlider setMinimumValue:0.0f];
            [self.filterSlider setMaximumValue:1.0f];
            [self.filterSlider setValue:self.filterValue];
            
            self.filterSlider.hidden = YES;
        }; break;
        case GPUIMAGE_SKETCH://0.0, 1.0
        {
            self.filterValue = 0.45;
            
            [self.filterSlider setMinimumValue:0.0];
            [self.filterSlider setMaximumValue:1.0];
            [self.filterSlider setValue:self.filterValue];
            
            self.filterSlider.hidden = YES;
        }; break;
        case GPUIMAGE_SMOOTHTOON://1.0, 6.0
        {
            self.filterValue = 1.0;
            
            [self.filterSlider setMinimumValue:1.0];
            [self.filterSlider setMaximumValue:6.0];
            [self.filterSlider setValue:self.filterValue];
            
            self.filterSlider.hidden = YES;
        }; break;
        case GPUIMAGE_TILTSHIFT://0.2, 0.8
        {
            self.filterValue = 0.2;
            
            [self.filterSlider setMinimumValue:0.2];
            [self.filterSlider setMaximumValue:0.8];
            [self.filterSlider setValue:self.filterValue];
        }; break;
        case GPUIMAGE_EMBOSS://0.0, 5.0
        {
            self.filterValue = 1.0;
            
            [self.filterSlider setMinimumValue:0.0];
            [self.filterSlider setMaximumValue:5.0];
            [self.filterSlider setValue:self.filterValue];
        }; break;
        case GPUIMAGE_POSTERIZE://1.0, 20.0
        {
            self.filterValue = 10.0f;
            
            [self.filterSlider setMinimumValue:1.0];
            [self.filterSlider setMaximumValue:20.0];
            [self.filterSlider setValue:self.filterValue];
        }; break;
        case GPUIMAGE_PINCH://-2.0, 2.0
        {
            self.filterValue = 0.5;
            
            [self.filterSlider setMinimumValue:-2.0];
            [self.filterSlider setMaximumValue:2.0];
            [self.filterSlider setValue:self.filterValue];
        }; break;
        case GPUIMAGE_VIGNETTE://0.5, 0.9
        {
            self.filterValue = 0.75;
            
            [self.filterSlider setMinimumValue:0.5];
            [self.filterSlider setMaximumValue:0.9];
            [self.filterSlider setValue:self.filterValue];
        }; break;
        case GPUIMAGE_GAUSSIAN://0.0, 24.0
        {
            self.filterValue = 2.0f;
            
            [self.filterSlider setMinimumValue:0.0f];
            [self.filterSlider setMaximumValue:24.0f];
            [self.filterSlider setValue:self.filterValue];
            
            self.filterSlider.hidden = YES;
        }; break;
        case GPUIMAGE_GAUSSIAN_SELECTIVE://0.0, 0.75f
        {
            self.filterValue = 0.5f;
            
            [self.filterSlider setMinimumValue:0.0f];
            [self.filterSlider setMaximumValue:0.75f];
            [self.filterSlider setValue:self.filterValue];
            
            self.filterSlider.hidden = YES;
        }; break;
        case GPUIMAGE_GAUSSIAN_POSITION://0.0, 0.75
        {
            self.filterValue = 0.5f;
            
            [self.filterSlider setMinimumValue:0.0f];
            [self.filterSlider setMaximumValue:0.75f];
            [self.filterSlider setValue:self.filterValue];
            
            self.filterSlider.hidden = YES;
        }; break;
    }
}


#pragma mark -
#pragma mark - Video Play, Seek Actions

- (void) actionPlay:(id*) sender
{
    if (self.isPlaying)
    {
        self.isPlaying = NO;
        
        [self.playBtn setImage:[UIImage imageNamed:@"NewPlay"] forState:UIControlStateNormal];
        [self.playBtn setImage:[UIImage imageNamed:@"NewPlay"] forState:UIControlStateSelected];
        
        [self.player pause];
    }
    else
    {
        self.isPlaying = YES;
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        {
            [self.playBtn setImage:[UIImage imageNamed:@"NewPause_iPhone"] forState:UIControlStateNormal];
            [self.playBtn setImage:[UIImage imageNamed:@"NewPause_iPhone"] forState:UIControlStateSelected];
        }
        else
        {
            [self.playBtn setImage:[UIImage imageNamed:@"NewPause_iPad"] forState:UIControlStateNormal];
            [self.playBtn setImage:[UIImage imageNamed:@"NewPause_iPad"] forState:UIControlStateSelected];
        }
        
        [self.player play];
    }
}

- (void) changeSeekSlider
{
    float time = self.seekSlider.value;
    
    self.isPlaying = NO;
    
    [self.playBtn setImage:[UIImage imageNamed:@"NewPlay"] forState:UIControlStateNormal];
    [self.playBtn setImage:[UIImage imageNamed:@"NewPlay"] forState:UIControlStateSelected];
    
    [self.player pause];
    [self.player seekToTime:CMTimeMake(time*self.player.currentItem.asset.duration.timescale, self.player.currentItem.asset.duration.timescale) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}


#pragma mark -
#pragma mark - Menu Apparence

-(void) actionShowMenu
{
    NSArray *menuItems = nil;
    
    menuItems =
    @[
      [YJLActionMenuItem menuItem:@"Cancel"
                            image:nil
                           target:self
                           action:@selector(cancelVideoFilter)],
      
      [YJLActionMenuItem menuItem:@"Apply Filter"
                            image:nil
                           target:self
                           action:@selector(applyVideoFilter)],
      
      [YJLActionMenuItem menuItem:@"Save to Album"
                            image:nil
                           target:self
                           action:@selector(didSaveFilteredVideoToAlbum)],
      ];
    
    [YJLActionMenu showMenuInView:self
                         fromRect:self.applyBtn.frame
                        menuItems:menuItems isWhiteBG:NO];
}


#pragma mark -
#pragma mark - Cancel, Apply, Save Actions

-(void) cancelVideoFilter
{
    [self.player pause];
    [self.player removeTimeObserver:self.observer];
    self.playerItem = nil;
    self.player = nil;
    
    [self.movieFile removeAllTargets];
    [self.movieFile endProcessing];
    self.movieFile = nil;
    
    [self.filter removeAllTargets];
    self.filter = nil;

    for (int i=0; i<self.thumbArray.count; i++)
    {
        VideoFilterThumbView* thumbView = [self.thumbArray objectAtIndex:i];
        [thumbView setVideoThumbImage:nil];
    }

    if ([self.delegate respondsToSelector:@selector(didCancelVideoFilterUI)])
    {
        [self.delegate didCancelVideoFilterUI];
    }
}

- (void)retrievingProgress
{
    [self.hudProgressView setProgress:self.movieFile.progress];
    
    if (self.movieFile.progress >= 1.0f)
    {
        [self.hudProgressView hide];
        [self.timer invalidate];

        [self.movieWriter endProcessing];
    }
}

-(void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    [[SHKActivityIndicator currentIndicator] hide];
    
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:@"Saved"
                              message:@"You can look this video on the Camera Roll."
                              delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
    [alertView show];
}


#pragma mark -
#pragma mark - Preview Processing!!!

-(void) previewSelectedFilter
{
    if (!self.playerItem)
    {
        self.playerItem = [[AVPlayerItem alloc] initWithURL:self.originalVideoUrl];
        self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
        
        AVAsset* asset = [AVAsset assetWithURL:self.originalVideoUrl];
        CGFloat duration = asset.duration.value / 500;
        
        __weak typeof (self) weakSelf = self;
        
        self.observer = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(MAX(1, duration), asset.duration.timescale) queue:/*dispatch_get_current_queue()*/ dispatch_get_main_queue() usingBlock:^(CMTime time) {
            
            if (CMTimeCompare(time, asset.duration) >= 0)
            {
                weakSelf.isPlaying = NO;
                [weakSelf.seekSlider setValue:0.0f];
                [weakSelf.videoPositionLabel setText:@"0:00"];
                [weakSelf.playBtn setImage:[UIImage imageNamed:@"NewPlay"] forState:UIControlStateNormal];
                [weakSelf.playBtn setImage:[UIImage imageNamed:@"NewPlay"] forState:UIControlStateSelected];
                [weakSelf.player pause];
                [weakSelf.player seekToTime:kCMTimeZero];
            }
            else
            {
                CGFloat currentTime = CMTimeGetSeconds(time);
                [weakSelf.seekSlider setValue:currentTime];
                int min = currentTime / 60;
                int sec = currentTime - (min * 60);
                [weakSelf.videoPositionLabel setText:[NSString stringWithFormat:@"%d:%02d", min, sec]];
            }
        }];
        
        self.movieFile = [[GPUImageMovie alloc] initWithPlayerItem:self.playerItem];
        self.movieFile.playAtActualSpeed = YES; //// if YES is fixed "Problem appending pixel buffer at time".
    }
    
    self.filter = [self setupFilterWithFilterValue:self.filterIndex value:self.filterValue];
    
    if (self.samplePipeline == nil)
    {
        self.samplePipeline = [[GPUImageFilterPipeline alloc] initWithOrderedFilters:@[self.filter] input:self.movieFile output:self.filterView];
        [self.movieFile startProcessing];
    }
    else
    {
        [self.samplePipeline replaceAllFilters:@[self.filter]];
        
        if (self.player.rate != 1.0f)
        {
            self.isPlaying = YES;
            
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
            {
                [self.playBtn setImage:[UIImage imageNamed:@"NewPause_iPhone"] forState:UIControlStateNormal];
                [self.playBtn setImage:[UIImage imageNamed:@"NewPause_iPhone"] forState:UIControlStateSelected];
            }
            else
            {
                [self.playBtn setImage:[UIImage imageNamed:@"NewPause_iPad"] forState:UIControlStateNormal];
                [self.playBtn setImage:[UIImage imageNamed:@"NewPause_iPad"] forState:UIControlStateSelected];
            }

            [self.player play];
        }
    }
}


#pragma mark -
#pragma mark -

-(void) applyVideoFilter
{
    self.samplePipeline = nil;
    
    [self.player pause];
    [self.player removeTimeObserver:self.observer];
    self.playerItem = nil;
    self.player = nil;
    
    [self.movieFile removeTarget:self.filter];
    [self.movieFile endProcessing];
    self.movieFile = nil;
    
    [self.filter removeAllTargets];
    self.filter = nil;

    self.isPlaying = NO;
    [self.seekSlider setValue:0.0f];
    [self.videoPositionLabel setText:@"0:00"];
    [self.playBtn setImage:[UIImage imageNamed:@"NewPlay"] forState:UIControlStateNormal];
    [self.playBtn setImage:[UIImage imageNamed:@"NewPlay"] forState:UIControlStateSelected];
    
    if (self.filterIndex == 0)
    {
        if ([self.delegate respondsToSelector:@selector(didApplyVideoFilter:)])
        {
            [self.delegate didApplyVideoFilter:self.originalVideoUrl];
        }
        
        return;
    }
    
    self.movieFile = [[GPUImageMovie alloc] initWithURL:self.originalVideoUrl];
    self.movieFile.playAtActualSpeed = YES; //// if YES is fixed "Problem appending pixel buffer at time".
    self.filter = [self setupFilterWithFilterValue:self.filterIndex value:self.filterValue];
    [self.movieFile addTarget:self.filter];
    
    NSDate *myDate = [NSDate date];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyyMMddhhmms"];
    NSString *dateForFilename = [df stringFromDate:myDate];
    NSString *folderDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *folderPath = [folderDir stringByAppendingPathComponent:gstrCurrentProjectName];
    NSURL *movieURL = [NSURL fileURLWithPath:[folderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"TrimVideo-%@.m4v", dateForFilename]]];
    
    AVAsset* asset = [AVAsset assetWithURL:self.originalVideoUrl];
    AVAssetTrack *assetTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    
    self.movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:assetTrack.naturalSize];
    [self.filter addTarget:self.movieWriter];
    self.movieWriter.shouldPassthroughAudio = YES;
    
    if ([[asset tracksWithMediaType:AVMediaTypeAudio] count] > 0)
        self.movieFile.audioEncodingTarget = self.movieWriter;
    else
        self.movieFile.audioEncodingTarget = nil;
    
    [self.movieFile enableSynchronizedEncodingUsingMovieWriter:self.movieWriter];
    
    [self.movieWriter startRecording];
    [self.movieFile startProcessing];
    
    //progress view
    self.hudProgressView = [[ATMHud alloc] initWithDelegate:self];
    self.hudProgressView.delegate = self;
    [self addSubview:self.hudProgressView.view];
    self.hudProgressView.view.center = self.filterView.center;
    [self.hudProgressView setCaption:@"Apply filter..."];
    [self.hudProgressView setProgress:0.08f];
    [self.hudProgressView show];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.02f
                                                  target:self
                                                selector:@selector(retrievingProgress)
                                                userInfo:nil
                                                 repeats:YES];
    
    __weak typeof (self) weakSelf = self;
    
    [self.movieWriter setCompletionBlock:^{
        
        dispatch_async(dispatch_get_main_queue(), ^{

            [weakSelf.filter removeTarget:weakSelf.movieWriter];

            [weakSelf.movieWriter finishRecordingWithCompletionHandler:^{
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [weakSelf.hudProgressView hide];
                    [weakSelf.timer invalidate];
                    
                    [weakSelf.movieFile removeAllTargets];
                    [weakSelf.movieFile endProcessing];
                    weakSelf.movieFile = nil;
                    
                    weakSelf.filter = nil;
                    
                    for (int i=0; i<weakSelf.thumbArray.count; i++)
                    {
                        VideoFilterThumbView* thumbView = [weakSelf.thumbArray objectAtIndex:i];
                        [thumbView setVideoThumbImage:nil];
                    }

                    if ([weakSelf.delegate respondsToSelector:@selector(didApplyVideoFilter:)])
                    {
                        [weakSelf.delegate didApplyVideoFilter:movieURL];
                    }
                    
                });

            }];
            
        });

    }];
    
    [self.movieWriter setFailureBlock:^(NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [weakSelf.filter removeTarget:weakSelf.movieWriter];

            [weakSelf.hudProgressView hide];
            [weakSelf.timer invalidate];
            
            UIAlertView *alertView = [[UIAlertView alloc]
                                      initWithTitle:@"Failed"
                                      message:error.description
                                      delegate:nil
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil];
            [alertView show];
            
            [weakSelf previewSelectedFilter];
        });
    }];
}

-(void) didSaveFilteredVideoToAlbum
{
    if (self.filterIndex == 0)
    {
        [[SHKActivityIndicator currentIndicator] displayActivity:(@"Saving...") isLock:YES];
        
        NSString* videoPath = [self.originalVideoUrl path];
        
        UISaveVideoAtPathToSavedPhotosAlbum(videoPath, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
        
        return;
    }
    
    self.samplePipeline = nil;
    
    [self.player pause];
    [self.player removeTimeObserver:self.observer];
    self.playerItem = nil;
    self.player = nil;
    
    [self.movieFile removeAllTargets];
    [self.movieFile endProcessing];
    self.movieFile = nil;
    
    [self.filter removeAllTargets];
    self.filter = nil;
    
    
    self.isPlaying = NO;
    [self.seekSlider setValue:0.0f];
    [self.videoPositionLabel setText:@"0:00"];
    [self.playBtn setImage:[UIImage imageNamed:@"NewPlay"] forState:UIControlStateNormal];
    [self.playBtn setImage:[UIImage imageNamed:@"NewPlay"] forState:UIControlStateSelected];
    
    
    self.movieFile = [[GPUImageMovie alloc] initWithURL:self.originalVideoUrl];
    self.movieFile.playAtActualSpeed = YES; //// if YES is fixed "Problem appending pixel buffer at time".
    
    //init filter
    self.filter = [self setupFilterWithFilterValue:self.filterIndex value:self.filterValue];
    
    [self.movieFile addTarget:self.filter];
    
    NSString *pathToMovie = [NSTemporaryDirectory() stringByAppendingPathComponent:@"VideoFilterTemp.m4v"];
    unlink([pathToMovie UTF8String]);
    NSURL *movieURL = [NSURL fileURLWithPath:pathToMovie];
    
    AVAsset* asset = [AVAsset assetWithURL:self.originalVideoUrl];
    AVAssetTrack *assetTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    
    self.movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:assetTrack.naturalSize];
    [self.filter addTarget:self.movieWriter];
    self.movieWriter.shouldPassthroughAudio = YES;
    
    if ([[asset tracksWithMediaType:AVMediaTypeAudio] count] > 0)
        self.movieFile.audioEncodingTarget = self.movieWriter;
    else
        self.movieFile.audioEncodingTarget = nil;
    
    [self.movieFile enableSynchronizedEncodingUsingMovieWriter:self.movieWriter];
    
    [self.movieWriter startRecording];
    [self.movieFile startProcessing];
    
    //progress view
    self.hudProgressView = [[ATMHud alloc] initWithDelegate:self];
    self.hudProgressView.delegate = self;
    [self addSubview:self.hudProgressView.view];
    self.hudProgressView.view.center = self.filterView.center;
    [self.hudProgressView setCaption:@"Apply filter..."];
    [self.hudProgressView setProgress:0.08f];
    [self.hudProgressView show];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.02f
                                                  target:self
                                                selector:@selector(retrievingProgress)
                                                userInfo:nil
                                                 repeats:YES];
    
    __weak typeof (self) weakSelf = self;
    
    [self.movieWriter setCompletionBlock:^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [weakSelf.filter removeTarget:weakSelf.movieWriter];

            [weakSelf.movieWriter finishRecordingWithCompletionHandler:^{
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [weakSelf.hudProgressView hide];
                    [weakSelf.timer invalidate];
                    
                    [[SHKActivityIndicator currentIndicator] displayActivity:(@"Saving...") isLock:YES];
                    
                    UISaveVideoAtPathToSavedPhotosAlbum(pathToMovie, weakSelf, @selector(video:didFinishSavingWithError:contextInfo:), nil);
                    
                    [weakSelf previewSelectedFilter];
                    
                });
                
            }];
            
        });
        
    }];
    
    [self.movieWriter setFailureBlock:^(NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [weakSelf.filter removeTarget:weakSelf.movieWriter];

            [weakSelf.hudProgressView hide];
            [weakSelf.timer invalidate];
            
            UIAlertView *alertView = [[UIAlertView alloc]
                                      initWithTitle:@"Failed"
                                      message:error.description
                                      delegate:nil
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil];
            [alertView show];
            
            [weakSelf.filter removeTarget:weakSelf.movieWriter];
            [weakSelf.movieWriter finishRecording];
            
            [weakSelf previewSelectedFilter];
        });
    }];
}


#pragma mark - 
#pragma mark -

-(void) filterSliderChanged
{
    self.filterValue = self.filterSlider.value;
    
    switch (self.filterIndex)
    {
        case GPUIMAGE_SEPIA://(0.0, 1.0)
        {
            [(GPUImageSepiaFilter *)self.filter setIntensity:self.self.filterValue];
        }; break;
        case GPUIMAGE_SATURATION://(0.0, 2.0)
        {
            [(GPUImageSaturationFilter *)self.filter setSaturation:self.filterValue];
        }; break;
        case GPUIMAGE_CONTRAST://(0.0, 4.0)
        {
            [(GPUImageContrastFilter *)self.filter setContrast:self.filterValue];
        }; break;
        case GPUIMAGE_BRIGHTNESS://(-1.0, 1.0)
        {
            [(GPUImageBrightnessFilter *)self.filter setBrightness:self.filterValue];
        }; break;
        case GPUIMAGE_LEVELS://(0.0, 1.0)
        {
            [(GPUImageLevelsFilter *)self.filter setRedMin:self.filterValue gamma:1.0 max:1.0 minOut:0.0 maxOut:1.0];
            [(GPUImageLevelsFilter *)self.filter setGreenMin:self.filterValue gamma:1.0 max:1.0 minOut:0.0 maxOut:1.0];
            [(GPUImageLevelsFilter *)self.filter setBlueMin:self.filterValue gamma:1.0 max:1.0 minOut:0.0 maxOut:1.0];
        }; break;
        case GPUIMAGE_EXPOSURE://(-4.0, 4.0)
        {
            [(GPUImageExposureFilter *)self.filter setExposure:self.filterValue];
        }; break;
        case GPUIMAGE_RGB://(0.0, 2.0)
        {
            [(GPUImageRGBFilter *)self.filter setGreen:self.filterValue];
        }; break;
        case GPUIMAGE_HUE://(0.0, 360.0)
        {
            [(GPUImageHueFilter *)self.filter setHue:self.filterValue];
        }; break;
        case GPUIMAGE_WHITEBALANCE://(2500, 7500)
        {
            [(GPUImageWhiteBalanceFilter *)self.filter setTemperature:self.filterValue];
        }; break;
        case GPUIMAGE_MONOCHROME://(0.0, 1.0)
        {
            [(GPUImageMonochromeFilter *)self.filter setIntensity:self.filterValue];
        }; break;
        case GPUIMAGE_SHARPEN://(-1.0, 4.0)
        {
            [(GPUImageSharpenFilter *)self.filter setSharpness:self.filterValue];
        }; break;
        case GPUIMAGE_UNSHARPMASK://(0.0, 5.0)
        {
            [(GPUImageUnsharpMaskFilter *)self.filter setIntensity:self.filterValue];
        }; break;
        case GPUIMAGE_GAMMA://(0.0, 3.0)
        {
            [(GPUImageGammaFilter *)self.filter setGamma:self.filterValue];
        }; break;
        case GPUIMAGE_HIGHLIGHTSHADOW://(0.0, 1.0)
        {
            [(GPUImageHighlightShadowFilter *)self.filter setHighlights:self.filterValue];
        }; break;
        case GPUIMAGE_HAZE://(-0.2, 0.2)
        {
            [(GPUImageHazeFilter *)self.filter setDistance:self.filterValue];
        }; break;
        case GPUIMAGE_TILTSHIFT://0.2, 0.8
        {
            [(GPUImageTiltShiftFilter *)self.filter setFocusFallOffRate:self.filterValue];
        }; break;
        case GPUIMAGE_EMBOSS://0.0, 5.0
        {
            [(GPUImageEmbossFilter *)self.filter setIntensity:self.filterValue];
        }; break;
        case GPUIMAGE_POSTERIZE://1.0, 20.0
        {
            [(GPUImagePosterizeFilter *)self.filter setColorLevels:self.filterValue];
        }; break;
        case GPUIMAGE_PINCH://-2.0, 2.0
        {
            [(GPUImagePinchDistortionFilter *)self.filter setScale:self.filterValue];
        }; break;
        case GPUIMAGE_VIGNETTE://0.5, 0.9
        {
            [(GPUImageVignetteFilter *)self.filter setVignetteEnd:self.filterValue];
        }; break;
    }
    
    if (self.player.rate != 1.0f)
    {
        self.isPlaying = YES;
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        {
            [self.playBtn setImage:[UIImage imageNamed:@"NewPause_iPhone"] forState:UIControlStateNormal];
            [self.playBtn setImage:[UIImage imageNamed:@"NewPause_iPhone"] forState:UIControlStateSelected];
        }
        else
        {
            [self.playBtn setImage:[UIImage imageNamed:@"NewPause_iPad"] forState:UIControlStateNormal];
            [self.playBtn setImage:[UIImage imageNamed:@"NewPause_iPad"] forState:UIControlStateSelected];
        }

        [self.player play];
    }
}


@end
