//
//  LMBannerView.m
//  LMBannerViewDemo
//
//  Created by LM on 2019/9/12.
//  Copyright © 2019 LM. All rights reserved.
//

#import "LMBannerView.h"

NS_INLINE BOOL LMEqualIndexSection(LMIndexSection indexSection1,LMIndexSection indexSection2) {
    return indexSection1.index == indexSection2.index && indexSection1.section == indexSection2.section;
}

NS_INLINE LMIndexSection LMMakeIndexSection(NSInteger index, NSInteger section) {
    LMIndexSection indexSection;
    indexSection.index = index;
    indexSection.section = section;
    return indexSection;
}

@interface LMBannerView ()<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, LMBannerViewLayoutDelegate> {
    struct {
        unsigned int bannerViewDidScroll   :1;
        unsigned int didScrollFromIndexToNewIndex   :1;
        unsigned int initializeLayoutAttributes   :1;
        unsigned int applyLayoutToAttributes   :1;
    }_delegateFlags;
    struct {
        unsigned int cellForItemAtIndex   :1;
        unsigned int layoutForBannerView   :1;
    }_dataSourceFlags;
}

@property (nonatomic, weak) UICollectionView *collectionView;
@property (nonatomic, strong) LMPageLayout *layout;
@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, assign) NSInteger numberOfItems;
@property (nonatomic, assign) NSInteger dequeueSection;
@property (nonatomic, assign) LMIndexSection beginDragIndexSection;
@property (nonatomic, assign) NSInteger firstScrollIndex;

@property (nonatomic, assign) BOOL needClearLayout;
@property (nonatomic, assign) BOOL didReloadData;
@property (nonatomic, assign) BOOL didLayout;
@property (nonatomic, assign) BOOL needResetIndex;

@end

#define kBannerViewMaxSectionCount 200
#define kBannerViewMinSectionCount 18

@implementation LMBannerView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self configureProperty];
        [self addCollectionView];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self configureProperty];
        [self addCollectionView];
    }
    return self;
}

- (void)configureProperty {
    _needResetIndex = NO;
    _didReloadData = NO;
    _didLayout = NO;
    _isInfiniteLoop = YES;
    _autoScrollInterval = 0;
    _beginDragIndexSection.index = 0;
    _beginDragIndexSection.section = 0;
    _indexSection.index = -1;
    _indexSection.section = -1;
    _firstScrollIndex = -1;
}

- (void)addCollectionView {
    LMBannerViewLayout *layout = [[LMBannerViewLayout alloc] init];
    UICollectionView *collectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:layout];
    layout.delegate = _delegateFlags.applyLayoutToAttributes ? self : nil;;
    collectionView.backgroundColor = [UIColor clearColor];
    collectionView.dataSource = self;
    collectionView.delegate = self;
    collectionView.pagingEnabled = NO;
    collectionView.decelerationRate = 1 - 0.0076;
    if (@available(iOS 10.0, *)) {
        collectionView.prefetchingEnabled = NO;
    }
    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.showsVerticalScrollIndicator = NO;
    [self addSubview:collectionView];
    _collectionView = collectionView;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    if (!newSuperview) {
        [self removeTimer];
    }else {
        [self removeTimer];
        if (_autoScrollInterval > 0) {
            [self addTimer];
        }
    }
}

