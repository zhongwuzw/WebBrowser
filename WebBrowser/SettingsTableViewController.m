//
//  SettingsTableViewController.m
//  WebBrowser
//
//  Created by 钟武 on 2017/1/10.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import "SettingsTableViewController.h"
#import "SettingActivityTableViewCell.h"
#import "SettingSwitchTableViewCell.h"
#import "NSFileManager+ZWUtility.h"
#import "PreferenceHelper.h"

typedef enum : NSUInteger {
    CellKindForCache,
    CellKindForNoImage,
} CellKind;

static NSString *const SettingActivityTableViewCellIdentifier = @"SettingActivityTableViewCellIdentifier";
static NSString *const SettingSwitchTableViewCellIdentifier   = @"SettingSwitchTableViewCellIdentifier";
static NSString *const SettingPlaceholderTableViewCellIdentifier   = @"SettingPlaceholderTableViewCellIdentifier";

@interface SettingsTableViewController ()

@property (nonatomic, copy) NSArray *dataArray;

@end

@implementation SettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"设置";
    
    self.dataArray = @[@"清除缓存",@"无图浏览模式"];
    
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([SettingActivityTableViewCell class]) bundle:nil] forCellReuseIdentifier:SettingActivityTableViewCellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([SettingSwitchTableViewCell class]) bundle:nil] forCellReuseIdentifier:SettingSwitchTableViewCellIdentifier];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:SettingPlaceholderTableViewCellIdentifier];
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
    SettingActivityTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:SettingActivityTableViewCellIdentifier];
    
    cell.leftLabel.text = self.dataArray[indexPath.row];
    [cell.activityIndicatorView startAnimating];
    
    [cell setCalculateBlock:^{
        NSArray *urlArray = [NSArray arrayWithObjects:[NSURL URLWithString:CachePath], [NSURL URLWithString:TempPath], nil];
        long long size = [[NSFileManager defaultManager] getAllocatedSizeOfDirectoryAtURLS:urlArray error:nil];
        
        if (size == -1)
            return @"0M";
        
        NSString *sizeStr = [NSByteCountFormatter stringFromByteCount:size countStyle:NSByteCountFormatterCountStyleBinary];
        
        return sizeStr;
    }];
    
    return cell;
}

- (UITableViewCell *)noImageModeCellWithIndexPath:(NSIndexPath *)indexPath{
    SettingSwitchTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:SettingSwitchTableViewCellIdentifier];
    cell.leftLabel.text = self.dataArray[indexPath.row];
    [cell.switchControl setOn:[PreferenceHelper boolForKey:KeyNoImageModeStatus]];
    cell.valueChangedBlock = ^(UISwitch *switchControl){
        [PreferenceHelper setBool:switchControl.on forKey:KeyNoImageModeStatus];
        [Notifier postNotification:[NSNotification notificationWithName:kNoImageModeChanged object:nil]];
    };
    
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
        case CellKindForNoImage:
            cell = [self noImageModeCellWithIndexPath:indexPath];
            break;
        default:
            //never called
            cell = [tableView dequeueReusableCellWithIdentifier:SettingPlaceholderTableViewCellIdentifier];
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
                NSArray *resourceKeys = @[NSURLIsDirectoryKey];
                
                NSDirectoryEnumerator *fileEnumerator = [[NSFileManager defaultManager] enumeratorAtURL:diskCacheURL includingPropertiesForKeys:resourceKeys options:NSDirectoryEnumerationSkipsHiddenFiles errorHandler:NULL];
                
                NSMutableArray *urlsToDelete = [NSMutableArray array];
                foreach(fileURL, fileEnumerator) {
                    NSDictionary *resourceValues = [fileURL resourceValuesForKeys:resourceKeys error:NULL];
                    
                    if ([resourceValues[NSURLIsDirectoryKey] boolValue]) {
                        continue;
                    }
                    
                    [urlsToDelete addObject:fileURL];
                }
                
                foreach(fileURL, urlsToDelete) {
                    [[NSFileManager defaultManager] removeItemAtURL:fileURL error:nil];
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
