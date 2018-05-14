//
//  BBMFPhotoForceTouchPeekViewController.m
//  BBMFPhotoGirdViewController
//
//  Created by lu9869 on 2018/4/4.
//  Copyright © 2018年 wk. All rights reserved.
//

#import "BBMFPhotoForceTouchPeekViewController.h"
#import "BBMFPhotoManager.h"
#import <PhotosUI/PhotosUI.h>

@interface BBMFPhotoForceTouchPeekViewController ()
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) PHLivePhotoView *livePhotoView API_AVAILABLE(ios(9.1));
@end

@implementation BBMFPhotoForceTouchPeekViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    _imageView.frame = self.view.bounds;
    if (@available(iOS 9.1, *)) {
        _livePhotoView.frame = self.view.bounds;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configureWithAsset:(BBMFAsset *)asset {
    if (!asset) {
        return;
    }
    if (asset.mediaType == BBMFAssetMediaTypePhoto) {
        [self loadPhotoWithAsset:asset.asset];
    } else if (asset.mediaType == BBMFAssetMediaTypePhotoLive) {
        [self loadLivePhotoWithAsset:asset.asset];
    } else {
        [self loadPhotoWithAsset:asset.asset];
    }
}

- (void)loadPhotoWithAsset:(PHAsset *)asset {
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize size = CGSizeMake(CGRectGetWidth(self.view.bounds) * scale, CGRectGetHeight(self.view.bounds) * scale);
    [[BBMFPhotoManager defaultManager] requestImageWithAsset:asset targetSize:size progressHandler:^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
        
    } completion:^(UIImage *image, NSDictionary *options) {
        self.imageView.image = image;
    }];
}

- (void)loadLivePhotoWithAsset:(PHAsset *)asset {
    if (@available(iOS 9.1, *)) {
        CGFloat scale = [UIScreen mainScreen].scale;
        CGSize size = CGSizeMake(CGRectGetWidth(self.view.bounds) * scale, CGRectGetHeight(self.view.bounds) * scale);
        [[BBMFPhotoManager defaultManager] requestLivePhotoWithAsset:asset targetSize:size progressHandler:^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
            
        } completion:^(PHLivePhoto *livePhoto, NSDictionary *options) {
            self.livePhotoView.livePhoto = livePhoto;
            [self.livePhotoView startPlaybackWithStyle:PHLivePhotoViewPlaybackStyleFull];
        }];
    } else {
        [self loadPhotoWithAsset:asset];
    }
}

#pragma mark - getter
- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        [self.view addSubview:_imageView];
    }
    return _imageView;
}

- (PHLivePhotoView *)livePhotoView  API_AVAILABLE(ios(9.1)) {
    if (!_livePhotoView) {
        _livePhotoView = [[PHLivePhotoView alloc] initWithFrame:self.view.bounds];
        _livePhotoView.clipsToBounds = YES;
        [self.view addSubview:_livePhotoView];
    }
    return _livePhotoView;
}

@end
