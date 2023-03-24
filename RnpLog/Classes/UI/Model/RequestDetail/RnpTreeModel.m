//
//  RnpTreeModel.m
//  RnpLog
//
//  Created by user on 2023/3/23.
//

#import "RnpTreeModel.h"
/* -- util -- */
#import "NSString+log.h"
#import "NSDictionary+log.h"
#import "NSArray+log.h"

@interface RnpTreeModel ()

@property (nonatomic, strong) RnpTreeValueModel * rootTree;

@property (nonatomic, copy) NSArray * allShowTrees;

@property (nonatomic, assign) NSInteger allCount;

@property (nonatomic, strong) NSMutableArray * showTrees;

@end
@implementation RnpTreeModel

- (instancetype)initWithJson:(id)json{
    if(self = [super init]){
        
        NSDictionary * object = @{
            @"level": @0,
            @"key" : @"JSON",
            @"value": json ?: @{},
            @"isLast" : @(true)
        };
        self.showTrees = [NSMutableArray new];
        self.rootTree = [[RnpTreeValueModel alloc] initWithObject:object];
        [self updateAllTrees];
    }
    return self;
}

- (void)getAllShowTrees:(RnpTreeValueModel *)treeModel{
    [self.showTrees addObject:treeModel];
    if(treeModel.isFold){
        return;
    }
    [treeModel.subTrees enumerateObjectsUsingBlock:^(RnpTreeValueModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        [self.showTrees addObject:obj];
        [self getAllShowTrees:obj];
    }];
}

- (void)updateAllTrees{
    self.showTrees = [NSMutableArray new];
    self.allCount = 0;
    [self getAllShowTrees:self.rootTree];
    self.allShowTrees = self.showTrees;
    self.allCount = self.allShowTrees.count;
}

@end

@interface RnpTreeValueModel()

@property (nonatomic, assign) NSInteger level;

@property (nonatomic, copy) NSString * key;

@property (nonatomic, copy) id value;

@property (nonatomic, assign) NSInteger arrayIndex;

@property (nonatomic, assign) BOOL isLast;

@property (nonatomic, copy)   NSString * cpText;

/* -- 本地生成数据 -- */


@property (nonatomic, assign) CGFloat width;

@property (nonatomic, assign) NSInteger count;

@property (nonatomic, assign) RnpTreeType type;

@property (nonatomic, copy) NSArray<RnpTreeValueModel *> * subTrees;

@property (nonatomic, strong) UIColor * keyColor;

@property (nonatomic, strong) UIColor * keyBGColor;

@property (nonatomic, strong) UIColor * valueColor;

@property (nonatomic, strong) UIColor * valueBGColor;

@end
@implementation RnpTreeValueModel

- (instancetype)initWithObject:(NSDictionary *)object
{
    if(self = [super init])
    {
        if ([object isKindOfClass:NSDictionary.class]) {
            self.level  = [object[@"level"] integerValue];
            self.key    = object[@"key"] ? [NSString stringWithFormat:@"%@",object[@"key"]] : nil;
            self.value  = object[@"value"];
            self.isLast = [object[@"isLast"] boolValue];
            self.arrayIndex = object[@"arrayIndex"] ? [object[@"arrayIndex"] integerValue] : -1;
            self.keyBGColor = self.valueBGColor = UIColor.clearColor;
            
            id copyValue = self.value;
            
            if([self.value isKindOfClass:NSDictionary.class]){
                self.type = RnpTreeDictType;
                self.keyColor = [UIColor blackColor];
                self.valueColor = UIColor.clearColor;
                [self initSubTreesFromDict];
            }else if ([self.value isKindOfClass:NSArray.class]){
                self.type = RnpTreeArrayType;
                self.keyColor = [UIColor colorWithRed:68 / 255.f green:170 / 255.f blue:0 alpha:1];
                self.valueColor = UIColor.whiteColor;
                self.valueBGColor = [UIColor colorWithRed:211 / 255.f green:211 / 255.f blue:211 / 255.f alpha:1];
                [self initSubTreesFromArr];
                self.value = [NSString stringWithFormat:@" %ld ", self.subTrees.count];
            }else{
                self.keyColor = [UIColor colorWithRed:68 / 255.f green:170 / 255.f blue:0 alpha:1];
                copyValue = [NSString stringWithFormat:@"%@",self.value];
                if([self.value isKindOfClass:NSString.class]){
                    self.type = RnpTreeStringType;
                    self.value = [NSString stringWithFormat:@"\"%@\"",self.value];
                    self.valueColor = [UIColor colorWithRed:255 / 255.f green:102 / 255.f blue:50 / 255.f alpha:1];
                }else if ([self.value isKindOfClass:NSNumber.class]){
                    [NSNumber numberWithBool:true];
                    self.value = [NSString stringWithFormat:@"%@",self.value];
                    self.type = RnpTreeNumberType;
                    self.valueColor = [UIColor colorWithRed:204 / 255.f green:2 / 255.f blue:255 / 255.f alpha:1];
                }else{
                    self.type = RnpTreeOtherType;
                    self.value = [NSString stringWithFormat:@"\"%@\"",self.value];
                    self.valueColor = [UIColor colorWithRed:0 / 255.f green:153 / 255.f blue:204 / 255.f alpha:1];
                }
                [self calculativeWidth];
            }
            
            NSString * copyText = @"";
            
            if(self.arrayIndex >= 0){
                self.keyColor = [UIColor colorWithRed:211 / 255.f green:211 / 255.f blue:211 / 255.f alpha:1];
                copyText = [copyValue isKindOfClass:NSString.class] ? copyValue : [copyValue toJson];
            }else{
                copyText = @{self.key : copyValue}.toJson;
            }
            self.cpText = copyText;
            
            self.count = 1 + self.subTrees.count;
        }
    }
    return self;
}

- (void)calculativeWidth{
    CGFloat remainSpace = [UIScreen mainScreen].bounds.size.width - self.level * kHorizontalPadding;
    
}


- (void)initSubTreesFromDict{
    NSInteger subTreeLevel = self.level + 1;
    NSMutableArray * subTrees = [NSMutableArray new];
    __block NSInteger index = 0;
    [(NSDictionary *)self.value enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSDictionary * object = @{
            @"level": @(subTreeLevel),
            @"key" : key,
            @"value": obj,
            @"isLast": @([(NSDictionary *)self.value count] - 1 == index)
        };
        [subTrees addObject:[[RnpTreeValueModel alloc] initWithObject:object]];
        index += 1;
    }];
    self.subTrees = subTrees;
}

- (void)initSubTreesFromArr{
    NSInteger subTreeLevel = self.level + 1;
    NSMutableArray * subTrees = [NSMutableArray new];
    [(NSArray *)self.value enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSDictionary * object = @{
            @"level": @(subTreeLevel),
            @"key" : [NSString stringWithFormat:@" %ld ",idx],
            @"value": obj,
            @"arrayIndex": @(idx),
            @"isLast": @([(NSArray *)self.value count] - 1 == idx)
        };
        [subTrees addObject:[[RnpTreeValueModel alloc] initWithObject:object]];
    }];
    self.subTrees = subTrees;
}
@end
