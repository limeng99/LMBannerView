//
//  LMBannerViewLayout.m
//  LMBannerViewDemo
//
//  Created by LM on 2019/9/11.
//  Copyright © 2019 LM. All rights reserved.
//

#import "LMBannerViewLayout.h"

#pragma mark - LMPageLayout
typedef NS_ENUM(NSUInteger, LMPageLayoutItemDirection) {
    LMPageLayoutItemLeft,
    LMPageLayoutItemCenter,
    LMPageLayoutItemRight,
};

@interface LMPageLayout ()

@property (nonatomic, weak) UIView *pageView;

@end

@implementation LMPageLayout

- (instancetype)init {
    if (self = [super init]) {
        _minimumScale = 0.8;
        _minimumAlpha = 1.0;
        _maximumAngle = 0.2;
        _rateOfChange = 0.4;
        _itemVerticalCenter = YES;
        _adjustSpacingWhenScroling = YES;
    }
    return self;
}

#pragma mark - getter
- (UIEdgeInsets)onlyOneSectionInset {
    CGFloat leftSpace = _pageView && !_isInfiniteLoop && _itemHorizontalCenter ? (CGRectGetWidth(_pageView.frame) - _itemSize.width)/2 : _sectionInset.left;
    CGFloat rightSpace = _pageView && !_isInfiniteLoop && _itemHorizontalCenter ? (CGRectGetWidth(_pageView.frame) - _itemSize.width)/2 : _sectionInset.right;
    if (_itemVerticalCenter) {
        CGFloat verticalSpace = (CGRectGetHeight(_pageView.frame) - _itemSize.height)/2;
        return UIEdgeInsetsMake(verticalSpace, leftSpace, verticalSpace, rightSpace);
    }
    return UIEdgeInsetsMake(_sectionInset.top, leftSpace, _sectionInset.bottom, rightSpace);
}

- (UIEdgeInsets)firstSectionInset {
    if (_itemVerticalCenter) {
        CGFloat verticalSpace = (CGRectGetHeight(_pageView.frame) - _itemSize.height)/2;
        return UIEdgeInsetsMake(verticalSpace, _sectionInset.left, verticalSpace, _itemSpacing);
    }
    return UIEdgeInsetsMake(_sectionInset.top, _sectionInset.left, _sectionInset.bottom, _itemSpacing);
}

- (UIEdgeInsets)lastSectionInset {
    if (_itemVerticalCenter) {
        CGFloat verticalSpace = (CGRectGetHeight(_pageView.frame) - _itemSize.height)/2;
        return UIEdgeInsetsMake(verticalSpace, 0, verticalSpace, _sectionInset.right);
    }
    return UIEdgeInsetsMake(_sectionInset.top, 0, _sectionInset.bottom, _sectionInset.right);
}

- (UIEdgeInsets)middleSectionInset {
    if (_itemVerticalCenter) {
        CGFloat verticalSpace = (CGRectGetHeight(_pageView.frame) - _itemSize.height)/2;
        return UIEdgeInsetsMake(verticalSpace, 0, verticalSpace, _itemSpacing);
    }
    return UIEdgeInsetsMake(_sectionInset.top, 0, _sectionInset.bottom, _itemSpacing);
}

@end

#pragma mark - LMBannerViewLayout
@interface LMBannerViewLayout () {
    struct {
        unsigned int applyLayoutToAttributes   :1;
        unsigned int initializeLayoutAttributes   :1;
    }_delegateFlags;
}

@end

@implementation LMBannerViewLayout

- (instancetype)init {
    if (self = [super init]) {
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    }
    return self;
}

#pragma mark - getter setter
- (void)setDelegate:(id<LMBannerViewLayoutDelegate>)delegate {
    _delegate = delegate;
    _delegateFlags.initializeLayoutAttributes = [delegate respondsToSelector:@selector(bannerViewLayout:initializeLayoutAttributes:)];
    _delegateFlags.applyLayoutToAttributes = [delegate respondsToSelector:@selector(bannerViewLayout:applyLayoutToAttributes:)];
}

- (void)setLayout:(LMPageLayout *)layout {
    _layout = layout;
    _layout.pageView = self.collectionView;
    self.itemSize = _layout.itemSize;
    self.minimumLineSpacing = _layout.itemSpacing;
    self.minimumInteritemSpacing = _layout.itemSpacing;
}

- (CGSize)itemSize {
    if (!_layout) {
        return [super itemSize];
    }
    return _layout.itemSize;
}

- (CGFloat)minimumLineSpacing {
    if (!_layout) {
        return [super minimumLineSpacing];
    }
    return _layout.itemSpacing;
}

- (CGFloat)minimumInteritemSpacing {
    if (!_layout) {
        return [super minimumInteritemSpacing];
    }
    return _layout.itemSpacing;
}

- (LMPageLayoutItemDirection)directionWithCenterX:(CGFloat)centerX {
    LMPageLayoutItemDirection direction = LMPageLayoutItemRight;
    CGFloat contentCenterX = self.collectionView.contentOffset.x + CGRectGetWidth(self.collectionView.frame)/2;
    if (ABS(centerX - contentCenterX) < 0.5) {
        direction = LMPageLayoutItemCenter;
    } else if (centerX - contentCenterX < 0) {
        direction = LMPageLayoutItemLeft;
    }
    return direction;
}

