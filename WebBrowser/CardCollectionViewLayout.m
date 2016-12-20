//
//  CardCollectionViewLayout.m
//  WebBrowser
//
//  Created by 钟武 on 2016/12/20.
//  Copyright © 2016年 钟武. All rights reserved.
//

#import "CardCollectionViewLayout.h"

static CGFloat BottomPercent = 0.85;

@interface CardCollectionViewLayout ()

@property (nonatomic, strong) NSMutableArray<NSIndexPath *> *insertPath;
@property (nonatomic, strong) NSMutableArray<NSIndexPath *> *deletePath;
@property (nonatomic, strong) NSMutableArray<CardLayoutAttributes *> *attributesList;
@property (nonatomic, assign, readonly) CGSize cellSize;
@property (nonatomic, assign) CGFloat titleHeight;

@end

@implementation CardCollectionViewLayout

- (instancetype)init{
    if (self = [super init]) {
        self.titleHeight = 80;
        self.insertPath = [NSMutableArray array];
        self.deletePath = [NSMutableArray array];
        self.attributesList = [NSMutableArray array];
    }
    return self;
}

- (CGSize)cellSize{
    CGFloat w = self.collectionView.width;
    CGFloat h = self.collectionView.height * BottomPercent;
    CGSize size = CGSizeMake(w, h);
    return size;
}

- (void)reloadCollection{
    dispatch_main_async_safe(^{
        [self.collectionView performBatchUpdates:^{
            [self.collectionView reloadData];
        }completion:nil];
    });
}

- (void)generateAttributesList{
    NSInteger count = [self.collectionView numberOfItemsInSection:0];
    NSInteger attributesAcount = self.attributesList.count;
    
    if (count > attributesAcount) {
        NSInteger delta = count - attributesAcount;
        for (int i = 0; i < delta; i++) {
            CardLayoutAttributes *attr = [CardLayoutAttributes layoutAttributesForCellWithIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
            [self.attributesList addObject:attr];
        }
    }
    [[self.attributesList subarrayWithRange:NSMakeRange(0, count)] enumerateObjectsUsingBlock:^(CardLayoutAttributes *attribute, NSUInteger idx, BOOL *stop){
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:idx inSection:0];
        attribute.indexPath = indexPath;
        [self applyAttribute:attribute];
    }];
}

- (void)applyAttribute:(CardLayoutAttributes *)attribute{
    NSInteger shitIdx = self.collectionView.contentOffset.y / self.titleHeight;
    NSInteger index = attribute.indexPath.row;
    CGRect currentFrame = CGRectMake(self.collectionView.frame.origin.x, self.titleHeight * index, self.cellSize.width, self.cellSize.height);
    CGRect attributeFrame = CGRectMake(currentFrame.origin.x, self.collectionView.contentOffset.y, self.cellSize.width, self.cellSize.height);
    
    if ((index <= shitIdx && index >= shitIdx - 2) || index == 0) {
        attribute.frame = attributeFrame;
    }
    else if (index < shitIdx - 2){
        attribute.hidden = YES;
        attribute.frame = attributeFrame;
    }
    else{
        attribute.frame = currentFrame;
    }
}

- (void)prepareLayout{
    [super prepareLayout];
    
    [self generateAttributesList];
}

- (CGSize)collectionViewContentSize{
    NSInteger count = [self.collectionView numberOfItemsInSection:0];
    CGFloat contentHeight = self.titleHeight * (count - 1) + self.cellSize.height;
    return CGSizeMake(self.cellSize.width, contentHeight);
}

- (CardLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath{
    return self.attributesList[indexPath.row];
}

- (NSArray<CardLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect{
    NSArray<CardLayoutAttributes *> *attributesList = [self.attributesList filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(CardLayoutAttributes *attribute, NSDictionary *bindings){
        return CGRectIntersectsRect(attribute.frame, rect);
    }]];
    
    return attributesList;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds{
    return YES;
}

@end

@implementation CardLayoutAttributes

@end
