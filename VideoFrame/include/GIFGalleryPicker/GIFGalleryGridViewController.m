//
//  GIFGalleryGridViewController.m
//  VideoFrame
//
//  Created by Yinjing Li on 6/18/15.
//  Copyright (c) 2015 Yinjing Li. All rights reserved.
//

#import "GIFGalleryGridViewController.h"
#import "GIFGalleryPickerController.h"
#import "GIFGalleryGridViewCell.h"
#import "SHKActivityIndicator.h"
#import "Definition.h"
#import "UIImageExtras.h"


@import Photos;

@interface GIFGalleryGridViewController ()

@end


@implementation GIFGalleryGridViewController

@synthesize gifGalleryPickerController = _gifGalleryPickerController;

static NSString * const CellReuseIdentifier = @"Cell";
static CGSize GIFGridThumbnailSize;

#define IPHONE_CELL_SIZE 74.0f
#define IPAD_CELL_SIZE 140.0f


- (void)awakeFromNib
{
    self.oldestNewestButton = [[UIBarButtonItem alloc] initWithTitle:@"Oldest" style:UIBarButtonItemStylePlain target:self action:@selector(handleOldestNewestButtonItem:)];
    [self.oldestNewestButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:MYRIADPRO size:18.0f], NSFontAttributeName, [UIColor blackColor], NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];

    self.saveClipboardButton = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(saveGifFromClipboard:)];
    [self.saveClipboardButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:MYRIADPRO size:18.0f], NSFontAttributeName, [UIColor blackColor], NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];

    self.navigationItem.rightBarButtonItems = @[self.oldestNewestButton, self.saveClipboardButton];

    self.cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(handleCancelButtonItem:)];
    [self.cancelButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:MYRIADPRO size:18.0f], NSFontAttributeName, [UIColor blackColor], NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
    
    self.deleteButton = [[UIBarButtonItem alloc] initWithTitle:@"Select" style:UIBarButtonItemStylePlain target:self action:@selector(deleteGifs:)];
    [self.deleteButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:MYRIADPRO size:18.0f], NSFontAttributeName, [UIColor blackColor], NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
    
    self.navigationItem.leftBarButtonItems = @[self.cancelButton, self.deleteButton];
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIImageView* imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    [imageView setImage:[UIImage imageNamed:@"specialistEditBg"]];
    self.collectionView.backgroundView = imageView;

    self.gifGalleryPickerController = (GIFGalleryPickerController*)self.navigationController;

    localFileManager = [NSFileManager defaultManager];
    folderDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Library"];
    folderPath = [folderDir stringByAppendingPathComponent:@"Preferences"];
    gifFolderPath = [folderPath stringByAppendingPathComponent:@"GIFs"];

    BOOL isDirectory = NO;
    BOOL exist = [localFileManager fileExistsAtPath:gifFolderPath isDirectory:&isDirectory];
    
    if (!exist)
    {
        [localFileManager createDirectoryAtPath:gifFolderPath withIntermediateDirectories:NO attributes:nil error:nil];
    }

    //load GIF files
    [self loadGIFsArray];
    
    [[SHKActivityIndicator currentIndicator] performSelectorOnMainThread:@selector(hide) withObject:nil waitUntilDone:YES];

    isDeleteActived = NO;
    
    [selectedCellIndexArray removeAllObjects];
    selectedCellIndexArray = [[NSMutableArray alloc] init];

    self.myCache = [[NSCache alloc] init];
    
    if (_thumbnailQueue != nil)
    {
        [_thumbnailQueue cancelAllOperations];
        _thumbnailQueue = nil;
    }
    
    _thumbnailQueue = [NSOperationQueue mainQueue];
    _thumbnailQueue.maxConcurrentOperationCount = 10;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    [self.myCache removeAllObjects];
}

- (void) freeAll
{
    localFileManager = nil;

    [selectedCellIndexArray removeAllObjects];
    selectedCellIndexArray = nil;
    
    [gifsArray removeAllObjects];
    gifsArray = nil;
    
    [gifsFlagArray removeAllObjects];
    gifsFlagArray = nil;
    
    [self.myCache removeAllObjects];
}

