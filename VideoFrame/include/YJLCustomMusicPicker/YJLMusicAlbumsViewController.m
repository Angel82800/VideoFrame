//
//  YJLMusicAlbumsViewController.m
//  VideoFrame
//
//  Created by Yinjing Li on 5/12/14.
//  Copyright (c) 2014 Yinjing Li. All rights reserved.
//

#import "YJLMusicAlbumsViewController.h"
#import "AppDelegate.h"
#import "YJLCustomMusicController.h"
#import "MusicAssetCell.h"
#import "MusicCell.h"
#import "YJLActionMenu.h"
#import "Definition.h"


#define PLAYLISTS 0
#define ARTISTS 1
#define SONGS 2
#define ALBUMS 3
#define GENRES 4
#define LIBRARY 5


@interface YJLMusicAlbumsViewController ()  <UITableViewDelegate, UITableViewDataSource, UITabBarDelegate, MusicCellDelegate>
{
    BOOL _fetchedFirstTime;
    BOOL sortByDuration;

    NSInteger collectionSelectedIndex;
    
    UIActivityIndicatorView *_indicatorView;
    
    NSArray* collectionsArray;
    NSArray* songsArray;
    NSMutableArray* musicArray;
}

@end


@implementation YJLMusicAlbumsViewController


- (void)viewDidLoad
{
    [super viewDidLoad];

    collectionSelectedIndex = PLAYLISTS;
    sortByDuration = YES;
    isEdit = NO;
    
    [self _configureMusicLoader];
    [self _configureAlbumsLoader:PLAYLISTS];
    [self _configureNavigationBarButtons];
    [self _setupViews];
    
    self.title = @"Playlists";
}

-(BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)_configureNavigationBarButtons
{
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(onDidCancel)];
    [self.navigationItem setLeftBarButtonItem:cancelButton];
    self.navigationItem.leftBarButtonItem.tag = 1;
}

- (void)_configureRightButton
{
    _sortBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20 , 20)];
    [_sortBtn setImage:[UIImage imageNamed:@"sort_down"] forState:UIControlStateNormal];
    [_sortBtn addTarget:self action:@selector(onShowSortMenu:) forControlEvents:UIControlEventTouchUpInside];
    _sortBtn.tag = 1;

    UIBarButtonItem *sortButton = [[UIBarButtonItem alloc] initWithCustomView:_sortBtn];
    
    [self.navigationItem setRightBarButtonItem:sortButton];

    
    NSSortDescriptor *sorter = [NSSortDescriptor sortDescriptorWithKey:MPMediaItemPropertyPlaybackDuration
                                                             ascending:YES];
    NSArray *sortedSongsArray = [songsArray sortedArrayUsingDescriptors:@[sorter]];
    songsArray = [NSArray arrayWithArray:sortedSongsArray];
}

-(void) _configureEditButton
{
    _editBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50 , 20)];
    [_editBtn setTitle:@"Edit" forState:UIControlStateNormal];
    [_editBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [_editBtn setBackgroundColor:[UIColor clearColor]];
    [_editBtn addTarget:self action:@selector(onEdit:) forControlEvents:UIControlEventTouchUpInside];
    _editBtn.tag = 1;
    
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithCustomView:_editBtn];
    [self.navigationItem setRightBarButtonItem:editButton];
    
    if (musicArray.count == 0)
    {
        _editBtn.enabled = NO;
    }
}

