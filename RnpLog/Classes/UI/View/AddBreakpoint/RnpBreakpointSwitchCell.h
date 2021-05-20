//
//  RnpAddBreakpointSwitchCell.h
//  RnpLog
//
//  Created by user on 2021/5/20.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RnpBreakpointSwitchCell : UITableViewCell

@property (nonatomic, strong, readonly) UILabel * label;

@property (nonatomic, assign) BOOL isOn;

@property (nonatomic, copy) void(^onChange)(BOOL on);

@property (nonatomic, copy) NSString * title;

@end

NS_ASSUME_NONNULL_END
