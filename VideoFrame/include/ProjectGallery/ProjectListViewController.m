//
//  ProjectListViewController.m
//  VideoFrame
//
//  Created by YinjingLi on 1/14/15.
//  Copyright (c) 2015 Yinjing Li. All rights reserved.
//

#import "ProjectListViewController.h"
#import "ProjectGalleryPickerController.h"
#import "ProjectCell.h"
#import "Definition.h"
#import "SHKActivityIndicator.h"
#import "MyCloudDocument.h"
#import "SSZipArchive.h"


@interface ProjectListViewController ()

@end

@implementation ProjectListViewController


- (void)viewDidLoad
{
    [super viewDidLoad];

    //  navigation controller
    self.projectGalleryPickerController = (ProjectGalleryPickerController*)self.navigationController;
    self.isBackup = self.projectGalleryPickerController.isBackup;

    //  specialist white background
    UIImageView* imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    [imageView setImage:[UIImage imageNamed:@"specialistEditBg"]];
    self.projectListTableView.backgroundView = imageView;
    
    //  select all button
    self.selectAllButton = [[UIBarButtonItem alloc] initWithTitle:@"Select All" style:UIBarButtonItemStylePlain target:self action:@selector(actionSelectAll:)];
    [self.selectAllButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:MYRIADPRO size:15.0f], NSFontAttributeName, [UIColor blackColor], NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];

    //  backup restore button
    [self.backupRestoreButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:MYRIADPRO size:15.0f], NSFontAttributeName, [UIColor blackColor], NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];

    //  cancel button
    [self.cancelButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:MYRIADPRO size:15.0f], NSFontAttributeName, [UIColor blackColor], NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];

    self.navigationItem.rightBarButtonItems = @[self.backupRestoreButton, self.selectAllButton];
    
    
    if (self.isBackup)  //backup to iCloud
    {
        [self.backupRestoreButton setTitle:@"Backup"];
        
        [self fetchProjects];
    }
    else    //restore from iCloud
    {
        [self.backupRestoreButton setTitle:@"Restore"];
        
        [self loadSavedProjectsFromICloud];
    }
    
    [self.projectListTableView reloadData];
    
    isSelectAll = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)prefersStatusBarHidden
{
    return YES;
}


-(void) fetchProjects
{
    [self.projectNamesArray removeAllObjects];
    self.projectNamesArray = nil;
    self.projectNamesArray = [[NSMutableArray alloc] init];

    NSError *error;
    NSFileManager *localFileManager = [NSFileManager defaultManager];
    NSString *documentsPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSArray *filesArray = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsPath error:&error];
    
    if (filesArray.count > 0)
    {
        NSMutableArray* filesAndProperties = [NSMutableArray arrayWithCapacity:[filesArray count]];
        
        for(NSString* file in filesArray)
        {
            error = nil;
            
            NSString* filePath = [documentsPath stringByAppendingPathComponent:file];
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
        
        for (int i=0; i<sortedFiles.count; i++)
        {
            NSDictionary* dict = [sortedFiles objectAtIndex:i];
            
            NSString* projectPath = [documentsPath stringByAppendingPathComponent:[dict objectForKey:@"path"]];
            NSString* filePath = [projectPath stringByAppendingPathComponent:@"screenshot.png"];
            
            if([localFileManager fileExistsAtPath:filePath])
                [self.projectNamesArray addObject:[dict objectForKey:@"path"]];
        }
    }
    
    
    [self.projectThumbnailArray removeAllObjects];
    self.projectThumbnailArray = nil;
    self.projectThumbnailArray = [[NSMutableArray alloc] init];
    
    
    for (int i=0; i<self.projectNamesArray.count; i++)
    {
        NSString* projectName = [self.projectNamesArray objectAtIndex:i];
        NSString* projectPath = [documentsPath stringByAppendingPathComponent:projectName];
        NSString* filePath = [projectPath stringByAppendingPathComponent:@"screenshot.png"];
        
        UIImage* screenshotImage = [UIImage imageWithContentsOfFile:filePath];
        
        [self.projectThumbnailArray addObject:screenshotImage];
    }

    
    [self.selectedProjectArray removeAllObjects];
    self.selectedProjectArray = nil;
    self.selectedProjectArray = [[NSMutableArray alloc] init];

    for (int i=0; i<self.projectNamesArray.count; i++)
    {
        [self.selectedProjectArray addObject:[NSNumber numberWithBool:NO]];
    }
}