#pragma mark - timer
- (void)addTimer {
    if (_timer || _autoScrollInterval <= 0) {
        return;
    }
    _timer = [NSTimer timerWithTimeInterval:_autoScrollInterval target:self selector:@selector(timerFired:) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

- (void)removeTimer {
    if (!_timer) {
        return;
    }
    [_timer invalidate];
    _timer = nil;
}

- (void)timerFired:(NSTimer *)timer {
    if (!self.superview || !self.window || _numberOfItems == 0 || self.tracking) {
        return;
    }
    [self scrollToNearlyIndexAtDirection:LMBannerScorllDirectionRight animate:YES];
}

#pragma mark - getter
- (LMPageLayout *)layout {
    if (!_layout) {
        if (_dataSourceFlags.layoutForBannerView) {
            _layout = [_dataSource layoutForBannerView:self];
            _layout.isInfiniteLoop = _isInfiniteLoop;
        }
        if (_layout.itemSize.width <= 0 || _layout.itemSize.height <= 0) {
            _layout = nil;
        }
    }
    return _layout;
}

- (NSInteger)currentIndex {
    return _indexSection.index;
}

- (CGPoint)contentOffset {
    return _collectionView.contentOffset;
}

- (BOOL)tracking {
    return _collectionView.tracking;
}

- (BOOL)dragging {
    return _collectionView.dragging;
}

- (BOOL)decelerating {
    return _collectionView.decelerating;
}

- (UIView *)backgroundView {
    return _collectionView.backgroundView;
}

- (__kindof UICollectionViewCell *)currentIndexCell {
    return [_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:_indexSection.index inSection:_indexSection.section]];
}

- (NSArray<__kindof UICollectionViewCell *> *)visibleCells {
    return _collectionView.visibleCells;
}

- (NSArray *)visibleIndexs {
    NSMutableArray *indexs = [NSMutableArray array];
    for (NSIndexPath *indexPath in _collectionView.indexPathsForVisibleItems) {
        [indexs addObject:@(indexPath.item)];
    }
    return [indexs copy];
}

#pragma mark - setter
- (void)setBackgroundView:(UIView *)backgroundView {
    [_collectionView setBackgroundView:backgroundView];
}

- (void)setAutoScrollInterval:(CGFloat)autoScrollInterval {
    _autoScrollInterval = autoScrollInterval;
    [self removeTimer];
    if (autoScrollInterval > 0 && self.superview) {
        [self addTimer];
    }
}

- (void)setDelegate:(id<LMBannerViewDelegate>)delegate {
    _delegate = delegate;
    _delegateFlags.bannerViewDidScroll = [delegate respondsToSelector:@selector(bannerViewDidScroll:)];
    _delegateFlags.didScrollFromIndexToNewIndex = [delegate respondsToSelector:@selector(bannerView:didScrollFromIndex:toIndex:)];
    _delegateFlags.initializeLayoutAttributes = [delegate respondsToSelector:@selector(bannerView:initializeLayoutAttributes:)];
    _delegateFlags.applyLayoutToAttributes = [delegate respondsToSelector:@selector(bannerView:applyLayoutToAttributes:)];
    if (self.collectionView && self.collectionView.collectionViewLayout) {
        ((LMBannerViewLayout *)self.collectionView.collectionViewLayout).delegate = _delegateFlags.applyLayoutToAttributes ? self : nil;
    }
}

- (void)setDataSource:(id<LMBannerViewDataSource>)dataSource {
    _dataSource = dataSource;
    _dataSourceFlags.cellForItemAtIndex = [dataSource respondsToSelector:@selector(bannerView:cellForItemAtIndex:)];
    _dataSourceFlags.layoutForBannerView = [dataSource respondsToSelector:@selector(layoutForBannerView:)];
}

#pragma mark - public
- (void)reloadData {
    _didReloadData = YES;
    _needResetIndex = YES;
    [self setNeedClearLayout];
    [self clearLayout];
    [self updateData];
}

- (void)updateData {
    [self updateLayout];
    _numberOfItems = [_dataSource numberOfItemsInBannerView:self];
    [_collectionView reloadData];
    if (!_didLayout && !CGRectIsEmpty(self.collectionView.frame) && _indexSection.index < 0) {
        _didLayout = YES;
    }
    BOOL needResetIndex = _needResetIndex && _reloadDataNeedResetIndex;
    _needResetIndex = NO;
    if (needResetIndex) {
        [self removeTimer];
    }
    [self resetBannerViewAtIndex:(_indexSection.index < 0 && !CGRectIsEmpty(self.collectionView.frame)) || needResetIndex ? 0 :_indexSection.index];
    if (needResetIndex) {
        [self addTimer];
    }
}

- (void)scrollToNearlyIndexAtDirection:(LMBannerScorllDirection)direction animate:(BOOL)animate {
    LMIndexSection indexSection = [self nearlyIndexPathAtDirection:direction];
    [self scrollToItemAtIndexSection:indexSection animate:animate];
}

- (void)scrollToItemAtIndex:(NSInteger)index animate:(BOOL)animate {
    if (!_didLayout && _didReloadData) {
        _firstScrollIndex = index;
    }else {
        _firstScrollIndex = -1;
    }
    if (!_isInfiniteLoop) {
        [self scrollToItemAtIndexSection:LMMakeIndexSection(index, 0) animate:animate];
        return;
    }
    
    [self scrollToItemAtIndexSection:LMMakeIndexSection(index, index >= self.currentIndex ? _indexSection.section : _indexSection.section+1) animate:animate];
}

- (void)scrollToItemAtIndexSection:(LMIndexSection)indexSection animate:(BOOL)animate {
    if (_numberOfItems <= 0 || ![self isValidIndexSection:indexSection]) {
        //NSLog(@"scrollToItemAtIndex: item indexSection is invalid!");
        return;
    }
    
    if (animate && [_delegate respondsToSelector:@selector(bannerViewWillBeginScrollingAnimation:)]) {
        [_delegate bannerViewWillBeginScrollingAnimation:self];
    }
    CGFloat offset = [self caculateOffsetXAtIndexSection:indexSection];
    [_collectionView setContentOffset:CGPointMake(offset, _collectionView.contentOffset.y) animated:animate];
}

- (void)registerClass:(Class)Class forCellWithReuseIdentifier:(NSString *)identifier {
    [_collectionView registerClass:Class forCellWithReuseIdentifier:identifier];
}

- (void)registerNib:(UINib *)nib forCellWithReuseIdentifier:(NSString *)identifier {
    [_collectionView registerNib:nib forCellWithReuseIdentifier:identifier];
}

- (__kindof UICollectionViewCell *)dequeueReusableCellWithReuseIdentifier:(NSString *)identifier forIndex:(NSInteger)index {
    UICollectionViewCell *cell = [_collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:[NSIndexPath indexPathForItem:index inSection:_dequeueSection]];
    return cell;
}

#pragma mark - layout
- (void)updateLayout {
    if (!self.layout) {
        return;
    }
    self.layout.isInfiniteLoop = _isInfiniteLoop;
    ((LMBannerViewLayout *)_collectionView.collectionViewLayout).layout = self.layout;
}

- (void)clearLayout {
    if (_needClearLayout) {
        _layout = nil;
        _needClearLayout = NO;
    }
}

- (void)setNeedClearLayout {
    _needClearLayout = YES;
}

- (void)setNeedUpdateLayout {
    if (!self.layout) {
        return;
    }
    [self clearLayout];
    [self updateLayout];
    [_collectionView.collectionViewLayout invalidateLayout];
    [self resetBannerViewAtIndex:_indexSection.index < 0 ? 0 :_indexSection.index];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    BOOL needUpdateLayout = !CGRectEqualToRect(_collectionView.frame, self.bounds);
    _collectionView.frame = self.bounds;
    if ((_indexSection.section < 0 || needUpdateLayout) && (_numberOfItems > 0 || _didReloadData)) {
        _didLayout = YES;
        [self setNeedUpdateLayout];
    }
}

#pragma mark - banner index
- (BOOL)isValidIndexSection:(LMIndexSection)indexSection {
    return indexSection.index >= 0 && indexSection.index < _numberOfItems && indexSection.section >= 0 && indexSection.section < kBannerViewMaxSectionCount;
}

- (LMIndexSection)nearlyIndexPathAtDirection:(LMBannerScorllDirection)direction{
    return [self nearlyIndexPathForIndexSection:_indexSection direction:direction];
}

- (LMIndexSection)nearlyIndexPathForIndexSection:(LMIndexSection)indexSection direction:(LMBannerScorllDirection)direction {
    if (indexSection.index < 0 || indexSection.index >= _numberOfItems) {
        return indexSection;
    }
    
    if (!_isInfiniteLoop) {
        if (direction == LMBannerScorllDirectionRight && indexSection.index == _numberOfItems - 1) {
            return _autoScrollInterval > 0 ? LMMakeIndexSection(0, 0) : indexSection;
        } else if (direction == LMBannerScorllDirectionRight) {
            return LMMakeIndexSection(indexSection.index+1, 0);
        }
        
        if (indexSection.index == 0) {
            return _autoScrollInterval > 0 ? LMMakeIndexSection(_numberOfItems - 1, 0) : indexSection;
        }
        return LMMakeIndexSection(indexSection.index-1, 0);
    }
    
    if (direction == LMBannerScorllDirectionRight) {
        if (indexSection.index < _numberOfItems-1) {
            return LMMakeIndexSection(indexSection.index+1, indexSection.section);
        }
        if (indexSection.section >= kBannerViewMaxSectionCount-1) {
            return LMMakeIndexSection(indexSection.index, kBannerViewMaxSectionCount-1);
        }
        return LMMakeIndexSection(0, indexSection.section+1);
    }
    
    if (indexSection.index > 0) {
        return LMMakeIndexSection(indexSection.index-1, indexSection.section);
    }
    if (indexSection.section <= 0) {
        return LMMakeIndexSection(indexSection.index, 0);
    }
    return LMMakeIndexSection(_numberOfItems-1, indexSection.section-1);
}

- (LMIndexSection)caculateIndexSectionWithOffsetX:(CGFloat)offsetX {
    if (_numberOfItems <= 0) {
        return LMMakeIndexSection(0, 0);
    }
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)_collectionView.collectionViewLayout;
    CGFloat leftEdge = _isInfiniteLoop ? _layout.sectionInset.left : _layout.onlyOneSectionInset.left;
    CGFloat width = CGRectGetWidth(_collectionView.frame);
    CGFloat middleOffset = offsetX + width/2;
    CGFloat itemWidth = layout.itemSize.width + layout.minimumInteritemSpacing;
    NSInteger curIndex = 0;
    NSInteger curSection = 0;
    if (middleOffset - leftEdge >= 0) {
        NSInteger itemIndex = (middleOffset - leftEdge+layout.minimumInteritemSpacing/2)/itemWidth;
        if (itemIndex < 0) {
            itemIndex = 0;
        }else if (itemIndex >= _numberOfItems*kBannerViewMaxSectionCount) {
            itemIndex = _numberOfItems*kBannerViewMaxSectionCount - 1;
        }
        curIndex = itemIndex%_numberOfItems;
        curSection = itemIndex/_numberOfItems;
    }
    return LMMakeIndexSection(curIndex, curSection);
}

