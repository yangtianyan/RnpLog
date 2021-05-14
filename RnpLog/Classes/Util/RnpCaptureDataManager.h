//
//  RnpCaptureDataManager.h
//  NetworkLog
//
//  Created by user on 2021/5/13.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RnpCaptureDataManager : NSObject

@property (nonatomic, strong, class) RnpCaptureDataManager * instance;

///网络请求列表 最多存放100条
@property (nonatomic, copy, readonly) NSArray * requests;


/// 网络请求字典
@property (nonatomic, copy, readonly) NSDictionary * requests_dict;


- (void)addRequest:(NSURLSessionDataTask *)task;

@end

NS_ASSUME_NONNULL_END
