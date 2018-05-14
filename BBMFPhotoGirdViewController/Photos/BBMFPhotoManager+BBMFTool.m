//
//  BBMFPhotoManager+BBMFTool.m
//  BBMFPhotoGirdViewController
//
//  Created by lu9869 on 2018/4/11.
//  Copyright © 2018年 wk. All rights reserved.
//

#import "BBMFPhotoManager+BBMFTool.h"

@implementation BBMFPhotoManager (BBMFTool)

- (BOOL)checkAssetMeetTheRequirements:(BBMFAsset *)asset {
    if (asset.mediaType == BBMFAssetMediaTypeUnknown ||
        asset.mediaType == BBMFAssetMediaTypeAudio) {
        NSLog(@"暂不支持的类型");
        return NO;
    }
    if (asset.mediaType == BBMFAssetMediaTypePhoto ||
        asset.mediaType == BBMFAssetMediaTypePhotoLive ||
        asset.mediaType == BBMFAssetMediaTypePhotoGIF) {
        //尺寸大小必须在10*10以上
        if (asset.asset.pixelWidth < 10 || asset.asset.pixelHeight < 10) {
            NSLog(@"请上传宽和高≥10px的图片");
            return NO;
        }
        [self requestImageDataWithAsset:asset.asset completion:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
            
        }];
    } else if (asset.mediaType == BBMFAssetMediaTypeVideo) {
        
    } else {
        NSLog(@"暂不支持的类型");
        return NO;
    }
    return YES;
}

@end
