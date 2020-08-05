//
//  CRJConfig.m
//  VoIPTest
//
//  Created by zhuyuhui on 2020/8/5.
//  Copyright © 2020 oopsr. All rights reserved.
//

#import "CRJConfig.h"

@implementation CRJConfig
+ (instancetype)shared {
    static CRJConfig *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[CRJConfig alloc] init];
    });
    return instance;
}


+ (NSTimeInterval)answerTimeInterval {
    return 30;
}
@end
