//
//  FilterListView.m
//  VideoFrame
//
//  Created by Yinjing Li on 04/01/14.
//  Copyright (c) 2014 Yinjing Li. All rights reserved.
//


#import "FilterListView.h"

@implementation FilterListView

@synthesize delegate, titleLabel, videoFilterListTable;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        
        CGFloat rTitleLabelHeight = 40.0f;
        CGFloat rFontSize = 20.0f;
        
        // Title label
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 8.0f, self.frame.size.width, rTitleLabelHeight)];
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.text = @"Generate Video";
        self.titleLabel.font = [UIFont fontWithName:MYRIADPRO size:rFontSize+2];
        self.titleLabel.adjustsFontSizeToFitWidth = YES;
        self.titleLabel.minimumScaleFactor = 0.1f;
        self.titleLabel.numberOfLines = 0;
        self.titleLabel.textColor = [UIColor whiteColor];
        [self addSubview:self.titleLabel];
        
        //FilterListTableView
        self.videoFilterListTable = nil;
        self.videoFilterListTable = [[UITableView alloc] initWithFrame:CGRectMake(5.0f, 10.0f + rTitleLabelHeight, self.frame.size.width - 10.0f, self.frame.size.height - (10.0f + rTitleLabelHeight) - 2.0f) style:UITableViewStylePlain];
        self.videoFilterListTable.delegate = self;
        self.videoFilterListTable.dataSource = self;
        [self.videoFilterListTable reloadData];
        self.videoFilterListTable.backgroundColor = [UIColor clearColor];
        self.videoFilterListTable.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.videoFilterListTable.scrollEnabled = NO;
        [self addSubview:self.videoFilterListTable];
    }
    
    return self;
}


#pragma mark -
#pragma mark - UITableView Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
	
	FilterListCell *cell = [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[FilterListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier index:indexPath.row];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.delegate = self;
    }
    else
    {
        [cell reloadCell:indexPath.row];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 54.0f;
}

- (void)tableView:(UITableView *)aTableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
    return proposedDestinationIndexPath;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Change the selected background view of the cell.
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark -
#pragma mark - filterSelectDelegate

-(void) filterPreviewDidSelected:(NSInteger) index
{
    if ([self.delegate respondsToSelector:@selector(didFilterPreview:)])
    {
        [self.delegate didFilterPreview:index];
    }
}

-(void) filterApplyDidSelected:(NSInteger) index
{
    if ([self.delegate respondsToSelector:@selector(didFilterApply:)])
    {
        [self.delegate didFilterApply:index];
    }
}


@end
