//
//  BBMFPhotoManager.m
//  BBMFPhotoGirdViewController
//
//  Created by lu9869 on 2018/3/27.
//  Copyright © 2018年 wk. All rights reserved.
//

#import "BBMFPhotoManager.h"
#import <ImageIO/ImageIO.h>

PHOTOS_STATIC_INLINE BBMFAssetMediaType (_BBMFAssetMediaTypeFromPHAsset)(PHAsset *asset){
    switch (asset.mediaType) {
        case PHAssetMediaTypeImage:
        {
            if (@available(iOS 9.1, *)) {
                if (asset.mediaSubtypes == PHAssetMediaSubtypePhotoLive) {
                    return BBMFAssetMediaTypePhotoLive;
                }
            }
            if ([[asset valueForKey:@"filename"] hasSuffix:@"GIF"]) {
                return BBMFAssetMediaTypePhotoGIF;
            }
            return BBMFAssetMediaTypePhoto;
        }
            break;
        case PHAssetMediaTypeVideo:
            return BBMFAssetMediaTypeVideo;
        case PHAssetMediaTypeAudio:
            return BBMFAssetMediaTypeAudio;
        case PHAssetMediaTypeUnknown:
            return BBMFAssetMediaTypeUnknown;
        default:
            return BBMFAssetMediaTypeUnknown;
            break;
    }
}

@interface BBMFPhotoManager () {
    dispatch_queue_t _queue;
}
@end

@implementation BBMFPhotoManager

#pragma mark - Init

- (instancetype)init {
    if (self = [super init]) {
        _queue = dispatch_queue_create("com.bbmf.photoprocess-thread", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

+ (instancetype)defaultManager {
    static BBMFPhotoManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[BBMFPhotoManager alloc] init];
    });
    return instance;
}

#pragma mark - Request

/// 获取相册
- (void)requestAssetCollectionCompletion:(void (^)(NSArray<BBMFAssetCollection *> *, NSDictionary *))completion {
    // 用户的iCloud照片流
    PHFetchResult *myPhotoStreamAlbum = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum
                                                                                 subtype:PHAssetCollectionSubtypeAlbumMyPhotoStream
                                                                                 options:nil];
    // 智能相册(相机胶卷，最近删除，最近添加，自拍，Videos.edg.)
    PHFetchResult <PHAssetCollection *> *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum
                                                                                                subtype:PHAssetCollectionSubtypeAlbumRegular
                                                                                                options:nil];
    // 用户创建的相册
    PHFetchResult <PHCollection *> *userCollections = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
    
    // 使用iTunes 同步的所有相册
    PHFetchResult <PHAssetCollection *> *syncedAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum
                                                                                                 subtype:PHAssetCollectionSubtypeAlbumSyncedAlbum
                                                                                                 options:nil];
    
    // iCloud同步过来的相册
    PHFetchResult *sharedAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum
                                                                           subtype:PHAssetCollectionSubtypeAlbumCloudShared
                                                                           options:nil];
    
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    //过滤逻辑
    //    options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeVideo];
    //    options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
    NSArray *phAlbums = @[myPhotoStreamAlbum, smartAlbums, userCollections, syncedAlbums, sharedAlbums];
    NSMutableArray *albums = [NSMutableArray array];
    [phAlbums enumerateObjectsUsingBlock:^(PHFetchResult *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj enumerateObjectsUsingBlock:^(PHAssetCollection *_Nonnull assetCollection, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([assetCollection isKindOfClass:[PHAssetCollection class]]) {
                PHFetchResult <PHAsset *> *assets = [PHAsset fetchAssetsInAssetCollection:assetCollection options:options];
                NSString *albumName = assetCollection.localizedTitle;
                BOOL canAddAlbum = [self _canAddAlbum:albumName asstesCount:assets.count];
                if (canAddAlbum) {
                    BBMFAssetCollection *album = [[BBMFAssetCollection alloc] init];
                    album.fetchResult = assets;
                    album.name = albumName;
                    BOOL needInsertAtFirst = [self _needInsertAlbumAtFirst:albumName];
                    if (__builtin_expect(needInsertAtFirst, NO)) {
                        [albums insertObject:album atIndex:0];
                    } else {
                        [albums addObject:album];
                    }
                }
            }
        }];
    }];
    !completion ? : completion(albums.copy, nil);
}

