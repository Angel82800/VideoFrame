
#import <Foundation/Foundation.h>

#if defined(__IPHONE_OS_VERSION_MIN_REQUIRED)

#import <UIKit/UIKit.h>


extern __attribute__((overloadable)) UIImage * UIImageWithAnimatedGIFData(NSData *data);
extern __attribute__((overloadable)) UIImage * UIImageWithAnimatedGIFData(NSData *data, CGFloat scale, NSTimeInterval duration, NSError * __autoreleasing *error);
extern __attribute__((overloadable)) NSData * UIImageAnimatedGIFRepresentation(UIImage *image);
extern __attribute__((overloadable)) NSData * UIImageAnimatedGIFRepresentation(UIImage *image, NSTimeInterval duration, NSUInteger loopCount, NSError * __autoreleasing *error);


@interface AnimatedGIFImageSerialization : NSObject

+ (UIImage *)imageWithData:(NSData *)data error:(NSError * __autoreleasing *)error;
+ (UIImage *)imageWithData:(NSData *)data scale:(CGFloat)scale duration:(NSTimeInterval)duration error:(NSError * __autoreleasing *)error;
+ (NSData *)animatedGIFDataWithImage:(UIImage *)image error:(NSError * __autoreleasing *)error;
+ (NSData *)animatedGIFDataWithImage:(UIImage *)image duration:(NSTimeInterval)duration loopCount:(NSUInteger)loopCount error:(NSError * __autoreleasing *)error;

@end

extern NSString * const AnimatedGIFImageErrorDomain;

#endif
