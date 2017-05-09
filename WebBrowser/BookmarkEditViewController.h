//
//  BookmarkEditViewController.h
//  WebBrowser
//
//  Created by 钟武 on 2017/5/7.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import "BaseTableViewController.h"

@class BookmarkDataManager;

typedef void(^BookmarkEditCompletion)();

@interface BookmarkEditViewController : UIViewController

- (instancetype)initWithDataManager:(BookmarkDataManager *)dataManager completion:(BookmarkEditCompletion)completion;

@end