-(void)loadSavedProjectsFromICloud
{
    [[SHKActivityIndicator currentIndicator] displayActivity:(@"Load projects from iCloud...") isLock:YES];

    self.query = [[NSMetadataQuery alloc] init];
    [self.query setSearchScopes:[NSArray arrayWithObject:NSMetadataQueryUbiquitousDocumentsScope]];
    NSPredicate *pred = [NSPredicate predicateWithFormat: @"%K like '*.zip'", NSMetadataItemFSNameKey];
    [self.query setPredicate:pred];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(queryDidFinishGathering:)
                                                 name:NSMetadataQueryDidFinishGatheringNotification
                                               object:self.query];
    
    [self.query startQuery];
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)queryDidFinishGathering:(NSNotification *)notification
{
    NSMetadataQuery *query = [notification object];
    [query disableUpdates];
    [query stopQuery];
    
    [self loadData:query];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSMetadataQueryDidFinishGatheringNotification object:query];
    
    self.query = nil;
}

- (void)loadData:(NSMetadataQuery *)query
{
    NSFileManager *localFileManager = [NSFileManager defaultManager];

    [self.projectNamesArray removeAllObjects];
    self.projectNamesArray = nil;
    self.projectNamesArray = [[NSMutableArray alloc] init];

    [self.projectThumbnailArray removeAllObjects];
    self.projectThumbnailArray = nil;
    self.projectThumbnailArray = [[NSMutableArray alloc] init];

    [self.selectedProjectArray removeAllObjects];
    self.selectedProjectArray = nil;
    self.selectedProjectArray = [[NSMutableArray alloc] init];

    
    selectedProjectCount = (int)[[query results] count];
    saveCount = 0;
    
    if (selectedProjectCount == 0)
    {
        [[SHKActivityIndicator currentIndicator] hide];
    }
    
    for (NSMetadataItem *item in [query results])
    {
        NSURL *url = [item valueForAttribute:NSMetadataItemURLKey];
        
        NSString* projectPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[url lastPathComponent]];
        projectPath = [projectPath stringByReplacingOccurrencesOfString:@".zip" withString:@""];

        if ([localFileManager fileExistsAtPath:projectPath])
        {
            [self.projectNamesArray addObject:[projectPath lastPathComponent]];

            NSString* filePath = [projectPath stringByAppendingPathComponent:@"screenshot.png"];
            UIImage* screenshotImage = [UIImage imageWithContentsOfFile:filePath];
            [self.projectThumbnailArray addObject:screenshotImage];

            saveCount++;
            
            if (saveCount == selectedProjectCount)
            {
                for (int i=0; i<self.projectNamesArray.count; i++)
                {
                    [self.selectedProjectArray addObject:[NSNumber numberWithBool:NO]];
                }
                
                [self.projectListTableView reloadData];
                
                [[SHKActivityIndicator currentIndicator] hide];
            }
        }
        else
        {
            MyCloudDocument *mydoc = [[MyCloudDocument alloc] initWithFileURL:url];
            
            [mydoc openWithCompletionHandler:^(BOOL success) {
                
                if (success)
                {
                    //download zip file to temp folder
                    NSData* zipFileData = mydoc.dataContent;
                    
                    NSString* zipFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[url lastPathComponent]];
                    unlink([zipFilePath UTF8String]);
                    
                    [zipFileData writeToFile:zipFilePath atomically:YES];
                    
                    [mydoc closeWithCompletionHandler:^(BOOL success) {
                        
                    }];
                    
                    
                    //unzip
                    NSString* unzipFolderPath = [zipFilePath stringByReplacingOccurrencesOfString:@".zip" withString:@""];

                    @autoreleasepool
                    {
                        [SSZipArchive unzipFileAtPath:zipFilePath toDestination:unzipFolderPath];
                    }
                    
                    
                    [self.projectNamesArray addObject:[unzipFolderPath lastPathComponent]];
                    
                    NSString* filePath = [unzipFolderPath stringByAppendingPathComponent:@"screenshot.png"];
                    UIImage* screenshotImage = [UIImage imageWithContentsOfFile:filePath];
                    [self.projectThumbnailArray addObject:screenshotImage];
                    
                    unlink([zipFilePath UTF8String]);
                    
                    saveCount++;
                    
                    if (saveCount == selectedProjectCount)
                    {
                        for (int i=0; i<self.projectNamesArray.count; i++)
                        {
                            [self.selectedProjectArray addObject:[NSNumber numberWithBool:NO]];
                        }
                        
                        [self.projectListTableView reloadData];
                        
                        [[SHKActivityIndicator currentIndicator] hide];
                    }
                }
                
            }];
        }
    }
}

