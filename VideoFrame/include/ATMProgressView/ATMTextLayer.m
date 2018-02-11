/*
 *  ATMTextLayer.m
 *  VideoFrame
 *
 *  Created by Yinjing Li 2011-03-01.
 *  Copyright (c) 2010-2011, Yinjing Li
 *  All rights reserved.
 *
 *	https://github.com/atomton/ATMHud
 */

#import "ATMTextLayer.h"
#import "Definition.h"

@implementation ATMTextLayer
@synthesize caption;

- (id)initWithLayer:(id)layer {
	if ((self = [super init])) {
		caption = @"";
	}
	return self;
}

+ (BOOL)needsDisplayForKey:(NSString *)key {
	if ([key isEqualToString:@"caption"]) {
		return YES;
	} else {
		return [super needsDisplayForKey:key];
	}
}

- (void)drawInContext:(CGContextRef)ctx
{
	UIGraphicsPushContext(ctx);
	
	CGRect f = self.bounds;
	CGRect s = f;
	s.origin.y -= 1;

    UIFont *font = [UIFont fontWithName:MYRIADPRO size:14];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    NSDictionary *attributes = @{ NSFontAttributeName: font, NSForegroundColorAttributeName: [UIColor whiteColor],
                                  NSParagraphStyleAttributeName: paragraphStyle };
    
    [caption drawInRect:f withAttributes:attributes];
    
	UIGraphicsPopContext();
}

@end
