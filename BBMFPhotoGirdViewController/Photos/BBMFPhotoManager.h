//
//  BBMFPhotoManager.h
//  BBMFPhotoGirdViewController
//
//  Created by lu9869 on 2018/3/27.
//  Copyright © 2018年 wk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import "BBMFAssetCollection.h"

/// 想要过滤掉的媒体类型
typedef NS_ENUM(NSInteger, BBMFFilterAssetMediaType) {
    BBMFFilterAssetMediaTypeNone = 0,           //默认，不过滤任何类型
    BBMFFilterAssetMediaTypeImage = 1 << 0,     //过滤掉图片
    BBMFFilterAssetMediaTypeVideo = 1 << 1,     //过滤掉视频
    BBMFFilterAssetMediaTypeAudio = 1 << 2      //过滤掉音频
};

@interface BBMFPhotoManager : NSObject

+ (instancetype)defaultManager;

/**
 相册认证状态
 
 @return 相册认证结果
 */
- (PHAuthorizationStatus)authorizationStatus;

/**
 请求访问用户相册
 
 @param handler 访问权限结果回调
 */
- (void)requestAuthorization:(void (^) (PHAuthorizationStatus status))handler;

/**
 获取所有的相册

 @param completion 返回所有的相册
 */
- (void)requestAssetCollectionCompletion:(void(^)(NSArray <BBMFAssetCollection *> *assetCollection, NSDictionary *options))completion;

/**
 获取某个相册下所有的照片

 @param assetCollection 相册
 @param completion 返回该相册下所有的asset
 */
- (void)requestAssetsInAssetCollection:(BBMFAssetCollection *)assetCollection completion:(void(^)(NSArray <BBMFAsset *> *assets, NSDictionary *options))completion;

- (PHImageRequestID)requestImageWithAsset:(PHAsset *)phAsset targetSize:(CGSize)targetSize completion:(void(^)(UIImage *image, NSDictionary *options))completion;

- (PHImageRequestID)requestImageWithAsset:(PHAsset *)phAsset targetSize:(CGSize)targetSize progressHandler:(PHAssetImageProgressHandler)progressHandler completion:(void(^)(UIImage *image, NSDictionary *options))completion;

/**
 获取PHLivePhoto类型的照片，包含iCloud上的照片

 @param phAsset asset
 @param targetSize 想要获取照片的size
 @param completion 返回对应的PHLivePhoto实例
 @return Uniquely identify a cancellable async request
 */
- (PHImageRequestID)requestLivePhotoWithAsset:(PHAsset *)phAsset targetSize:(CGSize)targetSize completion:(void(^)(PHLivePhoto *livePhoto, NSDictionary *options))completion API_AVAILABLE(ios(9.1));

/**
 获取PHLivePhoto类型的照片，包含iCloud上的照片

 @param phAsset asset
 @param targetSize 想要获取照片的size
 @param progressHandler 下载进度
 @param completion 返回对应的PHLivePhoto实例
 @return Uniquely identify a cancellable async request
 */
- (PHImageRequestID)requestLivePhotoWithAsset:(PHAsset *)phAsset targetSize:(CGSize)targetSize progressHandler:(PHAssetImageProgressHandler)progressHandler completion:(void(^)(PHLivePhoto *livePhoto, NSDictionary *options))completion API_AVAILABLE(ios(9.1));

/**
 获取imageData，可以从获取iCloud获取data

 @param phAsset asset
 @param completion 返回对应的imageData等信息
 @return PHImageRequestID
 */
- (PHImageRequestID)requestImageDataWithAsset:(PHAsset *)phAsset completion:(void(^)(NSData *__nullable imageData, NSString *__nullable dataUTI, UIImageOrientation orientation, NSDictionary *__nullable info))completion;

/**
 获取imageData，可以从获取iCloud获取data，提供下载进度回调

 @param phAsset asset
 @param progressHandler 下载进度回调
 @param completion 返回对应的imageData等信息
 @return PHImageRequestID
 */
- (PHImageRequestID)requestImageDataWithAsset:(PHAsset *)phAsset progressHandler:(PHAssetImageProgressHandler)progressHandler completion:(void(^)(NSData *__nullable imageData, NSString *__nullable dataUTI, UIImageOrientation orientation, NSDictionary *__nullable info))completion;

/**
 获取imageData，提供是否需要从iCloud下载照片，提供下载进度回调

 @param phAsset asset
 @param networkAccessAllowed 是否允许从iCloud下载照片
 @param progressHandler 下载进度
 @param completion 返回对应的imageData等信息
 @return PHImageRequestID
 */
- (PHImageRequestID)requestImageDataWithAsset:(PHAsset *)phAsset  networkAccessAllowed:(BOOL)networkAccessAllowed progressHandler:(PHAssetImageProgressHandler)progressHandler completion:(void(^)(NSData *__nullable imageData, NSString *__nullable dataUTI, UIImageOrientation orientation, NSDictionary *__nullable info))completion;

@end