#pragma mark -
#pragma mark - action Cancel

-(IBAction)actionCancel:(id)sender
{
    if ([self.projectGalleryPickerController.projectGalleryPickerDelegate respondsToSelector:@selector(projectGalleryPickerControllerDidCancel:)])
    {
        [self.projectGalleryPickerController.projectGalleryPickerDelegate projectGalleryPickerControllerDidCancel:self.projectGalleryPickerController];
    }
}


#pragma mark -
#pragma mark - action Select/Deselect All

-(void)actionSelectAll:(id)sender
{
    isSelectAll = !isSelectAll;
    
    if (isSelectAll)
    {
        [self.selectAllButton setTitle:@"Deselect All"];
        
        for (int i=0; i<self.selectedProjectArray.count; i++)
        {
            [self.selectedProjectArray replaceObjectAtIndex:i withObject:[NSNumber numberWithBool:YES]];
        }
    }
    else
    {
        [self.selectAllButton setTitle:@"Select All"];

        for (int i=0; i<self.selectedProjectArray.count; i++)
        {
            [self.selectedProjectArray replaceObjectAtIndex:i withObject:[NSNumber numberWithBool:NO]];
        }
    }
    
    [self.projectListTableView reloadData];
}


#pragma mark -
#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.projectNamesArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 64.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* CellIdentifier = @"ProjectCell";
    
    if (self.projectNamesArray.count > 0)
    {
        ProjectCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        cell.projectNameLabel.text = [self.projectNamesArray objectAtIndex:indexPath.row];
        cell.projectThumbImageView.image = [self.projectThumbnailArray objectAtIndex:indexPath.row];
        
        BOOL isSelected = [[self.selectedProjectArray objectAtIndex:indexPath.row] boolValue];
        cell.isSelected = isSelected;
        [cell didSelected:isSelected];
        
        return cell;
    }

    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    BOOL isSelected = [[self.selectedProjectArray objectAtIndex:indexPath.row] boolValue];

    [self.selectedProjectArray replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithBool:!isSelected]];
}


#pragma mark -
#pragma mark - action Backup / Restore

-(IBAction)actionBackupRestore:(id)sender
{
    selectedProjectCount = 0;
    
    if (self.selectedProjectArray.count == 0)
    {
        return;
    }
    
    for (int i=0; i<self.selectedProjectArray.count; i++)
    {
        BOOL isSelected = [[self.selectedProjectArray objectAtIndex:i] boolValue];

        if (isSelected)
        {
            selectedProjectCount++;
        }
    }
    
    if (selectedProjectCount > 0)
    {
        if (self.isBackup)
        {
            NSURL *ubiq = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
            
            if (ubiq)
            {
                [[SHKActivityIndicator currentIndicator] displayActivity:(@"Backup to iCloud...") isLock:YES];
                
                [self performSelector:@selector(saveProjectsToICloud) withObject:nil afterDelay:0.2f];   //save data to iCloud
            }
            else
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please login to iCloud first!"  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil, nil];
                [alert show];
            }
        }
        else
        {
            NSURL *ubiq = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
            
            if (ubiq)
            {
                [[SHKActivityIndicator currentIndicator] displayActivity:(@"Restore from iCloud...") isLock:YES];
                
                [self performSelector:@selector(restoreProjectsFromICloud) withObject:nil afterDelay:0.2f];   //restore data from iCloud
            }
            else
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please login to iCloud first!"  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil, nil];
                [alert show];
            }
        }
    }
}


#pragma mark - 
#pragma mark - Save project to iCloud

