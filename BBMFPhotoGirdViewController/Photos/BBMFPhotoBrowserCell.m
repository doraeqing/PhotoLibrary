//
//  BBMFPhotoBrowserCell.m
//  BBMFPhotoGirdViewController
//
//  Created by lu9869 on 2018/3/29.
//  Copyright © 2018年 wk. All rights reserved.
//

#import "BBMFPhotoBrowserCell.h"

@interface BBMFPhotoBrowserCell ()
@property (nonatomic, strong) UIImageView *imageView;
@end

@implementation BBMFPhotoBrowserCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.clipsToBounds = YES;
        [self.contentView addSubview:_imageView];
        
        _progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, (frame.size.height - 4) / 2, frame.size.width, 4)];
        _progressView.progressViewStyle = UIProgressViewStyleBar;
        [_imageView addSubview:_progressView];
        
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.progressView.hidden = YES;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _imageView.frame = self.contentView.bounds;
    _progressView.frame = CGRectMake(0, (_imageView.frame.size.height - 4) / 2, _imageView.frame.size.width, 4);
}

@end