- (void)_setupViews
{
    [self.view setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    /* Tabbar */
    UITabBarItem* playlistsItem = [[UITabBarItem alloc] initWithTitle:@"Playlists" image:[UIImage imageNamed:@"playlists"] tag:PLAYLISTS];
    UITabBarItem* artistsItem = [[UITabBarItem alloc] initWithTitle:@"Artists" image:[UIImage imageNamed:@"artists"] tag:ARTISTS];
    UITabBarItem* songsItem = [[UITabBarItem alloc] initWithTitle:@"Songs" image:[UIImage imageNamed:@"songs"] tag:SONGS];
    UITabBarItem* albumsItem = [[UITabBarItem alloc] initWithTitle:@"Albums" image:[UIImage imageNamed:@"albums"] tag:ALBUMS];
    UITabBarItem* genresItem = [[UITabBarItem alloc] initWithTitle:@"Genres" image:[UIImage imageNamed:@"genres"] tag:GENRES];
    UITabBarItem* libraryItem = [[UITabBarItem alloc] initWithTitle:@"Library" image:[UIImage imageNamed:@"library"] tag:LIBRARY];
    
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary: [[UIBarButtonItem appearance] titleTextAttributesForState:UIControlStateNormal]];
    [attributes setValue:[UIFont fontWithName:MYRIADPRO size:[UIFont systemFontSize]] forKey:NSFontAttributeName];
    [playlistsItem setTitleTextAttributes:attributes forState:UIControlStateNormal];
    [artistsItem setTitleTextAttributes:attributes forState:UIControlStateNormal];
    [songsItem setTitleTextAttributes:attributes forState:UIControlStateNormal];
    [albumsItem setTitleTextAttributes:attributes forState:UIControlStateNormal];
    [genresItem setTitleTextAttributes:attributes forState:UIControlStateNormal];
    [libraryItem setTitleTextAttributes:attributes forState:UIControlStateNormal];
    
    CGRect frame = self.view.bounds;
    if (([[[UIDevice currentDevice] systemVersion] compare:@"7.0" options:NSNumericSearch] == NSOrderedAscending))
    {
        AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
        frame.size.height -= CGRectGetHeight(appDelegate.navigationController.navigationBar.frame);
    }

    _albumsTabbar = [[UITabBar alloc] initWithFrame:CGRectMake(0, frame.size.height - 55.0f, frame.size.width, 50)];
    [_albumsTabbar setAutoresizingMask:(UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth)];
    _albumsTabbar.delegate = self;
    [_albumsTabbar setItems:@[playlistsItem, artistsItem, songsItem, albumsItem, genresItem, libraryItem]];
    [_albumsTabbar setTintColor:[UIColor redColor]];
    [self.view addSubview:_albumsTabbar];
    [_albumsTabbar setSelectedItem:playlistsItem];

    /* table */
    _collectionTableView = [self newTableView];
    [self.view addSubview:_collectionTableView];
    _collectionTableView.tag = 0;
    
    UIImageView* imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    [imageView setImage:[UIImage imageNamed:@"specialistEditBg"]];
    _collectionTableView.backgroundView = imageView;


    _musicTableView = [self newTableView];
    [self.view addSubview:_musicTableView];
    CGFloat max = self.view.frame.size.width >= self.view.frame.size.height ? self.view.frame.size.width : self.view.frame.size.height;
    _musicTableView.frame = CGRectMake(max, _musicTableView.frame.origin.y, _musicTableView.frame.size.width, _musicTableView.frame.size.height);
    _musicTableView.tag = 1;
    _musicTableView.hidden = YES;
    
    UIImageView* imageView_ = [[UIImageView alloc] initWithFrame:self.view.bounds];
    [imageView_ setImage:[UIImage imageNamed:@"specialistEditBg"]];
    _musicTableView.backgroundView = imageView_;
}

- (UITableView *)newTableView
{
    CGRect frame = self.view.bounds;
    
    if (([[[UIDevice currentDevice] systemVersion] compare:@"7.0" options:NSNumericSearch] == NSOrderedAscending))
    {
        AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
        frame.size.height -= CGRectGetHeight(appDelegate.navigationController.navigationBar.frame);
    }
    else
    {
        AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
        frame.origin.y = appDelegate.navigationController.navigationBar.frame.size.height;
        frame.size.height -= CGRectGetHeight(appDelegate.navigationController.navigationBar.frame);
    }
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, frame.origin.y, frame.size.width, frame.size.height - _albumsTabbar.frame.size.height) style:UITableViewStylePlain];
    [tableView setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
    [tableView setDelegate:self];
    [tableView setDataSource:self];
    
    return tableView;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}


#pragma mark -
#pragma mark - Actions

- (void)onDidCancel
{
    if (self.navigationItem.leftBarButtonItem.tag == 1)
    {
        if ([self.delegate respondsToSelector:@selector(musicAlbumsViewControllerDidCancel)]) {
            [self.delegate musicAlbumsViewControllerDidCancel];
        }
    }
    else if (self.navigationItem.leftBarButtonItem.tag == 2)
    {
        [self _configureAlbumsLoader:collectionSelectedIndex];
        [_collectionTableView reloadData];

        self.navigationItem.leftBarButtonItem.tag = 1;
        [self.navigationItem.leftBarButtonItem setTitle:@"Cancel"];
        self.title = self.albumsTabbar.selectedItem.title;
        
        self.navigationItem.rightBarButtonItem = nil;
        
        [UIView animateWithDuration:0.2f animations:^{
            CGFloat max = self.view.frame.size.width >= self.view.frame.size.height ? self.view.frame.size.width : self.view.frame.size.height;
            _musicTableView.frame = CGRectMake(max, _musicTableView.frame.origin.y, _musicTableView.frame.size.width, _musicTableView.frame.size.height);
        } completion:^(BOOL finished) {
            _musicTableView.hidden = YES;
            _collectionTableView.userInteractionEnabled = YES;
        }];
    }
}

