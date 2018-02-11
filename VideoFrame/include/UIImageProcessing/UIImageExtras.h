//
//  UIImageExtras.h
//  DreamClouds
//
//  Created by Yinjing Li and Frederick Weber on 1/29/13.
//  Copyright (c) 2013 __MontanaSky_Networks_Inc__. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * Convenience methods to help with resizing images retrieved from the 
 * ObjectiveFlickr library.
 */
@interface UIImage (OpenFlowExtras)

- (UIImage*) rescaleImageToSize:(CGSize)size;
- (UIImage*) rescaleGIFImageToSize:(CGSize)size;
- (UIImage*) cropImageToRect:(CGRect)cropRect;
- (CGSize) calculateNewSizeForCroppingBox:(CGSize)croppingBox;
- (UIImage*) cropCenterAndScaleImageToSize:(CGSize)cropSize;
- (UIImage*) imageByScalingProportionallyToSize:(CGSize)targetSize;
- (UIImage*) imageWithOverlayColor:(UIColor *)color;
+ (UIImage*) rotateImage:(UIImage *)image;
- (BOOL)detectTransparency;

@end