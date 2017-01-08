//
//  SearchTableViewCell.m
//  WebBrowser
//
//  Created by 钟武 on 2017/1/7.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import "SearchTableViewCell.h"
#import "HttpHelper.h"

@interface SearchTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *leftImageView;
@property (weak, nonatomic) IBOutlet UILabel *searchResultLabel;

@end

@implementation SearchTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    
}

- (void)updateCellWithString:(NSString *)text{
    self.searchResultLabel.text = text;
    
    if ([HttpHelper isURL:text])
        [self.leftImageView setImage:[UIImage imageNamed:@"search_list_url"]];
    else
        [self.leftImageView setImage:[UIImage imageNamed:@"search_list_search"]];
}

@end