- (CGFloat)caculateOffsetXAtIndexSection:(LMIndexSection)indexSection{
    if (_numberOfItems == 0) {
        return 0;
    }
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)_collectionView.collectionViewLayout;
    UIEdgeInsets edge = _isInfiniteLoop ? _layout.sectionInset : _layout.onlyOneSectionInset;
    CGFloat leftEdge = edge.left;
    CGFloat rightEdge = edge.right;
    CGFloat width = CGRectGetWidth(_collectionView.frame);
    CGFloat itemWidth = layout.itemSize.width + layout.minimumInteritemSpacing;
    CGFloat offsetX = 0;
    if (!_isInfiniteLoop && !_layout.itemHorizontalCenter && indexSection.index == _numberOfItems - 1) {
        offsetX = leftEdge + itemWidth*(indexSection.index + indexSection.section*_numberOfItems) - (width - itemWidth) -  layout.minimumInteritemSpacing + rightEdge;
    }else {
        offsetX = leftEdge + itemWidth*(indexSection.index + indexSection.section*_numberOfItems) - layout.minimumInteritemSpacing/2 - (width - itemWidth)/2;
    }
    return MAX(offsetX, 0);
}

- (void)resetBannerViewAtIndex:(NSInteger)index {
    if (_didLayout && _firstScrollIndex >= 0) {
        index = _firstScrollIndex;
        _firstScrollIndex = -1;
    }
    if (index < 0) {
        return;
    }
    if (index >= _numberOfItems) {
        index = 0;
    }
    [self scrollToItemAtIndexSection:LMMakeIndexSection(index, _isInfiniteLoop ? kBannerViewMaxSectionCount/3 : 0) animate:NO];
    if (!_isInfiniteLoop && _indexSection.index < 0) {
        [self scrollViewDidScroll:_collectionView];
    }
}

