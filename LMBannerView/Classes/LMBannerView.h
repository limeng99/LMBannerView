//
//  LMBannerView.h
//  LMBannerViewDemo
//
//  Created by LM on 2019/9/12.
//  Copyright © 2019 LM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LMBannerViewLayout.h"

NS_ASSUME_NONNULL_BEGIN

typedef struct {
    NSInteger index;
    NSInteger section;
}LMIndexSection;

typedef NS_ENUM(NSUInteger, LMBannerScorllDirection) {
    LMBannerScorllDirectionLeft,
    LMBannerScorllDirectionRight,
};


@class LMBannerView;
@protocol LMBannerViewDataSource <NSObject>

/// item number
- (NSInteger)numberOfItemsInBannerView:(LMBannerView *)bannerView;

/// banner layout
- (LMPageLayout *)layoutForBannerView:(LMBannerView *)bannerView;

/// banner item cell
- (__kindof UICollectionViewCell *)bannerView:(LMBannerView *)bannerView cellForItemAtIndex:(NSInteger)index;

@end


@protocol LMBannerViewDelegate <NSObject>

@optional

/// banner did scroll to new index page
- (void)bannerView:(LMBannerView *)pageView didScrollFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex;

/// banner did selected item cell
- (void)bannerView:(LMBannerView *)bannerView didSelectedItemCell:(__kindof UICollectionViewCell *)cell atIndex:(NSInteger)index;
- (void)bannerView:(LMBannerView *)bannerView didSelectedItemCell:(__kindof UICollectionViewCell *)cell atIndexSection:(LMIndexSection)indexSection;

/// custom layout
- (void)bannerView:(LMBannerView *)bannerView initializeLayoutAttributes:(UICollectionViewLayoutAttributes *)attributes;
- (void)bannerView:(LMBannerView *)bannerView applyLayoutToAttributes:(UICollectionViewLayoutAttributes *)attributes;

/// scrollview delegate
- (void)bannerViewDidScroll:(LMBannerView *)bannerView;
- (void)bannerViewWillBeginDragging:(LMBannerView *)bannerView;
- (void)bannerViewDidEndDragging:(LMBannerView *)bannerView willDecelerate:(BOOL)decelerate;
- (void)bannerViewWillBeginDecelerating:(LMBannerView *)bannerView;
- (void)bannerViewDidEndDecelerating:(LMBannerView *)bannerView;
- (void)bannerViewWillBeginScrollingAnimation:(LMBannerView *)bannerView;
- (void)bannerViewDidEndScrollingAnimation:(LMBannerView *)bannerView;

@end


@interface LMBannerView : UIView

/// datasource
@property (nonatomic, weak, nullable) id<LMBannerViewDataSource> dataSource;

/// delegate
@property (nonatomic, weak, nullable) id<LMBannerViewDelegate> delegate;

/// don't set datasource and delegate
@property (nonatomic, weak, readonly) UICollectionView *collectionView;

/// banner view layout
@property (nonatomic, strong, readonly) LMPageLayout *layout;

/// will be automatically resized to track the size of the bannerview
@property (nonatomic, strong, nullable) UIView *backgroundView;

///  is infinite cycle bannerview
@property (nonatomic, assign) BOOL isInfiniteLoop;

/// bannerview automatic scroll time interval, default 0, disable automatic
@property (nonatomic, assign) CGFloat autoScrollInterval;

/// bannerview reload data when reset index
@property (nonatomic, assign) BOOL reloadDataNeedResetIndex;

/// bannerview current index
@property (nonatomic, assign, readonly) NSInteger currentIndex;
@property (nonatomic, assign, readonly) LMIndexSection indexSection;

/// scrollView property
@property (nonatomic, assign, readonly) CGPoint contentOffset;
@property (nonatomic, assign, readonly) BOOL tracking;
@property (nonatomic, assign, readonly) BOOL dragging;
@property (nonatomic, assign, readonly) BOOL decelerating;

/// reload data, !!important!!: will clear layout and call delegate layoutForBannerView
- (void)reloadData;

/// update data is reload data, but not clear layuot
- (void)updateData;

/// if you only want update layout
- (void)setNeedUpdateLayout;

/// will set layout nil and call delegate layoutForBannerView
- (void)setNeedClearLayout;

/// current index cell in bannerview
- (__kindof UICollectionViewCell * _Nullable)currentIndexCell;

/// visible cells in bannerview
- (NSArray<__kindof UICollectionViewCell *> *_Nullable)visibleCells;

/// visible bannerview indexs, maybe repeat index
- (NSArray *)visibleIndexs;

/// scroll to item at index
- (void)scrollToItemAtIndex:(NSInteger)index animate:(BOOL)animate;
- (void)scrollToItemAtIndexSection:(LMIndexSection)indexSection animate:(BOOL)animate;

/// scroll to next or pre item
- (void)scrollToNearlyIndexAtDirection:(LMBannerScorllDirection)direction animate:(BOOL)animate;

/// register banner view cell with class
- (void)registerClass:(Class)Class forCellWithReuseIdentifier:(NSString *)identifier;

/// register pager view cell with nib
- (void)registerNib:(UINib *)nib forCellWithReuseIdentifier:(NSString *)identifier;

/// dequeue reusable cell for pagerView
- (__kindof UICollectionViewCell *)dequeueReusableCellWithReuseIdentifier:(NSString *)identifier forIndex:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
