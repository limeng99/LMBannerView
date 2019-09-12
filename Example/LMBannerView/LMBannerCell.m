//
//  LMBannerCell.m
//  LMBannerViewDemo
//
//  Created by LM on 2019/9/12.
//  Copyright © 2019 LM. All rights reserved.
//

#import "LMBannerCell.h"

@interface LMBannerCell ()

@property (nonatomic, strong) UIImageView   *imageView;
@property (nonatomic, strong) UILabel       *titleLabel;

@end

@implementation LMBannerCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.layer.cornerRadius = 10;
        _imageView.clipsToBounds = YES;
        [self addSubview:_imageView];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 50, self.frame.size.width-40, 40)];
        _titleLabel.font = [UIFont boldSystemFontOfSize:30];
        _titleLabel.textColor = [UIColor whiteColor];
        [self addSubview:_titleLabel];
        
    }
    return self;
}

- (void)setDataDic:(NSDictionary *)dataDic {
    _dataDic = dataDic;
    _imageView.image = [UIImage imageNamed:dataDic[@"image"]];
    _titleLabel.text = dataDic[@"title"];
}

@end
