//
//  BBMFPhotoBrowserViewController.h
//  BBMFPhotoGirdViewController
//
//  Created by lu9869 on 2018/3/29.
//  Copyright © 2018年 wk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BBMFPhotoManager.h"

@interface BBMFPhotoBrowserViewController : UIViewController

@property (nonatomic, strong, readonly) NSArray <BBMFAsset *> *assets;

- (void)configureWithAssets:(NSArray <BBMFAsset *> *)assets currentIndex:(NSInteger)index;

@end
