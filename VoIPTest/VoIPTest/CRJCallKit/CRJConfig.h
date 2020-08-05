//
//  CRJConfig.h
//  VoIPTest
//
//  Created by zhuyuhui on 2020/8/5.
//  Copyright © 2020 oopsr. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CRJConfig : NSObject
+ (instancetype)shared;

/**
 *  Answer time interval
 *
 *  @return current answer time interval;
 */
+ (NSTimeInterval)answerTimeInterval;

@end

NS_ASSUME_NONNULL_END
