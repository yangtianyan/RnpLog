//
//  RnpRequestSetupController.h
//  RnpLog
//
//  Created by user on 2021/5/20.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RnpRequestSetupController : UIViewController

@property (nonatomic, copy) NSString * text;

@property (nonatomic, copy) void(^onSaveBlock)(NSString * text);

@end

NS_ASSUME_NONNULL_END
