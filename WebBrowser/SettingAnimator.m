//
//  SettingAnimator.m
//  WebBrowser
//
//  Created by 钟武 on 2016/12/26.
//  Copyright © 2016年 钟武. All rights reserved.
//

#import "SettingAnimator.h"
#import "SettingsViewController.h"

@interface SettingsViewController (SettingAnimator)
- (void)enterTheStageWithCompletion:(void (^)(void))completion;
- (void)leaveTheStageWithCompletion:(void (^)(void))completion;
@end

@implementation SettingAnimator

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 0;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *container = [transitionContext containerView];
    
    if (self.isDismissing)
    {
        UINavigationController *nav = (UINavigationController *)fromViewController;
        SettingsViewController *menu = (SettingsViewController *)nav.topViewController;
        
        [menu leaveTheStageWithCompletion:^{
            [nav.view removeFromSuperview];
            [transitionContext completeTransition:YES];
        }];
    }
    else
    {
        UINavigationController *nav = (UINavigationController *)toViewController;
        SettingsViewController *menu = (SettingsViewController *)nav.topViewController;
        
        nav.view.frame = container.bounds;
        [container addSubview:nav.view];
        
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [menu enterTheStageWithCompletion:^{
                [transitionContext completeTransition:YES];
            }];
        }];
        
        
    }
}

@end
