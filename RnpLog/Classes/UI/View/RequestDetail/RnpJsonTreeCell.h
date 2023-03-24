//
//  RnpJsonTreeCell.h
//  RnpLog
//
//  Created by user on 2023/3/23.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class RnpTreeValueModel;
@interface RnpJsonTreeCell : UITableViewCell

@property (nonatomic, strong) RnpTreeValueModel * valueModel;


@end

NS_ASSUME_NONNULL_END
