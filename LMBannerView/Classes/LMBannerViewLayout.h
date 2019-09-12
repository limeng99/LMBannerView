//
//  LMBannerViewLayout.h
//  LMBannerViewDemo
//
//  Created by LM on 2019/9/11.
//  Copyright © 2019 LM. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, LMBannerViewLayoutType) {
    LMBannerViewLayoutNormal,
    LMBannerViewLayoutLinear,
    LMBannerViewLayoutCoverflow,
};

@class LMBannerViewLayout;
@protocol LMBannerViewLayoutDelegate <NSObject>

// initialize layout attributes
- (void)bannerViewLayout:(LMBannerViewLayout *)bannerViewLayout initializeLayoutAttributes:(UICollectionViewLayoutAttributes *)attributes;

// apply layout attributes
- (void)bannerViewLayout:(LMBannerViewLayout *)bannerViewLayout applyLayoutToAttributes:(UICollectionViewLayoutAttributes *)attributes;

@end


@interface LMPageLayout : NSObject

/// item size
@property (nonatomic, assign) CGSize itemSize;

/// item spacing
@property (nonatomic, assign) CGFloat itemSpacing;

/// default 0.8
@property (nonatomic, assign) CGFloat minimumScale;

/// default 1.0
@property (nonatomic, assign) CGFloat minimumAlpha;

/// default 0.2, angle is %
@property (nonatomic, assign) CGFloat maximumAngle;

/// infinte scroll
@property (nonatomic, assign) BOOL isInfiniteLoop;

/// scale and angle change rate
@property (nonatomic, assign) CGFloat rateOfChange;

/// adjust spacing when scroling
@property (nonatomic, assign) BOOL adjustSpacingWhenScroling;

/// pageView cell item vertical centering
@property (nonatomic, assign) BOOL itemVerticalCenter;

/// first and last item horizontalc enter, when isInfiniteLoop is NO
@property (nonatomic, assign) BOOL itemHorizontalCenter;

/// section inset
@property (nonatomic, assign) UIEdgeInsets sectionInset;

/// section inset
@property (nonatomic, assign, readonly) UIEdgeInsets onlyOneSectionInset;
@property (nonatomic, assign, readonly) UIEdgeInsets firstSectionInset;
@property (nonatomic, assign, readonly) UIEdgeInsets lastSectionInset;
@property (nonatomic, assign, readonly) UIEdgeInsets middleSectionInset;

@property (nonatomic, assign) LMBannerViewLayoutType layoutType;

@end


@interface LMBannerViewLayout : UICollectionViewFlowLayout

@property (nonatomic, strong) LMPageLayout *layout;

@property (nonatomic, weak, nullable) id<LMBannerViewLayoutDelegate> delegate;

@end


NS_ASSUME_NONNULL_END