- (void)onShowSortMenu:(id)sender
{
    NSArray *menuItems =
    @[
      [YJLActionMenuItem menuItem:@"Sort by duration"
                     image:nil
                    target:self
                    action:@selector(onSortByDuration)],
      
      [YJLActionMenuItem menuItem:@"Sort by alphabetical"
                     image:nil
                    target:self
                    action:@selector(onSortByAlphabetical)],
      ];
    
    
    CGRect frame = [_sortBtn convertRect:_sortBtn.bounds toView:self.view];
    [YJLActionMenu showMenuInView:self.navigationController.view
                  fromRect:frame
                 menuItems:menuItems isWhiteBG:NO];
}

- (void)onSortByDuration
{
    if (_sortBtn.tag == 1)
    {
        _sortBtn.tag = 2;
        [_sortBtn setImage:[UIImage imageNamed:@"sort_up"] forState:UIControlStateNormal];
        
        NSSortDescriptor *sorter = [NSSortDescriptor sortDescriptorWithKey:MPMediaItemPropertyPlaybackDuration
                                                                 ascending:NO];
        NSArray *sortedSongsArray = [songsArray sortedArrayUsingDescriptors:@[sorter]];
        songsArray = [NSArray arrayWithArray:sortedSongsArray];
        
        [_musicTableView reloadData];
    }
    else if (_sortBtn.tag == 2)
    {
        _sortBtn.tag = 1;
        [_sortBtn setImage:[UIImage imageNamed:@"sort_down"] forState:UIControlStateNormal];
        
        NSSortDescriptor *sorter = [NSSortDescriptor sortDescriptorWithKey:MPMediaItemPropertyPlaybackDuration
                                                                 ascending:YES];
        NSArray *sortedSongsArray = [songsArray sortedArrayUsingDescriptors:@[sorter]];
        songsArray = [NSArray arrayWithArray:sortedSongsArray];

        [_musicTableView reloadData];
    }
}

- (void)onSortByAlphabetical
{
    if (_sortBtn.tag == 1)
    {
        _sortBtn.tag = 2;
        [_sortBtn setImage:[UIImage imageNamed:@"sort_up"] forState:UIControlStateNormal];
        
        NSSortDescriptor *sorter = [NSSortDescriptor sortDescriptorWithKey:MPMediaItemPropertyTitle
                                                                 ascending:NO];
        NSArray *sortedSongsArray = [songsArray sortedArrayUsingDescriptors:@[sorter]];
        songsArray = [NSArray arrayWithArray:sortedSongsArray];
        
        [_musicTableView reloadData];
    }
    else if (_sortBtn.tag == 2)
    {
        _sortBtn.tag = 1;
        [_sortBtn setImage:[UIImage imageNamed:@"sort_down"] forState:UIControlStateNormal];
        
        NSSortDescriptor *sorter = [NSSortDescriptor sortDescriptorWithKey:MPMediaItemPropertyTitle
                                                                 ascending:YES];
        NSArray *sortedSongsArray = [songsArray sortedArrayUsingDescriptors:@[sorter]];
        songsArray = [NSArray arrayWithArray:sortedSongsArray];
        
        [_musicTableView reloadData];
    }
}

-(void) onEdit:(id) sender
{
    if ([sender tag] == 1)
    {
        if (musicArray.count > 0)
        {
            isEdit = YES;
            
            [_editBtn setTitle:@"Done" forState:UIControlStateNormal];
            _editBtn.tag = 2;
            
            [_musicTableView setEditing:YES animated:YES];
        }
    }
    else if ([sender tag] == 2)
    {
        isEdit = NO;
        
        [_editBtn setTitle:@"Edit" forState:UIControlStateNormal];
        _editBtn.tag = 1;
        
        [_musicTableView setEditing:NO animated:YES];
    }
    
    [_musicTableView reloadData];
}


#pragma mark -
#pragma mark - Configuration