- (void)requestAssetsInAssetCollection:(BBMFAssetCollection *)assetCollection completion:(void (^)(NSArray<BBMFAsset *> *, NSDictionary *))completion {
    NSMutableArray *bbmfAssets = [NSMutableArray array];
    dispatch_async(_queue, ^{
        for (PHAsset *phAsset in assetCollection.fetchResult) {
            @autoreleasepool {
                BBMFAssetMediaType mediaType = _BBMFAssetMediaTypeFromPHAsset(phAsset);
                BBMFAsset *asset = [[BBMFAsset alloc] initWithAsset:phAsset mediaType:mediaType];
                // from http://developer.limneos.net/?ios=8.0&framework=Photos.framework&header=PHAsset.h
                asset.inCloud = [[phAsset valueForKey:@"isCloudPlaceholder"] boolValue];
                [bbmfAssets addObject:asset];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            !completion ? : completion(bbmfAssets, nil);
        });
    });
}

- (PHImageRequestID)requestImageWithAsset:(PHAsset *)phAsset targetSize:(CGSize)targetSize completion:(void (^)(UIImage *, NSDictionary *))completion {
    return [self requestImageWithAsset:phAsset targetSize:targetSize progressHandler:nil completion:completion];
}

- (PHImageRequestID)requestImageWithAsset:(PHAsset *)phAsset targetSize:(CGSize)targetSize progressHandler:(PHAssetImageProgressHandler)progressHandler completion:(void (^)(UIImage *, NSDictionary *))completion {
    // deliveryMode控制图片质量和获取速度
    //PHImageRequestOptionsDeliveryModeOpportunistic  图片质量和获取速度均衡 默认
    //PHImageRequestOptionsDeliveryModeHighQualityFormat 获取高质量图片,不保证获取速度
    //PHImageRequestOptionsDeliveryModeFastFormat 快速获得,不保证质量

    //resizeMode裁剪的方式
    //PHImageRequestOptionsResizeModeNone 不设置 默认
    //PHImageRequestOptionsResizeModeFast  返回的图像可能和目标大小不一样并且质量较低,但效率高.
    //PHImageRequestOptionsResizeModeExact 返回图像必须和目标大小相匹配,并且图像质量也为高质量图像

    //version 请求的图片版本
    //PHImageRequestOptionsVersionCurrent 图片的最新版本（包括所有编辑版本）
    //PHImageRequestOptionsVersionUnadjusted 原版，无任何调整编辑
    //PHImageRequestOptionsVersionOriginal 原始的高保真的版本
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.version = PHImageRequestOptionsVersionCurrent;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
    options.resizeMode = PHImageRequestOptionsResizeModeFast;
    options.synchronous = NO;
    options.networkAccessAllowed = YES;
    options.progressHandler = progressHandler;
    return [[PHImageManager defaultManager] requestImageForAsset:phAsset targetSize:targetSize contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
//        BOOL downloadFinished = (![[info objectForKey : PHImageCancelledKey] boolValue] && ![info objectForKey : PHImageErrorKey]);
        BOOL downloadFinished = ![[info objectForKey:PHImageCancelledKey] boolValue];
        if (downloadFinished) {
            !completion ? : completion(result, info);
        }
    }];
    
    //!!!!:todo
//    return [[PHImageManager defaultManager] requestImageDataForAsset:phAsset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
//        if (completion) {
////            UIImage *image = [UIImage imageWithData:imageData];
////            BOOL downloadFinished = (![[info objectForKey : PHImageCancelledKey] boolValue] && ![info objectForKey : PHImageErrorKey]);
////            if(downloadFinished) {
////                !completion ? : completion(result, info);
////            }
//            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                CFDictionaryRef myOptions = NULL;
//                CFStringRef myKeys[2];
//                CFTypeRef myValues[2];
//                // 第一次解压缩耗时长 第二次很快 直接读缓存
//                myKeys[0] = kCGImageSourceShouldCache;
//                myValues[0] = kCFBooleanTrue;
//
//                myKeys[1] = kCGImageSourceShouldAllowFloat;
//                myValues[1] = kCFBooleanTrue;
//                myOptions = CFDictionaryCreate(NULL, (const void **)myKeys, (const void **)myValues, 2, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
//
//                CGImageSourceRef imageSource = CGImageSourceCreateWithData((__bridge CFDataRef)imageData, myOptions);
//                CFRelease(myOptions);
//                if (imageSource != NULL) {
//                    fprintf(stderr, "获取图像源失败");
//                    CGImageRef imageRef = CGImageSourceCreateImageAtIndex(imageSource, 0, NULL);
//                    CFRelease(imageSource);
//                    if (imageRef) {
//                        CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
////                        CGFloat scale = [UIScreen mainScreen].scale;
////                        CGSize size = [UIScreen mainScreen].bounds.size;
////                        CGFloat w = 0.0, h = 0.0;
////                        CFDictionaryRef properties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, NULL);
////                        CFRelease(imageSource);
////                        if (properties) {
////                            CFTypeRef value = CFDictionaryGetValue(properties, kCGImagePropertyPixelWidth);
////                            if (value) {
////                                CFNumberGetValue(value, kCFNumberNSIntegerType, &w);
////                            }
////                            value = CFDictionaryGetValue(properties, kCGImagePropertyPixelHeight);
////                            if (value) {
////                                CFNumberGetValue(value, kCFNumberNSIntegerType, &h);
////                            }
//                            CGContextRef context = CGBitmapContextCreate(NULL, targetSize.width, targetSize.height, 8, 0, colorSpaceRef, kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedFirst);
//                            if (context != NULL) {
//                                CGContextDrawImage(context, CGRectMake(0, 0, targetSize.width, targetSize.height), imageRef);
//                                imageRef = CGBitmapContextCreateImage(context);
//                                CGContextRelease(context);
//                            }
//                            dispatch_async(dispatch_get_main_queue(), ^{
//                                if (imageRef) {
//                                    completion([UIImage imageWithCGImage:imageRef], info);
//                                    CGImageRelease(imageRef);
//                                }
//                            });
////                        }
//
//                    }
//                }
//            });
//        }
//    }];
}

