//
//  CRJProviderDelegate.m
//  VoIPTest
//
//  Created by 朱玉辉(EX-ZHUYUHUI001) on 2020/7/31.
//  Copyright © 2020 oopsr. All rights reserved.
//

#import "CRJAudioManager.h"
#import "CRJCall.h"
#import "CRJCallKitManager.h"
#import "CRJProviderDelegate.h"
@interface CRJProviderDelegate ()
//ProviderDelegate 需要和 CXProvider 和 CXCallController 打交道，因此保持两个对二者的引用。
@property (nonatomic, strong) CRJCallKitManager *callManager;
@property (nonatomic, strong) CXProvider *provider;
@end

@implementation CRJProviderDelegate {
    NSMutableDictionary *_settings;
}
+ (instancetype)shared {
    static CRJProviderDelegate *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[CRJProviderDelegate alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _settings = [NSMutableDictionary dictionary];

        self.callManager = [CRJCallKitManager shared];
        //用一个 CXProviderConfiguration 初始化 CXProvider，前者在后面会定义成一个静态属性。CXProviderConfiguration 用于定义通话的行为和能力。
        self.provider = [[CXProvider alloc] initWithConfiguration:[self getProviderConfiguration]];
        //为了能够响应来自于 CXProvider 的事件，你需要设置它的委托。
        [self.provider setDelegate:self queue:nil];
    }
    return self;
}

//通过设置CXProviderConfiguration来支持视频通话、电话号码处理，并将通话群组的数字限制为 1 个，其实光看属性名大家也能看得懂吧。
- (CXProviderConfiguration *)getProviderConfiguration {
#ifdef DEBUG
    NSLog(@"[RNCallKit][getProviderConfiguration]");
#endif
    CXProviderConfiguration *providerConfiguration = [[CXProviderConfiguration alloc] initWithLocalizedName:_settings[@"appName"]];
    providerConfiguration.supportsVideo = YES;
    providerConfiguration.maximumCallGroups = 1;
    providerConfiguration.maximumCallsPerCallGroup = 1;
    providerConfiguration.supportedHandleTypes = [NSSet setWithObjects:[NSNumber numberWithInteger:CXHandleTypePhoneNumber], nil];
    if (_settings[@"imageName"]) {
        providerConfiguration.iconTemplateImageData = UIImagePNGRepresentation([UIImage imageNamed:_settings[@"imageName"]]);
    }
    if (_settings[@"ringtoneSound"]) {
        providerConfiguration.ringtoneSound = _settings[@"ringtoneSound"];
    }
    return providerConfiguration;
}

//这个方法牛逼了，它是用来更新系统电话属性的。。
- (CXCallUpdate *)callUpdateWithHandle:(NSString *)handle hasVideo:(BOOL)hasVideo {
    CXCallUpdate *update = [[CXCallUpdate alloc] init];
    //这里是系统通话记录里显示的联系人名称哦。需要显示什么按照你们的业务逻辑来。
    update.localizedCallerName = @"ParadiseDuo";
    update.supportsGrouping = false;
    update.supportsHolding = false;
    //填了联系人的名字，怎么能不填他的handle('电话号码')呢，具体填什么，根据你们的业务逻辑来
    update.remoteHandle = [[CXHandle alloc] initWithType:CXHandleTypePhoneNumber value:handle];
    update.hasVideo = hasVideo;
    return update;
}

- (void)configureAudioSession {
    [[CRJAudioManager shared] configureAudioSession];
}

- (void)stopAudio {
    [[CRJAudioManager shared] stopAudio];
}

//这个方法需要在所有接电话的地方手动调用，需要根据自己的业务逻辑来判断。还有就是不要忘了iOS的版本兼容哦。。
- (void)reportIncomingCall:(NSUUID *)uuid
                    handle:(NSString *)handle
                  hasVideo:(BOOL)hasVideo
                completion:(void (^)(NSError *error))completion {
    
    //准备向系统报告一个 call update 事件，它包含了所有的来电相关的元数据。
    CXCallUpdate *update = [self callUpdateWithHandle:handle hasVideo:hasVideo];
    
    //调用 CXProvider 的reportIcomingCall(with:update:completion:)方法通知系统有来电。
    [self.provider reportNewIncomingCallWithUUID:uuid update:update completion:^(NSError * _Nullable error) {
        if (error == nil) {
            //completion 回调会在系统处理来电时调用。如果没有任何错误，你就创建一个 Call 实例，将它添加到 CallManager 的通话列表。
            CRJCall *call = [[CRJCall alloc] initWithUUID:uuid outgoing:NO handle:handle];
            [self.callManager add:call];
        }
        
        //调用 completion，如果它不为空的话。
        if (completion) {
            completion(error);
        }
    }];
}

