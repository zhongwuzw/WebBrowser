//
//  SearchTableViewCell.h
//  WebBrowser
//
//  Created by 钟武 on 2017/1/7.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchTableViewCell : UITableViewCell

- (void)updateCellWithString:(NSString *)text;
- (NSString *)cellText;

@end
