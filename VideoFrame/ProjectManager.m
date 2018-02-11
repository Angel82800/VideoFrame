//
//  ProjectManager.m
//  VideoFrame
//
//  Created by Yinjing Li on 6/18/14.
//  Copyright (c) 2014 Yinjing Li. All rights reserved.
//

#import "ProjectManager.h"
#import "UIImageExtras.h"


@implementation ProjectManager

@synthesize projectName = _projectName;



-(id)init
{
    self = [super init];
    
    if (self)
    {

    }
    
    return self;
}


#pragma mark -
#pragma mark - Create New Project

-(NSString*) createNewProject
{
    NSDate *myDate = [NSDate date];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd-hh-mm-s"];
    
    self.projectName = [df stringFromDate:myDate];

    NSString *folderDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *folderPath = [folderDir stringByAppendingPathComponent:self.projectName];

    NSFileManager *localFileManager = [NSFileManager defaultManager];
    [localFileManager createDirectoryAtPath:folderPath withIntermediateDirectories:NO attributes:nil error:nil];
    
    return self.projectName;
}


#pragma mark -
#pragma mark - Delete Project

-(void) deleteProject
{
    NSString *folderDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *folderPath = [folderDir stringByAppendingPathComponent:self.projectName];

    NSFileManager *localFileManager = [NSFileManager defaultManager];
    [localFileManager removeItemAtPath:folderPath error:NULL];
}

-(void) noSaveProject
{
    NSString *folderDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *folderPath = [folderDir stringByAppendingPathComponent:self.projectName];
    
    NSFileManager *localFileManager = [NSFileManager defaultManager];
    
    NSString* plistFileName = [folderPath stringByAppendingPathComponent:@"project.plist"];
    
    if (![localFileManager fileExistsAtPath:plistFileName])
        [localFileManager removeItemAtPath:folderPath error:NULL];
}


#pragma mark -
#pragma mark - Delete File

-(void) deleteFile:(NSString*) filename
{
    NSString *folderDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *folderPath = [folderDir stringByAppendingPathComponent:self.projectName];
    
    NSFileManager *localFileManager = [NSFileManager defaultManager];
    
    filename = [folderPath stringByAppendingPathComponent:filename];
    
    if ([localFileManager fileExistsAtPath:filename])
        [localFileManager removeItemAtPath:filename error:NULL];
}

#pragma mark - 
#pragma mark - Save Project

