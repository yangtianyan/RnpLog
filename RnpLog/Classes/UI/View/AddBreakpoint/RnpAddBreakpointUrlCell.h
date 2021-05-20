//
//  RnpAddBreakpointUrlCell.h
//  RnpLog
//
//  Created by user on 2021/5/20.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RnpAddBreakpointUrlCell : UITableViewCell

@property (nonatomic, copy) void(^textChangeBlock)(NSString * text);

@property (nonatomic, copy) NSString * url;

@property (nonatomic, assign) BOOL editable;

@end

NS_ASSUME_NONNULL_END
