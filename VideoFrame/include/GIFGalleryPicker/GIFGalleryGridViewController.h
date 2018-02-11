//
//  GIFGalleryGridViewController.h
//  VideoFrame
//
//  Created by Yinjing Li on 6/18/15.
//  Copyright (c) 2015 Yinjing Li. All rights reserved.
//

@import UIKit;
@import Photos;

@class GIFGalleryPickerController;

@interface GIFGalleryGridViewController : UICollectionViewController <UICollectionViewDelegateFlowLayout, UIAlertViewDelegate>
{
    NSFileManager* localFileManager;
    NSString* folderDir;
    NSString* folderPath;
    NSString* gifFolderPath;
    
    NSMutableArray* gifsArray;
    NSMutableArray* selectedCellIndexArray;
    NSMutableArray* gifsFlagArray;
    
    NSOperationQueue *_thumbnailQueue;

    BOOL isDeleteActived;
}

@property(nonatomic, weak) GIFGalleryPickerController* gifGalleryPickerController;

@property (strong) NSCache* myCache;

@property (strong) UIBarButtonItem *oldestNewestButton;
@property (strong) UIBarButtonItem *saveClipboardButton;
@property (strong) UIBarButtonItem *cancelButton;
@property (strong) UIBarButtonItem *deleteButton;

@end
