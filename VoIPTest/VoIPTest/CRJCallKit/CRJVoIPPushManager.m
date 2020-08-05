//
//  CRJVoIPPushManager.m
//  VoIPTest
//
//  Created by 朱玉辉(EX-ZHUYUHUI001) on 2020/7/31.
//  Copyright © 2020 oopsr. All rights reserved.
//

#import "CRJVoIPPushManager.h"
#import <PushKit/PushKit.h>

#import "CRJCallKitEnum.h"
#import "CRJConfig.h"
#import "CRJProviderDelegate.h"

const NSUInteger kQBPageSize = 50;
static NSString *const kAps = @"aps";
static NSString *const kAlert = @"alert";
static NSString *const kVoipEvent = @"VOIPCall";
NSString *const DEFAULT_PASSOWORD = @"quickblox";
static const NSTimeInterval kAnswerInterval = 10.0f;

@interface CRJVoIPPushManager () <PKPushRegistryDelegate>

typedef void (^VoipMsgBlcok)(PKPushRegistry *, PKPushPayload *, NSString *);

//@property (nonatomic,copy)void (^voipMsgBlcok)(PKPushRegistry *registry, PKPushPayload *payload, NSString * _Nullable type);
@property (nonatomic, strong) NSMutableArray<VoipMsgBlcok> *voipMsgBlcokArray;
@end

@implementation CRJVoIPPushManager

+ (instancetype)shareInstance {
    static CRJVoIPPushManager *shareMessage = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        shareMessage = [[CRJVoIPPushManager alloc] init];
    });
    return shareMessage;
}

+ (void)registryVoIPWithVoIPMessageBlock:(void (^)(PKPushRegistry *registry, PKPushPayload *payload, NSString *type))VoIPMessageBlock {
    if (VoIPMessageBlock) {
        if (![CRJVoIPPushManager shareInstance].voipMsgBlcokArray) {
            [CRJVoIPPushManager shareInstance].voipMsgBlcokArray = [NSMutableArray array];
        }
        [[CRJVoIPPushManager shareInstance].voipMsgBlcokArray addObject:VoIPMessageBlock];
    }
    [CRJVoIPPushManager registryVoIPPush];
}

+ (void)registryVoIPPush {
    [[CRJVoIPPushManager shareInstance] initVoIPPush];
}

- (void)initVoIPPush {
    PKPushRegistry *voipRegistry = [[PKPushRegistry alloc] initWithQueue:dispatch_get_main_queue()];
    voipRegistry.delegate = self;
    voipRegistry.desiredPushTypes = [NSSet setWithObject:PKPushTypeVoIP];

    UIUserNotificationType types = (UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert);

    UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];

    [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
}

#pragma mark PKPushRegistryDelegate

- (void)pushRegistry:(PKPushRegistry *)registry didUpdatePushCredentials:(PKPushCredentials *)credentials forType:(NSString *)type {
    NSData *deviceTokenData = credentials.token;
    const unsigned *tokenBytes = [deviceTokenData bytes];
    NSString *pushDeviceTokenString = [NSString stringWithFormat:@"%08x%08x%08x%08x%08x%08x%08x%08x", ntohl(tokenBytes[0]), ntohl(tokenBytes[1]), ntohl(tokenBytes[2]), ntohl(tokenBytes[3]), ntohl(tokenBytes[4]), ntohl(tokenBytes[5]), ntohl(tokenBytes[6]), ntohl(tokenBytes[7])];
    //    /*
    //     yuhuiMr iphone7P:
    //     bec3bc20083580af2c4a164cd168a999a976360e3fd5e8cb6d00fc04d8827ea4
    //     */
    NSLog(@"voip deviceToken = %@", pushDeviceTokenString);
    //    [[NSUserDefaults standardUserDefaults] setObject:pushDeviceTokenString forKey:@"voipDeviceToken"];
    //    [NSUserDefaults.standardUserDefaults synchronize];

//    NSString *str = [NSString stringWithFormat:@"%@", credentials.token];
//    NSString *deviceToken = [[[str stringByReplacingOccurrencesOfString:@"<" withString:@""]
//        stringByReplacingOccurrencesOfString:@">"
//                                  withString:@""] stringByReplacingOccurrencesOfString:@" "
//                                                                            withString:@""];
//    NSLog(@"device_token is %@", deviceToken);
#warning 上传token处理
    //    [PASCLib.share pasc_setVoIPToken:credentials.token];
}

/*
 实现PKPushRegistryDelegate接收VoIP消息方法，APP未启动时收到VoIP消息，
 会先走普通的启动流程，执行完didFinishLaunchingWithOptions，再执行此方法
 */
