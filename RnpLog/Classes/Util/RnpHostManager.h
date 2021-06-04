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

- (void)replaceHostDict:(NSDictionary *)dict;

- (NSMutableURLRequest *)checkAndReplaceHost:(NSMutableURLRequest *)mutableRequest;
@end

NS_ASSUME_NONNULL_END
