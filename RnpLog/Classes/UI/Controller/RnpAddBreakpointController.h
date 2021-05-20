//
//  RnpAddBreakpointController.h
//  RnpLog
//
//  Created by user on 2021/5/19.
//

#import <UIKit/UIKit.h>
static const NSString * _Nullable kUrl;
NS_ASSUME_NONNULL_BEGIN
@class RnpDataModel;
@class RnpBreakpointModel;
@interface RnpBreakpointInfoController : UIViewController

@property (nonatomic, strong) RnpDataModel * dataModel;

@property (nonatomic, strong) RnpBreakpointModel * breakpoint;

@end

NS_ASSUME_NONNULL_END
