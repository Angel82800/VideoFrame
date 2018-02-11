//
//  iCarousel.h
//  DreamClouds
//
//  Created by Yinjing Li and Frederick Weber on 1/29/13.
//  Copyright (c) 2013 __MontanaSky_Networks_Inc__. All rights reserved.
//

#ifndef ah_retain
#if __has_feature(objc_arc)
#define ah_retain self
#define ah_dealloc self
#define release self
#define autorelease self
#else
#define ah_retain retain
#define ah_dealloc dealloc
#define __bridge
#endif
#endif

//  Weak delegate support

#ifndef ah_weak
#import <Availability.h>
#if (__has_feature(objc_arc)) && \
((defined __IPHONE_OS_VERSION_MIN_REQUIRED && \
__IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_5_0) || \
(defined __MAC_OS_X_VERSION_MIN_REQUIRED && \
__MAC_OS_X_VERSION_MIN_REQUIRED > __MAC_10_7))
#define ah_weak weak
#define __ah_weak __weak
#else
#define ah_weak unsafe_unretained
#define __ah_weak __unsafe_unretained
#endif
#endif

//  ARC Helper ends


#import <QuartzCore/QuartzCore.h>
#ifdef USING_CHAMELEON
#define ICAROUSEL_IOS
#elif defined __IPHONE_OS_VERSION_MAX_ALLOWED
#define ICAROUSEL_IOS
typedef CGRect NSRect;
typedef CGSize NSSize;
#else
#define ICAROUSEL_MACOS
#endif


#ifdef ICAROUSEL_IOS
#import <UIKit/UIKit.h>
#else
#import <Cocoa/Cocoa.h>
typedef NSView UIView;
#endif


typedef enum
{
    iCarouselTypeLinear = 0,
    iCarouselTypeRotary,
    iCarouselTypeInvertedRotary,
    iCarouselTypeCylinder,
    iCarouselTypeInvertedCylinder,
    iCarouselTypeWheel,
    iCarouselTypeInvertedWheel,
    iCarouselTypeCoverFlow,
    iCarouselTypeCoverFlow2,
    iCarouselTypeTimeMachine,
    iCarouselTypeInvertedTimeMachine,
    iCarouselTypeCustom
}
iCarouselType;


typedef enum
{
    iCarouselOptionWrap = 0,
    iCarouselOptionShowBackfaces,
    iCarouselOptionOffsetMultiplier,
    iCarouselOptionVisibleItems,
    iCarouselOptionCount,
    iCarouselOptionArc,
	iCarouselOptionAngle,
    iCarouselOptionRadius,
    iCarouselOptionTilt,
    iCarouselOptionSpacing,
    iCarouselOptionFadeMin,
    iCarouselOptionFadeMax,
    iCarouselOptionFadeRange
}
iCarouselOption;


@protocol iCarouselDataSource, iCarouselDelegate;

@interface iCarousel : UIView

//required for 32-bit Macs
#ifdef __i386__
{
	@private
	
    id<iCarouselDelegate> __ah_weak _delegate;
    id<iCarouselDataSource> __ah_weak _dataSource;
    
    iCarouselType _type;
    
    NSInteger _numberOfItems;
    NSInteger _numberOfPlaceholders;
	NSInteger _numberOfPlaceholdersToShow;
    NSInteger _numberOfVisibleItems;
    NSInteger _previousItemIndex;
    NSInteger _animationDisableCount;
    
    UIView *_contentView;
    
    NSMutableDictionary *_itemViews;
    
    NSMutableSet *_itemViewPool;
    NSMutableSet *_placeholderViewPool;
    
    CGFloat _itemWidth;
    CGFloat _scrollOffset;
    CGFloat _offsetMultiplier;
    CGFloat _startVelocity;
    CGFloat _decelerationRate;
    CGFloat _startOffset;
    CGFloat _endOffset;
    CGFloat _previousTranslation;
    CGFloat _perspective;
    CGFloat _scrollSpeed;
    CGFloat _bounceDistance;
    CGFloat _toggle;

    NSTimer __unsafe_unretained *_timer;
    
    BOOL _decelerating;
    BOOL _scrollEnabled;
    BOOL _bounces;
    BOOL _scrolling;
    BOOL _centerItemWhenSelected;
    BOOL _wrapEnabled;
    BOOL _dragging;
    BOOL _didDrag;
    BOOL _stopAtItemBoundary;
    BOOL _scrollToItemBoundary;
    BOOL _vertical;
    BOOL _ignorePerpendicularSwipes;

    CGSize _contentOffset;
    CGSize _viewpointOffset;
    
    NSTimeInterval _scrollDuration;
    NSTimeInterval _startTime;
    NSTimeInterval _toggleTime;
}

#endif

@property (nonatomic, ah_weak) id<iCarouselDataSource> dataSource;
@property (nonatomic, ah_weak) id<iCarouselDelegate> delegate;

@property (nonatomic, assign) iCarouselType type;

