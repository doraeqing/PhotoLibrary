//
//  BBMFAsset.m
//  BBMFPhotoGirdViewController
//
//  Created by lu9869 on 2018/3/27.
//  Copyright © 2018年 wk. All rights reserved.
//

#import "BBMFAsset.h"
#import <Photos/PHAsset.h>

@interface BBMFAsset ()

@property (nonatomic, assign) BBMFAssetMediaType mediaType;

@end

@implementation BBMFAsset

- (instancetype)initWithAsset:(PHAsset *)asset mediaType:(BBMFAssetMediaType)mediaType {
    if (self = [super init]) {
        _asset = asset;
        _mediaType = mediaType;
        _selected = NO;
        _selectedSequenceNumber = 0;
    }
    return self;
}

- (NSString *)representedAssetIdentifier {
    return self.asset.localIdentifier;
}

@end