-(void) saveProject:(UIImage*) screenShotImg objects:(NSMutableArray*) objectArray
{
    NSFileManager *localFileManager = [NSFileManager defaultManager];

    NSString *folderDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *folderPath = [folderDir stringByAppendingPathComponent:self.projectName];
    
    NSError *error;

    /************ Save Project Screenshot ****************/
    NSString* screenshotFileName = [folderPath stringByAppendingPathComponent:@"screenshot.png"];
    
    if ([localFileManager fileExistsAtPath:screenshotFileName])
        [localFileManager removeItemAtPath:screenshotFileName error:&error ];

    [UIImagePNGRepresentation(screenShotImg)  writeToFile:screenshotFileName atomically:YES];
    
    
    /*********** Create plist or get path of plist ***********/
    NSString* plistFileName = [folderPath stringByAppendingPathComponent:@"project.plist"];
    
    if ([localFileManager fileExistsAtPath:plistFileName])
        [localFileManager removeItemAtPath:plistFileName error:&error ];

    [localFileManager createFileAtPath:plistFileName contents:nil attributes:nil];
    
    
    /********************** Save Data ************************/
    
    NSMutableDictionary *plistDict = [NSMutableDictionary dictionary];

    [plistDict setObject:[NSNumber numberWithInt:gnOrientation] forKey:@"gnOrientation"];
    [plistDict setObject:[NSNumber numberWithInt:gnInstagramOrientation] forKey:@"gnInstagramOrientation"];
    [plistDict setObject:[NSNumber numberWithInt:gnTemplateIndex] forKey:@"gnTemplateIndex"];
    [plistDict setObject:[NSNumber numberWithInt:(int)objectArray.count] forKey:@"ObjectArrayCount"];
    [plistDict setObject:[NSNumber numberWithFloat:grNormalFilterOutputTotalTime] forKey:@"gfNormalFilterOutputTotalTime"];

    
    for (int i=0; i<objectArray.count; i++)
    {
        MediaObjectView* object = [objectArray objectAtIndex:i];
        
        [plistDict setObject:[NSNumber numberWithInt:object.mediaType] forKey:[NSString stringWithFormat:@"%d-mediaType", i]];
        
        [plistDict setObject:[NSNumber numberWithBool:object.isGrouped] forKey:[NSString stringWithFormat:@"%d-isGrouped", i]];

        if (object.mediaType == MEDIA_PHOTO)
        {
            [plistDict setObject:object.imageName forKey:[NSString stringWithFormat:@"%d-imageName", i]];
            [plistDict setObject:[NSNumber numberWithFloat:object.imageView.alpha] forKey:[NSString stringWithFormat:@"%d-objectOpacity", i]];
            
            NSString* filteredImageFileName = [folderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"obj_filter_%d.png", i]];
            
            [UIImagePNGRepresentation(object.imageView.image) writeToFile:filteredImageFileName atomically:YES];
            
            [plistDict setObject:[NSString stringWithFormat:@"obj_filter_%d.png", i] forKey:[NSString stringWithFormat:@"%d-filterImageName", i]];

            [plistDict setObject:[NSNumber numberWithInteger:object.photoFilterIndex] forKey:[NSString stringWithFormat:@"%d-photoFilterIndex", i]];
            [plistDict setObject:[NSNumber numberWithFloat:object.photoFilterValue] forKey:[NSString stringWithFormat:@"%d-photoFilterValue", i]];

            //shape save
            if (object.isShape)
            {
                [plistDict setObject:[NSNumber numberWithBool:object.isShape] forKey:[NSString stringWithFormat:@"%d-isShape", i]];
                [plistDict setObject:[NSNumber numberWithInt:object.shapeOverlayStyle] forKey:[NSString stringWithFormat:@"%d-shapeOverlayStyle", i]];
                
                const CGFloat* colors = CGColorGetComponents(object.shapeOverlayColor.CGColor);
                CGFloat red = colors[0];
                CGFloat green = colors[1];
                CGFloat blue = colors[2];
                CGFloat alpha = CGColorGetAlpha(object.shapeOverlayColor.CGColor);
                
                [plistDict setObject:[NSNumber numberWithFloat:red] forKey:[NSString stringWithFormat:@"%d-shapeOverlayColor-Red", i]];
                [plistDict setObject:[NSNumber numberWithFloat:green] forKey:[NSString stringWithFormat:@"%d-shapeOverlayColor-Green", i]];
                [plistDict setObject:[NSNumber numberWithFloat:blue] forKey:[NSString stringWithFormat:@"%d-shapeOverlayColor-Blue", i]];
                [plistDict setObject:[NSNumber numberWithFloat:alpha] forKey:[NSString stringWithFormat:@"%d-shapeOverlayColor-Alpha", i]];
            }
        }
        else if (object.mediaType == MEDIA_GIF)
        {
            [plistDict setObject:object.imageName forKey:[NSString stringWithFormat:@"%d-gifName", i]];
            [plistDict setObject:[NSNumber numberWithFloat:object.imageView.alpha] forKey:[NSString stringWithFormat:@"%d-objectOpacity", i]];
        }
        else if (object.mediaType == MEDIA_VIDEO)
        {
            NSString* videoName = [object.mediaUrl lastPathComponent];
            [plistDict setObject:videoName forKey:[NSString stringWithFormat:@"%d-videoName", i]];
            [plistDict setObject:[NSNumber numberWithFloat:object.imageView.alpha] forKey:[NSString stringWithFormat:@"%d-objectOpacity", i]];
        }
        else if (object.mediaType == MEDIA_MUSIC)
        {
            NSString* musicName = [object.mediaUrl lastPathComponent];
            [plistDict setObject:musicName forKey:[NSString stringWithFormat:@"%d-musicName", i]];
            [plistDict setObject:[NSNumber numberWithFloat:1.0f] forKey:[NSString stringWithFormat:@"%d-objectOpacity", i]];
        }
        else if (object.mediaType == MEDIA_TEXT)
        {
            const CGFloat* colors = CGColorGetComponents(object.textView.textColor.CGColor);
            CGFloat red = colors[0];
            CGFloat green = colors[1];
            CGFloat blue = colors[2];
            CGFloat alpha = CGColorGetAlpha(object.textView.textColor.CGColor);
            
            [plistDict setObject:[NSNumber numberWithFloat:red] forKey:[NSString stringWithFormat:@"%d-textViewTextColor-Red", i]];
            [plistDict setObject:[NSNumber numberWithFloat:green] forKey:[NSString stringWithFormat:@"%d-textViewTextColor-Green", i]];
            [plistDict setObject:[NSNumber numberWithFloat:blue] forKey:[NSString stringWithFormat:@"%d-textViewTextColor-Blue", i]];
            [plistDict setObject:[NSNumber numberWithFloat:alpha] forKey:[NSString stringWithFormat:@"%d-textViewTextColor-Alpha", i]];
            [plistDict setObject:[object.textView.font fontName] forKey:[NSString stringWithFormat:@"%d-textViewFontName", i]];
            [plistDict setObject:NSStringFromCGRect(object.textView.frame) forKey:[NSString stringWithFormat:@"%d-textViewFrame", i]];
            [plistDict setObject:[NSNumber numberWithFloat:object.textObjectFontSize] forKey:[NSString stringWithFormat:@"%d-textObjectFontSize", i]];
            [plistDict setObject:[NSNumber numberWithInteger:object.textView.textAlignment] forKey:[NSString stringWithFormat:@"%d-textViewTextAlignment", i]];
            [plistDict setObject:[NSNumber numberWithBool:object.isBold] forKey:[NSString stringWithFormat:@"%d-isBold", i]];
            [plistDict setObject:[NSNumber numberWithBool:object.isItalic] forKey:[NSString stringWithFormat:@"%d-isItalic", i]];
            [plistDict setObject:[NSNumber numberWithBool:object.isUnderline] forKey:[NSString stringWithFormat:@"%d-isUnderline", i]];
            [plistDict setObject:[NSNumber numberWithBool:object.isStroke] forKey:[NSString stringWithFormat:@"%d-isStroke", i]];
            [plistDict setObject:object.textView.text forKey:[NSString stringWithFormat:@"%d-text", i]];
            [plistDict setObject:[NSNumber numberWithFloat:object.textView.alpha] forKey:[NSString stringWithFormat:@"%d-objectOpacity", i]];
        }

        if ((object.mediaType == MEDIA_PHOTO)||(object.mediaType == MEDIA_GIF)||(object.mediaType == MEDIA_VIDEO)||(object.mediaType == MEDIA_TEXT))
        {
            [plistDict setObject:NSStringFromCGSize(object.workspaceSize) forKey:[NSString stringWithFormat:@"%d-workspaceSize", i]];
            [plistDict setObject:NSStringFromCGSize(object.originalVideoSize) forKey:[NSString stringWithFormat:@"%d-originalVideoSize", i]];
            [plistDict setObject:NSStringFromCGSize(object.superViewSize) forKey:[NSString stringWithFormat:@"%d-superViewSize", i]];
            [plistDict setObject:NSStringFromCGRect(object.mediaView.frame) forKey:[NSString stringWithFormat:@"%d-mediaViewFrame", i]];
            [plistDict setObject:NSStringFromCGRect(object.imageView.frame) forKey:[NSString stringWithFormat:@"%d-imageViewFrame", i]];
            [plistDict setObject:NSStringFromCGRect(object.videoView.frame) forKey:[NSString stringWithFormat:@"%d-videoViewFrame", i]];
            [plistDict setObject:NSStringFromCGRect(object.frame) forKey:[NSString stringWithFormat:@"%d-frame", i]];
            [plistDict setObject:NSStringFromCGRect(object.bounds) forKey:[NSString stringWithFormat:@"%d-bounds", i]];
            [plistDict setObject:NSStringFromCGRect(object.originalBounds) forKey:[NSString stringWithFormat:@"%d-originalBounds", i]];
            [plistDict setObject:NSStringFromCGRect(object.normalFilterVideoCropRect) forKey:[NSString stringWithFormat:@"%d-normalFilterVideoCropRect", i]];
            [plistDict setObject:NSStringFromCGRect(object.borderLineLayer.frame) forKey:[NSString stringWithFormat:@"%d-borderLineLayerFrame", i]];
            [plistDict setObject:NSStringFromCGPoint(object.lastPoint) forKey:[NSString stringWithFormat:@"%d-lastPoint", i]];
            [plistDict setObject:NSStringFromCGPoint(object.firstTouchedPoint) forKey:[NSString stringWithFormat:@"%d-firstTouchedPoint", i]];
            [plistDict setObject:NSStringFromCGPoint(object.reflectionDelta) forKey:[NSString stringWithFormat:@"%d-reflectionDelta", i]];
            [plistDict setObject:NSStringFromCGPoint(object.originalVideoCenter) forKey:[NSString stringWithFormat:@"%d-originalVideoCenter", i]];
            [plistDict setObject:NSStringFromCGPoint(object.changedVideoCenter) forKey:[NSString stringWithFormat:@"%d-changedVideoCenter", i]];
            [plistDict setObject:[NSNumber numberWithFloat:object.mediaDuration] forKey:[NSString stringWithFormat:@"%d-mediaDuration", i]];
            [plistDict setObject:[NSNumber numberWithFloat:object.mediaVolume] forKey:[NSString stringWithFormat:@"%d-mediaVolume", i]];
            [plistDict setObject:[NSNumber numberWithFloat:object.mfStartPosition] forKey:[NSString stringWithFormat:@"%d-mfStartPosition", i]];
            [plistDict setObject:[NSNumber numberWithFloat:object.mfEndPosition] forKey:[NSString stringWithFormat:@"%d-mfEndPosition", i]];
            [plistDict setObject:[NSNumber numberWithFloat:object.mfStartAnimationDuration] forKey:[NSString stringWithFormat:@"%d-mfStartAnimationDuration", i]];
            [plistDict setObject:[NSNumber numberWithFloat:object.mfEndAnimationDuration] forKey:[NSString stringWithFormat:@"%d-mfEndAnimationDuration", i]];
            [plistDict setObject:[NSNumber numberWithFloat:object.lastScaleFactor] forKey:[NSString stringWithFormat:@"%d-lastScaleFactor", i]];
            [plistDict setObject:[NSNumber numberWithFloat:object.rotateAngle] forKey:[NSString stringWithFormat:@"%d-rotateAngle", i]];
            [plistDict setObject:[NSNumber numberWithFloat:object.scaleValue] forKey:[NSString stringWithFormat:@"%d-scaleValue", i]];
            [plistDict setObject:[NSNumber numberWithFloat:object.portraitSpecialScale] forKey:[NSString stringWithFormat:@"%d-portraitSpecialScale", i]];
            [plistDict setObject:[NSNumber numberWithFloat:object.firstX] forKey:[NSString stringWithFormat:@"%d-firstX", i]];
            [plistDict setObject:[NSNumber numberWithFloat:object.firstY] forKey:[NSString stringWithFormat:@"%d-firstY", i]];
            [plistDict setObject:[NSNumber numberWithFloat:object.mySX] forKey:[NSString stringWithFormat:@"%d-mySX", i]];
            [plistDict setObject:[NSNumber numberWithFloat:object.mySY] forKey:[NSString stringWithFormat:@"%d-mySY", i]];
            [plistDict setObject:[NSNumber numberWithFloat:object.objectBorderWidth] forKey:[NSString stringWithFormat:@"%d-objectBorderWidth", i]];
            [plistDict setObject:[NSNumber numberWithFloat:object.objectShadowBlur] forKey:[NSString stringWithFormat:@"%d-objectShadowBlur", i]];
            [plistDict setObject:[NSNumber numberWithFloat:object.objectShadowOffset] forKey:[NSString stringWithFormat:@"%d-objectShadowOffset", i]];
            [plistDict setObject:[NSNumber numberWithFloat:object.objectCornerRadius] forKey:[NSString stringWithFormat:@"%d-objectCornerRadius", i]];
            [plistDict setObject:[NSNumber numberWithFloat:object.reflectionScale] forKey:[NSString stringWithFormat:@"%d-reflectionScale", i]];
            [plistDict setObject:[NSNumber numberWithFloat:object.reflectionAlpha] forKey:[NSString stringWithFormat:@"%d-reflectionAlpha", i]];
            [plistDict setObject:[NSNumber numberWithFloat:object.reflectionGap] forKey:[NSString stringWithFormat:@"%d-reflectionGap", i]];
            [plistDict setObject:object.motionArray forKey:[NSString stringWithFormat:@"%d-motionArray", i]];
            [plistDict setObject:object.startPositionArray forKey:[NSString stringWithFormat:@"%d-startPositionArray", i]];
            [plistDict setObject:object.endPositionArray forKey:[NSString stringWithFormat:@"%d-endPositionArray", i]];
            [plistDict setObject:[NSNumber numberWithInt:object.startActionType] forKey:[NSString stringWithFormat:@"%d-startActionType", i]];
            [plistDict setObject:[NSNumber numberWithInt:object.endActionType] forKey:[NSString stringWithFormat:@"%d-endActionType", i]];
            [plistDict setObject:[NSNumber numberWithInteger:object.boundMode] forKey:[NSString stringWithFormat:@"%d-boundMode", i]];
            [plistDict setObject:[NSNumber numberWithInt:object.objectBorderStyle] forKey:[NSString stringWithFormat:@"%d-objectBorderStyle", i]];
            [plistDict setObject:[NSNumber numberWithInt:object.objectShadowStyle] forKey:[NSString stringWithFormat:@"%d-objectShadowStyle", i]];
            [plistDict setObject:[NSNumber numberWithBool:object.isReflection] forKey:[NSString stringWithFormat:@"%d-isReflection", i]];
            [plistDict setObject:[NSNumber numberWithBool:object.isPlaying] forKey:[NSString stringWithFormat:@"%d-isPlaying", i]];
            [plistDict setObject:[NSNumber numberWithBool:object.isKbEnabled] forKey:[NSString stringWithFormat:@"%d-isKbEnabled", i]];
            [plistDict setObject:[NSNumber numberWithInteger:object.nKbIn] forKey:[NSString stringWithFormat:@"%d-nKbIn", i]];
            [plistDict setObject:NSStringFromCGPoint(object.kbFocusPoint) forKey:[NSString stringWithFormat:@"%d-kbFocusPoint", i]];
            [plistDict setObject:[NSNumber numberWithFloat:object.fKbScale] forKey:[NSString stringWithFormat:@"%d-fKbScale", i]];
            
            CGFloat currentScaleX = sqrtf(powf(object.transform.a, 2) + powf(object.transform.c, 2));
            
            if (currentScaleX == 0.0)
                currentScaleX = 1;
            
            [plistDict setObject:[NSNumber numberWithFloat:4/currentScaleX] forKey:[NSString stringWithFormat:@"%d-selectedLineLayerLineWidth", i]];
            
            CGAffineTransform transform = CGAffineTransformMakeScale(1 / currentScaleX, 1 / currentScaleX);
            
            [plistDict setObject:NSStringFromCGAffineTransform(transform) forKey:[NSString stringWithFormat:@"%d-maskArrowTransform", i]];
            [plistDict setObject:NSStringFromCGAffineTransform(object.inputTransform) forKey:[NSString stringWithFormat:@"%d-inputTransform", i]];
            [plistDict setObject:NSStringFromCGAffineTransform(object.nationalVideoTransform) forKey:[NSString stringWithFormat:@"%d-nationalVideoTransform", i]];
            [plistDict setObject:NSStringFromCGAffineTransform(object.nationalVideoTransformOutputValue) forKey:[NSString stringWithFormat:@"%d-nationalVideoTransformOutputValue", i]];
            [plistDict setObject:NSStringFromCGAffineTransform(object.nationalReflectionVideoTransformOutputValue) forKey:[NSString stringWithFormat:@"%d-nationalReflectionVideoTransformOutputValue", i]];
            [plistDict setObject:NSStringFromCGAffineTransform(object.transform) forKey:[NSString stringWithFormat:@"%d-transform", i]];
            [plistDict setObject:NSStringFromCGAffineTransform(object.videoTransform) forKey:[NSString stringWithFormat:@"%d-videoTransform", i]];
            [plistDict setObject:NSStringFromCGPoint(CGPointMake(object.maskArrowLeft.frame.size.width/2, object.bounds.size.height/2)) forKey:[NSString stringWithFormat:@"%d-maskArrowLeftCenter", i]];
            [plistDict setObject:NSStringFromCGPoint(CGPointMake(object.bounds.size.width - object.maskArrowRight.frame.size.width/2, object.bounds.size.height/2)) forKey:[NSString stringWithFormat:@"%d-maskArrowRightCenter", i]];
            [plistDict setObject:NSStringFromCGPoint(CGPointMake(object.bounds.size.width/2, object.maskArrowTop.frame.size.height/2)) forKey:[NSString stringWithFormat:@"%d-maskArrowTopCenter", i]];
            [plistDict setObject:NSStringFromCGPoint(CGPointMake(object.bounds.size.width/2, object.bounds.size.height - object.maskArrowBottom.frame.size.height/2)) forKey:[NSString stringWithFormat:@"%d-maskArrowBottomCenter", i]];
            
            const CGFloat* colors = CGColorGetComponents(object.objectBorderColor.CGColor);
            CGFloat red = colors[0];
            CGFloat green = colors[1];
            CGFloat blue = colors[2];
            CGFloat alpha = CGColorGetAlpha(object.objectBorderColor.CGColor);
            
            [plistDict setObject:[NSNumber numberWithFloat:red] forKey:[NSString stringWithFormat:@"%d-objectBorderColor-Red", i]];
            [plistDict setObject:[NSNumber numberWithFloat:green] forKey:[NSString stringWithFormat:@"%d-objectBorderColor-Green", i]];
            [plistDict setObject:[NSNumber numberWithFloat:blue] forKey:[NSString stringWithFormat:@"%d-objectBorderColor-Blue", i]];
            [plistDict setObject:[NSNumber numberWithFloat:alpha] forKey:[NSString stringWithFormat:@"%d-objectBorderColor-Alpha", i]];
            
            colors = CGColorGetComponents(object.objectShadowColor.CGColor);
            red = colors[0];
            green = colors[1];
            blue = colors[2];
            alpha = CGColorGetAlpha(object.objectShadowColor.CGColor);
            
            [plistDict setObject:[NSNumber numberWithFloat:red] forKey:[NSString stringWithFormat:@"%d-objectShadowColor-Red", i]];
            [plistDict setObject:[NSNumber numberWithFloat:green] forKey:[NSString stringWithFormat:@"%d-objectShadowColor-Green", i]];
            [plistDict setObject:[NSNumber numberWithFloat:blue] forKey:[NSString stringWithFormat:@"%d-objectShadowColor-Blue", i]];
            [plistDict setObject:[NSNumber numberWithFloat:alpha] forKey:[NSString stringWithFormat:@"%d-objectShadowColor-Alpha", i]];
            
            colors = CGColorGetComponents(object.objectChromaColor.CGColor);
            red = colors[0];
            green = colors[1];
            blue = colors[2];
            
            [plistDict setObject:[NSNumber numberWithFloat:red] forKey:[NSString stringWithFormat:@"%d-objectChromaColor-Red", i]];
            [plistDict setObject:[NSNumber numberWithFloat:green] forKey:[NSString stringWithFormat:@"%d-objectChromaColor-Green", i]];
            [plistDict setObject:[NSNumber numberWithFloat:blue] forKey:[NSString stringWithFormat:@"%d-objectChromaColor-Blue", i]];
        }
        else if (object.mediaType == MEDIA_MUSIC)
        {
            [plistDict setObject:[NSNumber numberWithFloat:object.mediaDuration] forKey:[NSString stringWithFormat:@"%d-mediaDuration", i]];
            [plistDict setObject:[NSNumber numberWithFloat:object.mediaVolume] forKey:[NSString stringWithFormat:@"%d-mediaVolume", i]];
            [plistDict setObject:[NSNumber numberWithFloat:object.mfStartPosition] forKey:[NSString stringWithFormat:@"%d-mfStartPosition", i]];
            [plistDict setObject:[NSNumber numberWithFloat:object.mfEndPosition] forKey:[NSString stringWithFormat:@"%d-mfEndPosition", i]];
            [plistDict setObject:[NSNumber numberWithFloat:object.mfStartAnimationDuration] forKey:[NSString stringWithFormat:@"%d-mfStartAnimationDuration", i]];
            [plistDict setObject:[NSNumber numberWithFloat:object.mfEndAnimationDuration] forKey:[NSString stringWithFormat:@"%d-mfEndAnimationDuration", i]];
            [plistDict setObject:object.motionArray forKey:[NSString stringWithFormat:@"%d-motionArray", i]];
            [plistDict setObject:object.startPositionArray forKey:[NSString stringWithFormat:@"%d-startPositionArray", i]];
            [plistDict setObject:object.endPositionArray forKey:[NSString stringWithFormat:@"%d-endPositionArray", i]];
            [plistDict setObject:[NSNumber numberWithInt:object.startActionType] forKey:[NSString stringWithFormat:@"%d-startActionType", i]];
            [plistDict setObject:[NSNumber numberWithInt:object.endActionType] forKey:[NSString stringWithFormat:@"%d-endActionType", i]];
            [plistDict setObject:[NSNumber numberWithBool:object.isPlaying] forKey:[NSString stringWithFormat:@"%d-isPlaying", i]];
        }
    }
    
    //Write dictionary to plist file
    [plistDict writeToFile:plistFileName atomically:YES];
}


