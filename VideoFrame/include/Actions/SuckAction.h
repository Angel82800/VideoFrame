
#import <UIKit/UIKit.h>
#import "Definition.h"



@interface SuckAction:NSObject

- (id)init;

- (NSMutableArray*) startSuckAction:(UIImage*) image startPosition:(CFTimeInterval)startPosition duration:(CFTimeInterval)duration orientation:(ADTransitionOrientation)orientation sourceRect:(CGRect)sourceRect;
- (NSMutableArray*) endSuckAction:(UIImage*) image endPosition:(CFTimeInterval)endPosition duration:(CFTimeInterval)duration orientation:(ADTransitionOrientation)orientation sourceRect:(CGRect)sourceRect;

@end
