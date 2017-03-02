//
//  CardBrowserCollectionViewLayout.h
//  WebBrowser
//
//  Created by 钟武 on 2017/3/1.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CardBrowserCollectionViewLayout : UICollectionViewLayout

@property (nonatomic, strong) NSIndexPath *pannedItemIndexPath;
@property (nonatomic, assign) CGPoint panStartPoint;
@property (nonatomic, assign) CGPoint panUpdatePoint;

@end