#pragma mark -
#pragma mark - Save Video from a modified filter result

-(void) saveObjectWithModifiedVideoInfo:(MediaObjectView*) object
{
    NSInteger index = object.objectIndex;
    NSFileManager *localFileManager = [NSFileManager defaultManager];
    
    NSString *folderDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *folderPath = [folderDir stringByAppendingPathComponent:self.projectName];
    NSString* plistFileName = [folderPath stringByAppendingPathComponent:@"project.plist"];

    if ([localFileManager fileExistsAtPath:plistFileName])// already saved
    {
        NSMutableDictionary *plistDict = [[NSMutableDictionary alloc] initWithContentsOfFile:plistFileName];
        [plistDict setObject:[object.mediaUrl lastPathComponent] forKey:[NSString stringWithFormat:@"%d-videoName", (int)index]];
        [plistDict setObject:[NSNumber numberWithFloat:object.mediaDuration] forKey:[NSString stringWithFormat:@"%d-mediaDuration", (int)index]];
        [plistDict setObject:[NSNumber numberWithFloat:object.mfStartPosition] forKey:[NSString stringWithFormat:@"%d-mfStartPosition", (int)index]];
        [plistDict setObject:[NSNumber numberWithFloat:object.mfEndPosition] forKey:[NSString stringWithFormat:@"%d-mfEndPosition", (int)index]];
        [plistDict setObject:object.motionArray forKey:[NSString stringWithFormat:@"%d-motionArray", (int)index]];
        [plistDict setObject:object.startPositionArray forKey:[NSString stringWithFormat:@"%d-startPositionArray", (int)index]];
        [plistDict setObject:object.endPositionArray forKey:[NSString stringWithFormat:@"%d-endPositionArray", (int)index]];
        [plistDict setObject:[NSNumber numberWithFloat:grNormalFilterOutputTotalTime] forKey:@"gfNormalFilterOutputTotalTime"];
        [plistDict writeToFile:plistFileName atomically:YES];
    }
}


#pragma mark -
#pragma mark - Copy Project

