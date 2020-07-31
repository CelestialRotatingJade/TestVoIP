//
//  CRJCallKitManager.m
//  VoIPTest
//
//  Created by 朱玉辉(EX-ZHUYUHUI001) on 2020/7/31.
//  Copyright © 2020 oopsr. All rights reserved.
//

#import "CRJCall.h"
#import "CRJCallKitEnum.h"
#import "CRJCallKitManager.h"
@interface CRJCallKitManager ()
@property (nonatomic, strong) CXCallController *callController;
@end

@implementation CRJCallKitManager

+ (instancetype)shared {
    static CRJCallKitManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[CRJCallKitManager alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.calls = [NSMutableArray array];
        self.callController = [[CXCallController alloc] init];
    }
    return self;
}

- (CRJCall *)callWithUUID:(NSUUID *)uuid {
    for (CRJCall *call in self.calls) {
        if ([uuid isEqual:call.uuid]) {
            return call;
        }
    }
    return nil;
}

- (void)add:(CRJCall *)call {
    [self.calls addObject:call];
    __weak __typeof(self) weakSelf = self;
    call.stateChanged = ^{
        weakSelf.callsChangedHandler();
    };

    self.callsChangedHandler();
}

- (void)remove:(CRJCall *)call {
    [self.calls removeObject:call];
    self.callsChangedHandler();
}

- (void)removeAllCalls {
    [self.calls removeAllObjects];
    self.callsChangedHandler();
}

- (void)startCallWithHandle:(NSString *)handle videoEnabled:(BOOL)videoEnabled {
    //一个 CXHandle 对象表示了一次操作，同时指定了操作的类型和值。App支持对电话号码进行操作，因此我们在操作中指定了电话号码。
    CXHandle *cxHandle = [[CXHandle alloc] initWithType:CXHandleTypePhoneNumber value:handle];
    
    //一个 CXStartCallAction 用一个 UUID 和一个操作作为输入。
    CXStartCallAction *startCallAction = [[CXStartCallAction alloc] initWithCallUUID:[NSUUID UUID] handle:cxHandle];
    
    //你可以通过 action 的 video 属性指定通话是音频还是视频。
    startCallAction.video = videoEnabled;

    CXTransaction *transaction = [[CXTransaction alloc] initWithAction:startCallAction];
    [self requestTransaction:transaction];
}


#pragma mark - private
//调用 callController 的 request(_:completion:) 。系统会请求 CXProvider 执行这个 CXTransaction，这会导致你实现的委托方法被调用。
- (void)requestTransaction:(CXTransaction *)transaction {
    #ifdef DEBUG
        NSLog(@"[RNCallKit][requestTransaction] transaction = %@", transaction);
    #endif
    [self.callController requestTransaction:transaction completion:^(NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"[RNCallKit][requestTransaction] Error requesting transaction (%@): (%@)", transaction.actions, error);
        } else {
            NSLog(@"[RNCallKit][requestTransaction] Requested transaction successfully");
        }
    }];
}




@end
