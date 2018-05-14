//
//  BBMFAsset.h
//  BBMFPhotoGirdViewController
//
//  Created by lu9869 on 2018/3/27.
//  Copyright © 2018年 wk. All rights reserved.
//

#import <Foundation/Foundation.h>
@class PHAsset;

typedef NS_ENUM(NSInteger, BBMFAssetMediaType) {
    BBMFAssetMediaTypeUnknown = 0,
    BBMFAssetMediaTypePhoto = 1,
    BBMFAssetMediaTypePhotoLive,
    BBMFAssetMediaTypePhotoGIF,
    BBMFAssetMediaTypeVideo,
    BBMFAssetMediaTypeAudio,
};

@interface BBMFAsset : NSObject

- (instancetype)initWithAsset:(PHAsset *)asset mediaType:(BBMFAssetMediaType)mediaType;

@property (nonatomic, strong) PHAsset *asset;

@property (nonatomic, getter=isInCloud) BOOL inCloud;
@property (nonatomic, getter=isSelected) BOOL selected;
@property (nonatomic) NSUInteger selectedSequenceNumber; /// 选中的下标 默认0
@property (nonatomic) int32_t imageRequestID;
@property (nonatomic, copy) NSString *representedAssetIdentifier;
@property (nonatomic, readonly) BBMFAssetMediaType mediaType;

@end
