//
//  RCStatusDefine.h
//  VoIPTest
//
//  Created by zhuyuhui on 2020/8/4.
//  Copyright © 2020 oopsr. All rights reserved.
//

#ifndef RCStatusDefine_h
#define RCStatusDefine_h

#pragma mark RCConversationType - 会话类型
/*!
 会话类型
 */
typedef NS_ENUM(NSUInteger, RCConversationType) {
    /*!
     单聊
     */
    ConversationType_PRIVATE = 1,

    /*!
     讨论组
     */
    ConversationType_DISCUSSION = 2,

    /*!
     群组
     */
    ConversationType_GROUP = 3,

    /*!
     聊天室
     */
    ConversationType_CHATROOM = 4,

    /*!
     客服
     */
    ConversationType_CUSTOMERSERVICE = 5,

    /*!
     系统会话
     */
    ConversationType_SYSTEM = 6,

    /*!
     应用内公众服务会话

     @discussion
     客服 2.0 使用应用内公众服务会话（ConversationType_APPSERVICE）的方式实现。
     即客服 2.0  会话是其中一个应用内公众服务会话， 这种方式我们目前不推荐，
     请尽快升级到新客服，升级方法请参考官网的客服文档。文档链接
     https://docs.rongcloud.cn/services/public/app/prepare/
     */
    ConversationType_APPSERVICE = 7,

    /*!
     跨应用公众服务会话
     */
    ConversationType_PUBLICSERVICE = 8,

    /*!
     推送服务会话
     */
    ConversationType_PUSHSERVICE = 9,

    /*!
     加密会话（仅对部分私有云用户开放，公有云用户不适用）
     */
    ConversationType_Encrypted = 11,
    /**
     * RTC 会话
     */
    ConversationType_RTC = 12,

    /*!
     无效类型
     */
    ConversationType_INVALID

};



/*!
 媒体类型
 */
typedef NS_ENUM(NSInteger, RCCallMediaType) {
    /*!
     音频
     */
    RCCallMediaAudio = 1,
    /*!
     视频
     */
    RCCallMediaVideo = 2,
};

/**
 视频显示模式
 */
typedef NS_ENUM(NSInteger, RCCallRenderModel) {
    
    /*!
     默认: 如果视频尺寸与显示视窗尺寸不一致，则视频流会按照显示视窗的比例进行周边裁剪或图像拉伸后填满视窗。
     */
    RCCallRenderModelHidden = 1,
    
    /*!
     RenderFit: 如果视频尺寸与显示视窗尺寸不一致，在保持长宽比的前提下，将视频进行缩放后填满视窗。
     */
    RCCallRenderModelFit = 2,
    
    /*!
     RenderAdaptive: 如果自己和对方都是竖屏，或者如果自己和对方都是横屏，使用
     RCCallRenderModelHidden；如果对方和自己一个竖屏一个横屏，则使用RCCallRenderModelFit。
     */
    RCCallRenderModelAdaptive = 3,
};
#pragma mark - Call
/*!
 通话结束原因
 */
typedef NS_ENUM(NSInteger, RCCallDisconnectReason) {
    /*!
     己方取消已发出的通话请求
     */
    RCCallDisconnectReasonCancel = 1,
    /*!
     己方拒绝收到的通话请求
     */
    RCCallDisconnectReasonReject = 2,
    /*!
     己方挂断
     */
    RCCallDisconnectReasonHangup = 3,
    /*!
     己方忙碌
     */
    RCCallDisconnectReasonBusyLine = 4,
    /*!
     己方未接听
     */
    RCCallDisconnectReasonNoResponse = 5,
    /*!
     己方不支持当前引擎
     */
    RCCallDisconnectReasonEngineUnsupported = 6,
    /*!
     己方网络出错
     */
    RCCallDisconnectReasonNetworkError = 7,
    /*!
     对方取消已发出的通话请求
     */
    RCCallDisconnectReasonRemoteCancel = 11,
    /*!
     对方拒绝收到的通话请求
     */
    RCCallDisconnectReasonRemoteReject = 12,
    /*!
     通话过程对方挂断
     */
    RCCallDisconnectReasonRemoteHangup = 13,
    /*!
     对方忙碌
     */
    RCCallDisconnectReasonRemoteBusyLine = 14,
    /*!
     对方未接听
     */
    RCCallDisconnectReasonRemoteNoResponse = 15,
    /*!
     对方网络错误
     */
    RCCallDisconnectReasonRemoteEngineUnsupported = 16,
    /*!
     对方网络错误
     */
    RCCallDisconnectReasonRemoteNetworkError = 17,
    /*!
     己方其他端已接听
     */
    RCCallDisconnectReasonAcceptByOtherClient = 18,
    /*!
     己方被加入黑名单
     */
    RCCallDisconnectReasonAddToBlackList = 19,
    /*!
     己方被降级为观察者
     */
    RCCallDisconnectReasonDegrade = 20,
    /*!
     已被禁止通话
     */
    RCCallDisconnectReasonKickedByServer = 21
};

/*!
 通话状态
 */
typedef NS_ENUM(NSInteger, RCCallStatus) {
    /*!
     初始状态
     */
    //RCCallIdle = 0,
    /*!
     正在呼出
     */
    RCCallDialing = 1,
    /*!
     正在呼入
     */
    RCCallIncoming = 2,
    /*!
     收到一个通话呼入后，正在振铃
     */
    RCCallRinging = 3,
    /*!
     正在通话
     */
    RCCallActive = 4,
    /*!
     已经挂断
     */
    RCCallHangup = 5,
};

/*!
 用户类型
 */
typedef NS_ENUM(NSInteger, RCCallUserType) {
    /*!
     正常用户
     */
    RCCallUserNormal = 1,
    /*!
     观察者
     */
    RCCallUserObserver = 2
};

#endif /* RCStatusDefine_h */
