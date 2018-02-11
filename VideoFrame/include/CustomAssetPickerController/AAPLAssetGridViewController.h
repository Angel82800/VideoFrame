//
//  AAPLAssetGridViewController.h
//  VideoFrame
//
//  Created by Yinjing Li on 9/22/14.
//  Copyright (c) 2014 Yinjing Li. All rights reserved.
//


@import UIKit;
@import Photos;

@class CustomAssetPickerController;
@class YJLVideoThumbMaker;
@class CustomModalView;
@class AAPLGridViewCell;
@class YJLVideoPlayer;


@interface AAPLAssetGridViewController : UICollectionViewController <UICollectionViewDelegateFlowLayout>
{
    NSMutableArray* assetsArray;
    NSMutableArray* selectedAssetsArray;
    NSMutableArray* assetsFlagArray;
    
    UIActivityIndicatorView *_indicatorView;
    
    PHImageRequestOptions* requestOptions;
    
    AAPLGridViewCell* selectedCell;
    
    NSFileManager *localFileManager;
    NSString *folderDir;
    NSString *plistFolderPath;
    NSString *thumbFolderPath;
    
    CGFloat myCell_Size;
}

@property(nonatomic, weak) CustomAssetPickerController* customAssetPickerController;

@property (nonatomic) PHAssetMediaType filterType;
@property (strong) PHFetchResult *assetsFetchResults;
@property (strong) PHAssetCollection *assetCollection;
@property (strong) NSCache* myCache;
@property (strong) NSString *urlShare;
@property (strong) NSURL *movieURL;


@property(nonatomic, strong) CustomModalView* customModalView;
@property(nonatomic, strong) YJLVideoThumbMaker* videoThumbMaker;
@property(nonatomic, strong) YJLVideoPlayer* videoPlayer;

@end
