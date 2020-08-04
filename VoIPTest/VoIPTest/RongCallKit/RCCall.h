//
//  RCCall.h
//  VoIPTest
//
//  Created by zhuyuhui on 2020/8/4.
//  Copyright © 2020 oopsr. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "RCCallSession.h"
#import "RCStatusDefine.h"
#import "RCMultiCallInviteNewUserDelegate.h"
NS_ASSUME_NONNULL_BEGIN

@interface RCCall : NSObject

/*!
 当前的通话会话实体
 */
@property(nonatomic, strong, readonly) RCCallSession *currentCallSession;

/*!
 音频通话支持的最大通话人数
 */
@property(nonatomic, assign) int maxMultiAudioCallUserNumber;

/*!
 视频通话支持的最大通话人数
 */
@property(nonatomic, assign) int maxMultiVideoCallUserNumber;

/**
 系统来电显示的 app 名字
 */
@property(nonatomic, copy) NSString *appLocalizedName;

/**
 是否处理来电, 默认: YES 处理, 设置为 NO 时会直接挂断来电
*/
@property(nonatomic, assign) BOOL canIncomingCall;

/**
 多人音视频通话邀请用户代理
 
 @discussion 如果实现该代理则多人音视频通话界面将有用户自己定义否则使用 RongCallKit 自带的选人界面
 
 */
@property(nonatomic, weak) id<RCMultiCallInviteNewUserDelegate> callInviteNewUserDelegate;


/*!
 获取融云通话界面组件CallKit的核心类单例

 @return 融云通话界面组件CallKit的核心类单例

 @discussion 您可以通过此方法，获取CallKit的单例，访问对象中的属性和方法.
 */
+ (instancetype)sharedRCCall;

/*!
 当前会话类型是否支持音频通话

 @param conversationType 会话类型

 @return 是否支持音频通话
 */
- (BOOL)isAudioCallEnabled:(RCConversationType)conversationType;

/*!
 当前会话类型是否支持视频通话

 @param conversationType 会话类型

 @return 是否支持视频通话
 */
- (BOOL)isVideoCallEnabled:(RCConversationType)conversationType;

/*!
 发起单人通话

 @param targetId  对方的用户ID
 @param mediaType 使用的媒体类型
 */
- (void)startSingleCall:(NSString *)targetId mediaType:(RCCallMediaType)mediaType;

/*!
 选择成员并发起多人通话

 @param conversationType 会话类型
 @param targetId         会话目标ID
 @param mediaType        使用的媒体类型

 @discussion
 此方法会先弹出选择成员界面，选择完成后再会发起通话。目前支持的会话类型有讨论组和群组。

 @warning
 如果您需要在群组中调用此接口发起多人会话，需要设置并实现groupMemberDataSource。
 */
- (void)startMultiCall:(RCConversationType)conversationType
              targetId:(NSString *)targetId
             mediaType:(RCCallMediaType)mediaType;

/*!
 直接发起多人通话

 @param conversationType 会话类型
 @param targetId         会话目标ID
 @param mediaType        使用的媒体类型
 @param userIdList       邀请的用户ID列表

 @discussion 此方法会直接发起通话。目前支持的会话类型有讨论组和群组。

 @warning 您需要设置并实现groupMemberDataSource才能加人。
 */
- (void)startMultiCallViewController:(RCConversationType)conversationType
                            targetId:(NSString *)targetId
                           mediaType:(RCCallMediaType)mediaType
                          userIdList:(NSArray *)userIdList;

#pragma mark - Utility
/*!
 弹出通话ViewController或选择成员ViewController

 @param viewController 通话ViewController或选择成员ViewController
 */
- (void)presentCallViewController:(UIViewController *)viewController;

/*!
 取消通话ViewController或选择成员ViewController

 @param viewController 通话ViewController或选择成员ViewController
 */
- (void)dismissCallViewController:(UIViewController *)viewController;

/*!
 停止来电铃声和震动
 */
- (void)stopReceiveCallVibrate;

@end

NS_ASSUME_NONNULL_END
