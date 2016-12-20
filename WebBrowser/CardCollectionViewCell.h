//
//  CardCollectionViewCell.h
//  WebBrowser
//
//  Created by 钟武 on 2016/12/20.
//  Copyright © 2016年 钟武. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^reloadBlock)();

@interface CardCollectionViewCell : UICollectionViewCell

@property (nonatomic, weak) UICollectionView *collectionView;
@property (nonatomic, copy) reloadBlock reloadBlock;

@end
