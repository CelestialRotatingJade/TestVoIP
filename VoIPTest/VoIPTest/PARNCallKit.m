//
//  PARNCallKit.m
//  VoIPTest
//
//  Created by 朱玉辉(EX-ZHUYUHUI001) on 2020/7/31.
//  Copyright © 2020 oopsr. All rights reserved.
//

#import "PARNCallKit.h"
#import <AVFoundation/AVFoundation.h>

static int const DelayInSeconds = 3;

static NSString *const RNCallKitHandleStartCallNotification = @"RNCallKitHandleStartCallNotification";
static NSString *const RNCallKitDidReceiveStartCallAction = @"RNCallKitDidReceiveStartCallAction";
static NSString *const RNCallKitPerformAnswerCallAction = @"RNCallKitPerformAnswerCallAction";
static NSString *const RNCallKitPerformEndCallAction = @"RNCallKitPerformEndCallAction";
static NSString *const RNCallKitDidActivateAudioSession = @"RNCallKitDidActivateAudioSession";
static NSString *const RNCallKitDidDisplayIncomingCall = @"RNCallKitDidDisplayIncomingCall";
static NSString *const RNCallKitDidPerformSetMutedCallAction = @"RNCallKitDidPerformSetMutedCallAction";

@implementation PARNCallKit {
    NSMutableDictionary *_settings;
    NSOperatingSystemVersion _version;
    BOOL _isStartCallActionEventListenerAdded;
}

+ (instancetype)shareManager {
    static PARNCallKit *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[PARNCallKit alloc] init];
    });
    return instance;
}

- (instancetype)init {
#ifdef DEBUG
    NSLog(@"[RNCallKit][init]");
#endif
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleStartCallNotification:)
                                                     name:RNCallKitHandleStartCallNotification
                                                   object:nil];
        _isStartCallActionEventListenerAdded = NO;
    }
    return self;
}

