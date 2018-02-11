//
//  AAPLAssetGridViewController.m
//  VideoFrame
//
//  Created by Yinjing Li on 9/22/14.
//  Copyright (c) 2014 Yinjing Li. All rights reserved.
//

#import "AAPLAssetGridViewController.h"

#import <AssetsLibrary/AssetsLibrary.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

#import "Definition.h"

#import "CustomAssetPickerController.h"
#import "AAPLGridViewCell.h"
#import "SHKActivityIndicator.h"
#import "YJLActionMenu.h"
#import "YJLVideoThumbMaker.h"
#import "CustomModalView.h"
#import "ALAssetsLibrary+CustomPhotoAlbum.h"
#import "YJLVideoPlayer.h"
#import "MyCloudDocument.h"
#import "TTOpenInAppActivity.h"

@import Photos;


@interface AAPLAssetGridViewController () <PHPhotoLibraryChangeObserver, AAPLGridViewCellDelegate, CustomModalViewDelegate, YJLVideoThumbMakerDelegate, YJLVideoPlayerDelegate, TTOpenInAppActivityDelegate>

@property (strong) IBOutlet UIBarButtonItem *selectButton;
@property (strong) UIBarButtonItem *oldestButton;
@property (strong) PHCachingImageManager *imageManager;
@property (nonatomic, strong) UIPopoverController *activityPopoverController;

@end


@implementation AAPLAssetGridViewController

@synthesize customAssetPickerController, customModalView, videoThumbMaker, videoPlayer, myCache;


static NSString * const CellReuseIdentifier = @"Cell";
static CGSize AssetGridThumbnailSize;

- (void)awakeFromNib
{
    self.oldestButton = [[UIBarButtonItem alloc] initWithTitle:@"Oldest" style:UIBarButtonItemStylePlain target:self action:@selector(handleOldestButtonItem:)];
    [self.oldestButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:MYRIADPRO size:[UIFont systemFontSize]], NSFontAttributeName, [UIColor blackColor], NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
    
    self.imageManager = [[PHCachingImageManager alloc] init];
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
    
    [self addActivityIndicatorToNavigationBar];
    
    [self.selectButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:MYRIADPRO size:[UIFont systemFontSize]], NSFontAttributeName, [UIColor blackColor], NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
    self.selectButton.enabled = NO;
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    localFileManager = [NSFileManager defaultManager];
    folderDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Library"];
    plistFolderPath = [folderDir stringByAppendingPathComponent:@"Preferences"];
    thumbFolderPath = [plistFolderPath stringByAppendingPathComponent:@"CustomThumbnails"];

    BOOL isDirectory = NO;
    BOOL exist = [localFileManager fileExistsAtPath:thumbFolderPath isDirectory:&isDirectory];
    
    if (!exist)
    {
        [localFileManager createDirectoryAtPath:thumbFolderPath withIntermediateDirectories:NO attributes:nil error:nil];
    }

    UIImageView* imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    [imageView setImage:[UIImage imageNamed:@"specialistEditBg"]];
    self.collectionView.backgroundView = imageView;
    
    requestOptions = [[PHImageRequestOptions alloc] init];
    requestOptions.synchronous = NO;
    requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    
    self.myCache = [[NSCache alloc] init];

    [self setupAssetsArray];
    
    if (self.filterType == PHAssetMediaTypeVideo)
    {
        [self.selectButton setTitle:@"iCloud Save"];
        self.selectButton.enabled = YES;
    }
    
    NSDictionary* barButtonItemAttributes =  @{NSFontAttributeName:[UIFont fontWithName:MYRIADPRO size:[UIFont systemFontSize]],
                                               NSForegroundColorAttributeName:[UIColor blackColor]};
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setTitleTextAttributes:barButtonItemAttributes forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    [self.myCache removeAllObjects];
}


