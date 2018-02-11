//
//
//  ALAssetsLibrary+CustomPhotoAlbum.h
//  VideoFrame
//
//  Created by Yinjing Li on 11/29/13.
//  Copyright (c) 2013 Yinjing Li. All rights reserved.
//
//  Description
//  ALAssetsLibrary category to handle a custom photo album
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>


typedef void(^SaveImageCompletion)(NSError* error);


@interface ALAssetsLibrary(CustomPhotoAlbum)

-(void) saveImage:(UIImage*)image toAlbum:(NSString*)albumName withCompletionBlock:(SaveImageCompletion)completionBlock;
-(void) saveVideo:(NSURL*)videoUrl toAlbum:(NSString*)albumName withCompletionBlock:(SaveImageCompletion)completionBlock;
-(void) addAssetURL:(NSURL*)assetURL toAlbum:(NSString*)albumName withCompletionBlock:(SaveImageCompletion)completionBlock;

@end