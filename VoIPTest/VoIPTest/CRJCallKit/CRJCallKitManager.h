//
//  CRJCallKitManager.h
//  VoIPTest
//
//  Created by 朱玉辉(EX-ZHUYUHUI001) on 2020/7/31.
//  Copyright © 2020 oopsr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CallKit/CallKit.h>
NS_ASSUME_NONNULL_BEGIN
@class CRJCall;
@interface CRJCallKitManager : NSObject

@property (nonatomic, strong) NSMutableArray *calls;


+ (instancetype)shared;

@property (nonatomic, copy) void (^callsChangedHandler)(void);

- (CRJCall *)callWithUUID:(NSUUID *)uuid;

- (void)add:(CRJCall *)call;

- (void)remove:(CRJCall *)call;

- (void)removeAllCalls;

@end

NS_ASSUME_NONNULL_END