-(BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    CGSize cellSize = CGSizeZero;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        myCell_Size = MIN([[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height) / 3.0f - 2.0f;
    else
        myCell_Size = MAX([[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height) / 7.0f - 5.0f;
    
    cellSize = CGSizeMake(myCell_Size, myCell_Size);
    
    ((UICollectionViewFlowLayout *)self.collectionViewLayout).itemSize = cellSize;

    AssetGridThumbnailSize = CGSizeMake(cellSize.width*2.0f, cellSize.height*2.0f);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(AssetGridThumbnailSize.width/2.0f, AssetGridThumbnailSize.height/2.0f);
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self removeActivityIndicatorFromNavigationBar];
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
    
    if (self.customAssetPickerController.isSingleOnly)
    {
        self.navigationItem.rightBarButtonItems = nil;
    }
    else
    {
        self.navigationItem.rightBarButtonItems = @[self.selectButton, self.oldestButton];
    }
}

- (void) setupAssetsArray
{
    [assetsArray removeAllObjects];
    assetsArray = nil;
    assetsArray = [[NSMutableArray alloc] init];
    
    [assetsFlagArray removeAllObjects];
    assetsFlagArray = nil;
    assetsFlagArray = [[NSMutableArray alloc] init];
    
    [selectedAssetsArray removeAllObjects];
    selectedAssetsArray = nil;
    selectedAssetsArray = [[NSMutableArray alloc] init];

    if (([self.title isEqualToString:@"Shapes"])&&(self.filterType == PHAssetMediaTypeImage))
    {
        for (int i=0; i<SHAPES_MAX_COUNT; i++)
        {
            [assetsArray addObject:[NSNumber numberWithInteger:i]];
            [assetsFlagArray addObject:[NSNumber numberWithBool:NO]];
        }
    }
    else if (([self.title isEqualToString:@"Movies"])&&(self.filterType == PHAssetMediaTypeVideo))
    {
        NSNumber *mediaTypeNumber = [NSNumber numberWithInteger:MPMediaTypeAnyVideo];
        MPMediaPropertyPredicate *mediaTypePredicate = [MPMediaPropertyPredicate predicateWithValue:mediaTypeNumber
                                                                                        forProperty:MPMediaItemPropertyMediaType];
        NSSet *predicateSet = [NSSet setWithObjects:mediaTypePredicate, nil];
        MPMediaQuery* query = [[MPMediaQuery alloc] initWithFilterPredicates:predicateSet];
        NSArray* collectionsArray = [query collections];
        
        for (int i=0; i<collectionsArray.count; i++)
        {
            MPMediaItemCollection* item = [collectionsArray objectAtIndex:i];
            MPMediaItem *representativeItem = [item representativeItem];
            NSURL *url = [representativeItem valueForProperty:MPMediaItemPropertyAssetURL];
            
            if (url)
            {
                [assetsArray addObject:[collectionsArray objectAtIndex:i]];
                [assetsFlagArray addObject:[NSNumber numberWithBool:NO]];
            }
        }
    }
    else
    {
        for (int i=0; i<self.assetsFetchResults.count; i++)
        {
            PHAsset* asset = [self.assetsFetchResults objectAtIndex:(self.assetsFetchResults.count - 1 - i)];
            
            if (asset.mediaType == self.filterType)
            {
                [assetsArray addObject:asset];
                [assetsFlagArray addObject:[NSNumber numberWithBool:NO]];
            }
        }
    }
}

#pragma mark - PHPhotoLibraryChangeObserver

- (void)photoLibraryDidChange:(PHChange *)changeInstance
{
    // Call might come on any background queue. Re-dispatch to the main queue to handle it.
    dispatch_async(dispatch_get_main_queue(), ^{
        
        // check if there are changes to the assets (insertions, deletions, updates)
        PHFetchResultChangeDetails *collectionChanges = [changeInstance changeDetailsForFetchResult:self.assetsFetchResults];
        
        if (collectionChanges)
        {
            // get the new fetch result
            self.assetsFetchResults = [collectionChanges fetchResultAfterChanges];
            
            [self setupAssetsArray];
            
            [self.collectionView reloadData];
        }
    });
}


#pragma mark -
#pragma mark - UICollectionViewDataSource

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 5.0f;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger count = [assetsArray count];

    if (([self.title isEqualToString:@"Shapes"])&&(self.filterType == PHAssetMediaTypeImage))
        count = SHAPES_MAX_COUNT;
    
    return count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    AAPLGridViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellReuseIdentifier forIndexPath:indexPath];
    
    // Increment the cell's tag
    NSInteger currentTag = cell.tag + 1;
    cell.tag = currentTag;
    
    
    if (([self.title isEqualToString:@"Shapes"])&&(self.filterType == PHAssetMediaTypeImage))   //Shape
    {
        NSNumber* number = [assetsArray objectAtIndex:indexPath.item];
        NSInteger index = [number integerValue];
        
        UIImage* assetImage = [UIImage imageNamed:[NSString stringWithFormat:@"shape%d_thumb", (int)index]];
        
        cell.thumbnailImage = assetImage;
        [cell setPixelLabelString:@""];
        [cell hideGrayBgView];
        [cell setSizeLabelString:@""];
        [cell setFileNameLabelString:@""];
        [cell changeContentForShape];
        [cell hideVideoThumbnailMenuBtn];
    }
    else if (([self.title isEqualToString:@"Movies"])&&(self.filterType == PHAssetMediaTypeVideo))  //Movies
    {
        cell.delegate = self;
        cell.cellIndex = indexPath.item;
        cell.isSlowMo = NO;

        MPMediaItemCollection* item = [assetsArray objectAtIndex:indexPath.item];
        
        MPMediaItem *representativeItem = [item representativeItem];

        MPMediaItemArtwork* artwork = [representativeItem valueForProperty:MPMediaItemPropertyArtwork];
        
        NSNumber *persistentIDNumber = [representativeItem valueForProperty:MPMediaItemPropertyPersistentID];
        NSString* persistentID = [persistentIDNumber stringValue];

        //Video thumbnail
        NSString* plistFileName = [plistFolderPath stringByAppendingPathComponent:@"ThumbFileName.plist"];
        NSMutableDictionary *plistDict = [[NSMutableDictionary alloc] initWithContentsOfFile:plistFileName];
        
        if ([plistDict objectForKey:persistentID])
        {
            NSString* thumbName = [plistDict objectForKey:persistentID];
            NSString* thumbFileName = [thumbFolderPath stringByAppendingPathComponent:thumbName];
            
            UIImage* thumbImage = [UIImage imageWithContentsOfFile:thumbFileName];
            cell.thumbnailImage = thumbImage;
        }
        else
        {
            cell.thumbnailImage = [artwork imageWithSize:AssetGridThumbnailSize];
        }
        
        //Video Pixel width, height
        CGRect artworkBound = artwork.bounds;
        [cell setPixelLabelString:[NSString stringWithFormat:@"%d x %d", (int)artworkBound.size.width, (int)artworkBound.size.height]];
        
        NSString* videoSize = [self.myCache objectForKey:[NSString stringWithFormat:@"%@-videoSize", persistentID]];
        
        if (videoSize)
        {
            NSString* videoFileName = [self.myCache objectForKey:[NSString stringWithFormat:@"%@-videoFileName", persistentID]];
            NSString* videoDuration = [self.myCache objectForKey:[NSString stringWithFormat:@"%@-videoDuration", persistentID]];
            
            [cell setFileNameLabelString:videoFileName];
            [cell setDurationLabelString:videoDuration];
            [cell setSizeLabelString:videoSize];
        }
        else
        {
            //Video File Name
            NSString* plistFileName = [plistFolderPath stringByAppendingPathComponent:@"VideoName.plist"];
            NSMutableDictionary *plistDict = [[NSMutableDictionary alloc] initWithContentsOfFile:plistFileName];
            
            if ([plistDict objectForKey:persistentID])
            {
                [cell setFileNameLabelString:[plistDict objectForKey:persistentID]];
                [self.myCache setObject:[plistDict objectForKey:persistentID] forKey:[NSString stringWithFormat:@"%@-videoFileName", persistentID]];
            }
            else
            {
                [cell setFileNameLabelString:[representativeItem valueForProperty:MPMediaItemPropertyTitle]];
                [self.myCache setObject:[representativeItem valueForProperty:MPMediaItemPropertyTitle] forKey:[NSString stringWithFormat:@"%@-videoFileName", persistentID]];
            }
            
            
            //Video Duration
            NSNumber* duration = [representativeItem valueForProperty:MPMediaItemPropertyPlaybackDuration];
            CGFloat dur = [duration floatValue];
            int min = (int)(dur / 60.0f);
            int sec = (int)(dur - min*60);
            NSString* durationStr = [NSString stringWithFormat:@"%d:%02d", min, sec];
            [cell setDurationLabelString:durationStr];
            [self.myCache setObject:durationStr forKey:[NSString stringWithFormat:@"%@-videoDuration", persistentID]];
            
            
            //File size
            NSURL *url = [representativeItem valueForProperty:MPMediaItemPropertyAssetURL];
            
            AVURLAsset* asset = [[AVURLAsset alloc] initWithURL:url options:nil];
            NSArray *tracks = [asset tracks];
            CGFloat byte = 0.0f;
            for (AVAssetTrack * track in tracks) {
                float rate = ([track estimatedDataRate] / 8);
                float seconds = CMTimeGetSeconds([track timeRange].duration);
                byte += seconds * rate;
            }
            
            NSString* videoSizeString;
            if (byte >= (1024.0f*1024.0f))
            {
                byte = byte / (1024.0f*1024.0f);
                videoSizeString = [NSString stringWithFormat:@"%.1fMB", byte];
            }
            else if (byte >= 1024.0f)
            {
                byte = byte / 1024.0f;
                videoSizeString = [NSString stringWithFormat:@"%.1fKB", byte];
            }
            else
            {
                videoSizeString = [NSString stringWithFormat:@"%.1fB", byte];
            }
            
            [cell setSizeLabelString:videoSizeString];
            [self.myCache setObject:videoSizeString forKey:[NSString stringWithFormat:@"%@-videoSize", persistentID]];
        }
    }
    else
    {
        PHAsset *asset = [assetsArray objectAtIndex:indexPath.item];
        
        [cell setPixelLabelString:[NSString stringWithFormat:@"%d x %d", (int)asset.pixelWidth, (int)asset.pixelHeight]];

        if (asset.mediaType == PHAssetMediaTypeImage)    //Photo
        {
            cell.isSlowMo = NO;
            [cell hideVideoThumbnailMenuBtn];
            [cell hideGrayBgView];

            //Image size, File name
            NSString* imageSize = [self.myCache objectForKey:[NSString stringWithFormat:@"%@-imageSize", asset.localIdentifier]];
            
            if (imageSize)
            {
                [cell setSizeLabelString:imageSize];
                
                NSString* imageName = [self.myCache objectForKey:[NSString stringWithFormat:@"%@-imageName", asset.localIdentifier]];
                [cell setFileNameLabelString:imageName];
                
                //Image Thumbnail
                [self.imageManager requestImageForAsset:asset
                                             targetSize:AssetGridThumbnailSize
                                            contentMode:PHImageContentModeDefault
                                                options:requestOptions
                                          resultHandler:^(UIImage *result, NSDictionary *info) {
                                              
                                              if (cell.tag == currentTag)
                                              {
                                                  cell.thumbnailImage = result;
                                              }
                                          }];
            }
            else
            {
                //Image Thumbnail
                [self.imageManager requestImageForAsset:asset
                                             targetSize:AssetGridThumbnailSize
                                            contentMode:PHImageContentModeDefault
                                                options:requestOptions
                                          resultHandler:^(UIImage *result, NSDictionary *info) {
                                              
                                              if (cell.tag == currentTag)
                                              {
                                                  cell.thumbnailImage = result;
                                              }
                                          }];

                [self.imageManager requestImageDataForAsset:asset options:requestOptions resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
                    
                    if (cell.tag == currentTag)
                    {
                        //Image Binary Size
                        CGFloat byte = imageData.length;
                        NSString* sizeString = nil;
                        
                        if (byte >= (1024.0f*1024.0f))
                        {
                            byte = byte / (1024.0f*1024.0f);
                            sizeString = [NSString stringWithFormat:@"%.1fMB", byte];
                        }
                        else if (byte >= 1024.0f)
                        {
                            byte = byte / 1024.0f;
                            sizeString = [NSString stringWithFormat:@"%.1fKB", byte];
                        }
                        else
                        {
                            sizeString = [NSString stringWithFormat:@"%.1fB", byte];
                        }
                        
                        [cell setSizeLabelString:sizeString];
                        
                        
                        //Image File Name
                        NSURL* nameUrl = [info objectForKey:@"PHImageFileURLKey"];
                        
                        if (nameUrl)
                        {
                            NSString* nameString = [nameUrl absoluteString];
                            nameString = [nameString lastPathComponent];
                            
                            [cell setFileNameLabelString:nameString];
                            
                            
                            [self.myCache setObject:sizeString forKey:[NSString stringWithFormat:@"%@-imageSize", asset.localIdentifier]];
                            [self.myCache setObject:nameString forKey:[NSString stringWithFormat:@"%@-imageName", asset.localIdentifier]];
                        }
                    }
                }];
            }
        }
        else if (asset.mediaType == PHAssetMediaTypeVideo)  //Video
        {
            cell.delegate = self;
            cell.cellIndex = indexPath.item;
            
            //Video thumbnail
            NSString* plistFileName = [plistFolderPath stringByAppendingPathComponent:@"ThumbFileName.plist"];
            NSMutableDictionary *plistDict = [[NSMutableDictionary alloc] initWithContentsOfFile:plistFileName];
            
            if ([plistDict objectForKey:asset.localIdentifier])
            {
                NSString* thumbName = [plistDict objectForKey:asset.localIdentifier];
                NSString* thumbFileName = [thumbFolderPath stringByAppendingPathComponent:thumbName];
                
                UIImage* thumbImage = [UIImage imageWithContentsOfFile:thumbFileName];
                cell.thumbnailImage = thumbImage;
            }
            else
            {
                [self.imageManager requestImageForAsset:asset
                                             targetSize:AssetGridThumbnailSize
                                            contentMode:PHImageContentModeDefault
                                                options:requestOptions
                                          resultHandler:^(UIImage *result, NSDictionary *info) {
                                              
                                              if (cell.tag == currentTag)
                                              {
                                                  cell.thumbnailImage = result;
                                              }
                                          }];
            }


            //Video size, duration, File name
            NSString* videoSize = [self.myCache objectForKey:[NSString stringWithFormat:@"%@-videoSize", asset.localIdentifier]];
            
            if (videoSize)
            {
                NSString* videoFileName = [self.myCache objectForKey:[NSString stringWithFormat:@"%@-videoFileName", asset.localIdentifier]];
                NSString* videoDuration = [self.myCache objectForKey:[NSString stringWithFormat:@"%@-videoDuration", asset.localIdentifier]];

                [cell setFileNameLabelString:videoFileName];
                [cell setDurationLabelString:videoDuration];
                [cell setSizeLabelString:videoSize];
                
                NSString* slowmo = [self.myCache objectForKey:[NSString stringWithFormat:@"%@-SlowMo", asset.localIdentifier]];
                
                if ([slowmo isEqualToString:@"YES"])
                {
                    cell.isSlowMo = YES;
                }
                else if ([slowmo isEqualToString:@"NO"])
                {
                    cell.isSlowMo = NO;
                }
            }
            else
            {
                [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:nil resultHandler:^(AVAsset *avAsset, AVAudioMix *audioMix, NSDictionary *info) {
                    
                    if ([avAsset isKindOfClass:[AVURLAsset class]]) //normal video
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            if ((cell.tag == currentTag)&&(avAsset != nil))
                            {
                                cell.isSlowMo = NO;
                                [self.myCache setObject:@"NO" forKey:[NSString stringWithFormat:@"%@-SlowMo", asset.localIdentifier]];

                                NSURL* url = [(AVURLAsset*)avAsset URL];
                                
                                if (url != nil)
                                {
                                    //Video File Name
                                    NSString* plistFileName = [plistFolderPath stringByAppendingPathComponent:@"VideoName.plist"];
                                    NSMutableDictionary *plistDict = [[NSMutableDictionary alloc] initWithContentsOfFile:plistFileName];
                                    
                                    if ([plistDict objectForKey:asset.localIdentifier])
                                    {
                                        [cell setFileNameLabelString:[plistDict objectForKey:asset.localIdentifier]];
                                        [self.myCache setObject:[plistDict objectForKey:asset.localIdentifier] forKey:[NSString stringWithFormat:@"%@-videoFileName", asset.localIdentifier]];
                                    }
                                    else
                                    {
                                        NSString* nameString = [url absoluteString];
                                        nameString = [nameString lastPathComponent];
                                        
                                        [cell setFileNameLabelString:nameString];
                                        [self.myCache setObject:nameString forKey:[NSString stringWithFormat:@"%@-videoFileName", asset.localIdentifier]];
                                    }
                                    
                                    
                                    //Video Duration
                                    CGFloat duration = asset.duration;
                                    NSString* durationStr = [self timeToStr:duration];
                                    
                                    [cell setDurationLabelString:durationStr];
                                    [self.myCache setObject:durationStr forKey:[NSString stringWithFormat:@"%@-videoDuration", asset.localIdentifier]];
                                    
                                    
                                    //File size
                                    NSNumber *size;
                                    [url getResourceValue:&size forKey:NSURLFileSizeKey error:nil];
                                    
                                    //Binary Size
                                    CGFloat byte = (CGFloat)[size floatValue];
                                    NSString* videoSizeString = nil;
                                    
                                    if (byte >= (1024.0f*1024.0f))
                                    {
                                        byte = byte / (1024.0f*1024.0f);
                                        videoSizeString = [NSString stringWithFormat:@"%.1fMB", byte];
                                    }
                                    else if (byte >= 1024.0f)
                                    {
                                        byte = byte / 1024.0f;
                                        videoSizeString = [NSString stringWithFormat:@"%.1fKB", byte];
                                    }
                                    else
                                    {
                                        videoSizeString = [NSString stringWithFormat:@"%.1fB", byte];
                                    }
                                    
                                    [cell setSizeLabelString:videoSizeString];
                                    
                                    [self.myCache setObject:videoSizeString forKey:[NSString stringWithFormat:@"%@-videoSize", asset.localIdentifier]];
                                }
                            }
                        });
                    }
                    else    //Slow-Mo video
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            if ((cell.tag == currentTag)&&(avAsset != nil))
                            {
                                cell.isSlowMo = YES;
                                [self.myCache setObject:@"YES" forKey:[NSString stringWithFormat:@"%@-SlowMo", asset.localIdentifier]];

                                [[PHImageManager defaultManager] requestImageDataForAsset:asset options:nil resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
                                    
                                    if (cell.tag == currentTag)
                                    {
                                        //Video Binary Size
                                        CGFloat byte = imageData.length;
                                        NSString* sizeString = nil;
                                        
                                        if (byte >= (1024.0f*1024.0f))
                                        {
                                            byte = byte / (1024.0f*1024.0f);
                                            sizeString = [NSString stringWithFormat:@"%.1fMB", byte];
                                        }
                                        else if (byte >= 1024.0f)
                                        {
                                            byte = byte / 1024.0f;
                                            sizeString = [NSString stringWithFormat:@"%.1fKB", byte];
                                        }
                                        else
                                        {
                                            sizeString = [NSString stringWithFormat:@"%.1fB", byte];
                                        }
                                        
                                        [cell setSizeLabelString:sizeString];
                                        [self.myCache setObject:sizeString forKey:[NSString stringWithFormat:@"%@-videoSize", asset.localIdentifier]];
                                        
                                        
                                        //Video File Name
                                        NSURL* nameUrl = [info objectForKey:@"PHImageFileURLKey"];
                                        
                                        if (nameUrl)
                                        {
                                            NSString* plistFileName = [plistFolderPath stringByAppendingPathComponent:@"VideoName.plist"];
                                            NSMutableDictionary *plistDict = [[NSMutableDictionary alloc] initWithContentsOfFile:plistFileName];
                                            
                                            if ([plistDict objectForKey:asset.localIdentifier])
                                            {
                                                [cell setFileNameLabelString:[plistDict objectForKey:asset.localIdentifier]];
                                                [self.myCache setObject:[plistDict objectForKey:asset.localIdentifier] forKey:[NSString stringWithFormat:@"%@-videoFileName", asset.localIdentifier]];
                                            }
                                            else
                                            {
                                                NSString* nameString = [nameUrl absoluteString];
                                                nameString = [nameString stringByReplacingOccurrencesOfString:@".JPG" withString:@".MOV"];
                                                nameString = [[nameString lastPathComponent] stringByAppendingString:@"(slow-mo)"];

                                                [cell setFileNameLabelString:nameString];
                                                [self.myCache setObject:nameString forKey:[NSString stringWithFormat:@"%@-videoFileName", asset.localIdentifier]];
                                            }
                                        }
                                        
                                        //Video Duration
                                        CGFloat duration = asset.duration;
                                        NSString* durationStr = [self timeToStr:duration];
                                        
                                        [cell setDurationLabelString:durationStr];
                                        [self.myCache setObject:durationStr forKey:[NSString stringWithFormat:@"%@-videoDuration", asset.localIdentifier]];
                                    }
                                }];
                            }
                        });
                    }
                }];
            }
        }
    }

    NSNumber* flag = [assetsFlagArray objectAtIndex:indexPath.item];
    BOOL selectedFlag = [flag boolValue];
    
    [cell markSelectedCheck:selectedFlag];
    
    return cell;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL shouldSelect = NO;

    BOOL multiSelectEnable = self.filterType == PHAssetMediaTypeImage ? YES : NO;
    
    if(self.customAssetPickerController.isSingleOnly)
        multiSelectEnable = NO;
    
    if (multiSelectEnable)
    {
        shouldSelect = YES;
    }
    else
    {
        shouldSelect = (selectedAssetsArray.count < 1);
    }
    
    AAPLGridViewCell *cell = (AAPLGridViewCell *)[collectionView cellForItemAtIndexPath:indexPath];

    if (cell.isSelected)
    {
        shouldSelect = NO;
    }
    
    if (([self.title isEqualToString:@"Shapes"])&&(self.filterType == PHAssetMediaTypeImage))
    {
        NSNumber* number = [assetsArray objectAtIndex:indexPath.item];
        
        if (shouldSelect)
        {
            [selectedAssetsArray addObject:number];
            [assetsFlagArray replaceObjectAtIndex:indexPath.item withObject:[NSNumber numberWithBool:YES]];
        }
        else
        {
            [selectedAssetsArray removeObject:number];
            [assetsFlagArray replaceObjectAtIndex:indexPath.item withObject:[NSNumber numberWithBool:NO]];
        }
    }
    else if (self.filterType == PHAssetMediaTypeVideo)
    {
        [self didSelectedThumbMenuBtn:cell];

        return NO;
    }
    else
    {
        PHAsset *asset = [assetsArray objectAtIndex:indexPath.item];
        
        if (shouldSelect)
        {
            [selectedAssetsArray addObject:asset];
            [assetsFlagArray replaceObjectAtIndex:indexPath.item withObject:[NSNumber numberWithBool:YES]];
        }
        else
        {
            [selectedAssetsArray removeObject:asset];
            [assetsFlagArray replaceObjectAtIndex:indexPath.item withObject:[NSNumber numberWithBool:NO]];
        }
    }
    
    [cell markSelectedCheck:shouldSelect];
    
    if (self.filterType == PHAssetMediaTypeVideo)
        [self.selectButton setEnabled:YES];
    else
        [self.selectButton setEnabled:(selectedAssetsArray.count > 0)];
    
    if (!multiSelectEnable & shouldSelect)
    {
        [self didSelectedAssets];
    }
    
    return shouldSelect;
}