- (void)_configureAlbumsLoader:(NSInteger) index
{
    MPMediaQuery* query = nil;
    collectionsArray = nil;
    
    switch (index)
    {
        case PLAYLISTS:
            query = [MPMediaQuery playlistsQuery];
            [query addFilterPredicate:[MPMediaPropertyPredicate predicateWithValue:[NSNumber numberWithBool:NO] forProperty:MPMediaItemPropertyIsCloudItem]];
            collectionsArray = [query collections];
            break;
        case ARTISTS:
            query = [MPMediaQuery artistsQuery];
            [query addFilterPredicate:[MPMediaPropertyPredicate predicateWithValue:[NSNumber numberWithBool:NO] forProperty:MPMediaItemPropertyIsCloudItem]];
            collectionsArray = [query collections];
            break;
        case SONGS:
            query = [MPMediaQuery songsQuery];
            [query addFilterPredicate:[MPMediaPropertyPredicate predicateWithValue:[NSNumber numberWithBool:NO] forProperty:MPMediaItemPropertyIsCloudItem]];
            collectionsArray = [query items];
            songsArray = [query items];
            break;
        case ALBUMS:
            query = [MPMediaQuery albumsQuery];
            [query addFilterPredicate:[MPMediaPropertyPredicate predicateWithValue:[NSNumber numberWithBool:NO] forProperty:MPMediaItemPropertyIsCloudItem]];
            collectionsArray = [query collections];
            break;
        case GENRES:
            query = [MPMediaQuery genresQuery];
            [query addFilterPredicate:[MPMediaPropertyPredicate predicateWithValue:[NSNumber numberWithBool:NO] forProperty:MPMediaItemPropertyIsCloudItem]];
            collectionsArray = [query collections];
            break;
            
        default:
            break;
    }
}

- (void)_configureSongsLoader:(int) index
{
    songsArray = nil;
    
    switch (collectionSelectedIndex) {
        case PLAYLISTS:
        {
            MPMediaPlaylist* playlist = [collectionsArray objectAtIndex:index];
            
            NSMutableArray* _array = [[NSMutableArray alloc] init];
            NSArray* array = [playlist items];
            
            for (MPMediaItemCollection* item in array)
            {
                MPMediaItem *representativeItem = [item representativeItem];
                
                if(representativeItem.mediaType == MPMediaTypeMusic)
                {
                    [_array addObject:item];
                }
            }
            
            songsArray = [NSArray arrayWithArray:_array];
        }
            break;
        case ARTISTS:
        {
            MPMediaItemCollection* item = [collectionsArray objectAtIndex:index];
            songsArray = [item items];
        }
            break;
        case SONGS:
        {
            MPMediaQuery* query = [MPMediaQuery songsQuery];
            [query addFilterPredicate:[MPMediaPropertyPredicate predicateWithValue:[NSNumber numberWithBool:NO] forProperty:MPMediaItemPropertyIsCloudItem]];
            songsArray = [query items];
        }
            break;
        case ALBUMS:
        {
            MPMediaItemCollection* item = [collectionsArray objectAtIndex:index];
            songsArray = [item items];
        }
            break;
        case GENRES:
        {
            MPMediaItemCollection* item = [collectionsArray objectAtIndex:index];
            songsArray = [item items];
        }
            break;
            
        default:
            break;
    }
}

-(void) _configureMusicLoader
{
    [musicArray removeAllObjects];
    musicArray = nil;
    
    musicArray = [[NSMutableArray alloc] init];
    
    NSFileManager *localFileManager = [NSFileManager defaultManager];
    NSString *folderDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Library"];
    NSString *folderPath = [folderDir stringByAppendingPathComponent:@"Music Library"];
    
    NSArray* files = [localFileManager contentsOfDirectoryAtPath:folderPath error:nil];

    for (NSString* filePath in files)
    {
        NSURL* mediaUrl = [NSURL fileURLWithPath:[folderPath stringByAppendingPathComponent:filePath]];
        [musicArray addObject:mediaUrl];
    }

    localFileManager = nil;

}

- (NSString*) getCollectionName:(NSInteger) index
{
    NSString* collectionName = nil;
    
    switch (collectionSelectedIndex)
    {
        case PLAYLISTS:
            collectionName = [[collectionsArray objectAtIndex:index] valueForProperty:MPMediaPlaylistPropertyName];
            break;
        case ARTISTS:
        {
            MPMediaItemCollection* item = [collectionsArray objectAtIndex:index];
            MPMediaItem *representativeItem = [item representativeItem];
            collectionName = [representativeItem valueForProperty:MPMediaItemPropertyArtist];
        }
            break;
        case ALBUMS:
        {
            MPMediaItemCollection* item = [collectionsArray objectAtIndex:index];
            MPMediaItem *representativeItem = [item representativeItem];
            collectionName = [representativeItem valueForProperty:MPMediaItemPropertyAlbumArtist];
        }
            break;
        case GENRES:
        {
            MPMediaItemCollection* item = [collectionsArray objectAtIndex:index];
            MPMediaItem *representativeItem = [item representativeItem];
            collectionName = [representativeItem valueForProperty:MPMediaItemPropertyGenre];
        }
            break;
            
        default:
            break;
    }
    
    return collectionName;
}

