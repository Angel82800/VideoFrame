//
//  KZColorPickerWheel.h
//  VideoFrame
//
//  Created by Yinjing Li on 3/6/14.
//  Copyright (c) 2014 Yinjing Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HSV.h"

@interface KZColorPickerHSWheel : UIControl
{
	
	HSVType currentHSV;
}

@property(nonatomic) HSVType currentHSV;

-(id) initAtOrigin:(CGRect)frame;

@end