- (NSString *)timeToStr:(CGFloat)time
{
    // time - seconds
    int min = floor(time / 60);
    int sec = floor(time - min * 60);
    
    NSString *minStr = [NSString stringWithFormat:@"%d", min];
    NSString *secStr = [NSString stringWithFormat:sec >= 10 ? @"%d" : @"0%d", sec];
    
    return [NSString stringWithFormat:@"%@:%@", minStr, secStr];
}


#pragma mark -
#pragma mark - Select, iCloud Save

- (IBAction)handleSelectButtonItem:(id)sender
{
    if (self.filterType == PHAssetMediaTypeVideo)
    {
        NSURL *ubiq = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
        
        if (ubiq)
        {
            [[SHKActivityIndicator currentIndicator] displayActivity:(@"Backup to iCloud...") isLock:YES];
            
            [self performSelector:@selector(saveCustomVideoData) withObject:nil afterDelay:0.02f];   //save custom video thumb to iCloud
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please login to iCloud first!"  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil, nil];
            [alert show];
        }
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [[SHKActivityIndicator currentIndicator] displayActivity:(@"Optimizing Selections...") isLock:YES];
            
            [self performSelector:@selector(didSelectedAssets) withObject:nil afterDelay:0.02f];
        });
    }
}


#pragma mark -
#pragma mark - Oldest/Newest

