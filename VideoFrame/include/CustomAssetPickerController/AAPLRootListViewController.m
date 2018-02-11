//
//  AAPLRootListViewController.m
//  VideoFrame
//
//  Created by Yinjing Li on 9/22/14.
//  Copyright (c) 2014 Yinjing Li. All rights reserved.
//

#import "AAPLRootListViewController.h"

#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

#import "CustomAssetPickerController.h"
#import "AAPLAssetGridViewController.h"

#import "Definition.h"


@import Photos;


@interface AAPLRootListViewController ()<PHPhotoLibraryChangeObserver>

@property (strong) NSMutableArray* collectionsArray;

@end


@implementation AAPLRootListViewController

@synthesize customAssetPickerController = _customAssetPickerController;

static NSString * const CollectionSegue = @"showCollection";


- (void)awakeFromNib
{
    [self addActivityIndicatorToNavigationBar];
    
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
    
    NSDictionary* barButtonItemAttributes =  @{NSFontAttributeName:[UIFont fontWithName:MYRIADPRO size:[UIFont systemFontSize]],
                                               NSForegroundColorAttributeName:[UIColor blackColor]};
    
    [self.cancelButtonItem setTitleTextAttributes:barButtonItemAttributes forState:UIControlStateNormal];
    [super awakeFromNib];
}

-(BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark -
#pragma mark -

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImageView* imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    [imageView setImage:[UIImage imageNamed:@"specialistEditBg"]];
    self.tableView.backgroundView = imageView;
 
    self.customAssetPickerController = (CustomAssetPickerController*)self.navigationController;
    
    filterType = self.customAssetPickerController.filterType;
    
    if (!self.collectionsArray)
    {
        self.collectionsArray = [[NSMutableArray alloc] init];
    }
    
    //smart albums
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    
    //top level albums
    PHFetchResult *topLevelUserCollections = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
    
    [self addCollections:smartAlbums];
    [self addCollections:topLevelUserCollections];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self removeActivityIndicatorFromNavigationBar];
}

#pragma mark - PHPhotoLibraryChangeObserver

- (void)photoLibraryDidChange:(PHChange *)changeInstance
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.collectionsArray removeAllObjects];
        self.collectionsArray = [[NSMutableArray alloc] init];
        
        //smart albums
        PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
        
        //top level albums
        PHFetchResult *topLevelUserCollections = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
        
        [self addCollections:smartAlbums];
        [self addCollections:topLevelUserCollections];
        
        [self.tableView reloadData];
    });
}

