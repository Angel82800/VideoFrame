//
//  ProjectManager.h
//  VideoFrame
//
//  Created by Yinjing Li on 6/18/14.
//  Copyright (c) 2014 Yinjing Li. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Definition.h"
#import "MediaObjectView.h"


@interface ProjectManager : NSObject

@property(nonatomic, strong) NSString* projectName;


-(id)init;

-(NSString*) createNewProject;
-(void) deleteProject;
-(void) noSaveProject;
-(void) saveProject:(UIImage*) screenShotImg objects:(NSMutableArray*) objectArray;
-(void) saveObjectWithModifiedVideoInfo:(MediaObjectView*) object;
-(void) copyProject:(UIImage*) screenShotImg objects:(NSMutableArray*) objectArray;
-(void) saveAsProject:(UIImage*) screenShotImg objects:(NSMutableArray*) objectArray;
-(BOOL) renameProjectFolder:(NSString*) newName;
-(void) deleteFile:(NSString*) filename;

@end
