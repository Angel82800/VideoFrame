/*
 *  ATMHudQueueItem.m
 *  ATMHud
 *
 *  Created by Marcel Müller on 2011-03-01.
 *  Copyright (c) 2010-2011, Marcel Müller (atomcraft)
 *  All rights reserved.
 *
 *	https://github.com/atomton/ATMHud
 */

#import "ATMHudQueueItem.h"

@implementation ATMHudQueueItem

- (id)init {
	if ((self = [super init])) {
		_caption = @"";
		_image = nil;
		_showActivity = NO;
		_accessoryPosition = ATMHudAccessoryPositionBottom;
		_activityStyle = UIActivityIndicatorViewStyleWhite;
	}
	return self;
}


@end