- (void)handleOldestButtonItem:(id)sender
{
    NSArray* array = assetsArray.reverseObjectEnumerator.allObjects;
    
    [assetsArray removeAllObjects];
    assetsArray = nil;
    assetsArray = [NSMutableArray arrayWithArray:array];
    
    array = assetsFlagArray.reverseObjectEnumerator.allObjects;
    
    [assetsFlagArray removeAllObjects];
    assetsFlagArray = nil;
    assetsFlagArray = [NSMutableArray arrayWithArray:array];

    if ([self.oldestButton.title isEqualToString:@"Oldest"])
    {
        [self.oldestButton setTitle:@"Newest"];
    }
    else
    {
        [self.oldestButton setTitle:@"Oldest"];
    }

    [self.collectionView reloadData];
}

- (void)didSelectedAssets
{
    if (self.filterType == PHAssetMediaTypeVideo)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[SHKActivityIndicator currentIndicator] displayActivity:(@"Loading...") isLock:YES];
        });
    }
    
    if (([self.title isEqualToString:@"Shapes"])&&(self.filterType == PHAssetMediaTypeImage))
    {
        if ([self.customAssetPickerController.customAssetDelegate respondsToSelector:@selector(customAssetsPickerController:didFinishPickingShapes:)])
        {
            [self.customAssetPickerController.customAssetDelegate customAssetsPickerController:self.customAssetPickerController didFinishPickingShapes:selectedAssetsArray];
        }
    }
    else if (([self.title isEqualToString:@"Movies"])&&(self.filterType == PHAssetMediaTypeVideo))
    {
        if ([self.customAssetPickerController.customAssetDelegate respondsToSelector:@selector(customAssetsPickerController:didFinishPickingMovies:)])
        {
            [self.customAssetPickerController.customAssetDelegate customAssetsPickerController:self.customAssetPickerController didFinishPickingMovies:selectedAssetsArray];
        }
    }
    else
    {
        if ([self.customAssetPickerController.customAssetDelegate respondsToSelector:@selector(customAssetsPickerController:didFinishPickingAssets:)])
        {
            [self.customAssetPickerController.customAssetDelegate customAssetsPickerController:self.customAssetPickerController didFinishPickingAssets:selectedAssetsArray];
        }
    }
}


#pragma mark - 
#pragma mark - AAPLGridViewCellDelegate

- (void)didSelectedThumbMenuBtn:(AAPLGridViewCell*) cell
{
    if (cell.isSlowMo)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Video Dreamer" message:@"Sorry, Slow-Mo video is not supported."  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil, nil];
        [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
        
        return;
    }
    
    selectedCell = cell;
    
    NSArray *menuItems = nil;
    
    if (isWorkspace)
    {
        if ( [self.title isEqualToString:@"Recently Deleted"]  || [self.title isEqualToString:@"Movies"]) {
            menuItems = @[[YJLActionMenuItem menuItem:@"Open in Player"
                                                image:nil
                                               target:self
                                               action:@selector(didOpenInPlayer)],
                          
                          [YJLActionMenuItem menuItem:@"Open in Project"
                                                image:nil
                                               target:self
                                               action:@selector(didOpenInProject)],
                          
                          [YJLActionMenuItem menuItem:@"Custom Thumbnail"
                                                image:nil
                                               target:self
                                               action:@selector(didCustomThumbnail)],
                          
                          [YJLActionMenuItem menuItem:@"Rename"
                                                image:nil
                                               target:self
                                               action:@selector(didRename)],
                          
                          [YJLActionMenuItem menuItem:@"Duplicate"
                                                image:nil
                                               target:self
                                               action:@selector(didDuplicate)],
                          ];
        }
        else{
            menuItems = @[[YJLActionMenuItem menuItem:@"Open in Player"
                                                image:nil
                                               target:self
                                               action:@selector(didOpenInPlayer)],
                          
                          [YJLActionMenuItem menuItem:@"Open in Project"
                                                image:nil
                                               target:self
                                               action:@selector(didOpenInProject)],
                          
                          [YJLActionMenuItem menuItem:@"Custom Thumbnail"
                                                image:nil
                                               target:self
                                               action:@selector(didCustomThumbnail)],
                          
                          [YJLActionMenuItem menuItem:@"Rename"
                                                image:nil
                                               target:self
                                               action:@selector(didRename)],
                          
                          [YJLActionMenuItem menuItem:@"Duplicate"
                                                image:nil
                                               target:self
                                               action:@selector(didDuplicate)],
                          
                          [YJLActionMenuItem menuItem:@"Delete"
                                                image:nil
                                               target:self
                                               action:@selector(didDelete)],
                          
                          [YJLActionMenuItem menuItem:@"Share"
                                                image:nil
                                               target:self
                                               action:@selector(didShare)],
                          
                          
                          ];
        }
        
    }
    else
    {
        if ( [self.title isEqualToString:@"Recently Deleted"] || [self.title isEqualToString:@"Movies"]){
            menuItems = @[[YJLActionMenuItem menuItem:@"Open in Player"
                                                image:nil
                                               target:self
                                               action:@selector(didOpenInPlayer)],
                          
                          [YJLActionMenuItem menuItem:@"Custom Thumbnail"
                                                image:nil
                                               target:self
                                               action:@selector(didCustomThumbnail)],
                          
                          [YJLActionMenuItem menuItem:@"Rename"
                                                image:nil
                                               target:self
                                               action:@selector(didRename)],
                          
                          [YJLActionMenuItem menuItem:@"Duplicate"
                                                image:nil
                                               target:self
                                               action:@selector(didDuplicate)], ];
        }
        else{
            menuItems = @[[YJLActionMenuItem menuItem:@"Open in Player"
                                                image:nil
                                               target:self
                                               action:@selector(didOpenInPlayer)],
                          
                          [YJLActionMenuItem menuItem:@"Custom Thumbnail"
                                                image:nil
                                               target:self
                                               action:@selector(didCustomThumbnail)],
                          
                          [YJLActionMenuItem menuItem:@"Rename"
                                                image:nil
                                               target:self
                                               action:@selector(didRename)],
                          
                          [YJLActionMenuItem menuItem:@"Duplicate"
                                                image:nil
                                               target:self
                                               action:@selector(didDuplicate)],
                          [YJLActionMenuItem menuItem:@"Delete"
                                                image:nil
                                               target:self
                                               action:@selector(didDelete)],
                          
                          [YJLActionMenuItem menuItem:@"Share"
                                                image:nil
                                               target:self
                                               action:@selector(didShare)],
                          ];

        }
    }
    
    CGRect frame = [cell.videoThumbMenuBtn convertRect:cell.videoThumbMenuBtn.bounds toView:self.view];
    
    [YJLActionMenu showMenuInView:self.navigationController.view
                         fromRect:frame
                        menuItems:menuItems isWhiteBG:NO];
}


-(void) didOpenInPlayer
{
    if (self.customModalView != nil)
    {
        [self.customModalView hideCustomModalView];
        self.customModalView = nil;
    }
    
    CGRect menuFrame = CGRectZero;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        if ([UIScreen mainScreen].bounds.size.height <= 320.0f)
        {
            menuFrame = CGRectMake(0.0f, 0.0f, 300.0f, 230.0f);
        }
        else
        {
            menuFrame = CGRectMake(0.0f, 0.0f, 300.0f, 250.0f);
        }
    }
    else
        menuFrame = CGRectMake(0.0f, 0.0f, 700.0f, 500.0f);
    
    if (self.videoPlayer != nil)
    {
        self.videoPlayer = nil;
    }
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        self.videoPlayer = [[[NSBundle mainBundle] loadNibNamed:@"YJLVideoPlayer"
                                                              owner:self
                                                            options:nil] objectAtIndex:0];
    else
        self.videoPlayer = [[[NSBundle mainBundle] loadNibNamed:@"YJLVideoPlayer_iPad"
                                                              owner:self
                                                            options:nil] objectAtIndex:0];
    
    [self.videoPlayer initFrame:menuFrame];
    self.videoPlayer.delegate = self;
    
    if (([self.title isEqualToString:@"Movies"])&&(self.filterType == PHAssetMediaTypeVideo))
    {
        MPMediaItemCollection* item = [assetsArray objectAtIndex:selectedCell.cellIndex];
        
        MPMediaItem *representativeItem = [item representativeItem];
        NSURL *url = [representativeItem valueForProperty:MPMediaItemPropertyAssetURL];
        
        [self.videoPlayer initMovie:url];
    }
    else
    {
        PHAsset *asset = [assetsArray objectAtIndex:selectedCell.cellIndex];
        
        [self.videoPlayer initVideo:asset];
    }
    
    self.customModalView = [[CustomModalView alloc] initWithViewController:self view:self.videoPlayer];
    self.customModalView.delegate = self;
    self.customModalView.dismissButtonRight = YES;
    [self.customModalView show];
}

-(void) didOpenInProject
{
    if (([self.title isEqualToString:@"Movies"])&&(self.filterType == PHAssetMediaTypeVideo))
    {
        MPMediaItemCollection* item = [assetsArray objectAtIndex:selectedCell.cellIndex];
        
        [selectedAssetsArray addObject:item];
    }
    else
    {
        PHAsset *asset = [assetsArray objectAtIndex:selectedCell.cellIndex];
        
        [selectedAssetsArray addObject:asset];
    }
    
    [assetsFlagArray replaceObjectAtIndex:selectedCell.cellIndex withObject:[NSNumber numberWithBool:YES]];
    
    [selectedCell markSelectedCheck:YES];
    
    if (self.filterType == PHAssetMediaTypeVideo)
        [self.selectButton setEnabled:YES];
    else
        [self.selectButton setEnabled:(selectedAssetsArray.count > 0)];
    
    [self didSelectedAssets];

}

