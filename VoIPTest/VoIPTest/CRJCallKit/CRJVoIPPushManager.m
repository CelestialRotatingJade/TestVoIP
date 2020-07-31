//
//  CRJVoIPPushManager.m
//  VoIPTest
//
//  Created by 朱玉辉(EX-ZHUYUHUI001) on 2020/7/31.
//  Copyright © 2020 oopsr. All rights reserved.
//

#import "CRJVoIPPushManager.h"

#import <PushKit/PushKit.h>

@interface CRJVoIPPushManager () <PKPushRegistryDelegate>

typedef void (^VoipMsgBlcok)(PKPushRegistry *, PKPushPayload *, NSString *);

//@property (nonatomic,copy)void (^voipMsgBlcok)(PKPushRegistry *registry, PKPushPayload *payload, NSString * _Nullable type);
@property (nonatomic,strong) NSMutableArray<VoipMsgBlcok> *voipMsgBlcokArray;
@end


@implementation CRJVoIPPushManager

+ (instancetype)shareInstance
{
    static CRJVoIPPushManager *shareMessage = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        shareMessage = [[CRJVoIPPushManager alloc] init];
    });
    return shareMessage;
}

+ (void)registryVoIPWithVoIPMessageBlock:(void (^)(PKPushRegistry *registry, PKPushPayload *payload, NSString *type))VoIPMessageBlock{
    if (VoIPMessageBlock) {
        if (![CRJVoIPPushManager shareInstance].voipMsgBlcokArray) {
            [CRJVoIPPushManager shareInstance].voipMsgBlcokArray = [NSMutableArray array];
        }
        [[CRJVoIPPushManager shareInstance].voipMsgBlcokArray addObject:VoIPMessageBlock];
    }
    [CRJVoIPPushManager registryVoIPPush];
}

+ (void)registryVoIPPush{
    [[CRJVoIPPushManager shareInstance]initVoIPPush];
}

- (void)initVoIPPush{
    PKPushRegistry * voipRegistry = [[PKPushRegistry alloc]initWithQueue:dispatch_get_main_queue()];
    voipRegistry.delegate = self;
    voipRegistry.desiredPushTypes = [NSSet setWithObject:PKPushTypeVoIP];
}


#pragma mark PKPushRegistryDelegate

- (void)pushRegistry:(PKPushRegistry *)registry didUpdatePushCredentials:(PKPushCredentials *)credentials forType:(NSString *)type{
    
    NSData *deviceTokenData = credentials.token;
    const unsigned *tokenBytes = [deviceTokenData bytes];
    NSString *pushDeviceTokenString = [NSString stringWithFormat:@"%08x%08x%08x%08x%08x%08x%08x%08x", ntohl(tokenBytes[0]), ntohl(tokenBytes[1]), ntohl(tokenBytes[2]), ntohl(tokenBytes[3]), ntohl(tokenBytes[4]), ntohl(tokenBytes[5]), ntohl(tokenBytes[6]), ntohl(tokenBytes[7])];

    NSLog(@"voip deviceToken = %@",pushDeviceTokenString);
//    [[NSUserDefaults standardUserDefaults] setObject:pushDeviceTokenString forKey:@"voipDeviceToken"];
//    [NSUserDefaults.standardUserDefaults synchronize];
#warning 上传token处理
//    [PASCLib.share pasc_setVoIPToken:credentials.token];
}


- (void)pushRegistry:(PKPushRegistry *)registry didReceiveIncomingPushWithPayload:(PKPushPayload *)payload forType:(NSString *)type{
    
//    UIUserNotificationType theType = [UIApplication sharedApplication].currentUserNotificationSettings.types;
//
//    if (theType == UIUserNotificationTypeNone)
//    {
//        UIUserNotificationSettings *userNotifySetting = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert categories:nil];
//        [[UIApplication sharedApplication] registerUserNotificationSettings:userNotifySetting];
//    }
//
//    NSDictionary * dic = payload.dictionaryPayload;
//
//    NSLog(@"VoIP message = %@",dic);
//
//    UILocalNotification *backgroudMsg = [[UILocalNotification alloc] init];
//    backgroudMsg.alertBody= @"大佬,已收到VoIP消息，可以收工啦";
//    backgroudMsg.applicationIconBadgeNumber = [[UIApplication sharedApplication]applicationIconBadgeNumber] + 1;
//    [[UIApplication sharedApplication] presentLocalNotificationNow:backgroudMsg];
    
    for (VoipMsgBlcok voipMsgBlcok in self.voipMsgBlcokArray) {
        voipMsgBlcok(registry, payload, type);
    }
    
    
    if (![type isEqualToString:PKPushTypeVoIP]) {
        NSLog(@"Callkit& pushRegistry didReceiveIncomingPush But Not VoIP");
    }
    NSDictionary *alert = [payload.dictionaryPayload[@"aps"] objectForKey:@"alert"];

    
    log.info("Callkit& pushRegistry didReceiveIncomingPush")
    //别忘了在这里加上你们自己接电话的逻辑，比如连接聊天服务器啥的，不然这个电话打不通的
    if let uuidString = payload.dictionaryPayload["UUID"] as? String,
        let handle = payload.dictionaryPayload["handle"] as? String,
        let hasVideo = payload.dictionaryPayload["hasVideo"] as? Bool,
        let uuid = UUID(uuidString: uuidString)
    {
        if #available(iOS 10.0, *) {
            ProviderDelegate.shared.reportIncomingCall(uuid: uuid, handle: handle, hasVideo: hasVideo, completion: { (error) in
                if let e = error {
                    log.info("CallKit& displayIncomingCall Error \(e)")
                }
            })
        } else {
            // Fallback on earlier versions
        }
    }

    
    
}

@end