- (void)pushRegistry:(PKPushRegistry *)registry didReceiveIncomingPushWithPayload:(PKPushPayload *)payload forType:(NSString *)type {
    /*
    NSDictionary *payload = @{
        @"message"  : [NSString stringWithFormat:@"%@ is calling you.", initiatorName],
        @"ios_voip" : @"1",
        kVoipEvent  : @"1",
        @"sessionID" : session.ID,
        @"opponentsIDs" : allUsersIDsString,
        @"contactIdentifier" : allUsersNamesString,
        @"conferenceType" : conferenceTypeString,
        @"timestamp" : timeStamp
    };
    */
    NSDictionary *dic = payload.dictionaryPayload;
    NSLog(@"dic  %@", dic);
    //in case of bad internet we check how long the VOIP Push was delivered for call(1-1)
    //if time delivery is more than “answerTimeInterval” - return
    if (type == PKPushTypeVoIP &&
        [payload.dictionaryPayload objectForKey:kVoipEvent] != nil &&
        payload.dictionaryPayload[@"timestamp"] != nil &&
        payload.dictionaryPayload[@"opponentsIDs"] != nil) {
        NSString *opponentsIDsString = (NSString *)payload.dictionaryPayload[@"opponentsIDs"];
        NSArray *opponentsIDsArray = [opponentsIDsString componentsSeparatedByString:@","];
        if (opponentsIDsArray.count == 2) {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
            NSString *timeStampString = payload.dictionaryPayload[@"timestamp"];
            NSDate *startCallDate = [formatter dateFromString:timeStampString];
            NSTimeInterval timeIntervalSinceStartCall = [[NSDate date] timeIntervalSinceDate:startCallDate];
            if (timeIntervalSinceStartCall > CRJConfig.answerTimeInterval) {
                CRJCallKitLog(@"timeIntervalSinceStartCall > QBRTCConfig.answerTimeInterval");
                return;
            }
        }
    }

    if (type == PKPushTypeVoIP &&
//        [payload.dictionaryPayload objectForKey:kVoipEvent] != nil &&
//        [UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
//        __weak __typeof(self) weakSelf = self;
//        
//        NSMutableArray<NSNumber *> *opponentsNumberIDs = [NSMutableArray array];
//        NSArray<NSString *> *opponentsIDs = nil;
//        NSString *opponentsNamesString = @"incoming call. Connecting...";
//        NSString *sessionID = nil;
//        NSUUID *callUUID = [NSUUID UUID];
//        NSUInteger sessionConferenceType = CRJCConferenceTypeAudio;
//        self.isUpdatedPayload = NO;
//        [QBRTCClient.instance addDelegate:self];
//        
        
        
        
        
        
    }

    if ([dic[@"cmd"] isEqualToString:@"call"]) {
        UILocalNotification *backgroudMsg = [[UILocalNotification alloc] init];
        backgroudMsg.alertBody = @"You receive a new call";
        backgroudMsg.soundName = @"ring.caf";
        backgroudMsg.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber] + 1;
        [[UIApplication sharedApplication] presentLocalNotificationNow:backgroudMsg];
    } else if ([dic[@"cmd"] isEqualToString:@"cancel"]) {
        [[UIApplication sharedApplication] cancelAllLocalNotifications];

        UILocalNotification *wei = [[UILocalNotification alloc] init];
        wei.alertBody = [NSString stringWithFormat:@"%ld 个未接来电", [[UIApplication sharedApplication] applicationIconBadgeNumber]];
        wei.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber];
        [[UIApplication sharedApplication] presentLocalNotificationNow:wei];
    }

    for (VoipMsgBlcok voipMsgBlcok in self.voipMsgBlcokArray) {
        voipMsgBlcok(registry, payload, type);
    }

    //
    //    if (![type isEqualToString:PKPushTypeVoIP]) {
    //        NSLog(@"Callkit& pushRegistry didReceiveIncomingPush But Not VoIP");
    //    }
    //    NSDictionary *alert = [payload.dictionaryPayload[@"aps"] objectForKey:@"alert"];

    //    log.info("Callkit& pushRegistry didReceiveIncomingPush")
    //    //别忘了在这里加上你们自己接电话的逻辑，比如连接聊天服务器啥的，不然这个电话打不通的
    //    if let uuidString = payload.dictionaryPayload["UUID"] as? String,
    //        let handle = payload.dictionaryPayload["handle"] as? String,
    //        let hasVideo = payload.dictionaryPayload["hasVideo"] as? Bool,
    //        let uuid = UUID(uuidString: uuidString)
    //    {
    //        if #available(iOS 10.0, *) {
    //            ProviderDelegate.shared.reportIncomingCall(uuid: uuid, handle: handle, hasVideo: hasVideo, completion: { (error) in
    //                if let e = error {
    //                    log.info("CallKit& displayIncomingCall Error \(e)")
    //                }
    //            })
    //        } else {
    //            // Fallback on earlier versions
    //        }
    //    }

    if (type == PKPushTypeVoIP) {
        NSDictionary *dictionaryPayload = payload.dictionaryPayload;

        NSString *uuidString = dictionaryPayload[@"UUID"];
        NSString *handle = dictionaryPayload[@"handle"];
        NSNumber *hasVideo = dictionaryPayload[@"hasVideo"];

        NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:uuidString];
        [[CRJProviderDelegate shared] reportIncomingCall:uuid
                                                  handle:handle
                                                hasVideo:hasVideo
                                              completion:^(NSError *_Nonnull error) {
                                                  if (error) {
                                                      CRJCallKitLog(@"CallKit & reportIncomingCall Error %@", error);
                                                  }
                                              }];
    }
}

@end
