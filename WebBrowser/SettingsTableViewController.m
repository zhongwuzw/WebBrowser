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

#define CELL_IDENTIFIER @"CELL_IDENTIFIER"

@interface SettingsTableViewController ()

@property (nonatomic, copy) NSArray *dataArray;
@property (nonatomic, copy) NSArray *handleSelArray;

@end

@implementation SettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.clearsSelectionOnViewWillAppear = NO;
    self.title = @"设置";
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.dataArray = @[@"清除缓存"];
    
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([SettingActivityTableViewCell class]) bundle:nil] forCellReuseIdentifier:CELL_IDENTIFIER];
    self.tableView.tableFooterView = [UIView new];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)handleTableViewSelectAt:(NSInteger)index{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"您确定清除缓存？" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action){
        SettingActivityTableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        [cell.activityIndicatorView startAnimating];
        cell.rightLabel.text = @"";
        WEAK_REF(self)
        [self cleanCacheWithURLs:[NSArray arrayWithObjects:[NSURL URLWithString:CachePath], [NSURL URLWithString:TempPath], nil] completionBlock:^{
            STRONG_REF(self_)
            if (self__) {
                [self__.tableView reloadData];
            }
        }];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){}];
    
    [alert addAction:defaultAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SettingActivityTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER forIndexPath:indexPath];
    
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
                for (NSURL *fileURL in fileEnumerator) {
                    NSDictionary *resourceValues = [fileURL resourceValuesForKeys:resourceKeys error:NULL];
                    
                    if ([resourceValues[NSURLIsDirectoryKey] boolValue]) {
                        continue;
                    }
                    
                    [urlsToDelete addObject:fileURL];
                }
                
                for (NSURL *fileURL in urlsToDelete) {
                    [[NSFileManager defaultManager] removeItemAtURL:fileURL error:nil];
                }

            }
        }];
        
        if (completionBlock) {
            dispatch_main_async_safe(^{
                completionBlock();
            })
        }
    });
}

@end