#pragma mark - layout
- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return _layout.layoutType == LMBannerViewLayoutNormal ? [super shouldInvalidateLayoutForBoundsChange:newBounds] : YES;
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    if (_delegateFlags.applyLayoutToAttributes || _layout.layoutType != LMBannerViewLayoutNormal) {
        NSArray *arrributesArray = [[NSArray alloc] initWithArray:[super layoutAttributesForElementsInRect:rect] copyItems:YES];
        CGRect visibleRect = {self.collectionView.contentOffset, self.collectionView.bounds.size};
        for (UICollectionViewLayoutAttributes *attributes in arrributesArray) {
            if (!CGRectIntersectsRect(visibleRect, attributes.frame)) {
                continue;
            }
            if (_delegateFlags.applyLayoutToAttributes) {
                [_delegate bannerViewLayout:self applyLayoutToAttributes:attributes];
            } else {
                [self applyLayoutToAttributes:attributes layoutType:_layout.layoutType];
            }
        }
        return arrributesArray;
    }
    return [super layoutAttributesForElementsInRect:rect];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *attributes = [super layoutAttributesForItemAtIndexPath:indexPath];
    if (_delegateFlags.initializeLayoutAttributes) {
        [_delegate bannerViewLayout:self initializeLayoutAttributes:attributes];
    } else if(_layout.layoutType != LMBannerViewLayoutNormal) {
        [self initializeLayoutAttributes:attributes layoutType:_layout.layoutType];
    }
    return attributes;
}


#pragma mark - transform
- (void)initializeLayoutAttributes:(UICollectionViewLayoutAttributes *)attributes layoutType:(LMBannerViewLayoutType)layoutType  {
    switch (layoutType) {
        case LMBannerViewLayoutLinear:
            [self applyLinearLayoutToAttributes:attributes scale:_layout.minimumScale alpha:_layout.minimumAlpha];
            break;
        case LMBannerViewLayoutCoverflow:
            [self applyCoverflowLayoutToAttributes:attributes angle:_layout.maximumAngle alpha:_layout.minimumAlpha];
            break;
        default:
            break;
    }
}

- (void)applyLayoutToAttributes:(UICollectionViewLayoutAttributes *)attributes layoutType:(LMBannerViewLayoutType)layoutType {
    switch (layoutType) {
        case LMBannerViewLayoutLinear:
            [self applyLinearLayoutToAttributes:attributes];
            break;
        case LMBannerViewLayoutCoverflow:
            [self applyCoverflowLayoutToAttributes:attributes];
            break;
        default:
            break;
    }
}

#pragma mark - linear
- (void)applyLinearLayoutToAttributes:(UICollectionViewLayoutAttributes *)attributes {
    CGFloat collectionViewWidth = self.collectionView.frame.size.width;
    if (collectionViewWidth <= 0) {
        return;
    }
    CGFloat centerX = self.collectionView.contentOffset.x + collectionViewWidth/2;
    CGFloat delta = ABS(attributes.center.x - centerX);
    CGFloat scale = MAX(1 - delta/collectionViewWidth*_layout.rateOfChange, _layout.minimumScale);
    CGFloat alpha = MAX(1 - delta/collectionViewWidth, _layout.minimumAlpha);
    [self applyLinearLayoutToAttributes:attributes scale:scale alpha:alpha];
}

- (void)applyLinearLayoutToAttributes:(UICollectionViewLayoutAttributes *)attributes scale:(CGFloat)scale alpha:(CGFloat)alpha {
    CGAffineTransform transform = CGAffineTransformMakeScale(scale, scale);
    if (_layout.adjustSpacingWhenScroling) {
        LMPageLayoutItemDirection direction = [self directionWithCenterX:attributes.center.x];
        CGFloat translate = 0;
        switch (direction) {
            case LMPageLayoutItemLeft:
                translate = 1.15 * attributes.size.width*(1-scale)/2;
                break;
            case LMPageLayoutItemRight:
                translate = -1.15 * attributes.size.width*(1-scale)/2;
                break;
            default:
                scale = 1.0;
                alpha = 1.0;
                break;
        }
        transform = CGAffineTransformTranslate(transform, translate, 0);
    }
    attributes.transform = transform;
    attributes.alpha = alpha;
}

#pragma mark - coverflow
- (void)applyCoverflowLayoutToAttributes:(UICollectionViewLayoutAttributes *)attributes {
    CGFloat collectionViewWidth = self.collectionView.frame.size.width;
    if (collectionViewWidth <= 0) {
        return;
    }
    CGFloat centerX = self.collectionView.contentOffset.x + collectionViewWidth/2;
    CGFloat delta = ABS(attributes.center.x - centerX);
    CGFloat angle = MIN(delta/collectionViewWidth*(1 - _layout.rateOfChange), _layout.maximumAngle);
    CGFloat alpha = MAX(1 - delta/collectionViewWidth, _layout.minimumAlpha);
    [self applyCoverflowLayoutToAttributes:attributes angle:angle alpha:alpha];
}

- (void)applyCoverflowLayoutToAttributes:(UICollectionViewLayoutAttributes *)attributes angle:(CGFloat)angle alpha:(CGFloat)alpha {
    LMPageLayoutItemDirection direction = [self directionWithCenterX:attributes.center.x];
    CATransform3D transform3D = CATransform3DIdentity;
    transform3D.m34 = -0.002;
    CGFloat translate = 0;
    switch (direction) {
        case LMPageLayoutItemLeft:
            translate = (1-cos(angle*1.2*M_PI))*attributes.size.width;
            break;
        case LMPageLayoutItemRight:
            translate = -(1-cos(angle*1.2*M_PI))*attributes.size.width;
            angle = -angle;
            break;
        default:
            angle = 0;
            alpha = 1;
            break;
    }
    transform3D = CATransform3DRotate(transform3D, M_PI*angle, 0, 1, 0);
    if (_layout.adjustSpacingWhenScroling) {
        transform3D = CATransform3DTranslate(transform3D, translate, 0, 0);
    }
    attributes.transform3D = transform3D;
    attributes.alpha = alpha;
}

@end




