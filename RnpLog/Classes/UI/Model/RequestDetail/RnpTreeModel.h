//
//  RnpTreeModel.h
//  RnpLog
//
//  Created by user on 2023/3/23.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSUInteger, RnpTreeType) {
    RnpTreeDictType,
    RnpTreeArrayType,
    RnpTreeNumberType,
    RnpTreeStringType,
    RnpTreeOtherType
};
static const CGFloat kHorizontalPadding = 20;
#define kKeyFont   [UIFont boldSystemFontOfSize:15]
#define kValueFont [UIFont systemFontOfSize:14]
#define kKeyColor  [UIColor blackColor]
#define kValueColor  [UIColor blackColor]

NS_ASSUME_NONNULL_BEGIN
@class RnpTreeValueModel;
@interface RnpTreeModel : NSObject

@property (nonatomic, strong, readonly) RnpTreeValueModel * rootTree;

@property (nonatomic, assign, readonly) NSInteger allCount;

@property (nonatomic, copy, readonly) NSArray * allShowTrees;

- (instancetype)initWithJson:(id)json;

- (void)updateAllTrees;

@end

@interface RnpTreeValueModel : NSObject

@property (nonatomic, assign) BOOL isFold;

@property (nonatomic, assign, readonly) NSInteger level;

@property (nonatomic, copy, readonly) NSString * key;

@property (nonatomic, copy, readonly) id value;

@property (nonatomic, assign, readonly) NSInteger arrayIndex;

@property (nonatomic, assign, readonly) BOOL isLast;

/* -- 本地生成数据 -- */
@property (nonatomic, assign, readonly) RnpTreeType type;

@property (nonatomic, copy, readonly) NSArray<RnpTreeValueModel *> * subTrees;

@property (nonatomic, strong, readonly) UIColor * keyColor;

@property (nonatomic, strong, readonly) UIColor * keyBGColor;

@property (nonatomic, strong, readonly) UIColor * valueColor;

@property (nonatomic, strong, readonly) UIColor * valueBGColor;

@property (nonatomic, assign, readonly) CGFloat width;

@property (nonatomic, assign, readonly) NSInteger count;

- (instancetype)initWithObject:(NSDictionary *)object;

@end

NS_ASSUME_NONNULL_END
