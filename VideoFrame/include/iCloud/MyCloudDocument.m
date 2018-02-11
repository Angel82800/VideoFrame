//
//  MyCloudDocument.m
//  Video Dreamer
//
//  Created by Yinjing Li on 01/09/15.
//  Copyright (c) 2015 Yinjing Li and Frederick Weaber. All rights reserved.
//

#import "MyCloudDocument.h"

@implementation MyCloudDocument

@synthesize dataContent = _dataContent;


// Called whenever the application reads data from the file system
- (BOOL)loadFromContents:(id)contents ofType:(NSString *)typeName error:(NSError **)outError
{
    if ([contents length] > 0)
    {
        self.dataContent = [[NSData alloc] initWithBytes:[contents bytes] length:[contents length]];
    }
    else
    {
        self.dataContent = nil;
    }
    
    return YES;
}

// Called whenever the application (auto)saves the content of a note
- (id)contentsForType:(NSString *)typeName error:(NSError **)outError
{
    if (self.dataContent == nil)
    {
        return nil;
    }
    
    return self.dataContent;
}

@end
