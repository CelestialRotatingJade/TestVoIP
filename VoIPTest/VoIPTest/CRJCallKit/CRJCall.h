//
//  CRJCall.h
//  VoIPTest
//
//  Created by 朱玉辉(EX-ZHUYUHUI001) on 2020/7/31.
//  Copyright © 2020 oopsr. All rights reserved.
//

#import "CRJCallKitEnum.h"
#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN

@interface CRJCall : NSObject
/* 来电的唯一标识符*/
@property (nonatomic, strong) NSUUID *uuid;
/* 是拨打的还是接听的*/
@property (nonatomic, assign) BOOL outgoing;
/*
 后面很多地方用得到，名字都是handle，可以理解为电话号码，其实就是自己App里被呼叫方的账号
 */
@property (nonatomic, copy) NSString *handle;

@property (nonatomic, assign) CRJCallState state;

@property (nonatomic, assign) CRJCallConnectedState connectedState;

@property (nonatomic, copy) void (^stateChanged)(void);
@property (nonatomic, copy) void (^connectedStateChanged)(void);

- (instancetype)initWithUUID:(NSUUID *)uuid
                    outgoing:(BOOL)outgoing
                      handle:(NSString *)handle;

- (void)start:(void (^)(BOOL success))completion;

- (void)answer;

- (void)end;

@end

NS_ASSUME_NONNULL_END
