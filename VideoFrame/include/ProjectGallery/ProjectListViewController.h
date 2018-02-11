//
//  ProjectListViewController.h
//  VideoFrame
//
//  Created by YinjingLi on 1/14/15.
//  Copyright (c) 2015 Yinjing Li. All rights reserved.
//

#import <UIKit/UIKit.h>


@class ProjectGalleryPickerController;


@interface ProjectListViewController : UIViewController
{
    BOOL isSelectAll;
    
    int selectedProjectCount;
    int saveCount;
}

@property(nonatomic, assign) BOOL isBackup;

@property(nonatomic, strong) IBOutlet UIBarButtonItem *cancelButton;
@property(nonatomic, strong) IBOutlet UIBarButtonItem *backupRestoreButton;
@property(nonatomic, strong) UIBarButtonItem *selectAllButton;

@property(nonatomic, strong) IBOutlet UITableView* projectListTableView;


@property(nonatomic, strong) NSMutableArray* projectNamesArray;
@property(nonatomic, strong) NSMutableArray* projectThumbnailArray;
@property(nonatomic, strong) NSMutableArray* selectedProjectArray;

@property(nonatomic, strong) NSMetadataQuery* query;

@property(nonatomic, strong) ProjectGalleryPickerController* projectGalleryPickerController;



@end
