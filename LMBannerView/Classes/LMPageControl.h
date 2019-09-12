//
//  LMPageControl.h
//  LMBannerViewDemo
//
//  Created by LM on 2019/9/11.
//  Copyright © 2019 LM. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LMPageControl : UIControl

/// default is 0
@property(nonatomic, assign) NSInteger numberOfPages;

/// default is 0. value pinned to 0..numberOfPages-1
@property(nonatomic, assign) NSInteger currentPage;

/// hide the the indicator if there is only one page. default is NO
@property (nonatomic, assign) BOOL hidesForSinglePage;

/// page space
@property (nonatomic, assign) CGFloat pageIndicatorSpaing;

/// center will ignore this
@property (nonatomic, assign) UIEdgeInsets contentInset;

/// real content size
@property (nonatomic, assign ,readonly) CGSize contentSize;

/// indicator tint color
@property (nonatomic, strong, nullable) UIColor *pageIndicatorTintColor;
@property (nonatomic, strong, nullable) UIColor *currentPageIndicatorTintColor;

/// indicator image
@property (nonatomic, strong, nullable) UIImage *pageIndicatorImage;
@property (nonatomic, strong, nullable) UIImage *currentPageIndicatorImage;

/// default is UIViewContentModeCenter
@property (nonatomic, assign) UIViewContentMode indicatorImageContentMode;

/// indicator size
@property (nonatomic, assign) CGSize pageIndicatorSize;
@property (nonatomic, assign) CGSize currentPageIndicatorSize;

/// default 0.3
@property (nonatomic, assign) CGFloat animateDuring;

- (void)setCurrentPage:(NSInteger)currentPage animate:(BOOL)animate;

@end

NS_ASSUME_NONNULL_END
