//
//  BBMFAssetCollection.h
//  BBMFPhotoGirdViewController
//
//  Created by lu9869 on 2018/3/27.
//  Copyright © 2018年 wk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/PHFetchResult.h>
#import "BBMFAsset.h"

@interface BBMFAssetCollection : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSMutableArray <BBMFAsset *> *assets;

/// 相册中所有的PHAsset合集
@property (nonatomic, strong) PHFetchResult <PHAsset *> *fetchResult;

/// 相册中asset个数
@property (nonatomic, assign, readonly) NSUInteger count;

@end
