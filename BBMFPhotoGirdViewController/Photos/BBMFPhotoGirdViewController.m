//
//  BBMFPhotoGirdViewController.m
//  BBMFPhotoGirdViewController
//
//  Created by lu9869 on 2018/3/27.
//  Copyright © 2018年 wk. All rights reserved.
//

#import "BBMFPhotoGirdViewController.h"
#import "BBMFPhotoBrowserViewController.h"
#import "BBMFPhotoForceTouchPeekViewController.h"
#import "BBMFPhotoGirdCell.h"

CGFloat const kBBMFMinimumLineInteritemSpacing = 0.5;
NSInteger const kBBMFPhotoColumnCount = 3;

#define BBMFHEXCOLOR(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define BBMFHEXACOLOR(rgbValue,a) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:(a)]

#define BBMFPhotoScale [[UIScreen mainScreen] scale]

@interface BBMFPhotoGirdViewController ()
<
UICollectionViewDelegate,
UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout,
UIViewControllerPreviewingDelegate,
BBMFPhotoGirdCellDelegate
>
{
    CGSize _itemSize;
}

@property (nonatomic, strong) NSArray <BBMFAsset *> *assets;
@property (nonatomic, strong) NSMutableArray <BBMFAsset *> *selectedPhotos;
@property (nonatomic, strong) NSMutableArray <BBMFAsset *> *selectedVideos;
@property (nonatomic, strong) NSMutableArray <BBMFAsset *> *selectedAllAssets;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;
@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation BBMFPhotoGirdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[self collectionView] registerClass:[BBMFPhotoGirdCell class] forCellWithReuseIdentifier:@"BBMFPhotoGirdCell"];
    [self.view addSubview:[self collectionView]];
    [self _registerForceTouch];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    CGFloat spacing = (kBBMFPhotoColumnCount - 1) * kBBMFMinimumLineInteritemSpacing;
    CGFloat itemWH = (CGRectGetWidth(self.view.frame) - spacing) / kBBMFPhotoColumnCount;
    _itemSize = CGSizeMake(itemWH, itemWH);
    [[self collectionView] setFrame:self.view.bounds];
}

- (void)dealloc {
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - public
- (void)configureWithAssets:(NSArray <BBMFAsset *> *)assets {
    if (self.assets != assets) {
        self.assets = assets;
    }
}

#pragma mark - private
- (void)_registerForceTouch {
    if (@available(iOS 9.0, *)) {
        if (self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable) {
            [self registerForPreviewingWithDelegate:self sourceView:[self collectionView]];
        }
    }
}

- (CGSize)_previewingPreferredContentSizeWithAsset:(PHAsset *)asset {
    CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
    CGFloat screenHieght = [[UIScreen mainScreen] bounds].size.height;
    CGFloat preferredContentHeight = screenWidth * asset.pixelHeight / asset.pixelWidth;
    if (preferredContentHeight > screenHieght + 20) {
        preferredContentHeight = screenHieght;
    }
    return CGSizeMake(screenWidth, preferredContentHeight);
}

#pragma mark - BBMFPhotoGirdCellDelegate
- (void)photoGirdCell:(BBMFPhotoGirdCell *)cell didSelectButton:(UIButton *)button {
    BBMFAsset *asset = cell.asset;

    asset.selected = !asset.selected;
    button.selected = asset.selected;
    if (asset.isSelected) {
        if (asset.mediaType == BBMFAssetMediaTypePhoto ||
            asset.mediaType == BBMFAssetMediaTypePhotoLive ||
            asset.mediaType == BBMFAssetMediaTypePhotoGIF) {
            [self.selectedPhotos addObject:asset];
        } else if (asset.mediaType == BBMFAssetMediaTypeVideo) {
            [self.selectedVideos addObject:asset];
        }
        [self.selectedAllAssets addObject:asset];
        asset.selectedSequenceNumber = self.selectedAllAssets.count;
        cell.coverView.hidden = NO;
        [button setTitle:@(asset.selectedSequenceNumber).stringValue forState:UIControlStateSelected];
    } else {
        cell.coverView.hidden = YES;
        [button setTitle:nil forState:UIControlStateNormal];
        NSMutableArray *indexPaths = [NSMutableArray array];
        [self.selectedAllAssets removeObject:asset];
        [self.selectedPhotos removeObject:asset];
        [self.selectedVideos removeObject:asset];
        [self.selectedAllAssets enumerateObjectsUsingBlock:^(BBMFAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.selectedSequenceNumber = idx + 1;
            NSInteger row = [self.assets indexOfObject:obj];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
            if (indexPath) {
                [indexPaths addObject:indexPath];
            }
        }];
        if (indexPaths.count) {
            [[self collectionView] reloadItemsAtIndexPaths:indexPaths];
        }
    }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.assets.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    BBMFPhotoGirdCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"BBMFPhotoGirdCell" forIndexPath:indexPath];
    cell.delegate = self;
    BBMFAsset *asset = [self.assets objectAtIndex:indexPath.row];
    cell.representedAssetIdentifier = asset.representedAssetIdentifier;
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize targetSize = CGSizeMake(_itemSize.width * scale, _itemSize.height * scale);
    [[BBMFPhotoManager defaultManager] requestImageWithAsset:asset.asset targetSize:targetSize progressHandler:^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
        
    } completion:^(UIImage *image, NSDictionary *options) {
        if ([cell.representedAssetIdentifier isEqualToString:asset.representedAssetIdentifier] &&
            image) {
            cell.imageView.image = image;
        } else {
            NSLog(@"representedAssetIdentifier%@", indexPath);
        }
    }];
    [cell setAsset:asset];
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    BBMFPhotoBrowserViewController *vc = [[BBMFPhotoBrowserViewController alloc] init];
    [vc configureWithAssets:self.assets currentIndex:indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return _itemSize;
}