- (void)dealloc {
#ifdef DEBUG
    NSLog(@"[RNCallKit][dealloc]");
#endif
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

// Override method of RCTEventEmitter
- (NSArray<NSString *> *)supportedEvents {
    return @[
        RNCallKitDidReceiveStartCallAction,
        RNCallKitPerformAnswerCallAction,
        RNCallKitPerformEndCallAction,
        RNCallKitDidActivateAudioSession,
        RNCallKitDidDisplayIncomingCall,
        RNCallKitDidPerformSetMutedCallAction
    ];
}

/// 初始化CXProvider与CXCallController
/// @param options 参数
- (void)setup:(NSDictionary *)options {
#ifdef DEBUG
    NSLog(@"[RNCallKit][setup] options = %@", options);
#endif
    // 返回操作系统的版本号
    _version = [[[NSProcessInfo alloc] init] operatingSystemVersion];
    self.callKitCallController = [[CXCallController alloc] init];
    _settings = [[NSMutableDictionary alloc] initWithDictionary:options];
    self.callKitProvider = [[CXProvider alloc] initWithConfiguration:[self getProviderConfiguration]];
    // queue一般直接指定为nil，即在main线程执行callback。
    [self.callKitProvider setDelegate:self queue:nil];
}
//
//RCT_REMAP_METHOD(checkIfBusy,
//                 checkIfBusyWithResolver:(RCTPromiseResolveBlock)resolve
//                 rejecter:(RCTPromiseRejectBlock)reject)
//{
//#ifdef DEBUG
//    NSLog(@"[RNCallKit][checkIfBusy]");
//#endif
//    resolve(@(self.callKitCallController.callObserver.calls.count > 0));
//}
//
//RCT_REMAP_METHOD(checkSpeaker,
//                 checkSpeakerResolver:(RCTPromiseResolveBlock)resolve
//                 rejecter:(RCTPromiseRejectBlock)reject)
//{
//#ifdef DEBUG
//    NSLog(@"[RNCallKit][checkSpeaker]");
//#endif
//    NSString *output = [AVAudioSession sharedInstance].currentRoute.outputs.count > 0 ? [AVAudioSession sharedInstance].currentRoute.outputs[0].portType : nil;
//    resolve(@([output isEqualToString:@"Speaker"]));
//}

#pragma mark - CXCallController call actions

// Display the incoming call to the user
- (void)displayIncomingCall:(NSString *)uuidString
                     handle:(NSString *)handle
                 handleType:(NSString *)handleType
                   hasVideo:(BOOL)hasVideo
        localizedCallerName:(NSString *_Nullable)localizedCallerName {
#ifdef DEBUG
    NSLog(@"[RNCallKit][displayIncomingCall] uuidString = %@", uuidString);
#endif
    int _handleType = [self getHandleType:handleType];
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:uuidString];
    CXCallUpdate *callUpdate = [[CXCallUpdate alloc] init];
    //通话对方的Handle 信息
    callUpdate.remoteHandle = [[CXHandle alloc] initWithType:_handleType value:handle];
    //是否支持键盘拨号
    callUpdate.supportsDTMF = YES;
    // TODO: Holding
    //通话过程中再来电，是否支持保留并接听
    callUpdate.supportsHolding = NO;
    callUpdate.supportsGrouping = NO;
    callUpdate.supportsUngrouping = NO;
    //本次通话是否有视频
    callUpdate.hasVideo = hasVideo;
    //对方的名字，可以设置为app注册的昵称
    callUpdate.localizedCallerName = localizedCallerName;
    /*
     收到VoIP电话，报告系统，好让系统按照它的配置弹出一个系统来电界面。如果执行成功，completion中的error为nil, 否则，不会弹出系统界面。
     UUID是每次随机生成的，标记一次通话；
     */
    [self.callKitProvider reportNewIncomingCallWithUUID:uuid
                                                 update:callUpdate
                                             completion:^(NSError *_Nullable error) {
                                                 [self sendEventWithName:RNCallKitDidDisplayIncomingCall body:@{@"error" : error ? error.localizedDescription : @""}];
                                                 if (error == nil) {
                                                     // Workaround per https://forums.developer.apple.com/message/169511
                                                     if ([self lessThanIos10_2]) {
                                                         [self configureAudioSession];
                                                     }
                                                 }
                                             }];
}

- (void)startCall:(NSString *)uuidString
               handle:(NSString *)handle
           handleType:(NSString *)handleType
                video:(BOOL)video
    contactIdentifier:(NSString *_Nullable)contactIdentifier {
#ifdef DEBUG
    NSLog(@"[RNCallKit][startCall] uuidString = %@", uuidString);
#endif
    int _handleType = [self getHandleType:handleType];
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:uuidString];
    CXHandle *callHandle = [[CXHandle alloc] initWithType:_handleType value:handle];
    CXStartCallAction *startCallAction = [[CXStartCallAction alloc] initWithCallUUID:uuid handle:callHandle];
    [startCallAction setVideo:video];
    [startCallAction setContactIdentifier:contactIdentifier];

    CXTransaction *transaction = [[CXTransaction alloc] initWithAction:startCallAction];

    [self requestTransaction:transaction];
}

- (void)endCall:(NSString *)uuidString {
#ifdef DEBUG
    NSLog(@"[RNCallKit][endCall] uuidString = %@", uuidString);
#endif
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:uuidString];
    CXEndCallAction *endCallAction = [[CXEndCallAction alloc] initWithCallUUID:uuid];
    CXTransaction *transaction = [[CXTransaction alloc] initWithAction:endCallAction];

    [self requestTransaction:transaction];
}

