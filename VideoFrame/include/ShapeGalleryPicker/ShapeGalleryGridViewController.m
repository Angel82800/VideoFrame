//
//  AAPLAssetGridViewController.m
//  VideoFrame
//
//  Created by Yinjing Li on 9/22/14.
//  Copyright (c) 2014 Yinjing Li. All rights reserved.
//

#import "ShapeGalleryGridViewController.h"
#import "ShapeGalleryPickerController.h"
#import "ShapeGalleryGridViewCell.h"
#import "SHKActivityIndicator.h"
#import "Definition.h"

@import Photos;


@interface ShapeGalleryGridViewController ()

@end


@implementation ShapeGalleryGridViewController

@synthesize shapeGalleryPickerController = _shapeGalleryPickerController;

static NSString * const CellReuseIdentifier = @"Cell";
static CGSize AssetGridThumbnailSize;

#define IPHONE_CELL_SIZE 74.0f
#define IPAD_CELL_SIZE 140.0f

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIImageView* imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    [imageView setImage:[UIImage imageNamed:@"specialistEditBg"]];
    self.collectionView.backgroundView = imageView;

    self.shapeGalleryPickerController = (ShapeGalleryPickerController*)self.navigationController;
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

	AssetGridThumbnailSize = CGSizeMake(cellSize.width * scale, cellSize.height * scale);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(AssetGridThumbnailSize.width/2.0f, AssetGridThumbnailSize.height/2.0f);
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}


- (IBAction)handleCancelButtonItem:(id)sender
{
    if ([self.shapeGalleryPickerController.shapeGalleryDelegate respondsToSelector:@selector(shapeGalleryPickerControllerDidCancel:)])
    {
        [self.shapeGalleryPickerController.shapeGalleryDelegate shapeGalleryPickerControllerDidCancel:self.shapeGalleryPickerController];
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
    NSInteger count = SHAPES_MAX_COUNT;
    
    return count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ShapeGalleryGridViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellReuseIdentifier forIndexPath:indexPath];
    
    UIImage* image = [UIImage imageNamed:[NSString stringWithFormat:@"shape%d_thumb", (int)indexPath.row]];
    [cell setThumbnailImage:image];
    
    return cell;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < SHAPES_MAX_COUNT)
    {
        return YES;
    }
    else
    {
        return NO;
    }
    
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [[SHKActivityIndicator currentIndicator] displayActivity:(@"Loading...") isLock:YES];

    if ([self.shapeGalleryPickerController.shapeGalleryDelegate respondsToSelector:@selector(shapeGalleryPickerController:didFinishPickingIndex:)])
    {
        [self.shapeGalleryPickerController.shapeGalleryDelegate shapeGalleryPickerController:self.shapeGalleryPickerController didFinishPickingIndex:indexPath.row];
    }
}


@end
