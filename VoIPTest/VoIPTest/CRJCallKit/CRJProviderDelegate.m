//
//  CRJProviderDelegate.m
//  VoIPTest
//
//  Created by 朱玉辉(EX-ZHUYUHUI001) on 2020/7/31.
//  Copyright © 2020 oopsr. All rights reserved.
//

#import "CRJAudioManager.h"
#import "CRJCall.h"
#import "CRJCallKitEnum.h"
#import "CRJCallKitManager.h"
#import "CRJProviderDelegate.h"

static const NSInteger DefaultMaximumCallsPerCallGroup = 1;
static const NSInteger DefaultMaximumCallGroups = 1;

@interface CRJProviderDelegate ()
@property (nonatomic, strong) CRJCallKitManager *callManager;
@property (nonatomic, strong) CXProvider *provider;
@property (nonatomic, assign) BOOL isCallStarted;
@end

@implementation CRJProviderDelegate {
    NSMutableDictionary *_settings;
    NSOperatingSystemVersion _version;
}

+ (instancetype)shared {
    static CRJProviderDelegate *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[CRJProviderDelegate alloc] init];
    });
    return instance;
}

+ (CXProviderConfiguration *)configuration {
    NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
    CXProviderConfiguration *config = [[CXProviderConfiguration alloc] initWithLocalizedName:appName];
    config.supportsVideo = YES;
    config.maximumCallsPerCallGroup = DefaultMaximumCallsPerCallGroup;
    config.maximumCallGroups = DefaultMaximumCallGroups;
    config.supportedHandleTypes = [NSSet setWithObjects:@(CXHandleTypePhoneNumber), nil];
    config.iconTemplateImageData = UIImagePNGRepresentation([UIImage imageNamed:@"CallKitLogo"]);
    config.ringtoneSound = @"voip_call.wav";
    return config;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.callManager = [CRJCallKitManager shared];
        CXProviderConfiguration *configuration = [CRJProviderDelegate configuration];
        self.provider = [[CXProvider alloc] initWithConfiguration:configuration];
        [self.provider setDelegate:self queue:nil];
        self.isCallStarted = NO;
    }
    return self;
}

- (void)setup:(NSDictionary *)options {
    CRJCallKitLog(@"options = %@", options);
    _version = [[[NSProcessInfo alloc] init] operatingSystemVersion];
    _settings = [[NSMutableDictionary alloc] initWithDictionary:options];
}




- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
            options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options NS_AVAILABLE_IOS(9_0) {
    CRJCallKitLog(@"%@", url);
    /*
    NSString *handle = [url startCallHandle];
    if (handle != nil && handle.length > 0 ){
        NSDictionary *userInfo = @{
            @"handle": handle,
            @"video": @NO
        };
        [[NSNotificationCenter defaultCenter] postNotificationName:RNCallKitHandleStartCallNotification
                                                            object:self
                                                          userInfo:userInfo];
        return YES;
    }
    return NO;
    */
    return YES;
}

- (BOOL)application:(UIApplication *)application
    continueUserActivity:(NSUserActivity *)userActivity
      restorationHandler:(void (^)(NSArray *__nullable restorableObjects))restorationHandler {
    CRJCallKitLog(@"%@", userActivity);
    INInteraction *interaction = userActivity.interaction;
    INPerson *contact;
    NSString *handle;
    BOOL isAudioCall = [userActivity.activityType isEqualToString:INStartAudioCallIntentIdentifier];
    BOOL isVideoCall = [userActivity.activityType isEqualToString:INStartVideoCallIntentIdentifier];

    if (isAudioCall) {
        INStartAudioCallIntent *startAudioCallIntent = (INStartAudioCallIntent *)interaction.intent;
        contact = [startAudioCallIntent.contacts firstObject];
    } else if (isVideoCall) {
        INStartVideoCallIntent *startVideoCallIntent = (INStartVideoCallIntent *)interaction.intent;
        contact = [startVideoCallIntent.contacts firstObject];
    }

    if (contact != nil) {
        handle = contact.personHandle.value;
    }

    if (handle != nil && handle.length > 0) {
        NSDictionary *userInfo = @{
            @"handle" : handle,
            @"video" : @(isVideoCall)
        };
#warning 逻辑
        [[CRJCallKitManager shared] startCall:handle video:userInfo[@"video"]];
        return YES;
    }
    return NO;
}

- (BOOL)isCallDidStarted {
    return self.isCallStarted == YES;
}

- (CRJCall *)currentCall {
    CRJCallKitLog(@"currentCall self.calls %@",  @(self.callManager.calls.count));
    CRJCall *currentCall = (CRJCall *)self.callManager.calls.firstObject;
    if (currentCall) {
        return currentCall;
    }
    return nil;
}