- (void)endAllCalls {
#ifdef DEBUG
    NSLog(@"[RNCallKit][endAllCalls] calls = %@", self.callKitCallController.callObserver.calls);
#endif
    for (CXCall *call in self.callKitCallController.callObserver.calls) {
        CXEndCallAction *endCallAction = [[CXEndCallAction alloc] initWithCallUUID:call.UUID];
        CXTransaction *transaction = [[CXTransaction alloc] initWithAction:endCallAction];
        [self requestTransaction:transaction];
    }
}

- (void)setHeldCall:(NSString *)uuidString onHold:(BOOL)onHold {
#ifdef DEBUG
    NSLog(@"[RNCallKit][setHeldCall] uuidString = %@", uuidString);
#endif
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:uuidString];
    CXSetHeldCallAction *setHeldCallAction = [[CXSetHeldCallAction alloc] initWithCallUUID:uuid onHold:onHold];
    CXTransaction *transaction = [[CXTransaction alloc] init];
    [transaction addAction:setHeldCallAction];

    [self requestTransaction:transaction];
}

- (void)_startCallActionEventListenerAdded {
    _isStartCallActionEventListenerAdded = YES;
}

/// 通话连接上
/// @param uuidString uuidString
- (void)reportConnectedOutgoingCallWithUUID:(NSString *)uuidString {
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:uuidString];
    [self.callKitProvider reportOutgoingCallWithUUID:uuid connectedAtDate:[NSDate date]];
}

- (void)setMutedCall:(NSString *)uuidString muted:(BOOL)muted {
#ifdef DEBUG
    NSLog(@"[RNCallKit][setMutedCall] muted = %i", muted);
#endif
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:uuidString];
    CXSetMutedCallAction *setMutedAction = [[CXSetMutedCallAction alloc] initWithCallUUID:uuid muted:muted];
    CXTransaction *transaction = [[CXTransaction alloc] init];
    [transaction addAction:setMutedAction];

    [self requestTransaction:transaction];
}

/// 在开始或结束一次通话时，需要提交action事务请求,这些事务会交给上面的provider执行。
/// @param transaction 事务
- (void)requestTransaction:(CXTransaction *)transaction {
#ifdef DEBUG
    NSLog(@"[RNCallKit][requestTransaction] transaction = %@", transaction);
#endif
    if (self.callKitCallController == nil) {
        self.callKitCallController = [[CXCallController alloc] init];
    }
    [self.callKitCallController requestTransaction:transaction
                                        completion:^(NSError *_Nullable error) {
                                            if (error != nil) {
                                                NSLog(@"[RNCallKit][requestTransaction] Error requesting transaction (%@): (%@)", transaction.actions, error);
                                            } else {
                                                NSLog(@"[RNCallKit][requestTransaction] Requested transaction successfully");

                                                // CXStartCallAction
                                                if ([[transaction.actions firstObject] isKindOfClass:[CXStartCallAction class]]) {
                                                    CXStartCallAction *startCallAction = [transaction.actions firstObject];
                                                    CXCallUpdate *callUpdate = [[CXCallUpdate alloc] init];
                                                    callUpdate.remoteHandle = startCallAction.handle;
                                                    callUpdate.supportsDTMF = YES;
                                                    callUpdate.supportsHolding = NO;
                                                    callUpdate.supportsGrouping = NO;
                                                    callUpdate.supportsUngrouping = NO;
                                                    callUpdate.hasVideo = NO;
                                                    /*
                                                     我们还可以动态更改provider的配置信息CXCallUpdate,
                                                     比如作为拨打方，开始没有地方配置通话的界面，就可以在通话开始时更新这些配置信息。 其方法是：
                                                     */
                                                    [self.callKitProvider reportCallWithUUID:startCallAction.callUUID updated:callUpdate];
                                                }
                                            }
                                        }];
}

- (BOOL)lessThanIos10_2 {
    if (_version.majorVersion < 10) {
        return YES;
    } else if (_version.majorVersion > 10) {
        return NO;
    } else {
        return _version.minorVersion < 2;
    }
}

