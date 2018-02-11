//
//  AAPLRootListViewController.h
//  VideoFrame
//
//  Created by Yinjing Li on 9/22/14.
//  Copyright (c) 2014 Yinjing Li. All rights reserved.
//


@import UIKit;
@import Photos;

@class CustomAssetPickerController;

@interface AAPLRootListViewController : UITableViewController
{
    PHAssetMediaType filterType;
    
    UIActivityIndicatorView *_indicatorView;
}

@property(nonatomic, weak) IBOutlet UIBarButtonItem* cancelButtonItem;

@property(nonatomic, weak) CustomAssetPickerController* customAssetPickerController;

@end
