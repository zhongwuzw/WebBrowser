//
//  CardBrowserCollectionViewLayout.m
//  WebBrowser
//
//  Created by 钟武 on 2017/3/1.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import "CardBrowserCollectionViewLayout.h"

@interface CardBrowserCollectionViewLayout ()

@property (nonatomic, assign) CGSize contentSize;
@property (nonatomic, assign) CGFloat itemGap;
@property (nonatomic, strong) NSMutableArray<UICollectionViewLayoutAttributes *> *attributes;

@end

@implementation CardBrowserCollectionViewLayout

- (instancetype)init
{
    if (self = [super init]) {
        _attributes = [NSMutableArray array];
    }
    
    return self;
}

- (void)prepareLayout
{
    [super prepareLayout];
    
    self.itemGap = roundf(self.collectionView.frame.size.height*0.2f);
    
    [self.attributes removeAllObjects];
    
    CGFloat top = -110.0f;
    CGFloat left = 6.0f;
    CGFloat width = roundf(self.collectionView.frame.size.width - 2*left);
    CGFloat height = roundf((self.collectionView.frame.size.height/self.collectionView.frame.size.width)*width);
    
    for (NSInteger item = 0; item < [self.collectionView numberOfItemsInSection:0]; item++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:0];
        
        UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        
        CGRect frame = CGRectMake(left, top, width, height);
        attributes.frame = frame;
        attributes.zIndex = item;
        
        // standard angle
        CGFloat angleOfRotation = -61.0f;
        
        CGFloat frameOffset = self.collectionView.contentOffset.y - frame.origin.y - floorf(self.collectionView.frame.size.height/10.0f);
        if (frameOffset > 0) {
            // make the cell at the top fall away
            frameOffset = frameOffset/5.0f;
            frameOffset = MIN(frameOffset, 30.0f);
            angleOfRotation += frameOffset;
        }
        
        // rotation
        CATransform3D rotation = CATransform3DMakeRotation((M_PI*angleOfRotation/180.0f), 1.0f, 0.0f, 0.0f);
        
        // perspective
        CGFloat depth = 300.0f;
        CATransform3D translateDown = CATransform3DMakeTranslation(0.0f, 0.0f, -depth);
        CATransform3D translateUp = CATransform3DMakeTranslation(0.0f, 0.0f, depth);
        CATransform3D scale = CATransform3DIdentity;
        scale.m34 = -1.0f/1500.0f;
        CATransform3D perspective =  CATransform3DConcat(CATransform3DConcat(translateDown, scale), translateUp);
        
        // final transform
        CATransform3D transform = CATransform3DConcat(rotation, perspective);
        
        CGFloat gap = self.itemGap;
        
        if (self.pannedItemIndexPath && item == self.pannedItemIndexPath.item) {
            CGFloat dx = MAX(self.panStartPoint.x - self.panUpdatePoint.x, 0.0f);
            frame.origin.x -= dx;
            attributes.frame = frame;
            attributes.alpha = MAX(1.0f - dx/width, 0);
            
            gap = attributes.alpha * self.itemGap;
        }
        
        attributes.transform3D = transform;
        
        [self.attributes addObject:attributes];
        
        top += gap;
    }
    
    if (self.attributes.count) {
        UICollectionViewLayoutAttributes *lastItemAttributes = [self.attributes lastObject];
        self.contentSize = CGSizeMake(self.collectionView.frame.size.width, CGRectGetMaxY(lastItemAttributes.frame));
    }
}

- (CGSize)collectionViewContentSize
{
    return self.contentSize;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray *attributesInRect = [NSMutableArray array];
    
    foreach(attributes, self.attributes) {
        if (CGRectIntersectsRect(attributes.frame, rect)) {
            [attributesInRect addObject:attributes];
        }
    }
    
    return attributesInRect;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item < self.attributes.count) {
        return self.attributes[indexPath.item];
    }
    return nil;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return YES;
}

- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath
{
    if (itemIndexPath.item < self.attributes.count) {
        return self.attributes[itemIndexPath.item];
    }
    
    return nil;
}

@end
