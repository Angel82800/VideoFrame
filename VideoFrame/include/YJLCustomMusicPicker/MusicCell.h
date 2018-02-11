//
//  MusicCell.h
//  VideoFrame
//
//  Created by Yinjing Li on 5/12/14.
//  Copyright (c) 2014 Yinjing Li. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol MusicCellDelegate;

@protocol MusicCellDelegate <NSObject>

- (void)changedMusicName;

@end

@interface MusicCell : UITableViewCell <UITextFieldDelegate>

@property(nonatomic, retain) id <MusicCellDelegate> delegate;

@property(nonatomic, retain) UITextField* nameTextField;

@property(nonatomic, retain) NSString* originalName;




@end
