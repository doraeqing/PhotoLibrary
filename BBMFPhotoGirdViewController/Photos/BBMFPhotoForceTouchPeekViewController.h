//
//  BBMFPhotoForceTouchPeekViewController.h
//  BBMFPhotoGirdViewController
//
//  Created by lu9869 on 2018/4/4.
//  Copyright © 2018年 wk. All rights reserved.
//

#import <UIKit/UIKit.h>
@class BBMFAsset;

@interface BBMFPhotoForceTouchPeekViewController : UIViewController

@property (nonatomic, strong) BBMFAsset *asset;
- (void)configureWithAsset:(BBMFAsset *)asset;

@end
