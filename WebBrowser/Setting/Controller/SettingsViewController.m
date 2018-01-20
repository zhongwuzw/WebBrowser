//
//  SettingsViewController.m
//  WebBrowser
//
//  Created by 钟武 on 2016/12/26.
//  Copyright © 2016年 钟武. All rights reserved.
//

#import "SettingsViewController.h"
#import "SettingAnimator.h"
#import "SettingsCollectionViewCell.h"
#import "BrowserHeader.h"

@interface SettingsMenuBackgroundView : UIView

@end

@implementation SettingsMenuBackgroundView

+ (Class)layerClass
{
    return [CAGradientLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        CAGradientLayer *layer = (CAGradientLayer *)self.layer;
        layer.colors = @[
                         (id)[[UIColor colorWithWhite:0 alpha:1] CGColor],
                         (id)[[UIColor colorWithWhite:0 alpha:0.7f] CGColor],
                         ];
    }
    return self;
}

@end


@interface SettingsMenuItem ()

@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) NSAttributedString *attributedText;
@property (nonatomic, copy) void (^action)(void);
@property (nonatomic, strong) UIImage *image;

@end

@implementation SettingsMenuItem

+ (instancetype)itemWithText:(NSString *)text image:(UIImage *)image action:(void (^)(void))action
{
    SettingsMenuItem *item = [self new];
    item.text = text;
    item.image = image;
    item.action = action;
    return item;
}

+ (instancetype)itemWithAttributedText:(NSAttributedString *)attributedText image:(UIImage *)image action:(void (^)(void))action {
    SettingsMenuItem *item = [self new];
    item.attributedText = attributedText;
    item.image = image;
    item.action = action;
    return item;
}

@end

static NSString * const CellId = @"SettingsMenuCell";

@interface SettingsViewController ()<UICollectionViewDelegateFlowLayout, UIViewControllerTransitioningDelegate, UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, copy) NSArray *items;

@property (nonatomic, strong) UIToolbar *blurView;
@property (nonatomic, strong) SettingsMenuBackgroundView *backgroundView;
@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) SettingAnimator *transitionController;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    self.view.tintColor = [UIColor whiteColor];
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:[UICollectionViewFlowLayout new]];
    self.collectionView.autoresizingMask = 0;
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.alwaysBounceVertical = YES;
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.clipsToBounds = YES;
    [self.collectionView registerClass:[SettingsCollectionViewCell class] forCellWithReuseIdentifier:CellId];
    [self.view addSubview:self.collectionView];
    
    self.collectionView.backgroundView = [UIView new];
    self.collectionView.backgroundView.backgroundColor = [UIColor clearColor];
    self.collectionView.backgroundView.userInteractionEnabled = YES;
    [self.collectionView.backgroundView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss:)]];
    [self adjustCollectionView];
    
    self.backgroundView.alpha = 0;
    self.collectionView.hidden = YES;
}

- (void)adjustCollectionView{
    CGFloat height = self.collectionView.height - (self.items.count * [self itemHeight] + BOTTOM_TOOL_BAR_HEIGHT);
    self.collectionView.contentInset = UIEdgeInsetsMake(height, 0, 0, 0);
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self.collectionView.collectionViewLayout invalidateLayout];
    
    self.backgroundView.frame = self.view.bounds;
}

+ (instancetype)presentFromViewController:(UIViewController *)viewController withItems:(NSArray *)items completion:(void (^)(void))completion{
    SettingsViewController *settingsVC = [SettingsViewController new];
    settingsVC.items = items;
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:settingsVC];
    nav.view.tintColor = settingsVC.view.tintColor;
    [nav setNavigationBarHidden:YES animated:NO];
    
    nav.transitioningDelegate = settingsVC;
    nav.modalPresentationStyle = UIModalPresentationCustom;
    
    [viewController presentViewController:nav animated:YES completion:^{
        if (completion)
        {
            completion();
        }
    }];
    return settingsVC;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)dismiss:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded) {
        UIViewController *vc = [self presentingViewController];
        if ([vc isKindOfClass:[UINavigationController class]])
        {
            vc = [vc performSelector:@selector(topViewController)];
        }
        
        [self dismissViewControllerAnimated:YES completion:^{
            [vc.view setNeedsLayout];
            if ([vc respondsToSelector:@selector(collectionView)])
            {
                UICollectionView *collectionView = [vc performSelector:@selector(collectionView)];
                [collectionView.collectionViewLayout invalidateLayout];
            }
        }];
    }
}