- (void) loadGIFsArray
{
    [gifsArray removeAllObjects];
    gifsArray = nil;
    gifsArray = [[NSMutableArray alloc] init];
    
    NSError *error;
    NSArray* filesArray = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:gifFolderPath error:&error];
    
    if (filesArray.count > 0)
    {
        NSMutableArray* filesAndProperties = [NSMutableArray arrayWithCapacity:[filesArray count]];
        
        for(NSString* file in filesArray)
        {
            error = nil;
            
            NSString* filePath = [gifFolderPath stringByAppendingPathComponent:file];
            NSDictionary* properties = [[NSFileManager defaultManager]
                                        attributesOfItemAtPath:filePath
                                        error:&error];
            NSDate* modDate = [properties objectForKey:NSFileModificationDate];
            
            if(error == nil)
            {
                [filesAndProperties addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                               file, @"path",
                                               modDate, @"lastModDate",
                                               nil]];
            }
        }
        
        NSArray* sortedFiles = [filesAndProperties sortedArrayUsingComparator:
                                ^(id path1, id path2)
                                {
                                    NSComparisonResult comp = [[path2 objectForKey:@"lastModDate"] compare:
                                                               [path1 objectForKey:@"lastModDate"]];
                                    if (comp == NSOrderedDescending)
                                        comp = NSOrderedAscending;
                                    else if(comp == NSOrderedAscending)
                                        comp = NSOrderedDescending;
                                    
                                    return comp;
                                }];
        
        NSArray* reverseArray = sortedFiles.reverseObjectEnumerator.allObjects;
        
        for (int i=0; i<reverseArray.count; i++)
        {
            NSDictionary* dict = [reverseArray objectAtIndex:i];
            NSString* gifName = [dict objectForKey:@"path"];
            NSString* gifPath = [gifFolderPath stringByAppendingPathComponent:gifName];
            [gifsArray addObject:gifPath];
        }
    }
    
    [gifsFlagArray removeAllObjects];
    gifsFlagArray = nil;
    gifsFlagArray = [[NSMutableArray alloc] init];

    for (int i=0; i<gifsArray.count; i++)
    {
        [gifsFlagArray addObject:[NSNumber numberWithBool:NO]];
    }
}

-(BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
	CGFloat scale = [UIScreen mainScreen].scale;
    CGSize cellSize = CGSizeZero;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        cellSize = CGSizeMake(IPHONE_CELL_SIZE, IPHONE_CELL_SIZE);
    else
        cellSize = CGSizeMake(IPAD_CELL_SIZE, IPAD_CELL_SIZE);
    
    ((UICollectionViewFlowLayout *)self.collectionViewLayout).itemSize = cellSize;
    ((UICollectionViewFlowLayout *)self.collectionViewLayout).sectionInset = UIEdgeInsetsMake(5.0f, 5.0f, 5.0f, 5.0f);

	GIFGridThumbnailSize = CGSizeMake(cellSize.width * scale, cellSize.height * scale);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(GIFGridThumbnailSize.width/2.0f, GIFGridThumbnailSize.height/2.0f);
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)handleCancelButtonItem:(id)sender
{
    if (isDeleteActived)
    {
        isDeleteActived = NO;
        self.saveClipboardButton.enabled = YES;
        self.oldestNewestButton.enabled = YES;
        self.deleteButton.enabled = YES;
        
        [self.saveClipboardButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:MYRIADPRO size:18.0f], NSFontAttributeName, [UIColor blackColor], NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
        [self.oldestNewestButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:MYRIADPRO size:18.0f], NSFontAttributeName, [UIColor blackColor], NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
        [self.deleteButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:MYRIADPRO size:18.0f], NSFontAttributeName, [UIColor blackColor], NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
        
        [self.deleteButton setTitle:@"Select"];
        
        if (selectedCellIndexArray.count > 0)
        {
            for (int i=0; i<selectedCellIndexArray.count; i++)
            {
                NSIndexPath* indexPath = [selectedCellIndexArray objectAtIndex:i];
                
                GIFGalleryGridViewCell *cell = (GIFGalleryGridViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
                [cell didSelectedGIF:NO];
                
                [gifsFlagArray replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithBool:NO]];
            }
            
            [selectedCellIndexArray removeAllObjects];
        }
    }
    else
    {
        if ([self.gifGalleryPickerController.gifGalleryDelegate respondsToSelector:@selector(gifGalleryPickerControllerDidCancel:)])
        {
            [self.gifGalleryPickerController.gifGalleryDelegate gifGalleryPickerControllerDidCancel:self.gifGalleryPickerController];
            
            [self freeAll];
        }
    }
}

