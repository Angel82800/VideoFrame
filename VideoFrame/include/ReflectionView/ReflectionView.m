

#import "ReflectionView.h"


@interface ReflectionView ()

@property (nonatomic, strong) CAGradientLayer *gradientLayer;

@end


@implementation ReflectionView



+ (Class)layerClass
{
    return [CAReplicatorLayer class];
}

- (void)update
{
    CAReplicatorLayer *layer = (CAReplicatorLayer *)self.layer;

    if (self.isReflection)
    {
        layer.instanceCount = 2;
        
        CATransform3D transform = CATransform3DIdentity;
        transform = CATransform3DTranslate(transform, 0.0f, layer.bounds.size.height + _reflectionGap, 0.0f);
        transform = CATransform3DScale(transform, 1.0f, -1.0f, 0.0f);
        
        layer.instanceTransform = transform;
        layer.instanceAlphaOffset = _reflectionAlpha - 1.0f;
        
        if (!_gradientLayer)
        {
            _gradientLayer = [[CAGradientLayer alloc] init];
            _gradientLayer.colors = [NSArray arrayWithObjects:
                                     (__bridge id)[UIColor blackColor].CGColor,
                                     (__bridge id)[UIColor blackColor].CGColor,
                                     (__bridge id)[UIColor clearColor].CGColor,
                                     nil];
        }
        
        self.layer.mask = _gradientLayer;
        
        CGFloat total = layer.bounds.size.height * 2.0f + _reflectionGap + 150.0f;
        CGFloat halfWay = (layer.bounds.size.height + 150.0f + _reflectionGap) / total - 0.01f;
        _gradientLayer.frame = CGRectMake(-150.0f, -150.0f, self.bounds.size.width + 300.0f, total);
        _gradientLayer.locations = [NSArray arrayWithObjects:
                                    [NSNumber numberWithFloat:0.0f],
                                    [NSNumber numberWithFloat:halfWay],
                                    [NSNumber numberWithFloat:halfWay + (1.0f - halfWay) * _reflectionScale],
                                    nil];
        
    }
    else{
        layer.instanceCount = 1;
        self.layer.mask = nil;
    }

}

- (void)setUp
{
    //set default properties
    _reflectionGap = 0.0f;
    _reflectionScale = 0.5f;
    _reflectionAlpha = 0.5f;
    
    //update reflection
    [self setNeedsLayout];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder]))
    {
        [self setUp];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
    {
        [self setUp];
    }
    return self;
}

- (void)setReflectionGap:(CGFloat)reflectionGap
{
    _reflectionGap = reflectionGap;
}

- (void)setReflectionScale:(CGFloat)reflectionScale
{
    _reflectionScale = reflectionScale;
}

- (void)setReflectionAlpha:(CGFloat)reflectionAlpha
{
    _reflectionAlpha = reflectionAlpha;
}

- (void)setIsReflection:(BOOL)isReflection{
    _isReflection = isReflection;
}


@end