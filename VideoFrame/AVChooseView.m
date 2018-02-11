//
//  AVChooseView.m
//  VideoFrame
//
//  Created by Yinjing Li on 3/31/14.
//  Copyright (c) 2014 Yinjing Li. All rights reserved.
//


#import "AVChooseView.h"

@implementation AVChooseView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        CGFloat rTitleLabelHeight = 25.0f;
        CGFloat rFontSize = 0.0f;
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        {
            rTitleLabelHeight = 25.0f;
            rFontSize = 14.0f;
        }
        else
        {
            rTitleLabelHeight = 40.0f;
            rFontSize = 20.0f;
        }
        
        self.backgroundColor = [UIColor clearColor];
        
        // title label
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 10.0f, self.frame.size.width, rTitleLabelHeight)];
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.text = @"Replace Photo/Video";
        self.titleLabel.font = [UIFont fontWithName:MYRIADPRO size:rFontSize];
        self.titleLabel.adjustsFontSizeToFitWidth = YES;
        self.titleLabel.minimumScaleFactor = 0.1f;
        self.titleLabel.numberOfLines = 0;
        self.titleLabel.textColor = [UIColor whiteColor];
        [self addSubview:self.titleLabel];
        
        UIImage* backgroundImage = [self makeBackgroundImage:CGSizeMake(self.frame.size.width/2.0f - 15.0f, rTitleLabelHeight)];
        
        self.photoCamBtn = [self createCustomButton:CGRectMake(10.0f, rTitleLabelHeight + 20.0f, self.frame.size.width/2.0f - 15.0f, rTitleLabelHeight) image:backgroundImage title:@"PhotoCam" size:rFontSize];
        [self.photoCamBtn addTarget:self action:@selector(didPhotoCam:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.photoCamBtn];
        
        self.videoCamBtn = [self createCustomButton:CGRectMake(self.frame.size.width/2.0f + 5.0f, rTitleLabelHeight + 20.0f, self.frame.size.width/2.0f - 15.0f, rTitleLabelHeight) image:backgroundImage title:@"VideoCam" size:rFontSize];
        [self.videoCamBtn addTarget:self action:@selector(didVideoCam:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.videoCamBtn];

        self.photoGalleryBtn = [self createCustomButton:CGRectMake(10.0f, 2*rTitleLabelHeight + 30.0f, self.frame.size.width/2.0f - 15.0f, rTitleLabelHeight) image:backgroundImage title:@"Photos" size:rFontSize];
        [self.photoGalleryBtn addTarget:self action:@selector(didPhotoGallery:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.photoGalleryBtn];

        self.videoGalleryBtn = [self createCustomButton:CGRectMake(self.frame.size.width/2.0f + 5.0f, 2*rTitleLabelHeight + 30.0f, self.frame.size.width/2.0f - 15.0f, rTitleLabelHeight) image:backgroundImage title:@"Videos" size:rFontSize];
        [self.videoGalleryBtn addTarget:self action:@selector(didVideoGallery:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.videoGalleryBtn];
    }
    
    return self;
}

- (UIButton*) createCustomButton:(CGRect) frame image:(UIImage*) backgroundImage title:(NSString*) title size:(CGFloat) rFontSize
{
    UIButton* customButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [customButton setFrame:frame];
    customButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    customButton.backgroundColor = UIColorFromRGB(0x53585f);
    [customButton setBackgroundImage:backgroundImage forState:UIControlStateHighlighted];
    [customButton setBackgroundImage:backgroundImage forState:UIControlStateSelected|UIControlStateHighlighted];
    customButton.layer.masksToBounds = YES;
    customButton.layer.borderColor = [UIColor whiteColor].CGColor;
    customButton.layer.borderWidth = 1.0f;
    customButton.layer.cornerRadius = 5.0f;
    [customButton setTitle:title forState:UIControlStateNormal];
    customButton.titleLabel.font = [UIFont fontWithName:MYRIADPRO size:rFontSize];
    customButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    customButton.titleLabel.minimumScaleFactor = 0.1f;
    customButton.titleLabel.numberOfLines = 0;

    return customButton;
}

- (UIImage*) makeBackgroundImage:(CGSize) size
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(size.width, size.height), NO, 0.0);
    CGContextSetFillColorWithColor(UIGraphicsGetCurrentContext(), UIColorFromRGB(0x9da1a0).CGColor);
    
    CGRect r = CGRectMake(0.0f, 0.0f, size.width, size.height);
    CGFloat cornerRadius = 5.0f;
    
    CGMutablePathRef path = CGPathCreateMutable() ;
    CGPathMoveToPoint( path, NULL, r.origin.x + cornerRadius, r.origin.y ) ;
    CGFloat maxX = CGRectGetMaxX( r ) ;    CGFloat maxY = CGRectGetMaxY( r ) ;
    CGPathAddArcToPoint( path, NULL, maxX, r.origin.y, maxX, r.origin.y + cornerRadius, cornerRadius ) ;
    CGPathAddArcToPoint( path, NULL, maxX, maxY, maxX - cornerRadius, maxY, cornerRadius ) ;
    CGPathAddArcToPoint( path, NULL, r.origin.x, maxY, r.origin.x, maxY - cornerRadius, cornerRadius ) ;
    CGPathAddArcToPoint( path, NULL, r.origin.x, r.origin.y, r.origin.x + cornerRadius, r.origin.y, cornerRadius ) ;
    CGContextAddPath(UIGraphicsGetCurrentContext(), path);
    CGContextFillPath(UIGraphicsGetCurrentContext());
    CGPathRelease(path);
    
    UIImage* resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resultImage;
}

- (void) didPhotoCam:(id) sender
{
    if ([self.delegate respondsToSelector:@selector(onPhotoFromCamera)])
    {
        [self.delegate onPhotoFromCamera];
    }
}

- (void) didVideoCam:(id) sender
{
    if ([self.delegate respondsToSelector:@selector(onVideoFromCamera)])
    {
        [self.delegate onVideoFromCamera];
    }
}

- (void) didPhotoGallery:(id) sender
{
    if ([self.delegate respondsToSelector:@selector(onPhotoFromGallery)])
    {
        [self.delegate onPhotoFromGallery];
    }
}

- (void) didVideoGallery:(id) sender
{
    if ([self.delegate respondsToSelector:@selector(onVideoFromGallery)])
    {
        [self.delegate onVideoFromGallery];
    }
}


@end