//用来更新系统电话属性的。。
- (CXCallUpdate *)callUpdateWithHandle:(NSString *)handle
                              hasVideo:(BOOL)hasVideo {
    CXHandle *remoteHandle = [[CXHandle alloc] initWithType:CXHandleTypePhoneNumber value:handle];

    CXCallUpdate *update = [[CXCallUpdate alloc] init];
//    update.localizedCallerName = @"ParadiseDuo"; //对方的名字，可以设置为app注册的昵称
//    update.supportsHolding = NO;                 //通话过程中再来电，是否支持保留并接听
//    update.supportsDTMF = NO;                    //是否支持键盘拨号
    update.remoteHandle = remoteHandle;          //通话对方的Handle 信息
    update.hasVideo = hasVideo;                  //本次通话是否有视频
    return update;
}

- (void)configureAudioSession {
    [[CRJAudioManager shared] configureAudioSession];
}

- (void)startAudio {
    [[CRJAudioManager shared] startAudio];
}

- (void)stopAudio {
    [[CRJAudioManager shared] stopAudio];
}


//这个方法需要在所有接电话的地方手动调用，需要根据自己的业务逻辑来判断。还有就是不要忘了iOS的版本兼容哦。。
- (void)reportIncomingCall:(NSUUID *)uuid
                    handle:(NSString *)handle
                  hasVideo:(BOOL)hasVideo
                completion:(void (^)(NSError *error))completion {
    CRJCallKitLog(@"uuid = %@ \n handle = %@ \n hasVideo = %@", uuid, handle, @(hasVideo));
    //准备向系统报告一个 call update 事件，它包含了所有的来电相关的元数据。
    CXCallUpdate *update = [self callUpdateWithHandle:handle hasVideo:hasVideo];

    //调用 CXProvider
    //的reportIcomingCall(with:update:completion:)方法通知系统有来电。
    [self.provider reportNewIncomingCallWithUUID:uuid
                                          update:update
                                      completion:^(NSError *_Nullable error) {
                                          if (error == nil) {
                                              // completion
                                              // 回调会在系统处理来电时调用。如果没有任何错误，你就创建一个
                                              // Call 实例，将它添加到
                                              // CallManager 的通话列表。
                                              CRJCall *call = [[CRJCall alloc]
                                                  initWithUUID:uuid
                                                      outgoing:NO
                                                        handle:handle];
                                              [self.callManager add:call];
                                          } else {
                                              CRJCallKitLog(@"error = %@", error);
                                          }

                                          !completion ?: completion(error);
                                      }];
}




#pragma mark - CXProviderDelegate
/*
 当接收到呼叫重置时 调用的函数，这个函数必须被实现，其不需做任何逻辑，只用来重置状态.
 CXProvider 被 reset时，这个方法被调用，这样你的 App就可以清空所有去电，会到干净的状态。
 在这个方法中，你会停止所有的呼出音频会话，然后抛弃所有激活的通话。
 */
- (void)providerDidReset:(CXProvider *)provider {
    CRJCallKitLog(@"provider %@", provider);
    [self stopAudio];
    for (CRJCall *call in self.callManager.calls) {
        [call end];
    }
    [self.callManager removeAllCalls];
#warning //这里添加你们挂断电话或抛弃所有激活的通话的代码。。。
}

/*
 呼叫开始时回调
 */
- (void)providerDidBegin:(CXProvider *)provider {
    CRJCallKitLog(@"provider %@", provider);
}

/*
 音频会话激活状态的回调
 */
- (void)provider:(CXProvider *)provider didActivateAudioSession:(AVAudioSession *)audioSession {
    CRJCallKitLog(@"provider %@", provider);
    [self startAudio];
}

/*
 音频会话停用的回调
 */
- (void)provider:(CXProvider *)provider didDeactivateAudioSession:(AVAudioSession *)audioSession {
    CRJCallKitLog(@"provider %@", provider);
}

/*
 行为超时的回调
 */
- (void)provider:(CXProvider *)provider timedOutPerformingAction:(CXAction *)action {
    CRJCallKitLog(@"provider %@", provider);
}

//有事务被提交时调用
//如果返回YES 则表示事务被捕获处理 后面的回调都不会调用 如果返回NO 则表示事务不被捕获，会回调后面的函数
//- (BOOL)provider:(CXProvider *)provider executeTransaction:(CXTransaction *)transaction;

/*
 点击开始按钮的回调
 */