#pragma mark - UIViewControllerPreviewingDelegate
- (void)previewingContext:(nonnull id<UIViewControllerPreviewing>)previewingContext commitViewController:(nonnull UIViewController *)viewControllerToCommit {
    if ([viewControllerToCommit isKindOfClass:[BBMFPhotoForceTouchPeekViewController class]]) {
        BBMFPhotoBrowserViewController *browserViewController = [[BBMFPhotoBrowserViewController alloc] init];
        [browserViewController configureWithAssets:self.assets currentIndex:self.selectedIndexPath.row];
        [self showViewController:browserViewController sender:self];
    }
}

- (nullable UIViewController *)previewingContext:(nonnull id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location {
    NSIndexPath *indexPath = [[self collectionView] indexPathForItemAtPoint:location];
    self.selectedIndexPath = indexPath;
    
    UICollectionViewLayoutAttributes *attributes = [[self collectionView] layoutAttributesForItemAtIndexPath:indexPath];
    //设置点击位置出现的白色块大小
    if (@available(iOS 9.0, *)) {
        previewingContext.sourceRect = attributes.frame;
    }
    BBMFPhotoForceTouchPeekViewController *peekViewController = [[BBMFPhotoForceTouchPeekViewController alloc] init];
    BBMFAsset *asset = [self.assets objectAtIndex:indexPath.row];
    peekViewController.preferredContentSize = [self _previewingPreferredContentSizeWithAsset:asset.asset];
    [peekViewController configureWithAsset:asset];
    return peekViewController;
}

#pragma mark - getter
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.minimumLineSpacing = kBBMFMinimumLineInteritemSpacing;
        flowLayout.minimumInteritemSpacing = kBBMFMinimumLineInteritemSpacing;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = BBMFHEXCOLOR(0x444444);
    }
    return _collectionView;
}

- (NSMutableArray<BBMFAsset *> *)selectedPhotos {
    if (!_selectedPhotos) {
        _selectedPhotos = [NSMutableArray array];
    }
    return _selectedPhotos;
}

- (NSMutableArray<BBMFAsset *> *)selectedVideos {
    if (!_selectedVideos) {
        _selectedVideos = [NSMutableArray array];
    }
    return _selectedVideos;
}

- (NSMutableArray<BBMFAsset *> *)selectedAllAssets {
    if (!_selectedAllAssets) {
        _selectedAllAssets = [NSMutableArray array];
    }
    return _selectedAllAssets;
}

@end
