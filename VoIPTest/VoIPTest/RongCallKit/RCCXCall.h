//
//  RCCXCall.h
//  VoIPTest
//
//  Created by zhuyuhui on 2020/8/4.
//  Copyright © 2020 oopsr. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/*!
 融云适配苹果 CallKit 核心类
 */
@interface RCCXCall : NSObject

/**
 获取 RCCXCall 单例

 @return RCCXCall 单例
 */
+ (instancetype)sharedInstance;

/*!
 通知苹果 Callkit 开始呼出电话
 
 @param userId 呼叫用户 id，如果是多人通话则传多个用户 id，以:::分隔
 */
- (void)startCall:(NSString *)userId;

/*!
 通知苹果 Callkit 呼出电话已连接
 
 */
- (void)reportOutgoingCallConnected;

/**
 通知苹果 Callkit 来电

 @param inviterId 来电人用户 id
 @param userIdList 被邀请者的 userId 列表。nil 表示单人通话
 @param isVideo 是否视频通话。YES: video NO: audio
 */
- (void)reportIncomingCallWithInviter:(NSString *)inviterId
                           userIdList:(NSArray <NSString *> *)userIdList
                              isVideo:(BOOL)isVideo;

/*!
 挂断苹果 Callkit 通话
 
 */
- (void)endCXCall;

/**
 当系统来电接通时，如果没有激活苹果 Callkit 通话，则挂断 VOIP
 
 @param UUID 系统来电 UUID
 */
- (void)hangupIfNeedWithUUID:(NSString *)UUID;

/**
 当苹果 Callkit 通话接通后，重新设置AVAudioSessionMode
 */
- (void)setAVAudioSessionMode;

@end


NS_ASSUME_NONNULL_END