-(void) copyProject:(UIImage*) screenShotImg objects:(NSMutableArray*) objectArray
{
    NSFileManager *localFileManager = [NSFileManager defaultManager];

    // create "To" folder
    NSString* toProjectName = [NSString stringWithFormat:@"Copy of %@", self.projectName];
    NSString *toFolderDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *toFolderPath = [toFolderDir stringByAppendingPathComponent:toProjectName];
    
    if (![localFileManager createDirectoryAtPath:toFolderPath withIntermediateDirectories:NO attributes:nil error:nil])
    {
        int i = 1;
        BOOL isCreated = NO;

        while (!isCreated)
        {
            i++;
            toProjectName = [NSString stringWithFormat:@"Copy%d of %@", i, self.projectName];
            toFolderDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
            toFolderPath = [toFolderDir stringByAppendingPathComponent:toProjectName];

            isCreated = [localFileManager createDirectoryAtPath:toFolderPath withIntermediateDirectories:NO attributes:nil error:nil];
        }
    }
    
    NSString *fromFolderDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *fromFolderPath = [fromFolderDir stringByAppendingPathComponent:self.projectName];
    
    NSArray* files = [localFileManager contentsOfDirectoryAtPath:fromFolderPath error:nil];
    
    NSError* error = nil;
    
    for (NSString* file in files)
    {
        [localFileManager copyItemAtPath:[fromFolderPath stringByAppendingPathComponent:file] toPath:[toFolderPath stringByAppendingPathComponent:file] error:&error];
        
        if (error)
        {
            NSLog(@"%@", [error localizedDescription]);
        }
    }
    
    
    /************ Save Project Screenshot ****************/
    NSString* screenshotFileName = [toFolderPath stringByAppendingPathComponent:@"screenshot.png"];
    
    if ([localFileManager fileExistsAtPath:screenshotFileName])
        [localFileManager removeItemAtPath:screenshotFileName error:&error ];
    
    [UIImagePNGRepresentation(screenShotImg)  writeToFile:screenshotFileName atomically:YES];
    
    
    /*********** Create plist or get path of plist ***********/
    NSString* plistFileName = [toFolderPath stringByAppendingPathComponent:@"project.plist"];
    
    if ([localFileManager fileExistsAtPath:plistFileName])
        [localFileManager removeItemAtPath:plistFileName error:&error ];
    
    [localFileManager createFileAtPath:plistFileName contents:nil attributes:nil];
    
    
    /********************** Save Data ************************/
    
    NSMutableDictionary *plistDict = [NSMutableDictionary dictionary];
    
    [plistDict setObject:[NSNumber numberWithInt:gnOrientation] forKey:@"gnOrientation"];
    [plistDict setObject:[NSNumber numberWithInt:gnInstagramOrientation] forKey:@"gnInstagramOrientation"];
    [plistDict setObject:[NSNumber numberWithInt:gnTemplateIndex] forKey:@"gnTemplateIndex"];
    [plistDict setObject:[NSNumber numberWithInt:(int)objectArray.count] forKey:@"ObjectArrayCount"];
    [plistDict setObject:[NSNumber numberWithFloat:grNormalFilterOutputTotalTime] forKey:@"gfNormalFilterOutputTotalTime"];

    for (int i=0; i<objectArray.count; i++)
    {
        MediaObjectView* object = [objectArray objectAtIndex:i];
        
        [plistDict setObject:[NSNumber numberWithInt:object.mediaType] forKey:[NSString stringWithFormat:@"%d-mediaType", i]];
        
        [plistDict setObject:[NSNumber numberWithBool:object.isGrouped] forKey:[NSString stringWithFormat:@"%d-isGrouped", i]];

        if (object.mediaType == MEDIA_PHOTO)
        {
            [plistDict setObject:object.imageName forKey:[NSString stringWithFormat:@"%d-imageName", i]];
            [plistDict setObject:[NSNumber numberWithFloat:object.imageView.alpha] forKey:[NSString stringWithFormat:@"%d-objectOpacity", i]];
            
            //filter save
            NSString* filteredImageFileName = [toFolderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"obj_filter_%d.png", i]];
            
            [UIImagePNGRepresentation(object.imageView.image) writeToFile:filteredImageFileName atomically:YES];
            
            [plistDict setObject:[NSString stringWithFormat:@"obj_filter_%d.png", i] forKey:[NSString stringWithFormat:@"%d-filterImageName", i]];
            [plistDict setObject:[NSNumber numberWithInteger:object.photoFilterIndex] forKey:[NSString stringWithFormat:@"%d-photoFilterIndex", i]];
            [plistDict setObject:[NSNumber numberWithFloat:object.photoFilterValue] forKey:[NSString stringWithFormat:@"%d-photoFilterValue", i]];

            //shape save
            if (object.isShape)
            {
                [plistDict setObject:[NSNumber numberWithBool:object.isShape] forKey:[NSString stringWithFormat:@"%d-isShape", i]];
                [plistDict setObject:[NSNumber numberWithInt:object.shapeOverlayStyle] forKey:[NSString stringWithFormat:@"%d-shapeOverlayStyle", i]];
                
                const CGFloat* colors = CGColorGetComponents(object.shapeOverlayColor.CGColor);
                CGFloat red = colors[0];
                CGFloat green = colors[1];
                CGFloat blue = colors[2];
                CGFloat alpha = CGColorGetAlpha(object.shapeOverlayColor.CGColor);
                
                [plistDict setObject:[NSNumber numberWithFloat:red] forKey:[NSString stringWithFormat:@"%d-shapeOverlayColor-Red", i]];
                [plistDict setObject:[NSNumber numberWithFloat:green] forKey:[NSString stringWithFormat:@"%d-shapeOverlayColor-Green", i]];
                [plistDict setObject:[NSNumber numberWithFloat:blue] forKey:[NSString stringWithFormat:@"%d-shapeOverlayColor-Blue", i]];
                [plistDict setObject:[NSNumber numberWithFloat:alpha] forKey:[NSString stringWithFormat:@"%d-shapeOverlayColor-Alpha", i]];
            }
        }
        else if (object.mediaType == MEDIA_GIF)
        {
            [plistDict setObject:object.imageName forKey:[NSString stringWithFormat:@"%d-gifName", i]];
            [plistDict setObject:[NSNumber numberWithFloat:object.imageView.alpha] forKey:[NSString stringWithFormat:@"%d-objectOpacity", i]];
        }
        else if (object.mediaType == MEDIA_VIDEO)
        {
            NSString* videoName = [object.mediaUrl lastPathComponent];
            [plistDict setObject:videoName forKey:[NSString stringWithFormat:@"%d-videoName", i]];
            [plistDict setObject:[NSNumber numberWithFloat:object.imageView.alpha] forKey:[NSString stringWithFormat:@"%d-objectOpacity", i]];
        }
        else if (object.mediaType == MEDIA_MUSIC)
        {
            NSString* musicName = [object.mediaUrl lastPathComponent];
            [plistDict setObject:musicName forKey:[NSString stringWithFormat:@"%d-musicName", i]];
            [plistDict setObject:[NSNumber numberWithFloat:1.0f] forKey:[NSString stringWithFormat:@"%d-objectOpacity", i]];
        }
        else if (object.mediaType == MEDIA_TEXT)
        {
            const CGFloat* colors = CGColorGetComponents(object.textView.textColor.CGColor);
            CGFloat red = colors[0];
            CGFloat green = colors[1];
            CGFloat blue = colors[2];
            CGFloat alpha = CGColorGetAlpha(object.textView.textColor.CGColor);
            
            [plistDict setObject:[NSNumber numberWithFloat:red] forKey:[NSString stringWithFormat:@"%d-textViewTextColor-Red", i]];
            [plistDict setObject:[NSNumber numberWithFloat:green] forKey:[NSString stringWithFormat:@"%d-textViewTextColor-Green", i]];
            [plistDict setObject:[NSNumber numberWithFloat:blue] forKey:[NSString stringWithFormat:@"%d-textViewTextColor-Blue", i]];
            [plistDict setObject:[NSNumber numberWithFloat:alpha] forKey:[NSString stringWithFormat:@"%d-textViewTextColor-Alpha", i]];
            [plistDict setObject:[object.textView.font fontName] forKey:[NSString stringWithFormat:@"%d-textViewFontName", i]];
            [plistDict setObject:NSStringFromCGRect(object.textView.frame) forKey:[NSString stringWithFormat:@"%d-textViewFrame", i]];
            [plistDict setObject:[NSNumber numberWithFloat:object.textObjectFontSize] forKey:[NSString stringWithFormat:@"%d-textObjectFontSize", i]];
            [plistDict setObject:[NSNumber numberWithInteger:object.textView.textAlignment] forKey:[NSString stringWithFormat:@"%d-textViewTextAlignment", i]];
            [plistDict setObject:[NSNumber numberWithBool:object.isBold] forKey:[NSString stringWithFormat:@"%d-isBold", i]];
            [plistDict setObject:[NSNumber numberWithBool:object.isItalic] forKey:[NSString stringWithFormat:@"%d-isItalic", i]];
            [plistDict setObject:[NSNumber numberWithBool:object.isUnderline] forKey:[NSString stringWithFormat:@"%d-isUnderline", i]];
            [plistDict setObject:[NSNumber numberWithBool:object.isStroke] forKey:[NSString stringWithFormat:@"%d-isStroke", i]];
            [plistDict setObject:object.textView.text forKey:[NSString stringWithFormat:@"%d-text", i]];
            [plistDict setObject:[NSNumber numberWithFloat:object.textView.alpha] forKey:[NSString stringWithFormat:@"%d-objectOpacity", i]];
        }
        
        if ((object.mediaType == MEDIA_PHOTO)||(object.mediaType == MEDIA_GIF)||(object.mediaType == MEDIA_VIDEO)||(object.mediaType == MEDIA_TEXT))
        {
            [plistDict setObject:NSStringFromCGSize(object.workspaceSize) forKey:[NSString stringWithFormat:@"%d-workspaceSize", i]];
            [plistDict setObject:NSStringFromCGSize(object.originalVideoSize) forKey:[NSString stringWithFormat:@"%d-originalVideoSize", i]];
            [plistDict setObject:NSStringFromCGSize(object.superViewSize) forKey:[NSString stringWithFormat:@"%d-superViewSize", i]];
            [plistDict setObject:NSStringFromCGRect(object.mediaView.frame) forKey:[NSString stringWithFormat:@"%d-mediaViewFrame", i]];
            [plistDict setObject:NSStringFromCGRect(object.imageView.frame) forKey:[NSString stringWithFormat:@"%d-imageViewFrame", i]];
            [plistDict setObject:NSStringFromCGRect(object.videoView.frame) forKey:[NSString stringWithFormat:@"%d-videoViewFrame", i]];
            [plistDict setObject:NSStringFromCGRect(object.frame) forKey:[NSString stringWithFormat:@"%d-frame", i]];
            [plistDict setObject:NSStringFromCGRect(object.bounds) forKey:[NSString stringWithFormat:@"%d-bounds", i]];
            [plistDict setObject:NSStringFromCGRect(object.originalBounds) forKey:[NSString stringWithFormat:@"%d-originalBounds", i]];
            [plistDict setObject:NSStringFromCGRect(object.normalFilterVideoCropRect) forKey:[NSString stringWithFormat:@"%d-normalFilterVideoCropRect", i]];
            [plistDict setObject:NSStringFromCGRect(object.borderLineLayer.frame) forKey:[NSString stringWithFormat:@"%d-borderLineLayerFrame", i]];
            [plistDict setObject:NSStringFromCGPoint(object.lastPoint) forKey:[NSString stringWithFormat:@"%d-lastPoint", i]];
            [plistDict setObject:NSStringFromCGPoint(object.firstTouchedPoint) forKey:[NSString stringWithFormat:@"%d-firstTouchedPoint", i]];
            [plistDict setObject:NSStringFromCGPoint(object.reflectionDelta) forKey:[NSString stringWithFormat:@"%d-reflectionDelta", i]];
            [plistDict setObject:NSStringFromCGPoint(object.originalVideoCenter) forKey:[NSString stringWithFormat:@"%d-originalVideoCenter", i]];
            [plistDict setObject:NSStringFromCGPoint(object.changedVideoCenter) forKey:[NSString stringWithFormat:@"%d-changedVideoCenter", i]];
            [plistDict setObject:[NSNumber numberWithFloat:object.mediaDuration] forKey:[NSString stringWithFormat:@"%d-mediaDuration", i]];
            [plistDict setObject:[NSNumber numberWithFloat:object.mediaVolume] forKey:[NSString stringWithFormat:@"%d-mediaVolume", i]];
            [plistDict setObject:[NSNumber numberWithFloat:object.mfStartPosition] forKey:[NSString stringWithFormat:@"%d-mfStartPosition", i]];
            [plistDict setObject:[NSNumber numberWithFloat:object.mfEndPosition] forKey:[NSString stringWithFormat:@"%d-mfEndPosition", i]];
            [plistDict setObject:[NSNumber numberWithFloat:object.mfStartAnimationDuration] forKey:[NSString stringWithFormat:@"%d-mfStartAnimationDuration", i]];
            [plistDict setObject:[NSNumber numberWithFloat:object.mfEndAnimationDuration] forKey:[NSString stringWithFormat:@"%d-mfEndAnimationDuration", i]];
            [plistDict setObject:[NSNumber numberWithFloat:object.lastScaleFactor] forKey:[NSString stringWithFormat:@"%d-lastScaleFactor", i]];
            [plistDict setObject:[NSNumber numberWithFloat:object.rotateAngle] forKey:[NSString stringWithFormat:@"%d-rotateAngle", i]];
            [plistDict setObject:[NSNumber numberWithFloat:object.scaleValue] forKey:[NSString stringWithFormat:@"%d-scaleValue", i]];
            [plistDict setObject:[NSNumber numberWithFloat:object.portraitSpecialScale] forKey:[NSString stringWithFormat:@"%d-portraitSpecialScale", i]];
            [plistDict setObject:[NSNumber numberWithFloat:object.firstX] forKey:[NSString stringWithFormat:@"%d-firstX", i]];
            [plistDict setObject:[NSNumber numberWithFloat:object.firstY] forKey:[NSString stringWithFormat:@"%d-firstY", i]];
            [plistDict setObject:[NSNumber numberWithFloat:object.mySX] forKey:[NSString stringWithFormat:@"%d-mySX", i]];
            [plistDict setObject:[NSNumber numberWithFloat:object.mySY] forKey:[NSString stringWithFormat:@"%d-mySY", i]];
            [plistDict setObject:[NSNumber numberWithFloat:object.objectBorderWidth] forKey:[NSString stringWithFormat:@"%d-objectBorderWidth", i]];
            [plistDict setObject:[NSNumber numberWithFloat:object.objectShadowBlur] forKey:[NSString stringWithFormat:@"%d-objectShadowBlur", i]];
            [plistDict setObject:[NSNumber numberWithFloat:object.objectShadowOffset] forKey:[NSString stringWithFormat:@"%d-objectShadowOffset", i]];
            [plistDict setObject:[NSNumber numberWithFloat:object.objectCornerRadius] forKey:[NSString stringWithFormat:@"%d-objectCornerRadius", i]];
            [plistDict setObject:[NSNumber numberWithFloat:object.reflectionScale] forKey:[NSString stringWithFormat:@"%d-reflectionScale", i]];
            [plistDict setObject:[NSNumber numberWithFloat:object.reflectionAlpha] forKey:[NSString stringWithFormat:@"%d-reflectionAlpha", i]];
            [plistDict setObject:[NSNumber numberWithFloat:object.reflectionGap] forKey:[NSString stringWithFormat:@"%d-reflectionGap", i]];
            [plistDict setObject:object.motionArray forKey:[NSString stringWithFormat:@"%d-motionArray", i]];
            [plistDict setObject:object.startPositionArray forKey:[NSString stringWithFormat:@"%d-startPositionArray", i]];
            [plistDict setObject:object.endPositionArray forKey:[NSString stringWithFormat:@"%d-endPositionArray", i]];
            [plistDict setObject:[NSNumber numberWithInt:object.startActionType] forKey:[NSString stringWithFormat:@"%d-startActionType", i]];
            [plistDict setObject:[NSNumber numberWithInt:object.endActionType] forKey:[NSString stringWithFormat:@"%d-endActionType", i]];
            [plistDict setObject:[NSNumber numberWithInteger:object.boundMode] forKey:[NSString stringWithFormat:@"%d-boundMode", i]];
            [plistDict setObject:[NSNumber numberWithInt:object.objectBorderStyle] forKey:[NSString stringWithFormat:@"%d-objectBorderStyle", i]];
            [plistDict setObject:[NSNumber numberWithInt:object.objectShadowStyle] forKey:[NSString stringWithFormat:@"%d-objectShadowStyle", i]];
            [plistDict setObject:[NSNumber numberWithBool:object.isReflection] forKey:[NSString stringWithFormat:@"%d-isReflection", i]];
            [plistDict setObject:[NSNumber numberWithBool:object.isPlaying] forKey:[NSString stringWithFormat:@"%d-isPlaying", i]];
            [plistDict setObject:[NSNumber numberWithBool:object.isKbEnabled] forKey:[NSString stringWithFormat:@"%d-isKbEnabled", i]];
            [plistDict setObject:[NSNumber numberWithInteger:object.nKbIn] forKey:[NSString stringWithFormat:@"%d-nKbIn", i]];
            [plistDict setObject:NSStringFromCGPoint(object.kbFocusPoint) forKey:[NSString stringWithFormat:@"%d-kbFocusPoint", i]];
            [plistDict setObject:[NSNumber numberWithFloat:object.fKbScale] forKey:[NSString stringWithFormat:@"%d-fKbScale", i]];

            CGFloat currentScaleX = sqrtf(powf(object.transform.a, 2) + powf(object.transform.c, 2));
            
            if (currentScaleX == 0.0)
                currentScaleX = 1;
            
            [plistDict setObject:[NSNumber numberWithFloat:4/currentScaleX] forKey:[NSString stringWithFormat:@"%d-selectedLineLayerLineWidth", i]];
            
            CGAffineTransform transform = CGAffineTransformMakeScale(1 / currentScaleX, 1 / currentScaleX);
            
            [plistDict setObject:NSStringFromCGAffineTransform(transform) forKey:[NSString stringWithFormat:@"%d-maskArrowTransform", i]];
            [plistDict setObject:NSStringFromCGAffineTransform(object.inputTransform) forKey:[NSString stringWithFormat:@"%d-inputTransform", i]];
            [plistDict setObject:NSStringFromCGAffineTransform(object.nationalVideoTransform) forKey:[NSString stringWithFormat:@"%d-nationalVideoTransform", i]];
            [plistDict setObject:NSStringFromCGAffineTransform(object.nationalVideoTransformOutputValue) forKey:[NSString stringWithFormat:@"%d-nationalVideoTransformOutputValue", i]];
            [plistDict setObject:NSStringFromCGAffineTransform(object.nationalReflectionVideoTransformOutputValue) forKey:[NSString stringWithFormat:@"%d-nationalReflectionVideoTransformOutputValue", i]];
            [plistDict setObject:NSStringFromCGAffineTransform(object.transform) forKey:[NSString stringWithFormat:@"%d-transform", i]];
            [plistDict setObject:NSStringFromCGAffineTransform(object.videoTransform) forKey:[NSString stringWithFormat:@"%d-videoTransform", i]];
            [plistDict setObject:NSStringFromCGPoint(CGPointMake(object.maskArrowLeft.frame.size.width/2, object.bounds.size.height/2)) forKey:[NSString stringWithFormat:@"%d-maskArrowLeftCenter", i]];
            [plistDict setObject:NSStringFromCGPoint(CGPointMake(object.bounds.size.width - object.maskArrowRight.frame.size.width/2, object.bounds.size.height/2)) forKey:[NSString stringWithFormat:@"%d-maskArrowRightCenter", i]];
            [plistDict setObject:NSStringFromCGPoint(CGPointMake(object.bounds.size.width/2, object.maskArrowTop.frame.size.height/2)) forKey:[NSString stringWithFormat:@"%d-maskArrowTopCenter", i]];
            [plistDict setObject:NSStringFromCGPoint(CGPointMake(object.bounds.size.width/2, object.bounds.size.height - object.maskArrowBottom.frame.size.height/2)) forKey:[NSString stringWithFormat:@"%d-maskArrowBottomCenter", i]];
            
            const CGFloat* colors = CGColorGetComponents(object.objectBorderColor.CGColor);
            CGFloat red = colors[0];
            CGFloat green = colors[1];
            CGFloat blue = colors[2];
            CGFloat alpha = CGColorGetAlpha(object.objectBorderColor.CGColor);
            
            [plistDict setObject:[NSNumber numberWithFloat:red] forKey:[NSString stringWithFormat:@"%d-objectBorderColor-Red", i]];
            [plistDict setObject:[NSNumber numberWithFloat:green] forKey:[NSString stringWithFormat:@"%d-objectBorderColor-Green", i]];
            [plistDict setObject:[NSNumber numberWithFloat:blue] forKey:[NSString stringWithFormat:@"%d-objectBorderColor-Blue", i]];
            [plistDict setObject:[NSNumber numberWithFloat:alpha] forKey:[NSString stringWithFormat:@"%d-objectBorderColor-Alpha", i]];
            
            colors = CGColorGetComponents(object.objectShadowColor.CGColor);
            red = colors[0];
            green = colors[1];
            blue = colors[2];
            alpha = CGColorGetAlpha(object.objectShadowColor.CGColor);
            
            [plistDict setObject:[NSNumber numberWithFloat:red] forKey:[NSString stringWithFormat:@"%d-objectShadowColor-Red", i]];
            [plistDict setObject:[NSNumber numberWithFloat:green] forKey:[NSString stringWithFormat:@"%d-objectShadowColor-Green", i]];
            [plistDict setObject:[NSNumber numberWithFloat:blue] forKey:[NSString stringWithFormat:@"%d-objectShadowColor-Blue", i]];
            [plistDict setObject:[NSNumber numberWithFloat:alpha] forKey:[NSString stringWithFormat:@"%d-objectShadowColor-Alpha", i]];
            
            colors = CGColorGetComponents(object.objectChromaColor.CGColor);
            red = colors[0];
            green = colors[1];
            blue = colors[2];
            
            [plistDict setObject:[NSNumber numberWithFloat:red] forKey:[NSString stringWithFormat:@"%d-objectChromaColor-Red", i]];
            [plistDict setObject:[NSNumber numberWithFloat:green] forKey:[NSString stringWithFormat:@"%d-objectChromaColor-Green", i]];
            [plistDict setObject:[NSNumber numberWithFloat:blue] forKey:[NSString stringWithFormat:@"%d-objectChromaColor-Blue", i]];
        }
        else if (object.mediaType == MEDIA_MUSIC)
        {
            [plistDict setObject:[NSNumber numberWithFloat:object.mediaDuration] forKey:[NSString stringWithFormat:@"%d-mediaDuration", i]];
            [plistDict setObject:[NSNumber numberWithFloat:object.mediaVolume] forKey:[NSString stringWithFormat:@"%d-mediaVolume", i]];
            [plistDict setObject:[NSNumber numberWithFloat:object.mfStartPosition] forKey:[NSString stringWithFormat:@"%d-mfStartPosition", i]];
            [plistDict setObject:[NSNumber numberWithFloat:object.mfEndPosition] forKey:[NSString stringWithFormat:@"%d-mfEndPosition", i]];
            [plistDict setObject:[NSNumber numberWithFloat:object.mfStartAnimationDuration] forKey:[NSString stringWithFormat:@"%d-mfStartAnimationDuration", i]];
            [plistDict setObject:[NSNumber numberWithFloat:object.mfEndAnimationDuration] forKey:[NSString stringWithFormat:@"%d-mfEndAnimationDuration", i]];
            [plistDict setObject:object.motionArray forKey:[NSString stringWithFormat:@"%d-motionArray", i]];
            [plistDict setObject:object.startPositionArray forKey:[NSString stringWithFormat:@"%d-startPositionArray", i]];
            [plistDict setObject:object.endPositionArray forKey:[NSString stringWithFormat:@"%d-endPositionArray", i]];
            [plistDict setObject:[NSNumber numberWithInt:object.startActionType] forKey:[NSString stringWithFormat:@"%d-startActionType", i]];
            [plistDict setObject:[NSNumber numberWithInt:object.endActionType] forKey:[NSString stringWithFormat:@"%d-endActionType", i]];
            [plistDict setObject:[NSNumber numberWithBool:object.isPlaying] forKey:[NSString stringWithFormat:@"%d-isPlaying", i]];
        }
    }
    
    //Write dictionary to plist file
    [plistDict writeToFile:plistFileName atomically:YES];
}