- (BOOL)containsLowerCaseLetter:(NSString *)callUUID {
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:@"[a-z]" options:0 error:nil];
    return [regex numberOfMatchesInString:callUUID options:0 range:NSMakeRange(0, [callUUID length])] > 0;
}

- (int)getHandleType:(NSString *)handleType {
    int _handleType;
    if ([handleType isEqualToString:@"generic"]) {
        _handleType = CXHandleTypeGeneric;
    } else if ([handleType isEqualToString:@"number"]) {
        _handleType = CXHandleTypePhoneNumber;
    } else if ([handleType isEqualToString:@"email"]) {
        _handleType = CXHandleTypeEmailAddress;
    } else {
        _handleType = CXHandleTypeGeneric;
    }
    return _handleType;
}

/// 设置CXProviderConfiguration
- (CXProviderConfiguration *)getProviderConfiguration {
#ifdef DEBUG
    NSLog(@"[RNCallKit][getProviderConfiguration]");
#endif
    CXProviderConfiguration *providerConfiguration = [[CXProviderConfiguration alloc] initWithLocalizedName:_settings[@"appName"]];
    providerConfiguration.supportsVideo = YES;
    providerConfiguration.maximumCallGroups = 1;
    providerConfiguration.maximumCallsPerCallGroup = 1;
    providerConfiguration.supportedHandleTypes = [NSSet setWithObjects:[NSNumber numberWithInteger:CXHandleTypePhoneNumber], [NSNumber numberWithInteger:CXHandleTypeEmailAddress], [NSNumber numberWithInteger:CXHandleTypeGeneric], nil];
    if (_settings[@"imageName"]) {
        providerConfiguration.iconTemplateImageData = UIImagePNGRepresentation([UIImage imageNamed:_settings[@"imageName"]]);
    }
    if (_settings[@"ringtoneSound"]) {
        providerConfiguration.ringtoneSound = _settings[@"ringtoneSound"];
    }
    return providerConfiguration;
}

- (void)configureAudioSession {
#ifdef DEBUG
    NSLog(@"[RNCallKit][configureAudioSession] Activating audio session");
#endif

    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];

    [audioSession setMode:AVAudioSessionModeVoiceChat error:nil];

    double sampleRate = 44100.0;
    [audioSession setPreferredSampleRate:sampleRate error:nil];

    NSTimeInterval bufferDuration = .005;
    [audioSession setPreferredIOBufferDuration:bufferDuration error:nil];
    [audioSession setActive:TRUE error:nil];
}

+ (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
            options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options NS_AVAILABLE_IOS(9_0) {
#ifdef DEBUG
    NSLog(@"[RNCallKit][application:openURL]");
#endif
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

+ (BOOL)application:(UIApplication *)application
    continueUserActivity:(NSUserActivity *)userActivity
      restorationHandler:(void (^)(NSArray *__nullable restorableObjects))restorationHandler {
#ifdef DEBUG
    NSLog(@"[RNCallKit][application:continueUserActivity]");
#endif
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

        [[NSNotificationCenter defaultCenter] postNotificationName:RNCallKitHandleStartCallNotification
                                                            object:self
                                                          userInfo:userInfo];
        return YES;
    }
    return NO;
}

- (void)handleStartCallNotification:(NSNotification *)notification {
#ifdef DEBUG
    NSLog(@"[RNCallKit][handleStartCallNotification] userInfo = %@", notification.userInfo);
#endif
    int delayInSeconds;
    if (!_isStartCallActionEventListenerAdded) {
        // Workaround for when app is just launched and JS side hasn't registered to the event properly
        delayInSeconds = DelayInSeconds;
    } else {
        delayInSeconds = 0;
    }
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^{
        [self sendEventWithName:RNCallKitDidReceiveStartCallAction body:notification.userInfo];
    });
}

