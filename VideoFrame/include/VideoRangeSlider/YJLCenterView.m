//
//  YJLCenterView.m
//  VideoFrame
//
//  Created by Yinjing Li on 8/19/14.
//  Copyright (c) 2014 Yinjing Li. All rights reserved.
//

#import "YJLCenterView.h"
#import "Definition.h"

@implementation YJLCenterView

@synthesize colorIndex = _colorIndex;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight;

        self.duration = 0.0f;
        self.colorIndex = MEDIA_PHOTO;
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.

- (void)drawRect:(CGRect)rect
{
    self.backgroundColor = [UIColor gradientFromColor:self.frame.size.height colorIndex:self.colorIndex];

    [[UIColor blackColor] set];

    CGFloat totalSeconds = self.duration;
    
    NSInteger majorTickInterval = 2;
    NSInteger minorTickCounter = majorTickInterval;
    
    CGFloat currentWidth = self.bounds.size.width;
    int majorTickLength = 15;
    int minorTickLength = 10;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        majorTickLength = 10;
        minorTickLength = 5;
    }
    
    if (totalSeconds*2 == 0.0f)
        return;
    
    CGFloat minorTickSpacingInPixels = currentWidth / (totalSeconds * 2);// pixel per 0.5 sec.
    NSInteger totalNumberOfTicks = currentWidth / minorTickSpacingInPixels;
    
    if (totalNumberOfTicks == 0)
        return;
    
    for (NSInteger currentTickNumber = 0; currentTickNumber < totalNumberOfTicks; currentTickNumber++)
    {
        UIBezierPath *bezier = [[UIBezierPath alloc] init];
        [bezier moveToPoint:CGPointMake(round(currentTickNumber * minorTickSpacingInPixels), 0.0f)];
        
        minorTickCounter++;
        
        if (minorTickCounter >= majorTickInterval)
        {
            [bezier addLineToPoint:CGPointMake(round(currentTickNumber * minorTickSpacingInPixels), round(majorTickLength*grZoomScale))];

            minorTickCounter = 0;
        }
        else
        {
            [bezier addLineToPoint:CGPointMake(round(currentTickNumber * minorTickSpacingInPixels), round(minorTickLength*grZoomScale))];
        }

        [bezier setLineWidth:1.0f];
        [bezier setLineCapStyle:kCGLineCapSquare];
        
        [bezier stroke];
    }
}



@end