#pragma mark -
#pragma mark - Save as Project

-(void) saveAsProject:(UIImage*) screenShotImg objects:(NSMutableArray*) objectArray
{
    NSFileManager *localFileManager = [NSFileManager defaultManager];
    
    // create "To" folder
    NSString* toProjectName = [NSString stringWithFormat:@"Copy of %@", self.projectName];
    NSString *toFolderDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *toFolderPath = [toFolderDir stringByAppendingPathComponent:toProjectName];
    
    if (![localFileManager createDirectoryAtPath:toFolderPath withIntermediateDirectories:NO attributes:nil error:nil])
    {
        int i = 1;
        BOOL isCreated = NO;
        
        while (!isCreated)
        {
            i++;
            toProjectName = [NSString stringWithFormat:@"Copy%d of %@", i, self.projectName];
            toFolderDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
            toFolderPath = [toFolderDir stringByAppendingPathComponent:toProjectName];
            
            isCreated = [localFileManager createDirectoryAtPath:toFolderPath withIntermediateDirectories:NO attributes:nil error:nil];
        }
    }
    
    NSString *fromFolderDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *fromFolderPath = [fromFolderDir stringByAppendingPathComponent:self.projectName];
    
    NSArray* files = [localFileManager contentsOfDirectoryAtPath:fromFolderPath error:nil];
    
    NSError* error = nil;
    
    for (NSString* file in files)
    {
        [localFileManager copyItemAtPath:[fromFolderPath stringByAppendingPathComponent:file] toPath:[toFolderPath stringByAppendingPathComponent:file] error:&error];
        
        if (error)
        {
            NSLog(@"%@", [error localizedDescription]);
        }
    }
    
    
    /************ Save Project Screenshot ****************/
    NSString* screenshotFileName = [toFolderPath stringByAppendingPathComponent:@"screenshot.png"];
    
    if ([localFileManager fileExistsAtPath:screenshotFileName])
        [localFileManager removeItemAtPath:screenshotFileName error:&error ];
    
    [UIImagePNGRepresentation(screenShotImg)  writeToFile:screenshotFileName atomically:YES];
    
    
    screenshotFileName = [fromFolderPath stringByAppendingPathComponent:@"screenshot.png"];
    
    if ([localFileManager fileExistsAtPath:screenshotFileName])
        [localFileManager removeItemAtPath:screenshotFileName error:&error ];
    
    [UIImagePNGRepresentation(screenShotImg)  writeToFile:screenshotFileName atomically:YES];

    
    /*********** Create plist or get path of plist ***********/
    NSString* plistFileName = [toFolderPath stringByAppendingPathComponent:@"project.plist"];
    
    if ([localFileManager fileExistsAtPath:plistFileName])
        [localFileManager removeItemAtPath:plistFileName error:&error ];
    
    [localFileManager createFileAtPath:plistFileName contents:nil attributes:nil];

    
    /********************** Save Data ************************/
    
    NSMutableDictionary *plistDict = [NSMutableDictionary dictionary];
    
    [plistDict setObject:[NSNumber numberWithInt:gnOrientation] forKey:@"gnOrientation"];
    [plistDict setObject:[NSNumber numberWithInt:gnInstagramOrientation] forKey:@"gnInstagramOrientation"];
    [plistDict setObject:[NSNumber numberWithInt:gnTemplateIndex] forKey:@"gnTemplateIndex"];
    [plistDict setObject:[NSNumber numberWithInt:(int)objectArray.count] forKey:@"ObjectArrayCount"];
    [plistDict setObject:[NSNumber numberWithFloat:grNormalFilterOutputTotalTime] forKey:@"gfNormalFilterOutputTotalTime"];
    
    for (int i=0; i<objectArray.count; i++)
    {
        MediaObjectView* object = [objectArray objectAtIndex:i];
        
        [plistDict setObject:[NSNumber numberWithInt:object.mediaType] forKey:[NSString stringWithFormat:@"%d-mediaType", i]];
        
        [plistDict setObject:[NSNumber numberWithBool:object.isGrouped] forKey:[NSString stringWithFormat:@"%d-isGrouped", i]];

        if (object.mediaType == MEDIA_PHOTO)
        {
            [plistDict setObject:object.imageName forKey:[NSString stringWithFormat:@"%d-imageName", i]];
            [plistDict setObject:[NSNumber numberWithFloat:object.imageView.alpha] forKey:[NSString stringWithFormat:@"%d-objectOpacity", i]];
            
            //filter save
            NSString* filteredImageFileName = [toFolderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"obj_filter_%d.png", i]];
            
            [UIImagePNGRepresentation(object.imageView.image) writeToFile:filteredImageFileName atomically:YES];
            
            [plistDict setObject:[NSString stringWithFormat:@"obj_filter_%d.png", i] forKey:[NSString stringWithFormat:@"%d-filterImageName", i]];
            [plistDict setObject:[NSNumber numberWithInteger:object.photoFilterIndex] forKey:[NSString stringWithFormat:@"%d-photoFilterIndex", i]];
            [plistDict setObject:[NSNumber numberWithFloat:object.photoFilterValue] forKey:[NSString stringWithFormat:@"%d-photoFilterValue", i]];

            //shape save
            if (object.isShape)
            {
                [plistDict setObject:[NSNumber numberWithBool:object.isShape] forKey:[NSString stringWithFormat:@"%d-isShape", i]];
                [plistDict setObject:[NSNumber numberWithInt:object.shapeOverlayStyle] forKey:[NSString stringWithFormat:@"%d-shapeOverlayStyle", i]];
                
                const CGFloat* colors = CGColorGetComponents(object.shapeOverlayColor.CGColor);
                CGFloat red = colors[0];
                CGFloat green = colors[1];
                CGFloat blue = colors[2];
                CGFloat alpha = CGColorGetAlpha(object.shapeOverlayColor.CGColor);
                
                [plistDict setObject:[NSNumber numberWithFloat:red] forKey:[NSString stringWithFormat:@"%d-shapeOverlayColor-Red", i]];
                [plistDict setObject:[NSNumber numberWithFloat:green] forKey:[NSString stringWithFormat:@"%d-shapeOverlayColor-Green", i]];
                [plistDict setObject:[NSNumber numberWithFloat:blue] forKey:[NSString stringWithFormat:@"%d-shapeOverlayColor-Blue", i]];
                [plistDict setObject:[NSNumber numberWithFloat:alpha] forKey:[NSString stringWithFormat:@"%d-shapeOverlayColor-Alpha", i]];
            }
        }
        else if (object.mediaType == MEDIA_GIF)
        {
            [plistDict setObject:object.imageName forKey:[NSString stringWithFormat:@"%d-gifName", i]];
            [plistDict setObject:[NSNumber numberWithFloat:object.imageView.alpha] forKey:[NSString stringWithFormat:@"%d-objectOpacity", i]];
        }
        else if (object.mediaType == MEDIA_VIDEO)
        {
            NSString* videoName = [object.mediaUrl lastPathComponent];
            [plistDict setObject:videoName forKey:[NSString stringWithFormat:@"%d-videoName", i]];
            [plistDict setObject:[NSNumber numberWithFloat:object.imageView.alpha] forKey:[NSString stringWithFormat:@"%d-objectOpacity", i]];
        }
        else if (object.mediaType == MEDIA_MUSIC)
        {
            NSString* musicName = [object.mediaUrl lastPathComponent];
            [plistDict setObject:musicName forKey:[NSString stringWithFormat:@"%d-musicName", i]];
            [plistDict setObject:[NSNumber numberWithFloat:1.0f] forKey:[NSString stringWithFormat:@"%d-objectOpacity", i]];
        }
        else if (object.mediaType == MEDIA_TEXT)
        {
            const CGFloat* colors = CGColorGetComponents(object.textView.textColor.CGColor);
            CGFloat red = colors[0];
            CGFloat green = colors[1];
            CGFloat blue = colors[2];
            CGFloat alpha = CGColorGetAlpha(object.textView.textColor.CGColor);
            
            [plistDict setObject:[NSNumber numberWithFloat:red] forKey:[NSString stringWithFormat:@"%d-textViewTextColor-Red", i]];
            [plistDict setObject:[NSNumber numberWithFloat:green] forKey:[NSString stringWithFormat:@"%d-textViewTextColor-Green", i]];
            [plistDict setObject:[NSNumber numberWithFloat:blue] forKey:[NSString stringWithFormat:@"%d-textViewTextColor-Blue", i]];
            [plistDict setObject:[NSNumber numberWithFloat:alpha] forKey:[NSString stringWithFormat:@"%d-textViewTextColor-Alpha", i]];
            [plistDict setObject:[object.textView.font fontName] forKey:[NSString stringWithFormat:@"%d-textViewFontName", i]];
            [plistDict setObject:NSStringFromCGRect(object.textView.frame) forKey:[NSString stringWithFormat:@"%d-textViewFrame", i]];
            [plistDict setObject:[NSNumber numberWithFloat:object.textObjectFontSize] forKey:[NSString stringWithFormat:@"%d-textObjectFontSize", i]];
            [plistDict setObject:[NSNumber numberWithInteger:object.textView.textAlignment] forKey:[NSString stringWithFormat:@"%d-textViewTextAlignment", i]];
            [plistDict setObject:[NSNumber numberWithBool:object.isBold] forKey:[NSString stringWithFormat:@"%d-isBold", i]];
            [plistDict setObject:[NSNumber numberWithBool:object.isItalic] forKey:[NSString stringWithFormat:@"%d-isItalic", i]];
            [plistDict setObject:[NSNumber numberWithBool:object.isUnderline] forKey:[NSString stringWithFormat:@"%d-isUnderline", i]];
            [plistDict setObject:[NSNumber numberWithBool:object.isStroke] forKey:[NSString stringWithFormat:@"%d-isStroke", i]];
            [plistDict setObject:object.textView.text forKey:[NSString stringWithFormat:@"%d-text", i]];
            [plistDict setObject:[NSNumber numberWithFloat:object.textView.alpha] forKey:[NSString stringWithFormat:@"%d-objectOpacity", i]];
        }
        
        if ((object.mediaType == MEDIA_PHOTO)||(object.mediaType == MEDIA_GIF)||(object.mediaType == MEDIA_VIDEO)||(object.mediaType == MEDIA_TEXT))
        {
            [plistDict setObject:NSStringFromCGSize(object.workspaceSize) forKey:[NSString stringWithFormat:@"%d-workspaceSize", i]];
            [plistDict setObject:NSStringFromCGSize(object.originalVideoSize) forKey:[NSString stringWithFormat:@"%d-originalVideoSize", i]];
            [plistDict setObject:NSStringFromCGSize(object.superViewSize) forKey:[NSString stringWithFormat:@"%d-superViewSize", i]];
            [plistDict setObject:NSStringFromCGRect(object.mediaView.frame) forKey:[NSString stringWithFormat:@"%d-mediaViewFrame", i]];
            [plistDict setObject:NSStringFromCGRect(object.imageView.frame) forKey:[NSString stringWithFormat:@"%d-imageViewFrame", i]];
            [plistDict setObject:NSStringFromCGRect(object.videoView.frame) forKey:[NSString stringWithFormat:@"%d-videoViewFrame", i]];
            [plistDict setObject:NSStringFromCGRect(object.frame) forKey:[NSString stringWithFormat:@"%d-frame", i]];
            [plistDict setObject:NSStringFromCGRect(object.bounds) forKey:[NSString stringWithFormat:@"%d-bounds", i]];
            [plistDict setObject:NSStringFromCGRect(object.originalBounds) forKey:[NSString stringWithFormat:@"%d-originalBounds", i]];
            [plistDict setObject:NSStringFromCGRect(object.normalFilterVideoCropRect) forKey:[NSString stringWithFormat:@"%d-normalFilterVideoCropRect", i]];
            [plistDict setObject:NSStringFromCGRect(object.borderLineLayer.frame) forKey:[NSString stringWithFormat:@"%d-borderLineLayerFrame", i]];
            [plistDict setObject:NSStringFromCGPoint(object.lastPoint) forKey:[NSString stringWithFormat:@"%d-lastPoint", i]];
            [plistDict setObject:NSStringFromCGPoint(object.firstTouchedPoint) forKey:[NSString stringWithFormat:@"%d-firstTouchedPoint", i]];
            [plistDict setObject:NSStringFromCGPoint(object.reflectionDelta) forKey:[NSString stringWithFormat:@"%d-reflectionDelta", i]];
            [plistDict setObject:NSStringFromCGPoint(object.originalVideoCenter) forKey:[NSString stringWithFormat:@"%d-originalVideoCenter", i]];
            [plistDict setObject:NSStringFromCGPoint(object.changedVideoCenter) forKey:[NSString stringWithFormat:@"%d-changedVideoCenter", i]];
            [plistDict setObject:[NSNumber numberWithFloat:object.mediaDuration] forKey:[NSString stringWithFormat:@"%d-mediaDuration", i]];
            [plistDict setObject:[NSNumber numberWithFloat:object.mediaVolume] forKey:[NSString stringWithFormat:@"%d-mediaVolume", i]];
            [plistDict setObject:[NSNumber numberWithFloat:object.mfStartPosition] forKey:[NSString stringWithFormat:@"%d-mfStartPosition", i]];
            [plistDict setObject:[NSNumber numberWithFloat:object.mfEndPosition] forKey:[NSString stringWithFormat:@"%d-mfEndPosition", i]];
            [plistDict setObject:[NSNumber numberWithFloat:object.mfStartAnimationDuration] forKey:[NSString stringWithFormat:@"%d-mfStartAnimationDuration", i]];
            [plistDict setObject:[NSNumber numberWithFloat:object.mfEndAnimationDuration] forKey:[NSString stringWithFormat:@"%d-mfEndAnimationDuration", i]];
            [plistDict setObject:[NSNumber numberWithFloat:object.lastScaleFactor] forKey:[NSString stringWithFormat:@"%d-lastScaleFactor", i]];
            [plistDict setObject:[NSNumber numberWithFloat:object.rotateAngle] forKey:[NSString stringWithFormat:@"%d-rotateAngle", i]];
            [plistDict setObject:[NSNumber numberWithFloat:object.scaleValue] forKey:[NSString stringWithFormat:@"%d-scaleValue", i]];
            [plistDict setObject:[NSNumber numberWithFloat:object.portraitSpecialScale] forKey:[NSString stringWithFormat:@"%d-portraitSpecialScale", i]];
            [plistDict setObject:[NSNumber numberWithFloat:object.firstX] forKey:[NSString stringWithFormat:@"%d-firstX", i]];
            [plistDict setObject:[NSNumber numberWithFloat:object.firstY] forKey:[NSString stringWithFormat:@"%d-firstY", i]];
            [plistDict setObject:[NSNumber numberWithFloat:object.mySX] forKey:[NSString stringWithFormat:@"%d-mySX", i]];
            [plistDict setObject:[NSNumber numberWithFloat:object.mySY] forKey:[NSString stringWithFormat:@"%d-mySY", i]];
            [plistDict setObject:[NSNumber numberWithFloat:object.objectBorderWidth] forKey:[NSString stringWithFormat:@"%d-objectBorderWidth", i]];
            [plistDict setObject:[NSNumber numberWithFloat:object.objectShadowBlur] forKey:[NSString stringWithFormat:@"%d-objectShadowBlur", i]];
            [plistDict setObject:[NSNumber numberWithFloat:object.objectShadowOffset] forKey:[NSString stringWithFormat:@"%d-objectShadowOffset", i]];
            [plistDict setObject:[NSNumber numberWithFloat:object.objectCornerRadius] forKey:[NSString stringWithFormat:@"%d-objectCornerRadius", i]];
            [plistDict setObject:[NSNumber numberWithFloat:object.reflectionScale] forKey:[NSString stringWithFormat:@"%d-reflectionScale", i]];
            [plistDict setObject:[NSNumber numberWithFloat:object.reflectionAlpha] forKey:[NSString stringWithFormat:@"%d-reflectionAlpha", i]];
            [plistDict setObject:[NSNumber numberWithFloat:object.reflectionGap] forKey:[NSString stringWithFormat:@"%d-reflectionGap", i]];
            [plistDict setObject:object.motionArray forKey:[NSString stringWithFormat:@"%d-motionArray", i]];
            [plistDict setObject:object.startPositionArray forKey:[NSString stringWithFormat:@"%d-startPositionArray", i]];
            [plistDict setObject:object.endPositionArray forKey:[NSString stringWithFormat:@"%d-endPositionArray", i]];
            [plistDict setObject:[NSNumber numberWithInt:object.startActionType] forKey:[NSString stringWithFormat:@"%d-startActionType", i]];
            [plistDict setObject:[NSNumber numberWithInt:object.endActionType] forKey:[NSString stringWithFormat:@"%d-endActionType", i]];
            [plistDict setObject:[NSNumber numberWithInteger:object.boundMode] forKey:[NSString stringWithFormat:@"%d-boundMode", i]];
            [plistDict setObject:[NSNumber numberWithInt:object.objectBorderStyle] forKey:[NSString stringWithFormat:@"%d-objectBorderStyle", i]];
            [plistDict setObject:[NSNumber numberWithInt:object.objectShadowStyle] forKey:[NSString stringWithFormat:@"%d-objectShadowStyle", i]];
            [plistDict setObject:[NSNumber numberWithBool:object.isReflection] forKey:[NSString stringWithFormat:@"%d-isReflection", i]];
            [plistDict setObject:[NSNumber numberWithBool:object.isPlaying] forKey:[NSString stringWithFormat:@"%d-isPlaying", i]];
            [plistDict setObject:[NSNumber numberWithBool:object.isKbEnabled] forKey:[NSString stringWithFormat:@"%d-isKbEnabled", i]];
            [plistDict setObject:[NSNumber numberWithInteger:object.nKbIn] forKey:[NSString stringWithFormat:@"%d-nKbIn", i]];
            [plistDict setObject:NSStringFromCGPoint(object.kbFocusPoint) forKey:[NSString stringWithFormat:@"%d-kbFocusPoint", i]];
            [plistDict setObject:[NSNumber numberWithFloat:object.fKbScale] forKey:[NSString stringWithFormat:@"%d-fKbScale", i]];

            CGFloat currentScaleX = sqrtf(powf(object.transform.a, 2) + powf(object.transform.c, 2));
            
            if (currentScaleX == 0.0)
                currentScaleX = 1;
            
            [plistDict setObject:[NSNumber numberWithFloat:4/currentScaleX] forKey:[NSString stringWithFormat:@"%d-selectedLineLayerLineWidth", i]];
            
            CGAffineTransform transform = CGAffineTransformMakeScale(1 / currentScaleX, 1 / currentScaleX);
            
            [plistDict setObject:NSStringFromCGAffineTransform(transform) forKey:[NSString stringWithFormat:@"%d-maskArrowTransform", i]];
            [plistDict setObject:NSStringFromCGAffineTransform(object.inputTransform) forKey:[NSString stringWithFormat:@"%d-inputTransform", i]];
            [plistDict setObject:NSStringFromCGAffineTransform(object.nationalVideoTransform) forKey:[NSString stringWithFormat:@"%d-nationalVideoTransform", i]];
            [plistDict setObject:NSStringFromCGAffineTransform(object.nationalVideoTransformOutputValue) forKey:[NSString stringWithFormat:@"%d-nationalVideoTransformOutputValue", i]];
            [plistDict setObject:NSStringFromCGAffineTransform(object.nationalReflectionVideoTransformOutputValue) forKey:[NSString stringWithFormat:@"%d-nationalReflectionVideoTransformOutputValue", i]];
            [plistDict setObject:NSStringFromCGAffineTransform(object.transform) forKey:[NSString stringWithFormat:@"%d-transform", i]];
            [plistDict setObject:NSStringFromCGAffineTransform(object.videoTransform) forKey:[NSString stringWithFormat:@"%d-videoTransform", i]];
            [plistDict setObject:NSStringFromCGPoint(CGPointMake(object.maskArrowLeft.frame.size.width/2, object.bounds.size.height/2)) forKey:[NSString stringWithFormat:@"%d-maskArrowLeftCenter", i]];
            [plistDict setObject:NSStringFromCGPoint(CGPointMake(object.bounds.size.width - object.maskArrowRight.frame.size.width/2, object.bounds.size.height/2)) forKey:[NSString stringWithFormat:@"%d-maskArrowRightCenter", i]];
            [plistDict setObject:NSStringFromCGPoint(CGPointMake(object.bounds.size.width/2, object.maskArrowTop.frame.size.height/2)) forKey:[NSString stringWithFormat:@"%d-maskArrowTopCenter", i]];
            [plistDict setObject:NSStringFromCGPoint(CGPointMake(object.bounds.size.width/2, object.bounds.size.height - object.maskArrowBottom.frame.size.height/2)) forKey:[NSString stringWithFormat:@"%d-maskArrowBottomCenter", i]];
            
            const CGFloat* colors = CGColorGetComponents(object.objectBorderColor.CGColor);
            CGFloat red = colors[0];
            CGFloat green = colors[1];
            CGFloat blue = colors[2];
            CGFloat alpha = CGColorGetAlpha(object.objectBorderColor.CGColor);
            
            [plistDict setObject:[NSNumber numberWithFloat:red] forKey:[NSString stringWithFormat:@"%d-objectBorderColor-Red", i]];
            [plistDict setObject:[NSNumber numberWithFloat:green] forKey:[NSString stringWithFormat:@"%d-objectBorderColor-Green", i]];
            [plistDict setObject:[NSNumber numberWithFloat:blue] forKey:[NSString stringWithFormat:@"%d-objectBorderColor-Blue", i]];
            [plistDict setObject:[NSNumber numberWithFloat:alpha] forKey:[NSString stringWithFormat:@"%d-objectBorderColor-Alpha", i]];
            
            colors = CGColorGetComponents(object.objectShadowColor.CGColor);
            red = colors[0];
            green = colors[1];
            blue = colors[2];
            alpha = CGColorGetAlpha(object.objectShadowColor.CGColor);
            
            [plistDict setObject:[NSNumber numberWithFloat:red] forKey:[NSString stringWithFormat:@"%d-objectShadowColor-Red", i]];
            [plistDict setObject:[NSNumber numberWithFloat:green] forKey:[NSString stringWithFormat:@"%d-objectShadowColor-Green", i]];
            [plistDict setObject:[NSNumber numberWithFloat:blue] forKey:[NSString stringWithFormat:@"%d-objectShadowColor-Blue", i]];
            [plistDict setObject:[NSNumber numberWithFloat:alpha] forKey:[NSString stringWithFormat:@"%d-objectShadowColor-Alpha", i]];
            
            colors = CGColorGetComponents(object.objectChromaColor.CGColor);
            red = colors[0];
            green = colors[1];
            blue = colors[2];
            
            [plistDict setObject:[NSNumber numberWithFloat:red] forKey:[NSString stringWithFormat:@"%d-objectChromaColor-Red", i]];
            [plistDict setObject:[NSNumber numberWithFloat:green] forKey:[NSString stringWithFormat:@"%d-objectChromaColor-Green", i]];
            [plistDict setObject:[NSNumber numberWithFloat:blue] forKey:[NSString stringWithFormat:@"%d-objectChromaColor-Blue", i]];
        }
        else if (object.mediaType == MEDIA_MUSIC)
        {
            [plistDict setObject:[NSNumber numberWithFloat:object.mediaDuration] forKey:[NSString stringWithFormat:@"%d-mediaDuration", i]];
            [plistDict setObject:[NSNumber numberWithFloat:object.mediaVolume] forKey:[NSString stringWithFormat:@"%d-mediaVolume", i]];
            [plistDict setObject:[NSNumber numberWithFloat:object.mfStartPosition] forKey:[NSString stringWithFormat:@"%d-mfStartPosition", i]];
            [plistDict setObject:[NSNumber numberWithFloat:object.mfEndPosition] forKey:[NSString stringWithFormat:@"%d-mfEndPosition", i]];
            [plistDict setObject:[NSNumber numberWithFloat:object.mfStartAnimationDuration] forKey:[NSString stringWithFormat:@"%d-mfStartAnimationDuration", i]];
            [plistDict setObject:[NSNumber numberWithFloat:object.mfEndAnimationDuration] forKey:[NSString stringWithFormat:@"%d-mfEndAnimationDuration", i]];
            [plistDict setObject:object.motionArray forKey:[NSString stringWithFormat:@"%d-motionArray", i]];
            [plistDict setObject:object.startPositionArray forKey:[NSString stringWithFormat:@"%d-startPositionArray", i]];
            [plistDict setObject:object.endPositionArray forKey:[NSString stringWithFormat:@"%d-endPositionArray", i]];
            [plistDict setObject:[NSNumber numberWithInt:object.startActionType] forKey:[NSString stringWithFormat:@"%d-startActionType", i]];
            [plistDict setObject:[NSNumber numberWithInt:object.endActionType] forKey:[NSString stringWithFormat:@"%d-endActionType", i]];
            [plistDict setObject:[NSNumber numberWithBool:object.isPlaying] forKey:[NSString stringWithFormat:@"%d-isPlaying", i]];
        }
    }
    
    //Write dictionary to plist file
    [plistDict writeToFile:plistFileName atomically:YES];
    
    plistFileName = [fromFolderPath stringByAppendingPathComponent:@"project.plist"];
    
    if ([localFileManager fileExistsAtPath:plistFileName])
        [localFileManager removeItemAtPath:plistFileName error:&error ];
    
    [localFileManager createFileAtPath:plistFileName contents:nil attributes:nil];
    [plistDict writeToFile:plistFileName atomically:YES];
    
    self.projectName = [[NSString alloc] initWithString:toProjectName];
}


#pragma mark -
#pragma mark - rename project

-(BOOL) renameProjectFolder:(NSString*) newName
{
    NSString *toFolderDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *toFolderPath = [toFolderDir stringByAppendingPathComponent:newName];
    
    NSString *fromFolderDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *fromFolderPath = [fromFolderDir stringByAppendingPathComponent:self.projectName];

    if (rename([fromFolderPath fileSystemRepresentation], [toFolderPath fileSystemRepresentation]) == -1)
    {
        NSLog(@"%s",strerror(errno));
        
        NSString* errorMessage = [NSString stringWithFormat:@"A project \"%@\" is exist already! Please set another new name.", newName];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:errorMessage  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil, nil];
        [alert show];
        
        return NO;
    }
    else
    {
        gstrCurrentProjectName = [newName copy];
        self.projectName = [newName copy];
        
        return YES;
    }

    return YES;
}


@end
