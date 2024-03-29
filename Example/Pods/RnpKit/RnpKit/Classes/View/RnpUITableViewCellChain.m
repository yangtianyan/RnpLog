//
//  RnpUITableViewCellChain.m
//  RnpKit
//
//  Created by Zomfice on 2019/7/31.
//

#import "RnpUITableViewCellChain.h"
#import <objc/runtime.h>
#define RPCATEGORY_CHAIN_TABLEVIEWCELL_IMPLEMENTATION(RPMethod,RPParaType) RPCATEGORY_CHAIN_VIEWCLASS_IMPLEMENTATION(RPMethod,RPParaType, RnpUITableViewCellChain *,UITableViewCell)
#define RPCATEGORY_CHAIN_TABLEVIEWCELL_IMPLEMENTATION_VERSION(RPMethod,RPParaType,VERSION) RPCATEGORY_CHAIN_VIEWCLASS_IMPLEMENTATION_VERSION(RPMethod, RPParaType, RnpUITableViewCellChain *, UITableViewCell, VERSION)

@implementation RnpUITableViewCellChain

RPCATEGORY_CHAIN_TABLEVIEWCELL_IMPLEMENTATION(selectionStyle, UITableViewCellSelectionStyle)
RPCATEGORY_CHAIN_TABLEVIEWCELL_IMPLEMENTATION(accessoryType, UITableViewCellAccessoryType)
RPCATEGORY_CHAIN_TABLEVIEWCELL_IMPLEMENTATION(separatorInset, UIEdgeInsets)
RPCATEGORY_CHAIN_TABLEVIEWCELL_IMPLEMENTATION(editing, BOOL)
RPCATEGORY_CHAIN_TABLEVIEWCELL_IMPLEMENTATION(focusStyle, UITableViewCellFocusStyle)
RPCATEGORY_CHAIN_TABLEVIEWCELL_IMPLEMENTATION_VERSION(userInteractionEnabledWhileDragging, BOOL, 11.0)

- (RnpUITableViewCellChain * _Nonnull (^)(BOOL, BOOL))editingWithAnimated{
    return ^ (BOOL editing, BOOL animated){
        [(UITableViewCell *)self.view setEditing:editing animated:animated];
        return self;
    };
}

@end
RPCATEGORY_VIEW_IMPLEMENTATION(UITableViewCell, RnpUITableViewCellChain)
#undef RPCATEGORY_CHAIN_TABLEVIEWCELL_IMPLEMENTATION