- (PHImageRequestID)requestLivePhotoWithAsset:(PHAsset *)phAsset targetSize:(CGSize)targetSize completion:(void (^)(PHLivePhoto *, NSDictionary *))completion {
    return [self requestLivePhotoWithAsset:phAsset targetSize:targetSize progressHandler:nil completion:completion];
}

- (PHImageRequestID)requestLivePhotoWithAsset:(PHAsset *)phAsset targetSize:(CGSize)targetSize progressHandler:(PHAssetImageProgressHandler)progressHandler completion:(void (^)(PHLivePhoto *, NSDictionary *))completion {
    PHLivePhotoRequestOptions *options = [[PHLivePhotoRequestOptions alloc] init];
    options.version = PHImageRequestOptionsVersionCurrent;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
    options.networkAccessAllowed = YES;
    options.progressHandler = progressHandler;
    return [[PHImageManager defaultManager] requestLivePhotoForAsset:phAsset targetSize:targetSize contentMode:PHImageContentModeDefault options:options resultHandler:^(PHLivePhoto * _Nullable livePhoto, NSDictionary * _Nullable info) {
//        BOOL downloadFinished = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey]);
        BOOL downloadFinished = ![[info objectForKey:PHImageCancelledKey] boolValue];
        if(downloadFinished) {
            !completion ? : completion(livePhoto, info);
        }
    }];
}

- (PHImageRequestID)requestImageDataWithAsset:(PHAsset *)phAsset completion:(void (^)(NSData * _Nullable, NSString * _Nullable, UIImageOrientation, NSDictionary * _Nullable))completion {
    return [self requestImageDataWithAsset:phAsset progressHandler:nil completion:completion];
}

- (PHImageRequestID)requestImageDataWithAsset:(PHAsset *)phAsset progressHandler:(PHAssetImageProgressHandler)progressHandler completion:(void (^)(NSData * _Nullable, NSString * _Nullable, UIImageOrientation, NSDictionary * _Nullable))completion {
    return [self requestImageDataWithAsset:phAsset networkAccessAllowed:YES progressHandler:progressHandler completion:completion];
}

- (PHImageRequestID)requestImageDataWithAsset:(PHAsset *)phAsset networkAccessAllowed:(BOOL)networkAccessAllowed progressHandler:(PHAssetImageProgressHandler)progressHandler completion:(void (^)(NSData * _Nullable, NSString * _Nullable, UIImageOrientation, NSDictionary * _Nullable))completion {
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.version = PHImageRequestOptionsVersionCurrent;
    options.resizeMode = PHImageRequestOptionsResizeModeFast;
    options.networkAccessAllowed = networkAccessAllowed;
    options.progressHandler = progressHandler;
    return [[PHImageManager defaultManager] requestImageDataForAsset:phAsset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        BOOL downloadFinished = ![[info objectForKey:PHImageCancelledKey] boolValue];
//        && ![info objectForKey:PHImageErrorKey]
        if (downloadFinished) {
            !completion ? : completion(imageData, dataUTI, orientation, info);
        }
    }];
}

#pragma mark - private 

- (BOOL)_canAddAlbum:(NSString *)albumName asstesCount:(NSUInteger)asstesCount {
    if (asstesCount &&
        (![albumName isEqualToString:@"最近删除"] ||
         ![albumName isEqualToString:@"Recently Deleted"])) {
            return YES;
    }
    return NO;
}

- (BOOL)_needInsertAlbumAtFirst:(NSString *)albumName {
    if ([albumName isEqualToString:@"相机胶卷"] ||
        [albumName isEqualToString:@"所有照片"] ||
        [albumName isEqualToString:@"Camera Roll"] ||
        [albumName isEqualToString:@"All Photos"]) {
        return YES;
    }
    return NO;
}

@end
