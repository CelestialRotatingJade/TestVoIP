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

typedef void(^CompletionActionBlock)(Boolean isAccept);




@interface CRJCallKitManager : NSObject

+ (instancetype)shared;

@property (nonatomic, copy) void (^callsChangedHandler)(void);

- (CRJCall *)callWithUUID:(NSUUID *)uuid;

- (void)add:(CRJCall *)call;

- (void)remove:(CRJCall *)call;

- (void)removeAllCalls;

//打电话
- (void)startCall:(NSString *)handle video:(BOOL)video;

//通话暂时挂起
- (void)setHeld:(CRJCall *)call onHold:(BOOL)onHold;

//麦克风静音
- (void)setMute:(CRJCall *)call muted:(BOOL)muted;

//挂断电话
- (void)end:(CRJCall *)call;

@end

NS_ASSUME_NONNULL_END
