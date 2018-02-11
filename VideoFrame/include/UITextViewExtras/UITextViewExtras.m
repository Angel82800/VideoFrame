//
//  UITextViewExtras.m
//  VideoFrame
//
//  Created by Yinjing Li on 3/14/14.
//  Copyright (c) 2014 Yinjing Li. All rights reserved.
//

#import "UITextViewExtras.h"

@implementation UITextViewExtras

@synthesize customDelegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.backgroundColor = [UIColor clearColor];
        self.contentInset = UIEdgeInsetsZero;
        self.scrollEnabled = NO;
        self.selectable = NO;
        
        [self setAutocapitalizationType:UITextAutocapitalizationTypeNone];
        [self setAutocorrectionType:UITextAutocorrectionTypeNo];
        [self setSpellCheckingType:UITextSpellCheckingTypeNo];
        [self setDataDetectorTypes:UIDataDetectorTypeNone];

    }
    return self;
}


- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{

    if (action == @selector(paste:))
    {
        return [super canPerformAction:action withSender:sender];
    }
    else if (action == @selector(copy:))
    {
        return [super canPerformAction:action withSender:sender];
    }
    else if (action == @selector(cut:))
    {
        return [super canPerformAction:action withSender:sender];
    }
    else if (action == @selector(select:))
    {
        return [super canPerformAction:action withSender:sender];
    }
    else if (action == @selector(selectAll:))
    {
        return [super canPerformAction:action withSender:sender];
    }
    else{
        
        return NO;
    }

    return [super canPerformAction:action withSender:sender];

}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
    if ([self.customDelegate respondsToSelector:@selector(hit)]) {
        [self.customDelegate hit];
    }
    
}

- (void)insertDictationResult:(NSArray *)dictationResult {
    
    for (int i=0; i<dictationResult.count; i++) {
        UIDictationPhrase* parse = [dictationResult objectAtIndex:i];
        [self insertText:parse.text];
    }

}


@end