-(void) didCustomThumbnail
{
    if (self.customModalView != nil)
    {
        [self.customModalView hideCustomModalView];
        self.customModalView = nil;
    }
    
    CGRect menuFrame = CGRectZero;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        menuFrame = CGRectMake(0.0f, 0.0f, 300.0f, 250.0f);
    else
        menuFrame = CGRectMake(0.0f, 0.0f, 700.0f, 500.0f);
    
    if (self.videoThumbMaker != nil)
    {
        self.videoThumbMaker = nil;
    }
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        self.videoThumbMaker = [[[NSBundle mainBundle] loadNibNamed:@"YJLVideoThumbMaker"
                                                       owner:self
                                                     options:nil] objectAtIndex:0];
    else
        self.videoThumbMaker = [[[NSBundle mainBundle] loadNibNamed:@"YJLVideoThumbMaker_iPad"
                                                          owner:self
                                                        options:nil] objectAtIndex:0];

    self.videoThumbMaker.delegate = self;
    [self.videoThumbMaker initFrame:menuFrame];
    
    if (([self.title isEqualToString:@"Movies"])&&(self.filterType == PHAssetMediaTypeVideo))
    {
        MPMediaItemCollection* item = [assetsArray objectAtIndex:selectedCell.cellIndex];
        
        MPMediaItem *representativeItem = [item representativeItem];
        NSURL *url = [representativeItem valueForProperty:MPMediaItemPropertyAssetURL];

        [selectedAssetsArray addObject:item];
        
        [self.videoThumbMaker initMovie:url];
    }
    else
    {
        PHAsset *asset = [assetsArray objectAtIndex:selectedCell.cellIndex];
        
        [selectedAssetsArray addObject:asset];
        
        [self.videoThumbMaker initVideo:asset];
    }

    self.customModalView = [[CustomModalView alloc] initWithViewController:self view:self.videoThumbMaker];
    self.customModalView.delegate = self;
    self.customModalView.dismissButtonRight = YES;
    [self.customModalView show];
}

-(void) didRename
{
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:@"Rename Video"
                              message:[NSString stringWithFormat:@"Current Video Name is %@. Please enter new name!", selectedCell.videoNameLabel.text]
                              delegate:self
                              cancelButtonTitle:@"Cancel"
                              otherButtonTitles:@"Ok", nil];
    [alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
    
    UITextField *textField = [alertView textFieldAtIndex:0];
    textField.keyboardType = UIKeyboardTypeDefault;
    textField.text = [NSString stringWithFormat:@"%@", selectedCell.videoNameLabel.text];
    
    [textField performSelector:@selector(selectAll:) withObject:textField];
    
    [alertView show];
}

- (void) didDelete
{
    if (([self.title isEqualToString:@"Movies"])&&(self.filterType == PHAssetMediaTypeVideo))
    {
        [assetsArray removeObjectAtIndex: selectedCell.cellIndex];
        
        MPMediaItemCollection* item = [assetsArray objectAtIndex:selectedCell.cellIndex];
        
        MPMediaItem *representativeItem = [item representativeItem];
        self.movieURL = [representativeItem valueForProperty: MPMediaItemPropertyAssetURL];
//        NSString * name  = representativeItem.title;
//        NSURL * l = representativeItem.;
//        representativeItem.
//        
//   
//        NSFileManager *manager = [NSFileManager defaultManager];
//        NSError *error;
//        NSString * videoPath = [self.movieURL absoluteString];
//        if ([manager fileExistsAtPath:videoPath]) {
//            BOOL success = [manager removeItemAtPath:videoPath error:&error];
//            if (success) {
//                NSLog(@"Already exist. Removed!");
//            }
//        }
    }
    else{
        PHAsset *asset = [assetsArray objectAtIndex:selectedCell.cellIndex];
        [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:nil resultHandler:^(AVAsset *avAsset, AVAudioMix *audioMix, NSDictionary *info) {
            self.movieURL = [(AVURLAsset*)avAsset URL];
        }];

        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            [PHAssetChangeRequest deleteAssets:@[asset]];
        } completionHandler:^(BOOL success, NSError *error) {
            NSLog(@"Finished removing asset from the album. %@", (success ? @"Success" : error));
        }];

    }
}

- (void) didShare
{
//    [[SHKActivityIndicator currentIndicator] displayActivity:(@"Processing...") isLock:YES];
     typeof(self) __weak weakSelf = self;
    
    if (([self.title isEqualToString:@"Movies"])&&(self.filterType == PHAssetMediaTypeVideo))
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString * name  = [NSString stringWithFormat:@"%@.mp4", @"temp"];
        NSString* videoPath = [documentsDirectory stringByAppendingPathComponent:name];
        NSURL *outputURL = [NSURL fileURLWithPath:videoPath];

        
        MPMediaItemCollection* item = [assetsArray objectAtIndex:selectedCell.cellIndex];
        
        MPMediaItem *representativeItem = [item representativeItem];
        NSURL *movieURL = [representativeItem valueForProperty:MPMediaItemPropertyAssetURL];
        
//        PHAsset *asset;
        // Get FilePath
        //    [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:nil resultHandler:^(AVAsset *avAsset, AVAudioMix *audioMix, NSDictionary *info) {
        //        if ([avAsset isKindOfClass:[AVURLAsset class]]) //normal video
        //        {
        //            NSString * url = [[(AVURLAsset*)avAsset URL] absoluteString];
        //            // = [NSURL fileURLWithPath:self.filePath];
        //            NSArray * arr  = [url componentsSeparatedByString:@"/"];
        //            NSString * sub = [arr objectAtIndex:([arr count]-1)];
        //            NSArray * arr1 = [sub componentsSeparatedByString:@"."];
        //            self.urlShare  = [arr1 objectAtIndex:0];
        //        }
        //    }];

        
        AVAsset* outputVideoAsset = [AVAsset assetWithURL:movieURL];
        AVAssetExportSession* exporter = [[AVAssetExportSession alloc] initWithAsset:outputVideoAsset presetName:AVAssetExportPresetLowQuality];
        exporter.outputURL = [NSURL fileURLWithPath:videoPath];
        exporter.outputFileType = AVFileTypeQuickTimeMovie;
        exporter.shouldOptimizeForNetworkUse = YES;
        
        NSFileManager *manager = [NSFileManager defaultManager];
        
        [exporter exportAsynchronouslyWithCompletionHandler:^
         {
             [[SHKActivityIndicator currentIndicator] hide];
             dispatch_async(dispatch_get_main_queue(), ^(void) {
                 NSArray *activityItems = [NSArray arrayWithObjects:outputURL, nil];
                 
                 UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
                 
                 activityViewController.completionWithItemsHandler = ^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError) {
                     NSError *error;
                     if ([manager fileExistsAtPath:videoPath]) {
                         BOOL success = [manager removeItemAtPath:videoPath error:&error];
                         if (success) {
                             NSLog(@"Successfully removed temp video!");
                         }
                     }
                     [weakSelf dismissViewControllerAnimated:YES completion:nil];
                 };
                 if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
                     [weakSelf presentViewController:activityViewController animated:YES completion:nil];
                 else{
                     TTOpenInAppActivity *openInAppActivity = [[TTOpenInAppActivity alloc]initWithView:self.view andRect:CGRectMake(self.view.frame.size.width/2, self.view.frame.size.height , 0, 0)];
                     self.activityPopoverController = [[UIPopoverController alloc] initWithContentViewController:activityViewController];
                     openInAppActivity.superViewController = self.activityPopoverController;
                     [self.activityPopoverController presentPopoverFromRect:CGRectMake(self.view.frame.size.width/2, self.view.frame.size.height , 0, 0) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUnknown animated:YES];
                     
                 }
                 
             });

         }];

    }
    else{
        PHAsset *asset;
        asset = [assetsArray objectAtIndex:selectedCell.cellIndex];
       
        [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:nil resultHandler:^(AVAsset *avAsset, AVAudioMix *audioMix, NSDictionary *info) {
            if ([avAsset isKindOfClass:[AVURLAsset class]]) //normal video
            {
                NSString * url = [[(AVURLAsset*)avAsset URL] absoluteString];
                // = [NSURL fileURLWithPath:self.filePath];
                NSArray * arr  = [url componentsSeparatedByString:@"/"];
                NSString * sub = [arr objectAtIndex:([arr count]-1)];
                NSArray * arr1 = [sub componentsSeparatedByString:@"."];
                self.urlShare  = [arr1 objectAtIndex:0];
            }
            
            [[PHImageManager defaultManager] requestExportSessionForVideo: asset options:nil exportPreset:AVAssetExportPresetLowQuality resultHandler:^(AVAssetExportSession *exportSession, NSDictionary *info) {
                
                NSFileManager *manager = [NSFileManager defaultManager];
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
                NSString *documentsDirectory = [paths objectAtIndex:0];
                NSString * name  = [NSString stringWithFormat:@"%@.mp4", self.urlShare];
                NSString* videoPath = [documentsDirectory stringByAppendingPathComponent:name];
                NSURL *outputURL = [NSURL fileURLWithPath:videoPath];

                NSError *error;
                if ([manager fileExistsAtPath:videoPath]) {
                    BOOL success = [manager removeItemAtPath:videoPath error:&error];
                    if (success) {
                        NSLog(@"Already exist. Removed!");
                    }
                }
                
                NSLog(@"Final path %@",outputURL);
                exportSession.outputFileType=AVFileTypeQuickTimeMovie;
                exportSession.outputURL=outputURL;
                
                [exportSession exportAsynchronouslyWithCompletionHandler:^{
                    
                    [[SHKActivityIndicator currentIndicator] hide];
                    if (exportSession.status == AVAssetExportSessionStatusFailed) {
                        NSLog(@"failed");
                    } else if(exportSession.status == AVAssetExportSessionStatusCompleted){
                        NSLog(@"completed!");
                        dispatch_async(dispatch_get_main_queue(), ^(void) {
                            NSArray *activityItems = [NSArray arrayWithObjects:outputURL, nil];
                            
                            UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
                            
                            activityViewController.completionWithItemsHandler = ^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError) {
                                NSError *error;
                                if ([manager fileExistsAtPath:videoPath]) {
                                    BOOL success = [manager removeItemAtPath:videoPath error:&error];
                                    if (success) {
                                        NSLog(@"Successfully removed temp video!");
                                    }
                                }
                                [weakSelf dismissViewControllerAnimated:YES completion:nil];
                            };
                            if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
                                [weakSelf presentViewController:activityViewController animated:YES completion:nil];
                            else{
                                TTOpenInAppActivity *openInAppActivity = [[TTOpenInAppActivity alloc]initWithView:self.view andRect:CGRectMake(self.view.frame.size.width/2, self.view.frame.size.height , 0, 0)];
                                self.activityPopoverController = [[UIPopoverController alloc] initWithContentViewController:activityViewController];
                                openInAppActivity.superViewController = self.activityPopoverController;
                                [self.activityPopoverController presentPopoverFromRect:CGRectMake(self.view.frame.size.width/2, self.view.frame.size.height , 0, 0) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUnknown animated:YES];
                                
                            }
                            
                        });     
                    }
                }];
            }];

        }];
    }
}

