//
//  CRJCall.m
//  VoIPTest
//
//  Created by 朱玉辉(EX-ZHUYUHUI001) on 2020/7/31.
//  Copyright © 2020 oopsr. All rights reserved.
//

#import "CRJCall.h"

@implementation CRJCall

- (instancetype)initWithUUID:(NSUUID *)uuid
                    outgoing:(BOOL)outgoing
                      handle:(NSString *)handle {
    self = [super init];
    if (self) {
        self.uuid = uuid;
        self.outgoing = outgoing;
        self.handle = handle;
    }
    return self;
}

- (void)setState:(CRJCallState)state {
    _state = state;
    !self.stateChanged ?: self.stateChanged();
}

- (void)setConnectedState:(CRJCallConnectedState)connectedState {
    _connectedState = connectedState;
    !self.connectedStateChanged ?: self.connectedStateChanged();
}

- (void)start:(void (^)(BOOL success))completion {
    !completion ?: completion(YES);

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.state = CRJCallStateConnecting;
        self.connectedState = CRJCallConnectedStatePending;

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.state = CRJCallStateActive;
            self.connectedState = CRJCallConnectedStateComplete;

        });
    });
}

- (void)answer {
    self.state = CRJCallStateActive;
}

- (void)end {
    self.state = CRJCallStateEnded;
}

@end
