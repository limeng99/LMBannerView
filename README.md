# LMBannerView

## 项目介绍

一个简单而实用的循环页导航视图和自动滚动条视图，包括自定义pageControl

![image](https://github.com/limeng99/LMBannerView/blob/master/Example/LMBannerView.gif)

## 集成方式

```ruby
pod 'LMBannerView'~>0.1.1
```

## API

*  DataSource and Delegate 
```objc

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

@end

```

* Class
```objc

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

```