-(void) didDuplicate
{
    [[SHKActivityIndicator currentIndicator] displayActivity:(@"Duplicating...") isLock:YES];

    if (([self.title isEqualToString:@"Movies"])&&(self.filterType == PHAssetMediaTypeVideo))
    {
        MPMediaItemCollection* item = [assetsArray objectAtIndex:selectedCell.cellIndex];
        
        MPMediaItem *representativeItem = [item representativeItem];
        NSURL *movieURL = [representativeItem valueForProperty:MPMediaItemPropertyAssetURL];
 
        
        AVAsset* outputVideoAsset = [AVAsset assetWithURL:movieURL];
        
        NSString* pathToMovie = [NSTemporaryDirectory() stringByAppendingPathComponent:@"iPodMovie.m4v"];
        unlink([pathToMovie UTF8String]);

        AVAssetExportSession* exporter = [[AVAssetExportSession alloc] initWithAsset:outputVideoAsset presetName:AVAssetExportPresetHighestQuality];
        exporter.outputURL = [NSURL fileURLWithPath:pathToMovie];
        exporter.outputFileType = AVFileTypeQuickTimeMovie;
        exporter.shouldOptimizeForNetworkUse = YES;
        
        [exporter exportAsynchronouslyWithCompletionHandler:^
         {
             switch ([exporter status])
             {
                 case AVAssetExportSessionStatusFailed:
                     
                     NSLog(@"Export failed: %@", [[exporter error] localizedDescription]);
                     
                     dispatch_async(dispatch_get_main_queue(), ^{
                         
                         [[SHKActivityIndicator currentIndicator] hide];
                         
                     });
                     
                     break;
                     
                 case AVAssetExportSessionStatusCancelled:
                     
                     NSLog(@"Export canceled");
                     
                     dispatch_async(dispatch_get_main_queue(), ^{
                         
                         [[SHKActivityIndicator currentIndicator] hide];

                     });
                     
                     break;
                     
                 default:
                     
                     dispatch_async(dispatch_get_main_queue(), ^{
                         
                         if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0f)
                         {
                             ALAssetsLibrary* library = [[ALAssetsLibrary alloc] init];
                             
                             [library saveVideo:[NSURL fileURLWithPath:pathToMovie] toAlbum:@"Video Dreamer" withCompletionBlock:^(NSError *error)
                              {
                                  if (error!=nil)
                                  {
                                      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Video duplicate failed:%@", [error description]]  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil, nil];
                                      [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
                                  }
                                  else
                                  {
                                      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Duplicated video to Photo Album"  delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                                      [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
                                  }
                                  
                                  [[SHKActivityIndicator currentIndicator] performSelectorOnMainThread:@selector(hide) withObject:nil waitUntilDone:NO];
                              }];
                             
                             library = nil;
                         }
                         else
                         {
                             [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^
                              {
                                  PHFetchOptions *fetchOptions = [PHFetchOptions new];
                                  fetchOptions.predicate = [NSPredicate predicateWithFormat:@"title == %@", @"Video Dreamer"];
                                  
                                  PHFetchResult *fetchResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:fetchOptions];
                                  
                                  if (fetchResult.count == 0)//new create
                                  {
                                      //create asset
                                      PHAssetChangeRequest *videoRequest = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:[NSURL fileURLWithPath:pathToMovie]];
                                      
                                      //Create Album
                                      PHAssetCollectionChangeRequest *albumRequest = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:@"Video Dreamer"];
                                      
                                      //get a placeholder for the new asset and add it to the album editing request
                                      PHObjectPlaceholder* assetPlaceholder = [videoRequest placeholderForCreatedAsset];
                                      
                                      [albumRequest addAssets:@[assetPlaceholder]];
                                  }
                                  else //add video to album
                                  {
                                      //create asset
                                      PHAssetChangeRequest *videoRequest = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:[NSURL fileURLWithPath:pathToMovie]];
                                      
                                      //change Album
                                      PHAssetCollection *assetCollection = (PHAssetCollection *)fetchResult[0];
                                      PHAssetCollectionChangeRequest *albumRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:assetCollection];
                                      
                                      //get a placeholder for the new asset and add it to the album editing request
                                      PHObjectPlaceholder* assetPlaceholder = [videoRequest placeholderForCreatedAsset];
                                      
                                      [albumRequest addAssets:@[assetPlaceholder]];
                                  }
                                  
                              } completionHandler:^(BOOL success, NSError *error) {
                                  
                                  [[SHKActivityIndicator currentIndicator] performSelectorOnMainThread:@selector(hide) withObject:nil waitUntilDone:NO];
                                  
                                  if (error!=nil)
                                  {
                                      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Video duplicate failed:%@", [error description]]  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil, nil];
                                      [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
                                  }
                                  else
                                  {
                                      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Duplicated video to Photo Album"  delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                                      [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
                                  }
                              }];
                         }
                     });
                     
                     break;
             }
         }];
    }
    else
    {
        PHAsset *asset = [assetsArray objectAtIndex:selectedCell.cellIndex];
        
        [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:nil resultHandler:^(AVAsset *avAsset, AVAudioMix *audioMix, NSDictionary *info) {
            
            if ([avAsset isKindOfClass:[AVURLAsset class]]) //normal video
            {
                dispatch_async(dispatch_get_main_queue(), ^{

                    NSURL* url = [(AVURLAsset*)avAsset URL];

                    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0f)
                    {
                        ALAssetsLibrary* library = [[ALAssetsLibrary alloc] init];
                        
                        [library saveVideo:url toAlbum:@"Video Dreamer" withCompletionBlock:^(NSError *error)
                         {
                             if (error!=nil)
                             {
                                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Video duplicate failed:%@", [error description]]  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil, nil];
                                 [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
                             }
                             else
                             {
                                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Duplicated video to Photo Album"  delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                                 [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
                             }
                             
                             [[SHKActivityIndicator currentIndicator] performSelectorOnMainThread:@selector(hide) withObject:nil waitUntilDone:NO];
                         }];
                        
                        library = nil;
                    }
                    else
                    {
                        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^
                         {
                             PHFetchOptions *fetchOptions = [PHFetchOptions new];
                             fetchOptions.predicate = [NSPredicate predicateWithFormat:@"title == %@", @"Video Dreamer"];
                             
                             PHFetchResult *fetchResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:fetchOptions];
                             
                             if (fetchResult.count == 0)//new create
                             {
                                 //create asset
                                 PHAssetChangeRequest *videoRequest = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:url];
                                 
                                 //Create Album
                                 PHAssetCollectionChangeRequest *albumRequest = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:@"Video Dreamer"];
                                 
                                 //get a placeholder for the new asset and add it to the album editing request
                                 PHObjectPlaceholder* assetPlaceholder = [videoRequest placeholderForCreatedAsset];
                                 
                                 [albumRequest addAssets:@[assetPlaceholder]];
                             }
                             else //add video to album
                             {
                                 //create asset
                                 PHAssetChangeRequest *videoRequest = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:url];
                                 
                                 //change Album
                                 PHAssetCollection *assetCollection = (PHAssetCollection *)fetchResult[0];
                                 PHAssetCollectionChangeRequest *albumRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:assetCollection];
                                 
                                 //get a placeholder for the new asset and add it to the album editing request
                                 PHObjectPlaceholder* assetPlaceholder = [videoRequest placeholderForCreatedAsset];
                                 
                                 [albumRequest addAssets:@[assetPlaceholder]];
                             }
                             
                         } completionHandler:^(BOOL success, NSError *error) {
                             
                             [[SHKActivityIndicator currentIndicator] performSelectorOnMainThread:@selector(hide) withObject:nil waitUntilDone:NO];
                             
                             if (error!=nil)
                             {
                                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Video duplicate failed:%@", [error description]]  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil, nil];
                                 [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
                             }
                             else
                             {
                                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Duplicated video to Photo Album"  delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                                 [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
                             }
                         }];
                    }
                    
                });
            }
            else  //Slow-Mo video
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [[PHImageManager defaultManager] requestImageDataForAsset:asset options:nil resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
                        
                        NSURL* url = [info objectForKey:@"PHImageFileURLKey"];
                        
                        if (url)
                        {
                            if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0f)
                            {
                                ALAssetsLibrary* library = [[ALAssetsLibrary alloc] init];
                                
                                [library saveVideo:url toAlbum:@"Video Dreamer" withCompletionBlock:^(NSError *error)
                                 {
                                     if (error!=nil)
                                     {
                                         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Video duplicate failed:%@", [error description]]  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil, nil];
                                         [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
                                     }
                                     else
                                     {
                                         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Duplicated video to Photo Album"  delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                                         [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
                                     }
                                     
                                     [[SHKActivityIndicator currentIndicator] performSelectorOnMainThread:@selector(hide) withObject:nil waitUntilDone:NO];
                                 }];
                                
                                library = nil;
                            }
                            else
                            {
                                [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^
                                 {
                                     PHFetchOptions *fetchOptions = [PHFetchOptions new];
                                     fetchOptions.predicate = [NSPredicate predicateWithFormat:@"title == %@", @"Video Dreamer"];
                                     
                                     PHFetchResult *fetchResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:fetchOptions];
                                     
                                     if (fetchResult.count == 0)//new create
                                     {
                                         //create asset
                                         PHAssetChangeRequest *videoRequest = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:url];
                                         
                                         //Create Album
                                         PHAssetCollectionChangeRequest *albumRequest = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:@"Video Dreamer"];
                                         
                                         //get a placeholder for the new asset and add it to the album editing request
                                         PHObjectPlaceholder* assetPlaceholder = [videoRequest placeholderForCreatedAsset];
                                         
                                         [albumRequest addAssets:@[assetPlaceholder]];
                                     }
                                     else //add video to album
                                     {
                                         //create asset
                                         PHAssetChangeRequest *videoRequest = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:url];
                                         
                                         //change Album
                                         PHAssetCollection *assetCollection = (PHAssetCollection *)fetchResult[0];
                                         PHAssetCollectionChangeRequest *albumRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:assetCollection];
                                         
                                         //get a placeholder for the new asset and add it to the album editing request
                                         PHObjectPlaceholder* assetPlaceholder = [videoRequest placeholderForCreatedAsset];
                                         
                                         [albumRequest addAssets:@[assetPlaceholder]];
                                     }
                                     
                                 } completionHandler:^(BOOL success, NSError *error) {
                                     
                                     [[SHKActivityIndicator currentIndicator] performSelectorOnMainThread:@selector(hide) withObject:nil waitUntilDone:NO];
                                     
                                     if (error!=nil)
                                     {
                                         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Video duplicate failed:%@", [error description]]  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil, nil];
                                         [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
                                     }
                                     else
                                     {
                                         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Duplicated video to Photo Album"  delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                                         [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
                                     }
                                 }];
                            }
                        }
                    }];
                });
            }
        }];
    }
}


