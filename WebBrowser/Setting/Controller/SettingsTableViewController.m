//
//  SettingsTableViewController.m
//  WebBrowser
//
//  Created by 钟武 on 2017/1/10.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import "SettingsTableViewController.h"
#import "SettingActivityTableViewCell.h"
#import "NSFileManager+ZWUtility.h"

typedef enum : NSUInteger {
    CellKindForCache,
} CellKind;

static NSString *const kSettingActivityTableViewCellIdentifier = @"SettingActivityTableViewCellIdentifier";
static NSString *const kSettingPlaceholderTableViewCellIdentifier   = @"SettingPlaceholderTableViewCellIdentifier";

@interface SettingsTableViewController ()

@property (nonatomic, copy) NSArray *dataArray;

@end

@implementation SettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"设置";
    
    self.dataArray = @[@"清除缓存"];
    
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([SettingActivityTableViewCell class]) bundle:nil] forCellReuseIdentifier:kSettingActivityTableViewCellIdentifier];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kSettingPlaceholderTableViewCellIdentifier];
}

- (void)handleTableViewSelectAt:(NSInteger)index{
    if (index == 0) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"您确定清除缓存？" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action){
            SettingActivityTableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            [cell.activityIndicatorView startAnimating];
            cell.rightLabel.text = @"";
            
            [self cleanCacheWithURLs:[NSArray arrayWithObjects:[NSURL URLWithString:CachePath], [NSURL URLWithString:TempPath], nil] completionBlock:^{
                [cell.activityIndicatorView stopAnimating];
                [cell.rightLabel setText:@"0M"];
            }];
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){}];
        
        [alert addAction:defaultAction];
        [alert addAction:cancelAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

#pragma mark - Helper Method

- (UITableViewCell *)cacheCellWithIndexPath:(NSIndexPath *)indexPath{
    SettingActivityTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kSettingActivityTableViewCellIdentifier];
    
    cell.leftLabel.text = self.dataArray[indexPath.row];
    [cell.activityIndicatorView startAnimating];
    
    [cell setCalculateBlock:^{
        NSArray *urlArray = [NSArray arrayWithObjects:[NSURL URLWithString:CachePath], [NSURL URLWithString:TempPath], nil];

        long long size = [[NSFileManager defaultManager] getAllocatedSizeOfCacheDirectoryAtURLS:urlArray error:NULL];
        
        if (size == -1)
            return @"0M";
        
        NSString *sizeStr = [NSByteCountFormatter stringFromByteCount:size countStyle:NSByteCountFormatterCountStyleBinary];
        
        return sizeStr;
    }];
    
    return cell;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    switch (indexPath.row) {
        case CellKindForCache:
            cell = [self cacheCellWithIndexPath:indexPath];
            break;
        default:
            //never called
            cell = [tableView dequeueReusableCellWithIdentifier:kSettingPlaceholderTableViewCellIdentifier];
            break;
    }
    return cell;
}

#pragma mark - UITableViewDelegate Method

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self handleTableViewSelectAt:indexPath.row];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Clean Cache Method

- (void)cleanCacheWithURLs:(NSArray<NSURL *> *)array completionBlock:(SettingVoidReturnNoParamsBlock)completionBlock{
    if (array.count == 0) {
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [array enumerateObjectsUsingBlock:^(NSURL *diskCacheURL, NSUInteger idx, BOOL *stop){
            @autoreleasepool {
                NSArray *array = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:diskCacheURL includingPropertiesForKeys:nil options:0 error:NULL];
                foreach(path, array) {
                    if (![[path lastPathComponent] isEqualToString:@"Snapshots"]) {
                        [[NSFileManager defaultManager] removeItemAtURL:path error:NULL];
                    }
                }
            }
        }];
        
        if (completionBlock) {
            dispatch_main_safe_async(^{
                completionBlock();
            })
        }
    });
}

- (void)dealloc{
    DDLogDebug(@"SettingsTableViewController dealloc");
}

@end
