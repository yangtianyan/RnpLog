//
//  RnpRequestCell.h
//  NetworkLog
//
//  Created by user on 2021/5/14.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class RnpDataModel;
@interface RnpRequestCell : UITableViewCell

@property (nonatomic, strong) RnpDataModel * model;

@end

NS_ASSUME_NONNULL_END
