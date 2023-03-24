//
//  RnpJsonTreeView.h
//  RnpLog
//
//  Created by user on 2023/3/23.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class RnpTreeModel;
@interface RnpJsonTreeView : UIView

@property (nonatomic, strong) RnpTreeModel * treeModel;

- (void)allFoldAct;

@end

NS_ASSUME_NONNULL_END
