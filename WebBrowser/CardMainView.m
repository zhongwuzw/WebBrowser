//
//  CardMainView.m
//  WebBrowser
//
//  Created by 钟武 on 2016/12/20.
//  Copyright © 2016年 钟武. All rights reserved.
//

#import "CardMainView.h"
#import "CardCollectionViewLayout.h"
#import "CardCollectionViewCell.h"
#import "CardMainBottomView.h"
#import "BrowserHeader.h"

#define CardCellIdentifier @"cell"
#define CollectionViewTopMargin 50
#define CollectionViewSideMargin 50

@interface CardMainView () <UICollectionViewDelegate, UICollectionViewDataSource, CardBottomClickedDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray<NSString *> *cardArr;
@property (nonatomic, strong) CardMainBottomView *cardBottomView;

@end

@implementation CardMainView
@synthesize cardArr = _cardArr;

- (NSMutableArray<NSString *> *)cardArr{
    if (!_cardArr) {
        _cardArr = [NSMutableArray array];
    }
    return _cardArr;
}

- (void)setCardsWithArray:(NSArray<NSString *> *)array{
    [self.cardArr removeAllObjects];
    [self.cardArr addObjectsFromArray:array];
    
    dispatch_main_async_safe(^{
        [self.collectionView reloadData];
    })
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self commonInitWithFrame:frame];
    }
    
    return self;
}

- (void)commonInitWithFrame:(CGRect)frame{
    self.backgroundColor = [UIColor whiteColor];
    
    self.collectionView = ({
        CardCollectionViewLayout *layout = [CardCollectionViewLayout new];
    
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        collectionView.translatesAutoresizingMaskIntoConstraints = NO;

        collectionView.backgroundColor = [UIColor whiteColor];
        collectionView.showsVerticalScrollIndicator = NO;
        collectionView.delegate = self;
        collectionView.dataSource = self;
        [collectionView registerClass:[CardCollectionViewCell class] forCellWithReuseIdentifier:CardCellIdentifier];
        
        [self addSubview:collectionView];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:collectionView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:collectionView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:collectionView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:0.98 constant:0]];

        collectionView;
    });
    
    self.cardBottomView = ({
        CardMainBottomView *bottomView = [CardMainBottomView new];
        [self addSubview:bottomView];
        [bottomView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[bottomView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(bottomView)]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_collectionView]-0-[bottomView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_collectionView,bottomView)]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:bottomView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0 constant:BOTTOM_TOOL_BAR_HEIGHT]];
        bottomView.delegate = self;
        
        bottomView;
    });
    
    [self setCardsWithArray:[NSArray arrayWithObjects:@"sss",@"sdd",@"dds",@"sss",@"sdd",@"dds",@"sss",@"sdd",@"dds", nil]];
}

#pragma mark - UICollectionViewDelegate

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.cardArr.count;
}

- (CardCollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    CardCollectionViewCell *cell = (CardCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:CardCellIdentifier forIndexPath:indexPath];
    
    cell.collectionView = collectionView;
    
    return cell;
}

#pragma mark - CardBottomClickedDelegate

- (void)cardBottomBtnClickedWithTag:(ButtonClicked)tag{
    switch (tag) {
        case ReturnButtonClicked:
            [self removeFromSuperview];
            break;
        case AddButtonClicked:
            break;
        default:
            break;
    }
}

@end