-(void)saveProjectsToICloud
{
    NSString *documentsPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];

    saveCount = 0;
    
    for (int i=0; i<self.selectedProjectArray.count; i++)
    {
        BOOL isSelected = [[self.selectedProjectArray objectAtIndex:i] boolValue];

        if (isSelected)
        {
            NSString* projectName = [self.projectNamesArray objectAtIndex:i];
            NSString* projectPath = [documentsPath stringByAppendingPathComponent:projectName];

            //zip project
            NSString* zipFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.zip", projectName]];
            unlink([zipFilePath UTF8String]);
            
            @autoreleasepool
            {
                [SSZipArchive createZipFileAtPath:zipFilePath withContentsOfDirectory:projectPath];
            }
            
            //Save zip file to iCloud
            NSURL* zipUrl = [NSURL fileURLWithPath:zipFilePath];

            NSURL *containerUbiquitousURL = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
            NSURL *destinationUbiquitousURL = [[containerUbiquitousURL URLByAppendingPathComponent:@"Documents"] URLByAppendingPathComponent:[zipUrl lastPathComponent]];
            
            MyCloudDocument *mydoc = [[MyCloudDocument alloc] initWithFileURL:destinationUbiquitousURL];
            NSData *data = [NSData dataWithContentsOfFile:zipFilePath];
            mydoc.dataContent = data;
            
            [mydoc saveToURL:[mydoc fileURL] forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success)
             {
                 if (success)
                 {

                 }
                 else
                 {
                     NSLog(@"Saving failed zip to icloud");
                 }
                 
                 unlink([zipFilePath UTF8String]);
                 
                 saveCount++;
                 
                 if (saveCount == selectedProjectCount)
                 {
                     [[SHKActivityIndicator currentIndicator] hide];
                     
                     if ([self.projectGalleryPickerController.projectGalleryPickerDelegate respondsToSelector:@selector(projectGalleryPickerControllerDidCancel:)])
                     {
                         [self.projectGalleryPickerController.projectGalleryPickerDelegate projectGalleryPickerControllerDidCancel:self.projectGalleryPickerController];
                     }
                     
                     NSFileManager* localFileManager = [NSFileManager defaultManager];
                     NSString* folderDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Library"];
                     NSString* plistFolderPath = [folderDir stringByAppendingPathComponent:@"Preferences"];

                     NSString* lastUpdatePlistFileName = [plistFolderPath stringByAppendingPathComponent:@"LastUpdate.plist"];
                     
                     BOOL isDirectory = NO;
                     BOOL exist = [localFileManager fileExistsAtPath:lastUpdatePlistFileName isDirectory:&isDirectory];
                     
                     NSMutableDictionary* lastUpdatePlistDict = nil;
                     
                     if (!exist)
                     {
                         [localFileManager createFileAtPath:lastUpdatePlistFileName contents:nil attributes:nil];
                         
                         lastUpdatePlistDict = [NSMutableDictionary dictionary];

                     }
                     else
                     {
                         lastUpdatePlistDict = [[NSMutableDictionary alloc] initWithContentsOfFile:lastUpdatePlistFileName];
                     }
                     
                     NSDate* currentDate = [NSDate date];

                     [lastUpdatePlistDict setObject:currentDate forKey:@"LastUpdatedDate"];
                     [lastUpdatePlistDict writeToFile:lastUpdatePlistFileName atomically:YES];
                 }
             }];
        }
    }
}


#pragma mark -
#pragma mark - Restore project from iCloud

-(void)restoreProjectsFromICloud
{
    NSFileManager *localFileManager = [NSFileManager defaultManager];
    NSString *documentsPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    
    saveCount = 0;
    
    for (int i=0; i<self.selectedProjectArray.count; i++)
    {
        BOOL isSelected = [[self.selectedProjectArray objectAtIndex:i] boolValue];
        
        if (isSelected)
        {
            NSString* projectName = [self.projectNamesArray objectAtIndex:i];
            NSString* projectPath = [NSTemporaryDirectory() stringByAppendingPathComponent:projectName];
            NSString* savePath = [documentsPath stringByAppendingPathComponent:projectName];

            NSError* error = nil;

            if ([localFileManager fileExistsAtPath:savePath])
            {
                [localFileManager removeItemAtPath:savePath error:&error];
            }
            
            [localFileManager createDirectoryAtPath:savePath withIntermediateDirectories:NO attributes:nil error:nil];
            
            NSArray *filesArray = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:projectPath error:&error];
            
            if (filesArray.count > 0)
            {
                for(NSString* file in filesArray)
                {
                    error = nil;
                    
                    NSString* fileToPath = [savePath stringByAppendingPathComponent:file];
                    NSString* fileFromPath = [projectPath stringByAppendingPathComponent:file];

                    NSData *data = [NSData dataWithContentsOfFile:fileFromPath];
                    [data writeToFile:fileToPath atomically:YES];
                }
            }
            
            saveCount++;
            
            if (saveCount == selectedProjectCount)
            {
                [[SHKActivityIndicator currentIndicator] hide];
                
                if ([self.projectGalleryPickerController.projectGalleryPickerDelegate respondsToSelector:@selector(projectGalleryPickerControllerDidCancel:)])
                {
                    [self.projectGalleryPickerController.projectGalleryPickerDelegate projectGalleryPickerControllerDidCancel:self.projectGalleryPickerController];
                }
            }
        }
    }
}


@end
