
#import <UIKit/UIKit.h>

typedef NSString*(^StringGenerationBlock)(CGFloat progress);
typedef NSAttributedString*(^AttributedStringGenerationBlock)(CGFloat progress);

typedef NSString*(^StringGenerationBlockForDuration)(NSString* duration);
typedef NSAttributedString*(^AttributedStringGenerationBlockForDuration)(NSString* duration);



@protocol CircleProgressBarDelegate;


IB_DESIGNABLE
@interface CircleProgressBar : UIView<UIGestureRecognizerDelegate>

@property (nonatomic, weak) id <CircleProgressBarDelegate> delegate;

@property (nonatomic) BOOL hintHidden;

@property (nonatomic) CGFloat progressBarWidth;
@property (nonatomic) CGFloat hintViewSpacingForDrawing;

@property (nonatomic) CGFloat startAngle;
@property (nonatomic) CGFloat hintViewSpacing;

@property (nonatomic) CGPoint _centerPoint;
@property (nonatomic) CGPoint _lastPosition;

@property (nonatomic, readonly) CGFloat progress;

@property (nonatomic, readonly) NSString* duration;

@property (nonatomic) UIColor *progressBarProgressColor;
@property (nonatomic) UIColor *progressBarTrackColor;
@property (nonatomic) UIColor *hintViewBackgroundColor;
@property (nonatomic) UIColor *hintTextColor;

@property (nonatomic) UIFont *hintTextFont;
@property (nonatomic) UIFont *hintDurationTextFont;


- (void)setHintTextGenerationBlock:(StringGenerationBlock)generationBlock;
- (void)setHintAttributedGenerationBlock:(AttributedStringGenerationBlock)generationBlock;
- (void)setProgress:(CGFloat)progress timeStr:(NSString*)duration;
- (void)setProgress:(CGFloat)progress animated:(BOOL)animated;
- (void)setProgress:(CGFloat)progress animated:(BOOL)animated duration:(CGFloat)duration;
- (void)panGestureRecognized:(UIPanGestureRecognizer *)sender;

@end


@protocol CircleProgressBarDelegate <NSObject>

@optional

- (void) didChangedProgress:(CGFloat) progress;

@end