- (NSInteger) getCollectionCount:(NSInteger) index
{
    NSInteger count = 0;
    
    switch (collectionSelectedIndex)
    {
        case PLAYLISTS:
        {
            MPMediaPlaylist* playlist = [collectionsArray objectAtIndex:index];
            
            NSArray* array = [playlist items];
            
            for (MPMediaItemCollection* item in array)
            {
                MPMediaItem *representativeItem = [item representativeItem];

                if(representativeItem.mediaType == MPMediaTypeMusic)
                {
                    count++;
                }
            }
        }
            break;
        case ARTISTS:
        {
            MPMediaItemCollection* item = [collectionsArray objectAtIndex:index];
            count = item.count;
        }
            break;
        case ALBUMS:
        {
            MPMediaItemCollection* item = [collectionsArray objectAtIndex:index];
            count = item.count;
        }
            break;
        case GENRES:
        {
            MPMediaItemCollection* item = [collectionsArray objectAtIndex:index];
            count = item.count;
        }
            break;
            
        default:
            break;
    }
    
    return count;
}

- (NSString*) getSongName:(NSInteger)index
{
    NSString* songName = nil;
    MPMediaItemCollection* item = [songsArray objectAtIndex:index];
    MPMediaItem *representativeItem = [item representativeItem];
    songName = [representativeItem valueForProperty:MPMediaItemPropertyTitle];

    return songName;
}

- (NSString*) getSongDuration:(NSInteger)index
{
    MPMediaItemCollection* item = [songsArray objectAtIndex:index];
    MPMediaItem *representativeItem = [item representativeItem];
    NSNumber* duration=[representativeItem valueForProperty:MPMediaItemPropertyPlaybackDuration];
    
    CGFloat dur = [duration floatValue];
    int min = (int)(dur / 60.0f);
    int sec = (int)(dur - min*60);
    
    NSString* durationStr = [NSString stringWithFormat:@"%d:%02d", min, sec];

    return durationStr;
}


#pragma mark -
#pragma mark - UITabBarDelegate methods

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    self.title = item.title;
    collectionSelectedIndex = item.tag;
    
    isEdit = NO;
    
    [_editBtn setTitle:@"Edit" forState:UIControlStateNormal];
    _editBtn.tag = 1;
    
    [_musicTableView setEditing:NO animated:YES];

    [self _configureAlbumsLoader:collectionSelectedIndex];

    if (collectionSelectedIndex == LIBRARY)
    {
        [self _configureEditButton];

        [self.musicTableView reloadData];
        
        _musicTableView.frame = CGRectMake(0, _musicTableView.frame.origin.y, _musicTableView.frame.size.width, _musicTableView.frame.size.height);
        _musicTableView.hidden = NO;
        _collectionTableView.hidden = YES;
        
        self.navigationItem.leftBarButtonItem.tag = 1;
        [self.navigationItem.leftBarButtonItem setTitle:@"Cancel"];
    }
    else if (collectionSelectedIndex == SONGS)
    {
        [self _configureRightButton];
        
        [self.musicTableView reloadData];
        
        _musicTableView.frame = CGRectMake(0, _musicTableView.frame.origin.y, _musicTableView.frame.size.width, _musicTableView.frame.size.height);
        _musicTableView.hidden = NO;
        _collectionTableView.hidden = YES;
        
        self.navigationItem.leftBarButtonItem.tag = 1;
        [self.navigationItem.leftBarButtonItem setTitle:@"Cancel"];
    }
    else
    {
        self.navigationItem.rightBarButtonItems = nil;
        
        [self.collectionTableView reloadData];
        _collectionTableView.hidden = NO;
        _collectionTableView.userInteractionEnabled = YES;
        
        CGFloat max = self.view.frame.size.width >= self.view.frame.size.height ? self.view.frame.size.width : self.view.frame.size.height;
        _musicTableView.frame = CGRectMake(max, _musicTableView.frame.origin.y, _musicTableView.frame.size.width, _musicTableView.frame.size.height);
        _musicTableView.hidden = YES;
        
        self.navigationItem.leftBarButtonItem.tag = 1;
        [self.navigationItem.leftBarButtonItem setTitle:@"Cancel"];
    }
}


#pragma mark -
#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger i=0;
    
    if (tableView.tag == 0)
    {
        i = collectionsArray.count ? : 1;
    }
    else
    {
        if (collectionSelectedIndex == LIBRARY)
            i = musicArray.count ? : 1;
        else
            i = songsArray.count ? : 1;
    }
    
    return i;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0.0f;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        height = 44.0f;
    else
        height = 54.0f;
    
    return height;
}