- (void)provider:(CXProvider *)provider performStartCallAction:(CXStartCallAction *)action {
    CRJCallKitLog(@"provider %@", provider);
    //向系统通讯录更新通话记录
    CXCallUpdate *update = [self callUpdateWithHandle:action.handle.value hasVideo:action.isVideo];
    [provider reportCallWithUUID:action.callUUID updated:update];

    __block CRJCall *call = [[CRJCall alloc] initWithUUID:action.callUUID outgoing:YES handle:action.handle.value];

    /*
     当我们用 UUID 创建出 Call 对象之后，我们就应该去配置 App
     的音频会话。和呼入通话一样，你的唯一任务就是配置。真正的处理在后面进行，也就是在
     provider(_:didActivate) 委托方法被调用时
     */
    [self configureAudioSession];

    __weak CRJCall *weakCall = call;
    __weak __typeof(self) weakSelf = self;

    /*
     delegate会监听通话的生命周期。它首先会会报告的就是呼出通话开始连接。当通话最终连上时，delegate也会被通知。
     */
    call.connectedStateChanged = ^{
        if (call.connectedState == CRJCallConnectedStatePending) {
            [weakSelf.provider reportOutgoingCallWithUUID:weakCall.uuid
                                  startedConnectingAtDate:[NSDate date]];
        } else if (call.connectedState == CRJCallConnectedStateComplete) {
            [weakSelf.provider reportOutgoingCallWithUUID:weakCall.uuid
                                          connectedAtDate:[NSDate date]];
        }
    };

    /*
     调用 call.start() 方法会导致 call 的生命周期变化。如果连接成功，则标记
     action 为 fullfill。
     */
    [call start:^(BOOL success) {
        if (success) {
#warning 这里填写你们App内打电话的逻辑。。
            [weakSelf.callManager add:call];
            //所有的Action只有调用了fulfill()之后才算执行完毕。
            [action fulfill];
        } else {
            [action fail];
        }
    }];
}

/*
 点击接听按钮的回调
 */
- (void)provider:(CXProvider *)provider performAnswerCallAction:(CXAnswerCallAction *)action {
    CRJCallKitLog(@"provider %@", provider);
    //从 callManager 中获得一个引用，UUID 指定为要接听的动画的 UUID。
    CRJCall *call = [self.callManager callWithUUID:action.callUUID];
    if (!call) {
        [action fail];
        return;
    }

    /*
     configure audio session
     */
    [self configureAudioSession];
    //通过调用 answer，表明这个通话现在激活
    [call answer];
#warning 在这里添加自己App接电话的逻辑

    //在处理一个 CXAction
    //时，重要的一点是，要么你拒绝它（fail），要么满足它（fullfill)。如果处理过程中没有发生错误，你可以调用
    //fullfill() 表示成功。
    [action fulfill];
}

/*
 点击结束按钮的回调
 */
- (void)provider:(CXProvider *)provider performEndCallAction:(CXEndCallAction *)action {
    CRJCallKitLog(@"provider %@", provider);
    //从 callManager 中获得一个引用，UUID 指定为要接听的动画的 UUID。
    CRJCall *call = [self.callManager callWithUUID:action.callUUID];
    if (!call) {
        [action fail];
        return;
    }

    //当 call 即将结束时，停止这次通话的音频处理。
    [self stopAudio];
    //调用 end() 方法修改本次通话的状态，以允许其他类和新的状态交互。
    [call end];
#warning 在这里添加自己App挂断电话的逻辑
    //将 action 标记为 fulfill。
    [action fulfill];
    //当你不再需要这个通话时，可以让 callManager 回收它。
    [self.callManager remove:call];
}

/*
 点击保持通话按钮的回调
 */
- (void)provider:(CXProvider *)provider performSetHeldCallAction:(CXSetHeldCallAction *)action {
    CRJCallKitLog(@"provider %@", provider);
    //从 callManager 中获得一个引用，UUID 指定为要接听的动画的 UUID。
    CRJCall *call = [self.callManager callWithUUID:action.callUUID];
    if (!call) {
        [action fail];
        return;
    }
    //获得 CXCall 对象之后，我们要根据 action 的 isOnHold 属性来设置它的 state。
    call.state = action.isOnHold ? CRJCallStateHeld : CRJCallStateActive;
    //根据状态的不同，分别进行启动或停止音频会话。
    if (call.state == CRJCallStateHeld) {
        [self stopAudio];
    } else {
        [self startAudio];
    }
    [action fulfill];
#warning 在这里添加你们自己的通话挂起逻辑
}

/*
 点击静音按钮的回调
 */
- (void)provider:(CXProvider *)provider performSetMutedCallAction:(CXSetMutedCallAction *)action {
    CRJCallKitLog(@"provider %@", provider);
    //从 callManager 中获得一个引用，UUID 指定为要接听的动画的 UUID。
    CRJCall *call = [self.callManager callWithUUID:action.callUUID];
    if (!call) {
        [action fail];
        return;
    }
    //获得 CXCall 对象之后，我们要根据 action 的 isOnHold 属性来设置它的 state。
    call.state = action.isMuted ? CRJCallStateMuted : CRJCallStateActive;
    [action fulfill];
#warning 在这里添加你们自己的麦克风静音逻辑
}

/*
 点击组按钮的回调
 */
- (void)provider:(CXProvider *)provider performSetGroupCallAction:(CXSetGroupCallAction *)action {
    CRJCallKitLog(@"provider %@", provider);
}

@end
