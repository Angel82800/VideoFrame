
#import <UIKit/UIKit.h>
#import "Definition.h"



@interface GenieAction:NSObject

- (id)init;

- (NSMutableArray*) startGenieAction:(UIImage*) image startPosition:(CFTimeInterval)startPosition duration:(CFTimeInterval)duration orientation:(ADTransitionOrientation)orientation sourceRect:(CGRect)sourceRect;
- (NSMutableArray*) endGenieAction:(UIImage*) image endPosition:(CFTimeInterval)endPosition duration:(CFTimeInterval)duration orientation:(ADTransitionOrientation)orientation sourceRect:(CGRect)sourceRect;

@end
