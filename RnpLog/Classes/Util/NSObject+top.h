//
//  NSObject+top.h
//  RnpLog
//
//  Created by user on 2021/5/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (top)
- (UIViewController *)topViewControllerWithRootViewController:(UIViewController *)rootViewController;
- (UIViewController *)topViewControllerWithWindow:(UIWindow *)window;
@end

NS_ASSUME_NONNULL_END
