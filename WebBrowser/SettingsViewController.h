//
//  SettingsViewController.h
//  WebBrowser
//
//  Created by 钟武 on 2016/12/26.
//  Copyright © 2016年 钟武. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettingsCollectionViewCell.h"

@interface SettingsMenuItem : NSObject

@property (nonatomic, copy, readonly) NSString *text;
@property (nonatomic, copy, readonly) NSAttributedString *attributedText;
@property (nonatomic, copy, readonly) void (^action)(void);
@property (nonatomic, strong, readonly) UIImage *image;

+ (instancetype)itemWithText:(NSString *)text image:(UIImage *)image action:(void (^)(void))action;
+ (instancetype)itemWithAttributedText:(NSAttributedString *)attributedText image:(UIImage *)image action:(void (^)(void))action;

@end

@interface SettingsViewController : UIViewController

+ (instancetype)presentFromViewController:(UIViewController *)viewController
                                withItems:(NSArray *)items
                               completion:(void (^)(void))completion;

@end
