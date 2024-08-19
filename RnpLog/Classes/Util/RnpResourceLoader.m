//
//  RnpResourceLoader.m
//  RnpLog
//
//  Created by yangtianyan on 2024/8/19.
//

#import "RnpResourceLoader.h"

@implementation RnpResourceLoader

+ (NSBundle *)currentBundle{
    return [NSBundle bundleForClass:[self class]];
}

@end
