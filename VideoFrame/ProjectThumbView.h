//
//  ProjectThumbView.h
//  VideoFrame
//
//  Created by Yinjing Li on 6/20/14.
//  Copyright (c) 2014 Yinjing Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YJLCustomDeleteButton.h"

@protocol ProjectThumbViewDelegate <NSObject>

@optional
-(void) selectedProject:(NSString*) projectName;
-(void) deleteProject:(NSString*) projectName;
-(void) actionProjectDeleteEnabled;
@end




@interface ProjectThumbView : UIView<UIGestureRecognizerDelegate>
{
    NSString* strProjectName;
    NSString* strProjectCaption;
}

@property(nonatomic, weak) id <ProjectThumbViewDelegate> delegate;

@property(nonatomic, strong) UIImageView* thumbImageView;
@property(nonatomic, strong) UILabel* captionLabel;
@property(nonatomic, strong) YJLCustomDeleteButton* deleteBtn;

-(id) initWithFrame:(CGRect)frame caption:(NSString*) captionStr name:(NSString*)projectName image:(UIImage*) screenshot;

-(void) vibrateEnable;
-(void) vibrateDesable;

@end
