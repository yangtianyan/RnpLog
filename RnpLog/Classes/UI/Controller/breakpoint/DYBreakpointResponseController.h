//
//  DYBreakpointResponseController.h
//  RnpLog
//
//  Created by user on 2021/5/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class RnpDataModel;
@interface DYBreakpointResponseController : UIViewController

@property (nonatomic, strong) RnpDataModel * dataModel;

+ (void)showWithDataModel:(RnpDataModel *)dataModel completion:(void(^)(void))completion;
@end

NS_ASSUME_NONNULL_END
