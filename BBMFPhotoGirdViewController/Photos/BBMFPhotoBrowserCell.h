//
//  BBMFPhotoBrowserCell.h
//  BBMFPhotoGirdViewController
//
//  Created by lu9869 on 2018/3/29.
//  Copyright © 2018年 wk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BBMFPhotoBrowserCell : UICollectionViewCell

@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong, readonly) UIImageView *imageView;
@property (nonatomic, copy) NSString *representedAssetIdentifier;

@end
