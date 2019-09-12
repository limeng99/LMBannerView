//
//  LMPageControl.m
//  LMBannerViewDemo
//
//  Created by LM on 2019/9/11.
//  Copyright © 2019 LM. All rights reserved.
//

#import "LMPageControl.h"

@interface LMPageControl ()

@property (nonatomic, strong) NSArray<UIImageView *> *indicatorViews;

@property (nonatomic, assign) BOOL forceUpdate;

@end

@implementation LMPageControl

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self configureProtertys];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self configureProtertys];
    }
    return self;
}

- (void)configureProtertys {
    self.userInteractionEnabled = NO;
    _forceUpdate = NO;
    _animateDuring = 0.3;
    _pageIndicatorSpaing = 10;
    _indicatorImageContentMode = UIViewContentModeCenter;
    _pageIndicatorSize = CGSizeMake(6,6);
    _currentPageIndicatorSize = _pageIndicatorSize;
    _pageIndicatorTintColor = [UIColor colorWithRed:128/255. green:128/255. blue:128/255. alpha:1];
    _currentPageIndicatorTintColor = [UIColor whiteColor];
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    if (newSuperview) {
        _forceUpdate = YES;
        [self updateIndicatorViews];
        _forceUpdate = NO;
    }
}

#pragma mark - getter setter
- (CGSize)contentSize {
    CGFloat width = (_indicatorViews.count - 1) * (_pageIndicatorSize.width + _pageIndicatorSpaing) + _pageIndicatorSize.width + _contentInset.left + _contentInset.right;
    CGFloat height = _pageIndicatorSize.height + _contentInset.top + _contentInset.bottom;
    return CGSizeMake(width, height);
}

- (void)setNumberOfPages:(NSInteger)numberOfPages {
    if (numberOfPages == 0) {
        return;
    }
    _numberOfPages = numberOfPages;
    if (_currentPage >= numberOfPages) {
        _currentPage = 0;
    }
    [self updateIndicatorViews];
    if (_indicatorViews.count > 0) {
        [self setNeedsLayout];
    }
}

