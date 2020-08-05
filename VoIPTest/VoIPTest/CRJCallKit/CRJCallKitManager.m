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
#import "QBRTCSession.h"

typedef void (^AudioSessionInitializeBlock)(QBRTCSession *session);

static const NSInteger DefaultMaximumCallsPerCallGroup = 1;
static const NSInteger DefaultMaximumCallGroups = 1;

@interface CRJCallKitManager () <CXProviderDelegate>
@property (assign, nonatomic) BOOL isCallStarted;
@property (strong, nonatomic) CXProvider *provider;
@property (strong, nonatomic) CXCallController *callController;
@property (strong, nonatomic) NSMutableArray<CRJCall *> *calls;
@property (copy, nonatomic) dispatch_block_t actionCompletionBlock;
@property (copy, nonatomic) CompletionActionBlock onAcceptActionBlock;
@property (copy, nonatomic) AudioSessionInitializeBlock audioSessionInitializeBlock;
@property (weak, nonatomic) QBRTCSession *session;
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
        self.callController = [[CXCallController alloc] initWithQueue:dispatch_get_main_queue()];
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
        if (weakSelf.callsChangedHandler) {
            weakSelf.callsChangedHandler();
        }
    };

    if (self.callsChangedHandler) {
        self.callsChangedHandler();
    }
}

- (void)remove:(CRJCall *)call {
    [self.calls removeObject:call];
    if (self.callsChangedHandler) {
        self.callsChangedHandler();
    }
}

- (void)removeAllCalls {
    [self.calls removeAllObjects];
    if (self.callsChangedHandler) {
        self.callsChangedHandler();
    }
}

- (void)end:(CRJCall *)call {
    //先创建一个 CXEndCallAction。将通话的 UUID
    //传递给构造函数，以便在后面可以识别通话。
    CXEndCallAction *endCallAction = [[CXEndCallAction alloc] initWithCallUUID:call.uuid];
    //然后将 action 封装成 CXTransaction，以便发送给系统。
    CXTransaction *transaction = [[CXTransaction alloc] initWithAction:endCallAction];
    [self requestTransaction:transaction];
}

- (void)startCall:(NSString *)handle video:(BOOL)video {
    //一个 CXHandle
    //对象表示了一次操作，同时指定了操作的类型和值。App支持对电话号码进行操作，因此我们在操作中指定了电话号码。
    CXHandle *cxHandle = [[CXHandle alloc] initWithType:CXHandleTypePhoneNumber value:handle];

    //一个 CXStartCallAction 用一个 UUID 和一个操作作为输入。
    CXStartCallAction *startCallAction = [[CXStartCallAction alloc] initWithCallUUID:[NSUUID UUID] handle:cxHandle];

    //你可以通过 action 的 video 属性指定通话是音频还是视频。
    startCallAction.video = video;

    CXTransaction *transaction = [[CXTransaction alloc] initWithAction:startCallAction];
    [self requestTransaction:transaction];
}

- (void)setHeld:(CRJCall *)call onHold:(BOOL)onHold {
    //这个 CXSetHeldCallAction 包含了通话的 UUID 以及保持状态
    CXSetHeldCallAction *setHeldCallAction = [[CXSetHeldCallAction alloc] initWithCallUUID:call.uuid onHold:onHold];
    CXTransaction *transaction = [[CXTransaction alloc] init];
    [transaction addAction:setHeldCallAction];

    [self requestTransaction:transaction];
}

- (void)setMute:(CRJCall *)call muted:(BOOL)muted {
    // CXSetMutedCallAction设置麦克风静音
    CXSetMutedCallAction *setMuteCallAction = [[CXSetMutedCallAction alloc] initWithCallUUID:call.uuid muted:muted];
    CXTransaction *transaction = [[CXTransaction alloc] init];
    [transaction addAction:setMuteCallAction];
    [self requestTransaction:transaction];
}

#pragma mark - private
//调用 callController 的 request(_:completion:) 。系统会请求 CXProvider 执行这个
//CXTransaction，这会导致你实现的委托方法被调用。
- (void)requestTransaction:(CXTransaction *)transaction {
    CRJCallKitLog(@"[requestTransaction] transaction = %@", transaction);

    [self.callController requestTransaction:transaction
                                 completion:^(NSError *_Nullable error) {
                                     if (error != nil) {
                                         CRJCallKitLog(@"[requestTransaction] Error requesting transaction (%@): (%@)", transaction.actions, error);
                                     } else {
                                         CRJCallKitLog(@"[requestTransaction] Requested transaction successfully");
                                     }
                                 }];
}

@end
