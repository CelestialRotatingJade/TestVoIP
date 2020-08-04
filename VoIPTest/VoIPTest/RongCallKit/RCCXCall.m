//
//  RCCXCall.m
//  VoIPTest
//
//  Created by zhuyuhui on 2020/8/4.
//  Copyright © 2020 oopsr. All rights reserved.
//

#import "RCCXCall.h"
#import "RCCall.h"
#import <AVFoundation/AVFoundation.h>

#define RCCXCallLocalizedName @"RongCloud"

@interface RCCXCall()
@property(nonatomic, strong) NSUUID *currentUUID;
@end


@implementation RCCXCall

+ (instancetype)sharedInstance {
    static RCCXCall *pCall;
    static dispatch_once_t onceToken;
    if (([UIDevice currentDevice].systemVersion.floatValue < 10.0)) {
        return nil;
    }
    dispatch_once(&onceToken, ^{
        if (pCall == nil) {
            pCall = [[RCCXCall alloc] init];
        }
    });
    return pCall;
}

- (void)startCall:(NSString *)userId {
    NSUUID *uuid = [NSUUID UUID];
    self.currentUUID = uuid;
}

- (void)reportOutgoingCallConnected {
}

- (void)reportIncomingCallWithInviter:(NSString *)inviterId
                           userIdList:(NSArray<NSString *> *)userIdList
                              isVideo:(BOOL)isVideo {
}

- (void)endCXCall {
    self.currentUUID = nil;
}

- (void)hangupIfNeedWithUUID:(NSString *)UUID {
    if (UUID.length == 0) {
        return;
    }
    if (![UUID isEqualToString:self.currentUUID.UUIDString]) {
        [[RCCall sharedRCCall].currentCallSession hangup];
    }
}

- (void)setAVAudioSessionMode{
}
@end