#pragma mark -
#pragma mark - YJLVideoThumbMakerDelegate

-(void) didCancelVideoThumbMaker
{
    if (self.customModalView != nil)
    {
        [self.customModalView hideCustomModalView];
        self.customModalView = nil;
    }

    [selectedAssetsArray removeAllObjects];
    [assetsFlagArray replaceObjectAtIndex:selectedCell.cellIndex withObject:[NSNumber numberWithBool:NO]];
    
    [selectedCell markSelectedCheck:NO];
    
    if (self.filterType == PHAssetMediaTypeVideo)
        [self.selectButton setEnabled:YES];
    else
        [self.selectButton setEnabled:(selectedAssetsArray.count > 0)];

    selectedCell = nil;
}

-(void) didSelectedFrame:(CGFloat) time
{
    if (([self.title isEqualToString:@"Movies"])&&(self.filterType == PHAssetMediaTypeVideo))
    {
        MPMediaItemCollection* item = [assetsArray objectAtIndex:selectedCell.cellIndex];
        
        MPMediaItem *representativeItem = [item representativeItem];
        NSURL *url = [representativeItem valueForProperty:MPMediaItemPropertyAssetURL];
        NSNumber *persistentIDNumber = [representativeItem valueForProperty:MPMediaItemPropertyPersistentID];
        NSString* persistentID = [persistentIDNumber stringValue];

        AVAsset* avAsset = [AVAsset assetWithURL:url];
        
        AVAssetImageGenerator* generator = [[AVAssetImageGenerator alloc] initWithAsset:avAsset];
        generator.appliesPreferredTrackTransform = YES;
        
        CMTime thumbTime = CMTimeMakeWithSeconds(time, avAsset.duration.timescale);
        generator.maximumSize = CGSizeMake(selectedCell.bounds.size.width*2.0f, selectedCell.bounds.size.height*2.0f);
        
        AVAssetImageGeneratorCompletionHandler handler = ^(CMTime requestedTime, CGImageRef im, CMTime actualTime, AVAssetImageGeneratorResult result, NSError* error)
        {
            if (result == AVAssetImageGeneratorSucceeded)
            {
                UIImage *image = [UIImage imageWithCGImage:im];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    selectedCell.thumbnailImage = image;
                    
                    NSError *error;
                    
                    //Save Custom Thumbnail
                    NSDate *myDate = [NSDate date];
                    NSDateFormatter *df = [[NSDateFormatter alloc] init];
                    [df setDateFormat:@"yyyy-MM-dd-hh-mm-s"];
                    
                    NSString* thumbName = [df stringFromDate:myDate];
                    NSString* thumbnailFileName = [thumbFolderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", thumbName]];
                    
                    if ([localFileManager fileExistsAtPath:thumbnailFileName])
                        [localFileManager removeItemAtPath:thumbnailFileName error:&error ];
                    
                    [UIImagePNGRepresentation(image) writeToFile:thumbnailFileName atomically:YES];
                    
                    
                    //Store Custom Thumbnail file name in plist
                    NSMutableDictionary *plistDict = nil;
                    
                    NSString* plistFileName = [plistFolderPath stringByAppendingPathComponent:@"ThumbFileName.plist"];
                    
                    if (![localFileManager fileExistsAtPath:plistFileName])
                    {
                        [localFileManager createFileAtPath:plistFileName contents:nil attributes:nil];
                        
                        plistDict = [NSMutableDictionary dictionary];
                    }
                    else
                    {
                        plistDict = [[NSMutableDictionary alloc] initWithContentsOfFile:plistFileName];
                        
                        if ([plistDict objectForKey:persistentID])
                        {
                            NSString* oldThumbName = [plistDict objectForKey:persistentID];
                            NSString* oldThumbFileName = [thumbFolderPath stringByAppendingPathComponent:oldThumbName];
                            
                            if ([localFileManager fileExistsAtPath:oldThumbFileName])
                                [localFileManager removeItemAtPath:oldThumbFileName error:&error];
                            
                            [plistDict removeObjectForKey:persistentID];
                        }
                    }
                    
                    [plistDict setObject:[NSString stringWithFormat:@"%@.png", thumbName] forKey:persistentID];
                    [plistDict writeToFile:plistFileName atomically:YES];
                    
                    
                    if (self.customModalView != nil)
                    {
                        [self.customModalView hideCustomModalView];
                        self.customModalView = nil;
                    }
                    
                    [selectedAssetsArray removeAllObjects];
                    [assetsFlagArray replaceObjectAtIndex:selectedCell.cellIndex withObject:[NSNumber numberWithBool:NO]];
                    
                    [selectedCell markSelectedCheck:NO];
                    
                    if (self.filterType == PHAssetMediaTypeVideo)
                        [self.selectButton setEnabled:YES];
                    else
                        [self.selectButton setEnabled:(selectedAssetsArray.count > 0)];
                    
                    selectedCell = nil;
                });
            }
        };
        
        [generator generateCGImagesAsynchronouslyForTimes:[NSArray arrayWithObject:[NSValue valueWithCMTime:thumbTime]] completionHandler:handler];
    }
    else
    {
        PHAsset *asset = [assetsArray objectAtIndex:selectedCell.cellIndex];
        
        [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:nil resultHandler:^(AVAsset *avAsset, AVAudioMix *audioMix, NSDictionary *info) {
            
            AVAssetImageGenerator* generator = [[AVAssetImageGenerator alloc] initWithAsset:avAsset];
            generator.appliesPreferredTrackTransform = YES;
            
            CMTime thumbTime = CMTimeMakeWithSeconds(time, avAsset.duration.timescale);
            generator.maximumSize = CGSizeMake(selectedCell.bounds.size.width*2.0f, selectedCell.bounds.size.height*2.0f);
            
            AVAssetImageGeneratorCompletionHandler handler = ^(CMTime requestedTime, CGImageRef im, CMTime actualTime, AVAssetImageGeneratorResult result, NSError* error)
            {
                if (result == AVAssetImageGeneratorSucceeded)
                {
                    UIImage *image = [UIImage imageWithCGImage:im];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        selectedCell.thumbnailImage = image;
                        
                        NSError *error;
                        
                        //Save Custom Thumbnail
                        NSDate *myDate = [NSDate date];
                        NSDateFormatter *df = [[NSDateFormatter alloc] init];
                        [df setDateFormat:@"yyyy-MM-dd-hh-mm-s"];
                        
                        NSString* thumbName = [df stringFromDate:myDate];
                        NSString* thumbnailFileName = [thumbFolderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", thumbName]];
                        
                        if ([localFileManager fileExistsAtPath:thumbnailFileName])
                            [localFileManager removeItemAtPath:thumbnailFileName error:&error ];
                        
                        [UIImagePNGRepresentation(image) writeToFile:thumbnailFileName atomically:YES];
                        
                        
                        //Store Custom Thumbnail file name in plist
                        NSMutableDictionary *plistDict = nil;
                        
                        NSString* plistFileName = [plistFolderPath stringByAppendingPathComponent:@"ThumbFileName.plist"];
                        
                        if (![localFileManager fileExistsAtPath:plistFileName])
                        {
                            [localFileManager createFileAtPath:plistFileName contents:nil attributes:nil];
                            
                            plistDict = [NSMutableDictionary dictionary];
                        }
                        else
                        {
                            plistDict = [[NSMutableDictionary alloc] initWithContentsOfFile:plistFileName];
                            
                            if ([plistDict objectForKey:asset.localIdentifier])
                            {
                                NSString* oldThumbName = [plistDict objectForKey:asset.localIdentifier];
                                NSString* oldThumbFileName = [thumbFolderPath stringByAppendingPathComponent:oldThumbName];
                                
                                if ([localFileManager fileExistsAtPath:oldThumbFileName])
                                    [localFileManager removeItemAtPath:oldThumbFileName error:&error];
                                
                                [plistDict removeObjectForKey:asset.localIdentifier];
                            }
                        }
                        
                        [plistDict setObject:[NSString stringWithFormat:@"%@.png", thumbName] forKey:asset.localIdentifier];
                        [plistDict writeToFile:plistFileName atomically:YES];
                        
                        
                        if (self.customModalView != nil)
                        {
                            [self.customModalView hideCustomModalView];
                            self.customModalView = nil;
                        }
                        
                        [selectedAssetsArray removeAllObjects];
                        [assetsFlagArray replaceObjectAtIndex:selectedCell.cellIndex withObject:[NSNumber numberWithBool:NO]];
                        
                        [selectedCell markSelectedCheck:NO];
                        
                        if (self.filterType == PHAssetMediaTypeVideo)
                            [self.selectButton setEnabled:YES];
                        else
                            [self.selectButton setEnabled:(selectedAssetsArray.count > 0)];
                        
                        selectedCell = nil;
                    });
                }
            };
            
            [generator generateCGImagesAsynchronouslyForTimes:[NSArray arrayWithObject:[NSValue valueWithCMTime:thumbTime]] completionHandler:handler];
        }];
    }
}


