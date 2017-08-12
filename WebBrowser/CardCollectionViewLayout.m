//
//  CardCollectionViewLayout.m
//  WebBrowser
//
//  Created by 钟武 on 2016/12/20.
//  Copyright © 2016年 钟武. All rights reserved.
//

#import "CardCollectionViewLayout.h"

static CGFloat BottomPercent = 0.85f;
#define TitleHeight 150

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
        self.titleHeight = TitleHeight;
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
    dispatch_main_safe_async(^{
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
        attribute.zIndex = idx;
        attribute.transform = CGAffineTransformIdentity;
        [self applyAttribute:attribute];
    }];
}

- (void)applyAttribute:(CardLayoutAttributes *)attribute{
    NSInteger index = attribute.indexPath.item;
    CGRect currentFrame = CGRectMake(self.collectionView.bounds.origin.x, self.titleHeight * index, self.cellSize.width, self.cellSize.height);
    
    CGFloat yOffset = (self.collectionView.contentOffset.y >= self.titleHeight * index) ? self.collectionView.contentOffset.y : self.titleHeight * index;
    
    currentFrame.origin.y = yOffset;
    
    attribute.frame = currentFrame;
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
    return self.attributesList[indexPath.item];
}

- (NSArray<CardLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect{
    NSArray<CardLayoutAttributes *> *attributesList = [[self.attributesList subarrayWithRange:NSMakeRange(0, [self.collectionView numberOfItemsInSection:0])] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(CardLayoutAttributes *attribute, NSDictionary *bindings){
        return CGRectIntersectsRect(attribute.frame, rect);
    }]];
    
    return attributesList;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds{
    return YES;
}

- (void)prepareForCollectionViewUpdates:(NSArray<UICollectionViewUpdateItem *> *)updateItems{
    [super prepareForCollectionViewUpdates:updateItems];
    
    [self.deletePath removeAllObjects];
    [self.insertPath removeAllObjects];
    
    foreach(item, updateItems) {
        if (item.updateAction == UICollectionUpdateActionDelete) {
            [self.deletePath addObject:item.indexPathBeforeUpdate];
        }
        else if (item.updateAction == UICollectionUpdateActionInsert){
            [self.insertPath addObject:item.indexPathAfterUpdate];
        }
    }
    
}

- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath{
    UICollectionViewLayoutAttributes *attributes;
    if (itemIndexPath.item > self.attributesList.count - 1) {
        attributes = [super initialLayoutAttributesForAppearingItemAtIndexPath:itemIndexPath];
    }
    else
        attributes = self.attributesList[itemIndexPath.item];
    
    if ([self.insertPath containsObject:itemIndexPath]) {
        NSInteger randomLoc = (itemIndexPath.item % 2 == 0) ? 1 : -1;
        CGFloat x = self.collectionView.width * randomLoc;
        
        attributes.transform = CGAffineTransformMakeTranslation(x, 0);
    }

    return attributes;
}

- (UICollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingItemAtIndexPath:(NSIndexPath *)itemIndexPath{
    UICollectionViewLayoutAttributes *attributes = self.attributesList[itemIndexPath.item];
    
    if ([self.deletePath containsObject:itemIndexPath]) {
        NSInteger randomLoc;
        CGAffineTransform transform = [self.collectionView cellForItemAtIndexPath:itemIndexPath].transform;
        if (transform.tx < 0) {
            randomLoc = -1;
        }
        else if (transform.tx > 0){
            randomLoc = 1;
        }
        else
            randomLoc = (itemIndexPath.item % 2 == 0) ? 1 : -1;
        CGFloat x = self.collectionView.width * randomLoc;
        
        attributes.transform = CGAffineTransformMakeTranslation(x, 0);
    }
    
    return attributes;
}

@end

@implementation CardLayoutAttributes

@end