@property (nonatomic, assign) CGFloat perspective;
@property (nonatomic, assign) CGFloat decelerationRate;
@property (nonatomic, assign) CGFloat scrollSpeed;
@property (nonatomic, assign) CGFloat bounceDistance;
@property (nonatomic, assign) CGFloat scrollOffset;
@property (nonatomic, readonly) CGFloat offsetMultiplier;
@property (nonatomic, readonly) CGFloat itemWidth;
@property (nonatomic, readonly) CGFloat toggle;

@property (nonatomic, assign, getter = isScrollEnabled) BOOL scrollEnabled;
@property (nonatomic, assign, getter = isVertical) BOOL vertical;
@property (nonatomic, readonly, getter = isWrapEnabled) BOOL wrapEnabled;

@property (nonatomic, assign) BOOL bounces;
@property (nonatomic, assign) BOOL stopAtItemBoundary;
@property (nonatomic, assign) BOOL scrollToItemBoundary;
@property (nonatomic, assign) BOOL ignorePerpendicularSwipes;
@property (nonatomic, assign) BOOL centerItemWhenSelected;

@property (nonatomic, assign) CGSize contentOffset;
@property (nonatomic, assign) CGSize viewpointOffset;

@property (nonatomic, readonly) NSInteger numberOfItems;
@property (nonatomic, readonly) NSInteger numberOfPlaceholders;
@property (nonatomic, assign) NSInteger currentItemIndex;
@property (nonatomic, readonly) NSInteger numberOfVisibleItems;

@property (nonatomic, strong, readonly) UIView *currentItemView;
@property (nonatomic, strong, readonly) UIView *contentView;

@property (nonatomic, strong, readonly) NSArray *indexesForVisibleItems;
@property (nonatomic, strong, readonly) NSArray *visibleItemViews;

@property (nonatomic, readonly, getter = isDragging) BOOL dragging;
@property (nonatomic, readonly, getter = isDecelerating) BOOL decelerating;
@property (nonatomic, readonly, getter = isScrolling) BOOL scrolling;

- (void)scrollByOffset:(CGFloat)offset duration:(NSTimeInterval)duration;
- (void)scrollToOffset:(CGFloat)offset duration:(NSTimeInterval)duration;
- (void)scrollByNumberOfItems:(NSInteger)itemCount duration:(NSTimeInterval)duration;
- (void)scrollToItemAtIndex:(NSInteger)index duration:(NSTimeInterval)duration;
- (void)scrollToItemAtIndex:(NSInteger)index animated:(BOOL)animated;

- (UIView *)itemViewAtIndex:(NSInteger)index;
- (NSInteger)indexOfItemView:(UIView *)view;
- (NSInteger)indexOfItemViewOrSubview:(UIView *)view;
- (CGFloat)offsetForItemAtIndex:(NSInteger)index;

- (void)removeItemAtIndex:(NSInteger)index animated:(BOOL)animated;
- (void)insertItemAtIndex:(NSInteger)index animated:(BOOL)animated;
- (void)reloadItemAtIndex:(NSInteger)index animated:(BOOL)animated;

- (void)reloadData;

@end


@protocol iCarouselDataSource <NSObject>

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel;
- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view;

@optional

- (NSUInteger)numberOfPlaceholdersInCarousel:(iCarousel *)carousel;
- (UIView *)carousel:(iCarousel *)carousel placeholderViewAtIndex:(NSUInteger)index reusingView:(UIView *)view;

@end


@protocol iCarouselDelegate <NSObject>
@optional

- (void)carouselWillBeginScrollingAnimation:(iCarousel *)carousel;
- (void)carouselDidEndScrollingAnimation:(iCarousel *)carousel;
- (void)carouselDidScroll:(iCarousel *)carousel;
- (void)carouselCurrentItemIndexDidChange:(iCarousel *)carousel;
- (void)carouselWillBeginDragging:(iCarousel *)carousel;
- (void)carouselDidEndDragging:(iCarousel *)carousel willDecelerate:(BOOL)decelerate;
- (void)carouselWillBeginDecelerating:(iCarousel *)carousel;
- (void)carouselDidEndDecelerating:(iCarousel *)carousel;

- (BOOL)carousel:(iCarousel *)carousel shouldSelectItemAtIndex:(NSInteger)index;
- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index;

- (CGFloat)carouselItemWidth:(iCarousel *)carousel;
- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value;

- (CATransform3D)carousel:(iCarousel *)carousel itemTransformForOffset:(CGFloat)offset baseTransform:(CATransform3D)transform;

@end


@protocol iCarouselDeprecated
@optional

//deprecated delegate and datasource methods
//use carousel:valueForOption:withDefault: instead

- (NSUInteger)numberOfVisibleItemsInCarousel:(iCarousel *)carousel;
- (void)carouselCurrentItemIndexUpdated:(iCarousel *)carousel __attribute__((deprecated));
- (BOOL)carouselShouldWrap:(iCarousel *)carousel __attribute__((deprecated));
- (CGFloat)carouselOffsetMultiplier:(iCarousel *)carousel __attribute__((deprecated));
- (CGFloat)carousel:(iCarousel *)carousel itemAlphaForOffset:(CGFloat)offset __attribute__((deprecated));
- (CGFloat)carousel:(iCarousel *)carousel valueForTransformOption:(iCarouselOption)option withDefault:(CGFloat)value __attribute__((deprecated));

@end