#pragma mark -
#pragma mark - YJLVideoPlayerDelegate

-(void) openInProject
{
    if (([self.title isEqualToString:@"Movies"])&&(self.filterType == PHAssetMediaTypeVideo))
    {
        MPMediaItemCollection* item = [assetsArray objectAtIndex:selectedCell.cellIndex];
        
        [selectedAssetsArray addObject:item];
    }
    else
    {
        PHAsset *asset = [assetsArray objectAtIndex:selectedCell.cellIndex];
        
        [selectedAssetsArray addObject:asset];
    }
    
    [assetsFlagArray replaceObjectAtIndex:selectedCell.cellIndex withObject:[NSNumber numberWithBool:YES]];
    
    [selectedCell markSelectedCheck:YES];
    
    if (self.filterType == PHAssetMediaTypeVideo)
        [self.selectButton setEnabled:YES];
    else
        [self.selectButton setEnabled:(selectedAssetsArray.count > 0)];
    
    [self didSelectedAssets];
}


- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    popoverController = nil;
}

- (void)dismissViewControllerAnimated: (BOOL)flag completion: (void (^)(void))completion
{

}


#pragma mark -
#pragma mark - Rename Video

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)  //Ok
    {
        UITextField *textField = [alertView textFieldAtIndex:0];
        
        if ([textField.text isEqualToString:@""])
        {
            return;
        }
        else
        {
            selectedCell.videoNameLabel.text = textField.text;
            
            if (([self.title isEqualToString:@"Movies"])&&(self.filterType == PHAssetMediaTypeVideo))
            {
                MPMediaItemCollection* item = [assetsArray objectAtIndex:selectedCell.cellIndex];
                
                MPMediaItem *representativeItem = [item representativeItem];
                NSNumber *persistentIDNumber = [representativeItem valueForProperty:MPMediaItemPropertyPersistentID];
                NSString* persistentID = [persistentIDNumber stringValue];

                NSMutableDictionary *plistDict = nil;
                
                NSString* plistFileName = [plistFolderPath stringByAppendingPathComponent:@"VideoName.plist"];
                
                if (![localFileManager fileExistsAtPath:plistFileName])
                {
                    [localFileManager createFileAtPath:plistFileName contents:nil attributes:nil];
                    
                    plistDict = [NSMutableDictionary dictionary];
                }
                else
                {
                    plistDict = [[NSMutableDictionary alloc] initWithContentsOfFile:plistFileName];
                    
                    if ([plistDict objectForKey:persistentID])
                    {
                        [plistDict removeObjectForKey:persistentID];
                    }
                }
                
                [plistDict setObject:textField.text forKey:persistentID];
                [plistDict writeToFile:plistFileName atomically:YES];
                
                [self.myCache setObject:textField.text forKey:[NSString stringWithFormat:@"%@-videoFileName", persistentID]];
            }
            else
            {
                PHAsset *asset = [assetsArray objectAtIndex:selectedCell.cellIndex];
                
                NSMutableDictionary *plistDict = nil;
                
                NSString* plistFileName = [plistFolderPath stringByAppendingPathComponent:@"VideoName.plist"];
                
                if (![localFileManager fileExistsAtPath:plistFileName])
                {
                    [localFileManager createFileAtPath:plistFileName contents:nil attributes:nil];
                    
                    plistDict = [NSMutableDictionary dictionary];
                }
                else
                {
                    plistDict = [[NSMutableDictionary alloc] initWithContentsOfFile:plistFileName];
                    
                    if ([plistDict objectForKey:asset.localIdentifier])
                    {
                        [plistDict removeObjectForKey:asset.localIdentifier];
                    }
                }
                
                [plistDict setObject:textField.text forKey:asset.localIdentifier];
                [plistDict writeToFile:plistFileName atomically:YES];
                
                [self.myCache setObject:textField.text forKey:[NSString stringWithFormat:@"%@-videoFileName", asset.localIdentifier]];
            }
        }
    }
}


#pragma mark -
#pragma mark - CustomModalViewDelegate

-(void) didClosedCustomModalView
{
    if (self.videoPlayer)
    {
        [self.videoPlayer freePlayer];
        self.videoPlayer = nil;
    }
    
    if (self.videoThumbMaker)
    {
        [self.videoThumbMaker freePlayer];
        self.videoThumbMaker = nil;
    }
}


#pragma mark -
#pragma mark - Backup Data to iCloud

-(void)saveCustomVideoData
{
    //Save custom video name plist to iCloud
    NSString* plistFileName = [plistFolderPath stringByAppendingPathComponent:@"VideoName.plist"];
    
    BOOL isDirectory = NO;
    BOOL exist = [localFileManager fileExistsAtPath:plistFileName isDirectory:&isDirectory];
    
    if (exist)
    {
        NSURL *containerUbiquitousURL = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
        NSURL *destinationUbiquitousURL = [[containerUbiquitousURL URLByAppendingPathComponent:@"Documents"] URLByAppendingPathComponent:@"VideoName.plist"];
        
        MyCloudDocument *mydoc = [[MyCloudDocument alloc] initWithFileURL:destinationUbiquitousURL];
        NSData *data = [NSData dataWithContentsOfFile:plistFileName];
        mydoc.dataContent = data;
        
        [mydoc saveToURL:[mydoc fileURL] forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success)
         {
             if (success)
             {
                 
             }
             else
             {
                 NSLog(@"Saving failed VideoName.plist to icloud");
             }
         }];
    }
    
    
    //Save thumbnail file name plist to iCloud
    plistFileName = [plistFolderPath stringByAppendingPathComponent:@"ThumbFileName.plist"];
    
    isDirectory = NO;
    exist = [localFileManager fileExistsAtPath:plistFileName isDirectory:&isDirectory];
    
    if (exist)
    {
        NSURL *containerUbiquitousURL = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
        NSURL *destinationUbiquitousURL = [[containerUbiquitousURL URLByAppendingPathComponent:@"Documents"] URLByAppendingPathComponent:@"ThumbFileName.plist"];
        
        MyCloudDocument *mydoc = [[MyCloudDocument alloc] initWithFileURL:destinationUbiquitousURL];
        NSData *data = [NSData dataWithContentsOfFile:plistFileName];
        mydoc.dataContent = data;
        
        [mydoc saveToURL:[mydoc fileURL] forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success)
         {
             if (success)
             {
                 
             }
             else
             {
                 NSLog(@"Saving failed ThumbFileName.plist to icloud");
             }
         }];
    }
    
    
    //Save custom thumbnails to iCloud
    isDirectory = NO;
    exist = [localFileManager fileExistsAtPath:thumbFolderPath isDirectory:&isDirectory];
    
    if (exist)
    {
        NSArray* files = [localFileManager contentsOfDirectoryAtPath:thumbFolderPath error:nil];
        
        for (int i=0; i<files.count; i++)
        {
            NSString* file = [files objectAtIndex:i];
            
            NSString* filePath = [thumbFolderPath stringByAppendingPathComponent:file];
            
            NSURL *containerUbiquitousURL = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
            NSURL *destinationUbiquitousURL = [[containerUbiquitousURL URLByAppendingPathComponent:@"Documents"] URLByAppendingPathComponent:[filePath lastPathComponent]];
            
            MyCloudDocument *mydoc = [[MyCloudDocument alloc] initWithFileURL:destinationUbiquitousURL];
            NSData *data = [NSData dataWithContentsOfFile:filePath];
            mydoc.dataContent = data;
            
            [mydoc saveToURL:[mydoc fileURL] forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success)
             {
                 if (i == (files.count-1))
                 {
                     [[SHKActivityIndicator currentIndicator] hide];
                 }
                 
                 if (success)
                 {
                     
                 }
                 else
                 {
                     NSLog(@"Saving failed %@ to icloud", file);
                 }
             }];
        }
    }
    else
    {
        [[SHKActivityIndicator currentIndicator] hide];
    }
}

#pragma mark Share Delegate
- (void)openInAppActivityDidDismissDocumentInteractionController:(TTOpenInAppActivity*)activity
{
    
}

@end