- (void)recycleBannerViewIfNeed {
    if (!_isInfiniteLoop) {
        return;
    }
    if (_indexSection.section > kBannerViewMaxSectionCount - kBannerViewMinSectionCount || _indexSection.section < kBannerViewMinSectionCount) {
        [self resetBannerViewAtIndex:_indexSection.index];
    }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return _isInfiniteLoop ? kBannerViewMaxSectionCount : 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    _numberOfItems = [_dataSource numberOfItemsInBannerView:self];
    return _numberOfItems;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    _dequeueSection = indexPath.section;
    if (_dataSourceFlags.cellForItemAtIndex) {
        return [_dataSource bannerView:self cellForItemAtIndex:indexPath.row];
    }
    NSAssert(NO, @"bannerView: cellForItemAtIndex: is nil!");
    return nil;
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    if (!_isInfiniteLoop) {
        return _layout.onlyOneSectionInset;
    }
    if (section == 0 ) {
        return _layout.firstSectionInset;
    }else if (section == kBannerViewMaxSectionCount -1) {
        return _layout.lastSectionInset;
    }
    return _layout.middleSectionInset;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    if ([_delegate respondsToSelector:@selector(bannerView:didSelectedItemCell:atIndex:)]) {
        [_delegate bannerView:self didSelectedItemCell:cell atIndex:indexPath.item];
    }
    if ([_delegate respondsToSelector:@selector(bannerView:didSelectedItemCell:atIndexSection:)]) {
        [_delegate bannerView:self didSelectedItemCell:cell atIndexSection:LMMakeIndexSection(indexPath.item, indexPath.section)];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (!_didLayout) {
        return;
    }
    LMIndexSection newIndexSection =  [self caculateIndexSectionWithOffsetX:scrollView.contentOffset.x];
    if (_numberOfItems <= 0 || ![self isValidIndexSection:newIndexSection]) {
        NSLog(@"inVlaidIndexSection:(%ld,%ld)!",(long)newIndexSection.index,(long)newIndexSection.section);
        return;
    }
    LMIndexSection indexSection = _indexSection;
    _indexSection = newIndexSection;
    
    if (_delegateFlags.bannerViewDidScroll) {
        [_delegate bannerViewDidScroll:self];
    }
    
    if (_delegateFlags.didScrollFromIndexToNewIndex && !LMEqualIndexSection(_indexSection, indexSection)) {
        [_delegate bannerView:self didScrollFromIndex:MAX(indexSection.index, 0) toIndex:_indexSection.index];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (_autoScrollInterval > 0) {
        [self removeTimer];
    }
    _beginDragIndexSection = [self caculateIndexSectionWithOffsetX:scrollView.contentOffset.x];
    if ([_delegate respondsToSelector:@selector(bannerViewWillBeginDragging:)]) {
        [_delegate bannerViewWillBeginDragging:self];
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if (fabs(velocity.x) < 0.35 || !LMEqualIndexSection(_beginDragIndexSection, _indexSection)) {
        targetContentOffset->x = [self caculateOffsetXAtIndexSection:_indexSection];
        return;
    }
    LMBannerScorllDirection direction = LMBannerScorllDirectionRight;
    if ((scrollView.contentOffset.x < 0 && targetContentOffset->x <= 0) || (targetContentOffset->x < scrollView.contentOffset.x && scrollView.contentOffset.x < scrollView.contentSize.width - scrollView.frame.size.width)) {
        direction = LMBannerScorllDirectionLeft;
    }
    LMIndexSection indexSection = [self nearlyIndexPathForIndexSection:_indexSection direction:direction];
    targetContentOffset->x = [self caculateOffsetXAtIndexSection:indexSection];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (_autoScrollInterval > 0) {
        [self addTimer];
    }
    if ([_delegate respondsToSelector:@selector(bannerViewDidEndDragging:willDecelerate:)]) {
        [_delegate bannerViewDidEndDragging:self willDecelerate:decelerate];
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    if ([_delegate respondsToSelector:@selector(bannerViewWillBeginDecelerating:)]) {
        [_delegate bannerViewWillBeginDecelerating:self];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self recycleBannerViewIfNeed];
    if ([_delegate respondsToSelector:@selector(bannerViewDidEndDecelerating:)]) {
        [_delegate bannerViewDidEndDecelerating:self];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self recycleBannerViewIfNeed];
    if ([_delegate respondsToSelector:@selector(bannerViewDidEndScrollingAnimation:)]) {
        [_delegate bannerViewDidEndScrollingAnimation:self];
    }
}

#pragma mark - LMBannerViewLayoutDelegate
- (void)bannerViewLayout:(LMBannerViewLayout *)bannerViewLayout initializeLayoutAttributes:(UICollectionViewLayoutAttributes *)attributes {
    if (_delegateFlags.initializeLayoutAttributes) {
        [_delegate bannerView:self initializeLayoutAttributes:attributes];
    }
}

- (void)bannerViewLayout:(LMBannerViewLayout *)bannerViewLayout applyLayoutToAttributes:(UICollectionViewLayoutAttributes *)attributes {
    if (_delegateFlags.applyLayoutToAttributes) {
        [_delegate bannerView:self applyLayoutToAttributes:attributes];
    }
}

#pragma mark - dealloc
- (void)dealloc {
    ((LMBannerViewLayout *)_collectionView.collectionViewLayout).delegate = nil;
    _collectionView.delegate = nil;
    _collectionView.dataSource = nil;
}

@end
