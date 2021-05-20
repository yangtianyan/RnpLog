//
//  NSObject+top.m
//  RnpLog
//
//  Created by user on 2021/5/20.
//

#import "NSObject+top.h"

@implementation NSObject (top)

- (UIViewController *)topViewControllerWithRootViewController:
   (UIViewController *)rootViewController
{
    if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabBarController = (UITabBarController *)rootViewController;
        return [self topViewControllerWithRootViewController:tabBarController.selectedViewController];
        
    } else if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController* navigationController = (UINavigationController*)rootViewController;
        return [self topViewControllerWithRootViewController:navigationController.visibleViewController];
    } else if (rootViewController.presentedViewController) {
        UIViewController* presentedViewController = rootViewController.presentedViewController;
        return [self topViewControllerWithRootViewController:presentedViewController];
    } else {
        return rootViewController;
    }
}
- (UIViewController *)topViewControllerWithWindow:(UIWindow *)window{
    return [self topViewControllerWithRootViewController:window.rootViewController];
}
@end
