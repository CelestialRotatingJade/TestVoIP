//
//  CRJCallKitEnum.h
//  VoIPTest
//
//  Created by 朱玉辉(EX-ZHUYUHUI001) on 2020/7/31.
//  Copyright © 2020 oopsr. All rights reserved.
//

#ifndef CRJCallKitEnum_h
#define CRJCallKitEnum_h

#ifdef DEBUG
#define CRJCallKitLog(...) NSLog(@"%s 第%d行 \n %@\n\n",__func__,__LINE__,[NSString stringWithFormat:__VA_ARGS__])
#else
#define CRJCallKitLog(...)
#endif

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSUInteger, CRJCallState) {
    CRJCallStateConnecting,
    CRJCallStateActive,
    CRJCallStateHeld,
    CRJCallStateEnded,
    CRJCallStateMuted
};

typedef NS_ENUM(NSUInteger, CRJCallConnectedState) {
    CRJCallConnectedStatePending,
    CRJCallConnectedStateComplete,
};

/**
 *  Quickblox WebRTC conference types.
 *
 *  - QBRTCConferenceTypeVideo: video conference type
 *  - QBRTCConferenceTypeAudio: audio conference type
 */
typedef NS_ENUM (NSUInteger, CRJCConferenceType) {
    CRJCConferenceTypeVideo = 1,
    CRJCConferenceTypeAudio = 2,
};

#endif /* CRJCallKitEnum_h */