#pragma mark -

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:CollectionSegue])
    {
        AAPLAssetGridViewController *assetGridViewController = segue.destinationViewController;
        
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        
        PHFetchOptions *options = [[PHFetchOptions alloc] init];
        options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
        
        if (indexPath.row == self.collectionsArray.count)
        {
            if (filterType == PHAssetMediaTypeImage)    //Add Shapes at last of Photos Albums
            {
                assetGridViewController.assetsFetchResults = [PHAsset fetchAssetsWithMediaType:filterType options:options];
                assetGridViewController.title = @"Shapes";
                assetGridViewController.filterType = filterType;
                assetGridViewController.customAssetPickerController = self.customAssetPickerController;
            }
            else if (filterType == PHAssetMediaTypeVideo)    //Add iTunes Synced Movies at last of Videos Albums
            {
                assetGridViewController.assetsFetchResults = nil;
                assetGridViewController.title = @"Movies";
                assetGridViewController.filterType = filterType;
                assetGridViewController.customAssetPickerController = self.customAssetPickerController;
            }
        }
        else
        {
            PHCollection *collection = [self.collectionsArray objectAtIndex:indexPath.row];
            
            if ([collection isKindOfClass:[PHAssetCollection class]])
            {
                PHAssetCollection *assetCollection = (PHAssetCollection *)collection;
                
                assetGridViewController.assetsFetchResults = [PHAsset fetchAssetsInAssetCollection:assetCollection options:options];
                assetGridViewController.assetCollection = assetCollection;
                assetGridViewController.title = assetCollection.localizedTitle;
                assetGridViewController.filterType = filterType;
                assetGridViewController.customAssetPickerController = self.customAssetPickerController;
            }
        }
    }
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRows = self.collectionsArray.count + 1;   // add Shapes or Movies
    
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    NSString *localizedTitle = nil;
    NSInteger count = 0;
    
    if (indexPath.row == self.collectionsArray.count)
    {
        if (filterType == PHAssetMediaTypeImage)
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"CollectionCell" forIndexPath:indexPath];
            localizedTitle = @"Shapes";
            
            count = SHAPES_MAX_COUNT;
        }
        else if(filterType == PHAssetMediaTypeVideo)
        {
            NSNumber *mediaTypeNumber = [NSNumber numberWithInteger:MPMediaTypeAnyVideo];
            MPMediaPropertyPredicate *mediaTypePredicate = [MPMediaPropertyPredicate predicateWithValue:mediaTypeNumber
                                                                                            forProperty:MPMediaItemPropertyMediaType];
            NSSet *predicateSet = [NSSet setWithObjects:mediaTypePredicate, nil];
            MPMediaQuery* query = [[MPMediaQuery alloc] initWithFilterPredicates:predicateSet];
            NSArray* moviesArray = [query collections];
            
            for (int i=0; i<moviesArray.count; i++)
            {
                MPMediaItemCollection* item = [moviesArray objectAtIndex:i];
                MPMediaItem *representativeItem = [item representativeItem];
                NSURL *url = [representativeItem valueForProperty:MPMediaItemPropertyAssetURL];
                
                if (url)
                {
                    count++;
                }
            }

            cell = [tableView dequeueReusableCellWithIdentifier:@"CollectionCell" forIndexPath:indexPath];
            localizedTitle = @"Movies";
        }
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"CollectionCell" forIndexPath:indexPath];
        
        PHCollection *collection = [self.collectionsArray objectAtIndex:indexPath.row];
        localizedTitle = collection.localizedTitle;
        
        if ([collection isKindOfClass:[PHAssetCollection class]])
        {
            PHAssetCollection *assetCollection = (PHAssetCollection *)collection;
            PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:nil];
            count = [assetsFetchResult countOfAssetsWithMediaType:filterType];
        }
    }
    
    cell.textLabel.text = localizedTitle;
    cell.textLabel.font = [UIFont fontWithName:MYRIADPRO size:[UIFont systemFontSize]];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", (int)count];
    cell.detailTextLabel.textColor = [UIColor blackColor];
    cell.detailTextLabel.font = [UIFont fontWithName:MYRIADPRO size:[UIFont systemFontSize]];
    
    cell.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.75f];

    return cell;
}


#pragma mark - Actions

- (IBAction)handleCancelButtonItem:(id)sender
{
    if ([self.customAssetPickerController.customAssetDelegate respondsToSelector:@selector(customAssetsPickerControllerDidCancel:)])
    {
        [self.customAssetPickerController.customAssetDelegate customAssetsPickerControllerDidCancel:self.customAssetPickerController];
    }
}


#pragma mark - Add PHFetchResult

-(void) addCollections:(PHFetchResult*) result
{
    for (int i=0; i<result.count; i++)
    {
        PHCollection *collection = result[i];
        
        if ([collection isKindOfClass:[PHAssetCollection class]])
        {
            PHAssetCollection *assetCollection = (PHAssetCollection *)collection;
            PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:nil];
            
            if ([assetsFetchResult countOfAssetsWithMediaType:filterType] > 0)
            {
                [self.collectionsArray addObject:collection];
            }
        }
    }
}

- (void)addActivityIndicatorToNavigationBar
{
    if (!_indicatorView)
    {
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [_indicatorView setHidesWhenStopped:YES];
    }
    
    UIBarButtonItem *itemIndicator = [[UIBarButtonItem alloc] initWithCustomView:_indicatorView];
    [self.navigationItem setRightBarButtonItem:itemIndicator];
    [_indicatorView startAnimating];
}

- (void)removeActivityIndicatorFromNavigationBar
{
    [_indicatorView stopAnimating];
}



@end
