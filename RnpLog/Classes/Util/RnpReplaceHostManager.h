//
//  RnpReplaceHostManager.h
//  RnpLog
//
//  Created by user on 2021/5/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RnpReplaceHostManager : NSObject

@property (nonatomic, strong, class) RnpReplaceHostManager * instance;

@property (nonatomic, copy, readonly) NSDictionary<NSString *, NSString *> * host_dict;

- (void)replaceHostDict:(NSDictionary *)dict;

- (NSMutableURLRequest *)checkAndReplaceHost:(NSMutableURLRequest *)mutableRequest;
@end

NS_ASSUME_NONNULL_END