- (void)setCurrentPage:(NSInteger)currentPage {
    if (_currentPage == currentPage || currentPage >= _indicatorViews.count) {
        return;
    }
    _currentPage = currentPage;
    if (!CGSizeEqualToSize(_currentPageIndicatorSize, _pageIndicatorSize)) {
        [self setNeedsLayout];
    }
    [self updateIndicatorViewsBehavior];
    if (self.userInteractionEnabled) {
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
}

- (void)setCurrentPage:(NSInteger)currentPage animate:(BOOL)animate {
    if (animate) {
        [UIView animateWithDuration:_animateDuring animations:^{
            [self setCurrentPage:currentPage];
        }];
    } else {
        [self setCurrentPage:currentPage];
    }
}

- (void)setPageIndicatorImage:(UIImage *)pageIndicatorImage {
    _pageIndicatorImage = pageIndicatorImage;
    [self updateIndicatorViewsBehavior];
}

- (void)setCurrentPageIndicatorImage:(UIImage *)currentPageIndicatorImage {
    _currentPageIndicatorImage = currentPageIndicatorImage;
    [self updateIndicatorViewsBehavior];
}

- (void)setPageIndicatorTintColor:(UIColor *)pageIndicatorTintColor {
    _pageIndicatorTintColor = pageIndicatorTintColor;
    [self updateIndicatorViewsBehavior];
}

- (void)setCurrentPageIndicatorTintColor:(UIColor *)currentPageIndicatorTintColor {
    _currentPageIndicatorTintColor = currentPageIndicatorTintColor;
    [self updateIndicatorViewsBehavior];
}

- (void)setPageIndicatorSize:(CGSize)pageIndicatorSize {
    if (CGSizeEqualToSize(_pageIndicatorSize, pageIndicatorSize)) {
        return;
    }
    _pageIndicatorSize = pageIndicatorSize;
    if (CGSizeEqualToSize(_currentPageIndicatorSize, CGSizeZero) || (_currentPageIndicatorSize.width < pageIndicatorSize.width && _currentPageIndicatorSize.height < pageIndicatorSize.height)) {
        _currentPageIndicatorSize = pageIndicatorSize;
    }
    if (_indicatorViews.count > 0) {
        [self setNeedsLayout];
    }
}

- (void)setPageIndicatorSpaing:(CGFloat)pageIndicatorSpaing {
    _pageIndicatorSpaing = pageIndicatorSpaing;
    if (_indicatorViews.count > 0) {
        [self setNeedsLayout];
    }
}

- (void)setCurrentPageIndicatorSize:(CGSize)currentPageIndicatorSize {
    if (CGSizeEqualToSize(_currentPageIndicatorSize, currentPageIndicatorSize)) {
        return;
    }
    _currentPageIndicatorSize = currentPageIndicatorSize;
    if (_indicatorViews.count > 0) {
        [self setNeedsLayout];
    }
}

- (void)setContentHorizontalAlignment:(UIControlContentHorizontalAlignment)contentHorizontalAlignment {
    [super setContentHorizontalAlignment:contentHorizontalAlignment];
    if (_indicatorViews.count > 0) {
        [self setNeedsLayout];
    }
}

- (void)setContentVerticalAlignment:(UIControlContentVerticalAlignment)contentVerticalAlignment {
    [super setContentVerticalAlignment:contentVerticalAlignment];
    if (_indicatorViews.count > 0) {
        [self setNeedsLayout];
    }
}

#pragma mark - update indicator
- (void)updateIndicatorViews {
    if (!self.superview && !_forceUpdate) {
        return;
    }
    if (_indicatorViews.count == _numberOfPages) {
        [self updateIndicatorViewsBehavior];
        return;
    }
    NSMutableArray *indicatorViews = _indicatorViews ? [_indicatorViews mutableCopy] : [NSMutableArray array];
    if (indicatorViews.count < _numberOfPages) {
        for (NSInteger idx = indicatorViews.count; idx < _numberOfPages; ++idx) {
            UIImageView *indicatorView = [[UIImageView alloc] init];
            indicatorView.contentMode = _indicatorImageContentMode;
            [self addSubview:indicatorView];
            [indicatorViews addObject:indicatorView];
        }
    } else {
        for (NSInteger idx = indicatorViews.count - 1; idx >= _numberOfPages; --idx) {
            UIImageView *indicatorView = indicatorViews[idx];
            [indicatorView removeFromSuperview];
            [indicatorViews removeObjectAtIndex:idx];
        }
    }
    _indicatorViews = [indicatorViews copy];
    [self updateIndicatorViewsBehavior];
}

- (void)updateIndicatorViewsBehavior {
    if (!_indicatorViews.count || (!self.superview && !_forceUpdate)) {
        return;
    }
    if (_hidesForSinglePage && _indicatorViews.count == 1) {
        UIImageView *indicatorView = _indicatorViews.lastObject;
        indicatorView.hidden = YES;
        return;
    }
    NSInteger index = 0;
    for (UIImageView *indicatorView in _indicatorViews) {
        if (_pageIndicatorImage) {
            indicatorView.contentMode = _indicatorImageContentMode;
            indicatorView.image = _currentPage == index ? _currentPageIndicatorImage : _pageIndicatorImage;
        } else {
            indicatorView.image = nil;
            indicatorView.backgroundColor = _currentPage == index ? _currentPageIndicatorTintColor : _pageIndicatorTintColor;
        }
        indicatorView.hidden = NO;
        ++index;
    }
}

#pragma mark - layout
- (void)layoutSubviews {
    [super layoutSubviews];
    [self layoutIndicatorViews];
}

- (void)layoutIndicatorViews {
    if (!_indicatorViews.count) {
        return;
    }
    CGFloat originX = 0;
    CGFloat centerY = 0;
    CGFloat pageIndicatorSpaing = _pageIndicatorSpaing;
    switch (self.contentHorizontalAlignment) {
        case UIControlContentHorizontalAlignmentCenter:
            originX = (CGRectGetWidth(self.frame) - (_indicatorViews.count-1) * (_pageIndicatorSize.width + _pageIndicatorSpaing) - _currentPageIndicatorSize.width)/2;
            break;
        case UIControlContentHorizontalAlignmentLeft:
            originX = _contentInset.left;
            break;
        case UIControlContentHorizontalAlignmentRight:
            originX = CGRectGetWidth(self.frame) - (_indicatorViews.count-1) * (_pageIndicatorSize.width + _pageIndicatorSpaing) - _currentPageIndicatorSize.width - _contentInset.right;;
            break;
        case UIControlContentHorizontalAlignmentFill:
            originX = _contentInset.left;
            if (_indicatorViews.count > 1) {
                pageIndicatorSpaing = (CGRectGetWidth(self.frame) - _contentInset.left - _contentInset.right - _pageIndicatorSize.width - (_indicatorViews.count - 1) * _pageIndicatorSize.width)/(_indicatorViews.count - 1);
            }
            break;
        default:
            break;
    }
    switch (self.contentVerticalAlignment) {
        case UIControlContentVerticalAlignmentCenter:
            centerY = CGRectGetHeight(self.frame)/2;
            break;
        case UIControlContentVerticalAlignmentTop:
            centerY = _contentInset.top + _currentPageIndicatorSize.height/2;
            break;
        case UIControlContentVerticalAlignmentBottom:
            centerY = CGRectGetHeight(self.frame) - _currentPageIndicatorSize.height/2 - _contentInset.bottom;
            break;
        case UIControlContentVerticalAlignmentFill:
            centerY = (CGRectGetHeight(self.frame) - _contentInset.top - _contentInset.bottom)/2 + _contentInset.top;
            break;
        default:
            break;
    }
    NSInteger index = 0;
    for (UIImageView *indicatorView in _indicatorViews) {
        if (_pageIndicatorImage) {
            indicatorView.layer.cornerRadius = 0;
        } else {
            indicatorView.layer.cornerRadius = _currentPage == index ? _currentPageIndicatorSize.height/2 : _pageIndicatorSize.height/2;
        }
        CGSize size = index == _currentPage ? _currentPageIndicatorSize : _pageIndicatorSize;
        indicatorView.frame = CGRectMake(originX, centerY - size.height/2, size.width, size.height);
        originX += size.width + pageIndicatorSpaing;
        ++index;
    }
}

@end
