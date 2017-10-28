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

static NSString *const ExtentionsTableViewCellIdentifier = @"ExtentionsTableViewCellIdentifier";

typedef NS_ENUM(NSUInteger, ExtentionsTableViewCellKind) {
    ExtentionsTableViewCellKindOfNoImage,
    ExtentionsTableViewCellKindOfBlockBaiduAD,
};

@interface ExtentionsTableViewController ()

@property (nonatomic, copy) NSArray *dataArray;
@property (nonatomic, copy) NSArray *footerDescriptionArray;
@property (nonatomic, copy) NSArray *dataKeyArray;

@end

@implementation ExtentionsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"扩展";
    
    self.dataArray = @[@"无图模式",@"去除百度广告"];
    self.footerDescriptionArray = @[@"注意：无图模式仅对图片进行了隐藏，浏览器依然会发起图片资源请求",@"去除百度搜索页面广告及banner推广,基于https://greasyfork.org/scripts/24192-kill-baidu-ad/code/Kill%20Baidu%20AD.user.js代码修改,感谢作者@hoothin"];
    self.dataKeyArray = @[KeyNoImageModeStatus, KeyBlockBaiduADStatus];
    
    self.tableView.sectionHeaderHeight = 0;
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([SettingSwitchTableViewCell class]) bundle:nil] forCellReuseIdentifier:ExtentionsTableViewCellIdentifier];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SettingSwitchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ExtentionsTableViewCellIdentifier forIndexPath:indexPath];
    
    ValueChangedBlock valueChangedBlock = nil;
    
    if (indexPath.section == ExtentionsTableViewCellKindOfNoImage) {
        valueChangedBlock = ^(UISwitch *sw){
            [Notifier postNotification:[NSNotification notificationWithName:kNoImageModeChanged object:nil]];
        };
    }
    
    [self configureExtentionCell:cell section:indexPath.section valueChangedBlock:valueChangedBlock];
 
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
    return self.footerDescriptionArray[section];
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

@end
