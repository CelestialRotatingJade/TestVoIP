//
//  CRJCallKitManager.h
//  VoIPTest
//
//  Created by 朱玉辉(EX-ZHUYUHUI001) on 2020/7/31.
//  Copyright © 2020 oopsr. All rights reserved.
//

#import <CallKit/CallKit.h>
#import <Foundation/Foundation.h>
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

- (void)startCall:(NSString *)handle video:(BOOL)video;

//通话暂时挂起
- (void)setHeld:(CRJCall *)call onHold:(BOOL)onHold;

//麦克风静音
- (void)setMute:(CRJCall *)call muted:(BOOL)muted;
@end

NS_ASSUME_NONNULL_END