#pragma mark - CXProviderDelegate
//CXProviderDelegate 唯一一个必须实现的代理方法！！当 CXProvider 被 reset 时，这个方法被调用，这样你的 App 就可以清空所有去电，会到干净的状态。在这个方法中，你会停止所有的呼出音频会话，然后抛弃所有激活的通话。
- (void)providerDidReset:(CXProvider *)provider {
    [self stopAudio];
    for (CRJCall *call in self.callManager.calls) {
        [call end];
    }
    [self.callManager removeAllCalls];
#warning //这里添加你们挂断电话或抛弃所有激活的通话的代码。。。
}

- (void)provider:(CXProvider *)provider performStartCallAction:(CXStartCallAction *)action {
#ifdef DEBUG
    NSLog(@"[RNCallKit][CXProviderDelegate][provider:performStartCallAction]");
#endif
    //向系统通讯录更新通话记录
    CXCallUpdate *update = [self callUpdateWithHandle:action.handle.value hasVideo:action.isVideo];
    [provider reportCallWithUUID:action.callUUID updated:update];

    __block CRJCall *call = [[CRJCall alloc] initWithUUID:action.callUUID outgoing:YES handle:action.handle.value];
    //当我们用 UUID 创建出 Call 对象之后，我们就应该去配置 App 的音频会话。和呼入通话一样，你的唯一任务就是配置。真正的处理在后面进行，也就是在 provider(_:didActivate) 委托方法被调用时
    [self configureAudioSession];

    __weak CRJCall *weakCall = call;
    __weak __typeof(self) weakSelf = self;
    //delegate 会监听通话的生命周期。它首先会会报告的就是呼出通话开始连接。当通话最终连上时，delegate 也会被通知。
    call.connectedStateChanged = ^{
        if (call.connectedState == CRJCallConnectedStatePending) {
            [weakSelf.provider reportOutgoingCallWithUUID:weakCall.uuid startedConnectingAtDate:[NSDate date]];
        } else if (call.connectedState == CRJCallConnectedStateComplete) {
            [weakSelf.provider reportOutgoingCallWithUUID:weakCall.uuid connectedAtDate:[NSDate date]];
        }
    };
    //调用 call.start() 方法会导致 call 的生命周期变化。如果连接成功，则标记 action 为 fullfill。
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

//系统接电话的代理
- (void)provider:(CXProvider *)provider performAnswerCallAction:(CXAnswerCallAction *)action {
    //从 callManager 中获得一个引用，UUID 指定为要接听的动画的 UUID。
    CRJCall *call = [self.callManager callWithUUID:action.callUUID];
    if (!call) {
        [action fail];
        return;
    }
    
    
    //设置通话要用的 audio session 是 App 的责任。系统会以一个较高的优先级来激活这个 session。
    [self configureAudioSession];
    //通过调用 answer，表明这个通话现在激活
    [call answer];
#warning 在这里添加自己App接电话的逻辑
       
    //在处理一个 CXAction 时，重要的一点是，要么你拒绝它（fail），要么满足它（fullfill)。如果处理过程中没有发生错误，你可以调用 fullfill() 表示成功。
    [action fulfill];

}


//当系统激活 CXProvider 的 audio session时，委托会被调用。这给你一个机会开始处理通话的音频。
- (void)provider:(CXProvider *)provider didActivateAudioSession:(AVAudioSession *)audioSession {
#ifdef DEBUG
    NSLog(@"[RNCallKit][CXProviderDelegate][provider:didActivateAudioSession]");
#endif
    [self stopAudio]; //一定要记得播放铃声呐。。
}

@end
