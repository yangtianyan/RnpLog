//
//  RnpBreakpointModel.m
//  RnpLog
//
//  Created by user on 2021/5/19.
//

#import "RnpBreakpointModel.h"

@implementation RnpBreakpointModel

- (instancetype)init
{
    if (self = [super init]) {
        self.isActivate = true;
        self.isAfter = true;
    }
    return self;
}

@end
