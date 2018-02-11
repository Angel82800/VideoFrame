
#import <UIKit/UIKit.h>
#import "Definition.h"



@interface ExplodeAction:NSObject

- (id)init;

- (NSMutableArray*) startExplodeAction:(UIImage*) image startPosition:(CFTimeInterval)startPosition duration:(CFTimeInterval)duration sourceRect:(CGRect)sourceRect;
- (NSMutableArray*) endExplodeAction:(UIImage*) image endPosition:(CFTimeInterval)endPosition duration:(CFTimeInterval)duration sourceRect:(CGRect)sourceRect;

@end
