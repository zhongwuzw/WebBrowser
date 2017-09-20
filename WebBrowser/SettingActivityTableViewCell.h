//
//  SettingActivityTableViewCell.h
//  WebBrowser
//
//  Created by 钟武 on 2017/1/18.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NSString *(^SettingNoParamsBlock)(void);
typedef void (^SettingVoidReturnNoParamsBlock)(void);
typedef void (^SettingCompletionBlock)(NSString *);

@interface SettingActivityTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *leftLabel;
@property (weak, nonatomic) IBOutlet UILabel *rightLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;


/**
 先在全局队列中执行block，其返回NSString类型，再将其结果作为参数传入completion块中执行

 @param block 返回值类型为NSString
 */
- (void)setCalculateBlock:(SettingNoParamsBlock)block;

@end
