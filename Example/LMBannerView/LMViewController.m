//
//  LMViewController.m
//  LMBannerView
//
//  Created by 1805441570@qq.com on 09/12/2019.
//  Copyright (c) 2019 1805441570@qq.com. All rights reserved.
//

#import "LMViewController.h"
#import "LMBannerCell.h"
#import "LMBannerView.h"
#import "LMPageControl.h"

@interface LMViewController ()<LMBannerViewDataSource, LMBannerViewDelegate>

@property (nonatomic, strong) UIImageView       *bannerBgView;
@property (nonatomic, strong) NSArray           *dataArray;
@property (nonatomic, strong) NSArray           *bgImagesArray;
@property (nonatomic, strong) LMBannerView      *bannerView;
@property (nonatomic, strong) LMPageControl     *pageControl;

@end

@implementation LMViewController

- (NSArray *)dataArray {
    if (!_dataArray) {
        _dataArray = @[@{@"image":@"home_artisticbanner", @"title":@"Index-1", @"icon":@"home_filter"},
                       @{@"image":@"home_cutoutbanner", @"title":@"Index-2", @"icon":@"home_cutout"},
                       @{@"image":@"home_posterbanner", @"title":@"Index-3", @"icon":@"home_poster"},];
    }
    return _dataArray;
}

- (NSArray *)bgImagesArray {
    if (!_bgImagesArray) {
        _bgImagesArray = @[@"home_filterbg", @"home_cutoutbg", @"home_posterbg"];
    }
    return _bgImagesArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _bannerBgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 300)];
    _bannerBgView.image = [UIImage imageNamed:@"home_filterbg"];
    [self.view addSubview:_bannerBgView];
    
    _bannerView =  [[LMBannerView alloc] initWithFrame:CGRectMake(0, 50, self.view.frame.size.width, 170)];
    _bannerView.dataSource = self;
    _bannerView.delegate = self;
    _bannerView.isInfiniteLoop = YES;
    _bannerView.autoScrollInterval = 2.0;
    [_bannerView registerClass:[LMBannerCell class] forCellWithReuseIdentifier:NSStringFromClass([LMBannerCell class])];
    [self.view addSubview:_bannerView];
    [_bannerView reloadData];
    
    _pageControl = [[LMPageControl alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_bannerView.frame), self.view.frame.size.width, 30)];
    _pageControl.numberOfPages = self.dataArray.count;
    _pageControl.currentPageIndicatorSize = CGSizeMake(20, 6);
    _pageControl.pageIndicatorSize = CGSizeMake(6, 6);
    _pageControl.currentPageIndicatorTintColor = [UIColor colorWithRed:216/255. green:216/255. blue:216/255. alpha:1.0];
    _pageControl.pageIndicatorTintColor = [UIColor colorWithRed:216/255. green:216/255. blue:216/255. alpha:1.0];;
    [self.view addSubview:_pageControl];
}


- (IBAction)buttonAction:(UIButton *)sender {
    _bannerView.layout.layoutType = sender.tag;
    [_bannerView setNeedUpdateLayout];
}

#pragma mark - LMBannerViewDataSource
- (NSInteger)numberOfItemsInBannerView:(LMBannerView *)bannerView {
    return self.dataArray.count;
}

- (UICollectionViewCell *)bannerView:(LMBannerView *)bannerView cellForItemAtIndex:(NSInteger)index {
    LMBannerCell *cell = [bannerView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([LMBannerCell class]) forIndex:index];
    cell.dataDic = self.dataArray[index];
    return cell;
}

- (LMPageLayout *)layoutForBannerView:(LMBannerView *)bannerView {
    LMPageLayout *layout = [[LMPageLayout alloc] init];
    layout.itemSize = CGSizeMake(bannerView.frame.size.width-56, bannerView.frame.size.height);
    layout.itemSpacing = 10;
    layout.itemHorizontalCenter = YES;
    layout.layoutType = LMBannerViewLayoutNormal;
    return layout;
}

#pragma mark - LMBannerViewDelegate
- (void)bannerView:(LMBannerView *)pageView didScrollFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex {
    [_pageControl setCurrentPage:toIndex animate:YES];
    NSLog(@"didScrollFromIndex %ld toIndex:%ld", fromIndex, toIndex);
    _bannerBgView.image = [UIImage imageNamed:self.bgImagesArray[toIndex]];
}

- (void)bannerView:(LMBannerView *)pageView didSelectedItemCell:(__kindof UICollectionViewCell *)cell atIndex:(NSInteger)index {
    NSLog(@"didSelectedItemCell ----- %ld", index);
}


@end
