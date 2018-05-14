//
//  BBMFPhotoGirdCell.m
//  BBMFPhotoGirdViewController
//
//  Created by lu9869 on 2018/3/27.
//  Copyright © 2018年 wk. All rights reserved.
//

#import "BBMFPhotoGirdCell.h"
#import "BBMFAssetCollection.h"
#import "BBMFAsset.h"
#import <PhotosUI/PhotosUI.h>

@interface BBMFPhotoGirdCell ()
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImageView *livePhotoBadgeImageView;
@property (nonatomic, strong) UIView *coverView;
@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) BBMFAsset *asset;
@end

@implementation BBMFPhotoGirdCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _imageView = [[UIImageView alloc] initWithFrame:frame];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        [self.contentView addSubview:_imageView];
        
        _coverView = [[UIView alloc] initWithFrame:self.contentView.bounds];
        _coverView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        _coverView.hidden = YES;
        [self.contentView addSubview:_coverView];
        
        if (@available(iOS 9.1, *)) {
            _livePhotoBadgeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 28, 28)];
            _livePhotoBadgeImageView.hidden = YES;
            _livePhotoBadgeImageView.image = [PHLivePhotoView livePhotoBadgeImageWithOptions:PHLivePhotoBadgeOptionsOverContent];
            [self.contentView addSubview:_livePhotoBadgeImageView];
        }

        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        [_button setBackgroundImage:[UIImage imageNamed:@"common_oval_unselected_icon"] forState:UIControlStateNormal];
        [_button setBackgroundImage:[UIImage imageNamed:@"common_oval_selected_icon"] forState:UIControlStateSelected];
        [_button addTarget:self action:@selector(didSelectButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_button];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.imageView.image = nil;
    self.livePhotoBadgeImageView.hidden = YES;
    self.coverView.hidden = YES;
    [self.button setTitle:nil forState:UIControlStateNormal];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.imageView.frame = self.contentView.bounds;
    CGFloat spacing = 4.0, width = 33.0, height = 33.0;
    CGFloat buttonX = CGRectGetWidth(self.contentView.bounds) - width - spacing;
    self.button.frame = CGRectMake(buttonX, spacing, width, height);
}

- (void)setAsset:(BBMFAsset *)asset {
    _asset = asset;
    if (asset.isInCloud) {
        self.livePhotoBadgeImageView.hidden = NO;
    }
    if (asset.isSelected) {
        self.coverView.hidden = NO;
    }
    if (asset.selectedSequenceNumber > 0) {
        [self.button setTitle:@(asset.selectedSequenceNumber).stringValue forState:UIControlStateSelected];
    }
    self.button.selected = asset.isSelected;
}

#pragma mark - action
- (void)didSelectButton:(UIButton *)button {
    if ([self.delegate respondsToSelector:@selector(photoGirdCell:didSelectButton:)]) {
        [self.delegate photoGirdCell:self didSelectButton:button];
    }
}

@end
