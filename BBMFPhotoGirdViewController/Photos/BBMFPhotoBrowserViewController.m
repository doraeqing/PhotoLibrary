//
//  BBMFPhotoBrowserViewController.m
//  BBMFPhotoGirdViewController
//
//  Created by lu9869 on 2018/3/29.
//  Copyright © 2018年 wk. All rights reserved.
//

#import "BBMFPhotoBrowserViewController.h"
#import "BBMFPhotoBrowserCell.h"

CGFloat const kBBMFMinimumLineSpacing = 20.0;

@interface BBMFPhotoBrowserViewController ()
<
UICollectionViewDelegate,
UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout
>

@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, strong) NSArray <BBMFAsset *> *assets;
@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation BBMFPhotoBrowserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:[self collectionView]];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    CGRect rect = CGRectMake(-kBBMFMinimumLineSpacing / 2, 0, CGRectGetWidth(self.view.bounds) + kBBMFMinimumLineSpacing, CGRectGetHeight(self.view.bounds));
    [[self collectionView] setFrame:rect];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGFloat width = CGRectGetWidth([[self collectionView] bounds]);
    [[self collectionView] setContentOffset:CGPointMake(self.currentIndex * width, 0) animated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - public
- (void)configureWithAssets:(NSArray<BBMFAsset *> *)assets currentIndex:(NSInteger)index {
    if (self.assets != assets) {
        self.assets = assets;
        self.currentIndex = index;
    }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.assets.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    BBMFPhotoBrowserCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"BBMFPhotoBrowserCell" forIndexPath:indexPath];
    PHAsset *asset = [[self.assets objectAtIndex:indexPath.row] asset];
    cell.representedAssetIdentifier = asset.localIdentifier;
    CGFloat scale = [UIScreen mainScreen].scale;
    [[BBMFPhotoManager defaultManager] requestImageWithAsset:asset targetSize:CGSizeMake(collectionView.bounds.size.width * scale, collectionView.bounds.size.height * scale) progressHandler:^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (progress < 1.0) {
                cell.progressView.hidden = NO;
                [cell.progressView setProgress:progress animated:YES];
            } else {
                [cell.progressView setProgress:progress animated:YES];
                cell.progressView.hidden = YES;
            }
        });
    } completion:^(UIImage *image, NSDictionary *options) {
        if ([cell.representedAssetIdentifier isEqualToString:asset.localIdentifier] &&
            image) {
            cell.imageView.image = image;
        } else {
            NSLog(@"%@", indexPath);
        }
    }];
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.view.bounds.size;
}

#pragma mark - getter
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        flowLayout.minimumLineSpacing = kBBMFMinimumLineSpacing;
        flowLayout.minimumInteritemSpacing = 0.f;
        flowLayout.sectionInset = UIEdgeInsetsMake(0, kBBMFMinimumLineSpacing/ 2, 0, kBBMFMinimumLineSpacing / 2);
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _collectionView.pagingEnabled = YES;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.bounces = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.backgroundColor = [UIColor blackColor];
        [_collectionView registerClass:[BBMFPhotoBrowserCell class] forCellWithReuseIdentifier:@"BBMFPhotoBrowserCell"];
    }
    return _collectionView;
}

@end
