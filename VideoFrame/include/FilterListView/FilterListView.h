//
//  FilterListView.h
//  VideoFrame
//
//  Created by Yinjing Li on 04/01/14.
//  Copyright (c) 2014 Yinjing Li. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Definition.h"
#import "FilterListCell.h"


@protocol FilterListDelegate <NSObject>
@optional

-(void) didFilterPreview:(NSInteger) index;
-(void) didFilterApply:(NSInteger) index;

@end


@interface FilterListView : UIView<UITableViewDelegate, UITableViewDataSource, filterSelectDelegate>{
    
}

@property (nonatomic, weak) id <FilterListDelegate> delegate;

@property(nonatomic, strong) UILabel* titleLabel;

@property(nonatomic, strong) UITableView* videoFilterListTable;



@end