- (SettingsMenuBackgroundView *)backgroundView {
    if (!_backgroundView) {
        _backgroundView = [[SettingsMenuBackgroundView alloc] initWithFrame:self.view.bounds];
        _backgroundView.autoresizingMask = 0;
        [self.view insertSubview:_backgroundView atIndex:0];
    }
    return _backgroundView;
}

#pragma mark - layout

- (CGFloat)itemHeight
{
    return 44;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(collectionView.bounds.size.width, [self itemHeight]);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

#pragma mark - collection view

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.items.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SettingsCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellId forIndexPath:indexPath];
    
    cell.tintColor = self.view.tintColor;
    
    SettingsMenuItem *item = self.items[indexPath.item];
    if (item.text && item.text.length > 0) {
        cell.textLabel.text = item.text;
    }
    else if (item.attributedText && item.attributedText.length > 0) {
        cell.textLabel.attributedText = item.attributedText;
    }
    cell.imageView.image = item.image;
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat delayInSeconds = 0.15f;
    SettingsMenuItem *item = self.items[indexPath.item];
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self dismissViewControllerAnimated:YES completion:^{
            if (item.action)
            {
                CGFloat delayInSeconds = 0.15f;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    item.action();
                });
            }
        }];
    });
}

#pragma mark - transition

- (SettingAnimator *)transitionController
{
    if (!_transitionController)
    {
        _transitionController = [SettingAnimator new];
    }
    return _transitionController;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    self.transitionController.isDismissing = YES;
    return self.transitionController;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    self.transitionController.isDismissing = NO;
    return self.transitionController;
}

- (CGAffineTransform)offStageTransformForItemAtIndex:(NSInteger)idx negative:(BOOL)negative
{
    const CGFloat maxTranslation = 200;
    const CGFloat minTranslation = 100;
    CGFloat translation = maxTranslation - (maxTranslation - minTranslation) * ((CGFloat)idx / self.items.count);
    if (negative)
    {
        translation = -translation;
    }
    
    return CGAffineTransformMakeTranslation(-translation, 0);
}

- (void)enterTheStageWithCompletion:(void (^)(void))completion
{
    for (NSInteger idx = 0; idx < self.items.count; ++idx)
    {
        UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:idx inSection:0]];
        cell.transform = [self offStageTransformForItemAtIndex:idx negative:NO];
        cell.alpha = 0;
    }
    
    self.collectionView.hidden = NO;
    
    [UIView animateWithDuration:0.25f animations:^{
        self.backgroundView.alpha = 1.0f;
    } completion:^(BOOL finished) {
    }];
    
    for (NSInteger idx = 0; idx < self.items.count; ++idx)
    {
        CGFloat delay = 0.02f * idx;
        delay += 0.05f;
        [UIView animateWithDuration:0.8f delay:delay usingSpringWithDamping:0.6f initialSpringVelocity:1 options:0 animations:^{
            UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:idx inSection:0]];
            cell.transform = CGAffineTransformIdentity;
            cell.alpha = 1.0f;
        } completion:^(BOOL finished) {
            if (idx + 1 == self.items.count && completion)
            {
                completion();
            }
        }];
    }
}

- (void)leaveTheStageWithCompletion:(void (^)(void))completion
{
    for (NSInteger idx = 0; idx < self.items.count; ++idx)
    {
        [UIView animateWithDuration:0.3f delay:0.02f * idx options:UIViewAnimationOptionCurveEaseInOut animations:^{
            UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:self.items.count - idx - 1 inSection:0]];
            cell.transform = [self offStageTransformForItemAtIndex:idx negative:YES];
            cell.alpha = 0;
            if (idx + 1 == self.items.count)
            {
                self.backgroundView.alpha = 0;
            }
        } completion:^(BOOL finished) {
            if (idx + 1 == self.items.count && completion)
            {
                completion();
            }
        }];
    }
}

@end
