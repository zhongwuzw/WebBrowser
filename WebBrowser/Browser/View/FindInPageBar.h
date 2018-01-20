//
//  FindInPageBar.h
//  WebBrowser
//
//  Created by 钟武 on 2017/5/17.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FindInPageBar : UIView

@property (nonatomic, assign) NSInteger currentResult;
@property (nonatomic, assign) NSInteger totalResults;
@property (nonatomic, copy) NSString *text;

@end
