//
//  ExtentionsTableViewController.m
//  WebBrowser
//
//  Created by 钟武 on 2017/10/27.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import "ExtentionsTableViewController.h"
#import "SettingSwitchTableViewCell.h"
#import "PreferenceHelper.h"

static NSString *const kExtentionsTableViewSwitchCellIdentifier = @"ExtentionsTableViewSwitchCellIdentifier";
static NSString *const kExtentionsTableViewDefaultCellIdentifier = @"ExtentionsTableViewDefaultCellIdentifier";

typedef NS_ENUM(NSUInteger, ExtentionsTableViewCellKind) {
    ExtentionsTableViewCellKindOfNoImage,
    ExtentionsTableViewCellKindOfBlockBaiduAD,
    ExtentionsTableViewCellKindOfEyeProtective
};

@interface ExtentionsTableViewController ()

@property (nonatomic, copy) NSArray *dataArray;
@property (nonatomic, copy) NSArray *footerDescriptionArray;
@property (nonatomic, copy) NSArray *dataKeyArray;
@property (nonatomic, strong) NSIndexPath *eyeColorIndexPath;

@end

@implementation ExtentionsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"扩展";
    
    self.dataArray = @[@"无图模式",@"去除百度广告",@"护眼模式"];
    self.footerDescriptionArray = @[@"注意：无图模式仅对图片进行了隐藏，浏览器依然会发起图片资源请求",@"去除百度搜索页面广告及banner推广,基于https://greasyfork.org/scripts/24192-kill-baidu-ad/code/Kill%20Baidu%20AD.user.js代码修改,感谢作者@hoothin",@"护眼扩展,修改网页背景色,关闭护眼功能需刷新页面才能生效"];
    self.dataKeyArray = @[KeyNoImageModeStatus, KeyBlockBaiduADStatus, KeyEyeProtectiveStatus];
    self.tableView.sectionHeaderHeight = 0;
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([SettingSwitchTableViewCell class]) bundle:nil] forCellReuseIdentifier:kExtentionsTableViewSwitchCellIdentifier];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kExtentionsTableViewDefaultCellIdentifier];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == ExtentionsTableViewCellKindOfEyeProtective) {
        return [PreferenceHelper boolForKey:KeyEyeProtectiveStatus] ? 5 : 1;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == ExtentionsTableViewCellKindOfEyeProtective && indexPath.row > 0) {
        return [self configureEyeProtectiveCellAtIndexPath:indexPath];
    }
    
    SettingSwitchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kExtentionsTableViewSwitchCellIdentifier forIndexPath:indexPath];
    
    ValueChangedBlock valueChangedBlock = nil;
    
    if (indexPath.section == ExtentionsTableViewCellKindOfNoImage) {
        valueChangedBlock = ^(UISwitch *sw){
            [Notifier postNotification:[NSNotification notificationWithName:kNoImageModeChanged object:nil]];
        };
    }
    else if (indexPath.section == ExtentionsTableViewCellKindOfEyeProtective) {
        valueChangedBlock = ^(UISwitch *sw){
            NSMutableArray<NSIndexPath *> *array = [NSMutableArray arrayWithCapacity:4];
            for (int i = 1; i < 5; i++) {
                [array addObject:[NSIndexPath indexPathForRow:i inSection:ExtentionsTableViewCellKindOfEyeProtective]];
            }
            if (sw.on) {
                [tableView insertRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationTop];
            }
            else {
                [tableView deleteRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationBottom];
            }
        };
    }
    
    [self configureExtentionCell:cell section:indexPath.section valueChangedBlock:valueChangedBlock];
 
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
    return self.footerDescriptionArray[section];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.eyeColorIndexPath && !([self.eyeColorIndexPath compare:indexPath] == NSOrderedSame)) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:self.eyeColorIndexPath];
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        [Notifier postNotificationName:kEyeProtectiveModeChanged object:nil];
    }
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    [PreferenceHelper setInteger:indexPath.row forKey:KeyEyeProtectiveColorKind];
    
    self.eyeColorIndexPath = indexPath;
}

#pragma mark - Helper method

- (void)configureExtentionCell:(SettingSwitchTableViewCell *)cell section:(NSInteger)section valueChangedBlock:(ValueChangedBlock)block{
    cell.leftLabel.text = self.dataArray[section];
    
    NSString *dataKey = self.dataKeyArray[section];
    if ([dataKey isEqualToString:KeyBlockBaiduADStatus]) {
        [cell.switchControl setOn:[PreferenceHelper boolDefaultYESForKey:KeyBlockBaiduADStatus]];
    }
    else {
        [cell.switchControl setOn:[PreferenceHelper boolForKey:dataKey]];
    }
    
    ValueChangedBlock valueChangedBlock = ^(UISwitch *sw){
        [PreferenceHelper setBool:sw.on forKey:dataKey];
        
        if (block) {
            block(sw);
        }
    };
    
    cell.valueChangedBlock = valueChangedBlock;
}

- (UITableViewCell *)configureEyeProtectiveCellAtIndexPath:(NSIndexPath *)indexPath{
    NSArray<NSString *> *titleArray = @[@"",@"乡土黄",@"豆沙绿",@"浅色灰",@"淡橄榄"];
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kExtentionsTableViewDefaultCellIdentifier];
    cell.textLabel.text = titleArray[indexPath.row];
    
    if ([PreferenceHelper integerDefault1ForKey:KeyEyeProtectiveColorKind] == indexPath.row) {
        self.eyeColorIndexPath = indexPath;
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

@end