static NSString *const toAssetSegue = @"ToAssets";
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == 0)//asset table
    {
        BOOL showAlbumCell = collectionsArray.count > 0;
        
        if (showAlbumCell>0)
        {
            static NSString *CellIdentifier = @"Cell";
            
            MusicAssetCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (cell == nil)
            {
                cell = [[MusicAssetCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
                cell.selectionStyle = UITableViewCellSelectionStyleDefault;
                [cell.textLabel setText:[self getCollectionName:indexPath.row]];
                [cell.textLabel setFont:[UIFont fontWithName:MYRIADPRO size:[UIFont systemFontSize]]];
                [cell.detailTextLabel setFont:[UIFont fontWithName:MYRIADPRO size:[UIFont systemFontSize]]];
                
                int count = (int)[self getCollectionCount:indexPath.row];
                
                if (count == 0)
                {
                    [cell.detailTextLabel setText:@"no songs"];
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
                else
                {
                    [cell.detailTextLabel setText:[NSString stringWithFormat:@"%d songs", count]];
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                }
            }
            else
            {
                [cell.textLabel setText:[self getCollectionName:indexPath.row]];

                int count = (int)[self getCollectionCount:indexPath.row];
                
                if (count == 0)
                {
                    [cell.detailTextLabel setText:@"no songs"];
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
                else
                {
                    [cell.detailTextLabel setText:[NSString stringWithFormat:@"%d songs", count]];
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                }
            }
            
            return cell;
        }
        else
        {
            static NSString *CellNoneIdentifier = @"Cell_None";
            
            MusicAssetCell *cell = [tableView dequeueReusableCellWithIdentifier:CellNoneIdentifier];
            
            if (cell == nil)
            {
                cell = [[MusicAssetCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellNoneIdentifier];
                cell.selectionStyle = UITableViewCellSelectionStyleDefault;
                cell.accessoryType = UITableViewCellAccessoryNone;
                [cell.textLabel setText:[NSString stringWithFormat:@"%@ have not a content.", _albumsTabbar.selectedItem.title]];
                [cell.textLabel setFont:[UIFont fontWithName:MYRIADPRO size:[UIFont systemFontSize]]];
                [cell.detailTextLabel setFont:[UIFont fontWithName:MYRIADPRO size:[UIFont systemFontSize]]];
            }
            else
            {
                cell.accessoryType = UITableViewCellAccessoryNone;
                [cell.textLabel setText:[NSString stringWithFormat:@"%@ have not a content.", _albumsTabbar.selectedItem.title]];
            }
            
            return cell;
        }
    }
    else if (tableView.tag == 1)//music table
    {
        if (collectionSelectedIndex == LIBRARY)
        {
            BOOL showSongsCell = musicArray.count > 0;
            
            if (showSongsCell > 0)
            {
                static NSString *CellIdentifier = @"Cell";
                
                MusicCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                
                if (cell == nil)
                {
                    cell = [[MusicCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
                    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
                    cell.delegate = self;
                    
                    NSURL* musicUrl = [musicArray objectAtIndex:indexPath.row];
                    NSString* musicName = [musicUrl lastPathComponent];
                    
                    NSRange range = [musicName rangeOfString:@".m4a"];
                    if (range.length != 0)
                    {
                        musicName = [musicName substringToIndex:range.location];
                    }
                    
                    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:musicUrl options:nil];
                    CGFloat duration = asset.duration.value / asset.duration.timescale;
                    
                    int min = (int)(duration / 60.0f);
                    int sec = (int)(duration - min*60);
                    NSString* durationStr = [NSString stringWithFormat:@"%d:%02d", min, sec];

                    [cell.detailTextLabel setText:durationStr];
                    [cell.textLabel setFont:[UIFont fontWithName:MYRIADPRO size:[UIFont systemFontSize]]];
                    [cell.detailTextLabel setFont:[UIFont fontWithName:MYRIADPRO size:[UIFont systemFontSize]]];
                    
                    if (isEdit)
                    {
                        [cell.nameTextField setText:musicName];
                        cell.nameTextField.frame = CGRectMake(50.0f, 0.0f, cell.frame.size.width - 50.0f - cell.detailTextLabel.frame.size.width, cell.frame.size.height);
                        cell.nameTextField.font = cell.textLabel.font;
                        cell.nameTextField.userInteractionEnabled = YES;
                        [cell.textLabel setText:@""];
                    }
                    else
                    {
                        [cell.textLabel setText:musicName];
                        cell.nameTextField.frame = CGRectMake(50.0f, 0.0f, cell.frame.size.width - 50.0f - cell.detailTextLabel.frame.size.width, cell.frame.size.height);
                        [cell.nameTextField setText:@""];
                        cell.nameTextField.userInteractionEnabled = NO;
                    }
                    
                    cell.originalName = musicName;
                }
                else
                {
                    NSURL* musicUrl = [musicArray objectAtIndex:indexPath.row];
                    NSString* musicName = [musicUrl lastPathComponent];
                    
                    NSRange range = [musicName rangeOfString:@".m4a"];
                    if (range.length != 0)
                    {
                        musicName = [musicName substringToIndex:range.location];
                    }
                    
                    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:musicUrl options:nil];
                    CGFloat duration = asset.duration.value / asset.duration.timescale;
                    
                    int min = (int)(duration / 60.0f);
                    int sec = (int)(duration - min*60);
                    NSString* durationStr = [NSString stringWithFormat:@"%d:%02d", min, sec];
                    
                    [cell.detailTextLabel setText:durationStr];
                    
                    if (isEdit)
                    {
                        [cell.nameTextField setText:musicName];
                        cell.nameTextField.frame = CGRectMake(50.0f, 0.0f, cell.frame.size.width - 50.0f - cell.detailTextLabel.frame.size.width, cell.frame.size.height);
                        cell.nameTextField.font = cell.textLabel.font;
                        cell.nameTextField.userInteractionEnabled = YES;
                        [cell.textLabel setText:@""];
                    }
                    else
                    {
                        [cell.textLabel setText:musicName];
                        cell.nameTextField.frame = CGRectMake(50.0f, 0.0f, cell.frame.size.width - 50.0f - cell.detailTextLabel.frame.size.width, cell.frame.size.height);
                        [cell.nameTextField setText:@""];
                        cell.nameTextField.userInteractionEnabled = NO;
                    }
                    
                    cell.originalName = musicName;
                }
                
                return cell;
            }
            else
            {
                static NSString *CellNoneIdentifier = @"Cell_None";
                
                MusicCell *cell = [tableView dequeueReusableCellWithIdentifier:CellNoneIdentifier];
                
                if (cell == nil)
                {
                    cell = [[MusicCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellNoneIdentifier];
                    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
                    [cell.textLabel setText:[NSString stringWithFormat:@"%@ have not a content.", _albumsTabbar.selectedItem.title]];
                    [cell.textLabel setFont:[UIFont fontWithName:MYRIADPRO size:[UIFont systemFontSize]]];
                    [cell.detailTextLabel setFont:[UIFont fontWithName:MYRIADPRO size:[UIFont systemFontSize]]];
                    
                    [cell.nameTextField setText:@""];
                    cell.nameTextField.frame = CGRectMake(50.0f, 0.0f, cell.frame.size.width - 50.0f - cell.detailTextLabel.frame.size.width, cell.frame.size.height);
                }
                else
                {
                    [cell.textLabel setText:[NSString stringWithFormat:@"%@ have not a content.", _albumsTabbar.selectedItem.title]];
                    
                    [cell.nameTextField setText:@""];
                    cell.nameTextField.frame = CGRectMake(50.0f, 0.0f, cell.frame.size.width - 50.0f - cell.detailTextLabel.frame.size.width, cell.frame.size.height);
                }
                
                cell.originalName = @"";
                
                return cell;
            }
        }
        else
        {
            BOOL showSongsCell = songsArray.count > 0;
            
            if (showSongsCell > 0)
            {
                static NSString *CellIdentifier = @"Cell";
                
                MusicCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                
                if (cell == nil)
                {
                    cell = [[MusicCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
                    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
                    [cell.textLabel setText:[self getSongName:indexPath.row]];
                    [cell.detailTextLabel setText:[self getSongDuration:indexPath.row]];
                    [cell.textLabel setFont:[UIFont fontWithName:MYRIADPRO size:[UIFont systemFontSize]]];
                    [cell.detailTextLabel setFont:[UIFont fontWithName:MYRIADPRO size:[UIFont systemFontSize]]];
                }
                else
                {
                    [cell.textLabel setText:[self getSongName:indexPath.row]];
                    [cell.detailTextLabel setText:[self getSongDuration:indexPath.row]];
                }
                
                [cell.nameTextField setText:@""];
                cell.nameTextField.frame = CGRectMake(50.0f, 0.0f, cell.frame.size.width - 50.0f - cell.detailTextLabel.frame.size.width, cell.frame.size.height);

                return cell;
            }
            else
            {
                static NSString *CellNoneIdentifier = @"Cell_None";
                
                MusicCell *cell = [tableView dequeueReusableCellWithIdentifier:CellNoneIdentifier];
                
                if (cell == nil)
                {
                    cell = [[MusicCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellNoneIdentifier];
                    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
                    [cell.textLabel setText:[NSString stringWithFormat:@"%@ have not a content.", _albumsTabbar.selectedItem.title]];
                    [cell.textLabel setFont:[UIFont fontWithName:MYRIADPRO size:[UIFont systemFontSize]]];
                    [cell.detailTextLabel setFont:[UIFont fontWithName:MYRIADPRO size:[UIFont systemFontSize]]];
                }
                else
                {
                    [cell.textLabel setText:[NSString stringWithFormat:@"%@ have not a content.", _albumsTabbar.selectedItem.title]];
                }
                
                [cell.nameTextField setText:@""];
                cell.nameTextField.frame = CGRectMake(50.0f, 0.0f, cell.frame.size.width - 50.0f - cell.detailTextLabel.frame.size.width, cell.frame.size.height);
                
                return cell;
            }
        }
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ((collectionsArray.count>0) && (tableView.tag == 0))
    {
        if ([self getCollectionCount:indexPath.row] > 0)
        {
            [self.navigationItem.leftBarButtonItem setTitle:[NSString stringWithFormat:@"<%@", self.title]];
            self.title = [self getCollectionName:indexPath.row];
            self.navigationItem.leftBarButtonItem.tag = 2;
            
            [self _configureSongsLoader:(int)indexPath.row];
            
            [self _configureRightButton];
            
            [self.musicTableView reloadData];
            
            _musicTableView.hidden = NO;
            _collectionTableView.userInteractionEnabled = NO;
            
            [UIView animateWithDuration:0.2f animations:^{
                _musicTableView.frame = CGRectMake(0, _musicTableView.frame.origin.y, _musicTableView.frame.size.width, _musicTableView.frame.size.height);
            }];
        }
    }
    else if (((songsArray.count>0)&&(tableView.tag == 1))||((musicArray.count>0)&&(tableView.tag == 1)))
    {
        if (collectionSelectedIndex == LIBRARY)
        {
            self.assetUrl = [musicArray objectAtIndex:indexPath.row];
            
            if (([self.delegate respondsToSelector:@selector(musicSelected:)]) && (self.assetUrl != nil))
            {
                [self.delegate musicSelected:self.assetUrl];
            }
            else if (self.assetUrl == nil)
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Video Dreamer" message:@"You can`t use this music. Please use this music after download music from the iTunes Store."  delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
            }
        }
        else
        {
            MPMediaItemCollection* item = [songsArray objectAtIndex:indexPath.row];
            MPMediaItem *representativeItem = [item representativeItem];
            self.assetUrl = [representativeItem valueForProperty:MPMediaItemPropertyAssetURL];
            
            if (([self.delegate respondsToSelector:@selector(musicSelected:)]) && (self.assetUrl != nil))
            {
                [self.delegate musicSelected:self.assetUrl];
            }
            else if (self.assetUrl == nil)
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Video Dreamer" message:@"You can`t use this music. Please use this music after download music from the iTunes Store."  delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
            }
        }
    }
}


- (void)tableView:(UITableView *)tableview commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ((collectionSelectedIndex == LIBRARY)&&(tableview.tag == 1)&&(editingStyle == UITableViewCellEditingStyleDelete))
    {
        NSFileManager *localFileManager = [NSFileManager defaultManager];
        NSString *folderDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Library"];
        NSString *folderPath = [folderDir stringByAppendingPathComponent:@"Music Library"];
        
        NSURL* musicUrl = [musicArray objectAtIndex:indexPath.row];
        
        NSString *filename = [folderPath stringByAppendingPathComponent:[musicUrl lastPathComponent]];

        [localFileManager removeItemAtPath:filename error:NULL];
        
        [musicArray removeObjectAtIndex:indexPath.row];

        localFileManager = nil;
        
        [_musicTableView reloadData];
        
        if (musicArray.count == 0)
        {
            isEdit = NO;
            
            [_editBtn setTitle:@"Edit" forState:UIControlStateNormal];
            _editBtn.tag = 1;
            
            [_musicTableView setEditing:NO animated:YES];
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ((collectionSelectedIndex == LIBRARY)&&(tableView.tag == 1)&&(musicArray.count > 0))
    {
        return YES;
    }
    else
    {
        return NO;
    }
    
    return YES;
}


- (void)changedMusicName
{
    [self _configureMusicLoader];
}



@end