- (void)handleOldestNewestButtonItem:(id)sender
{
    NSArray* array = gifsArray.reverseObjectEnumerator.allObjects;
    
    [gifsArray removeAllObjects];
    gifsArray = nil;
    gifsArray = [NSMutableArray arrayWithArray:array];
    
    if ([self.oldestNewestButton.title isEqualToString:@"Oldest"])
        [self.oldestNewestButton setTitle:@"Newest"];
    else
        [self.oldestNewestButton setTitle:@"Oldest"];
    
    [self.collectionView reloadData];
}

-(void)saveGifFromClipboard:(id)sender
{
    [[SHKActivityIndicator currentIndicator] displayActivity:(@"Saving...") isLock:YES];
    
    [self performSelector:@selector(saveGif) withObject:nil afterDelay:0.02f];
}

-(void) saveGif
{
    NSURL* gifURL = [UIPasteboard generalPasteboard].URL;
    
    NSString* gifPath = [gifURL path];
    NSString* gifFileName = [gifPath lastPathComponent];
    
    NSData *gifData = [NSData dataWithContentsOfURL:gifURL];
    
    if (AnimatedGifDataIsValid(gifData))
    {
        gifFileName = [NSString stringWithFormat:@"%@.gif", [gifFileName stringByDeletingPathExtension]];
        NSString* gifFilePath = [gifFolderPath stringByAppendingPathComponent:gifFileName];
        [gifData writeToFile:gifFilePath atomically:YES];
        
        [[SHKActivityIndicator currentIndicator] performSelectorOnMainThread:@selector(hide) withObject:nil waitUntilDone:YES];

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Video Dreamer" message:@"Gif saved successfully!"  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil, nil];
        [alert show];
        
        [self loadGIFsArray];
        
        [self.collectionView reloadData];
        
        [[UIPasteboard generalPasteboard] setValue:@"" forPasteboardType:UIPasteboardNameGeneral];
    }
    else
    {
        [[SHKActivityIndicator currentIndicator] performSelectorOnMainThread:@selector(hide) withObject:nil waitUntilDone:YES];

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Video Dreamer" message:@"You need to copy a gif to clipboard!"  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil, nil];
        [alert show];
        
        [[UIPasteboard generalPasteboard] setValue:@"" forPasteboardType:UIPasteboardNameGeneral];
    }
}

