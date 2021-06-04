//
//  RnpHostManager.h
//  RnpLog
//
//  Created by user on 2021/5/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RnpHostManager : NSObject

@property (nonatomic, strong, class) RnpHostManager * instance;

@property (nonatomic, copy, readonly) NSDictionary<NSString *, NSString *> * replace_host_dict;

@property (nonatomic, copy, readonly) NSArray<NSString *> * white_list;

- (void)replaceHostDict:(NSDictionary *)dict;

- (void)setupWhiteList:(NSArray *)whiteList;

- (NSMutableURLRequest *)checkAndReplaceHost:(NSMutableURLRequest *)mutableRequest;

- (BOOL)checkWhiteList:(NSURLRequest *)request;
@end

NS_ASSUME_NONNULL_END
