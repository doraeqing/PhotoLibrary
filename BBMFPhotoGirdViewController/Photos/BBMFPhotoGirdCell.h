//
//  BBMFPhotoGirdCell.h
//  BBMFPhotoGirdViewController
//
//  Created by lu9869 on 2018/3/27.
//  Copyright © 2018年 wk. All rights reserved.
//

#import <UIKit/UIKit.h>
@class BBMFAsset;

@protocol BBMFPhotoGirdCellDelegate;

@interface BBMFPhotoGirdCell : UICollectionViewCell

@property (nonatomic, strong, readonly) UIImageView *imageView;
@property (nonatomic, strong, readonly) UIImageView *livePhotoBadgeImageView;
@property (nonatomic, strong, readonly) UIView *coverView;
@property (nonatomic, strong, readonly) UIButton *button;
@property (nonatomic, strong, readonly) BBMFAsset *asset;

@property (nonatomic, copy) NSString *representedAssetIdentifier;
@property (nonatomic, weak) id <BBMFPhotoGirdCellDelegate> delegate;

- (void)setAsset:(BBMFAsset *)asset;

@end

@protocol BBMFPhotoGirdCellDelegate <NSObject>

@optional
- (void)photoGirdCell:(BBMFPhotoGirdCell *)cell didSelectButton:(UIButton *)button;

@end