-(void)deleteGifs:(id)sender
{
    if (isDeleteActived)
    {
        for (int i=0; i<selectedCellIndexArray.count; i++)
        {
            NSIndexPath* indexPath = [selectedCellIndexArray objectAtIndex:i];
            NSString* gifPath = [gifsArray objectAtIndex:indexPath.row];
            
            if ([localFileManager fileExistsAtPath:gifPath])
                [localFileManager removeItemAtPath:gifPath error:NULL];
            
            GIFGalleryGridViewCell *cell = (GIFGalleryGridViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
            [cell didSelectedGIF:NO];
            
            [self.myCache removeObjectForKey:[gifPath lastPathComponent]];
        }
        
        [selectedCellIndexArray removeAllObjects];
        
        [self loadGIFsArray];
        
        [self.collectionView reloadData];
        
        isDeleteActived = NO;
        self.saveClipboardButton.enabled = YES;
        self.oldestNewestButton.enabled = YES;
        self.deleteButton.enabled = YES;
        
        [self.saveClipboardButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:MYRIADPRO size:18.0f], NSFontAttributeName, [UIColor blackColor], NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
        [self.oldestNewestButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:MYRIADPRO size:18.0f], NSFontAttributeName, [UIColor blackColor], NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
        [self.deleteButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:MYRIADPRO size:18.0f], NSFontAttributeName, [UIColor blackColor], NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
        
        [self.deleteButton setTitle:@"Select"];
    }
    else
    {
        isDeleteActived = YES;
        self.navigationItem.rightBarButtonItem.enabled = NO;

        self.saveClipboardButton.enabled = NO;
        self.oldestNewestButton.enabled = NO;
        self.deleteButton.enabled = NO;
        
        [self.saveClipboardButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:MYRIADPRO size:18.0f], NSFontAttributeName, [UIColor lightGrayColor], NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
        [self.oldestNewestButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:MYRIADPRO size:18.0f], NSFontAttributeName, [UIColor lightGrayColor], NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
        [self.deleteButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:MYRIADPRO size:18.0f], NSFontAttributeName, [UIColor lightGrayColor], NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
        
        [self.deleteButton setTitle:@"Delete"];
    }
}

#pragma mark -
#pragma mark - UICollectionViewDataSource

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 5.0f;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return gifsArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    GIFGalleryGridViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellReuseIdentifier forIndexPath:indexPath];
 
    NSString* gifPath = [gifsArray objectAtIndex:indexPath.row];
    
    UIImage* thumbImage = [self.myCache objectForKey:[gifPath lastPathComponent]];
    
    if (thumbImage)
    {
        [cell setThumbnailImageForGif:thumbImage];
    }
    else
    {
        NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{

            dispatch_async(dispatch_get_main_queue(), ^{

                UIImage* thumbGIf = [[UIImage alloc] initWithContentsOfFile:gifPath];
                CGSize thumbSize = CGSizeZero;
                
                if (thumbGIf.size.width >= thumbGIf.size.height)
                    thumbSize = CGSizeMake(GIFGridThumbnailSize.width, thumbGIf.size.height*GIFGridThumbnailSize.width/thumbGIf.size.width);
                else
                    thumbSize = CGSizeMake(thumbGIf.size.width*GIFGridThumbnailSize.height/thumbGIf.size.height, GIFGridThumbnailSize.height);
                
                thumbGIf = [thumbGIf rescaleGIFImageToSize:thumbSize];
                [cell setThumbnailImageForGif:thumbGIf];
                [self.myCache setObject:thumbGIf forKey:[gifPath lastPathComponent]];
            });

        }];
        
        [_thumbnailQueue addOperation:operation];
    }
    
    NSNumber* flag = [gifsFlagArray objectAtIndex:indexPath.row];
    
    if ([flag boolValue])
    {
        [cell didSelectedGIF:YES];
    }
    else
    {
        [cell didSelectedGIF:NO];
    }

    return cell;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < gifsArray.count)
        return YES;
    else
        return NO;
    
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (isDeleteActived)
    {
        GIFGalleryGridViewCell *cell = (GIFGalleryGridViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
        
        if (cell.isSelected)
        {
            [cell didSelectedGIF:NO];
            
            [gifsFlagArray replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithBool:NO]];
            
            [selectedCellIndexArray removeObject:indexPath];
            
            if (self.deleteButton.enabled && (selectedCellIndexArray.count == 0))
            {
                self.deleteButton.enabled = NO;
                
                [self.deleteButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:MYRIADPRO size:18.0f], NSFontAttributeName, [UIColor lightGrayColor], NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
            }
        }
        else
        {
            [cell didSelectedGIF:YES];

            [gifsFlagArray replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithBool:YES]];
            
            [selectedCellIndexArray addObject:indexPath];
            
            if (!self.deleteButton.enabled)
            {
                self.deleteButton.enabled = YES;
                
                [self.deleteButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:MYRIADPRO size:18.0f], NSFontAttributeName, [UIColor blackColor], NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
            }
        }
    }
    else
    {
        [[SHKActivityIndicator currentIndicator] displayActivity:(@"Loading...") isLock:YES];
        
        if ([self.gifGalleryPickerController.gifGalleryDelegate respondsToSelector:@selector(gifGalleryPickerController:didFinishPickingGifPath:)])
        {
            NSString* gifPath = [gifsArray objectAtIndex:indexPath.row];
            
            [self.gifGalleryPickerController.gifGalleryDelegate gifGalleryPickerController:self.gifGalleryPickerController didFinishPickingGifPath:gifPath];
            
            [self freeAll];
        }
    }
}


@end
