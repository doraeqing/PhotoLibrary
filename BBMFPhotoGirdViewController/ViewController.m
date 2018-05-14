//
//  ViewController.m
//  BBMFPhotoGirdViewController
//
//  Created by lu9869 on 2018/3/27.
//  Copyright © 2018年 wk. All rights reserved.
//

#import "ViewController.h"
#import "BBMFPhotoGirdViewController.h"

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSArray<BBMFAssetCollection *> *assetCollection;
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:[self tableView]];
    
    void (^requestAssetCollectionBlock) (void) = ^{
        [[BBMFPhotoManager defaultManager] requestAssetCollectionCompletion:^(NSArray<BBMFAssetCollection *> *assetCollection, NSDictionary *options) {
            self.assetCollection = assetCollection;
            self.title = self.assetCollection.firstObject.name;
            [[self tableView] reloadData];
        }];
    };
    
    void (^requestAuthorizationBlock) (void) = ^ {
        [[BBMFPhotoManager defaultManager] requestAuthorization:^(PHAuthorizationStatus status) {
            if (status != PHAuthorizationStatusAuthorized) {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"你没有允许访问相册的权限" message:@"可以到设置页面开启权限" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
                [alert addAction:action];
                [self presentViewController:alert animated:YES completion:nil];
            } else {
                requestAssetCollectionBlock();
            }
        }];
    };

    if ([[BBMFPhotoManager defaultManager] authorizationStatus] != PHAuthorizationStatusAuthorized) {
        requestAuthorizationBlock();
    } else {        
        requestAssetCollectionBlock();
    }
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [[self tableView] setFrame:self.view.bounds];
}

- (IBAction)push:(id)sender {
    BBMFPhotoGirdViewController *bvvc = [[BBMFPhotoGirdViewController alloc] init];
    [self.navigationController pushViewController:bvvc animated:YES];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.assetCollection.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    cell.textLabel.text = [self.assetCollection[indexPath.row] name];
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    BBMFPhotoGirdViewController *bvvc = [[BBMFPhotoGirdViewController alloc] init];
    BBMFAssetCollection *collection = self.assetCollection[indexPath.row];
    [[BBMFPhotoManager defaultManager] requestAssetsInAssetCollection:collection completion:^(NSArray<BBMFAsset *> *assets, NSDictionary *options) {
        [bvvc configureWithAssets:assets];
        [self.navigationController pushViewController:bvvc animated:YES];
    }];
    
//    [bvvc configureFecthResult:[self.assetCollection[indexPath.row] fetchResult]];
//    [self.navigationController pushViewController:bvvc animated:YES];
}

#pragma mark - getter
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

@end
