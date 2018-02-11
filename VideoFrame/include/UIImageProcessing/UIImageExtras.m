//
//  UIImageExtras.h
//  DreamClouds
//
//  Created by Yinjing Li and Frederick Weber on 1/29/13.
//  Copyright (c) 2013 __MontanaSky_Networks_Inc__. All rights reserved.
//

#import "UIImageExtras.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <ImageIO/ImageIO.h>

@import UIKit;

@implementation UIImage (OpenFlowExtras)


- (UIImage *)rescaleImageToSize:(CGSize)size
{
    CGRect rect = CGRectMake(0.0, 0.0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    [self drawInRect:rect];  // scales image to rect
    UIImage* rescaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return rescaledImage;
}


- (UIImage *)rescaleGIFImageToSize:(CGSize)size
{
    UIImage* rescaledImage = nil;
    
    if (self.images.count > 1)
    {
        NSMutableArray *mutableImages = [NSMutableArray arrayWithCapacity:self.images.count];
        
        for (int i=0; i<self.images.count; i++)
        {
            UIImage* image = [self.images objectAtIndex:i];
            
            CGRect rect = CGRectMake(0.0, 0.0, size.width, size.height);
            UIGraphicsBeginImageContext(rect.size);
            [image drawInRect:rect];
            UIImage *resImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            [mutableImages addObject:resImage];
        }
        
        rescaledImage = [UIImage animatedImageWithImages:mutableImages duration:self.duration];
        
        [mutableImages removeAllObjects];
        mutableImages = nil;
    }
    else
    {
        CGRect rect = CGRectMake(0.0, 0.0, size.width, size.height);
        UIGraphicsBeginImageContext(rect.size);
        [self drawInRect:rect];  // scales image to rect
        rescaledImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    return rescaledImage;
}


- (UIImage *)cropImageToRect:(CGRect)cropRect
{
    UIGraphicsBeginImageContext(cropRect.size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(ctx, 0.0, cropRect.size.height);
    CGContextScaleCTM(ctx, 1.0, -1.0);
    CGRect drawRect = CGRectMake(-cropRect.origin.x, cropRect.origin.y - (self.size.height - cropRect.size.height) , self.size.width, self.size.height);
    CGContextDrawImage(ctx, drawRect, self.CGImage);
    UIImage* cropImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return cropImage;
}

- (CGSize)calculateNewSizeForCroppingBox:(CGSize)croppingBox
{
	// Make the shortest side be equivalent to the cropping box.
	CGFloat newHeight, newWidth;
	if (self.size.width < self.size.height) {
		newWidth = croppingBox.width;
		newHeight = (self.size.height / self.size.width) * croppingBox.width;
	} else {
		newHeight = croppingBox.height;
		newWidth = (self.size.width / self.size.height) *croppingBox.height;
	}
	
	return CGSizeMake(newWidth, newHeight);
}

- (UIImage *)cropCenterAndScaleImageToSize:(CGSize)cropSize
{
	UIGraphicsBeginImageContext(cropSize);
	CGContextRef context = UIGraphicsGetCurrentContext();
	UIColor *colour=[UIColor clearColor];
	CGContextSetFillColorWithColor(context, [colour CGColor]);
	CGContextFillRect(context, CGRectMake(0, 0, cropSize.width, cropSize.height));

	CGRect rect;
	
    if (self.size.height<self.size.width)
    {
		CGFloat newWidth=cropSize.height/self.size.height*self.size.width;
		rect=CGRectMake((cropSize.width-newWidth)/2, 0, newWidth, cropSize.height);
	}
    else
    {
		CGFloat newHeight=cropSize.width/self.size.width*self.size.height;
		rect=CGRectMake(0, (cropSize.height-newHeight)/2, cropSize.width, newHeight);
	}
    
	[self drawInRect:rect];
    
	UIImage *result=UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
    return result;
}

- (UIImage *)imageByScalingProportionallyToSize:(CGSize)targetSize
{
    UIImage *sourceImage = self;
    UIImage *newImage = nil;
    
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    if (!CGSizeEqualToSize(imageSize, targetSize))
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor < heightFactor) 
            scaleFactor = widthFactor;
        else
            scaleFactor = heightFactor;
        
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        
        if (widthFactor < heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5; 
        }
        else if (widthFactor > heightFactor)
        {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    
    // this is actually the interesting part:
    
    UIGraphicsBeginImageContext(targetSize);
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if(newImage == nil)
        NSLog(@"could not scale image");
    
    return newImage ;
}

/* overlay color 20120922 */
- (UIImage *)imageWithOverlayColor:(UIColor *)color
{        
    CGRect rect = CGRectMake(0.0f, 0.0f, self.size.width, self.size.height);
    
    UIGraphicsBeginImageContext(self.size);
    
    [self drawInRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetBlendMode(context, kCGBlendModeSourceIn);
    
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage *)rotateImage:(UIImage *)image
{
    CGImageRef imgRef = image.CGImage;
    
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
    CGFloat boundHeight;

    UIImageOrientation orient = image.imageOrientation;
    
    switch(orient)
    {
        case UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
            
        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
            
        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
            
        case UIImageOrientationLeftMirrored: //EXIF = 5
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationLeft: //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationRightMirrored: //EXIF = 7
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        case UIImageOrientationRight: //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
            
    }
    
    UIGraphicsBeginImageContext(bounds.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft)
    {
        CGContextScaleCTM(context, -1, 1);
        CGContextTranslateCTM(context, -height, 0);
    }
    else
    {
        CGContextScaleCTM(context, 1, -1);
        CGContextTranslateCTM(context, 0, -height);
    }
    
    CGContextConcatCTM(context, transform);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imageCopy;
}

- (UIImage*) rotateImageAppropriately:(int) nIndex
{
    CGImageRef imageRef = [self CGImage];
    UIImage* properlyRotatedImage;
    
    if (nIndex == 0)
    {
        //Don't rotate the image
        properlyRotatedImage = self;
    }
    else if (nIndex == 1)
    {
        //We need to rotate the image back to a 3
        properlyRotatedImage = [UIImage imageWithCGImage:imageRef scale:1.0 orientation:UIImageOrientationRight];
    }
    else if (nIndex == 2)
    {
        //We need to rotate the image back to a 1
        properlyRotatedImage = [UIImage imageWithCGImage:imageRef scale:1.0 orientation:UIImageOrientationDown];
    }
    else
    {
        //We need to rotate the image back to a 1
        properlyRotatedImage = [UIImage imageWithCGImage:imageRef scale:1.0 orientation:UIImageOrientationLeft];
    }
    
    return properlyRotatedImage;
}


#pragma mark -
#pragma mark - Detect Transparent using Histogram

-(BOOL)detectTransparency
{
    @autoreleasepool
    {
        NSUInteger width = CGImageGetWidth(self.CGImage);
        NSUInteger height = CGImageGetHeight(self.CGImage);
        
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        
        unsigned char *rawData = (unsigned char*) calloc(height * width * 4, sizeof(unsigned char));
        
        NSUInteger bytesPerPixel = 4;
        NSUInteger bytesPerRow = bytesPerPixel * width;
        NSUInteger bitsPerComponent = 8;
        
        CGContextRef context = CGBitmapContextCreate(rawData, width, height, bitsPerComponent, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
        
        CGContextDrawImage(context, CGRectMake(0, 0, width, height), self.CGImage);
        
        CFRelease(context);
        CGColorSpaceRelease(colorSpace);
        
        for (int yy=0;yy<height; yy++)
        {
            for (int xx=0; xx<width; xx++)
            {
                // Now your rawData contains the image data in the RGBA8888 pixel format.
                int byteIndex = ((int)bytesPerRow * yy) + xx * (int)bytesPerPixel;
                
                for (int ii = 0 ; ii < 1 ; ++ii)
                {
                    CGFloat alpha = (rawData[byteIndex + 3] * 1.0) / 255.0;
                    byteIndex += 4;
                    
                    if (alpha == 0.0f)
                    {
                        free(rawData);
                        return YES;
                    }
                    
                }
            }
        }
        
        free(rawData);
    }

    return NO;
}


@end