/*
<!>实现通话流程或按钮的回调方法（每个回调结束的时候要执行[action fulfill];否则会提示通话失败）
*/
#pragma mark - CXProviderDelegate ============================================
/*
 当拨打方成功发起一个通话后，会触发.
 */
- (void)provider:(CXProvider *)provider performStartCallAction:(CXStartCallAction *)action {
#ifdef DEBUG
    NSLog(@"[RNCallKit][CXProviderDelegate][provider:performStartCallAction]");
#endif
    //报告通话的状态[通话连接时]
    [self.callKitProvider reportOutgoingCallWithUUID:action.callUUID
                             startedConnectingAtDate:[NSDate date]];
    [self configureAudioSession];
    [action fulfill];
}

/*
 当接听方成功接听一个电话时，会触发.
 */
- (void)provider:(CXProvider *)provider performAnswerCallAction:(CXAnswerCallAction *)action {
#ifdef DEBUG
    NSLog(@"[RNCallKit][CXProviderDelegate][provider:performAnswerCallAction]");
#endif
    if (![self lessThanIos10_2]) {
        [self configureAudioSession];
    }
    NSString *callUUID = [self containsLowerCaseLetter:action.callUUID.UUIDString] ? action.callUUID.UUIDString : [action.callUUID.UUIDString lowercaseString];
    [self sendEventWithName:RNCallKitPerformAnswerCallAction body:@{@"callUUID" : callUUID}];
    [action fulfill];
}

/*
 当接听方拒接电话或者双方结束通话时，会触发.
 */
- (void)provider:(CXProvider *)provider performEndCallAction:(CXEndCallAction *)action {
#ifdef DEBUG
    NSLog(@"[RNCallKit][CXProviderDelegate][provider:performEndCallAction]");
#endif
    NSString *callUUID = [self containsLowerCaseLetter:action.callUUID.UUIDString] ? action.callUUID.UUIDString : [action.callUUID.UUIDString lowercaseString];
    [self sendEventWithName:RNCallKitPerformEndCallAction body:@{@"callUUID" : callUUID}];
    [action fulfill];
}

/*
 当点击系统通话界面的Mute按钮时，会触发.
 */
- (void)provider:(CXProvider *)provider performSetMutedCallAction:(CXSetMutedCallAction *)action {
#ifdef DEBUG
    NSLog(@"[RNCallKit][CXProviderDelegate][provider:performSetMutedCallAction]");
#endif
    [self sendEventWithName:RNCallKitDidPerformSetMutedCallAction
                       body:@{@"muted" : @(action.muted)}];
    [action fulfill];
}

- (void)provider:(CXProvider *)provider performSetHeldCallAction:(CXSetHeldCallAction *)action {
#ifdef DEBUG
    NSLog(@"[RNCallKit][CXProviderDelegate][provider:performSetHeldCallAction]");
#endif
}

- (void)provider:(CXProvider *)provider timedOutPerformingAction:(CXAction *)action {
#ifdef DEBUG
    NSLog(@"[RNCallKit][CXProviderDelegate][provider:timedOutPerformingAction]");
#endif
}

- (void)provider:(CXProvider *)provider didActivateAudioSession:(AVAudioSession *)audioSession {
#ifdef DEBUG
    NSLog(@"[RNCallKit][CXProviderDelegate][provider:didActivateAudioSession]");
#endif
    [self sendEventWithName:RNCallKitDidActivateAudioSession
                       body:nil];
}

- (void)provider:(CXProvider *)provider didDeactivateAudioSession:(AVAudioSession *)audioSession {
#ifdef DEBUG
    NSLog(@"[RNCallKit][CXProviderDelegate][provider:didDeactivateAudioSession]");
#endif
}

- (void)providerDidReset:(CXProvider *)provider {
#ifdef DEBUG
    NSLog(@"[RNCallKit][providerDidReset]");
#endif
}

- (void)sendEventWithName:(NSString *)eventName body:(id)body {
}
@end
