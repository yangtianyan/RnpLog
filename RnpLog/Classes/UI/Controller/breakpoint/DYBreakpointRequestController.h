//
//  DYBreakpointRequestController.h
//  RnpLog
//
//  Created by user on 2021/5/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DYBreakpointRequestController : UIViewController

@property (nonatomic, strong) NSMutableURLRequest * request;

+ (void)showWithRequest:(NSMutableURLRequest *)request completion:(void(^)(void))completion;

@end

NS_ASSUME_NONNULL_END
